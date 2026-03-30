global class SAPCodeGenerationLogSchedulable implements Schedulable {
    public String schedulable_name;

    global SAPCodeGenerationLogSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
    }


    global void execute(SchedulableContext sc) {

        deleteSchedulable(this.schedulable_name);
        // 当前时间N分钟，下一次定时时间
        DateTime reTime = System.Now().addMinutes(10);
        Integer second = reTime.second();
        Integer minute = reTime.minute();
        Integer hour = reTime.hour();  
        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

        // 生成唯一值
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        System.schedule('SAPCodeGenerationLogSchedulable' + h, con, new SAPCodeGenerationLogSchedulable('SAPCodeGenerationLogSchedulable' + h));


        List<User> ul = [select id from user where Email like '%megan.xing@hisense.com%'];
        //List<User> ul = [select id from user where Email like '%syssfcrm@hisense.com%'];
        

        if(ul != null && ul.size() > 0){
            List<LoginHistory> lhList = [SELECT Id,LoginTime FROM LoginHistory where UserId =: ul.get(0).Id order by LoginTime desc limit 2];
            
            Datetime endTime = System.now();
            Datetime startTime = endTime.addDays(-1);
            if(lhList != null && lhList.size() >= 2){
                endTime = lhList.get(0).LoginTime;
                startTime = lhList.get(1).LoginTime;
            }

            List<SAP_Code_Generation_Log__c> checkList = [select id from SAP_Code_Generation_Log__c where LoginTime__c =:endTime];
            if(checkList != null && checkList.size() > 0){
                return;
            }

            SAP_Code_Generation_Log__c sagl = new SAP_Code_Generation_Log__c();
            sagl.LoginTime__c = endTime;
            insert sagl;

            //xxxx（客户编码+客户名称）客户已经完成审批，请前往SAP维护信用额度。
            List<Customer_Extend__c> ceList = [select id,Customer__r.SAP_Customer_Code__c,Customer__r.Customer_Name_Local_Language__c,Customer__r.Customer_Name_Local_Language_2__c 
            from Customer_Extend__c where Payment_Term__r.Name != 'G007' and Customer__r.SAP_Code_Generation_Time__c > :startTime and Customer__r.SAP_Code_Generation_Time__c <: endTime and Customer__r.Hisense_Entity__c in ('8200','8210')];
            if(ceList != null && ceList.size() > 0){
                String bodyStr = '客户已经完成审批，请前往SAP维护信用额度。';
                String customerStr = '';
                for(Customer_Extend__c ce : ceList){
                    customerStr += ce.Customer__r.SAP_Customer_Code__c + '+' + ce.Customer__r.Customer_Name_Local_Language__c + ce.Customer__r.Customer_Name_Local_Language_2__c + '，';
                }

                sagl.Name = bodyStr;
                sagl.Body__c = customerStr + bodyStr;
                update sagl;

                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle(bodyStr);
                currNotification.setBody(customerStr + bodyStr);
                currNotification.setNotificationTypeId([SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Custom_Notification'].Id);
                
                currNotification.setTargetId(sagl.Id);
                
                // Send the notification
                try {
                    currNotification.send(new Set<String>{ul.get(0).Id});
                }
                catch (Exception ex) {
                    string msg = 'Notification Failed: ' + ex.getMessage();
                    System.debug(msg);
                }
            }
        }
    }

    public static void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
    }
}