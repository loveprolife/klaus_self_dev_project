/**************************************************************************************************
 * Name: NewCheckInCheckOutAutoController
 * Object: Internal_Registration__c
 * Purpose: 系统自动check in/check out  自动打卡最近门店；进入首页到打卡时间系统没有考勤主数据创建并系统自动签到，如果已有签到则无需再次自动签到；签退到点肯定有一条。
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-11-13         Created        
 
***************************************************************************************************/
public without sharing class NewCheckInCheckOutAutoController {

     /**
     * @description 初始化考勤信息页面
     * @param   lati        维度
     * @param   lng         经度
     * @return
     */
    @AuraEnabled(cacheable=false)
    public static NewCheckInCheckOutController.ReturnData initStoreInfo(String lati, String lng) {
        NewCheckInCheckOutController.ReturnData rd = null;
        
        // 当前用户信息, 仅南非有自动签退
        User currentUser = [SELECT Id, Sales_Region__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (currentUser.Sales_Region__c == 'Hisense South Africa') {

            return NewCheckInCheckOutController.initStoreInfo(lati, lng);
        }
        
        return rd;
    }

    /**
     * @description 自动checkin
     * @param   curStatus   状态
     * @param   storeId     门店id
     * @param   lati        维度
     * @param   lng         经度
     * @param   device      设备信息
     * @param   addressStr  地址
     * @param   remark      备注
     * @param   photoStream 照片
     * @param   navigatorInfo   
     * @return
     */
	@AuraEnabled(cacheable=false)
    public static NewCheckInCheckOutController.ReturnData checkIn(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo) {
        return NewCheckInCheckOutController.checkInCore(curStatus, storeId, lati, lng, device, addressStr, remark, photoStream, navigatorInfo, true);
    }

    /**
     * @description 自动checkout
     * @param   curStatus   状态
     * @param   storeId     门店id
     * @param   lati        维度
     * @param   lng         经度
     * @param   device      设备信息
     * @param   addressStr  地址
     * @param   remark      备注
     * @param   photoStream 照片
     * @param   navigatorInfo   
     * @return
     */
    @AuraEnabled(cacheable=false)
    public static NewCheckInCheckOutController.ReturnData checkOut(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo) {
        return NewCheckInCheckOutController.checkOutCore(curStatus, storeId, lati, lng, device, addressStr, remark, photoStream, navigatorInfo, true);
    }
}