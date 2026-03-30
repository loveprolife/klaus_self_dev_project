/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 07-08-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class InspectionShopPlanScheduleTest {
	@isTest
    static void testMethod1(){
        UserRole testRole = new UserRole();
        testRole.Name = 'ID_Floorwalker';
        Insert testRole;
        
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '促销员', email='TestweX@noemail.com',
        emailencodingkey='UTF-8', lastname='Testwe', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,UserRoleId = testRole.Id,
        timezonesidkey='America/Los_Angeles', username='testwe@noemail.com');
        INSERT user1; 
		
        //SchedulableContext sc = new SchedulableContext();
        List<String> floorWalkerRole = new List<String>{'ID_Floorwalker','CL_Floorwalker','SA_Blitz_Field_Reps'};
        User testuser = [SELECT Id,Name,UserRoleId,UserRole.Name,managerId FROM User WHERE UserRole.DeveloperName IN: floorWalkerRole];
        System.debug('++++++++++++++++'+testuser);
        Test.startTest();
        System.Schedule('Delete DataManagerReport periodically on the first day of each month','0 20 18 7 * ?',new InspectionShopPlanSchedule());
        //InspectionShopPlanSchedule.execute(sc);
        Test.stopTest();
    }
}