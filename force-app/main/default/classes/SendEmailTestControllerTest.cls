@isTest
private class SendEmailTestControllerTest {
    static testMethod void testMethod1() {
        Test.startTest(); 
        Date meetingDate = Date.newInstance(2024, 8, 12); 
        Date meetingDate2 = Date.newInstance(2024, 9, 20);
        Time meetingStartTime2 = Time.newInstance(9, 0, 0, 0);
        Time meetingEndTime2 = Time.newInstance(18, 0, 0,0);

        Time meetingStartTime = Time.newInstance(16, 0, 0, 0);
        Time meetingEndTime = Time.newInstance(16, 30, 0,0);
        System.debug('AAAAA');
        ExpoInfo__c exp = new ExpoInfo__c(Name='XXX',TitleEN__c='XXX',LastRegistrationDate__c=meetingDate2);
        insert exp;
        ExpoInfo__c aa = [Select Id from ExpoInfo__c where Name='XXX'];
        Expo_Meeting_Booking_Info__c meetBook = new Expo_Meeting_Booking_Info__c(Name = 'Public Room 1',location__c='AAAA',Exhibition_Management__c=aa.Id,device__c='75 Interactive commercial TV',day_end__c= meetingDate2, day_start__c=meetingDate,time_start__c=meetingStartTime2,time_end__c=meetingEndTime2,access__c=0, capacity__c=0, whiteboard__c=0, computer__c=0);
        insert meetBook;
        Internal_Registration__c reg = new Internal_Registration__c(Name_CN__c = '崔杰',Email__c='zhangqiang1.ex@hx-partners.com',Company_Abbr__c='外部人员\\集团公司\\流程IT与数据管理部外协\\国际营销解决方案部',ContactEmail__c='zhangqiang1.ex@hx-partners.com',CurrencyIsoCode='ARS',Deliverable__c='hcjfb',Exhibition_Id__c=aa.Id, Phone__c='+86-16619728896', Position__c='DDDDDD');
        insert reg;
        List<Expo_Meeting_Booking_Info__c> bookInfo = [Select Id from Expo_Meeting_Booking_Info__c where Name =: 'Public Room 1'];
        List<Internal_Registration__c> inter = [Select Id,Name_CN__c from Internal_Registration__c where Name_CN__c =: '崔杰'];
        Expo_Meeting_Room__c meetRoom = new Expo_Meeting_Room__c(start_time__c=meetingStartTime,end_time__c=meetingEndTime,Name='Test',attendees__c='John Wo,Pan Duo,Yang way, Deo guo',note__c='Hello',Expo_Meeting_Booking_Info__c=bookInfo[0].Id,Internal_Registration__c=inter[0].Id,day__c=meetingDate);  
        Database.insert(meetRoom);
        String roomId = meetRoom.Id;
        String template = 'Meeting Room Reservation Cancelled';
        SendEmailTestController.sendData(roomId, template);
        Test.stopTest();
    }
}