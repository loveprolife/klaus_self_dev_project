/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public without sharing class EmailNotificationUtility {
    public static void sendEmailNotificationWithDummyContact(EmailTemplate etItem,List<Messaging.SingleEmailMessage> emailList) {
        if(emailList.size() > 0) {
            Savepoint sp = Database.setSavepoint();

            //建立虚假contact
            Contact dummyCon = new Contact(LastName ='dummyCon',Email = 'dummy@contact.com'); 
            insert dummyCon;
            for(Messaging.SingleEmailMessage emailItem : emailList){
                emailItem.setTargetObjectId(dummyCon.Id);
                emailItem.setTemplateId(etItem.Id);
            }
            EmailNotificationUtility.messageSendEmail(emailList);
            Database.rollback(sp);
            
            List<Messaging.SingleEmailMessage> semWithoutTemplateList = new List<Messaging.SingleEmailMessage>();
            for(Messaging.SingleEmailMessage semTemp : emailList){
                Messaging.SingleEmailMessage semWithoutTemplate = new Messaging.SingleEmailMessage();
                if(String.IsNotBlank(semTemp.getPlainTextBody())){
                    semWithoutTemplate.setPlainTextBody(semTemp.getPlainTextBody());
                }else if( String.IsNotBlank(semTemp.getHtmlBody()) ){
                    semWithoutTemplate.setHtmlBody(semTemp.getHtmlBody());
                }else if( String.IsNotBlank( etItem.HtmlValue ) ){
                    semWithoutTemplate.setHtmlBody( etItem.HtmlValue );
                }else if(  String.IsNotBlank( etItem.Body ) 
                    &&  !etItem.Body.equalsIgnoreCase('Error') ){
                    semWithoutTemplate.setPlainTextBody( etItem.Body );
                }else{
                    break;
                }
                semWithoutTemplate.setToAddresses(semTemp.getToAddresses());
                semWithoutTemplate.setSubject(semTemp.getSubject());
                semWithoutTemplateList.add(semWithoutTemplate);
            }
            
            System.debug('semWithoutTemplateList:' + semWithoutTemplateList);
            EmailNotificationUtility.messageSendEmail(semWithoutTemplateList);
        }
    }
    public static void sendEmailNotificationReplaceTargetUser(EmailTemplate etItem, List<String> userList) {
        List<Messaging.SingleEmailMessage> semWithoutTemplateList = new List<Messaging.SingleEmailMessage>();
        Map<String,String>  templateBodyMap =  getTargetUserField(etItem.Body,userList);
        for(String emailStr : templateBodyMap.keySet()) {
            Messaging.SingleEmailMessage semWithoutTemplate = new Messaging.SingleEmailMessage();
            semWithoutTemplate.setPlainTextBody(templateBodyMap.get(emailStr));
            semWithoutTemplate.setToAddresses(new List<String>{emailStr});
            semWithoutTemplate.setSubject(etItem.Subject);
            semWithoutTemplateList.add(semWithoutTemplate);
        }
        System.debug('semWithoutTemplateList:' + semWithoutTemplateList);
        EmailNotificationUtility.messageSendEmail(semWithoutTemplateList);
      //  if(emailList.size() > 0) {
            /*
            List<Messaging.SingleEmailMessage> semWithoutTemplateList = new List<Messaging.SingleEmailMessage>();
            for(Messaging.SingleEmailMessage semTemp : emailList){
                Messaging.SingleEmailMessage semWithoutTemplate = new Messaging.SingleEmailMessage();
                if(String.IsNotBlank(semTemp.getPlainTextBody())){
                    semWithoutTemplate.setPlainTextBody(semTemp.getPlainTextBody());
                }else if( String.IsNotBlank(semTemp.getHtmlBody()) ){
                    semWithoutTemplate.setHtmlBody(semTemp.getHtmlBody());
                }else if( String.IsNotBlank( etItem.HtmlValue ) ){
                    semWithoutTemplate.setHtmlBody( etItem.HtmlValue );
                }else if(  String.IsNotBlank( etItem.Body ) 
                    &&  !etItem.Body.equalsIgnoreCase('Error') ){
                    semWithoutTemplate.setPlainTextBody( etItem.Body );
                }else{
                    break;
                }
                semWithoutTemplate.setToAddresses(semTemp.getToAddresses());
                semWithoutTemplate.setSubject(semTemp.getSubject());
                semWithoutTemplateList.add(semWithoutTemplate);
            }
            EmailNotificationUtility.messageSendEmail(semWithoutTemplateList);
            */
       // }
    }
    public static Map<String,String>  getTargetUserField(String templateBody, List<Id> userIdList) {
        List<String> fieldNameList = templateBody.split('\\{!Target_User.');
        Set<String> fieldNameSet = new Set<String>();
        for(String fieldName : fieldNameList) {
            fieldName = fieldName.substringBefore('}');
            if(String.isNotBlank(fieldName)) {
                fieldNameSet.add(fieldName);
            }
            System.debug(fieldName);
        }
        fieldNameSet.add('Email');
        String queryStr = 'SELECT '+ String.join(new List<String>(fieldNameSet), ',') + ' FROM User WHERE Id IN:userIdList';
        List<User> userList = (List<User>)Database.query(queryStr);
        Map<String,String> templateBodyMap = new Map<String,String>();

        fieldNameSet.remove('Email');
        for(User userItem : userList) {
            for(String fieldName : fieldNameSet) {
                System.debug('{!Target_User.'+fieldName+'}' + ' = ' +userItem.get(fieldName));
                String templateBodyItem = templateBody.replace('{!Target_User.'+fieldName+'}',String.valueOf(userItem.get(fieldName)));
                System.debug('afterChange:' + templateBodyItem);
                templateBodyMap.put(userItem.Email,templateBodyItem);
            }
        }
        System.debug('map:' + templateBodyMap);
        return templateBodyMap;
    }
    public static void messageSendEmail(List<Messaging.SingleEmailMessage> emailList){
        // EmailNotificationButton__c rec = EmailNotificationButton__c.getOrgDefaults();
        // if(rec.IsActive__c) {
        //     Messaging.sendEmail(emailList);
        // }

        Email_Switch__mdt isActiveEmailMdt = [SELECT IsActive__c FROM Email_Switch__mdt WHERE DeveloperName = 'IsActive'];
        if (isActiveEmailMdt.IsActive__c) {
            Messaging.sendEmail(emailList);
        }
    }
    public static List<EmailTemplate> getEmailTemplate(String emailTemplateDeveloperName) {
        return [SELECT 
                    Id,
                    DeveloperName,
                    IsActive,
                    HtmlValue,
                    Body,
                    Subject 
                FROM EmailTemplate 
                WHERE 
                    DeveloperName =:emailTemplateDeveloperName 
                AND 
                    IsActive = TRUE];
    }
}