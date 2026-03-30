@isTest
private class GetSalesPeriodicityTest {

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

        List<Sales__c> saleses = new List<Sales__c>();
        for(Integer i=0;i<n;i++){
            Sales__c sales = new Sales__c(
                Product_Line__c = 'TV',
                Customer__c = accs.get(i).Id
            );
            saleses.add(sales);
        }
        insert saleses;
    }

    @isTest
    static void testDoPost() {
        init();
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI =  GetSalesPeriodicityTest.url;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;

        req.requestBody = Blob.valueOf('');
        GetSalesPeriodicity.doPost();
        String resbody = res.responseBody.toString();
        GetSalesPeriodicity.SFOutputResult rvo = (GetSalesPeriodicity.SFOutputResult)JSON.deserialize(resbody,
            GetSalesPeriodicity.SFOutputResult.class);
        System.assertEquals(false, rvo.IsSuccess);

        GetSalesPeriodicity.SFInput vo = new GetSalesPeriodicity.SFInput();
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetSalesPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetSalesPeriodicity.SFOutputResult)JSON.deserialize(resbody,
            GetSalesPeriodicity.SFOutputResult.class);
        System.assertEquals(false, rvo.IsSuccess);

        vo.salesRegion = 'China';
        vo.productLine = 'TV';
        vo.startDate = System.today().format();
        vo.endDate = System.today().addDays(2).format();
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetSalesPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetSalesPeriodicity.SFOutputResult)JSON.deserialize(resbody,GetSalesPeriodicity.SFOutputResult.class);
        System.assertEquals(true, rvo.IsSuccess);

        vo.salesRegion = 'TEST';
        vo.productLine = 'Freezer';
        req.requestBody = Blob.valueOf(JSON.serialize(vo));
        GetSalesPeriodicity.doPost();
        resbody = res.responseBody.toString();
        rvo = (GetSalesPeriodicity.SFOutputResult)JSON.deserialize(resbody,GetSalesPeriodicity.SFOutputResult.class);
        System.assertEquals(true, rvo.IsSuccess);
        Test.stopTest();
    }

    @isTest
    static void testValidateInput() {
        
        Test.startTest();
        GetSalesPeriodicity.SFInput vo = new GetSalesPeriodicity.SFInput();
        GetSalesPeriodicity.SFOutputResult re = GetSalesPeriodicity.validateInput(vo);
        System.assertEquals(false, re.IsSuccess);

        re = GetSalesPeriodicity.validateInput(null);
        System.assertEquals(false, re.IsSuccess);

        vo.salesRegion = 'test';
        vo.startDate = '2019-09-09';
        vo.endDate = '2019-09-01';
        re = GetSalesPeriodicity.validateInput(vo);
        System.assertEquals(false, re.IsSuccess);
        Test.stopTest();
    }
}