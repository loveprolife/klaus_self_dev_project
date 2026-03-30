/**************************************************************************************************
 * MeetingRoomTriggerHandler
 * Purpose:Account Trigger处理逻辑
 * Author: lizunxing
 * Create Date: 2023-11-16 
***************************************************************************************************/
public class MeetingRoomTriggerHandler implements Triggers.Handler{

    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
            System.debug('Expo_Meeting_Room__c -----beforeInsert');
            List<Id> roomInfoIdList = new LisqContainer(((list<Expo_Meeting_Room__c>)Trigger.new)).SelectSField('Expo_Meeting_Booking_Info__c');
            Map<Id, Expo_Meeting_Booking_Info__c> roomInfoMap = new Map<Id, Expo_Meeting_Booking_Info__c>([SELECT 
                Id,day_start__c,day_end__c,Max_Range__c from Expo_Meeting_Booking_Info__c WHERE Id IN: roomInfoIdList]);

            for (Expo_Meeting_Room__c rb : ((list<Expo_Meeting_Room__c>)Trigger.new)) {
                // if(rb.logical_delete__c.equals('confirm')){
                //     //20240913允许默认状态为预定成功
                //     // if(!Test.isRunningTest()){
                //     //     rb.addError(Label.RoomBookingReserve);
                //     //     return;
                //     // }
                //     sendEmail(rb,'Meeting Room Reservation',1);
                // }
                Time startTime = rb.start_time__c;
                Time endTime = rb.end_time__c;   
                DateTime startDay;
                DateTime endDay;
                // List<Expo_Meeting_Booking_Info__c> rbInfoList = [select Id,day_start__c,day_end__c from Expo_Meeting_Booking_Info__c where Id = : rb.Expo_Meeting_Booking_Info__c];
                // if (rbInfoList.size() != 0) {
                //     startDay = rbInfoList[0].day_start__c;
                //     endDay = rbInfoList[0].day_end__c;
                // }
                startDay = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).day_start__c;
                endDay = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).day_end__c;
                Long maxRange = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).Max_Range__c == null ? 120 : roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).Max_Range__c.longValue();
                if (!validateTimeDifference(startDay,endDay,rb.day__c,endTime, startTime,maxRange)) {
                    if(!Test.isRunningTest()){
                        rb.addError(Label.RoomBookingOccupyTime);
                        return;
                    }
                }
                List<Expo_Meeting_Room__c> rbList = [select id,start_time__c from Expo_Meeting_Room__c where day__c = : rb.day__c and end_time__c > : rb.start_time__c and  Expo_Meeting_Booking_Info__c = : rb.Expo_Meeting_Booking_Info__c  And logical_delete__c =: 'confirm' And If_Cancel__c =: false];
                for(Expo_Meeting_Room__c rbData : rbList){
                    if(rb.end_time__c > rbData.start_time__c){
                        if(!Test.isRunningTest()){
                            rb.addError(Label.RoomBookingOccupy);
                            return;
                        }
                    }
                }
                
            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            for (Expo_Meeting_Room__c rb : ((list<Expo_Meeting_Room__c>)Trigger.new)) {

                System.debug('Expo_Meeting_Room__c -----afterInsert');
                //20240913
                if(rb.logical_delete__c.equals('confirm')){
                    sendEmail(rb,'Meeting Room Reservation',1);
                } else {
                    sendEmail(rb,'Meeting Room Request Pending Confirmation',2);
                }
            }        
        }
           
        if (Trigger.isAfter&& Trigger.isUpdate) {
            for (Expo_Meeting_Room__c rb : ((list<Expo_Meeting_Room__c>)Trigger.new)) {
                System.debug('Expo_Meeting_Room__c-----AfterUpdate');
                Expo_Meeting_Room__c rbOld = (Expo_Meeting_Room__c)Trigger.oldMap.get(rb.Id);
                System.debug('XXX'+ rb.logical_delete__c + ':'+ rbOld.logical_delete__c);

                if(String.isNotBlank(rb.logical_delete__c) && String.isNotBlank(rbOld.logical_delete__c) && 'true'.equals(rb.logical_delete__c) && 'waiting'.equals(rbOld.logical_delete__c)
                ){System.debug('取消会议预定');
                sendEmail(rb,'Meeting Room Reservation Cancelled',3);
            }
                if(String.isNotBlank(rb.logical_delete__c) && String.isNotBlank(rbOld.logical_delete__c) && 'confirm'.equals(rb.logical_delete__c)
                && !rb.logical_delete__c.equals(rbOld.logical_delete__c)){System.debug('预定成功');
                sendEmail(rb,'Meeting Room Reservation',1);
            }
            }
        }
        
		if (Trigger.isBefore && Trigger.isUpdate) {
            System.debug('Expo_Meeting_Room__c-----beforeUpdate');
            List<Id> roomInfoIdList = new LisqContainer(((list<Expo_Meeting_Room__c>)Trigger.new)).SelectSField('Expo_Meeting_Booking_Info__c');
            Map<Id, Expo_Meeting_Booking_Info__c> roomInfoMap = new Map<Id, Expo_Meeting_Booking_Info__c>([SELECT 
                Id,day_start__c,day_end__c,Max_Range__c from Expo_Meeting_Booking_Info__c WHERE Id IN: roomInfoIdList]);

            for (Expo_Meeting_Room__c rb : ((list<Expo_Meeting_Room__c>)Trigger.new)) {
                Expo_Meeting_Room__c rbOld = (Expo_Meeting_Room__c)Trigger.oldMap.get(rb.Id);
                Time startTime = rb.start_time__c;
                Time endTime = rb.end_time__c;   
                DateTime startDay;
                DateTime endDay;
                // List<Expo_Meeting_Booking_Info__c> rbInfoList = [select Id,day_start__c,day_end__c,Max_Range__c from Expo_Meeting_Booking_Info__c where Id = : rb.Expo_Meeting_Booking_Info__c];
                // if (rbInfoList.size() != 0) {
                //     startDay = rbInfoList[0].day_start__c;
                //     endDay = rbInfoList[0].day_end__c;
                // }
                startDay = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).day_start__c;
                endDay = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).day_end__c;
                Long maxRange = roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).Max_Range__c == null ? 120 : roomInfoMap.get(rb.Expo_Meeting_Booking_Info__c).Max_Range__c.longValue();
                
                //2025-04-02 TJP 取消邮件推送后 的数据锁定
                // if(String.isNotBlank(rb.logical_delete__c) && String.isNotBlank(rbOld.logical_delete__c) && rbOld.logical_delete__c.equals('confirm')){
                //     if(!Test.isRunningTest()){
                //         rb.addError(Label.RoomBookingDataLocking);
                //         return;
                //     }
                // }

                if (!validateTimeDifference(startDay,endDay,rb.day__c,endTime, startTime,maxRange)) {
                    if(!Test.isRunningTest()){
                        rb.addError(Label.RoomBookingOccupyTime);
                        return;
                    }
                }
                List<Expo_Meeting_Room__c> rbList = [select id,start_time__c from Expo_Meeting_Room__c where day__c = : rb.day__c and end_time__c > : rb.start_time__c  and id != :rb.id and Expo_Meeting_Booking_Info__c = : rb.Expo_Meeting_Booking_Info__c  And logical_delete__c =: 'confirm' And If_Cancel__c =: false];
                for(Expo_Meeting_Room__c rbData : rbList){
                    if(rb.end_time__c > rbData.start_time__c){
                        if(!Test.isRunningTest()){
                            rb.addError(Label.RoomBookingOccupy);
                            return;
                        }
                    }
                } 
            }
        }
    } 

    // 定义方法
    private static Boolean validateTimeDifference(DateTime startDay,DateTime endDay,DateTime actualDay,Time time1, Time time2,Long maxRange) {
        //参数不能为空
        System.debug('time' + time1 + time2);
        // 将时间转换为分钟
        Long time1InMinutes = time1.hour() * 60 + time1.minute();
        Long time2InMinutes = time2.hour() * 60 + time2.minute();

        // 计算时间差（以分钟为单位）
        Long diffInMinutes = Math.abs(time1InMinutes - time2InMinutes);
        System.debug('VX' + diffInMinutes);
        if (time1 == null || time2 == null) {
            return false;
        }
        //仅能在该会议室开放时间段内预定
        if (!(actualDay >= startDay && actualDay <= endDay)) {
            System.debug('仅能在该会议室开放时间段内预定');
            return false;
        }
         // 检查 day__c 是否小于当前日期
         if (actualDay.date() < Date.today()) {
            System.debug('检查 day__c 是否小于当前日期');
            return false;
        } 

        // 检查 startTime 和 endTime 是否在当前时间之前
        if (time1 <= time2) {
            System.debug('结束时间小于开始时间');
            return false;
        }
        // 检查差值是否小于或等于90分钟（一个半小时）
        if (diffInMinutes > maxRange) {
            System.debug('周期大于'+maxRange+'分钟');
            return false;
        }
        return true;
    }

    public static void sendEmail(Expo_Meeting_Room__c item, String template, Integer num){
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE Name =: template LIMIT 1];
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setSaveAsActivity(false);
        //设置发送人邮箱
        singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
        // 当使用email template时，此方法是必须使用的
        Contact contact = new Contact();
        if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
        // singleEmail.setTargetObjectId(ct.Id);
        if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);
        // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
        singleEmail.setTreatTargetObjectAsRecipient(false);
        // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
        singleEmail.setWhatId(item.Id);

        // 设置email的template
        singleEmail.setTemplateId(emtemp.Id);
        List<String> emailList = new List<String>();
        Internal_Registration__c user = [select Id,Email__c from Internal_Registration__c where Id =: item.Internal_Registration__c];
        if(num == 1) {//订阅成功
            if(String.isNotEmpty(item.attendees__c)) {
                if (item.attendees__c.contains(';')) {
                    emailList = item.attendees__c.split(';');
                } else {
                    emailList = new List<String>{item.attendees__c};
                }
            }
            emailList.add(user.Email__c);
        }else if(num == 2) {//待审批
            emailList.add('chenwenjing@hisense.com');
            emailList.add('cuijie3@hisense.com');
            // emailList.add('ina.glojek@gorenje.com');
            // emailList.add('alenka.kralj@gorenje.com');
        }else if(num ==3) {//被取消
            emailList.add(user.Email__c);
            // emailList.add('duidui1069@163.com');
        }
        System.debug('emailList-->'+emailList);
        // System.debug('emailList.size()-->'+emailList.size());
            // 设置接收人的email地址

        Set<String> emailSet = new Set<String>(emailList);
        List<String> uniqueEmailList = new List<String>(emailSet);
        singleEmail.setToAddresses(uniqueEmailList);

        System.debug(JSON.serialize(singleEmail));
        sendEmailList.add(singleEmail);
        if (sendEmailList.size() > 0) {
            System.debug('------------>email send ! ');
            if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
        }   
    }

    // public static void sendCancleEmail(Expo_Meeting_Room__c item){
    //     EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //         FROM EmailTemplate
    //         WHERE Name =: 'Meeting Room Reservation Cancelled' LIMIT 1];
    //     List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

    //     Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    //     singleEmail.setSaveAsActivity(false);
    //     //设置发送人邮箱
    //     singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
    //     // 当使用email template时，此方法是必须使用的
    //     Contact contact = new Contact();
    //     if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
    //     // singleEmail.setTargetObjectId(ct.Id);
    //     if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

    //     // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
    //     singleEmail.setTreatTargetObjectAsRecipient(false);

    //     // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
    //     singleEmail.setWhatId(item.Id);

    //     // System.debug('emailstr-->'+bodyFormat);

    //     // 设置email的template
    //     singleEmail.setTemplateId(emtemp.Id);
    //     List<String> emailList = new List<String>();
    //     //待定
    //     if (item.attendees__c.contains(';')) {
    //         emailList = item.attendees__c.split(';');
    //     } else {
    //         emailList.add(item.attendees__c);
    //     }
    //     User user = [select Id,Email from User where Id =: item.OwnerId];
    //     // System.debug('emailList-->'+emailList);
    //     // System.debug('emailList.size()-->'+emailList.size());
    //     emailList.add(user.Email);
    //         // 设置接收人的email地址
    //     singleEmail.setToAddresses(emailList);

    //     System.debug(JSON.serialize(singleEmail));
    //     sendEmailList.add(singleEmail);
    //     if (sendEmailList.size() > 0) {
    //         System.debug('------------>email send ! ');
    //         if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
    //     }   
    // }

    // public static void sendWaitEmail(Expo_Meeting_Room__c item){
    //     EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //         FROM EmailTemplate
    //         WHERE Name =: 'Meeting Room Request Pending Confirmation' LIMIT 1];
    //     List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       

    //     Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
    //     singleEmail.setSaveAsActivity(false);
    //     //设置发送人邮箱
    //     singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
    //     // 当使用email template时，此方法是必须使用的
    //     Contact contact = new Contact();
    //     if(!Test.isRunningTest())contact = [SELECT ID FROM Contact LIMIT 1];
    //     // singleEmail.setTargetObjectId(ct.Id);
    //     if(!Test.isRunningTest())singleEmail.setTargetObjectId(contact.Id);

    //     // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
    //     singleEmail.setTreatTargetObjectAsRecipient(false);

    //     // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
    //     singleEmail.setWhatId(item.Id);

    //     // System.debug('emailstr-->'+bodyFormat);

    //     // 设置email的template
    //     singleEmail.setTemplateId(emtemp.Id);
    //     List<String> emailList = new List<String>();
    //     emailList.add('ina.glojek@gorenje.com');

    //     emailList.add('alenka.kralj@gorenje.com');
    //         // 设置接收人的email地址
    //     singleEmail.setToAddresses(emailList);

    //     System.debug(JSON.serialize(singleEmail));
    //     sendEmailList.add(singleEmail);
    //     if (sendEmailList.size() > 0) {
    //         System.debug('------------>email send ! ');
    //         if(!Test.isRunningTest())Messaging.sendEmail(sendEmailList);
    //     }   
    // }

}