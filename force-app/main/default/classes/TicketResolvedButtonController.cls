public without sharing class TicketResolvedButtonController {
    @AuraEnabled
    public static ConResponse saveRecord(String recordId){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Ticket__c ticket = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, 
                                    PromoterDailyReport__c, Newest_Feedback__c, Histories_Feedback__c
                                        FROM Ticket__c 
                                        WHERE Id = :recordId];
        
        System.Savepoint sp = Database.setSavepoint();
        try{  
            ticket.Status__c = 'Resolved';
            update ticket;

            resp.message = 'Success';
        }catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;                             
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Ticket__c ticket = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, 
                                    PromoterDailyReport__c, Newest_Feedback__c, Histories_Feedback__c
                                        FROM Ticket__c 
                                        WHERE Id = :recordId];
        String message = 'Resolve this ticket.';
        Boolean notResolved = true;
        if(UserInfo.getUserId() != ticket.AssignedTo__c) {
            message = 'The ticket is not assigned to you and you cannot change its status to resolved.';
            notResolved = false;
        } else if (ticket.Status__c != 'Open') {
            message = 'This ticket has ' + ticket.Status__c + ' !';
            notResolved = false;
        }
        System.debug('message：' + message);
        mso.put('ticket', ticket);
        mso.put('message', message);
        mso.put('notResolved', notResolved);
        resp.data = mso;
        return resp;
        
    }

    @AuraEnabled
    public static ConResponse editGetInitData(String recordId){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Ticket__c ticket = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, Department__c,
                                    PromoterDailyReport__c, Newest_Feedback__c, Histories_Feedback__c, OwnerId, ResponsibleDepartmentUserIds__c
                                FROM Ticket__c 
                                WHERE Id = :recordId];
        // List<String> userIdList = String.isBlank(ticket.ResponsibleDepartmentUserIds__c) ? new List<String>() : ticket.ResponsibleDepartmentUserIds__c.split(';');
        
        String userId = UserInfo.getUserId();        
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        Boolean isChile = (currentUser[0].Sales_Region__c == 'Hisense Chile');
        mso.put('isChile', isChile);

        // Department User
        List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c = :currentUser[0].Sales_Region__c AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> userGroupByDepartment = lc.GroupByS('Department__c');
        for(String item : userGroupByDepartment.keySet()) {
            mso.put(item, (new Map<Id, Sobject>(userGroupByDepartment.get(item).ToSobjectList())).keySet());
        }

        
        Boolean isOwner = (userId == ticket.OwnerId);
        Boolean isAssigned = (userId == ticket.AssignedTo__c);
        Boolean isFelipe = ((currentUser[0].Name == 'Felipe Aedo') || (currentUser[0].Email == 'felipe.aedo@hisense.com'));
    
        Set<Id> userIdList = new Set<Id>();
        if((!String.isBlank(ticket.Department__c)) && userGroupByDepartment.containsKey(ticket.Department__c)) {
            userIdList = (new Map<Id, Sobject>(userGroupByDepartment.get(ticket.Department__c).ToSobjectList())).keySet();
        }

        Boolean departmentTicket = false;
        if((ticket.AssignedTo__c == null) && (userIdList.contains(userId))) {
            isAssigned = true;
            departmentTicket = true;
            ticket.AssignedTo__c = userId;
        }
        mso.put('ticket', ticket);
        mso.put('isOwner', isOwner);
        mso.put('isAssigned', isAssigned);
        mso.put('departmentTicket', departmentTicket);
        mso.put('isFelipe', isFelipe);
        mso.put('fields', SObjectHelper.getFieldLabelMap('Ticket__c'));
        resp.data = mso;
        return resp;
    }

    @AuraEnabled
    public static ConResponse editSaveRecord(String recordJson){

        System.debug('recordJson: ' + recordJson);

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        Ticket__c ticket = (Ticket__c)JSON.deserialize(recordJson, Ticket__c.class);

        User user = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()][0];
        // if((ticket.ResponsibleDepartmentUserIds__c != null) && ((assignedTo == null) || (assignedTo == ''))) {
        //     assignedTo = user.Id;
        // }

        if(!String.isBlank(ticket.Newest_Feedback__c)) {
            String editInfo = user.Name + '&emsp;&emsp;' + datetime.now() + '&emsp; :  <br>' + ticket.Newest_Feedback__c;
            if(ticket.Histories_Feedback__c == null) {
                ticket.Histories_Feedback__c = editInfo;
            } else {
                ticket.Histories_Feedback__c += editInfo;
            }
            ticket.Newest_Feedback__c = null;
        }   

        System.Savepoint sp = Database.setSavepoint();
        try{              

            update ticket;

            resp.message = 'Success';
        }catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e.getMessage());
        	System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;                             
    }
    

}