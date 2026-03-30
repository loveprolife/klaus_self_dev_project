/**************************************************************************************************
 * PriceBookTriggerHandler
 * Purpose:Price Book Trigger处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-04-04
***************************************************************************************************/
public without sharing class  PriceBookTriggerHandler extends TriggerHandler{
    public static User currentUser = [SELECT Id,Profile.Name,ManagerId,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
    public Set<String> pbNameSet = new Set<String>();
    public List<Pricebook__c> pbList = new List<Pricebook__c>();
    public override void beforeInsert(){
        System.debug('beforeInsert');
        for(Pricebook__c pb : (List<Pricebook__c>)Trigger.new){
            pbNameSet.add(pb.Name);
            pbList.add(pb);
        }
        isDuplicateCheck(pbNameSet,pbList);
        
    }
    public override void beforeUpdate(){
        for(Pricebook__c newPb : (List<Pricebook__c>)Trigger.new){
            Pricebook__c oldPb = (Pricebook__c)Trigger.oldMap.get(newPb.Id);
            if(!newPb.Name.equals(oldPb.Name)){
                pbNameSet.add(newPb.Name);
                pbList.add(newPb);
            }
        }
        if(!pbNameSet.isEmpty()){
            isDuplicateCheck(pbNameSet,pbList);
        }
    }
    /**
     方法名: isDuplicateCheck
     功能说明: 判断价格手册名称是否重复
     参数说明: Set<String> pbNameSet,List<Pricebook__c> pbList
     返回值: 
     作者: Johnson
     日期: 2019-04-04
    */
    private void isDuplicateCheck(Set<String> pbNameSet,List<Pricebook__c> pbList){
    	Map<String,String> existPriceBookNameMap = new Map<String,String>();
        for(Pricebook__c pb : [SELECT Id,Name FROM Pricebook__c WHERE Name IN:pbNameSet]){
            existPriceBookNameMap.put(pb.Name, pb.Id);
        }
        //System.debug('existPriceBookNameMap: ' + existPriceBookNameMap);
        for(Pricebook__c pbNew : pbList){
            if(existPriceBookNameMap.containsKey(pbNew.Name)){
                //pbNew.addError('Creation or editing is not allowed, a price book with the same name already exists in the system.');
                pbNew.addError(Label.Price_Book_Name_Duplicate);
                continue;
            }
        }
    }
}