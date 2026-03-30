public without sharing class UserDeviceRelated{
    public static Promoter_Attendance_Information__c setPromoterAttendanceInformation(Promoter_Attendance_Information__c pai){
        List<UserDevice> uDevice = [SELECT Id, DeviceType, DeviceNativeUid
                                    FROM UserDevice
                                    WHERE UserId = :UserInfo.getUserId()
                                    ORDER BY CreatedDate DESC];
        if (uDevice.size() > 0){
            UserDevice ud = uDevice[0];
            pai.UserDeviceId__c = ud.Id;
            pai.DeviceNativeUid__c = ud.DeviceNativeUid;
            pai.DeviceType__c = ud.DeviceType;
        }
        return pai;
    }

}