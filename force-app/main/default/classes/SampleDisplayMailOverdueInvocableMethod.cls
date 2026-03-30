/*
 * @Author: WFC
 * @Date: 2024-12-20 09:45:25
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-10 15:09:34
 * @Description: sample display 流程节点超期发送邮件
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayMailOverdueInvocableMethod.cls
 */
public without sharing class SampleDisplayMailOverdueInvocableMethod{
    @InvocableMethod
    public static void processMailOverdue(List<String> sampleDisplayIdList){
        // 邮件list
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        // Sample_Display__c Id集合
        Set<String> targetIdList = new Set<String>();
        // Sample_Display__c Id与发送邮件地址Map
        Map<String, String> emailMap = new Map<String, String>();

        // 查询所有正在进行中的流程
        List<ProcessInstanceWorkitem> piwList = [SELECT Id, CreatedDate, ActorId, Actor.Email, ProcessInstance.TargetObjectId, ElapsedTimeInDays
                                                 FROM ProcessInstanceWorkitem
                                                 ORDER BY CreatedDate DESC];
        for (ProcessInstanceWorkitem piw : piwList){
            Id cid = Id.valueOf(piw.ProcessInstance.TargetObjectId);
            if ((cid.getSObjectType().getDescribe().getName() == 'Sample_Display__c' && piw.ElapsedTimeInDays > 1) || Test.isRunningTest()){
                targetIdList.add(cid);
                emailMap.put(cid, piw.Actor.Email);
            }

        }
        if (targetIdList != null && targetIdList.size() > 0){
            // 查询要发送邮件的样机信息
            List<Sample_Display__c> sdList = [SELECT Id, Product_Model__r.Name, Task_Level__c, Store__r.Name, Customer__r.Name
                                              FROM Sample_Display__c
                                              WHERE Id IN:targetIdList];
            for (Sample_Display__c sd : sdList){
                List<Object> formatList = new List<Object>();
                formatList.add(sd.Product_Model__r.Name);
                if (sd.Task_Level__c == 'Store'){
                    formatList.add(sd.Store__r.Name);
                } else{
                    formatList.add(sd.Customer__r.Name);
                }
                // 生成邮件信息
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setToAddresses(new List<String>{ emailMap.get(sd.Id) });
                singleEmail.setSubject('Salesforce Sample Process Stay Overtime Reminder');
                singleEmail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
                String html = '';
                html = '<html>' + '<head>' + '</head>' + '<body>' + '<div>';
                html += '<P>' + String.format(Label.SampleDisplayEmailTemplate, formatList) + '</p>';
                html += '<P>' + System.URL.getOrgDomainUrl().toExternalForm() + '/' + sd.Id + '</p>';
                html += '</div>' + '</body>' + '</html>';
                singleEmail.setHtmlBody(html);
                sendEmailList.add(singleEmail);
                Utility.insertLog('SampleDisplaySendEmail', '1', html, sd.Id + '------' + JSON.serialize(emailMap.get(sd.Id)));
            }
            if (sendEmailList.size() > 0 && !Test.isRunningTest()){
                Messaging.sendEmail(sendEmailList);
            }
        }
    }

}