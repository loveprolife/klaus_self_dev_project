/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class PlannedCompletionRateReportBatchTest {
	@testSetup 
    static void setup() {
    	TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8500';
        tcm.Country__c = 'US';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

    	Account acc1 = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504263',
            External_Key__c = '0000504263',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500'
        );
        Database.insert(acc1);
    	// ID acc1.Id = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = acc1.Id;
        customerProductLine.Management_Customer__c = acc1.Id;
        customerProductLine.Management_Customer_Branch_Company__c = acc1.Id;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        TestDataUtility.createCustomerModelProduct('H359BI-WD', null,null);
        TestDataUtility.createCustomerModelProduct('H359BI-WD1', 'Hisense USA','TV');
        //Cooking用出口型号
        TestDataUtility.createProduct('65M7000UWG');
        //电视  手机用工厂型号
        TestDataUtility.createProduct('HA65M7000UWTG');
        //冰冷洗用工厂型号建relation
        TestDataUtility.createProductRelation('HA65M7000UWTG');

        //添加产品线
        TestDataUtility.insertMapping('62','Refrigerator');
        TestDataUtility.insertMapping('65', 'Cooking');
        TestDataUtility.insertMapping('14', 'TV');

        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId = Schema.getGlobalDescribe().get('Mapping__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SAP_Product_Line_and_Product_Line_Mapping').getRecordTypeId();
        Database.insert(mpp1);

        Order__c order = new Order__c(
            Customer__c = acc1.Id,
            SAP_Order_No__c = '4500004397',
            External_Key__c = '45000043970000504263'
        );
        Database.insert(order);
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.External_Key__c = '4500004397000010';
        Database.insert(orderProduct);
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = acc1.Id;
        deliveryOrder.SAP_Delivery_Order_No__c = '0080002649';
        Database.insert(deliveryOrder);
        Delivery_Order_Item__c doi = new Delivery_Order_Item__c();
        doi.Delivery_Order__c = deliveryOrder.Id;
        doi.External_Key__c = '0080002649000010';
        doi.Order_Product__c = orderProduct.Id;
        Database.insert(doi);
       
        Invoice__c inv = new Invoice__c();
        inv.Customer__c = acc1.Id;
        inv.Invoice_Posting_Date__c = Date.newInstance(2019, 1, 15);
        insert inv;
        Invoice_Item__c invItem = new Invoice_Item__c();
        invItem.Invoice__c = inv.Id;
        invItem.SAP_Product_Line__c = mpp1.Id;
        invItem.Sales_Order_Item__c = orderProduct.Id;
        insert invItem;

        Sales_Target_Branch_Company_Use__c salesTarget1 = new Sales_Target_Branch_Company_Use__c();
        salesTarget1.Customer_Name__c = acc1.Id;
        salesTarget1.Product_Line__c = 'TV';
        salesTarget1.Year__c = '2019';
        Database.insert(salesTarget1);
    }	
    static testMethod void testMethod1() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','1','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod2() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','2','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod3() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','3','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod4() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','4','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod5() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','5','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod6() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','6','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod7() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','7','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod8() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','8','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod9() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','9','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod10() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','10','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod11() {
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','11','15');
        //损益表batch
        Database.executeBatch(pcrr,200);
    }
    static testMethod void testMethod12() {
        test.startTest();
    	PlannedCompletionRateReportBatch pcrr = new PlannedCompletionRateReportBatch('2019','12','15');
        //损益表batch
        Database.executeBatch(pcrr,200);


        ID accId = TestDataUtility.createAccount('BatchTest1', '0000504290', '0000504290', 'Hisense USA');
        Sales_Target_Branch_Company_Use__c stbc = new Sales_Target_Branch_Company_Use__c();
        stbc.Customer_Name__c = accId;
        stbc.Product_Line__c = Label.SACE;
        stbc.Year__c = '2019';
        Database.insert(stbc);
        PlannedCompletionRateReportBatch pc = new PlannedCompletionRateReportBatch('2','2','2');
        pc.planIncome('01', stbc);
        pc.planIncome('02', stbc);
        pc.planIncome('03', stbc);
        pc.planIncome('04', stbc);
        pc.planIncome('05', stbc);
        pc.planIncome('06', stbc);
        pc.planIncome('07', stbc);
        pc.planIncome('08', stbc);
        pc.planIncome('09', stbc);
        pc.planIncome('10', stbc);
        pc.planIncome('11', stbc);
        pc.planIncome('12', stbc);
        test.stopTest();
    }

}