/**************************************************************************************************
 * QuoteLineItemTriggerHandler
 * Purpose:Quote Product Trigger处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-03-20
***************************************************************************************************/
public without sharing class  QuoteLineItemTriggerHandler extends TriggerHandler{
    public static User currentUser = [SELECT Id,Profile.Name,ManagerId,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
    public override void beforeInsert(){
        System.debug('beforeInsert');
        Set<String> pbIdSet = new Set<String>();
        List<Quote_Product__c> insertQuoteItemList = new List<Quote_Product__c>();
        for(Quote_Product__c newQuoteItem : (List<Quote_Product__c>)Trigger.new){
        	System.debug('newQuoteItem: ' +newQuoteItem);
        	if(String.isBlank(newQuoteItem.Opportunity__c)
        	&& String.isNotBlank(newQuoteItem.Quote_Opportunity_ID__c)){
                newQuoteItem.Opportunity__c = newQuoteItem.Quote_Opportunity_ID__c;
        	}
        	//筛选出导入的报价产品，后台带出相关价格信息
            if(String.isNotBlank(newQuoteItem.External_ID__c)
            && String.isNotBlank(newQuoteItem.Pricebook_Entry__c)){
                System.debug('quote product import');
           		insertQuoteItemList.add(newQuoteItem);
                pbIdSet.add(newQuoteItem.Pricebook_Entry__c);
            }
        }
        if(pbIdSet.size() > 0){
            Map<String,Pricebook_Entry__c> pbEntryMap = new Map<String,Pricebook_Entry__c>(
            	                   [SELECT Id,Product__c,Product__r.Name,Product__r.Product_Model__c,Cost__c,Cost_Type__c,Lowest_Price__c,
                                   Product__r.Product_Line__c,CurrencyIsoCode,Customer_Model_Product__c,Customer_Model_Product__r.Product_Factory_Model__c,
                                   Customer_Model_Product__r.Product_Line__c,Customer_Model_Product__r.Brand__c,Indicative_Price__c,MSRP__c,OCY__c,Non_OCY__c 
                                   FROM Pricebook_Entry__c WHERE Id IN:pbIdSet]);
            for(Quote_Product__c quoteItem : insertQuoteItemList){
                if(!pbEntryMap.containsKey(quoteItem.Pricebook_Entry__c)){
                    continue;
                }
                Pricebook_Entry__c pb = pbEntryMap.get(quoteItem.Pricebook_Entry__c);
                quoteItem.Cost_Type__c = pb.Cost_Type__c;
                if(String.isNotBlank(pb.Product__c)){
                    quoteItem.Need_to_Provide_EXW__c = 'NO';
                    quoteItem.Product__c = pb.Product__c;
                    quoteItem.Product__r = pb.Product__r;
                    quoteItem.Product_Line__c = pb.Product__r.Product_Line__c;                    
                }
                if(String.isNotBlank(pb.Customer_Model_Product__c)){
                    quoteItem.Customer_Model_Product__c = pb.Customer_Model_Product__c;
                    quoteItem.Product_Line__c = pb.Customer_Model_Product__r.Product_Line__c;
                    quoteItem.Brand__c = pb.Customer_Model_Product__r.Brand__c;
                    quoteItem.Product__c = pb.Customer_Model_Product__r.Product_Factory_Model__c;
                }
                //quoteItem.CurrencyIsoCode = thisQuote.CurrencyIsoCode;
                //将直发部门的美元定价转换成实际报价币种 USD => Other currency
                Decimal rate;
                if(!quoteItem.CurrencyIsoCode.equals(pb.CurrencyIsoCode)
                    && pb.CurrencyIsoCode.equals('USD')){
                    rate = currencyRateMap.get(quoteItem.CurrencyIsoCode);
                    quoteItem.Cost__c = pb.Cost__c == null ? null : pb.Cost__c * rate;
                    quoteItem.MSRP__c = pb.MSRP__c == null ? null : pb.MSRP__c * rate;
                    quoteItem.OCY__c = pb.OCY__c == null ? null : pb.OCY__c * rate;
                    quoteItem.Non_OCY__c = pb.Non_OCY__c == null ? null : pb.Non_OCY__c * rate;
                }else{
                    quoteItem.Cost__c = pb.Cost__c;
                    quoteItem.MSRP__c = pb.MSRP__c;
                    quoteItem.OCY__c = pb.OCY__c;
                    quoteItem.Non_OCY__c = pb.Non_OCY__c;
                    //海外公司价格，不用汇率换算
                    quoteItem.Lowest_Price__c = pb.Lowest_Price__c;
                    quoteItem.Indicative_Price__c = pb.Indicative_Price__c;
                }
            }
        }
    }
}