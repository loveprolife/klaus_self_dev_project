/** 
    Description: Sending email notification when time reaches the [Sales Expected Reminding Date]
    Author: Roy
    Date: 2019/03/09
**/ 
public with sharing class SendingEmailToHSParticipant{
@InvocableMethod
public static void sendingEmail(List<String> visitIdList) {
    //add by Phoenix 2019/05/16 Filed without SOQL Start
    List<Visit_Participant__c> visitParticipantList = [select Visit_Participant_Name__c,Name,Hisense_Participant_Email__c,Visit_Record_Name__c,Visit_Date__c from Visit_Participant__c where Customer_Visit__r.id in :visitIdList and recordType.developername = 'Hisense_Participant'];
    //add by Phoenix 2019/05/16 Filed without SOQL End
    //Email list
    Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
    for(Visit_Participant__c visitParticipant : visitParticipantList ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //设置email体
        String emailBody = '<span style="display: inline-block; width:28px;"></span>Dear [' + visitParticipant.Visit_Participant_Name__c + ']，<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The Sales Expected Reminding Date for your customer visit [' + visitParticipant.Visit_Record_Name__c + ']&nbsp;&nbsp;(On &nbsp;&nbsp;&nbsp;[' + visitParticipant.Visit_Date__c + '] ) has already been reached, Please take action in time!';
        
        mail.setToAddresses(new List<string> {visitParticipant.Hisense_Participant_Email__c});
        mail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
        mail.setSubject(Label.Visit_Participant_Email_Title);
        mail.setHtmlBody(emailBody);
        theEmails.add(mail);
    }
    Messaging.Email[] allMails = new Messaging.Email[]{};
    for(Integer j = 0; j < theEmails.size(); j++) {
        allMails.add(theEmails.get(j));
    }
    // Print error information
    Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
    Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
    String emailErrorReport = '';
    for(Messaging.SendEmailResult currentResult : results) {
        errors = currentResult.getErrors();
        if(null != errors) {
            for(Messaging.SendEmailError currentError : errors) {
                emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
                System.debug(emailErrorReport);
            }
        }
    }     
}     
}