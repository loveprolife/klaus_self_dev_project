/**************************************************************************************************
 * Name:Opportunity__cAddProductController
 * Purpose:选择业务机会产品
 * Author: Deloitte Johnson
 * Create Date: 2019-03-11
***************************************************************************************************/
global  without sharing class OpportunityAddProductController{
    public static User currentUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];  
    public Class InitDataWarp{
        public Opportunity__c thisOpp;
        public Boolean isSolutionOpp;
        public List<Product__c> productList;
        List<Utility.PicklistItem> productStatusPicklists;
        List<Utility.PicklistItem> productLinePicklists;
    } 
    //页面初始化数据
    @AuraEnabled 
    public static String initData(String oppId){
        InitDataWarp initData = new InitDataWarp();  
        initData.productLinePicklists = new List<Utility.PicklistItem>();      
        Opportunity__c  thisOpp = getOppInfo(oppId);
        System.debug('thisOpp==>>>' +thisOpp);
        List<Utility.PicklistItem> allLinePicklists = Utility.getPicklistValueList('Opportunity__c', 'Opportunity_Product_Type__c');
        for(Utility.PicklistItem proLine : allLinePicklists){
            //initData.productLinePicklists.add(proLine);
            if(thisOpp.Opportunity_Product_Type__c.contains(proLine.value)){
                initData.productLinePicklists.add(proLine);
            }
        }
        List<Product__c> proList = new List<Product__c>();
        List<String> proLineList = new List<String>{initData.productLinePicklists[0].value};
        proList = getSearchResultList(proLineList,'',oppId);
        initData.productList = proList;
        initData.thisOpp = thisOpp;
        initData.productStatusPicklists = Utility.getPicklistValueList('Opportunity_Product__c', 'Product_Status__c');
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }
    //根据产品线、产品名获取产品搜索结果
    @AuraEnabled  
    public static List<Product__c> getSearchResultList(List<String> proLineList,String proName,String oppId){
        String sqlQuery='SELECT Id,Name'+ 
                        ' FROM Product__c WHERE Name != null';
        //Opportunity__c thisOpp = getOppInfo(oppId);
        if(proLineList.size() > 0){
            sqlQuery += ' AND Product_Line__c IN:proLineList';
        }
        if(String.isNotBlank(proName)){
            sqlQuery += ' AND (Name like \'%' + proName.trim() + '%\')';
        }
        sqlQuery += ' ORDER BY Name ASC LIMIT 20';
        System.debug('sqlQuery===>'+sqlQuery);
        List<Product__c> proList = Database.query(sqlQuery);
        return proList;
    }
    //获取选中的产品行信息
    @AuraEnabled  
    public static List<Opportunity_Product__c> getSelectedProList(String proIdString,String oppId){
        Opportunity__c  thisOpp = getOppInfo(oppId);
        List<String> proIdList = proIdString.split(';');
        List<Opportunity_Product__c> selectedProList = new List<Opportunity_Product__c>();
        List<Product__c> proList = [SELECT Id,Name
                                   FROM Product__c WHERE Id IN:proIdList ORDER BY Name ASC];
        for(Product__c pro : proList){
            Opportunity_Product__c oppItem = new Opportunity_Product__c();
            oppItem.Opportunity__c = oppId;
            oppItem.Product__r = pro;
            oppItem.Product__c = pro.Id;
            selectedProList.add(oppItem);
        }
        return selectedProList;
    }
    //保存产品
    @AuraEnabled 
    public static String saveOppProduct(List<Opportunity_Product__c> productList){
        String saveMessage = 'SUCCESS';
        Savepoint sp = Database.setSavepoint();
        try{
            if(productList == null || productList.size() <= 0){
                //saveMessage = 'Save information can\'t be null';
                saveMessage = Label.Common_Save_Info_Cannot_Be_Null;
                return saveMessage;
            }
            insert productList;

        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            saveMessage = Utility.getProperErrorMessage(e.getMessage());
        }
        return saveMessage;
    }
    public static Opportunity__c getOppInfo(String oppId){
        Opportunity__c opp = [SELECT Id,Name,RecordType.DeveloperName,Opportunity_Product_Type__c  
                           FROM Opportunity__c WHERE Id =:oppId];
        return opp;
    } 
}