/*
 * @Author: WFC
 * @Date: 2025-01-02 16:31:28
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-16 10:28:50
 * @Description: Sample Display 零售部长流程审批通过，抄送产品总监
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplaySendCCEmailInvocableMethod.cls
 */
public without sharing class SampleDisplaySendCCEmailInvocableMethod{
    @InvocableMethod
    public static void processMailCC(List<String> sampleDisplayIdList){
        // 邮件list
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();

        if (sampleDisplayIdList != null && sampleDisplayIdList.size() > 0){
            // 查询Store_Detail__c信息
            List<Store_Detail__c> sdList = [SELECT Id, Number__c, Store__r.Name, Product_Model__r.name, Sample_Display__r.Customer__r.name, Sample_Display__r.Product_Line__c, Sample_Display__r.Name, Sample_Display__r.Number__c
                                            FROM Store_Detail__c
                                            WHERE Sample_Display__c = :sampleDisplayIdList[0]];

            if (sdList != null && sdList.size() > 0){
                String ccEmail = '';
                String ccEmailOther = '';
                List<String> ccEmailList = new List<String>();
                // 收件人地址
                Sample_Display_CC_Email__mdt ccEmailMdt = Sample_Display_CC_Email__mdt.getInstance(sdList[0].Sample_Display__r.Product_Line__c);
                if (ccEmailMdt != null){
                    ccEmail = ccEmailMdt.CC_Email__c;
                    ccEmailList.add(ccEmail);
                }
                // 销售总监地址
                Sample_Display_CC_Email__mdt ccEmailMdtOther = Sample_Display_CC_Email__mdt.getInstance('Other');
                if (ccEmailMdtOther != null){
                    ccEmailOther = ccEmailMdtOther.CC_Email__c;
                    ccEmailList.add(ccEmailOther);
                }
                if (ccEmailList != null && ccEmailList.size() > 0){
                    // subject
                    String subject = '【Salesforce】' + sdList[0].Sample_Display__r.Name + ' Sample Task has been confirmed.';
                    // 生成邮件信息
                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                    singleEmail.setToAddresses(ccEmailList);
                    singleEmail.setSubject(subject);
                    singleEmail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
                    String html = '';
                    String sendEmailurl = System.URL.getOrgDomainUrl().toExternalForm() + '/' + sampleDisplayIdList[0];
                    html = '<html>' + '<head>' + '</head>' + '<body>' + '<div>';
                    html += '<P>' + 'The sample task numbered ' + sdList[0].Sample_Display__r.Name + ' has been confirmed.' + '</p>';
                    html += '<P>' + 'Please check the task and the details.' + '</p>';
                    html += '<P>' + 'You can also view the details through the following link. ';
                    html += '<a href="' + sendEmailurl + '">' + sendEmailurl + '</a></p>';
                    html += '<P>' + 'Sample Task: ' + '</p>';
                    html += '<P>' + 'Product Model:' + sdList[0].Product_Model__r.name + ' &emsp; Customer:' + sdList[0].Sample_Display__r.Customer__r.name + ' &emsp; Number:' + sdList[0].Sample_Display__r.Number__c + '</p>';
                    html += '<P>' + 'Sample Task Details:' + '</p>';
                    for (Store_Detail__c sd : sdList){
                        html += '<P>' + sd.Store__r.Name + ': ' + sd.Number__c + '</p>';
                    }
                    html += '</div>' + '</body>' + '</html>';
                    singleEmail.setHtmlBody(html);
                    sendEmailList.add(singleEmail);

                    try{
                        Messaging.sendEmail(sendEmailList);
                        Utility.insertLog('SampleDisplaySendCCEmail', '1', html, sampleDisplayIdList[0] + '——' + ccEmail + '——' + ccEmailOther);
                    } catch (Exception e){
                        Utility.insertLog('SampleDisplaySendCCEmail', '0', html, sampleDisplayIdList[0] + '——' + ccEmail + '——' + ccEmailOther);
                    }
                } else{
                    Utility.insertLog('SampleDisplaySendCCEmail', '0', '', '收件地址为空');
                }
            }
        }
    }

}