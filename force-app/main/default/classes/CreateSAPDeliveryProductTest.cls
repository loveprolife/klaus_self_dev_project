@isTest
private class CreateSAPDeliveryProductTest {
    static testMethod void testMethod1() {
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
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = accId;
        insert deliveryOrder;

        List<Delivery_Order_Item__c> deliveryOrderItemList = new List<Delivery_Order_Item__c>();
        Delivery_Order_Item__c deliveryOrderItem = new Delivery_Order_Item__c();
        deliveryOrderItem.SAP_Product_Line__c = mp1.Id;
        deliveryOrderItem.Product_Factory_Model__c = 'TestFactoryMode';
        deliveryOrderItem.SAP_Customer_Model_Product__c = 'TestCustomerModel';
        deliveryOrderItem.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItemList.add(deliveryOrderItem);

        Delivery_Order_Item__c deliveryOrderItem1 = new Delivery_Order_Item__c();
        deliveryOrderItem1.SAP_Product_Line__c = mp2.Id;
        deliveryOrderItem1.SAP_Product_Export_Model__c = 'TestExportModel';
        deliveryOrderItem1.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItemList.add(deliveryOrderItem1);

        Delivery_Order_Item__c deliveryOrderItem2 = new Delivery_Order_Item__c();
        deliveryOrderItem2.SAP_Product_Line__c = mp3.Id;
        deliveryOrderItem2.SAP_Product_Export_Model__c = 'TestExportModel10';
        deliveryOrderItem2.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItemList.add(deliveryOrderItem2);

        Delivery_Order_Item__c deliveryOrderItem3 = new Delivery_Order_Item__c();
        deliveryOrderItem3.SAP_Product_Line__c = mp4.Id;
        deliveryOrderItem3.SAP_Product_Export_Model__c = 'TestExportModel1';
        deliveryOrderItem3.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItemList.add(deliveryOrderItem3);

        Delivery_Order_Item__c deliveryOrderItem4 = new Delivery_Order_Item__c();
        deliveryOrderItem4.SAP_Product_Line__c = mp5.Id;
        deliveryOrderItem4.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem4.SAP_Product_Export_Model__c = 'TestExportModel2';
        deliveryOrderItemList.add(deliveryOrderItem4);

        Delivery_Order_Item__c deliveryOrderItem5 = new Delivery_Order_Item__c();
        deliveryOrderItem5.SAP_Product_Line__c = mp6.Id;
        deliveryOrderItem5.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem5.Product_Factory_Model__c = 'TestFactoryMode1';
        deliveryOrderItemList.add(deliveryOrderItem5);

        Delivery_Order_Item__c deliveryOrderItem6 = new Delivery_Order_Item__c();
        deliveryOrderItem6.SAP_Product_Line__c = mp7.Id;
        deliveryOrderItem6.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem6.Product_Factory_Model__c = 'TestFactoryMode2';
        deliveryOrderItemList.add(deliveryOrderItem6);

        Delivery_Order_Item__c deliveryOrderItem7 = new Delivery_Order_Item__c();
        deliveryOrderItem7.SAP_Product_Line__c = mp8.Id;
        deliveryOrderItem7.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem7.SAP_Product_Export_Model__c = 'TestExportModel3';
        deliveryOrderItemList.add(deliveryOrderItem7);

        Delivery_Order_Item__c deliveryOrderItem8 = new Delivery_Order_Item__c();
        deliveryOrderItem8.SAP_Product_Line__c = mp9.Id;
        deliveryOrderItem8.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem8.SAP_Product_Export_Model__c = 'TestExportModel4';
        deliveryOrderItemList.add(deliveryOrderItem8);

        Delivery_Order_Item__c deliveryOrderItem9 = new Delivery_Order_Item__c();
        deliveryOrderItem9.SAP_Product_Line__c = mp10.Id;
        deliveryOrderItem9.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem9.SAP_Product_Export_Model__c = 'TestExportModel5';
        deliveryOrderItemList.add(deliveryOrderItem9);

        Delivery_Order_Item__c deliveryOrderItem10 = new Delivery_Order_Item__c();
        deliveryOrderItem10.SAP_Product_Line__c = mp11.Id;
        deliveryOrderItem10.Delivery_Order__c = deliveryOrder.Id;
        deliveryOrderItem10.SAP_Product_Export_Model__c = 'TestExportModel6';
        deliveryOrderItemList.add(deliveryOrderItem10);

        insert deliveryOrderItemList;

        Test.startTest();
        Database.executeBatch(new CreateSAPDeliveryProduct(),200);
        Test.stopTest();

    }
}