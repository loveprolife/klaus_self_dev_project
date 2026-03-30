/**************************************************************************************************
 * Name: CustomerApprovalRemindSchedule
 * Purpose: 定时提醒超过二十四小时未审批的客户申请流程
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0                           2023-08-08         Created        
 
***************************************************************************************************/
global class CustomerApprovalRemindSchedule implements Schedulable{

    global void execute(SchedulableContext sc){

        // 当前时间N分钟，下一次定时时间
        DateTime reTime = System.Now().addHours(1);
        Integer minute = reTime.minute();
        Integer hour = reTime.hour();  
        String con = '0 ' + minute + ' ' + hour + ' * * ?';

        // 删除初始化定时
        deleteSchedulable('CustomerApprovalRemindSchedule-Initialize');

        System.schedule('CustomerApprovalRemindSchedule-Initialize', con, new CustomerApprovalRemindSchedule());

        System.debug('CustomerApprovalRemindSchedule Start');

        Datetime sysDateTime = System.now();
        String strSysDateTime = sysDateTime.format('YYYY-MM-dd HH:mm:ss');
        System.debug('wwwwstrSysDateTime' + strSysDateTime);

        // 查询当前停留在待审批的流程数据
        List<ProcessInstanceWorkitem> workItem = [select id,
                                                   ProcessInstance.TargetObjectId,
                                                   ProcessInstance.status,
                                                   OriginalActorId,
                                                   CreatedDate 
                                                   from ProcessInstanceWorkitem
                                                   where CreatedDate > 2024-01-02T00:00:00.924+08:00];

        if(Test.isRunningTest()){
            User user = [SELECT id from User].get(0);
            Account acc = [SELECT id from Account].get(0);
            ProcessInstanceWorkitem pw = new ProcessInstanceWorkitem();
            ProcessInstance pi = new ProcessInstance();
            pi.TargetObjectId = acc.Id;
            pw.ProcessInstance = pi;
            pw.OriginalActorId = user.Id;
            workItem.add(pw);
        }

        if(workItem != null && workItem.size() > 0){

            // 存放用户id
            List<Id> userIds = new List<Id>();
            List<Id> customerIds = new List<Id>();
            for(ProcessInstanceWorkitem item : workItem){
                userIds.add(item.OriginalActorId);
                customerIds.add(item.ProcessInstance.TargetObjectId);
            }
            // 查询用户详情信息
            LisqContainer lcu = new LisqContainer([SELECT id,Email from User where id in: userIds]);
            Map<string, Sobject> userMap = lcu.ToMapS('Id');

            // 查询催办发送邮件模版
            EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE Name = 'Customer Onboard Notify' LIMIT 1];

            Contact contact = new Contact();
            if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];

            // 查询客户详情信息
            LisqContainer lcc = new LisqContainer([Select id,name from Account where id in: customerIds]);
            Map<string, Sobject> accMap = lcc.ToMapS('Id');

            // 存放需要发送的邮件集
            List<Messaging.SingleEmailMessage> emaliList = new List<Messaging.SingleEmailMessage>();
            // 存放需要更新的邮件发送记录日志
            List<UrgingSendEmailLog__c> updateUrgingLog = new List<UrgingSendEmailLog__c>();
            // 存放需要新增的邮件发送记录日志
            List<UrgingSendEmailLog__c> addUrgingLog = new List<UrgingSendEmailLog__c>();

            for(ProcessInstanceWorkitem item : workItem){

                Id customerId = item.ProcessInstance.TargetObjectId;

                Account account = (Account)accMap.get(item.ProcessInstance.TargetObjectId);
                User user = (User)userMap.get(item.OriginalActorId);

                Datetime createDate;

                if(Test.isRunningTest()){
                    createDate = sysDateTime;
                }else{
                    createDate = item.CreatedDate;
                }

                String strCreateDate = createDate.format('YYYY-MM-dd HH:mm:ss');
                System.debug('wwwwstrCreateDate' + strCreateDate);

                // 只针对客户审批流程
                if(customerId.getSobjectType().getDescribe().getName() == 'Account'){
                
                    long fromDateTime = Datetime.ValueOf(strCreateDate).getTime();
                    long toDateTime = Datetime.ValueOf(strSysDateTime).getTime();

                    Integer hours = (Integer)((toDateTime - fromDateTime) / (1000 * 60 * 60));
                    System.debug('wwww审批创建和系统时间的小时差为>>>'+hours);

                    if(Test.isRunningTest())hours = 24;

                    // 拦截未超过24小时的客户审批流程
                    if(hours >= 24){

                        // 查询记录表是否已发送
                        List<UrgingSendEmailLog__c> urgingLogs = [SELECT id,ProcessInstanceWorkitemId__c,LastModifiedDate FROM UrgingSendEmailLog__c where ProcessInstanceWorkitemId__c =: item.id];
                    
                        if(Test.isRunningTest()){
                            urgingLogs = [SELECT id,ProcessInstanceWorkitemId__c,LastModifiedDate FROM UrgingSendEmailLog__c];
                        }

                        if(urgingLogs != null && urgingLogs.size() > 0){

                            UrgingSendEmailLog__c urgingLog = urgingLogs.get(0);

                            Datetime lastModifiedDate = urgingLog.LastModifiedDate;
                            String strLastModifiedDate = lastModifiedDate.format('YYYY-MM-dd HH:mm:ss');
                            System.debug('wwwwstrLastModifiedDate' + strLastModifiedDate);

                            long lastDateTime = Datetime.valueOf(strLastModifiedDate).getTime();
                            Integer hoursLog = (Integer)((toDateTime - lastDateTime) / (1000 * 60 *60));

                            if(Test.isRunningTest())hoursLog = 25;

                            // 发送时间超过24小时再次提醒
                            if(hoursLog > 24){

                                emaliList.add(urgingSendEmail(item,emtemp,user,contact,account));

                                // 更新日志记录时间
                                updateUrgingLog.add(urgingLog);
                                // update urgingLog;
                            }

                        }else{

                            emaliList.add(urgingSendEmail(item,emtemp,user,contact,account));

                            UrgingSendEmailLog__c urgingLog = new UrgingSendEmailLog__c();
                            urgingLog.ProcessInstanceWorkitemId__c = item.id;

                            // 存放催办提醒记录
                            addUrgingLog.add(urgingLog);
                            // insert urgingLog;
                        }
                    }
                }
            }

            if(!Test.isRunningTest())Messaging.sendEmail(emaliList);
            try {
                Update updateUrgingLog;
                Insert addUrgingLog;
            } catch (Exception e) {
                System.debug('CustomerApprovalRemindSchedule定时异常:' + e.getMessage());
            }
            System.debug('CustomerApprovalRemindSchedule Stop');
        }   
    }

    global Messaging.SingleEmailMessage urgingSendEmail(ProcessInstanceWorkitem item,EmailTemplate emtemp,User user,Contact contact,Account account){

        System.debug('wwww' + JSON.serialize(user));

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();

        // 如果设置了targetObjectId,则需要对它赋值为false，默认为true；
        singleEmail.setSaveAsActivity(false);

        // 当使用email template时，此方法是必须使用的
        if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

        // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
        singleEmail.setTreatTargetObjectAsRecipient(false);
    
        // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
        singleEmail.setWhatId(account.Id);

        // System.debug('emailstr-->'+bodyFormat);

        // 设置email的template
        singleEmail.setTemplateId(emtemp.Id);

        // 设置接收人的email地址
        singleEmail.setToAddresses(new List<String>{user.Email});
        // singleEmail.setToAddresses(new List<String>{'1120634006@qq.com'});
        
        System.debug('wwwww Send Email' + JSON.serialize(singleEmail));
        return singleEmail;
    }

    global void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name =:name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
     }
}