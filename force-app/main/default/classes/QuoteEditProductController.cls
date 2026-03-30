/**************************************************************************************************
 * Name:QuoteEditProductController
 * Purpose:编辑报价产品
 * Author: Deloitte Johnson
 * Create Date: 2019-02-25
***************************************************************************************************/
global  without sharing class QuoteEditProductController{
public static User currentUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
public Class InitDataWarp{
        public Quote__c thisQuote;
        public User currentUser;
        public List<Quote_Product__c> productList;
        public List<Utility.PicklistItem> productStatusPicklists;
        public List<Utility.PicklistItem> deliveryFormPicklists;
        List<Utility.PicklistItem> costTypePicklists;
    }
@AuraEnabled 
    public static String initData(String quoteId){
        InitDataWarp initData = new InitDataWarp();        
        initData.productList = new List<Quote_Product__c>();
        Quote__c thisQuote = getQuoteInfo(quoteId);
        initData.thisQuote = thisQuote;
        initData.currentUser = currentUser;
        initData.productList = thisQuote.Quote_Products__r;
        initData.productStatusPicklists = Utility.getPicklistValueList('Quote_Product__c', 'Product_Status__c');
        initData.deliveryFormPicklists = Utility.getPicklistValueList('Quote_Product__c', 'Delivery_Form__c');
        initData.costTypePicklists = Utility.getPicklistValueList('Quote_Product__c', 'Cost_Type__c');
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }
@AuraEnabled   
    public static String saveQuoteProduct(List<Quote_Product__c> productList, String quoteId){
        String saveMessage = 'SUCCESS';
        system.debug('productList ' +productList);
        List<Quote_Product__c> upsertQuoteItemList = new List<Quote_Product__c>();
        Savepoint sp = Database.setSavepoint();
        try{
        	Quote__c thisQuote = getQuoteInfo(quoteId);
        	Map<String,Quote_Product__c> quoteItemIdMap = new Map<String,Quote_Product__c>();
        	List<Quote_Product__c> deleteQuoteItemList = new List<Quote_Product__c>();
        	for(Quote_Product__c quoteItem : thisQuote.Quote_Products__r){
                quoteItemIdMap.put(quoteItem.Id,quoteItem);
        	}
            for(Quote_Product__c quoteItem : productList){
                if(String.isNotBlank(quoteItem.Id)){
                	//编辑quote product


                    //移除未删除的quote product
                    if(quoteItemIdMap.containsKey(quoteItem.Id)){
                        quoteItemIdMap.remove(quoteItem.Id);
                    }             
                }else{
                	//新增quote product
                }
                upsertQuoteItemList.add(quoteItem);
            }
            deleteQuoteItemList = quoteItemIdMap.values();
            update upsertQuoteItemList;
            if(deleteQuoteItemList.size() > 0){
                delete deleteQuoteItemList;
            }

        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            saveMessage = Utility.getProperErrorMessage(e.getMessage());
        }
        return saveMessage;
    }
    public static Quote__c getQuoteInfo(String quoteId){
        Quote__c thisQuote = [SELECT Id,Name,RecordType.DeveloperName,CurrencyIsoCode,(SELECT Id,Name,Product__c,Product__r.Name,Cost__c,Lowest_Price__c,Unit_Sell_In_Price__c,
        	                  Quantity__c,Product_Status__c,Remark__c,Delivery_Form__c,Estimatied_Delivery_Date__c,Royalties__c,Product_Name_Formula__c,Delivery_Form_Fee__c,
                              Need_to_Provide_EXW__c FROM Quote_Products__r ORDER BY Product__r.Name ASC) 
                              FROM Quote__c WHERE Id =:quoteId];
        return thisQuote;
    }
    // public class QuoteItemListData{
    //     public List<QuoteItemData> quoteItems;
    // }
    // public class QuoteItemData {
    //     public String quoteId;
    //     public String quoteItemId;
    //     public String pricebookEntryId;
    //     public String productId;
    //     public String exwCost;
    //     public String lowestPrice;
    //     public String sellInPrice;
    //     public String quantity;
    // } 
}