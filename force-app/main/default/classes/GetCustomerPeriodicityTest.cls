@isTest
private class GetCustomerPeriodicityTest {

    private static String url = '/services/apexrest/GetCustomers';

    public static void init(){
        Integer n = 20;
        List<Account> accs = new List<Account>();
        for(Integer i=0;i<n;i++){
            Account acc = new Account(
                SAP_Customer_Code__c = 'test'+i,
                //Customer_SF_Code__c = 'test'+i,
                Sales_Region__c = 'China',
                Customer_Status__c = 'XD06',
                Customer_Category__c='B2B',
                Name = 'Test James'+i,
                External_Key__c = 'sap1000000'+i,
                Approval_Status__c = 'Approved',
                isGoFinApprove__c = 'fin_approved'
            );
            accs.add(acc);
        }
        insert accs;

        List<Customer_Product_Line__c> cpls = new List<Customer_Product_Line__c>();
        for(Integer i=0;i<n;i++){
            Customer_Product_Line__c pl = new Customer_Product_Line__c(
                Management_Customer_Branch_Company__c = accs[i].Id,
                Customer__c = accs[i].Id,
                Management_Customer__c = accs[i].Id,
                Product_Line_Name__c = 'TV'
            );
            cpls.add(pl);
        }
        insert cpls;
    }

    @isTest
    static void testDoPost() {
        init();
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI =  GetCustomerPeriodicityTest.url;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;

        req.requestBody = Blob.valueOf('');
        GetCustomerPeriodicity.doPost();
        String resbody = res.responseBody.toString();
        GetCustomerPeriodicity.SFOutputResult rvo = (GetCustomerPeriodicity.SFOutputResult)JSON.deserialize(resbody,
            GetCustomerPeriodicity.SFOutputResult.class);
        System.assertEquals(false, rvo.IsSuccess);

        GetCustomerPeriodicity.SFInput vo = new GetCustomerPeriodicity.SFInput();
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetCustomerPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetCustomerPeriodicity.SFOutputResult)JSON.deserialize(resbody,
            GetCustomerPeriodicity.SFOutputResult.class);
        System.assertEquals(false, rvo.IsSuccess);

        vo.salesRegion = 'China';
        vo.startDate = System.today().format();
        vo.endDate = System.today().addDays(2).format();
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetCustomerPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetCustomerPeriodicity.SFOutputResult)JSON.deserialize(resbody,GetCustomerPeriodicity.SFOutputResult.class);
        System.assertEquals(true, rvo.IsSuccess);

        vo.salesRegion = 'TEST';
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetCustomerPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetCustomerPeriodicity.SFOutputResult)JSON.deserialize(resbody,GetCustomerPeriodicity.SFOutputResult.class);
        System.assertEquals(true, rvo.IsSuccess);
        Test.stopTest();
    }

     @isTest
    static void testValidateInput() {
        
        Test.startTest();
        GetCustomerPeriodicity.SFInput vo = new GetCustomerPeriodicity.SFInput();
        GetCustomerPeriodicity.SFOutputResult re = GetCustomerPeriodicity.validateInput(vo);
        System.assertEquals(false, re.IsSuccess);

        re = GetCustomerPeriodicity.validateInput(null);
        System.assertEquals(false, re.IsSuccess);

        vo.salesRegion = 'test';
        vo.startDate = '2019-09-09';
        vo.endDate = '2019-09-01';
        re = GetCustomerPeriodicity.validateInput(vo);
        System.assertEquals(false, re.IsSuccess);
        Test.stopTest();
    }

    @isTest
    static void testSort(){
        List<GetCustomerPeriodicity.BranchManagementCustomer> bmList = new List<GetCustomerPeriodicity.BranchManagementCustomer>();
        GetCustomerPeriodicity.BranchManagementCustomer bmc1 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc1.productLine = 'TV';
        bmList.add(bmc1);
        GetCustomerPeriodicity.BranchManagementCustomer bmc2 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc2.productLine = 'Freezer';
        bmList.add(bmc2);
        GetCustomerPeriodicity.BranchManagementCustomer bmc3 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc3.productLine = 'Refrigerator';
        bmList.add(bmc3);
        GetCustomerPeriodicity.BranchManagementCustomer bmc4 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc4.productLine = 'test';
        bmList.add(bmc4);
        GetCustomerPeriodicity.BranchManagementCustomer bmc5 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc5.productLine = 'WM';
        bmList.add(bmc5);
        GetCustomerPeriodicity.BranchManagementCustomer bmc6 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc6.productLine = 'AC';
        bmList.add(bmc6);
        bmList.add(bmc6);
        GetCustomerPeriodicity.BranchManagementCustomer bmc7 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmc7.productLine = 'TESTABC';
        bmList.add(bmc7);

        GetCustomerPeriodicity.BranchManagementCustomer bmc8 = new GetCustomerPeriodicity.BranchManagementCustomer();
        bmList.add(bmc8);
        bmList.add(bmc8);
        System.debug('before sorted:'+Json.serialize(bmList));
        bmList.sort();
        System.debug('after sorted:'+Json.serialize(bmList));
        System.assertEquals('TV',bmList[0].productLine);
        System.assertEquals('Refrigerator',bmList[1].productLine);
        System.assertEquals('Freezer',bmList[2].productLine);
        System.assertEquals('AC',bmList[3].productLine);
        System.assertEquals('AC',bmList[4].productLine);
        System.assertEquals('WM',bmList[5].productLine);
        System.assert(bmList[9].productLine==null);
    }
}