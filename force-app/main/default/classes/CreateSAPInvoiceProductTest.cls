@isTest
private class CreateSAPInvoiceProductTest {
    static testMethod void testMethod1() {
        Test.startTest();

        List<Mapping__c> mpList = new List<Mapping__c>();
        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp1);

        Mapping__c mp2 = new Mapping__c();
        mp2.Name = '62';
        mp2.Mapping_Code__c = 'Refrigerator';
        mp2.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp2);

        Mapping__c mp3 = new Mapping__c();
        mp3.Name = '6A';
        mp3.Mapping_Code__c = 'Cooking';
        mp3.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp3);

        Mapping__c mp4 = new Mapping__c();
        mp4.Name = '1';
        mp4.Mapping_Code__c = 'Freezer';
        mp4.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp4);

        Mapping__c mp5 = new Mapping__c();
        mp5.Name = '2';
        mp5.Mapping_Code__c = 'WM';
        mp5.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp5);

        Mapping__c mp6 = new Mapping__c();
        mp6.Name = '3';
        mp6.Mapping_Code__c = 'Laser TV';
        mp6.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp6);

        Mapping__c mp7 = new Mapping__c();
        mp7.Name = '4';
        mp7.Mapping_Code__c = 'Mobile';
        mp7.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp7);

        Mapping__c mp8 = new Mapping__c();
        mp8.Name = '5';
        mp8.Mapping_Code__c = 'AC';
        mp8.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp8);

        Mapping__c mp9= new Mapping__c();
        mp9.Name = '5';
        mp9.Mapping_Code__c = 'LCAC';
        mp9.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp9);

        Mapping__c mp10= new Mapping__c();
        mp10.Name = '6';
        mp10.Mapping_Code__c = 'Small Domestic Home Appliances';
        mp10.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp10);

        Mapping__c mp11= new Mapping__c();
        mp11.Name = '7';
        mp11.Mapping_Code__c = 'Dishwasher';
        mp11.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        mpList.add(mp11);

        insert mpList;

        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
    	customerProductLine.Product_Line_Name__c = 'TV';
    	customerProductLine.Customer__c = accId;
    	customerProductLine.Management_Customer__c = accId;
    	customerProductLine.Classification__c = 'Customer of Oversea Company';
    	customerProductLine.Development_Stage__c = 'Undeveloped';
    	customerProductLine.Prospective_Rank__c = 'Normal Customer';
    	Database.insert(customerProductLine);
    	Order__c order = new Order__c();
    	order.Customer__c = accId;
    	Database.insert(order);
    	Order_Product__c orderProduct = new Order_Product__c();
    	orderProduct.Order__c = order.Id;
    	Database.insert(orderProduct);

        
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c = accId;
        insert invoice;

        List<Invoice_Item__c> invoiceItemList = new List<Invoice_Item__c>();
        Invoice_Item__c invoiceItem = new Invoice_Item__c();
        invoiceItem.Invoice__c = invoice.Id;
        invoiceItem.SAP_Customer_Model_Product__c = 'TestCustomerModel';
        invoiceItem.Product_Factory_Model__c = 'TestFactoryModel';
        invoiceItem.SAP_Product_Line__c = mp1.Id;
        invoiceItem.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem);

        Invoice_Item__c invoiceItem1 = new Invoice_Item__c();
        invoiceItem1.Invoice__c = invoice.Id;
        invoiceItem1.SAP_Product_Export_Model__c = 'TestExpotModel';
        invoiceItem1.SAP_Product_Line__c = mp2.Id;
        invoiceItem1.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem1);

        Invoice_Item__c invoiceItem2 = new Invoice_Item__c();
        invoiceItem2.Invoice__c = invoice.Id;
        invoiceItem2.SAP_Product_Export_Model__c = 'TestExpotModel1';
        invoiceItem2.SAP_Product_Line__c = mp3.Id;
        invoiceItem2.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem2);

        Invoice_Item__c invoiceItem3 = new Invoice_Item__c();
        invoiceItem3.Invoice__c = invoice.Id;
        invoiceItem3.SAP_Product_Export_Model__c = 'TestExportModel2';
        invoiceItem3.SAP_Product_Line__c = mp4.Id;
        invoiceItem3.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem3);

        Invoice_Item__c invoiceItem4 = new Invoice_Item__c();
        invoiceItem4.Invoice__c = invoice.Id;
        invoiceItem4.SAP_Product_Export_Model__c = 'TestExportModel3';
        invoiceItem4.SAP_Product_Line__c = mp5.Id;
        invoiceItem4.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem4);

        Invoice_Item__c invoiceItem5 = new Invoice_Item__c();
        invoiceItem5.Invoice__c = invoice.Id;
        invoiceItem5.SAP_Product_Line__c = mp6.Id;
        invoiceItem5.Product_Factory_Model__c = 'TestFactoryModel1';
        invoiceItem5.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem5);

        Invoice_Item__c invoiceItem6 = new Invoice_Item__c();
        invoiceItem6.Invoice__c = invoice.Id;
        invoiceItem6.SAP_Product_Line__c = mp7.Id;
        invoiceItem6.Product_Factory_Model__c = 'TestFactoryModel2';
        invoiceItem6.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem6);

        Invoice_Item__c invoiceItem7 = new Invoice_Item__c();
        invoiceItem7.Invoice__c = invoice.Id;
        invoiceItem7.SAP_Product_Line__c = mp8.Id;
        invoiceItem7.SAP_Product_Export_Model__c = 'TestExportModel4';
        invoiceItem7.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem7);

        Invoice_Item__c invoiceItem8 = new Invoice_Item__c();
        invoiceItem8.Invoice__c = invoice.Id;
        invoiceItem8.SAP_Product_Line__c = mp9.Id;
        invoiceItem8.SAP_Product_Export_Model__c = 'TestExportModel5';
        invoiceItem8.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem8);
        
        Invoice_Item__c invoiceItem9 = new Invoice_Item__c();
        invoiceItem9.Invoice__c = invoice.Id;
        invoiceItem9.SAP_Product_Line__c = mp10.Id;
        invoiceItem9.SAP_Product_Export_Model__c = 'TestExportModel6';
        invoiceItem9.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem9);

        Invoice_Item__c invoiceItem10 = new Invoice_Item__c();
        invoiceItem10.Invoice__c = invoice.Id;
        invoiceItem10.SAP_Product_Line__c = mp11.Id;
        invoiceItem10.SAP_Product_Export_Model__c = 'TestExportModel7';
        invoiceItem10.Sales_Order_Item__c = orderProduct.id;
        invoiceItemList.add(invoiceItem10);

        insert invoiceItemList;       

        
        Database.executeBatch(new CreateSAPInvoiceProduct(),200);
        Test.stopTest();
    }
}