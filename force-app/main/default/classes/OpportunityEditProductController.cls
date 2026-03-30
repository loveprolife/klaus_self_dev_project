/**************************************************************************************************
 * Name:OpportunityEditProductController
 * Purpose:选择业务机会产品
 * Author: Deloitte Johnson
 * Create Date: 2019-03-11
***************************************************************************************************/
global  without sharing class OpportunityEditProductController{
	public Class InitDataWarp{
        public Opportunity__c thisOpp;
        public List<Opportunity_Product__c> productList;
        public List<Utility.PicklistItem> productStatusPicklists;
    }
    //页面初始化数据
    @AuraEnabled 
    public static String initData(String oppId){
        InitDataWarp initData = new InitDataWarp();        
        initData.productList = new List<Opportunity_Product__c>();
        Opportunity__c thisOpp = getOppInfo(oppId);
        initData.thisOpp = thisOpp;
        initData.productList = thisOpp.Opportunity_Products__r;
        initData.productStatusPicklists = Utility.getPicklistValueList('Opportunity_Product__c', 'Product_Status__c');
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }
    //保存产品
    @AuraEnabled   
    public static String saveOppProduct(List<Opportunity_Product__c> productList, String oppId){
        String saveMessage = 'SUCCESS';
        system.debug('productList ' +productList);
        List<Opportunity_Product__c> upsertoppItemList = new List<Opportunity_Product__c>();
        Savepoint sp = Database.setSavepoint();
        try{
        	Opportunity__c thisOpp = getOppInfo(oppId);
        	Map<String,Opportunity_Product__c> oppItemIdMap = new Map<String,Opportunity_Product__c>();
        	List<Opportunity_Product__c> deleteOppItemList = new List<Opportunity_Product__c>();
        	for(Opportunity_Product__c oppItem : thisOpp.Opportunity_Products__r){
                oppItemIdMap.put(oppItem.Id,oppItem);
        	}
            for(Opportunity_Product__c oppItem : productList){
                if(String.isNotBlank(oppItem.Id)){
                	//编辑quote product


                    //移除未删除的quote product
                    if(oppItemIdMap.containsKey(oppItem.Id)){
                        oppItemIdMap.remove(oppItem.Id);
                    }             
                }else{
                	//新增quote product
                }
                upsertoppItemList.add(oppItem);
            }
            deleteOppItemList = oppItemIdMap.values();
            update upsertoppItemList;
            if(deleteOppItemList.size() > 0){
                delete deleteOppItemList;
            }

        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            saveMessage = Utility.getProperErrorMessage(e.getMessage());
        }
        return saveMessage;
    }
    public static Opportunity__c getOppInfo(String oppId){
        Opportunity__c thisOpp = [SELECT Id,Name,RecordType.DeveloperName,(SELECT Id,Name,Product__c,Product__r.Name,Customer_Model_Product__r.Name,Product_Name_Formula__c,
                                  Quantity__c,Product_Status__c,Remark__c FROM Opportunity_Products__r ORDER BY Customer_Model_Product__r.Name ASC) 
                                  FROM Opportunity__c WHERE Id =:oppId];
        return thisOpp;
    }
}