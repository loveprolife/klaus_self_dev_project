/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class CheckInCheckOutService {
    public static List<List<sObject>> getShopList(String searchInfo) {
        return [
                FIND 
                    :searchInfo 
                IN 
                    ALL FIELDS 
                RETURNING 
                    Shop__c(
                        Id,
                        Name,
                        Account__c,
                        Account__r.Name,
                        Shop_Center_Location__c WHERE isLocationEmpty__c = false LIMIT 100 )
        ];
    }

    //获取签到签退时门店经纬度信息
    public static Shop__c getShopItem(String storeId) {
        return [SELECT 
                    Id,
                    Shop_Center_Location__c
                FROM Shop__c 
                WHERE 
                    Id =: storeId];
    }

    //创建巡店任务
    public static void createInspectionShopTask(String shopId) {
        List<Inspection_Shop_Task__c> istList = CheckInCheckOutController.getShopTaskList(CheckInCheckOutController.thisDay, UserInfo.getUserId() , shopId);
        
        //判断是不是内部会议门店
        List<Shop__c> currentShopList = [SELECT Id,Name FROM Shop__c WHERE Id = :shopId];
        if (!currentShopList.isEmpty() && currentShopList[0].Name == 'その他(Web会議等)') {
            // currentShopList[0].Name = 'その他(Web会議等)';
            return;
        }
            
        if(istList.size() <= 0) {
            //若该巡店任务不存在，则需要额外创建
            Inspection_Shop_Task__c istItem = new Inspection_Shop_Task__c();   
            List<Inspection_Shop_Plan__c> ispList = CheckInCheckOutController.getPlan(String.valueOf(CheckInCheckOutController.thisDay.year()) , String.valueOf(CheckInCheckOutController.thisDay.month()), UserInfo.getUserId());
            Inspection_Shop_Plan__c ispItem;
            if(ispList.size() > 0){
                ispItem = ispList[0];
            }else{
                ispItem = new Inspection_Shop_Plan__c();
                ispItem.Inspection_Year__c = String.valueOf(CheckInCheckOutController.thisDay.year());
                ispItem.Inspection_Month__c = String.valueOf(CheckInCheckOutController.thisDay.month());
                insert ispItem;
            }

            istItem.Shop__c = shopId;
            istItem.Inspection_Date__c = CheckInCheckOutController.thisDay;
            istItem.Status__c = CheckInCheckOutController.NOT_PLAN_ATTENDANCE;
            istItem.Inspection_Plan__c = ispItem.Id;
            insert istItem;
        }
    }

    public static void createPromoterAttendance(Promoter_Attendance__c paItem) {
        upsert paItem ExternalId__c;
    }

    public static void autoSaveResponsiblePerson(String storeId, String userId) {
        List<Responsible_Person__c> rpList = [SELECT Id,Shop_Name__c,Principal__c 
                                                FROM Responsible_Person__c 
                                                WHERE Shop_Name__c =:storeId 
                                                AND RecordType__c = '巡店员'];                                  
        if(rpList == null || rpList.size() == 0){
            if(!Label.Special_Shop_Ids.split(',').contains(storeId)){   
                Responsible_Person__c rp = new Responsible_Person__c();
                rp.Shop_Name__c = storeId;
                rp.Principal__c = userId;
                rp.RecordType__c = '巡店员';
                insert rp;
            }       
        }
    }
}