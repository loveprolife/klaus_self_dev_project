@isTest
private class PositionCreateControllerTest {
    static testMethod void testController() {
        String recordId = 'a230T0000005hmGQAQ';

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

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop = new Shop__c();
        shop.Name = 'testName';
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;

        Position__c pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        INSERT pos;

        Position_Permissions__c position = new Position_Permissions__c();
        position.Account__c = acc.Id;
        position.Position__c = pos.Id;
        position.Gridding__c = gird1.Id;
        position.Product_Line__c = 'Mobile';
        INSERT position;

        PositionCreateController.ProductLine pp = new PositionCreateController.ProductLine();
        pp.label = '1';
        pp.value = 'test';
        pp.isTrue = false;
        pp.isDisable = true;
        pp.accProductLineKey = acc.Id + '_' + position.Product_Line__c;
        List<PositionCreateController.ProductLine> productLineList = new List<PositionCreateController.ProductLine>();
        productLineList.add(pp);

        PositionCreateController.AccProductLine accProductLine = new PositionCreateController.AccProductLine();
        accProductLine.accId = acc.Id;
        accProductLine.productLineList = productLineList;
        List<PositionCreateController.AccProductLine> aplList = new List<PositionCreateController.AccProductLine>();
        aplList.add(accProductLine);

        String objStr =JSON.serialize(aplList);
        Map<String, String> shopSearchMap  = new Map<String, String>();
        shopSearchMap.put('shopName', shop.Name);
        shopSearchMap.put('accountName', acc.Name);
        shopSearchMap.put('griddingName', gird1.Name);
        

        List<String> noIncludingGridIdList = new List<String> ();
        noIncludingGridIdList.add(gird1.Id);

        PositionCreateController.shopWrapper shopWrapper = new PositionCreateController.shopWrapper();
        shopWrapper.accountName = acc.Name;
        shopWrapper.griddingName = gird1.Name;
        shopWrapper.positionPermissionId = position.Id;
        shopWrapper.shopExternalKeyID = shop.Id;
        shopWrapper.shopName = shop.Name;

        List<PositionCreateController.shopWrapper>  shopSearchList = new List<PositionCreateController.shopWrapper>();
        shopSearchList.add(shopWrapper);
        String shopSearchListJSON = JSON.serialize(shopSearchList);
        String shopListJSON = JSON.serialize(shopSearchList);

        PositionCreateController.shopGriddingWrapper shopGriddingWrapper = new PositionCreateController.shopGriddingWrapper();
        shopGriddingWrapper.name = 'test';
        shopGriddingWrapper.recordId = gird.Id;
        shopGriddingWrapper.parentId = gird.Id;
        shopGriddingWrapper.griExternalId = gird.Id;
        List<PositionCreateController.shopGriddingWrapper> posList = new List<PositionCreateController.shopGriddingWrapper>();
        posList.add(shopGriddingWrapper);
        String currentgridNewColumnsJson = JSON.serialize(posList);
        

        Test.startTest();
        PositionCreateController.initGridding(recordId);
        PositionCreateController.addNewRow(objStr);
        PositionCreateController.changeAccoutFunction(acc.Id,objStr,recordId);
        PositionCreateController.checkProductLine(true,pp.accProductLineKey,aplList,pos.Id);
        PositionCreateController.checkProductLine(false,pp.accProductLineKey,aplList,pos.Id);
        PositionCreateController.deleteRowLine(acc.Id,pos.Id);
        PositionCreateController.searchActionFunction(shopSearchMap,noIncludingGridIdList);
        PositionCreateController.chooseShopFunction(shop.Id, pos.Id, shopSearchListJSON, shopListJSON);
        PositionCreateController.unChooseShopFunction(shop.Id, pos.Id, shopSearchListJSON, shopListJSON, shopSearchMap);
        PositionCreateController.openOrCloseGridding(currentgridNewColumnsJson, gird.Id, 'utility:chevrondown', 'currentName');
        PositionCreateController.openOrCloseGridding(currentgridNewColumnsJson, gird.Id, 'utility:chevronright', 'currentName');
        
        PositionCreateController.checkGriddingFunction(currentgridNewColumnsJSON, true, gird.Id, pos.Id);
        PositionCreateController.checkGriddingFunction(currentgridNewColumnsJSON, false, gird.Id, pos.Id);
        //PositionCreateController.hiddenNextGridding(gird.Id,posList);
        Test.stopTest();
    }

}