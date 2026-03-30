@isTest(SeeAllData=true)
public class EventControllerTest{
    static testMethod void testMethod1(){
        Account acc = new Account();
        acc.Name = 'KS';
        insert acc;
        Product__c pro = new Product__c();
        pro.Name = 'NTC-22E';
        pro.CurrencyIsoCode = 'USD';
        pro.Sales_Region__c = 'Hisense USA';
        pro.Product_Line__c = 'TV';
        pro.Guiding_Price__c = 11;
        pro.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        insert pro;

        Product__c pro1 = new Product__c();
        pro1.Name = 'NTC-33E';
        pro1.CurrencyIsoCode = 'USD';
        pro1.Sales_Region__c = 'Hisense USA';
        pro1.Product_Line__c = 'Accessories';
        pro1.Guiding_Price__c = 22;
        pro1.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        insert pro1;

        Events__c ev = new Events__c();
        ev.Sales_Region__c = 'Hisense USA';
        ev.Subject__c = 'aaa';
        ev.Start_Date__c = Date.today();
        ev.End_Date__c = Date.today();
        ev.GST__c = 10;
        ev.Company_Information__c = 'aaaa';
        insert ev;

        Event_Receipt__c er = new Event_Receipt__c();
        er.Event_Subject__c = ev.Id;
        er.Customer_Name__c = 'aaaa';
        er.Address__c = 'AAA';
        er.Mobile_Number__c = '18888888888';
        insert er;

        String eventReceiptJson = '{"Id":"' + er.Id + '","Sales_Region__c":"Hisense USA","CurrencyIsoCode":"CNY"}';
        String eventSalesJson = '{"Product__c":"' + pro.Id + '","Unit_Price__c":"2.00","Quantity__c":"2","Discount__c":"1","Warranty_period_increase__c":"1","Warranty_price_increase__c":10}';
        String eventSalesAccessoriesJson = '{"Accessories__c":"' + pro1.Id + '","Unit_Price__c":"2.00","Quantity__c":"11"}';
        Boolean isShowWarranty = true;
        Boolean isShowAccessories = true;

        String type = 'Product';
        String type1 = 'Discount';

        Test.startTest();

        EventSalesController.searchEventReceipt(er.Id);
        EventSalesController.searchProductInfo(pro.Id, 'USD');
        EventSalesController.saveEventSalesDetail(eventReceiptJson, eventSalesJson, eventSalesAccessoriesJson, isShowWarranty, isShowAccessories, type);
        EventSalesController.saveEventSalesDetail(eventReceiptJson, eventSalesJson, eventSalesAccessoriesJson, isShowWarranty, isShowAccessories, type1);

        EventSalesController.generatePDF(er.Id);

        ApexPages.currentPage().getParameters().put('ID', er.Id);
        EventReceiptPrintPDFController pdf = new EventReceiptPrintPDFController();

        PageReference pdfPage = Page.EventReceiptPDFPage; // 确保 "MyPdfPage" 存在
        pdfPage.getParameters().put('ID', er.Id);
        Test.setCurrentPage(pdfPage);

        EventReceiptPrintPDFController.downloadFile(er.Id);

        Test.stopTest();
    }

}