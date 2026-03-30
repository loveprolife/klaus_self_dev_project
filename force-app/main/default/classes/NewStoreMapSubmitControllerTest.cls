@isTest
public class NewStoreMapSubmitControllerTest {
    // 查询当前用户信息
    public static User user = [SELECT Id,Name,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()][0];

    @isTest
    static void test1(){

        String currentLatStr = '86.587556';
        String currentLongStr = '29.567932';
        String userId = UserInfo.getUserId();

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
        shop1.Sales_Region__c = user.Sales_Region__c;
        Insert shop1;

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.id;
        shop2.Shop_Level__c = 'B';
        shop2.Name = '雪碧店';
        shop2.City__c = '青岛市';
        shop2.Shop_Center_Location__Latitude__s = 49.4545;
        shop2.Shop_Center_Location__Longitude__s = 106.509;
        shop2.Sales_Region__c = user.Sales_Region__c;
        Insert shop2;

        SubUser__c subUser = new SubUser__c();
        subUser.ParentUser__c = userId;
        subUser.IsActive__c = true;
        Insert subUser;

        SubStore__c subStore1 = new SubStore__c();
        subStore1.StoreID__c = shop1.Id;
        subStore1.SubUserID__c = subUser.Id;
        Insert subStore1;

        SubStore__c subStore2 = new SubStore__c();
        subStore2.StoreID__c = shop2.Id;
        subStore2.SubUserID__c = subUser.Id;
        Insert subStore2;

        SubUser_Device__c subDevice = new SubUser_Device__c();
        subDevice.SubUserID__c = subUser.Id;
        subDevice.IsActive__c = true;
        subDevice.LastUsedTime__c = System.now();
        subDevice.DeviceID__c = '001';
        Insert subDevice;

        SubUserLog__c subUserLog = new SubUserLog__c();
        subUserLog.SubUser__c = subUser.Id;
        subUserLog.StoreId__c = shop1.Id;
        subUserLog.Action_Time__c = System.now();
        subUserLog.DeviceID__c = subDevice.Id;
        Insert subUserLog;

        NewStoreMapSubmitController.getInit(subUser.Id,'001');
        NewStoreMapSubmitController.getInit('','001');
        NewStoreMapSubmitController.getInit('','002');

        NewStoreMapSubmitController.actionRecord(subUser.Id,shop1.Id,'Submit','001');
        NewStoreMapSubmitController.actionRecord(subUser.Id,shop1.Id,'Submit','002');

    }
}