/**************************************************************************************************
 * QuoteTriggerHandler
 * Purpose:Quote Trigger处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-03-20
***************************************************************************************************/
public without sharing class  QuoteTriggerHandler extends TriggerHandler{
    public static User currentUser = [SELECT Id,Profile.Name,ManagerId,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
    public static Map<String, String> quoteRecordTypeMap = Utility.getRecordTypeMapBySobj('Quote__c');
    public Set<String> customerIdSet = new Set<String>();
    public Set<String> regionSet = new Set<String>();
    public List<Quote__c> quoteList_USA = new List<Quote__c>();//美国更新价格手册的报价集合
    public List<Quote__c> quoteList_MY = new List<Quote__c>();//马来西亚更新价格手册的报价集合

    public Set<String> quoteNameSet = new Set<String>();
    public List<Quote__c> qtList = new List<Quote__c>();//新增或者修改名称的报价集合

    public override void beforeInsert(){
        System.debug('beforeInsert');
        
        for(Quote__c newQuote : (List<Quote__c>)Trigger.new){
            quoteNameSet.add(newQuote.Name);
            qtList.add(newQuote);
            String quoteRecordName = quoteRecordTypeMap.get(newQuote.RecordTypeId);
            if(quoteRecordName.contains('Sales_Department')&& String.isBlank(newQuote.Pricebook__c)){
                newQuote.Pricebook__c = Label.Price_Book_ID_For_SD;
                continue;
            }
            //为海外分公司默认币种及价格手册
            if(quoteRecordName.contains('USA')){
                newQuote.CurrencyIsoCode = 'USD';
                customerIdSet.add(newQuote.Customer_Name__c);
                quoteList_USA.add(newQuote);
            }
            if(quoteRecordName.contains('Malaysia')){
                if(String.isBlank(newQuote.Price_Book_Region__c)){
                    //Utility.addErrorToRecord(newQuote,'Please select the cutomer\'s price book region before creating a quote');
                    Utility.addErrorToRecord(newQuote,Label.Quote_Create_Must_Input_Customer_Price_Book_Region_MY);
                    continue;
                }
                newQuote.CurrencyIsoCode = 'MYR';
                regionSet.add(newQuote.Price_Book_Region__c);
                quoteList_MY.add(newQuote);
            }
            
        }
        //校验报价名称是否重复
        isDuplicateCheck(quoteNameSet,qtList);
        //为美国报价按照客户匹配价格手册
        if(quoteList_USA.size() > 0){
            matchQuotePriceBookByCustomer(quoteList_USA,customerIdSet);
        }
        //为马来报价按照价格手册区域匹配价格手册
        if(quoteList_MY.size() > 0){
            matchQuotePriceBookByCustomerRegion(quoteList_MY,regionSet);
        }
        
        
    }
    public override void beforeUpdate(){
        System.debug('beforeUpdate');
        for(Quote__c newQuote : (List<Quote__c>)Trigger.new){
            Quote__c oldQuote = (Quote__c)Trigger.oldMap.get(newQuote.Id);
            if(!newQuote.Name.equals(oldQuote.Name)){
                quoteNameSet.add(newQuote.Name);
                qtList.add(newQuote);
            }
            if(!newQuote.CurrencyIsoCode.equals(oldQuote.CurrencyIsoCode) 
                && newQuote.Quote_Product_Count__c > 0){
                //如果货币类型发生变化，且已经有添加好的报价产品，报错提示
                //Utility.addErrorToRecord(newQuote,'Please delete all added quote products before changing currency type');
                Utility.addErrorToRecord(newQuote,Label.Quote_Must_Delete_Added_Products_Before_Changing_Currency);
                continue;
            }
            String quoteRecordName = quoteRecordTypeMap.get(newQuote.RecordTypeId);
            if(!newQuote.Customer_Name__c.equals(oldQuote.Customer_Name__c)
            && quoteRecordName.contains('USA')){
                //如果价格手册发生变化，且已经有添加好的报价产品，报错提示
                if(newQuote.Quote_Product_Count__c > 0){
                    //Utility.addErrorToRecord(newQuote,'The price book will be changed, please delete all added quote products before doing this');
                    Utility.addErrorToRecord(newQuote,Label.Quote_Must_Delete_Added_Products_Before_Changing_Price_Book);
                    continue;
                }
                newQuote.Pricebook__c = null;//
                customerIdSet.add(newQuote.Customer_Name__c);
                quoteList_USA.add(newQuote);
                
            }
            if(!newQuote.Customer_Name__c.equals(oldQuote.Customer_Name__c) 
            && quoteRecordName.contains('Malaysia')){
                regionSet.add(newQuote.Price_Book_Region__c);
                quoteList_MY.add(newQuote);
            }
        }
        //校验报价名称是否重复
        if(quoteNameSet.size() > 0){
            isDuplicateCheck(quoteNameSet,qtList);
        }
        //为美国报价按照客户匹配价格手册
        if(quoteList_USA.size() > 0){
            matchQuotePriceBookByCustomer(quoteList_USA,customerIdSet);
        }
        //为马来报价按照价格手册区域匹配价格手册
        if(quoteList_MY.size() > 0){
            matchQuotePriceBookByCustomerRegion(quoteList_MY,regionSet);
        }

    }
    /**
     方法名: isDuplicateCheck
     功能说明: 判断报价名称是否重复
     参数说明: Set<String> quoteNameSet,List<Quote__c> qtList
     返回值: 
     作者: Johnson
     日期: 2019-04-04
    */
    private void isDuplicateCheck(Set<String> quoteNameSet,List<Quote__c> qtList){
        Map<String,String> existQuoteNameMap = new Map<String,String>();
        for(Quote__c pb : [SELECT Id,Name FROM Quote__c WHERE Name IN:quoteNameSet]){
            existQuoteNameMap.put(pb.Name, pb.Id);
        }
        //System.debug('existQuoteNameMap: ' + existQuoteNameMap);
        for(Quote__c newQuote : qtList){
            if(existQuoteNameMap.containsKey(newQuote.Name)){
                //Utility.addErrorToRecord(newQuote,'Creation or editing is not allowed, a quote with the same name already exists in the system.');
                Utility.addErrorToRecord(newQuote,Label.Quote_Name_Duplicate_Alert);
                continue;
            }
        }
    }
    /**
     方法名: matchQuotePriceBookByCustomer
     功能说明: 根据客户为海外分公司默认报价价格手册
     参数说明: List<Quote__c> quoteList,Set<String> customerIdSet 
     返回值: 
     作者: Johnson
     日期: 2019-04-03
    */
    private void matchQuotePriceBookByCustomer(List<Quote__c> quoteList,Set<String> customerIdSet){
        Map<String,String> pbMap = new Map<String,String>();//Customer ID => Price Book ID
        for(Pricebook__c pb : [SELECT Id,Name,Customer__c FROM Pricebook__c WHERE Customer__c IN:customerIdSet AND IsActive__c = TRUE]){
            pbMap.put(pb.Customer__c, pb.Id);
        }
        for(Quote__c newQuote : quoteList){
            if(!pbMap.containsKey(newQuote.Customer_Name__c)){
                continue; 
            }
            newQuote.Pricebook__c = pbMap.get(newQuote.Customer_Name__c);
        }
    }
    /**
     方法名: matchQuotePriceBookByCustomerRegion
     功能说明: 根据价格手册区域为海外分公司默认报价价格手册
     参数说明: List<Quote__c> quoteList,Set<String> regionSet 
     返回值: 
     作者: Johnson
     日期: 2019-04-19
    */
    private void matchQuotePriceBookByCustomerRegion(List<Quote__c> quoteList,Set<String> regionSet){
        Map<String,String> pbMap = new Map<String,String>();//Customer ID => Price Book ID
        for(Pricebook__c pb : [SELECT Id,Name,Price_Book_Region__c FROM Pricebook__c WHERE Price_Book_Region__c IN:regionSet AND IsActive__c = TRUE]){
            pbMap.put(pb.Price_Book_Region__c, pb.Id);
        }
        for(Quote__c newQuote : quoteList){
            if(!pbMap.containsKey(newQuote.Price_Book_Region__c)){
                continue; 
            }
            //如果价格手册发生变化，且已经有添加好的报价产品，报错提示
            if(String.isNotBlank(newQuote.Pricebook__c)
            && !newQuote.Pricebook__c.equals(pbMap.get(newQuote.Price_Book_Region__c))
            && newQuote.Quote_Product_Count__c > 0){
                //Utility.addErrorToRecord(newQuote,'The price book will be changed, please delete all added quote products before doing this');
                Utility.addErrorToRecord(newQuote,Label.Quote_Must_Delete_Added_Products_Before_Changing_Price_Book);
                continue;
            }
            newQuote.Pricebook__c = pbMap.get(newQuote.Price_Book_Region__c);
        }
    }
    
}