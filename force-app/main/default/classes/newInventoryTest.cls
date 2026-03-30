@isTest
public class newInventoryTest {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @isTest
    static void testMethod1(){

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = currentUser.Sales_Region__c;
        Insert shop1;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = currentUser.Id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2024';
        ispTest.Inspection_Month__c = '9';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Inspection_Product_Item__c testDIRItem = new Inspection_Product_Item__c();
        testDIRItem.Inspection_Report__c = testDIR.Id;
        testDIRItem.Product_Line__c = 'TV';
        testDIRItem.Status__c = 'Start';
        Insert testDIRItem;

        Inspection_Product_Item__c testDIRItem2 = new Inspection_Product_Item__c();
        testDIRItem2.Inspection_Report__c = testDIR.Id;
        testDIRItem2.Product_Line__c = 'Refrigerator';
        testDIRItem2.Status__c = 'Start';
        Insert testDIRItem2;

        // Inspection_Product_Item__c testDIRItem3 = new Inspection_Product_Item__c();
        // testDIRItem3.Inspection_Report__c = testDIR.Id;
        // testDIRItem3.Product_Line__c = 'Sound Bar';
        // testDIRItem3.Status__c = 'Start';
        // Insert testDIRItem3;

        Inventory__c inventory = new Inventory__c();
        inventory.Inspection_Product_Item__c = testDIRItem.id;
        inventory.BoxesFloor__c = 'Yes';
        inventory.InventoryTodayVisit__c = 'Yes';
        inventory.Product__c = 'a0z0o00000E1zNoAAJ';
        // inventory.Product__c = 'a0z9D000002Lbz0QAC';
        Insert inventory;

        Inventory_Barcode__c floorBox = new Inventory_Barcode__c();
        floorBox.Inventory__c = inventory.id;
        floorBox.Status__c = 'FloorBox';
        Insert floorBox;

        Inventory_Barcode__c addBoxed = new Inventory_Barcode__c();
        addBoxed.Inventory__c = inventory.id;
        addBoxed.Status__c = 'AddBoxed';
        Insert addBoxed;

        Inventory_Barcode__c floorBox2 = new Inventory_Barcode__c();
        floorBox2.Inventory__c = inventory.id;
        floorBox2.Status__c = 'FloorBox';

        Inventory_Barcode__c addBoxed2 = new Inventory_Barcode__c();
        addBoxed2.Inventory__c = inventory.id;
        addBoxed2.Status__c = 'AddBoxed';

        Inventory_Barcode__c floorBoxDel = new Inventory_Barcode__c();
        floorBoxDel.Inventory__c = inventory.id;
        floorBoxDel.Status__c = 'FloorBox';
        Insert floorBoxDel;

        Inventory_Barcode__c addBoxedDel = new Inventory_Barcode__c();
        addBoxedDel.Inventory__c = inventory.id;
        addBoxedDel.Status__c = 'AddBoxed';
        Insert addBoxedDel;

        String inventoryInfoJson = JSON.serialize(inventory);
        List<Inventory_Barcode__c> floorBoxList = new List<Inventory_Barcode__c>();
        floorBoxList.add(floorBox);
        floorBoxList.add(floorBox2);
        String barcodeFloorBoxJson = JSON.serialize(floorBoxList);
        List<Inventory_Barcode__c> addBoxedList = new List<Inventory_Barcode__c>();
        addBoxedList.add(addBoxed);
        addBoxedList.add(addBoxed2);
        String barcodeAddBoxedJson = JSON.serialize(addBoxedList);
        List<Inventory_Barcode__c> floorBoxDelList = new List<Inventory_Barcode__c>();
        floorBoxDelList.add(floorBoxDel);
        String barcodeFloorBoxDelJson = JSON.serialize(floorBoxDelList);
        List<Inventory_Barcode__c> addBoxedDelList = new List<Inventory_Barcode__c>();
        addBoxedDelList.add(addBoxedDel);
        String barcodeAddBoxedDelJson = JSON.serialize(addBoxedDelList);

        test.startTest();

        newInventory.getInventory(testDIRItem.id);
        // newInventory.getInventory(testDIRItem2.id);

        newInventory.saveInventory(inventoryInfoJson, barcodeFloorBoxJson, barcodeAddBoxedJson, barcodeFloorBoxDelJson, barcodeAddBoxedDelJson);

        newInventory.getInventoryCheckNumber(testDIRItem.id);

        test.stopTest();
    }
}