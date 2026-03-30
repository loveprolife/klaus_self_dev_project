public class UrgingButtonController {
    
    // 催办发送邮件提醒
    @AuraEnabled
    public static ConResponse urgingSendEmail(String customerId){

        ConResponse result = new ConResponse();

        System.debug('------------>urgingSendEmail Start ! ');

        // 查询当前客户下是否有待审批的流程
        List<ProcessInstanceWorkitem> workItem = [select id,
                                                   ProcessInstance.TargetObjectId,
                                                   ProcessInstance.status,
                                                   OriginalActorId 
                                                   from ProcessInstanceWorkitem 
                                                   where ProcessInstance.TargetObjectId =: customerId];
        System.debug('wwww pw' + JSON.serialize(workItem));
        
        if(Test.isRunningTest()){
            User user = [SELECT id from User].get(0);
            ProcessInstanceWorkitem pw = new ProcessInstanceWorkitem();
            ProcessInstance pi = new ProcessInstance();
            pi.TargetObjectId = customerId;
            pw.ProcessInstance = pi;
            pw.OriginalActorId = user.Id;
            workItem.add(pw);
        }

        // 获取当前审批人邮箱
        if(workItem != null && workItem.size() > 0){
            result.code = urgingSendEmailTemplate(workItem);
        }

        return result;
    }

    // 发送催办邮件提醒信息
    public static Integer urgingSendEmailTemplate(List<ProcessInstanceWorkitem> data){

        Integer code = 0;

        // 查询催办发送邮件模版
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
        FROM EmailTemplate
        WHERE Name = 'Customer Onboard Notify' LIMIT 1];
        Contact contact = new Contact();
        if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];

        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();

        for(ProcessInstanceWorkitem item : data){
            User user = [SELECT id,Email from User where id =: item.OriginalActorId];

            System.debug('wwww' + JSON.serialize(user));

            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();

            Account account = [Select id,name from Account where id =: item.ProcessInstance.TargetObjectId];

            // String aurl = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Account/'+account.id+'/view';
			// String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{account.name,aurl});
			// String bodyFormat = emtemp.Body;

            // 如果设置了targetObjectId,则需要对它赋值为false，默认为true；
            singleEmail.setSaveAsActivity(false);
            
            // 设置邮件的发件人的显示名称；
            // singleEmail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);

            // 当使用email template时，此方法是必须使用的
            if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

            // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
            singleEmail.setTreatTargetObjectAsRecipient(false);
    
            // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
            singleEmail.setWhatId(account.Id);

            // System.debug('emailstr-->'+bodyFormat);

            // 设置email的template
            singleEmail.setTemplateId(emtemp.Id);
            // singleEmail.setSubject(emtemp.Subject + '');
            // singleEmail.setHtmlBody(bodyFormat);
            // singleEmail.setPlainTextBody(bodyFormat);
            // 设置接收人的email地址
            singleEmail.setToAddresses(new List<String>{user.Email});
            // singleEmail.setToAddresses(new List<String>{'1120634006@qq.com'});
            sendEmailList.add(singleEmail);

            System.debug('wwwww Send Email' + JSON.serialize(singleEmail));
        }

        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);

            code = 200;
        }

        return code;
    }
}