/**********************************************************************
* Name: InspectionShopPlanSchedule
* Object: Inspection_Shop_Plan__c
* Purpose: Inspection_Shop_Plan__c schedule job
* Author: yong
* Create Date: 2023-06-28
*************************************************************************/
global class InspectionShopPlanSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        creatingNotification();
    }
    //每月最后三天提醒 创建下月巡店计划
    public static void creatingNotification(){
        //获取下月日期
        String year = String.valueOf(Date.today().addMonths(1).year());
        String month = String.valueOf(Date.today().addMonths(1).month());
        //获取所有巡店员及其区域经理关系
        Map<String,String> floorWalkerManagerMap = new Map<String,String>();
        List<String> floorWalkerRole = new List<String>{'ID_Floorwalker','CL_Floorwalker','SA_Blitz_Field_Reps'};
        Map<String,User> floorWalkerMap = new Map<String,User>([SELECT Id,Name,UserRoleId,UserRole.Name,managerId FROM User WHERE UserRole.DeveloperName IN: floorWalkerRole]);
        for(User floorWalker : floorWalkerMap.values()){
            floorWalkerManagerMap.put(floorWalker.Id,floorWalker.managerId);
        }
        //根据所有巡店员id,及日期搜索已存在巡店计划
        List<Inspection_Shop_Plan__c> ispList = [SELECT Id,Name ,OwnerId
                                                    FROM Inspection_Shop_Plan__c 
                                                    WHERE Inspection_Year__c =: year 
                                                        AND Inspection_Month__c =: month 
                                                        AND OwnerId IN: floorWalkerManagerMap.keySet()];
        //循环巡店计划，筛选出未创建巡店计划的巡店员
        List<String> ownerIdList = new List<String>();
        for(Inspection_Shop_Plan__c isp:ispList){
            ownerIdList.add(isp.OwnerId);
        }
        //发送通知
        CustomNotificationType TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Custom_Notification'];
        for(String floorwalkerId : floorWalkerManagerMap.keySet()){
            if(!ownerIdList.contains(floorwalkerId)){
                String title = System.label.InspectionShopPlanScheduleNotificationTitle;//Inspection Shop Plan Creating Reminder
                // String body = 'You don\'t make next month plan yet' ;
                String body = floorWalkerMap.get(floorwalkerId).Name + System.label.InspectionShopPlanScheduleNotificationBody ;//don\'t make next month plan yet
                Set<String> receiveUserIdSet = new Set<String>();
                // receiveUserIdSet.add(UserInfo.getUserId());
                receiveUserIdSet.add(floorwalkerId);
                receiveUserIdSet.add(floorWalkerManagerMap.get(floorwalkerId));
                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle(title);
                currNotification.setBody(body);
                currNotification.setNotificationTypeId(TemplateInfoDetail.Id);
                currNotification.setTargetId('000000000000000AAA');
                
                currNotification.send(receiveUserIdSet);
            }
        }
        
    }
}