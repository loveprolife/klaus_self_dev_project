/**********************************************************************
 * 名称: SamplingDetailHandler
 * 功能:
 * 出样明细trigger
 * Author: Gerry
 * Create Date: 2022-01-10
 *************************************************************************/
public without sharing class SamplingDetailHandler implements Triggers.Handler{
	public void handle(){
		System.debug('进入逻辑');
		if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
			System.debug('进入逻辑');

			for (Sampling_Detail__c samplingDetail : (List<Sampling_Detail__c>)Trigger.new ){
				samplingDetail.Product_Id__c = samplingDetail.Product__c;

				// if (String.isNotBlank(samplingDetail.Display_Type__c) && samplingDetail.Display_Type__c != 'All'){
				// 	samplingDetail.ExternalID__c = samplingDetail.Shop__c + '-' + samplingDetail.Product__c + '-' + samplingDetail.Display_Type__c;
				// } else{
				// 	samplingDetail.ExternalID__c = samplingDetail.Shop__c + '-' + samplingDetail.Product__c;
				// }

				samplingDetail.ExternalID__c = samplingDetail.Shop__c + '-' + samplingDetail.Product__c;
				
				// Display or Not=Not时，赋值Hidden_Time__c
				if (samplingDetail.Is_Add__c == '否'){
					samplingDetail.Hidden_Time__c = System.now();
				} else{
					samplingDetail.Hidden_Time__c = null;
				}
				// 再次出样申请，出样时间Sampling_Time__c有值，则不修改时间 东盟样机管理流程
				// if(Trigger.isUpdate){
				//   Sampling_Detail__c samplingDetailOld = (Sampling_Detail__c)Trigger.oldMap.get(samplingDetail.Id);
				//   if(samplingDetailOld.Sampling_Time__c != null) samplingDetail.Sampling_Time__c = samplingDetailOld.Sampling_Time__c;
				// }
			}
		}

		if (Trigger.isAfter && Trigger.isUpdate){
			System.debug('wwww---SamplingDetailHandler---AfterInsert');
			List<Sampling_Detail_Display_Time__c> addList = new List<Sampling_Detail_Display_Time__c>();
			Set<Id> samplingDetailIdSet = new Set<Id>();
			for (Sampling_Detail__c samplingDetail : (List<Sampling_Detail__c>)Trigger.new ){
				samplingDetailIdSet.add(samplingDetail.Id);
			}
			List<Sampling_Detail_Display_Time__c> sddtList = [SELECT Id, Hidden_Time__c, Sampling_Detail__c
			                                                  FROM Sampling_Detail_Display_Time__c
			                                                  WHERE Sampling_Detail__c IN:samplingDetailIdSet
			                                                  ORDER BY CreatedDate DESC];

			for (Sampling_Detail__c samplingDetail : (List<Sampling_Detail__c>)Trigger.new ){
				Sampling_Detail__c samplingDetailOld = (Sampling_Detail__c) Trigger.oldMap.get(samplingDetail.Id);
				if (samplingDetail.Is_Add__c == '是' && samplingDetailOld.Is_Add__c == '否'){
					List<Sampling_Detail_Display_Time__c> sddtFilter = new LisqContainer(sddtList).WhereOne('Sampling_Detail__c', '=', samplingDetail.Id).ToSobjectList();
					if (sddtFilter != null && sddtFilter.size() > 0){
						Sampling_Detail_Display_Time__c sddt = sddtFilter.get(0);
						sddt.Display_Time__c = System.now();
						Long displayTime = sddt.Display_Time__c.getTime();
						Long hiddenTime = sddt.Hidden_Time__c.getTime();
						// 计算时间差(秒)
						sddt.Time_Difference__c = (displayTime - hiddenTime) / 1000;
						addList.add(sddt);
					}
				} else if (samplingDetail.Is_Add__c == '否' && samplingDetailOld.Is_Add__c == '是'){
					Sampling_Detail_Display_Time__c sddt = new Sampling_Detail_Display_Time__c();
					sddt.Sampling_Detail__c = samplingDetail.Id;
					sddt.Hidden_Time__c = System.now();
					addList.add(sddt);
				}
			}
			upsert addList;
		}
	}

}