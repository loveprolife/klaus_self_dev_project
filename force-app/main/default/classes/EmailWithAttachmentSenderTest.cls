@isTest
public with sharing class EmailWithAttachmentSenderTest {
    testMethod static void test01() {
        Test.startTest();
        
        // 示例：从附件对象获取Base64编码
        //Attachment att = [SELECT Id, Body, Name FROM Attachment LIMIT 1];
        //String base64Content = EncodingUtil.base64Encode(att.Body);
        
        // 邮件参数
        String subject = '测试邮件 - 带附件';
        String htmlBody = '<p>你好，这是一封带有附件的测试邮件。</p>';
        List<String> recipients = new List<String>{'recipient@example.com'};
        List<String> ccRecipients = new List<String>{'cc@example.com'};
        List<String> bccRecipients = new List<String>{'bcc@example.com'};
        List<String> attachments = new List<String>{'base64Content'};
        List<String> attachmentNames = new List<String>{'att.Name'};
        String contentType = 'application/octet-stream';
        Boolean isInline = false;
        
        // 发送邮件
        Messaging.SendEmailResult[] results = EmailWithAttachmentSender.sendEmail(
            subject, htmlBody, recipients, ccRecipients, bccRecipients, 
            attachments, attachmentNames, contentType, isInline
        );
        
        // 处理发送结果
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('邮件发送成功');
            } else {
                System.debug('邮件发送失败: ' + result.getErrors()[0].getMessage());
            }
        }

        Test.stopTest();
    }
}