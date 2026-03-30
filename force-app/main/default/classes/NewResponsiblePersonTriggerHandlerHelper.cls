public with sharing class NewResponsiblePersonTriggerHandlerHelper {
    public static void JudgmentduplicationPromoter(List<Responsible_Person__c> triggerOld,List<Responsible_Person__c> triggerNew) {
        List<String> promoterList = new List<String>();
        List<String> storeList = new List<String>();
        for (Responsible_Person__c res : triggerNew) {
            if(!String.isBlank(res.Principal__c)){
                promoterList.add(res.Principal__c);
                storeList.add(res.Shop_Name__c);
            }
        }
        if(!promoterList.isEmpty()){
            List<Responsible_Person__c> proList = [
                SELECT 
                    Id, 
                    Principal__c,
                    Principal__r.Name, 
                    RecordType__c,
                    Shop_Name__c,
                	Shop_Name__r.Name
                FROM Responsible_Person__c 
                WHERE RecordType__c =:'促销员' 
                    and Id not in:triggerNew
                    and Shop_Name__c in:storeList
            ];
            Map<String, Responsible_Person__c> mso = new Map<String, Responsible_Person__c>();
            for (Responsible_Person__c rp : proList) {
                mso.put(rp.Shop_Name__c+''+rp.Principal__c, rp);
            }
            if (proList.size() > 0) {
                System.debug('proList>'+proList);
                for (Responsible_Person__c rp : triggerNew) {
                    if (mso.containsKey(rp.Shop_Name__c+''+rp.Principal__c)) {
                        Responsible_Person__c rpTemp = mso.get(rp.Shop_Name__c+''+rp.Principal__c);
                        System.debug('促销员数据重复' + rp.Shop_Name__c+','+rp.Principal__c);
                        rp.addError(rpTemp.Principal__r.Name +' '+System.Label.ResponsiblePerson_duplicate_promoter_error + rpTemp.Shop_Name__r.Name);
                        return;
                    }
                    
                }
            }
        }
    }
    /*
    * Name: autoChangeFutureInspectionShopTaskOwnerAfterUpdate
    * Purpose: sync Inspection_Shop_Task__c owner when Responsible_Person__c owner changing
    * Timing : after update
    * Author: yong
    * Create Date: 2023-07-27
    */
    public static void autoChangeFutureInspectionShopTaskOwnerAfterUpdate(List<Responsible_Person__c> triggerOld,List<Responsible_Person__c> triggerNew){
        LisqContainer lc = new LisqContainer(triggerOld);
        List<Responsible_Person__c> rpList = lc.Where1('Principal__c', 'ISCHANGED', triggerNew).ToSobjectList();
        if(rpList.size()>0){
            Map<String,Responsible_Person__c> oldMap = new Map<String,Responsible_Person__c>();
            List<String> oldOwnerId = new List<String>();
            List<String> oldShopId = new List<String>();
            for(Responsible_Person__c rp : rpList){
                oldMap.put(rp.id,rp);
                oldOwnerId.add(rp.Principal__c);
                oldShopId.add(rp.Shop_Name__c);
            }
            LisqContainer lc2 = new LisqContainer(triggerNew);
            List<Responsible_Person__c> rpList2 = lc2.Where1('Principal__c', 'ISCHANGED', triggerOld).ToSobjectList();
            List<Inspection_Shop_Task__c> istList = [SELECT Id,Name,OwnerId ,Shop__c
                                                        FROM Inspection_Shop_Task__c 
                                                        WHERE OwnerId IN: oldOwnerId 
                                                        AND Shop__c IN: oldShopId
                                                        AND Inspection_Date__c > today
                                                    ];
            for(Responsible_Person__c rp : rpList2){
                for(Inspection_Shop_Task__c ist : istList){
                    if(ist.OwnerId == oldMap.get(rp.Id).Principal__c && ist.Shop__c == oldMap.get(rp.Id).Shop_Name__c){
                        ist.OwnerId = rp.Principal__c;
                    }
                }
            }
            update istList;
        }
        
    }
}