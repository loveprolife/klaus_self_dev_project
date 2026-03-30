/**************************************************************************************************
 * ProductSearchInventoryController
 * Purpose:处理查询库存页面逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-03-38
***************************************************************************************************/
global  without sharing class ProductSearchInventoryController{

    // 马来Profiles
    public static List<String> profiles = Label.Inventory_MY_Profiles.split(',');
    // 马来个别用户
    public static List<String> userNameList = Label.Inventory_MY_Username.split(',');
    // 马来权限库存
    public static List<String> inventoryNameList = Label.Inventory_MY_Inventoryname.split(',');

    public static User currentUser = [SELECT Id,Profile.Name,Country__c,Username FROM User WHERE Id =:UserInfo.getUserId()];

    public class ReturnResult{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }
    public Class InitDataWarp{
        public List<Hisense_Entity_Relation__c> hEntityRelationList;
        public List<PickList__c> storageLocationList;
    }
    @AuraEnabled 
    //初始化数据
    public static String initData(){
        InitDataWarp initData = new InitDataWarp();        
        initData.hEntityRelationList = new List<Hisense_Entity_Relation__c>();
        initData.storageLocationList = new List<PickList__c>();
    	if(String.isNotBlank(currentUser.Country__c)){
            initData.hEntityRelationList = [SELECT Id,Name,Hisense_Entity__c,Hisense_Entity_Code__c FROM Hisense_Entity_Relation__c
                                   WHERE Country__c =:currentUser.Country__c];
            if(initData.hEntityRelationList.size() > 0 ){
                Set<String> hEntityCodeSet = new Set<String>();
                for(Hisense_Entity_Relation__c hEntityRelation : initData.hEntityRelationList){
                    hEntityCodeSet.add(hEntityRelation.Hisense_Entity_Code__c);
                }
                initData.storageLocationList = getStorageLocationList(hEntityCodeSet);
            }
    	}
    	return JSON.serialize(initData);
    }
    @AuraEnabled 
    //根据产品型号以及海信主体代码查询可用库存
    public static String getProductInventory(String productName, String hEnitityCode, String storageLocation){
        List<String> storageLocationList = new List<String>();
        if(String.isBlank(storageLocation)){
            // 马来特殊处理
            if(profiles.contains(currentUser.Profile.Name) && !userNameList.contains(currentUser.Username)){
                storageLocationList = inventoryNameList;
            }else {
                Set<String> hEntityCode = new Set<String>();
                for(Hisense_Entity_Relation__c hEntityRelation : [SELECT Id,Name,Hisense_Entity__c,Hisense_Entity_Code__c FROM Hisense_Entity_Relation__c
                    WHERE Country__c =:currentUser.Country__c]){
                    hEntityCode.add(hEntityRelation.Hisense_Entity_Code__c);
                }
                List<PickList__c> lists = getStorageLocationList(hEntityCode);
                for(PickList__c pl : lists){
                    storageLocationList.add(pl.name);
                }
                // storageLocationList.add('ALL');
            }
           
        }else{
            storageLocationList = storageLocation.split(',');
        }
        GetProductStockInfoFromSAP.ProductStockInfoInput responseData = GetProductStockInfoFromSAP.getData(productName,hEnitityCode,storageLocationList);
        System.debug('responseData: ' +responseData);
        return JSON.serialize(responseData);
    }
    //@AuraEnabled 
    //根据销售组织查询可选库位
    public static List<PickList__c> getStorageLocationList(Set<String> hEntityCodeSet){
        List<PickList__c> pickList = [SELECT Id,Name,Label__c,Value__c,belong_to_he__c FROM PickList__c 
                WHERE RecordType.DeveloperName = 'Master_Storage_Location' AND belong_to_he__c IN:hEntityCodeSet];
        List<PickList__c> pickListResult = new List<PickList__c>();
        for (PickList__c pick : pickList) {
            if(!profiles.contains(currentUser.Profile.Name) || checkInventoryName(pick.NAME) || userNameList.contains(currentUser.Username)){
                pickListResult.add(pick);
            }
        }
        return pickListResult;
        // return [SELECT Id,Name,Label__c,Value__c,belong_to_he__c FROM PickList__c 
        //         WHERE RecordType.DeveloperName = 'Master_Storage_Location' AND belong_to_he__c IN:hEntityCodeSet];
    }

    // 当前值是否包含label配置的InventoryName 
    public static Boolean checkInventoryName(String name){
        Boolean flag = false;
        for (String inventoryName : inventoryNameList) {
            if(name.contains(inventoryName)){
                flag = true;
            }
        }
        return flag;
    }


}