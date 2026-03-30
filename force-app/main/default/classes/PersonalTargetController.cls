public without sharing class PersonalTargetController {
	
    
    public static ConResponse getTargetAndCompletedAmount(String startDate,String endDate) {
        return getTargetAndCompletedAmountCore(UserInfo.getUserId(),startDate, endDate);
    }
    
    @AuraEnabled
    public static ConResponse getTargetAndCompletedAmountCore(String UserId,String startDate,String endDate){
        MapResponse resp = new MapResponse();
        Decimal completedAmount = 0;
        Decimal targetAmount = 0;
        if(UserId == null){
            UserId = UserInfo.getUserId();
        }
        if(startDate == null){
            startDate = Date.today().year()+'-'+ Date.today().month()+'-'+'1';
        }
        if(endDate == null){
            endDate = Date.today().year()+'-'+ Date.today().month()+'-'+Date.daysInMonth(Date.today().year(),Date.today().month());
        }
        // List<SalesGoal__c> sgList = [SELECT Id,Name,TargetDay__c ,CompletedSales__c,Amounts__c
        //                                 FROM SalesGoal__c 
        //                                 WHERE TargetDay__c >=: Date.valueOf(startDate) AND TargetDay__c <=: Date.valueOf(endDate) AND Promoter__c =:UserId];

        List<SalesGoal__c> sgList = [SELECT Id, Name, TargetDay__c, CompletedSales__c, Amounts__c, Month__c
                                        FROM SalesGoal__c 
                                        WHERE Month__c =:String.valueOf(Date.today().month()) AND Promoter__c =:UserId];

        for(SalesGoal__c sg:sgList){
            completedAmount += sg.CompletedSales__c;
            targetAmount += sg.Amounts__c;
        }
        
        resp.put('completedAmount', completedAmount);
        resp.put('targetAmount', targetAmount);
        
        return resp;
    }
}