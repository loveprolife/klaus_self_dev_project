public without sharing class AutoCheckOutBatch implements Database.Batchable<sObject> {

    // private Date today = System.today();
    private Date today = getSouthAfricaDate();
    private Boolean isAutoCheckOut = true;

    // 自动签退
    public AutoCheckOutBatch() {}
    // 指定日期签退
    public AutoCheckOutBatch(Date today, Boolean isAutoCheckOut) {
        this.today = today;
        this.isAutoCheckOut = isAutoCheckOut;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Shop_Name__c, Principal__c, Promoter_Attendance_Rule__c, RecordType__c  FROM Responsible_Person__c WHERE Principal__r.Sales_Region__c = \'Hisense South Africa\' AND RecordType__c =\'促销员\' AND Principal__r.IsActive = true ';
        System.debug('AutoCheckOutBatch -> query: ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Responsible_Person__c> scope) {
        System.debug('AutoCheckOutBatch -> today: ' + today);
        System.debug('AutoCheckOutBatch -> isAutoCheckOut: ' + isAutoCheckOut);
        try {
            List<String> ruleIdList = new List<String>();
            List<String> promoterResIdList = new List<String>();
            for (Responsible_Person__c item : scope) {
                promoterResIdList.add(item.Id);
                ruleIdList.add(item.Promoter_Attendance_Rule__c);
            }

            // 考勤规则
            List<Promoter_Attendance_Rule__c> ruleList = [SELECT Id, End_time__c FROM Promoter_Attendance_Rule__c WHERE Id IN :ruleIdList];
            Map<Id, Promoter_Attendance_Rule__c> ruleMap = new Map<Id, Promoter_Attendance_Rule__c>(ruleList);
            System.debug('AutoCheckOutBatch -> ruleList: ' + ruleList.size());

            // 已签到还未签退的考勤记录
            List<Promoter_Attendance__c> attendanceList = [SELECT Id, Shop__c, ExternalId__c, Check_in_Status__c, CreatedBy.Name, Owner.Name, CheckOutShop__c, CheckIn_Date__c, SignOutTime__c, Check_out_Status__c, CheckInStatus__c FROM Promoter_Attendance__c WHERE CheckInStatus__c = '已签到' AND CheckIn_Date__c = :today AND RecordType.Name = '促销员考勤'];
            Map<String, Promoter_Attendance__c> attendanceExternalAndRecordMap = new Map<String, Promoter_Attendance__c>();
            for (Promoter_Attendance__c item : attendanceList) {
                String attExternalStr = item.ExternalId__c.split('_').size() > 2 ? item.ExternalId__c.substringBeforeLast('_') : item.ExternalId__c;
                attendanceExternalAndRecordMap.put(attExternalStr, item);
            }
            System.debug('AutoCheckOutBatch -> attendanceList: ' + attendanceList.size());

            // 排班信息
            List<SchedulingTask__c> scheduledList = [SELECT Id, Check_Out_Attendance_Information__c, Responsible_person__c FROM SchedulingTask__c WHERE Scheduling_Date__c = :today AND Responsible_person__c IN :promoterResIdList];
            Map<String, SchedulingTask__c> promoterIdAndScheduledMap = new Map<String, SchedulingTask__c>();
            for (SchedulingTask__c item : scheduledList) {
                promoterIdAndScheduledMap.put(item.Responsible_person__c, item);
            }
            System.debug('AutoCheckOutBatch -> scheduledList: ' + scheduledList.size());

            List<Promoter_Attendance__c> updateAttendanceList = new List<Promoter_Attendance__c>();
            List<Promoter_Attendance_Information__c> checkOutList = new List<Promoter_Attendance_Information__c>();
            List<SchedulingTask__c> updateScheduledList = new List<SchedulingTask__c>();
            Map<String, Promoter_Attendance_Information__c> promoterIdAndCheckOutRecordMap = new Map<String, Promoter_Attendance_Information__c>();
            Set<String> promoterIdSet = new Set<String>();
            System.debug('AutoCheckOutBatch -> ruleMap: ' + ruleMap);
            System.debug('AutoCheckOutBatch -> attendanceExternalAndRecordMap: ' + attendanceExternalAndRecordMap.keySet());
            for (Responsible_Person__c item : scope) {
                String externalId = item.Principal__c + '_' + String.valueOf(today);
                System.debug('AutoCheckOutBatch -> externalId: ' + externalId);
                if (ruleMap.containsKey(item.Promoter_Attendance_Rule__c) && attendanceExternalAndRecordMap.containsKey(externalId)) {
                    Promoter_Attendance_Rule__c rule = ruleMap.get(item.Promoter_Attendance_Rule__c);
                    Promoter_Attendance__c attendance = attendanceExternalAndRecordMap.get(externalId);
                    // 多门店负责人下避免生成多条签退记录, 自动生成的签退记录门店与签到的门店保持一致
                    if (item.Shop_Name__c != attendance.Shop__c) {
                        System.debug('AutoCheckOutBatch -> store mismatch!');
                        
                        continue;
                    }
                    Time southAfricaTime = getSouthAfricaTime();
                    System.debug('AutoCheckOutBatch -> southAfricaTime: ' + southAfricaTime);
                    System.debug('AutoCheckOutBatch -> rule.End_time__c: ' + rule.End_time__c);
                    // 补签 
                    if (!isAutoCheckOut) {
                        southAfricaTime =  rule.End_time__c;
                    }
                    // 还未到签退时间
                    if ((southAfricaTime < rule.End_time__c) && !Test.isRunningTest()) {
                        System.debug('AutoCheckOutBatch -> Earlier than sign-out time!');

                        continue;
                    }

                    // 更新考勤信息
                    attendance.CheckOutShop__c = item.Shop_Name__c;
                    attendance.CheckIn_Date__c = today;
                    attendance.SignOutTime__c = southAfricaTime;
                    attendance.Check_out_Status__c = 'Check out';
                    if(attendance.CheckInStatus__c == '已签到' || attendance.CheckInStatus__c == '已签到签退'){
                        attendance.CheckInStatus__c = '已签到签退';
                    } else {
                        attendance.CheckInStatus__c = '已签退';
                    }
                    updateAttendanceList.add(attendance);
                    System.debug('AutoCheckOutBatch -> attendance: ' + attendance);

                    // insert签退信息
                    Promoter_Attendance_Information__c checkOutItem = new Promoter_Attendance_Information__c(
                        Promoter_Attendance__c = attendance.Id,
                        Shop__c = item.Shop_Name__c,
                        CheckIn_Date__c = today,
                        CheckIn_Time__c = southAfricaTime,
                        IsSystemAuto__c = true,
                        Type__c = 'Check out',
                        Status__c = 'Check out'
                    );
                    checkOutList.add(checkOutItem);
                    System.debug('AutoCheckOutBatch -> checkOutItem: ' + checkOutItem);

                    // 关联促销员与签退记录, 方便后续更新排班任务上的签退信息
                    promoterIdAndCheckOutRecordMap.put(item.Principal__c, checkOutItem);

                    // 自动签退通知人员
                    promoterIdSet.add(item.Principal__c);
                }
            }
            Database.update(updateAttendanceList);
            Database.insert(checkOutList);

            for (Responsible_Person__c item : scope) {
                if (promoterIdAndScheduledMap.containsKey(item.Id) && promoterIdAndCheckOutRecordMap.containsKey(item.Principal__c)) {
                    SchedulingTask__c scheduledTask = promoterIdAndScheduledMap.get(item.Id);
                    // 更新排班表
                    scheduledTask.Check_Out_Attendance_Information__c = promoterIdAndCheckOutRecordMap.get(item.Principal__c).Id;
                    updateScheduledList.add(scheduledTask);
                    System.debug('AutoCheckOutBatch -> scheduledTask: ' + scheduledTask);
                }
            }
            Database.update(updateScheduledList);

            // 发送自动打卡成功提醒
            System.debug('AutoCheckOutBatch -> promoterIdSet: ' + promoterIdSet);
            sendNotification('Auto Check out Successfully!', 'Thanks for your hard work!', promoterIdSet);
        }
        catch (Exception e) {
            System.debug('AutoCheckOutBatch Error : '+ e.getMessage() + e.getLineNumber());
        } 
    }

    public void finish(Database.BatchableContext bc){

    }


    public static Time getSouthAfricaTime() {
        // Africa/Johannesburg
        Date myDate = System.now().dateGMT();
        Time myTime = System.now().timeGmt();
        DateTime GMTDate = DateTime.newInstanceGMT(myDate, myTime);
        String strConvertedTime = GMTDate.format('yyyy-yy-dd HH:mm:ss:ms', 'Africa/Johannesburg').split(' ')[1];
        System.debug('getSouthAfricaTime -> : ' + GMTDate.format('yyyy-yy-dd HH:mm:ss:ms', 'Asia/Shanghai'));
        System.debug('getSouthAfricaTime -> strConvertedTime: ' + strConvertedTime);
        List<String> timeSplitList = strConvertedTime.split(':');
        Time convertTime = Time.newInstance(Integer.valueOf(timeSplitList[0]), Integer.valueOf(timeSplitList[1]), Integer.valueOf(timeSplitList[2]), Integer.valueOf(timeSplitList[3]));
        System.debug('getSouthAfricaTime -> convertTime: ' + convertTime);

        return convertTime;
    }

    public static Date getSouthAfricaDate() {
        Date myDate = System.now().dateGMT();
        Time myTime = System.now().timeGmt();
        DateTime GMTDate = DateTime.newInstanceGMT(myDate, myTime);
        String strConvertedTime = GMTDate.format('yyyy-MM-dd', 'Africa/Johannesburg');
        System.debug(strConvertedTime);
        System.debug(Date.valueOf(strConvertedTime));

        return Date.valueOf(strConvertedTime);
    }

    public static void sendNotification(String title, String body, Set<String> userIdSet) {

        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        // Set the contents for the delinking notification
        currNotification.setTitle(title);
        currNotification.setBody(body);

        // Set the notification type and target
        currNotification.setNotificationTypeId([SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Custom_Notification'].Id);
        // currNotification.setTargetId('000000000000000AAA');
        // String pageRef = 
        // '' +
        // '{' +
        // '       type: \'standard__navItemPage\',' +
        // '       attributes: {' +
        // '           apiName: \'New_Promoter_Daily_Report\'' +
        // '       }' +
        // '}';
        // currNotification.setTargetPageRef(pageRef);
        
        // Send the notification
        try {
            currNotification.send(userIdSet);
        }
        catch (Exception ex) {
            string msg = 'Notification Failed: ' + ex.getMessage();
            System.debug(msg);
        }
    }
}