public without sharing class SupplementaryInformationHandler implements Triggers.Handler {
    public void handle() {

        if(Trigger.isBefore && Trigger.isInsert) {
            Set<String> supplementarySet= new Set<String>(); 
            List<Promoter_Attendance__c> paList = new List<Promoter_Attendance__c>();
            for(Supplementary_Information__c   recItem : (List<Supplementary_Information__c  >)Trigger.new) {
                supplementarySet.add(recItem.Attendance__c + '_' + recItem.RecordTypeId);
                Promoter_Attendance__c paItem = new Promoter_Attendance__c(Id = recItem.Attendance__c);
                if(recItem.RecordTypeDevName__c == 'CheckOutSupplementary'){
                    paItem.CheckOutApprovalStatus__c = recItem.Status__c;
                }else if(recItem.RecordTypeDevName__c == 'CheckInSupplementary') {
                    paItem.ApprovalStatus__c = recItem.Status__c;
                }
                paList.add(paItem);
            }
            update paList;
            List<Supplementary_Information__c> siList = [SELECT Id FROM Supplementary_Information__c WHERE SearchMark__c IN: supplementarySet
                                                            AND Status__c <> '补签申请审批通过' ];
            if(siList.size() > 0) {
                for(Supplementary_Information__c recItem : (List<Supplementary_Information__c  >)Trigger.new) {
                    recItem.addError(System.Label.Supplementary_IN_APPROVAL);
                }
            }
        }

		if (Trigger.isAfter && Trigger.isUpdate) {
            List<Promoter_Attendance__c> paList = new List<Promoter_Attendance__c>();
            Map<Id, Supplementary_Information__c> recOldMap  = (Map<Id, Supplementary_Information__c>)Trigger.oldMap;
            
            Set<String> paId = new Set<String>();
            for (Supplementary_Information__c  recItem : (List<Supplementary_Information__c  >)Trigger.new) {
                paId.add(recItem.Attendance__c);
            }
            Map<String,Promoter_Attendance__c> promoterAttendanceMap = new Map<String,Promoter_Attendance__c>();
            List<Promoter_Attendance__c> paListInfo = [SELECT Id,CheckInStatus__c FROM Promoter_Attendance__c WHERE Id IN :paId];
            if(paListInfo != null && paListInfo.size() > 0){
                for(Promoter_Attendance__c pa : paListInfo){
                    if (!promoterAttendanceMap.containsKey(pa.Id)) {
                        promoterAttendanceMap.put(pa.Id, pa);
                    }	
                }
            }

            for (Supplementary_Information__c   recItem : (List<Supplementary_Information__c  >)Trigger.new) {
                Supplementary_Information__c oldRecItem = recOldMap.get(recItem.Id);
                if(recItem.Status__c <> oldRecItem.Status__c && recItem.Attendance__c <> null){
                    // Promoter_Attendance__c paItem = new Promoter_Attendance__c(Id = recItem.Attendance__c);
                    Promoter_Attendance__c paItem = promoterAttendanceMap.get(recItem.Attendance__c);
                    if(recItem.RecordTypeDevName__c == 'CheckOutSupplementary'){
                        paItem.CheckOutApprovalStatus__c = recItem.Status__c;
                        if(recItem.Status__c == '补签申请审批通过') {
                            paItem.SignOutTime__c = recItem.Supplementary_SignOut_Time__c;
                            if(recItem.Shop__c <> null){
                                paItem.CheckOutShop__c = recItem.Shop__c;
                            }
                            // 判断是否有签到 wfc
                            if(paItem.CheckInStatus__c == '已签到' || paItem.CheckInStatus__c == '已签到签退'){
                                paItem.CheckInStatus__c = '已签到签退';
                            }else {
                                paItem.CheckInStatus__c = '已签退';
                            }
                        }

                    }else if(recItem.RecordTypeDevName__c == 'CheckInSupplementary') {
                        paItem.ApprovalStatus__c = recItem.Status__c;
                        if(recItem.Status__c == '补签申请审批通过') {
                            paItem.SignInTime__c = recItem.Supplementary_SignIn_Time__c;
                            if(recItem.Shop__c <> null){
                                paItem.Shop__c = recItem.Shop__c;
                            }  
                            // 判断是否有签退 wfc
                            if(paItem.CheckInStatus__c == '已签退' || paItem.CheckInStatus__c == '已签到签退'){
                                paItem.CheckInStatus__c = '已签到签退';
                            }else {
                                paItem.CheckInStatus__c = '已签到';
                            } 
                        }
                    }   
                    paList.add(paItem);
                }
            }
            update paList;
        }
    }
}