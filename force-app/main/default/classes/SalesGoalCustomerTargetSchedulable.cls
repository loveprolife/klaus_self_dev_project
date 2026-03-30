global with sharing class SalesGoalCustomerTargetSchedulable implements Schedulable{

    public static string customerRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Customer_Target'].Id;
    
    global void execute(SchedulableContext context) {

        System.debug('wwww SalesGoalCustomerTargetSchedulable定时开始');

        // 存放更新的Customer Target
        List<SalesGoal__c> data = new List<SalesGoal__c>();

        // 查询客户信息
        List<SalesGoal__c> accountList = [SELECT Id,Name,Customer__C,Amounts__c,TargetDay__c,Actual_Finish__c from SalesGoal__c where RecordTypeId =: customerRecordTypeId];

        if(accountList != null && accountList.size() > 0){

            for(SalesGoal__c item : accountList){
                Double actualFinish = item.Actual_Finish__c;
                CustomerTargetTriggerHandlerHelper.computeAmount(item);
                
                // 实际完成数无变化则跳过更新
                if(actualFinish != item.Actual_Finish__c){
                    data.add(item);
                }
            }

        }

        Database.update(data,true);

        //日志内容
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SalesGoalCustomerTargetSchedulable';
        ic.Time__c = System.Now();
        ic.ReturnCode__c = '1';
        ic.Req_Json__c = data.toString();
        insert ic;

        System.debug('wwww SalesGoalCustomerTargetSchedulable定时结束');

        // System.schedule('SalesGoalCustomerTargetSchedulable-', con, new SalesGoalCustomerTargetSchedulable());
    }

}