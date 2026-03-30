/**************************************************************************************************
 * CertificateAssignmentTriggerHandler
 * Purpose:Account Trigger处理逻辑
 * Author: taojingpeng
 * Create Date: 2025-04-21 
***************************************************************************************************/
public class CertificateAssignmentTriggerHandler implements Triggers.Handler{
    private final static String Temporary_Certificate = '临时证';
    private final static String Exhibitor_Card = '参展商证';

    public void handle() {           
        if (Trigger.isAfter&& Trigger.isUpdate) {
            for (Expo_Certificate_Assignment__c rb : ((list<Expo_Certificate_Assignment__c>)Trigger.new)) {
                Expo_Certificate_Assignment__c rbOld = (Expo_Certificate_Assignment__c)Trigger.oldMap.get(rb.Id);
                if (rb.Is_Arranged__c && !rbOld.Is_Arranged__c) {
                    List<Internal_Registration__c> intCount = [Select Id,Approver__c,Company__c,Certificate_Type__c,Validity_Date__c from Internal_Registration__c Where Exhibition_Id__c =: rb.Exhibition_Management__c And Approver__c =: rb.Approver__c And Company__c =: rb.Region__c And (Certificate_Type__c INCLUDES ('参展商证|Exhibition Badge') or Certificate_Type__c INCLUDES ('临时证|Day Voucher'))];                
                    System.debug('使用' + intCount.size());
                    Decimal tempCert = 0; // 临时证的统计数值
                    Decimal exhibitorCert = 0; // 参展商证的统计数量
                    
                    // 遍历查询结果
                    If(intCount.size() > 0) {
                        for (Internal_Registration__c record: intCount) {
                            if (record.Certificate_Type__c.contains(Temporary_Certificate)) {
                                // 处理临时证
                                if (String.isNotEmpty(record.Validity_Date__c) && !record.Validity_Date__c.equals('None')) {
                                    // 分割并累加数值
                                    List<String> values = record.Validity_Date__c.split(';');
                                    Decimal total = 0;
                                    for (String value : values) {
                                        try {
                                            total += 1;
                                        } catch (Exception e) {
                                            // 忽略非法数值
                                        }
                                    }
                                    // 累加到 Map 中
                                    tempCert = tempCert + total;
                                }
                            } else if (record.Certificate_Type__c.contains(Exhibitor_Card)) {
                                // 处理参展商证
                                exhibitorCert = exhibitorCert + 1;
                            }
                        }
                        
                        // 输出结果
                        System.debug('临时证使用数值：' + tempCert);
                        System.debug('参展商证使用数量：' + exhibitorCert);
                    }
                    sendEmail(rb,tempCert,exhibitorCert);
                }
                
            }
        }
    } 

    public static void sendEmail(Expo_Certificate_Assignment__c item,Decimal tempCert,Decimal exhibitorCert){
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE DeveloperName =: 'Certificate_Assignment_Notification' LIMIT 1];
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setSaveAsActivity(false);
        singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
        Contact contact = new Contact();
        if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
        if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);
        singleEmail.setTreatTargetObjectAsRecipient(false);
        // singleEmail.setWhatId(item.Id);
        // 设置email的template
        singleEmail.setTemplateId(emtemp.Id);
        String toName = '';
        List<String> emailList = new List<String>();
        if(String.isNotBlank(item.Approver__c)) {
            toName = item.Approver__c.substring(0, item.Approver__c.indexOf('@'));
            emailList.add(item.Approver__c);
        } else {
            toName = 'taojingpeng.ex' + 
            emailList.add('taojingpeng.ex@hx-partners.com');
        }
        String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, item.Region__c, item.Certificate_Quantity__c + '', item.Validity__c + '', exhibitorCert + '', tempCert + ''});
        singleEmail.setHtmlBody(bodyFormat);
        
        if(String.isNotEmpty(item.Contact_Email1__c)){  emailList.add(item.Contact_Email1__c); }
        if(String.isNotEmpty(item.Contact_Email2__c)){  emailList.add(item.Contact_Email2__c); }
        if(String.isNotEmpty(item.Contact_Email3__c)){  emailList.add(item.Contact_Email3__c); }
        // System.debug('emailList.size()-->'+emailList.size());
            // 设置接收人的email地址

        Set<String> emailSet = new Set<String>(emailList);
        List<String> uniqueEmailList = new List<String>(emailSet);
        System.debug('emailList-->'+uniqueEmailList);
        singleEmail.setToAddresses(uniqueEmailList);

        System.debug(JSON.serialize(singleEmail));
        sendEmailList.add(singleEmail);
        Organization orgs = [SELECT Id, IsSandbox FROM Organization Limit 1];
        if (sendEmailList.size() > 0) {
            System.debug('------------>email send ! ');
            if(!(Test.isRunningTest() || orgs.IsSandbox))Messaging.sendEmail(sendEmailList);
        }   
    }

}