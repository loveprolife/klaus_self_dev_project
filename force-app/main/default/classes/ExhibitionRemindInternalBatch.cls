/**************************************************************************************************
 * Name: ExhibitionRemindInternalBatch
 * Object: Internal_Registration__c
 * Purpose: 展会进行过程中每天9点发送邮件提醒所有参展员工，提交交付物
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-08         Created        
 
***************************************************************************************************/
global class ExhibitionRemindInternalBatch implements Database.Batchable<sObject> {
    public String query;
    public Date queryDate;

    global ExhibitionRemindInternalBatch() {
        this.queryDate = Date.today();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id, Email__c, Exhibition_Id__c,Exhibition_Id__r.StartDate__c, Name_EN__c, Name_CN__c  FROM Internal_Registration__c WHERE Exhibition_Id__r.StartDate__c <=:queryDate AND Exhibition_Id__r.EndDate__c >=: queryDate  '+
             + ' AND Approval_Status__c=\'审批通过\' AND Company_Abbr__c LIKE \'%国际营销%\' ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Internal_Registration__c> expoApplyInfoList) {
         try {
            sendEmail(expoApplyInfoList);
        }
        catch (Exception e) {
            System.debug('ExhibitionRemindInternalBatch Error--->'+e.getLineNumber()+e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    global void sendEmail(List<Internal_Registration__c> expoAppList){
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE Name = 'Exhibition_Internal_Registration_Attachment_Upload_Html' LIMIT 1];
            
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

        for (Internal_Registration__c item : expoAppList) {//
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setSaveAsActivity(false);
                singleEmail.setTemplateId(emtemp.Id);
                singleEmail.setSubject(emtemp.Subject + '');//此模板不用变更
                //设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
                String toName = item.Name_CN__c != NULL ? item.Name_CN__c : item.Name_EN__c;
                String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName});
                // String bodyFormat = emtemp.Body;
                singleEmail.setHtmlBody(bodyFormat);
                singleEmail.setPlainTextBody(bodyFormat);
                System.debug('bodyFormat-->'+bodyFormat);
                singleEmail.setToAddresses(new List<String>{item.Email__c});
                // singleEmail.setCcAddresses(item.Email__c);
                sendEmailList.add(singleEmail);
        }

        //20241119 TJP 取消交付物提醒 待释放
        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            // Messaging.sendEmail(sendEmailList);
        }

        
    }
}