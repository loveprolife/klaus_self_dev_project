@isTest
/**************************************************************************************************
 * TestDataUtility
 * Purpose: 测试类公共方法类(数据工厂)
 * Author: Johnson
 * Create Date: 2019-05-07
 * 所有函数中返回值List在测试类中皆有参考，请按照次序往后递增数据！！！提交代码前请先更新，避免覆盖！！！
***************************************************************************************************/
public class TestDataUtility {
    public static Map<String,String> productRdTypeMap = Utility.getRecordTypeMapBySobj('Product__c');
    public static Map<String,String> quoteRdTypeMap = Utility.getRecordTypeMapBySobj('Quote__c');
    public static Map<String,String> mappingRdTypeMap = Utility.getRecordTypeMapBySobj('Mapping__c');
    public static Map<String,Profile> profileMap;
    static{
        profileMap = new Map<String,Profile>();
        List<String> pNameList = new List<String>{'System Administrator','SD Cost Team'};
        for(Profile p : [SELECT Id,Name FROM Profile WHERE Name IN:pNameList]){
            profileMap.put(p.Name, p);      
        }
    }
    public static List<User> createUserList(Boolean isInsert){
        List<User> userList = new List<User>();
        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profileMap.get('System Administrator').Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        userList.add(user1); 
        User user2 = new User(
            Alias = 'costteam', Email='costteam@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profileMap.get('SD Cost Team').Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='costteam@hisensetest.com'
        );
        userList.add(user2);
        if(isInsert){
            insert userList;
        }
        return userList;
    }
    public static void createCustomSettings(){
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAP';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
    }
    public static void createBulkApi(){
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'BulkApi';
        ifUrl1.Basic_Url__c = 'https://open-gw.hisense.com:443/apex/ords/edw_apex/sf/odss810_zhd_zgrt14?user_key=50f64716821be158f8c7fe7e45efa711';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
    }
    public static void createMappings(){
        List<Mapping__c> mpList = new List<Mapping__c>();
        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '美国分公司';
        mp1.Mapping_Code__c = 'Hisense USA';
        mp1.RecordTypeId = mappingRdTypeMap.get('GSS_Sales_Region_and_Sales_Region_Mapping');
        mpList.add(mp1);
        insert mpList;

    }
    public static List<Account> createAccountList(Boolean isInsert){
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA'

        );
        accList.add(acc1);
        Account acc2 = new Account(
        	Name = 'Test Account002',
        	SAP_Customer_Code__c = '1772378988',
        	External_Key__c = '1772378988'

        );
        accList.add(acc2);
        if(isInsert){
        	insert accList;
        }
        return accList;
    }
    public static ID createAccount(String name,String sapCustomerCode,String externalKey,String salesRegion){
        Account acc1 = new Account(
            Name = name,
            SAP_Customer_Code__c = sapCustomerCode,
            External_Key__c = externalKey,
            Sales_Region__c = salesRegion
        );
        Database.insert(acc1);
        return acc1.Id;
    }
    public static void createProduct(String name){
        Product__c productTV1 = new Product__c(
            Name = name,
            Product_Line__c = 'TV',
            Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('TV_Product_RecordType')
        );
        Database.insert(productTV1);
    }
    public static List<Product__c> createProductList(){
        List<Product__c> newProList = new List<Product__c>();
        //TV 
        Product__c productTV1 = new Product__c(
        	Name = 'TestProductTV001',
        	Product_Line__c = 'TV',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('TV_Product_RecordType')
        );
        newProList.add(productTV1);
        Product__c productTV2 = new Product__c(
            Name = 'TestProductTV002',
            Product_Line__c = 'TV',
            Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('TV_Product_RecordType')
        );
        newProList.add(productTV2);
        //Mobile
        Product__c product2 = new Product__c(
        	Name = 'TestProductMobile',
        	Product_Line__c = 'Mobile',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('Mobile_Product_RecordType')
        );
        //AC
        newProList.add(product2);
        Product__c product3 = new Product__c(
        	Name = 'TestProductAC',
        	Product_Line__c = 'AC',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('AC_Product_RecordType')
        );
        //WM
        newProList.add(product3);
        Product__c product4 = new Product__c(
        	Name = 'TestProductWM',
        	Product_Line__c = 'WM',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('WM_Product_RecordType')
        );
        //Freezer
        newProList.add(product4);
        Product__c product5 = new Product__c(
        	Name = 'TestProductFreezer',
        	Product_Line__c = 'Freezer',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('Freezer_Product_RecordType')
        );
        newProList.add(product5);
        //Refrigerator
        Product__c product6 = new Product__c(
        	Name = 'TestProductRefrigerator',
        	Product_Line__c = 'Refrigerator',
        	Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('Refrigerator_Product_RecordType')
        );
        newProList.add(product6);
        insert newProList;
        return newProList;
    }
    public static List<Pricebook__c> createPriceBookList(){
        List<Pricebook__c> newPList = new List<Pricebook__c>();
        List<Account> accList = createAccountList(true);
        List<Product__c> newProList = createProductList();
        List<Customer_Model_Product__c> newMpList = new List<Customer_Model_Product__c>();
        List<Pricebook_Entry__c> newPEntryList =new List<Pricebook_Entry__c>();
        

        Pricebook__c SD_PriceBook = new Pricebook__c(
        	Name = 'SD Price Book',
        	IsActive__c = TRUE,
        	Customer__c = accList[0].Id,
        	CurrencyIsoCode = 'USD'
        );
        newPList.add(SD_PriceBook);
        Pricebook__c USA_PriceBook = new Pricebook__c(
        	Name = 'USA Price Book',
        	IsActive__c = TRUE,
        	Customer__c = accList[0].Id,
        	CurrencyIsoCode = 'USD'
        );
        newPList.add(USA_PriceBook);
        Pricebook__c EMalaysia_PriceBook = new Pricebook__c(
        	Name = 'East Malaysia Price Book',
        	IsActive__c = TRUE,
        	Customer__c = accList[0].Id,
        	CurrencyIsoCode = 'MYR',
        	Price_Book_Region__c = 'East Malaysia'
        );
        newPList.add(EMalaysia_PriceBook);
        Pricebook__c WMalaysia_PriceBook = new Pricebook__c(
        	Name = 'West Malaysia Price Book',
        	IsActive__c = TRUE,
        	Customer__c = accList[0].Id,
        	CurrencyIsoCode = 'MYR',
        	Price_Book_Region__c = 'West Malaysia'
        );
        newPList.add(WMalaysia_PriceBook);
        insert newPList;
        //直发价格手册条目
        for(Product__c newPro : newProList){
            Pricebook_Entry__c newPEntry = new Pricebook_Entry__c(
                Product__c = newPro.Id,
                IsActive__c = TRUE,
                Cost__c = 1000,
                Cost_Type__c = 'EXW',
                CurrencyIsoCode = 'USD',
                Price_Book__c = newPList.get(0).Id,//SD Price Book
                OCY__c = 1150,
                Non_OCY__c = 1200,
                MSRP__c = 1300

            );
            newPEntryList.add(newPEntry);
            for(Integer i=0;i<2;i++){
                Customer_Model_Product__c newMp = new Customer_Model_Product__c();
	            newMp.Name = 'Customer' + newPro.Name;
	            newMp.Product_Line__c = newPro.Product_Line__c;
	            newMp.Brand__c = 'Hisense';
	            if(i == 1){
                    newMp.Country_Code__c = 'Hisense USA';
	            }else{
                    newMp.Country_Code__c = 'Hisense Malaysia';
	            }
	            newMp.ExternalId__c = newMp.Name + newMp.Country_Code__c;
	            newMpList.add(newMp);
            }
            
        }
        insert newMpList;
        for(Integer i=0;i<3;i++){
        	for(Customer_Model_Product__c newMp : newMpList){
        		//USA Price Book Entry
                if(i==0 && newMp.Country_Code__c == 'Hisense USA'){
                	Pricebook_Entry__c newPEntry = new Pricebook_Entry__c(
		                Customer_Model_Product__c = newMp.Id,
		                IsActive__c = TRUE,
		                Cost__c = 1000,
		                Cost_Type__c = 'EXW',
		                CurrencyIsoCode = 'USD',
		                Price_Book__c = newPList.get(1).Id,//USA Price Book
		                Indicative_Price__c = 1100,
		                MSRP__c = 1300

		            );
            		newPEntryList.add(newPEntry);
                }
                //Malaysia Price Book Entry
                if(i!= 0 && newMp.Country_Code__c == 'Hisense Malaysia'){
                	Pricebook_Entry__c newPEntry = new Pricebook_Entry__c(
		                Customer_Model_Product__c = newMp.Id,
		                IsActive__c = TRUE,
		                Cost__c = 1000,
		                Cost_Type__c = 'EXW',
		                CurrencyIsoCode = 'MYR',
		                Price_Book__c = i==1?newPList.get(2).Id : newPList.get(3).Id,//East Malaysia Price Book
		              
		                Indicative_Price__c = 1100,
		                Lowest_Price__c = 1200,
		                MSRP__c = 1300

		            );
		            newPEntryList.add(newPEntry);
                }
            }
        }
        insert newPEntryList;
        return newPList;
   
    }
    public static List<Quote__c> createQuoteList(Boolean isInsert){
        List<Pricebook__c> pbList = createPriceBookList();
        Account acc = new Account(
            Name = 'Test Customer for Quote'

        );
        insert acc;
        List<Quote__c> quoteList = new List<Quote__c>();
        Quote__c testQuote1 = new Quote__c(
            Name = 'Test SD Quote',
            Customer_Name__c = acc.Id,
            RecordTypeId = quoteRdTypeMap.get('Quote_Sales_Department_TV'),
            Product_Line__c = 'TV',
            Pricebook__c = pbList[0].Id,
            CurrencyIsoCode = 'USD',
            Approval_Status__c = 'Draft',
            Expiry_Date__c = System.today().addDays(-3)

        );
        quoteList.add(testQuote1);
        Quote__c testQuote2 = new Quote__c(
            Name = 'Test USA CE Quote',
            Customer_Name__c = acc.Id,
            RecordTypeId = quoteRdTypeMap.get('Quote_USA_CE'),
            Product_Line__c = 'TV',
            Pricebook__c = pbList[1].Id,
            CurrencyIsoCode = 'USD',
            Approval_Status__c = 'Draft'

        );
        quoteList.add(testQuote2);
        Quote__c testQuote3 = new Quote__c(
            Name = 'Test USA HA Quote',
            Customer_Name__c = acc.Id,
            RecordTypeId = quoteRdTypeMap.get('Quote_USA_HA'),
            Product_Line__c = 'WM;AC',
            Pricebook__c = pbList[1].Id,
            CurrencyIsoCode = 'USD',
            Approval_Status__c = 'Draft'

        );
        quoteList.add(testQuote3);
        Quote__c testQuote4 = new Quote__c(
            Name = 'Test Malaysia Quote',
            Customer_Name__c = acc.Id,
            RecordTypeId = quoteRdTypeMap.get('Quote_Malaysia'),
            Product_Line__c = 'TV',
            Pricebook__c = pbList[2].Id,
            CurrencyIsoCode = 'USD',
            Approval_Status__c = 'Draft'

        );
        quoteList.add(testQuote4);
        if(isInsert){
            insert quoteList;
        }
        return quoteList;
    }

    public static void createCustomerModelProduct(String name,String countryCode,String productLine){
        Customer_Model_Product__c customerModelProduct = new Customer_Model_Product__c();
        customerModelProduct.Product_Line__c = productLine;
        customerModelProduct.Name = name;
        customerModelProduct.Country_Code__c = countryCode;
        Database.insert(customerModelProduct);
    }

    public static void createProductRelation(String factoryModel){
        Product__c p = new Product__c(
            Name = 'TestProductTV001',
            Product_Line__c = 'TV',
            Brand__c = 'Hisense',
            RecordTypeId = productRdTypeMap.get('TV_Product_RecordType')
        );
        Database.insert(p);

        Product_Relation__c productRelation = new Product_Relation__c();
        productRelation.Product_Export_Model__c = factoryModel;
        productRelation.Factory_Model__c = p.Id;
        Database.insert(productRelation);
    }

    public static void insertMapping(String name,String mappingCode){
        Mapping__c mpp = new Mapping__c();
        mpp.Name = name;
        mpp.Mapping_Code__c = mappingCode;
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp);
    }

    public static Order_Product__c createOrderProduct(ID accId,String sapOrderNo,String externalKey){
        Order__c order = new Order__c(
            Customer__c = accId,
            SAP_Order_No__c = sapOrderNo
        );
        Database.insert(order);

        Order_Product__c orderProduct = new Order_Product__c(
            Order__c = order.Id,
            External_Key__c = '0036195576'+externalKey
        );
        return orderProduct;
    }

    public static void createSalesTargetData(String year,String month){
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8010';
        mpp.Mapping_Code__c = '8010';
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);
        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);
        SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
        costRevenueData.Year__c = year;
        costRevenueData.Month__c = month;
        costRevenueData.CurrencyIsoCode = 'MYR';
        costRevenueData.Company_Code__c = mpp.Id;
        costRevenueData.Business_Scope__c = mpp1.Id;
        costRevenueData.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData.Customer__c = accId;
        Database.insert(costRevenueData);
    }
}