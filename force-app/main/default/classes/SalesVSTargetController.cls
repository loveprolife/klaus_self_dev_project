public with sharing class SalesVSTargetController {

    // 此类数据有权限控制，不可将 with sharing 改为 without sharing
    
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    @AuraEnabled
    public static ConResponse getInitData(){

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
		resp.data = mso;     

        String userId = UserInfo.getUserId();
        List<User> currentUser = [SELECT Id, Name, Profile.Name, CurrencyIsoCode, Sales_Region__c FROM User WHERE Id = :userId ];
        Boolean isPromoter = false;
        String userCurrency = '';
        String salesRegion = '';
        if(currentUser.size() > 0) {
            System.debug('currentUser Profile Name：' + currentUser[0].Profile.Name);
            isPromoter = currentUser[0].Profile.Name.contains('Promoter');
            userCurrency = currentUser[0].CurrencyIsoCode;
            salesRegion = currentUser[0].Sales_Region__c;
        }
        

        // List<SalesGoal__c> targetList = [SELECT Promoter__c, Store__c, ProductLine__c, Product__c, Year__c, Month__c, Day__c, TargetDay__c, convertCurrency(Amounts__c) amount, FORMAT(Amounts__c)
        //                                     FROM SalesGoal__c 
        //                                     WHERE Promoter__c = :userId AND SameMonth__c = true AND IsActive__c = true ];

        String targetQueryString = 'SELECT Promoter__c, Store__c, ProductLine__c, Product__c, Year__c, Month__c, Day__c, TargetDay__c, convertCurrency(Amounts__c) amount, FORMAT(Amounts__c) ';
        targetQueryString += 'FROM SalesGoal__c ';
        targetQueryString += 'WHERE SameMonth__c = true AND IsActive__c = true ';
        if(isPromoter) {
            targetQueryString += 'AND Promoter__c = :userId ';
        }
        List<SalesGoal__c> targetList = Database.query(targetQueryString);

        // List<Retail_Number__c> salesList = [SELECT SalesGoal__c, Shop__c, CreatedById, CreatedBy.Name, Product__c, Product__r.Name, Product__r.Product_Line__c, Product_Line__c, convertCurrency(TotalPrice__c) amount, FORMAT(TotalPrice__c)
        //                                         FROM Retail_Number__c 
        //                                         WHERE CreatedById = :userId AND SameMonth__c = true];

        String salesQueryString = 'SELECT SalesGoal__c, Shop__c, CreatedById, CreatedBy.Name, Product__c, Product__r.Name, Product__r.Product_Line__c, Product_Line__c, convertCurrency(TotalPrice__c) amount, FORMAT(TotalPrice__c) ';
        salesQueryString += 'FROM Retail_Number__c ';
        salesQueryString += 'WHERE SameMonth__c = true AND Status__c = \'Submitted\' ';
        if(isPromoter) {
            salesQueryString += 'AND OwnerId__c = :userId ';
        }
        List<Retail_Number__c> salesList = Database.query(salesQueryString);

        Decimal target = 0.0;
        Decimal allSales = 0.0;
        Decimal completedSales = 0.0;
        Map<String, List<String>> storeIdAndTargetFactorMap = new Map<String, List<String>>();
        for(SalesGoal__c item : targetList) {
            target += (Decimal)item.get('amount');
            List<String> targetFactorList = new List<String>();
            if(storeIdAndTargetFactorMap.containsKey(item.Store__c)) {
                targetFactorList = storeIdAndTargetFactorMap.get(item.Store__c);
            }
            targetFactorList.add(item.ProductLine__c);
            targetFactorList.add(item.Product__c);
            if((item.ProductLine__c == null) & (item.Product__c == null)) {
                targetFactorList.add('emptyFactor');
            }
            storeIdAndTargetFactorMap.put(item.Store__c, targetFactorList);
        }
        for(Retail_Number__c item : salesList) {
            allSales += (Decimal)item.get('amount');
            if(storeIdAndTargetFactorMap.containsKey(item.Shop__c)) {
                List<String> targetFactorList = storeIdAndTargetFactorMap.get(item.Shop__c);
                if(targetFactorList.contains(item.Product__c) || targetFactorList.contains(item.Product__r.Product_Line__c) || targetFactorList.contains('emptyFactor')) {
                    completedSales += (Decimal)item.get('amount');
                }
            }
        }
        mso.put('target', target);
        mso.put('allSales', allSales);
        mso.put('completedSales', completedSales);
        mso.put('userCurrency', userCurrency);
        mso.put('salesRegion', salesRegion);


        if(salesRegion == 'Hisense Indonesia') {
            // 提成 Commission
            Decimal commission = 0;
            Date today = Date.today();
            String dataIndex = userId + '_' + String.valueOf(today.year()) + '_' + String.valueOf(today.month());
            List<Commission__c> commissionList = [SELECT Id, Name, OwnerId, Month__c, Year__c, DataIndex__c, convertCurrency(FinalAmount__c) amount, FORMAT(FinalAmount__c)
                                                        FROM Commission__c 
                                                        WHERE DataIndex__c = :dataIndex];
            if(commissionList.size() != 0) {
                commission = (Decimal)commissionList[0].get('amount');
            }
            mso.put('commission', commission);
        }

        return resp;
        
    }
}