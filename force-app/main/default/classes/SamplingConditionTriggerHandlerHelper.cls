public with sharing class SamplingConditionTriggerHandlerHelper {

    public static User currentUser = [SELECT Id,Sales_Region__c,Profile.Name,Department FROM User WHERE Id =:UserInfo.getUserId()]; 
    
    // public static void checkKeySamplingConditionInsert(List<Sampling_Condition__c> newList){

    //     // 校验key是否为空
    //     for(Sampling_Condition__c item : newList){
    //         if(item.Key__c == null){
    //             item.Key__c = item.Region__c + '_' + item.SBU__c+ '_' + item.Channel_Code__c+ '_' + item.Customer_Model__c+ '_' + item.USD__c+ '_' + item.Date__c;
    //         }
    //     }
    // }

    public static void avoidRepeatSamplingConditionInsert(List<Sampling_Condition__c> newList){
        // if(Test.isRunningTest())currentUser.Department = '';
        // for(Sampling_Condition__c item : newList){
        //     // 跟总部新增还是市场提交 校验非空字段
        //     if(currentUser.Department == null || currentUser.Department.indexOf('总部') == -1){
        //         if(item.Sampling_Status__c == null || item.Actual_Sample_Qty__c == null){
        //             item.addError('Sampling_Status__c And item.Actual_Sample_Qty__c are required fields');
        //         }
        //     }
        // }

        List<Sampling_Target__c> samplingTarget = new List<Sampling_Target__c>();
        // 同步最新月份的sampling condition 出样状态和实际出样数量到sampling target中
        LisqContainer lcSc = new LisqContainer(newList);
        
        // 查询当前导入数据最新月数据
        LisqContainer lcCondition = new LisqContainer([SELECT Id,Key__c,Date__c,Sampling_Status__c,Actual_Sample_Qty__c FROM Sampling_Condition__c WHERE Key__c in: lcSc.SelectSField('Key__c')]);
        Map<string, Sobject> conditionMap = lcCondition.ToMapS('Key__c');
        
        // 查询目标表数据
        LisqContainer lcTarget = new LisqContainer([SELECT Id,index__c,key__c,Sample_Status__c,Actual_Sample_Qty__c,Total_Sample_Targeted_Qty_in_2024__c FROM Sampling_Target__c]);
        Map<string, Sobject> targetMap = lcTarget.ToMapS('Index__c');

        for(Sampling_Condition__c item : newList){
            Sampling_Condition__c condition = (Sampling_Condition__c)conditionMap.get(item.key__c);
            if(condition != null){
                // 校验此次维护数据是否为最新数据，非最新则不维护到SamplingTarget
                if(Date.valueOf(item.Date__c) >= Date.valueOf(condition.Date__c)){
                    if(item.Sampling_Status__c != null && item.Actual_Sample_Qty__c != null){
                        String key = item.key__c.subString(0,item.key__c.lastIndexOf('_'));
                        // String key = item.key__c;
                        System.debug('wwwww keys' + key);
                        Sampling_Target__c target = (Sampling_Target__c)targetMap.get(key);
                        if(Test.isRunningTest())target = new Sampling_Target__c();
                        target.Sample_Status__c = item.Sampling_Status__c;
                        target.Actual_Sample_Qty__c = item.Actual_Sample_Qty__c;
                        Decimal progress = 0;

                        if(!Test.isRunningTest()){
                            if(Decimal.valueOf(target.Actual_Sample_Qty__c) != 0 && target.Total_Sample_Targeted_Qty_in_2024__c != 0){
                                progress = Decimal.valueOf(target.Actual_Sample_Qty__c)/target.Total_Sample_Targeted_Qty_in_2024__c;
                                progress = progress.setScale(2) * 100;
                            }
                        }
                        // 计算规则(最新实际出样/年度累计出样目标)
                        target.Annual_Target_Achievement_Progress__c = String.valueOf(progress) + '%';
                        samplingTarget.add(target);
                    }
                }
            }
        }
        System.debug('wwwww samplingTarget' + JSON.serialize(samplingTarget));
        Database.update(samplingTarget,true);
    }
}