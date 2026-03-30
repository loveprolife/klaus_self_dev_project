public with sharing class SendEmailTestController {
    @AuraEnabled
    public static void sendData(String roomId, String template) {
        // Handle the data received from the LWC component
        System.debug('Room ID: ' + roomId);
        System.debug('template: ' + template);
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE Name =: template LIMIT 1];
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        String emailC = 'duidui1069@163.com';

        // 如果设置了targetObjectId,则需要对它赋值为false，默认为true；
        singleEmail.setSaveAsActivity(false);

        // 当使用email template时，此方法是必须使用的
        Contact contact = new Contact();
        if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
        //设置发送人邮箱
        singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
        // singleEmail.setTargetObjectId(ct.Id);
        if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

        // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
        singleEmail.setTreatTargetObjectAsRecipient(false);
    
        // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
        singleEmail.setWhatId(roomId);

        // System.debug('emailstr-->'+bodyFormat);

        // 设置email的template
        singleEmail.setTemplateId(emtemp.Id);

        // 设置接收人的email地址
        singleEmail.setToAddresses(new List<String>{'duidui1069@163.com'});

        System.debug(JSON.serialize(singleEmail));
        sendEmailList.add(singleEmail);
        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
        }
        // sendCancleEmail(roomId);
        // sendWaitEmail(roomId);
        
        // Add your business logic here, such as saving data to the database or sending an email
    }

    // public static void sendCancleEmail(String roomId){
    //     EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //         FROM EmailTemplate
    //         WHERE Name =: 'Meeting Room Reservation Cancelled' LIMIT 1];
    //     List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

    //     Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    //     singleEmail.setSaveAsActivity(false);
    //     //设置发送人邮箱
    //     singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
    //     // 当使用email template时，此方法是必须使用的
    //     Contact contact = new Contact();
    //     if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
    //     // singleEmail.setTargetObjectId(ct.Id);
    //     if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

    //     // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
    //     singleEmail.setTreatTargetObjectAsRecipient(false);

    //     // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
    //     singleEmail.setWhatId(roomId);

    //     // System.debug('emailstr-->'+bodyFormat);

    //     // 设置email的template
    //     singleEmail.setTemplateId(emtemp.Id);
    //     List<String> emailList = new List<String>();

    //     // System.debug('emailList-->'+emailList);
    //     // System.debug('emailList.size()-->'+emailList.size());
    //     emailList.add('');
    //         // 设置接收人的email地址
    //     singleEmail.setToAddresses(new List<String>{'duidui1069@163.com'});

    //     System.debug(JSON.serialize(singleEmail));
    //     sendEmailList.add(singleEmail);
    //     if (sendEmailList.size() > 0) {
    //         System.debug('------------>email send ! ');
    //         if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
    //     }   
    // }

    // public static void sendWaitEmail(String roomId){
    //     EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //         FROM EmailTemplate
    //         WHERE Name =: 'Meeting Room Request Pending Confirmation' LIMIT 1];
    //     List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

    //     Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    //     singleEmail.setSaveAsActivity(false);
    //     //设置发送人邮箱
    //     singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
    //     // 当使用email template时，此方法是必须使用的
    //     Contact contact = new Contact();
    //     if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
    //     // singleEmail.setTargetObjectId(ct.Id);
    //     if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

    //     // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
    //     singleEmail.setTreatTargetObjectAsRecipient(false);

    //     // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
    //     singleEmail.setWhatId(roomId);

    //     // System.debug('emailstr-->'+bodyFormat);

    //     // 设置email的template
    //     singleEmail.setTemplateId(emtemp.Id);
    //     // List<String> emailList = new List<String>();
    //     // emailList.add('ina.glojek@gorenje.com');

    //     // emailList.add('alenka.kralj@gorenje.com');
    //     //     // 设置接收人的email地址
    //     // singleEmail.setToAddresses(emailList);

    //     // System.debug(JSON.serialize(singleEmail));
    //     // sendEmailList.add(singleEmail);
    //     singleEmail.setToAddresses(new List<String>{'duidui1069@163.com'});
    //     sendEmailList.add(singleEmail);
    //     if (sendEmailList.size() > 0) {
    //         System.debug('------------>email send ! ');
    //         if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
    //     }   
    // }
}