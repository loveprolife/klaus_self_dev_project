@isTest
public class UserDeviceRelatedTest {

    @IsTest
    static void method1(){
        
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        insert pa;
        
        Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
        pai.Promoter_Attendance__c = pa.Id;
        insert pai;
        
        UserDevice ud = new UserDevice();
        ud.UserId = UserInfo.getUserId();
        ud.Name = 'test';
        insert ud;
        
        UserDeviceRelated.setPromoterAttendanceInformation(pai);
        
    }
}