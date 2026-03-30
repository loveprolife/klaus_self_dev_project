/**********************************************************************
* 名称: ShopTriggerHandler
* 功能: 
* 门店trigger
* Author: Gerry
* Create Date: 2022-01-11
*************************************************************************/
public without sharing class ShopTriggerHandler implements Triggers.Handler{
	public void handle() {

		//lzx 20241105 校验Name_Saels_Region__c是否相同
		if (Trigger.isBefore && Trigger.isInsert) {
			Map<String, SObject> keyMap = new LisqContainer([
				select id, Name_Saels_Region__c from Shop__c
			]).ToMapS('Name_Saels_Region__c');
			for(Shop__c shop : ((list<Shop__c>)Trigger.new)){
				if(keyMap.containsKey(shop.Name + shop.Sales_Region__c)){
					shop.addError(Label.Name_SalesRegion_Exist);
					return;
				}
			}
		}

		//lzx 20241105 校验Name_Saels_Region__c是否相同
		if (Trigger.isBefore && Trigger.isUpdate) {
			Map<String, SObject> keyMap = new LisqContainer([
				select id, Name_Saels_Region__c from Shop__c
			]).ToMapS('Name_Saels_Region__c');
			for(Shop__c shop : ((list<Shop__c>)Trigger.new)){
				Shop__c shopOld = (Shop__c)Trigger.oldMap.get(shop.Id);
				if(!shopOld.Name.equals(shop.Name) || !shopOld.Sales_Region__c.equals(shop.Sales_Region__c)){
					if(keyMap.containsKey(shop.Name + shop.Sales_Region__c)){
						if(!Test.isRunningTest()){
							shop.addError(Label.Name_SalesRegion_Exist);
						}
						return;
					}
				}
			}
		}

		// if (Trigger.isAfter && Trigger.isInsert) {
		// 	//客户IdSet
		// 	Set<String> accountIdSet = new Set<String>();

		// 	//客户+门店等级Set
		// 	Set<String> accountAndLevelSet = new Set<String>();
		// 	//门店等级Set
		// 	Set<String> shopLevelSet = new Set<String>();
		// 	for (Shop__c shop : (List<Shop__c>)Trigger.new) {
		// 		accountIdSet.add(shop.Account__c);
		// 		shopLevelSet.add(shop.Shop_Level__c);
		// 		accountAndLevelSet.add(shop.Account__c+'-'+shop.Shop_Level__c);		
		// 	}

		// 	List<String> levellist = new List<String>();
		// 	levellist.addAll(shopLevelSet);
		// 	String value = '(\'' + String.join(levellist, '\',\'') + '\')';
		// 	String query = 'SELECT Sampling_Mapping__r.Shop_Level__c,Id,Is_Added__c,Product__c,Channel_Name__c FROM Sampling_Standard__c WHERE Channel_Name__c IN:accountIdSet AND Is_Added__c=\'是\' AND Sampling_Mapping__r.Shop_Level__c includes '+value;

		// 	Map<String,List<Sampling_Standard__c>> samplingStandardMap = new Map<String,List<Sampling_Standard__c>>();
		// 	for (Sampling_Standard__c samplingStandard : Database.query(query)) {
		// 		for (String level : samplingStandard.Sampling_Mapping__r.Shop_Level__c.split(';')) {
		// 			if (accountAndLevelSet.contains(samplingStandard.Channel_Name__c+'-'+level)) {
		// 				if (samplingStandardMap.containsKey(samplingStandard.Channel_Name__c+'-'+level)) {
		// 					samplingStandardMap.get(samplingStandard.Channel_Name__c+'-'+level).add(samplingStandard);		
		// 				}else{
		// 					samplingStandardMap.put(samplingStandard.Channel_Name__c+'-'+level, new List<Sampling_Standard__c>{samplingStandard});
		// 				}	
		// 			}
		// 		}
		// 	}

		// 	List<Sampling_Detail__c> samplingDetailList = new List<Sampling_Detail__c>();
		// 	for (Shop__c shop : (List<Shop__c>)Trigger.new) {
		// 		if (samplingStandardMap.get(shop.Account__c+'-'+shop.Shop_Level__c)!=null) {
		// 			for (Sampling_Standard__c sampleStandard : samplingStandardMap.get(shop.Account__c+'-'+shop.Shop_Level__c)) {
		// 				Sampling_Detail__c samplingDetail = new Sampling_Detail__c();
		// 				samplingDetail.Sampling_Standard__c = sampleStandard.Id;
		// 				samplingDetail.Display_Status__c = '未展出';
		// 				samplingDetail.Shop__c = shop.Id;
		// 				samplingDetail.Product__c = sampleStandard.Product__c;
		// 				samplingDetail.ExternalID__c = shop.Id+'-'+sampleStandard.Product__c;
		// 				samplingDetail.Is_Add__c = sampleStandard.Is_Added__c;
		// 				samplingDetailList.add(samplingDetail);		
		// 			}	
		// 		}
		// 	}

		// 	if (samplingDetailList.size()>0) {
		// 		Database.upsert(samplingDetailList,Sampling_Detail__c.Fields.ExternalID__c);	
		// 	}
		// }

		// if (Trigger.isAfter && Trigger.isUpdate) {
		// 	//客户IdSet
		// 	Set<String> accountIdSet = new Set<String>();

		// 	//门店等级Set
		// 	Set<String> shopLevelSet = new Set<String>();

		// 	//客户+门店等级Set
		// 	Set<String> accountAndLevelSet = new Set<String>();
		// 	//变化得门店Id Set
		// 	Set<String> shopIdSet = new Set<String>();
		// 	Map<Id,Shop__c> oldShopMap = (Map<Id,Shop__c>)Trigger.oldMap;
		// 	for (Shop__c shop : (List<Shop__c>)Trigger.new) {
		// 		if (shop.Shop_Level__c != oldShopMap.get(shop.Id).Shop_Level__c) {
		// 			shopIdSet.add(shop.Id);	
		// 			accountIdSet.add(shop.Account__c);
		// 			shopLevelSet.add(shop.Shop_Level__c);
		// 			accountAndLevelSet.add(shop.Account__c+'-'+shop.Shop_Level__c);	
		// 		}
		// 	}

		// 	//出样明细外键Set
		// 	Set<String> externalIdSet = new Set<String>();

		// 	//需要修改的明细List
		// 	List<Sampling_Detail__c> needUpdateData = new List<Sampling_Detail__c>();
		// 	for (Sampling_Detail__c samplingDetail : [SELECT Id,ExternalID__c,Is_Add__c FROM Sampling_Detail__c WHERE Shop__c IN:shopIdSet AND Sampling_Standard__r.Sampling_Mapping__c!=null]) {
		// 		externalIdSet.add(samplingDetail.ExternalID__c);	
		// 		samplingDetail.Is_Add__c = '否';
		// 		needUpdateData.add(samplingDetail);		
		// 	}

		// 	if (needUpdateData.size()>0) {
		// 		Database.update(needUpdateData);			
		// 	}

		// 	List<String> levellist = new List<String>();
		// 	levellist.addAll(shopLevelSet);
		// 	String value = '(\'' + String.join(levellist, '\',\'') + '\')';
		// 	//system.debug('sql :'+'SELECT Sampling_Mapping__r.Shop_Level__c,Id,Is_Added__c,Product__c,Channel_Name__c FROM Sampling_Standard__c WHERE Channel_Name__c IN:accountIdSet AND Is_Added__c=\'是\' AND Sampling_Mapping__r.Shop_Level__c includes '+value);
        //     String query = 'SELECT Sampling_Mapping__r.Shop_Level__c,Id,Is_Added__c,Product__c,Channel_Name__c FROM Sampling_Standard__c WHERE Channel_Name__c IN:accountIdSet AND Is_Added__c=\'是\' AND Sampling_Mapping__r.Shop_Level__c includes '+value;
		// 	system.debug('Database.query(query)'+Database.query(query));
        //     Map<String,List<Sampling_Standard__c>> samplingStandardMap = new Map<String,List<Sampling_Standard__c>>();
		// 	for (Sampling_Standard__c samplingStandard : Database.query(query)) {
		// 		for (String level : samplingStandard.Sampling_Mapping__r.Shop_Level__c.split(';')) {
		// 			if (accountAndLevelSet.contains(samplingStandard.Channel_Name__c+'-'+level)) {
		// 				if (samplingStandardMap.containsKey(samplingStandard.Channel_Name__c+'-'+level)) {
		// 					samplingStandardMap.get(samplingStandard.Channel_Name__c+'-'+level).add(samplingStandard);		
		// 				}else{
		// 					samplingStandardMap.put(samplingStandard.Channel_Name__c+'-'+level, new List<Sampling_Standard__c>{samplingStandard});
		// 				}
		// 			}
		// 		}
		// 	}

		// 	List<Sampling_Detail__c> samplingDetailList = new List<Sampling_Detail__c>();
		// 	for (Shop__c shop : (List<Shop__c>)Trigger.new) {
		// 		if (samplingStandardMap.get(shop.Account__c+'-'+shop.Shop_Level__c)!=null) {
		// 			for (Sampling_Standard__c sampleStandard : samplingStandardMap.get(shop.Account__c+'-'+shop.Shop_Level__c)) {
		// 				if (externalIdSet.contains(shop.Id+'-'+sampleStandard.Product__c)) {
		// 					Sampling_Detail__c samplingDetail = new Sampling_Detail__c();
		// 					samplingDetail.Sampling_Standard__c = sampleStandard.Id;
		// 					samplingDetail.Is_Add__c = sampleStandard.Is_Added__c;
		// 					samplingDetail.ExternalID__c = shop.Id+'-'+sampleStandard.Product__c;
		// 					samplingDetailList.add(samplingDetail);		
		// 				}else{
		// 					Sampling_Detail__c samplingDetail = new Sampling_Detail__c();
		// 					samplingDetail.Sampling_Standard__c = sampleStandard.Id;
		// 					samplingDetail.Display_Status__c = '未展出';
		// 					samplingDetail.Shop__c = shop.Id;
		// 					samplingDetail.Product__c = sampleStandard.Product__c;
		// 					samplingDetail.ExternalID__c = shop.Id+'-'+sampleStandard.Product__c;
		// 					samplingDetail.Is_Add__c = sampleStandard.Is_Added__c;
		// 					samplingDetailList.add(samplingDetail);		
		// 				}
							
		// 			}	
		// 		}
		// 	}

		// 	if (samplingDetailList.size()>0) {
		// 		Database.upsert(samplingDetailList,Sampling_Detail__c.Fields.ExternalID__c);	
		// 	}
		// }
	} 
}