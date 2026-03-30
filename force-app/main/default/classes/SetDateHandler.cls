/**********************************************************************
* 名称: SetDateHandler
* 功能: 
* 任务Handler
* Author: Gerry
* Create Date: 2022-01-07
*************************************************************************/
public without sharing class SetDateHandler implements Triggers.Handler{
    public void handle() {
    	if (Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {
            User currentUser = [SELECT Id,Name,Country__c FROM User WHERE Id =: UserInfo.getUserId()];
            Boolean isPhaseIIIUser = PhaseIIIUtility.isPhaseIIIUser();
            for (Inspection_Shop_Task__c shopTask : (List<Inspection_Shop_Task__c>)Trigger.new) {
                shopTask.DateString__c = String.valueOf(shopTask.Inspection_Date__c); 
                // if(isPhaseIIIUser){
                //     shopTask.ExternalID__c = shopTask.Plan_OwnerId__c + shopTask.DateString__c+'-'+shopTask.Shop__c; 
                // }else{
                //     shopTask.ExternalID__c = shopTask.DateString__c+'-'+shopTask.Shop__c; 
                // }
                shopTask.ExternalID__c = shopTask.Plan_OwnerId__c + shopTask.DateString__c+'-'+shopTask.Shop__c; 
                     
            }    
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
        	Set<String> taskIdSet = new Set<String>();
        	Map<Id,Inspection_Shop_Task__c> oldTask = (Map<Id,Inspection_Shop_Task__c>)Trigger.oldMap;
        	for (Inspection_Shop_Task__c shopTask : (List<Inspection_Shop_Task__c>)Trigger.new) {
                if (shopTask.Status__c == '未到访' && oldTask.get(shopTask.Id).Status__c=='已到访') {
                	taskIdSet.add(shopTask.Id);
                }
            }

            if (taskIdSet.size()>0) {
                updateData(taskIdSet);	
            }
        }

        if (Trigger.isBefore && Trigger.isDelete) {
        	Set<String> taskIdSet = new Set<String>();
        	for (Inspection_Shop_Task__c shopTask : (List<Inspection_Shop_Task__c>)Trigger.old) {
        		taskIdSet.add(shopTask.Id);		
        	}	
            if (taskIdSet.size()>0) {
                updateData(taskIdSet);
                //需要处理的考勤数据
                List<Promoter_Attendance__c> updatePromoterAttendanceList = [SELECT Id FROM Promoter_Attendance__c WHERE InspectionShopTask__c IN:taskIdSet];
                Database.delete(updatePromoterAttendanceList);
            }
        }
    }

    public void updateData(Set<String> taskIdSet) {
    	//出样明细IdSet
        Set<String> samplingDetailIdSet = new Set<String>();
        List<Sampling_Inspection__c> samplingInspectionList = [SELECT Id,Sample_Item__c FROM Sampling_Inspection__c WHERE Inspection_Shop_Task__c IN:taskIdSet]; 
        for (Sampling_Inspection__c samplingInspection : samplingInspectionList) {
        	samplingDetailIdSet.add(samplingInspection.Sample_Item__c);			
        }
        Database.delete(samplingInspectionList);

        //需要删除的出样明细
        List<Sampling_Detail__c> deleteSamplingDetailList = new List<Sampling_Detail__c>();

        //需要修改的出样明细
        List<Sampling_Detail__c> updateSamplingDetailList = new List<Sampling_Detail__c>();
        for (Sampling_Detail__c samplingDetail : [SELECT Id,(SELECT Id,Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c,Placement_Status__c FROM MVrr__r Order by Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c desc limit 1) FROM Sampling_Detail__c WHERE Id IN:samplingDetailIdSet]) {
        	if (samplingDetail.MVrr__r.size()>0) {
        		samplingDetail.Display_Status__c = samplingDetail.MVrr__r[0].Placement_Status__c;
        		updateSamplingDetailList.add(samplingDetail); 						
        	}else{
        		deleteSamplingDetailList.add(samplingDetail);

        	}					
        }

        System.debug('deleteSamplingDetailList'+deleteSamplingDetailList);

        Database.delete(deleteSamplingDetailList);
        Database.update(updateSamplingDetailList);

        //需要修改的竞品价格
        // List<Shop_Competitive_Product__c> shopCompetitiveProduct = [SELECT Id,Competitive_Products__c FROM Shop_Competitive_Product__c WHERE Inspection_Shop_Task__c IN:taskIdSet];
        // Set<String> competitiveProductsSet = new Set<String>();
        // for (Shop_Competitive_Product__c scp : shopCompetitiveProduct) {
        // 	competitiveProductsSet.add(scp.Competitive_Products__c);			
        // }

        // Database.delete(shopCompetitiveProduct);

        //需要删除的竞品
        // List<Competitive_products__c> deleteCompetitiveproductsList = new List<Competitive_products__c>();
        // for (Competitive_products__c competitiveProducts : [SELECT Id,(SELECT Id FROM Competitive_Competitive_Products__r) FROM Competitive_products__c WHERE Id IN:competitiveProductsSet]) {
        // 	if (competitiveProducts.Competitive_Competitive_Products__r.size()==0) {
        // 		deleteCompetitiveproductsList.add(competitiveProducts);			
        // 	}		
        // }

        // Database.delete(deleteCompetitiveproductsList);

        		
    }
    
}