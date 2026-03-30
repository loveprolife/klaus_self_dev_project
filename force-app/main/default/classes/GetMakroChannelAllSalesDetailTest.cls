@isTest
private class GetMakroChannelAllSalesDetailTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	
        String json = '{"DATA": [{"site": "Crown Mines","group_": "GF","group_name": "Home Appliances","article": "461570","article_name": "HISENSE 18KG T/LOADER W/MACHINE T/GREY","vendor_article_numbe": "WT5T1825DT","act_sales": 9564.35,"ly_sales": null,"ly_sales_var": null,"act_sales_qty_su": 1,"ly_sales_qty_su": null,"ly_sales_qty_su_var": null,"soh_cost": 46256,"soh_qty_bu": 7,"week": "9","loaddt": "2024-03-04T15:31:22Z","datatime": "26.02.2024to03.03.2024","load_dt": "2024-05-08T04:03:03Z"}]}';

        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetMakroChannelAllSalesDetail.getAll();
        Test.stopTest();
    }
}