/*
 * @Author: WFC
 * @Date: 2024-08-16 11:01:00
 * @LastEditors: WFC
 * @LastEditTime: 2024-08-26 11:03:03
 * @Description: 东盟客户拜访发送邮件提醒
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\CustomerVisitEmailReminderController.cls
 */
public without sharing class CustomerVisitEmailReminderController{
    @InvocableMethod
    public static void sendEmailReminder(List<String> visitIdList){
        // 邮件模板
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName
                                FROM EmailTemplate
                                WHERE Name = 'Asean_Customer_Visit_Email_Reminder'
                                LIMIT 1];
        // 发送人邮箱
        OrgWideEmailAddress oea = [SELECT Id, DisplayName, Address
                                   FROM OrgWideEmailAddress
                                   WHERE DisplayName = 'Salesforce System'
                                   LIMIT 1];
        // 获取所有要发送的用户
        List<GroupMember> groupMemberList = [SELECT id, UserOrGroupId, UserOrGroup.Email
                                 FROM GroupMember
                                 WHERE Group.DeveloperName = 'Asean_Customers_Visit_Sending_Email_User'];
        List<String> uIdList = new LisqContainer(groupMemberList).SelectSField('UserOrGroupId');
        // 往前最近的一个周天
        Date weekStart = Date.today().toStartOfWeek();
        // 统计数据时间-上周
        Date weekMonday = weekStart.addDays(-6);
        Date nextWeekMonday = weekStart.addDays(1);
        // 查询用户前一周创建的客户拜访
        List<Customer_Visit__c> cvlist = [SELECT Id, CreatedById
                                          FROM Customer_Visit__c
                                          WHERE CreatedDate >= :weekMonday AND CreatedDate < :nextWeekMonday AND CreatedById IN :uIdList];
        LisqContainer cvlistLc = new LisqContainer(cvlist);
        Map<String, LisqContainer> cvMap = cvlistLc.groupByS('CreatedById');

        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        for (GroupMember u : groupMemberList){
            if (!cvMap.containsKey(u.UserOrGroupId)){
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setSaveAsActivity(false);
                singleEmail.setTemplateId(emtemp.Id);
                singleEmail.setSubject(emtemp.Subject + '');
                singleEmail.setHtmlBody(emtemp.HtmlValue);
                // singleEmail.setPlainTextBody(emtemp.Body);
                //设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(oea.Id);
                singleEmail.setToAddresses(new List<String>{ u.UserOrGroup.Email });
                sendEmailList.add(singleEmail);
            }
        }

        if (sendEmailList.size() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(sendEmailList);
        }
    }

}