public without sharing class PromoterAttendanceHandler implements Triggers.Handler {
    public void handle() {
		if (Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {
			for (Promoter_Attendance__c   paItem : (List<Promoter_Attendance__c  >)Trigger.new) {
				//date:2022/02/14 -change:促销员和巡店员都一天只有一条考勤
				//paItem.ExternalId__c = paItem.Shop__c + '_' + paItem.OwnerId + '_' + paItem.CheckIn_Date__c;
				// data:2023/12/01 -change:培训签到每个门店一个考勤 wfc
				if(String.isBlank(paItem.ExternalId__c)){
					paItem.ExternalId__c = paItem.OwnerId + '_' + String.valueOf(paItem.CheckIn_Date__c);
				}
			}	
		}
    }
}