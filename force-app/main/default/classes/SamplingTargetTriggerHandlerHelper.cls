public with sharing class SamplingTargetTriggerHandlerHelper {

    public static void avoidRepeatSamplingConditionInsert(List<Sampling_Target__c> newList){

        // LisqContainer newlc = new LisqContainer(newList);
        // List<String> indexSampling = newlc.SelectSField('Index__c');

        // // 查询同一纬度数据
        // LisqContainer exsitlc = new LisqContainer([
        //     SELECT 
        //         Id,
        //         Index__c 
        //         from Sampling_Target__c 
        //         where Id not in :(newLc.ToIds())
        //         And Index__c in: indexSampling
        // ]);

        // Map<String,Sobject> indexMap =  exsitlc.ToMapS('Index__c');

        // for(Sampling_Target__c item : newList){

        //     if(indexMap.containsKey(item.Index__c)){
        //         System.debug('SamplingTarget Avoid Repeat');
        //         item.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{indexMap.get(item.Index__c).Id}));
        //     }

        // }
    }
    
}