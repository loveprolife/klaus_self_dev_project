@isTest
public class RoomBookControllerTest {
    @TestSetup
    static void makeData(){
        Date meetingDate = Date.newInstance(2025, 3, 12); 
        Date meetingDate2 = Date.newInstance(2025, 3, 20);
        Time meetingStartTime2 = Time.newInstance(9, 0, 0, 0);
        Time meetingEndTime2 = Time.newInstance(18, 0, 0,0);

        Time meetingStartTime = Time.newInstance(14, 0, 0, 0);
        Time meetingEndTime = Time.newInstance(14, 30, 0,0);
        System.debug('AAAAA');
        ExpoInfo__c exp = new ExpoInfo__c(Name='XXX',TitleEN__c='XXX',LastRegistrationDate__c=meetingDate2);
        insert exp;
        Expo_Meeting_Booking_Info__c meetBook = new Expo_Meeting_Booking_Info__c(Name = 'Public Room 1',location__c='AAAA',Exhibition_Management__c=exp.Id,device__c='75 Interactive commercial TV',day_end__c= meetingDate2, day_start__c=meetingDate,time_start__c=meetingStartTime2,time_end__c=meetingEndTime2,access__c=0, capacity__c=0, whiteboard__c=0, computer__c=0);
        insert meetBook;
        Internal_Registration__c reg = new Internal_Registration__c(Name_CN__c = '崔杰',Email__c='zhangqiang1.ex@hx-partners.com',Company_Abbr__c='外部人员\\集团公司\\流程IT与数据管理部外协\\国际营销解决方案部',ContactEmail__c='zhangqiang1.ex@hx-partners.com',CurrencyIsoCode='ARS',Deliverable__c='hcjfb',Exhibition_Id__c=exp.Id, Phone__c='+86-16619728896', Position__c='DDDDDD');
        insert reg;
        // insert reg;
        List<Expo_Meeting_Booking_Info__c> bookInfo = [Select Id from Expo_Meeting_Booking_Info__c where Name =: 'Public Room 1'];
        List<Internal_Registration__c> inter = [Select Id,Name_CN__c from Internal_Registration__c where Name_CN__c =: '崔杰'];
        Expo_Meeting_Room__c meetRoom = new Expo_Meeting_Room__c(Name='Test',start_time__c=meetingStartTime,end_time__c=meetingEndTime,attendees__c='John Wo,Pan Duo,Yang way, Deo guo',note__c='Hello',Expo_Meeting_Booking_Info__c=bookInfo[0].Id,Internal_Registration__c=inter[0].Id,day__c=meetingDate);  
        insert meetRoom;
    }
    @isTest static void getRoomTest() {
        RoomBookControllerTest.makeData();
        Test.startTest();
        List<Expo_Meeting_Booking_Info__c> mr = RoomBookController.getRoom() ;
        Test.stopTest();
        // Assert.areEqual(2, mr.size(),'Test wrong');

    }
    @isTest static void getBookingTest() {
        RoomBookControllerTest.makeData();
        Test.startTest();
        List<Expo_Meeting_Room__c>  rb = RoomBookController.getBooking() ;
        Test.stopTest();
        // Assert.areEqual(2, rb.size(),'Test wrong');

    }
}