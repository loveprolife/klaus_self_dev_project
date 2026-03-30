public class EmailWithAttachmentSender {
    /**
     * 发送带附件的电子邮件
     * @param subject 邮件主题
     * @param htmlBody 邮件HTML格式正文
     * @param recipientEmails 收件人邮箱列表
     * @param ccEmails 抄送人邮箱列表
     * @param bccEmails 密送人邮箱列表
     * @param base64Attachments 附件内容的Base64编码列表
     * @param attachmentNames 附件名称列表
     * @param contentType 附件内容类型
     * @param isInline 是否内联附件
     * @return 发送结果列表
     */
    public static Messaging.SendEmailResult[] sendEmail(
        String subject, 
        String htmlBody, 
        List<String> recipientEmails,
        List<String> ccEmails,
        List<String> bccEmails,
        List<String> base64Attachments,
        List<String> attachmentNames,
        String contentType,
        Boolean isInline
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // 设置邮件基本信息
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setCharset('UTF-8');
        
        // 设置收件人
        if (recipientEmails != null && !recipientEmails.isEmpty()) {
            email.setToAddresses(recipientEmails);
        }
        
        // 设置抄送人
        if (ccEmails != null && !ccEmails.isEmpty()) {
            email.setCcAddresses(ccEmails);
        }
        
        // 设置密送人
        if (bccEmails != null && !bccEmails.isEmpty()) {
            email.setBccAddresses(bccEmails);
        }
        
        // 添加附件
        if (base64Attachments != null && !base64Attachments.isEmpty() && 
            attachmentNames != null && !attachmentNames.isEmpty() && 
            base64Attachments.size() == attachmentNames.size()) {
            
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            for (Integer i = 0; i < base64Attachments.size(); i++) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setBody(EncodingUtil.base64Decode(base64Attachments[i]));
                attachment.setFileName(attachmentNames[i]);
                attachment.setContentType(contentType);
                attachment.setInline(isInline);
                attachments.add(attachment);
            }
            
            email.setFileAttachments(attachments);
        }
        
        // 发送邮件并返回结果
        return Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}