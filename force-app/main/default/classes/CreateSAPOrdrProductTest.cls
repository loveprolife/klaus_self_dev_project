@isTest
private class CreateSAPOrdrProductTest {
		
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Order__c order = new Order__c();
        order.Customer__c = accId;
        Database.insert(order);

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
    	List<Order_Product__c> orderProductList = new List<Order_Product__c>();
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.SAP_Product_Customer_Model__c = 'TestCustomerModel';
        orderProduct.SAP_Product_Export_Model__c = 'TestExprotModel';
        orderProduct.SAP_Product_Line__c = mp2.Id;
        orderProductList.add(orderProduct);

        Order_Product__c orderProduct1 = new Order_Product__c();
        orderProduct1.Order__c = order.Id;
        orderProduct1.Product_Factory_Model__c = 'TestFactoryModel';
        orderProduct1.SAP_Product_Line__c = mp1.Id;
        orderProductList.add(orderProduct1);

        Order_Product__c orderProduct2 = new Order_Product__c();
        orderProduct2.Order__c = order.Id;
        orderProduct2.SAP_Product_Export_Model__c = 'TestExprotModel1';
        orderProduct2.SAP_Product_Line__c = mp3.Id;
        orderProductList.add(orderProduct2);

        Order_Product__c orderProduct3 = new Order_Product__c();
        orderProduct3.Order__c = order.Id;
        orderProduct3.SAP_Product_Export_Model__c = 'TestExprotModel2';
        orderProduct3.SAP_Product_Line__c = mp4.Id;
        orderProductList.add(orderProduct3);

        Order_Product__c orderProduct4 = new Order_Product__c();
        orderProduct4.Order__c = order.Id;
        orderProduct4.SAP_Product_Export_Model__c = 'TestExprotModel9';
        orderProduct4.SAP_Product_Line__c = mp5.Id;
        orderProductList.add(orderProduct4);

        Order_Product__c orderProduct5 = new Order_Product__c();
        orderProduct5.Order__c = order.Id;
        orderProduct5.Product_Factory_Model__c = 'TestFactoryModel1';
        orderProduct5.SAP_Product_Line__c = mp6.Id;
        orderProductList.add(orderProduct5);

        Order_Product__c orderProduct6 = new Order_Product__c();
        orderProduct6.Order__c = order.Id;
        orderProduct6.Product_Factory_Model__c = 'TestFactoryModel2';
        orderProduct6.SAP_Product_Line__c = mp7.Id;
        orderProductList.add(orderProduct6);

        Order_Product__c orderProduct7 = new Order_Product__c();
        orderProduct7.Order__c = order.Id;
        orderProduct7.SAP_Product_Export_Model__c = 'TestExprotModel3';
        orderProduct7.SAP_Product_Line__c = mp8.Id;
        orderProductList.add(orderProduct7);

        Order_Product__c orderProduct8 = new Order_Product__c();
        orderProduct8.Order__c = order.Id;
        orderProduct8.SAP_Product_Export_Model__c = 'TestExprotModel4';
        orderProduct8.SAP_Product_Line__c = mp9.Id;
        orderProductList.add(orderProduct8);

        Order_Product__c orderProduct9 = new Order_Product__c();
        orderProduct9.Order__c = order.Id;
        orderProduct9.SAP_Product_Export_Model__c = 'TestExprotModel5';
        orderProduct9.SAP_Product_Line__c = mp10.Id;
        orderProductList.add(orderProduct9);

        Order_Product__c orderProduct10 = new Order_Product__c();
        orderProduct10.Order__c = order.Id;
        orderProduct10.SAP_Product_Export_Model__c = 'TestExprotModel6';
        orderProduct10.SAP_Product_Line__c = mp11.Id;
        orderProductList.add(orderProduct10);

        Database.insert(orderProductList);
        Test.startTest();
        Database.executeBatch(new CreateSAPOrderProduct(),200);
        Test.stopTest();
    }
}