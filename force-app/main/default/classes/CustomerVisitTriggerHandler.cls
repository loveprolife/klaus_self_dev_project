public class CustomerVisitTriggerHandler implements Triggers.Handler{
    
    public void handle() {

        if (Trigger.isAfter && Trigger.isUpdate) {
            // Set<String> accountIdSet = new Set<String>();
            // List<Customer_Visit__c> customerVistList = new List<Customer_Visit__c>();
            // List<Customer_Visit__c> updateList = new List<Customer_Visit__c>();
            // 流程审批人权限
            for (Customer_Visit__c cv : ((list<Customer_Visit__c>)Trigger.new)) {
                Customer_Visit__c cvOld = (Customer_Visit__c)Trigger.oldMap.get(cv.Id);
                // 判断提交流程
                if(cv.Approval_Status__c != null && 'Submitted'.equals(cv.Approval_Status__c) && !cvOld.Approval_Status__c.equals(cv.Approval_Status__c)) {
                    try {
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addMinutes(1);
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = '0 ' + minute + ' ' + hour + ' * * ?';
            
                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.schedule(h, con, new CustomerVisitSchedulable(cv.Id, h));
                    } catch (Exception e) {
                        system.debug('error message'+e.getMessage());
                        system.debug('line number'+e.getLineNumber());    
                    }
                }

                // 判断是否是审批流程修改数据
                if(cvOld.Approval_Status__c != null && cv.Approval_Status__c != null && !cvOld.Approval_Status__c.equals(cv.Approval_Status__c)){
                }else{
                    updateEventForCustomerVisit((List<Customer_Visit__c>)Trigger.new);
                }

                //-add：客户拜访邮件 chiara - date:2022/02/10
                // if(cv.Status__c == 'Completed' && cv.isSendEmail__c && cv.Customer_Sales_Region__c == 'Hisense Japan') {
                //     customerVistList.add(cv);
                //     accountIdSet.add(cv.Customer__c);

                //     Customer_Visit__c cvNew = new Customer_Visit__c();
                //     cvNew.id = cv.id;
                //     cvNew.isSendEmail__c = false;
                //     updateList.add(cvNew);
                // }
            }

            // sendEmailNotification(accountIdSet, customerVistList);

            //忽略触发器更新
            // GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerVisitTriggerHandler');
            // if(!Test.isRunningTest()){
            //     UPDATE updateList;
            // }

            // //恢复触发器
            // Utility.IgnoreAction(false,false,false,'');
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            Set<Id> accoutId = new Set<Id>();
            for(Customer_Visit__c cVisit : (List<Customer_Visit__c>)Trigger.new){
                accoutId.add(cVisit.Customer__c);
            }
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id,UserId,User.Email FROM AccountTeamMembers) FROM Account WHERE Id IN: accoutId]);

            // 状态为Completed 则赋值VisitCompletedDate为今天
            for(Customer_Visit__c cVisit : (List<Customer_Visit__c>)Trigger.new){
                Customer_Visit__c cvOld = (Customer_Visit__c)Trigger.oldMap.get(cVisit.Id);
                // 判断是否是审批流程修改数据
                if(cvOld.Approval_Status__c != null && cVisit.Approval_Status__c != null && !cvOld.Approval_Status__c.equals(cVisit.Approval_Status__c)){
                }else{
                    if(cVisit.Status__c == 'Completed' && cVisit.VisitCompletedDate__c == null) {
                        cVisit.VisitCompletedDate__c = Date.TODAY();
                    }
                } 
                
                // 添加Send_Email_Address__c 客户team邮箱
                // if(accountMap.containsKey(cVisit.Customer__c)) {
                //     String emailAddress = '';
                //     String emailAddressTemp = '';
                //     Integer i = 0;
                //     Integer j = 1;
                //     if(null != accountMap.get(cVisit.Customer__c).AccountTeamMembers && accountMap.get(cVisit.Customer__c).AccountTeamMembers.size() > 0){
                //         for(AccountTeamMember atmItem : accountMap.get(cVisit.Customer__c).AccountTeamMembers) { 
                //             emailAddress += atmItem.User.Email + ',';
                //             emailAddressTemp += atmItem.User.Email + ',';
                //             i++;
                //             if(i == 5){
                //                 String fieldName = 'Send_Email_Address' + j + '__c';
                //                 cVisit.put(fieldName, emailAddressTemp.substring(0, emailAddressTemp.length() - 1));
                //                 i = 0;
                //                 j++;
                //                 emailAddressTemp = '';
                //             }
                //         }
                //         if(emailAddressTemp != ''){
                //             String fieldName = 'Send_Email_Address' + j + '__c';
                //             cVisit.put(fieldName, emailAddressTemp.substring(0, emailAddressTemp.length() - 1));
                //             j++;
                //         }
                //         cVisit.Send_Email_Address__c = emailAddress.substring(0, emailAddress.length() - 1);

                //         if(j <= Integer.valueOf(Label.Customer_Visit_Send_Email)){
                //             for(Integer k = 0; k <= Integer.valueOf(Label.Customer_Visit_Send_Email) - j; k = 0){
                //                 String fieldName = 'Send_Email_Address' + j + '__c';
                //                 cVisit.put(fieldName, '');
                //                 j++;
                //             }
                //         }
                //     } 
                // }
            }
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            Set<Id> accoutId = new Set<Id>();
            for(Customer_Visit__c cVisit : (List<Customer_Visit__c>)Trigger.new){
                accoutId.add(cVisit.Customer__c);
            }
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id,UserId,User.Email FROM AccountTeamMembers) FROM Account WHERE Id IN: accoutId]);

            // 状态为Completed 则赋值VisitCompletedDate为今天
            for(Customer_Visit__c cVisit : (List<Customer_Visit__c>)Trigger.new){
                if(cVisit.Status__c == 'Completed' && cVisit.VisitCompletedDate__c == null) {
                    cVisit.VisitCompletedDate__c = Date.TODAY();
                }

                // 添加Send_Email_Address__c 客户team邮箱
                // if(accountMap.containsKey(cVisit.Customer__c)) {
                //     String emailAddress = '';
                //     String emailAddressTemp = '';
                //     Integer i = 0;
                //     Integer j = 1;
                //     if(null != accountMap.get(cVisit.Customer__c).AccountTeamMembers && accountMap.get(cVisit.Customer__c).AccountTeamMembers.size() > 0){
                //         for(AccountTeamMember atmItem : accountMap.get(cVisit.Customer__c).AccountTeamMembers) { 
                //             emailAddress += atmItem.User.Email + ',';
                //             emailAddressTemp += atmItem.User.Email + ',';
                //             i++;
                //             if(i == 5){
                //                 String fieldName = 'Send_Email_Address' + j + '__c';
                //                 cVisit.put(fieldName, emailAddressTemp.substring(0, emailAddressTemp.length() - 1));
                //                 i = 0;
                //                 j++;
                //                 emailAddressTemp = '';
                //             }
                //         }
                //         if(emailAddressTemp != ''){
                //             String fieldName = 'Send_Email_Address' + j + '__c';
                //             cVisit.put(fieldName, emailAddressTemp.substring(0, emailAddressTemp.length() - 1));
                //             j++;
                //         }
                //         cVisit.Send_Email_Address__c = emailAddress.substring(0, emailAddress.length() - 1);

                //         if(j <= Integer.valueOf(Label.Customer_Visit_Send_Email)){
                //             for(Integer k = 0; k <= Integer.valueOf(Label.Customer_Visit_Send_Email) - j; k = 0){
                //                 String fieldName = 'Send_Email_Address' + j + '__c';
                //                 cVisit.put(fieldName, '');
                //                 j++;
                //             }
                //         }
                //     } 
                // }
            }
 
        }

        //added by johnson zhang20200219
        if (Trigger.isAfter && Trigger.isInsert) {
            // Set<String> accountIdSet = new Set<String>();
            // List<Customer_Visit__c> customerVistList = new List<Customer_Visit__c>();
            // List<Customer_Visit__c> updateList = new List<Customer_Visit__c>();
            Map<String, String> vpRecordTypeMap = Utility.getRecordTypeMapBySobj('Visit_Participant__c');
            List<Visit_Participant__c> insertCVOwnerList = new List<Visit_Participant__c>();
            String idStr = '';
            for(Customer_Visit__c cVisit : (List<Customer_Visit__c>)Trigger.new){
                Visit_Participant__c insertCVOwner = new Visit_Participant__c();
                insertCVOwner.Customer_Visit__c = cVisit.Id;
                insertCVOwner.Hisense_Participant__c = cVisit.OwnerId;
                insertCVOwner.RecordTypeId = vpRecordTypeMap.get('Hisense_Participant');
                insertCVOwnerList.add(insertCVOwner);

                // //-add：客户拜访邮件 chiara - date:2022/02/10
                // if(cVisit.Status__c == 'Completed' && cVisit.isSendEmail__c && cVisit.Customer_Sales_Region__c == 'Hisense Japan') {
                //     customerVistList.add(cVisit);
                //     accountIdSet.add(cVisit.Customer__c);

                //     Customer_Visit__c cvNew = new Customer_Visit__c();
                //     cvNew.id = cVisit.id;
                //     cvNew.isSendEmail__c = false;
                //     updateList.add(cvNew);
                // }

                idStr += '\'' + cVisit.id + '\',';
            }
            if(insertCVOwnerList.size() > 0){
                try{
                    insert insertCVOwnerList;                
                }catch(Exception e){
                    system.debug('error message: '+e.getMessage());
                    system.debug('line number: '+e.getLineNumber());
                }
                
            }

            // sendEmailNotification(accountIdSet, customerVistList);

            // //忽略触发器更新
            // GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerVisitTriggerHandler');
            // if(!Test.isRunningTest()){
            //     UPDATE updateList;
            // }
            
            // //恢复触发器
            // Utility.IgnoreAction(false,false,false,'');

            String sql = 'SELECT IsNew__c,IsChange__c,Customer_Code__c FROM Customer_Visit__c WHERE (Customer__r.Sales_Region__c  = \'Hisense Japan\' OR Customer__r.Hisense_Entity__c = \'8410\') ';
            sql += ' AND id IN ( ' + idStr.substring(0, idStr.length()-1) + ' )';
            Share_Common_IntegrationBatch aprShareBatch = new Share_Common_IntegrationBatch(
                'Customer_Visit__c', 
                false, 
                '',
                0,
                sql
            );
            Database.executeBatch(aprShareBatch, 30);

        }

        if (Trigger.isBefore && Trigger.isDelete) {
            removeEvents((List<Customer_Visit__c>)Trigger.old);
        }

    }

    public void removeEvents(List<Customer_Visit__c> cvs){
        if(cvs == null || cvs.isEmpty()){
            return ;
        }
        List<Event> events = [
            SELECT Id, Customer_Visit__c,Status__c,IsAllDayEvent,
                StartDateTime,Remark__c,Location,OwnerId,Description,
                Subject,Customer__c
            FROM Event
            WHERE Customer_Visit__c in: cvs
        ];
        if(events != null && events.size()>0 ){
            delete events;
        }
    }
    
    public void updateEventForCustomerVisit(List<Customer_Visit__c> cvs){
        if(cvs == null || cvs.isEmpty()){
            return ;
        }
        Set<String> accountIds = new Set<String>();
        for(Customer_Visit__c cv: cvs){
            accountIds.add(cv.Customer__c);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id,Name 
            FROM Account
            WHERE Id 
            IN :accountIds
        ]);
        List<Event> events = [
            SELECT Id, Customer_Visit__c,Status__c,IsAllDayEvent,
                StartDateTime,Remark__c,Location,OwnerId,Description,
                Subject,Customer__c
            FROM Event
            WHERE Customer_Visit__c in: cvs
        ];

        Map<String, Event> evMap = new Map<String, Event>();
        for(Event evt: events){
            evMap.put(evt.Customer_Visit__c, evt);
        }

        List<Event> upsertEvents = new List<Event>();
        for(Customer_Visit__c cv: cvs){
            if(cv.Visit_Date__c == null){
                continue;
            }

            Event evt = evMap.get(cv.Id);
            if(evt==null) {
                evt = new Event();
                evt.Customer_Visit__c = cv.Id;
                evt.Status__c = 'Not Started';
                evt.IsAllDayEvent = true;
            }
            evt.StartDateTime = cv.Visit_Date__c;
            // evt.Remark__c = cv.Notes__c;
            evt.Location = cv.Place__c;
            evt.OwnerId = cv.OwnerId;
            Account acc = accMap.get(cv.Customer__c);
            evt.Description = String.format('Customer Visit {0}, Visit Category: {1}', 
                new List<String> {acc.Name, cv.Visit_Category__c});
            evt.Subject = String.format('Customer Visit {0}, Visit Category: {1}', 
                new List<String> {acc.Name, cv.Visit_Category__c});
            evt.Customer__c = cv.Customer__c;
            upsertEvents.add(evt);
        }

        if(upsertEvents.size() > 0) {
            upsert upsertEvents;
        }
    }

    // public void sendEmailNotification(Set<String> accountIdSet, List<Customer_Visit__c> customerVistList) {
    //     if(accountIdSet.size() > 0) {
    //         List<EmailTemplate> etList = EmailNotificationUtility.getEmailTemplate('CustomerVisitEmailTemplate');
    //         if(etList.size() > 0) {
    //             Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id,UserId,User.Email FROM AccountTeamMembers) FROM Account WHERE Id IN: accountIdSet]);
    //             List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
    //             for(Customer_Visit__c cvItem : customerVistList) {
    //                 if(accountMap.containsKey(cvItem.Customer__c)) {
    //                     Messaging.SingleEmailMessage craMail = new Messaging.SingleEmailMessage();
    //                     List<String> emailAddressList = new List<String>();
    //                     for(AccountTeamMember atmItem : accountMap.get(cvItem.Customer__c).AccountTeamMembers) {
    //                         emailAddressList.add(atmItem.User.Email);
    //                     }
    //                     craMail.setWhatId(cvItem.Id);
    //                     craMail.setToAddresses(emailAddressList);
    //                     craMail.setSaveAsActivity(false);
    //                     craMail.setUseSignature(false);
    //                     craMail.setTreatTargetObjectAsRecipient(false); 
    //                     semList.add(craMail);
    //                 }
    //             }
    //             EmailNotificationUtility.sendEmailNotificationWithDummyContact(etList[0],semList);
    //             /*
    //             Savepoint sp = Database.setSavepoint();
    //             //建立虚假contact
    //             Contact dummyCon = new Contact(LastName ='dummyCon',Email = 'dummy@contact.com'); 
    //             insert dummyCon;
    //             Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id,UserId,User.Email FROM AccountTeamMembers) FROM Account WHERE Id IN: accountIdSet]);
    //             List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
    //             for(Customer_Visit__c cvItem : customerVistList) {
    //                 if(accountMap.containsKey(cvItem.Customer__c)) {
    //                     Messaging.SingleEmailMessage craMail = new Messaging.SingleEmailMessage();
    //                     List<String> emailAddressList = new List<String>();
    //                     for(AccountTeamMember atmItem : accountMap.get(cvItem.Customer__c).AccountTeamMembers) {
    //                         emailAddressList.add(atmItem.User.Email);
    //                     }
    //                     craMail.setWhatId(cvItem.Id);
    //                     craMail.setTemplateId(etList[0].Id);
    //                     craMail.setTargetObjectId(dummyCon.Id);
    //                     craMail.setToAddresses(emailAddressList);
    //                     craMail.setSaveAsActivity(false);
    //                     craMail.setUseSignature(false);
    //                     craMail.setTreatTargetObjectAsRecipient(false); 
    //                     semList.add(craMail);
    //                 }
    //             }
    //             System.debug('semList:' + semList);
    //             EmailNotificationUtility.messageSendEmail(semList);
    //             //Messaging.sendEmail(semList);
    //             System.debug('semList:' + semList);
    //             Database.rollback(sp);
    //             List<Messaging.SingleEmailMessage> semWithoutTemplateList = new List<Messaging.SingleEmailMessage>();
    //             for(Messaging.SingleEmailMessage semTemp : semList){
    //                 Messaging.SingleEmailMessage semWithoutTemplate = new Messaging.SingleEmailMessage();
    //                 if(String.IsNotBlank(semTemp.getPlainTextBody())){
    //                     semWithoutTemplate.setPlainTextBody(semTemp.getPlainTextBody());
    //                 }else if( String.IsNotBlank(semTemp.getHtmlBody()) ){
    //                     semWithoutTemplate.setHtmlBody(semTemp.getHtmlBody());
    //                 }else if( String.IsNotBlank( etList[0].HtmlValue ) ){
    //                     semWithoutTemplate.setHtmlBody( etList[0].HtmlValue );
    //                 }else if(  String.IsNotBlank( etList[0].Body ) 
    //                     &&  !etList[0].Body.equalsIgnoreCase('Error') ){
    //                     semWithoutTemplate.setPlainTextBody( etList[0].Body );
    //                 }else{
    //                     break;
    //                 }
    //                 semWithoutTemplate.setToAddresses(semTemp.getToAddresses());
    //                 semWithoutTemplate.setSubject(semTemp.getSubject());
    //                 semWithoutTemplateList.add(semWithoutTemplate);
    //             }
    //             system.debug('semWithoutTemplateList:'+semWithoutTemplateList);
    //             EmailNotificationUtility.messageSendEmail(semWithoutTemplateList);
    //             //Messaging.sendEmail(semWithoutTemplateList);
    //             */
    //         }
    //     }
    // }
}