@isTest
public class PositionCreateServiceTest{
    private static Gridding__c gird6;
    private static Gridding__c gird5;
    private static List<Map<String, Object>> gridData;
    private static void makeData(){
        Gridding__c gird = new Gridding__c();
        gird.Name = 'test001';
        gird.Gridding_Level__c = 'A';
        gird.Gridding_Code__c  = 'J01';
        //gird.Parent_Gridding__c = gird.Id; 
        INSERT gird;
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        gird1.Parent_Gridding__c = gird.Id;
        INSERT gird1;
        Gridding__c gird2 = new Gridding__c();
        gird2.Name = 'test003';
        gird2.Gridding_Level__c = 'C';
        gird2.Gridding_Code__c  = 'J01-J001-J0001';
        gird2.Parent_Gridding__c = gird1.Id;
        INSERT gird2;
        Gridding__c gird3 = new Gridding__c();
        gird3.Name = 'test004';
        gird3.Gridding_Level__c = 'C';
        gird3.Gridding_Code__c  = 'J01-J001-J0001-J00001';
        gird3.Parent_Gridding__c = gird2.Id;
        INSERT gird3;
        Gridding__c gird4= new Gridding__c();
        gird4.Name = 'test005';
        gird4.Gridding_Level__c = 'C';
        gird4.Gridding_Code__c  = 'J01-J001-J0001-J00001-J000001';
        gird4.Parent_Gridding__c = gird3.Id;
        INSERT gird4;
        gird5 = new Gridding__c();
        gird5.Name = 'test006';
        gird5.Gridding_Level__c = 'C';
        gird5.Gridding_Code__c  = 'J01-J001-J0001-J00001-J000001-J0000001';
        gird5.Parent_Gridding__c = gird4.Id;
        INSERT gird5;
        gird6 = new Gridding__c();
        gird6.Name = 'test007';
        gird6.Gridding_Level__c = 'C';
        gird6.Gridding_Code__c  = 'J01-J001-J0001-J00001-J000001-J0000001-J00000001';
        gird6.Parent_Gridding__c = gird5.Id;
        INSERT gird6;
        List<Gridding__c> getGridList = new List<Gridding__c>();
        getGridList.add(gird);
        getGridList.add(gird1);
        getGridList.add(gird2);
        getGridList.add(gird3);
        getGridList.add(gird4);
        getGridList.add(gird5);
        getGridList.add(gird6);
        Map<String, List<Gridding__c>> griddingListMap = new Map<String, List<Gridding__c>>();
        griddingListMap.put(gird2.Id,getGridList);
        griddingListMap.put(gird1.Id,getGridList);
        griddingListMap.put(gird.Id,getGridList);
        griddingListMap.put(gird3.Id,getGridList);
        griddingListMap.put(gird4.Id,getGridList);
        griddingListMap.put(gird5.Id,getGridList);
        griddingListMap.put(gird6.Id,getGridList);

        Map<String, Object> gmap = new Map<String, Object>();
        gmap.put('_children',getGridList);
        gmap.put(gird1.Id,getGridList);
        gmap.put(gird.Id,getGridList);
        gmap.put(gird3.Id,getGridList);
        gmap.put(gird4.Id,getGridList);
        gmap.put(gird5.Id,getGridList);
        gmap.put(gird6.Id,getGridList);
        gridData = new List<Map<String, Object>> ();
        gridData.add(gmap);
    }

    // @IsTest
    // static void createGridDataTest(){
    //     makeData();
    //     Test.startTest();
    //     PositionCreateService.createGridData(gird6.Id);
    //     Test.stopTest();
        
    // }
    @IsTest
    static void asyncLoadBomNodeTest(){
        makeData();
        Test.startTest();
        PositionCreateService.asyncLoadBomNode(gird5.Id);
        Test.stopTest();
        
    }

    @IsTest
    static void initCurrentDataItemsTest(){
        makeData();
        PositionCreateController.ProductLine pp = new PositionCreateController.ProductLine();
        pp.label = '1';
        pp.value = 'test';
        pp.isTrue = true;
        pp.isDisable = true;
        List<PositionCreateController.ProductLine> productLineList = new List<PositionCreateController.ProductLine>();
        productLineList.add(pp);
        Map<String, String> productLineMap = new Map<String, String>();

        Position__c pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        INSERT pos;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird6.id;
        shop.City__c = '北京市';
        INSERT shop;

        Position_Permissions__c position = new Position_Permissions__c();
        position.Account__c = acc.Id;
        position.Position__c = pos.Id;
        position.Gridding__c = gird6.Id;
        position.Shop__c = shop.Id;
        position.Product_Line__c = 'Mobile';
        INSERT position;

        List<String> noIncludingGridIdList = new List<String> ();
        noIncludingGridIdList.add(gird6.Id);

        Test.startTest();
        PositionCreateService.initCurrentDataItems(pos.Id,productLineList,productLineMap);
        PositionCreateService.getSearchShopList(shop.Name,acc.Name,gird6.Name,noIncludingGridIdList);
        PositionCreateService.getCurrentGriddingMap(noIncludingGridIdList,pos.Id);
        PositionCreateService.getPositionPermissionFromAccount(acc.Id,pos.Id);
        PositionCreateService.getNewGridding(pos.Id);
        Test.stopTest();
        
    }

    // @IsTest
    // static void ParsingChooseGriddingTest(){
    //     makeData();
    //     Test.startTest();
    //     PositionCreateService.ParsingChooseGridding(gridData,gird6.Id);
    //     Test.stopTest();
        
    // }


}