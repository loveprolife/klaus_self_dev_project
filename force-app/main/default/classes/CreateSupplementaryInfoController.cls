/*
 * @Author: Rain
 * @Date: 2022-04-25 22:08:52
 * @LastEditors: Rain
 * @LastEditTime: 2022-04-27 21:24:28
 * @Description: CreateSupplementaryInfoLWC controller
 */
public without sharing class CreateSupplementaryInfoController {
    public static String EXIST_OUT_TIP = System.Label.SignOutExist;
    public static String EXIST_IN_TIP = System.Label.SignInExist;
    public static String NO_RELATED_RECORD = System.Label.SignNoRelatedRecord;
    @AuraEnabled
    public static ReturnData submitRecords(String reordJson){
        System.debug('reordJson: ' + reordJson);
        String checkInRTID = Schema.SObjectType.Supplementary_Information__c.getRecordTypeInfosByDeveloperName().get('CheckInSupplementary').getRecordTypeId();
        String checkOutRTID = Schema.SObjectType.Supplementary_Information__c.getRecordTypeInfosByDeveloperName().get('CheckOutSupplementary').getRecordTypeId();
        ReturnData returnData = new ReturnData();
        try {
            RecordData data = (RecordData)JSON.deserialize(reordJson, RecordData.class);
            List<Supplementary_Information__c> supplementaryInfoList = new List<Supplementary_Information__c>();
            String attendanceId = getAttendanceByDate(data.selectedDate);
            
            if(attendanceId == null) {
                returnData.errorMsg = NO_RELATED_RECORD;
                return returnData;
            }
            
            Set<String> existSupplementaryRTSet = getExistSupplementary(attendanceId);
            returnData.attendanceId = attendanceId;
            //补签到
            if(data.checkInBoxFieldValue != null && data.checkInBoxFieldValue) {
                if(existSupplementaryRTSet.contains(checkInRTID)) {
                    returnData.errorMsg = data.selectedDate + EXIST_IN_TIP;
                    return returnData;
                }

                Supplementary_Information__c signInInfo = new Supplementary_Information__c();
                signInInfo.RecordTypeId = checkInRTID;
                signInInfo.Shop__c = data.inShop;
                String[] strTimeSplit = data.signInTime.split(':');
                signInInfo.Supplementary_SignIn_Time__c = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
                signInInfo.Reson__c = ' ';
                signInInfo.Attendance__c = attendanceId;
                supplementaryInfoList.add(signInInfo);
            }
            //补签退
            if(data.checkOutBoxFieldValue != null && data.checkOutBoxFieldValue) {
                if(existSupplementaryRTSet.contains(checkOutRTID)) {
                    returnData.errorMsg = data.selectedDate + EXIST_OUT_TIP;
                    return returnData;
                }
                
                Supplementary_Information__c signOutInfo = new Supplementary_Information__c();
                signOutInfo.RecordTypeId = checkOutRTID;
                signOutInfo.Shop__c = data.outShop;
                String[] strTimeSplit = data.signOutTime.split(':');
                signOutInfo.Supplementary_SignOut_Time__c = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0,0);
                signOutInfo.Reson__c = ' ';
                signOutInfo.Attendance__c = attendanceId;
                supplementaryInfoList.add(signOutInfo);
            }

            if(supplementaryInfoList.size() > 0) {
                Database.SaveResult[] resultList = Database.insert(supplementaryInfoList,false);
                //提交审批
                List<Approval.ProcessSubmitRequest> submitRequestList = new List<Approval.ProcessSubmitRequest>();
                for(Database.SaveResult result : resultList) {
                    if(result.isSuccess()) {
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(result.getId());
                        req.setSubmitterId(UserInfo.getUserId());
                        req.setSkipEntryCriteria(false);
                        submitRequestList.add(req);
                    }
                }
                
                if(submitRequestList.size() > 0) {
                    Approval.process(submitRequestList);
                }
            }
        } catch (Exception e) {
            returnData.errorMsg = e.getLineNumber() + '---' + e.getMessage();
        }
        return returnData;
    }

    @AuraEnabled
    public static String getAttendanceByDate(String subjectDate) {
        Date checkInDate = Date.valueOf(subjectDate);
        return [SELECT Id FROM Promoter_Attendance__c WHERE OwnerId = :UserInfo.getUserId() AND CheckIn_Date__c = :checkInDate ORDER BY CreatedDate DESC][0].Id;
    }

    public static Set<String> getExistSupplementary(String attendanceId) {
        List<Supplementary_Information__c> supplementaryList = [
                                                                SELECT 
                                                                    Id, 
                                                                    RecordTypeId
                                                                FROM 
                                                                Supplementary_Information__c 
                                                                WHERE 
                                                                Attendance__c =: attendanceId
                                                                ];
        Set<String> recordTypeSet = new Set<String>();
        for(Supplementary_Information__c supplementary : supplementaryList) {
            recordTypeSet.add(supplementary.RecordTypeId);
        }
        return recordTypeSet;
    }

    public class ReturnData {
        @AuraEnabled
        public String attendanceId;
        @AuraEnabled
        public String errorMsg;
    }

    public class RecordData {
        public String selectedDate;
        public Boolean checkInBoxFieldValue;
        public Boolean checkOutBoxFieldValue;
        public String inShop;
        public String signInTime;
        public String outShop;
        public String signOutTime;
    }
}