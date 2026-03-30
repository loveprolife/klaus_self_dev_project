public with sharing class UserCalendarController {
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User WHERE IsActive = true ORDER BY Name];
    }
    
    @AuraEnabled
    public static void createEvent(String userId, String eventDate) {
        Event newEvent = new Event(
            Subject = '用户日程',
            OwnerId = userId,
            StartDateTime = DateTime.parse(eventDate + ' 09:00:00'),
            EndDateTime = DateTime.parse(eventDate + ' 17:00:00'),
            IsAllDayEvent = false
        );
        insert newEvent;
    }
}