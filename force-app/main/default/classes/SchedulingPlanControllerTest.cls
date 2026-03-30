@isTest
public with sharing class SchedulingPlanControllerTest {

    @IsTest
    public static void method1(){
        SchedulingPlanController.initLabel();
        SchedulingPlanController.init('');
        SchedulingPlanController.initData('2023','11','','','');
        SchedulingPlanController.initData('2023','11','','',UserInfo.getUserId());
    }
    @IsTest
    public static void method2(){
        
        User u = [SELECT Id,Name,Username,Sales_Region__c FROM User WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = new Shop__c();
        shop.Name = 'test';
        shop.City__c = '广州市';
        shop.Address1__c = '天河区';
        shop.Sales_Region__c = u.Sales_Region__c;
        insert shop;

        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,30,00,00);
        par.End_time__c = Time.newInstance(18,30,00,00);
        par.Distance__c = 300;
        par.Time_buffer__c = 30;
        par.Need_Check_Distance__c = true;
        par.Name = '10:00-22:00 Buffer-10min Distance-300m';
        insert par;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.UserEmail__c = 'test123@noemail.com';
        rp.RecordType__c = '促销员';
        rp.Shop_Name__c = shop.Id;
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp; 

        SchedulingTask__c task = new SchedulingTask__c();
        task.IsImport__c = false;
        task.Scheduling_Date__c = System.today();
        task.Responsible_person__c = rp.Id;
        task.Store__c = shop.Id;
        task.User__c = UserInfo.getUserId();
        task.Status__c = 'Scheduled';
        task.Promoter_Attendance_Rule__c = par.Id;
        // insert task;

        String taskid = SchedulingPlanController.upsertSchedulingTask(JSON.serialize(task));
        SchedulingPlanController.deleteSchedulingTask(taskid);

        
        Promoter_Attendance_Rule__c queryPar = [SELECT Id,Name FROM Promoter_Attendance_Rule__c WHERE Id = :par.Id];
        String json = '[{"storeName": "test","userName":"'+u.Username+'","task":{"1":"0","2":"1","3":"'+queryPar.Name+'"}}]';
        SchedulingPlanController.uploadCSV(json,'2050','1',u.Sales_Region__c);
        
        String recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Leave').getRecordTypeId();
        Application__c app = new Application__c();
        app.RecordTypeId = recordTypeId;
        app.From__c = Datetime.newInstance(2050, 1, 1, 1, 1, 1);
        app.To__c = Datetime.newInstance(2050, 1, 3, 1, 1, 1);
        app.FirstApprover__c = UserInfo.getUserId();
        insert app;
        SchedulingPlanController.upsertOnLeave(app.Id,UserInfo.getUserId(),Date.newInstance(2050, 1, 1),Date.newInstance(2050, 1, 3));
        
        SchedulingPlanController.queryTaskPromoterAttendanceRule(new List<String>{rp.Id},Date.newInstance(2050, 1, 1));
        SchedulingPlanController.queryTaskPromoterAttendanceRule(new List<String>{rp.Id},Date.newInstance(2050, 1, 5));
        
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.OwnerId = UserInfo.getUserId();
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today();
        pa.CheckInAddress__c = 'test address';
        pa.SignInTime__c = Time.newInstance(9,30,00,00);
        pa.Check_in_Type__c = 'Onsite';
        pa.Check_in_Status__c = 'Late Check in';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckOutAddress__c = 'test';
        pa.SignOutTime__c = Time.newInstance(18,30,00,00);
        pa.Check_out_Type__c = 'Onsite';
        pa.Check_out_Status__c = 'Check out';
        pa.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(pa.CheckIn_Date__c);
        insert pa;
        Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
        pai.Promoter_Attendance__c = pa.Id;
        pai.Shop__c = shop.Id;
        pai.Address__c = 'WITHOUT_ADDRESS';
        pai.CheckIn_Date__c =  System.today();
        pai.CheckIn_Time__c = Time.newInstance(9,30,00,00);
        insert pai;

        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put(rp.Id, pai.Id);
        SchedulingPlanController.updateTaskStatus(inputMap,Date.newInstance(2050, 1, 1),'checkIn');
    }
}