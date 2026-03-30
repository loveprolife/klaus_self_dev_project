/*
 * @Author: WFC
 * @Date: 2024-06-19 13:39:26
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-19 11:23:29
 * @Description: Sample Display Trigger
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayTriggerHandler.cls
 */
public class SampleDisplayTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id, Name, Username, Profile.name, Sales_Region__c
                                      FROM User
                                      WHERE Id = :UserInfo.getUserId()];
    public void handle(){

        if (Trigger.isBefore && Trigger.isInsert){
            for (Sample_Display__c sampleDisplay : ((list<Sample_Display__c>)Trigger.new )){
                // 设置sales region值
                if (String.isBlank(sampleDisplay.Sales_Region__c)){
                    sampleDisplay.Sales_Region__c = currentUser.Sales_Region__c;
                }
                // 设置唯一值 key
                sampleDisplay.Key__c = sampleDisplay.Sales_Region__c + '-' + sampleDisplay.Customer__c + '-' + sampleDisplay.Store__c + '-' + sampleDisplay.Product_Model__c + '-' + sampleDisplay.Deadline__c + '-' + sampleDisplay.Number__c;
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate){
            for (Sample_Display__c sampleDisplay : ((list<Sample_Display__c>)Trigger.new )){
                // 设置sales region值
                if (String.isBlank(sampleDisplay.Sales_Region__c)){
                    sampleDisplay.Sales_Region__c = currentUser.Sales_Region__c;
                }
                // 设置唯一值 key
                sampleDisplay.Key__c = sampleDisplay.Sales_Region__c + '-' + sampleDisplay.Customer__c + '-' + sampleDisplay.Store__c + '-' + sampleDisplay.Product_Model__c + '-' + sampleDisplay.Deadline__c + '-' + sampleDisplay.Number__c;
                // 第一次审批到Upload PO&Product Number结点时，判断po number和task number数量，是否需要第二次确认
                Sample_Display__c sampleDisplayOld = (Sample_Display__c) Trigger.oldMap.get(sampleDisplay.Id);
                if (sampleDisplay.Path__c == 'Upload PO&Product Number' && sampleDisplayOld.Path__c != 'Upload PO&Product Number' && sampleDisplay.Sum_PO_Number__c != sampleDisplay.Number__c){
                    sampleDisplay.First_Submit__c = false;
                }
            }
        }

        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            List<Store_Detail__c> addList = new List<Store_Detail__c>();
            List<Sample_Display__c> sampleDisplayList = new List<Sample_Display__c>();
            for (Sample_Display__c sampleDisplay : ((list<Sample_Display__c>)Trigger.new )){
                // store类型的sample display新建后同时创建一个store details
                if (sampleDisplay.Task_Level__c == 'Store'){
                    sampleDisplayList.add(sampleDisplay);
                }
            }
            for (Sample_Display__c sampleDisplay : sampleDisplayList){
                Store_Detail__c sd = new Store_Detail__c();
                sd.Sample_Display__c = sampleDisplay.Id;
                sd.Store__c = sampleDisplay.Store__c ;
                sd.Key__c = sampleDisplay.Id + '-' + sampleDisplay.Store__c;
                sd.Number__c = sampleDisplay.Number__c ;
                sd.Product_Model__c = sampleDisplay.Product_Model__c ;

                addList.add(sd);
            }
            Database.Upsert (addList, Store_Detail__c.Fields.Key__c, false);
        }

        // if (Trigger.isAfter && Trigger.isUpdate){
        // // 子任务全部完成总任务id集合
        // Set<Id> sendEmailIdSet = new Set<Id>();
        // Map<Id, Sample_Display__c> sdMap = new Map<Id, Sample_Display__c>();
        // for (Sample_Display__c sampleDisplay : ((list<Sample_Display__c>)Trigger.new )){
        //     Sample_Display__c sampleDisplayOld = (Sample_Display__c) Trigger.oldMap.get(sampleDisplay.Id);
        //     // 完成率100%后对流程内所有人进行邮件通知
        //     // if (sampleDisplay.Sum_Customer_Detail__c >= sampleDisplay.Number__c){
        //     //     sendEmailIdSet.add(sampleDisplay.Id);
        //     //     sdMap.put(sampleDisplay.Id, sampleDisplay);
        //     // }
        // }
        // // 查询所有的要发送邮件的审批人
        // List<ProcessInstance> instanceList = [SELECT Id, TargetObjectId, (SELECT Id, CreatedById, CreatedBy.Username
        //                                                                   FROM Steps)
        //                                       FROM ProcessInstance
        //                                       WHERE TargetObjectId IN:sendEmailIdSet
        //                                       ORDER BY CreatedDate DESC];
        // // 总任务 发送邮件集合
        // Map<String, Set<String>> sendEmailMap = new Map<String, Set<String>>();
        // for (ProcessInstance processInstance : instanceList){
        //     List<ProcessInstanceStep> stepsList = processInstance.Steps;
        //     for (ProcessInstanceStep step : stepsList){
        //         if (sendEmailMap.containsKey(processInstance.TargetObjectId)){
        //             Set<String> addressSet = sendEmailMap.get(processInstance.TargetObjectId);
        //             addressSet.add(step.CreatedBy.Username);
        //             sendEmailMap.put(processInstance.TargetObjectId, addressSet);
        //         } else{
        //             sendEmailMap.put(processInstance.TargetObjectId, new Set<String>{ step.CreatedBy.Username });
        //         }
        //     }
        // }
        // // 发送邮件
        // List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        // for (String str : sendEmailMap.keySet()){
        //     // 样机任务
        //     Sample_Display__c sd = sdMap.get(str);
        //     Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        //     singleEmail.setToAddresses(new List<String>(sendEmailMap.get(str)));
        //     singleEmail.setSubject('Salesforce sample display task completion notice');
        //     singleEmail.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
        //     String html = '';
        //     html = '<html>' + '<head>' + '</head>' + '<body>' + '<div">';
        //     html += '<P>' + String.format(Label.SampleDisplayEmailTemplate, new List<Object>{ sd.Product_Name__c, sd.Deadline__c.format() }) + '</p>';
        //     html += '<P>' + System.URL.getOrgDomainUrl().toExternalForm() + '/' + sd.Id + '</p>';
        //     html += '</div>' + '</body>' + '</html>';
        //     singleEmail.setHtmlBody(html);
        //     sendEmailList.add(singleEmail);
        //     Utility.insertLog('SampleDisplaySendEmail', '1', html, str + '------' + JSON.serialize(sendEmailMap.get(str)));
        // }

        // if (sendEmailList.size() > 0 && !Test.isRunningTest()){
        //     // Messaging.sendEmail(sendEmailList);
        // }
        // }

        if (Trigger.isBefore && Trigger.isDelete){
            for (Sample_Display__c sampleDisplay : ((list<Sample_Display__c>)Trigger.old)){
                // 审批通过后不可以删除
                if (sampleDisplay.Approval_Status__c == 'Approved'){
                    // if (!Test.isRunningTest()){
                    sampleDisplay.addError(System.label.Sample_Display_No_Delete); // 任务审批通过，不能删除
                    return;
                    // }
                }
            }

        }
    }

}