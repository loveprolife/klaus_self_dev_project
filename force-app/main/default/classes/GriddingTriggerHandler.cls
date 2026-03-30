/**********************************************************************
* 名称: GriddingTriggerHandler
* 功能: 
* 网格trigger
* Author: wfc
* Create Date: 2022-02-23
*************************************************************************/
public without sharing class GriddingTriggerHandler implements Triggers.Handler{

    public void handle() {

        if (Trigger.isAfter && Trigger.isUpdate) {
            for (Gridding__c gridding : (List<Gridding__c>)Trigger.new) {
                Gridding__c griddingOld = (Gridding__c)Trigger.oldMap.get(gridding.Id);
                if (!(gridding.Gridding_Code__c + '').equals(griddingOld.Gridding_Code__c)) {
                    ShopExternalKeyBatch scr = new ShopExternalKeyBatch();
                    Database.executeBatch(scr,200);
                }
            }
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            for (Gridding__c gridding : (List<Gridding__c>)Trigger.new) {
                gridding.Gridding_Code__c = gridding.name;
            }
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Gridding__c gridding : (List<Gridding__c>)Trigger.new) {
                Gridding__c griddingOld = (Gridding__c)Trigger.oldMap.get(gridding.Id);
                if (!gridding.name.equals(griddingOld.name)) {
                    gridding.Gridding_Code__c = gridding.name;
                }
            }
        }

    }
}