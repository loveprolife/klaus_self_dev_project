public class CustomerTargetTriggerHandlerHelper {

    // 根据客户信息查询汇总 实际完成率
    public static void computeAmount(SalesGoal__c salesGoal){

        System.debug('开始处理Customer TarGet');

        // 存放店铺id
        Set<String> shopId = new Set<String>();

        // 目标完成数
        Double finishNum = salesGoal.Amounts__c;

        if(salesGoal.Name == null){
            // 查询客户信息
            Account acc = [SELECT Id,Name FROM Account WHERE Id =: salesGoal.Customer__c];
            salesGoal.Name = String.valueOf(salesGoal.TargetDay__c) + '_' + acc.Name;
        }

        // 查询客户下的店铺信息
        List<Shop__c> shops = [SELECT Id from Shop__c where Account__c =: salesGoal.Customer__c];

        System.debug('Customer TarGet: Shops' + shops);

        if(shops != null && shops.size() > 0){
            // 汇总当天所有店铺的Daily sales
            List<AggregateResult> aggregateResultrs = [SELECT 
                                                        SUM(TotalPrice__c) totalPrice 
                                                        FROM Retail_Number__c 
                                                        WHERE Shop__c IN :shops
                                                        AND ReportDate__c =: salesGoal.TargetDay__c
                                                        ];
            System.debug('Customer TarGet: aggregateResultrs' + aggregateResultrs);

            // 实际完成数
            Double actualFinish = 0;
            // 实际完成率
            Double actualFinishRate = 0;
            Object totalPrice = aggregateResultrs[0].get('totalPrice');
            if(totalPrice != null){
                System.debug('wwwwsalesGoal.Actual_Finish__c' + salesGoal.Actual_Finish__c);
                // 如果实际完成没有变化则跳过计算
                actualFinish = (Double)totalPrice;
                actualFinishRate = (actualFinish/finishNum)*100;
            }

            salesGoal.Actual_Finish__c = actualFinish;
            salesGoal.Actual_Finish_Rate__c = actualFinishRate;
            
        }else{
            salesGoal.Actual_Finish__c = 0;
            salesGoal.Actual_Finish_Rate__c = 0;
        }

        System.debug('Customer TarGet: SalesGoal__c' + salesGoal);
    }
}