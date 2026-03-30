/*
 * @Author: WFC
 * @Date: 2025-02-06 09:01:32
 * @LastEditors: WFC
 * @LastEditTime: 2025-02-06 15:12:46
 * @Description: 客户拜访 发送邮件
 * @FilePath: \hisense005\force-app\main\default\classes\CustomerVisitSendEmailInvocableMethod.cls
 */
public without sharing class CustomerVisitSendEmailInvocableMethod{
    @InvocableMethod
    public static void CustomerVisitSendEmail(List<String> customerVisitIdList){
        if (customerVisitIdList != null && customerVisitIdList.size() > 0){
            // 邮件list
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            // 邮件地址list
            Set<String> emailAddressSet = new Set<String>();
            List<String> emailAddressList= new List<String>();
            // flow中使用，list中只有一个id
            String customerVisitId = customerVisitIdList[0];
            String html = '';
            try{
                // 客户拜访信息
                Customer_Visit__c customerVisit = [SELECT Id, Customer__c, Customer__r.Name, JP_Product_Line__c, Visit_Date__c, MeetingContent__c
                                                   FROM Customer_Visit__c
                                                   WHERE Id = :customerVisitId];
                // 获取站点信息
                Site site = [SELECT Id
                             FROM Site
                             WHERE Name = 'SendEmail'
                             LIMIT 1];
                SiteDetail siteDetail = [SELECT SecureUrl
                                         FROM SiteDetail
                                         WHERE DurableId = :site.Id
                                         LIMIT 1];
                String meetingContent = customerVisit.MeetingContent__c + '';
                meetingContent = meetingContent.replace('https://' + System.DomainCreator.getContentHostname() + '/', siteDetail != null ? siteDetail.SecureUrl : '');
                // 查询发送邮件地址
                List<AccountTeamMember> accountTeamMemberList = [SELECT User.Email
                                                                 FROM AccountTeamMember
                                                                 WHERE AccountId = :customerVisit.Customer__c];
                if (accountTeamMemberList != null && accountTeamMemberList.size() > 0){
                    for (AccountTeamMember accountTeamMember : accountTeamMemberList){
                        emailAddressSet.add(accountTeamMember.User.Email);
                    }
                    emailAddressList.addAll(emailAddressSet);
                    Date visitDate = customerVisit.Visit_Date__c != null ? customerVisit.Visit_Date__c : Date.today();
                    String vDate = visitDate.toString().substring(0, 10);
                    String subject = '商談報告書 "' + customerVisit.Customer__r.Name + '  ' + customerVisit.JP_Product_Line__c + '  ' + vDate + '"';
                    // 生成邮件信息
                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                    
                    singleEmail.setToAddresses(emailAddressList);
                    singleEmail.setSubject(subject);
                    singleEmail.setSenderDisplayName(System.UserInfo.getName());

                    String custmerVisitURL = System.URL.getOrgDomainUrl().toExternalForm() + '/' + customerVisitId;
                    html = '<html>' + '<head>' + '</head>' + '<body>' + '<div>';
                    html += '<div style="font-family: Arial, Helvetica, sans-serif; font-size: 12px;"><P>各位</p>';
                    html += '<P><br></p>';
                    html += '<P>お疲れ様です。</p>';
                    html += '<P>商談報告書を送付いたします。</p>';
                    html += '<P>ご確認お願い致します。"</p>';
                    html += '<P><br></p></div>';
                    html += '<P>' + meetingContent + '</p>';
                    html += '<P><a href="' + custmerVisitURL + '">' + custmerVisitURL + '</a></p>';
                    html += '</div>' + '</body>' + '</html>';
                    singleEmail.setHtmlBody(html);
                    sendEmailList.add(singleEmail);
                    if (!Test.isRunningTest()){
                        Messaging.sendEmail(sendEmailList);
                    }

                    Utility.insertLog('CustomerVisitSendEmailInvocableMethod', '1', html, customerVisitId + '------' + JSON.serialize(emailAddressList));
                }
            } catch (Exception e){
                Utility.insertLog('CustomerVisitSendEmailInvocableMethod', '0', html, customerVisitId + '------' + JSON.serialize(emailAddressList));
            }

        }
    }

}