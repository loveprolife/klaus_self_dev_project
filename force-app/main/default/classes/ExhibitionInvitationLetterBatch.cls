/**************************************************************************************************
 * Name: ExhibitionInvitationLetterBatch
 * Object: ExpoApplyInfo__c
 * Purpose: 邀请函 ：展会开始前N天给展会下的所有参展客户发送 90天                   参展客户
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-08         Created        
 
***************************************************************************************************/
global class ExhibitionInvitationLetterBatch implements Database.Batchable<sObject> {
    private final static String PROFILE_NAME = '展会 行政商务组';
    private final static String PERMISSION_SET_NAME = 'Exhibition_Administrative_Commercial';
    public String query;
    public Date queryDate;

    global ExhibitionInvitationLetterBatch() {
        this.queryDate = Date.today()-90;
        System.debug('queryDate------>'+queryDate);
       
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // query = 'SELECT Id, Email__c, ExpoId__c,ExpoId__r.StartDate__c FROM ExpoApplyInfo__c WHERE ExpoId__r.StartDate__c =: queryDate';
        query = 'SELECT Id, StartDate__c FROM ExpoInfo__c  WHERE StartDate__c =: queryDate';
        return Database.getQueryLocator(query);
    }

    // global void execute(Database.BatchableContext BC, list<ExpoApplyInfo__c> expoApplyInfoList) {
    global void execute(Database.BatchableContext BC, list<ExpoInfo__c> expoApplyInfoList) {
        try {
            if (expoApplyInfoList.size() > 0) sendEmail(expoApplyInfoList);
        }
        catch (Exception e) {
            System.debug('ExhibitionInvitationLetterBatch Error--->'+e.getLineNumber()+e.getMessage());
        }
        
    }

    global void finish(Database.BatchableContext BC) {

    }

    // global void sendEmail(List<ExpoApplyInfo__c> expoAppList){
    //     EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //         FROM EmailTemplate
    //         WHERE DeveloperName = 'Exhibition_Customer_Invitation_Letter' LIMIT 1];
            
    //     List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

    //     for (ExpoApplyInfo__c item : expoAppList) {//是否和旧的做对比 TODO 旧的用Map
    //             Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    //             singleEmail.setSaveAsActivity(false);
    //             singleEmail.setTemplateId(emtemp.Id);
    //             singleEmail.setSubject(emtemp.Subject + '');//此模板不用变更
    //             String bodyFormat = emtemp.HtmlValue;
    //             singleEmail.setHtmlBody(bodyFormat);
    //             System.debug('bodyFormat-->'+bodyFormat);
    //             singleEmail.setToAddresses(new List<String>{item.Email__c});
    //             // singleEmail.setCcAddresses(item.Email__c);
    //             sendEmailList.add(singleEmail);
    //     }

    //     if (sendEmailList.size() > 0) {
    //         System.debug('------------>already send ! ');
    //         Messaging.sendEmail(sendEmailList);
    //     }

        
    // }

    global void sendEmail(List<ExpoInfo__c> expoAppList){
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE DeveloperName = 'Exhibition_Customer_Invitation_Letter' LIMIT 1];
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();

        for (PermissionSetAssignment item: [SELECT Id, Assignee.Name, Assignee.Email, Assignee.IsActive, PermissionSet.Name, Assignee.Profile.Name FROM PermissionSetAssignment
            WHERE Assignee.IsActive = TRUE AND (PermissionSet.Name =:PERMISSION_SET_NAME OR Assignee.Profile.Name =:PROFILE_NAME)]) {
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setSaveAsActivity(false);
                singleEmail.setTemplateId(emtemp.Id);
                singleEmail.setSubject(emtemp.Subject + '');
                //设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
                String bodyFormat = emtemp.HtmlValue;
                singleEmail.setHtmlBody(bodyFormat);
                System.debug('bodyFormat-->'+bodyFormat);
                singleEmail.setToAddresses(new List<String>{item.Assignee.Email});
                // singleEmail.setCcAddresses(item.Email__c);
                sendEmailList.add(singleEmail);
        }


        // for (ExpoApplyInfo__c item : expoAppList) {
        //         Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        //         singleEmail.setSaveAsActivity(false);
        //         singleEmail.setTemplateId(emtemp.Id);
        //         singleEmail.setSubject(emtemp.Subject + '');
        //         singleEmail.setHtmlBody(bodyFormat);
        //         System.debug('bodyFormat-->'+bodyFormat);
        //         singleEmail.setToAddresses(new List<String>{item.Email__c});
        //         // singleEmail.setCcAddresses(item.Email__c);
        //         sendEmailList.add(singleEmail);
        // }

        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            Messaging.sendEmail(sendEmailList);
        }

        
    }

}