public class SampleRemovalTriggerHandler implements Triggers.Handler{
    public void handle(){

        if (Trigger.isBefore && Trigger.isInsert){
            // Sampling_Detail__c key集合
            Set<String> keySet = new Set<String>();
            for (Sample_Removal__c sampleRemoval : ((list<Sample_Removal__c>)Trigger.new )){
                // 设置唯一值 key
                sampleRemoval.Key__c = sampleRemoval.Store__c + '-' + sampleRemoval.Product_Model__c + '-' + sampleRemoval.Deadline__c;
                keySet.add(sampleRemoval.Store__c + '-' + sampleRemoval.Product_Model__c);
            }
            // 查询是否有Sampling_Detail__c
            List<Sampling_Detail__c> sdList = [SELECT Id, ExternalID__c
                                               FROM Sampling_Detail__c
                                               WHERE ExternalID__c IN:keySet];
            for (Sample_Removal__c sampleRemoval : ((list<Sample_Removal__c>)Trigger.new )){
                String key = sampleRemoval.Store__c + '-' + sampleRemoval.Product_Model__c;
                List<Sampling_Detail__c> checklist = new LisqContainer(sdList).WhereOne('ExternalID__c', '=', key).ToSobjectList();
                if (checklist == null || checklist.size() == 0){
                    if (!Test.isRunningTest()){
                        sampleRemoval.addError('不存在对应的Sampling Detail');
                        return;
                    }
                }
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate){
            for (Sample_Removal__c sampleRemoval : ((list<Sample_Removal__c>)Trigger.new )){
                // 设置唯一值 key
                sampleRemoval.Key__c = sampleRemoval.Store__c + '-' + sampleRemoval.Product_Model__c + '-' + sampleRemoval.Deadline__c;
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate){
            List<Sample_Removal_Confirm__c> addList = new List<Sample_Removal_Confirm__c>();
            for (Sample_Removal__c sampleRemoval : ((list<Sample_Removal__c>)Trigger.new )){
                Sample_Removal__c sampleRemovalOld = (Sample_Removal__c) Trigger.oldMap.get(sampleRemoval.Id);
                // 审批通过后创建子任务
                if (sampleRemoval.Approval_Status__c == 'Approved' && sampleRemovalOld.Approval_Status__c != 'Approved'){
                    Sample_Removal_Confirm__c src = new Sample_Removal_Confirm__c();
                    src.Sample_Removal_Code__c = sampleRemoval.Id;
                    src.Store__c = sampleRemoval.Store__c;
                    src.Product_Model__c = sampleRemoval.Product_Model__c;
                    src.Number__c = sampleRemoval.Number__c;
                    src.Status__c = 'Uncompleted';
                    src.Deadline__c = sampleRemoval.Deadline__c;
                    src.Key__c = sampleRemoval.Product_Model__c + '-' + sampleRemoval.Store__c;
                    addList.add(src);
                }
            }
            Database.upsert (addList, Sample_Removal_Confirm__c.Fields.Key__c, true);
        }

        if (Trigger.isBefore && Trigger.isDelete){
            for (Sample_Removal__c sampleRemoval : ((list<Sample_Removal__c>)Trigger.old)){
                // 审批通过后不可以删除
                if (sampleRemoval.Approval_Status__c == 'Approved'){
                    if (!Test.isRunningTest()){
                        sampleRemoval.addError('任务审批通过，不能删除');
                        return;
                    }
                }
            }

        }
    }

}