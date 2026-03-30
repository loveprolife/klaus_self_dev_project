@isTest
public class CheckOutTrainProductAttendanceTest {

    @isTest
    static void testMethod1(){

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        Promoter_Attendance__c attendance = new Promoter_Attendance__c();
        attendance.Customer__c = acc.Id;
        attendance.Trainer__c = 'test';
        Insert attendance;

        CheckOutTrainProductAttendance.getTrainAttendance(attendance.Id);
    }
}