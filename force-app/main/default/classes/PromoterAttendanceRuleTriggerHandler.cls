public without sharing class PromoterAttendanceRuleTriggerHandler extends TriggerHandler{

    public override void beforeInsert() {

        for (Promoter_Attendance_Rule__c par : ((list<Promoter_Attendance_Rule__c>)Trigger.new)) {
            String startTime = String.valueOf(par.Start_time__c).substring(0,5);
            String endTime = String.valueOf(par.End_time__c).substring(0,5);

            par.Name = startTime + '-' + endTime;

            if (par.Time_buffer__c != 0 && par.Time_buffer__c != null) {
                String timeBuffer = String.valueOf(par.Time_buffer__c);
                par.Name += ' Buffer-' + timeBuffer + 'min';
            }

            if (par.Distance__c != null) {
                String distance = String.valueOf(par.Distance__c);
                par.Name += ' Distance-' + distance + 'm';
            }

            if (par.Need_Check_Distance__c) {
                par.Name += ' Donot allow off-site check';
            }
            
            par.ExternalId__c = par.Name;
        }
    }

    public override void beforeUpdate() {

        for (Promoter_Attendance_Rule__c par : ((list<Promoter_Attendance_Rule__c>)Trigger.new)) {
            String startTime = String.valueOf(par.Start_time__c).substring(0,5);
            String endTime = String.valueOf(par.End_time__c).substring(0,5);

            par.Name = startTime + '-' + endTime;

            if (par.Time_buffer__c != 0 && par.Time_buffer__c != null) {
                String timeBuffer = String.valueOf(par.Time_buffer__c);
                par.Name += ' Buffer-' + timeBuffer + 'min';
            }

            if (par.Distance__c != null) {
                String distance = String.valueOf(par.Distance__c);
                par.Name += ' Distance-' + distance + 'm';
            }

            if (par.Need_Check_Distance__c) {
                par.Name += ' Donot allow off-site check';
            }

            par.ExternalId__c = par.Name;
        }
    }

    public override void afterUpdate() {

        Map<String, Promoter_Attendance_Rule__c> oldMap = new Map<String, Promoter_Attendance_Rule__c>();
        for (Promoter_Attendance_Rule__c par : ((list<Promoter_Attendance_Rule__c>)Trigger.old)) {
            oldMap.put(par.Id, par);
        }

        System.debug('oldMap--->'+oldMap);
        Set<Id> parIds = new Set<Id>();
        for (Promoter_Attendance_Rule__c par : ((list<Promoter_Attendance_Rule__c>)Trigger.new)) {
            if (par.Name != oldMap.get(par.Id).Name) {
                parIds.add(par.Id);
            }
        }

        List<Responsible_Person__c> rpList = [SELECT 
                                                    Id, 
                                                    Promoter_Attendance_Rule__c, 
                                                    Promoter_Attendance_Rule__r.Name,
                                                    Principal__c, 
                                                    Principal__r.Name, 
                                                    Shop_Name__c, 
                                                    Shop_Name__r.Name 
                                                FROM Responsible_Person__c 
                                                WHERE Promoter_Attendance_Rule__c = : parIds
                                                AND Principal__r.IsActive = true];
        Map<String, Responsible_Person__c> parIdRp = new Map<String, Responsible_Person__c>();

        system.debug('rpList===============>'+rpList);
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName='Custom_Notification'];
        for (Responsible_Person__c rp : rpList) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            String title = rp.Shop_Name__r.Name + ' rule changed';
            String body = rp.Promoter_Attendance_Rule__r.Name;
            Set<String> userIds = new Set<String>();
            userIds.add(rp.Principal__c);

            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(rp.Promoter_Attendance_Rule__c);
            notification.send(userIds);
        }
    }

}