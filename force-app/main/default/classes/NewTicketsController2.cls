public with sharing class NewTicketsController2 {
    

    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        System.debug('recordId=' + recordId);
        ConResponse resp = new ConResponse();
        try {
            Map<String,Object> mso = new Map<String,Object>();
            List<Ticket__c> recordList = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, PromoterDailyReport__c, Department__c, Category__c, Product__c
                                            FROM Ticket__c 
                                            WHERE PromoterDailyReport__c = :recordId
                                            ORDER BY Name];

            String userId = UserInfo.getUserId();
            List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
            // Boolean hasDepartment = (currentUser[0].Sales_Region__c != 'Hisense Indonesia');
            mso.put('userRegion', currentUser[0].Sales_Region__c);

            // Department User
            // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c = :currentUser[0].Sales_Region__c AND IsActive = true];
            // LisqContainer lc = new LisqContainer(departmentUserList);
            // Map<String, LisqContainer> userGroupByDepartment = lc.GroupByS('Department__c');
            // for(String item : userGroupByDepartment.keySet()) {
            //     mso.put(item, (new Map<Id, Sobject>(userGroupByDepartment.get(item).ToSobjectList())).keySet());
            // }

            mso.put('recordList', recordList);
            mso.put('fields', SObjectHelper.getFieldLabelMap('Ticket__c'));
            mso.put('userId', UserInfo.getUserId());
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static ConResponse saveData(String recordListJson, String recordId, String fileMapJson, String[] deleteIds){
        System.debug('recordListJson=' + recordListJson);
        System.debug('recordId=' + recordId);
        System.debug('fileMapJson=' + fileMapJson.length());
        System.debug('deleteIds=' + deleteIds);
        ConResponse resp = new ConResponse();
        try {
            Database.delete(deleteIds, false);
            
            String recordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'Ticket__c' AND DeveloperName = 'Promoter'].Id;
            List<Ticket__c> taskList = (List<Ticket__c>)JSON.deserialize(recordListJson, List<Ticket__c>.class);
            String checkDepartmentResult = checkDepartment(taskList);
            if(checkDepartmentResult != null) {
                resp.code = -1;
                resp.message = checkDepartmentResult;
                return resp;
            }
            for(Ticket__c item : taskList) {
                item.RecordTypeId = recordTypeId;
            }
            upsert taskList;
            System.debug('taskList=========>' + taskList);
            UploadFilesController.saveFiles(recordListJson, fileMapJson, taskList, recordId);

            taskList = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, PromoterDailyReport__c, Department__c, Category__c, Product__c
                            FROM Ticket__c 
                            WHERE PromoterDailyReport__c = :recordId
                            ORDER BY Name];
            Map<String, Object> mso = new Map<String, Object>();
            mso.put('recordList', taskList);
            System.debug('recordList=========>' + taskList);
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }
    //获取部门下的每个人
    @AuraEnabled
    public static List<User> getDepartmentUsers(String department){
        try {
            return [Select Id,Name,Email FROM User where department__c =:department];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static ConResponse newTicketGetInitData(){
        ConResponse resp = new ConResponse();

        Map<String, Object> mso = new Map<String, Object>();
        mso.put('fields', SObjectHelper.getFieldLabelMap('Ticket__c'));

        String userId = UserInfo.getUserId();
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        // Boolean hasDepartment = (currentUser[0].Sales_Region__c != 'Hisense Indonesia');
        mso.put('userRegion', currentUser[0].Sales_Region__c);

        // Department User
        // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c = :currentUser[0].Sales_Region__c AND IsActive = true];
        // LisqContainer lc = new LisqContainer(departmentUserList);
        // Map<String, LisqContainer> userGroupByDepartment = lc.GroupByS('Department__c');
        // for(String item : userGroupByDepartment.keySet()) {
        //     mso.put(item, (new Map<Id, Sobject>(userGroupByDepartment.get(item).ToSobjectList())).keySet());
        // }
        
        resp.data = mso;
        return resp;
    }

    @AuraEnabled
    public static ConResponse newTicketSaveData(String recordListJson, String fileMapJson){
        System.debug('recordListJson=' + recordListJson);
        System.debug('fileMapJson=' + fileMapJson.length());

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try {
            
            String recordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'Ticket__c' AND DeveloperName = 'Default'].Id;
            List<Ticket__c> taskList = (List<Ticket__c>)JSON.deserialize(recordListJson, List<Ticket__c>.class);
            //String checkDepartmentResult = checkDepartment(taskList);
            // if(checkDepartmentResult != null) {
            //     resp.code = -1;
            //     resp.message = checkDepartmentResult;
            //     return resp;
            // }
            for(Ticket__c item : taskList) {
                item.RecordTypeId = recordTypeId;
            }

            if(taskList.size() > 0) {

                upsert taskList;
                UploadFilesController.saveFiles(recordListJson, fileMapJson, taskList, taskList[0].Id);
                mso.put('ticketId', taskList[0].Id);
            }
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static ConResponse newTicketSaveData2(String ticketJson, List<Map<String,Object>> filesInfo){
        System.debug('wwww---ticketJson=' + ticketJson);
        System.debug('wwww---filesInfo=' + JSON.serialize(filesInfo));

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try {
            Ticket__c ticket = (Ticket__c)JSON.deserialize(ticketJson, Ticket__c.class);
            ticket.RecordTypeId = Schema.SobjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
            upsert ticket;

            if(!filesInfo.isEmpty()){
                List<ContentVersion> cvAddList = new List<ContentVersion>();
                for(Map<String,Object> file : filesInfo){
                    ContentVersion cv = new ContentVersion();
                    String name = String.valueOf(file.get('name'));
                    Integer i = name.lastIndexOf('.');
                    cv.Title = name.substring(0, i);
                    cv.PathOnClient = name;
                    String base64Str = String.valueOf(file.get('base64'));
                    Integer j = base64Str.indexOf('base64,');
                    cv.VersionData = EncodingUtil.base64Decode(base64Str.substring(j + 7));
                    cv.FirstPublishLocationId = ticket.Id;
                    cvAddList.add(cv);
                }
                insert cvAddList;
            }

            mso.put('ticketId', ticket.Id);
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }
    
    
    public static String checkDepartment(List<Ticket__c> newList) {

        String userId = UserInfo.getUserId();
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        String salesRegion = currentUser[0].Sales_Region__c;

        List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> departemntUserMap = lc.GroupByS('Department__c');

        for(Ticket__c item : newList) {
            if((String.isBlank(item.AssignedTo__c)) && !String.isBlank(item.Department__c)) {
                if(!departemntUserMap.containsKey(item.Department__c)) {
                    // item.addError(Label.Ticket_ReSelect_Department);
                    return Label.Ticket_ReSelect_Department;
                } else {
                    if(!String.isBlank(salesRegion)) {
                        Map<String, LisqContainer> userGroupByRegion = departemntUserMap.get(item.Department__c).GroupByS('Sales_Region__c');
                        if(!userGroupByRegion.containsKey(salesRegion)) {
                            // item.addError(Label.Ticket_ReSelect_Department);
                            return Label.Ticket_ReSelect_Department;
                        }
                    }
                }
            }
        }
        return null;

    }

    @AuraEnabled
    public static ConResponse handlerRemove(){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('isSuccess', true);
        resp.data = mso;
        return resp;
    }

    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-08-05 11:40:00
     * @Description: 查询查询 Ticket_Auto_Assigned__c 表，自动指派
     */    
    @AuraEnabled
    public static ConResponse autoAssigned(String sbu, String category, String productLine){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        // 查询配置的自动指派数据,，排除产品线维度
        List<Ticket_Auto_Assigned__c> ticketAutoAssignedList = [SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.Username, Assigned_To__r.FullPhotoUrl, Department__c
                                                                FROM Ticket_Auto_Assigned__c
                                                                WHERE SBU__c = :sbu
                                                                AND Category__c = :category
                                                                AND Product_Line__c = null
                                                                ORDER BY CreatedDate];
        // 产品线不为空时，查询产品线维度的自动指派数据
        if(String.isNotBlank(productLine)){
            List<Ticket_Auto_Assigned__c> ticketAutoAssignedProductLineList = [SELECT Id, Assigned_To__c, Assigned_To__r.Name, Assigned_To__r.Username, Assigned_To__r.FullPhotoUrl, Department__c
                                                                FROM Ticket_Auto_Assigned__c
                                                                WHERE SBU__c = :sbu
                                                                AND Category__c = :category
                                                                AND Product_Line__c IN :productLine.split(',')
                                                                ORDER BY CreatedDate];
            ticketAutoAssignedList.addAll(ticketAutoAssignedProductLineList);
        }
        if(!ticketAutoAssignedList.isEmpty()){
            mso.put('ticketAutoAssignedList', ticketAutoAssignedList);
        }else {
            resp.code = -1;
        }
        resp.data = mso;
        return resp;
    }
}