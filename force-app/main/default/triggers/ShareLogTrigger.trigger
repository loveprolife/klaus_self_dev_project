/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 01-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger ShareLogTrigger on Share_Log__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {

        for (Share_Log__c sl : (List<Share_Log__c>)Trigger.new) {
            //发送通知邮件
            String subject = '共享错误日志';
            String htmlBody = '共享对象: ' + sl.Share_Object__c + '<br/>' ;
            htmlBody += '在共享中发生错误, 错误原因: ' + sl.Row_Cause__c + '<br/>' ;
            htmlBody += '请及时处理';
            List<String> toAddress = new List<String>{'2872835113@qq.com'};
            // Utility.sendMail(subject, htmlBody, toAddress, '', '');
        }
    }
}