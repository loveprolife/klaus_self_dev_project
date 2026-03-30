/**************************************************************************************************
 * Name:QuoteAddProductController
 * Purpose:选择报价产品
 * Author: Deloitte Johnson
 * Create Date: 2019-02-20
***************************************************************************************************/
global  without sharing class QuoteAddProductController{
    public static User currentUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap(); 
    public Class InitDataWarp{
        public Quote__c thisQuote;
        public User currentUser;
        public List<Pricebook_Entry__c> productList;
        List<Utility.PicklistItem> productLinePicklists;
        List<Utility.PicklistItem> productStatusPicklists;
        List<Utility.PicklistItem> deliveryFormPicklists;
        List<Utility.PicklistItem> costTypePicklists;
    } 
    
    @AuraEnabled 
    public static String initData(String quoteId){
        InitDataWarp initData = new InitDataWarp(); 
        initData.productLinePicklists = new List<Utility.PicklistItem>();       
        Quote__c thisQuote = getQuoteInfo(quoteId);
        System.debug('thisQuote==>>>' +thisQuote);
        
        List<Utility.PicklistItem> allLinePicklists = Utility.getPicklistValueList('Quote__c', 'Product_Line__c');
        for(Utility.PicklistItem proLine : allLinePicklists){
            //initData.productLinePicklists.add(proLine);
            if(thisQuote.Product_Line__c.contains(proLine.value)){
                initData.productLinePicklists.add(proLine);
            }
        }
        //如果Quote价格手册为空,默认价格手册，直发根据区域，海外分公司一个客户对应只有一本价格手册
        if(String.isBlank(thisQuote.Pricebook__c)){
            String pbId = Utility.getPriceBookIdByRegionOrCustomer(thisQuote);
            if(String.isNotBlank(pbId)){
                thisQuote.Pricebook__c = pbId;
                update thisQuote;
            }
        }
        List<Pricebook_Entry__c> proList = new List<Pricebook_Entry__c>();
        List<String> proLineList = new List<String>{initData.productLinePicklists[0].value};
        proList = getSearchResultList(proLineList,'',quoteId);
        initData.productList = proList;
        initData.thisQuote = thisQuote;
        initData.currentUser = currentUser;
        initData.productStatusPicklists = Utility.getPicklistValueList('Quote_Product__c', 'Product_Status__c');
        initData.deliveryFormPicklists = Utility.getPicklistValueList('Quote_Product__c', 'Delivery_Form__c');
        initData.costTypePicklists = Utility.getPicklistValueList('Quote_Product__c', 'Cost_Type__c');
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }
@AuraEnabled  
    public static List<Pricebook_Entry__c> getSearchResultList(List<String> proLineList,String proName,String quoteId){
        String sqlQuery='SELECT Id,Product__c,Product__r.Name,Product__r.Product_Model__c,Product__r.Product_Manager__c,Product__r.Energy_Efficiency_Ratio__c,'+
                        ' Product__r.HDR__c,Product__r.Size__c,Product__r.Narrow_border__c,Product__r.Software_android_version__c,Cost__c,Cost_Type__c,CurrencyIsoCode,' + 
                        ' Customer_Model_Product__c,Customer_Model_Product__r.Name,Customer_Model_Product__r.Product_Factory_Model__c,' + 
                        ' Customer_Model_Product__r.Product_Factory_Model__r.Name,Customer_Model_Product__r.Product_Factory_Model__r.AC_Type__c' +
                        ' FROM Pricebook_Entry__c WHERE IsActive__c = true';
        Quote__c  thisQuote = getQuoteInfo(quoteId);
        if(String.isBlank(thisQuote.Pricebook__c)){
            return new List<Pricebook_Entry__c>();
        }
        if(thisQuote.RecordType.DeveloperName.contains('Sales_Department')){
            sqlQuery += ' AND Product__r.IsActive__c = true';
            if(String.isNotBlank(proName)){
                sqlQuery += ' AND (Product__r.Name like \'%' + proName.trim() + '%\')';
            }
            if(proLineList.size() > 0){
                sqlQuery += ' AND Product__r.Product_Line__c IN:proLineList';
            }
        }else{
            sqlQuery += ' AND Customer_Model_Product__c != null';
            if(String.isNotBlank(proName)){
                sqlQuery += ' AND (Customer_Model_Product__r.Name like \'%' + proName.trim() + '%\')';
            }
            if(proLineList.size() > 0){
                sqlQuery += ' AND Customer_Model_Product__r.Product_Line__c IN:proLineList';
            }
        }
        
        String priceBookId = thisQuote.Pricebook__c;
        sqlQuery += ' AND Price_Book__c =:priceBookId ORDER BY Product__r.Name ASC,Customer_Model_Product__r.Name ASC LIMIT 20';
        System.debug('sqlQuery===>'+sqlQuery);
        List<Pricebook_Entry__c> proList = Database.query(sqlQuery);
        return proList;
    }
@AuraEnabled  
    //根据选中的价格手册条目带值并生成相应的报价产品
    public static String saveSelectedProList(String proIdString,String quoteId){
        String saveMessage = 'SUCCESS';
        Quote__c  thisQuote = getQuoteInfo(quoteId);
        List<String> proIdList = proIdString.split(';');        
        List<Quote_Product__c> selectedProList = new List<Quote_Product__c>();
        List<Pricebook_Entry__c> proList = [SELECT Id,Product__c,Product__r.Name,Product__r.Product_Model__c,Cost__c,Cost_Type__c,Lowest_Price__c,
                                   Product__r.Product_Line__c,CurrencyIsoCode,Customer_Model_Product__c,Customer_Model_Product__r.Product_Factory_Model__c,
                                   Customer_Model_Product__r.Product_Line__c,Customer_Model_Product__r.Brand__c,Indicative_Price__c,MSRP__c,OCY__c,Non_OCY__c 
                                   FROM Pricebook_Entry__c WHERE Id IN:proIdList ORDER BY Product__r.Name ASC];
        Map<String,String> qtItemRecordTpeMap = Utility.getRecordTypeMapBySobj('Quote_Product__c');
        Savepoint sp = Database.setSavepoint();
        try{
            for(Pricebook_Entry__c pro : proList){
                Quote_Product__c quoteItem = new Quote_Product__c();
                quoteItem.Quote_Name__c = quoteId;
                if(String.isNotBlank(thisQuote.Opportunity_Name__c)){
                    quoteItem.Opportunity__c = thisQuote.Opportunity_Name__c;
                }
                quoteItem.Pricebook_Entry__c = pro.Id; 
                quoteItem.Cost_Type__c = pro.Cost_Type__c;
                if(String.isNotBlank(pro.Product__c)){
                    quoteItem.Need_to_Provide_EXW__c = 'NO';
                    quoteItem.Product__c = pro.Product__c;
                    quoteItem.Product__r = pro.Product__r;
                    quoteItem.Product_Line__c = pro.Product__r.Product_Line__c;                    
                }
                if(String.isNotBlank(pro.Customer_Model_Product__c)){
                    quoteItem.Customer_Model_Product__c = pro.Customer_Model_Product__c;
                    quoteItem.Product_Line__c = pro.Customer_Model_Product__r.Product_Line__c;
                    quoteItem.Brand__c = pro.Customer_Model_Product__r.Brand__c;
                    quoteItem.Product__c = pro.Customer_Model_Product__r.Product_Factory_Model__c;
                }
                quoteItem.CurrencyIsoCode = thisQuote.CurrencyIsoCode;
                //将直发部门的美元定价转换成实际报价币种 USD => Other currency
                Decimal rate;
                if(!quoteItem.CurrencyIsoCode.equals(pro.CurrencyIsoCode)
                    && pro.CurrencyIsoCode.equals('USD')){
                    rate = currencyRateMap.get(quoteItem.CurrencyIsoCode);
                    quoteItem.Cost__c = pro.Cost__c == null ? null : pro.Cost__c * rate;
                    quoteItem.MSRP__c = pro.MSRP__c == null ? null : pro.MSRP__c * rate;
                    quoteItem.OCY__c = pro.OCY__c == null ? null : pro.OCY__c * rate;
                    quoteItem.Non_OCY__c = pro.Non_OCY__c == null ? null : pro.Non_OCY__c * rate;
                }else{
                    quoteItem.Cost__c = pro.Cost__c;
                    quoteItem.MSRP__c = pro.MSRP__c;
                    quoteItem.OCY__c = pro.OCY__c;
                    quoteItem.Non_OCY__c = pro.Non_OCY__c;
                    //海外公司价格，不用汇率换算
                    quoteItem.Lowest_Price__c = pro.Lowest_Price__c;
                    quoteItem.Indicative_Price__c = pro.Indicative_Price__c;
                }
                
                if(thisQuote.RecordType.DeveloperName.contains('Sales_Department_TV')){
                    quoteItem.RecordTypeId = qtItemRecordTpeMap.get('Quote_Product_Sales_Department_TV');
                }else if(thisQuote.RecordType.DeveloperName.contains('Sales_Department_Mobile')){
                    quoteItem.RecordTypeId = qtItemRecordTpeMap.get('Quote_Product_Sales_Department_Mobile');
                }else if(thisQuote.RecordType.DeveloperName.contains('USA_CE')){
                    quoteItem.RecordTypeId = qtItemRecordTpeMap.get('Quote_Product_USA_CE');
                }else if(thisQuote.RecordType.DeveloperName.contains('USA_HA')){
                    quoteItem.RecordTypeId = qtItemRecordTpeMap.get('Quote_Product_USA_HA');
                }else if(thisQuote.RecordType.DeveloperName.contains('Malaysia')){
                    quoteItem.RecordTypeId = qtItemRecordTpeMap.get('Quote_Product_Malaysia');
                }
                selectedProList.add(quoteItem);
            }
            insert selectedProList;
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            saveMessage = Utility.getProperErrorMessage(e.getMessage());
        }
        return saveMessage;
    }
// @AuraEnabled  
//     public static String saveQuoteProduct(List<Quote_Product__c> productList){
//         String saveMessage = 'SUCCESS';
//         Savepoint sp = Database.setSavepoint();
//         try{
//             if(productList == null || productList.size() <= 0){
//                 saveMessage = 'Save information can\'t be null';
//                 return saveMessage;
//             }
//             insert productList;

//         }catch(Exception e){
//             Database.rollback(sp);
//             system.debug('error message: '+e.getMessage());
//             system.debug('line number: '+e.getLineNumber());
//             saveMessage = 'Error Message:' +e.getMessage() + ' Line Number:' + e.getLineNumber();
//         }
//         return saveMessage;
//     }
    public static Quote__c getQuoteInfo(String quoteId){
        Quote__c thisQuote = [SELECT Id,Name,Approval_Status__c,Customer_Name__c,Product_Line__c,RecordType.DeveloperName,
                             CurrencyIsoCode,Opportunity_Name__c,Pricebook__c,Price_Book_Region__c
                             FROM Quote__c WHERE Id =:quoteId];
        return thisQuote;
    }
    // public class QuoteItemListData{
    //     public List<QuoteItemData> quoteItems;
    // }
    // public class QuoteItemData {
    //     public String quoteId;
    //     public String pricebookEntryId;
    //     public String productId;
    //     public String exwCost;
    //     public String lowestPrice;
    //     public String sellInPrice;
    //     public String quantity;
    // }  
}