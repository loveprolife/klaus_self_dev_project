/*
 * @Author: WFC
 * @Date: 2024-12-26 10:12:18
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-26 17:22:52
 * @Description: 样机确认
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayConfirmController.cls
 */
public with sharing class SampleDisplayConfirmController{
    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-25 11:02:05
     * @Description: 获取sample display confrim 列表信息
     */
    @AuraEnabled
    public static List<Map<String, Object>> getSampleDisplayConfirmData(String deviceId){
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // 根据设备信息返回对应的门店id信息
        List<String> storeIdList = getStoreByDeviceId(deviceId);
        List<Sample_Display_Confirm__c> sdcList = [SELECT Id, Sample_Display__r.Name, Name, Product_Model__r.Name, Customer__r.Name, Store__r.Name, Number__c, Status__c, Deadline__c
                                                   FROM Sample_Display_Confirm__c
                                                   WHERE Store__c IN:storeIdList];
        for (Sample_Display_Confirm__c sdc : sdcList){
            Map<String, Object> temp = new Map<String, Object>();
            temp.put('Sample_Display_Code__c', sdc.Sample_Display__r.Name);
            temp.put('Name', sdc.Name);
            temp.put('NameToUrl', System.URL.getOrgDomainUrl().toExternalForm() + '/' + sdc.Id);
            temp.put('Product_Model__c', sdc.Product_Model__r.Name);
            temp.put('Customer__c', sdc.Customer__r.Name);
            temp.put('Store__c', sdc.Store__r.Name);
            temp.put('Number__c', sdc.Number__c);
            temp.put('Status__c', sdc.Status__c);
            temp.put('Deadline__c', sdc.Deadline__c);

            result.add(temp);
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-25 11:02:05
     * @Description: 获取sample removal confirm 列表信息
     */
    @AuraEnabled
    public static List<Map<String, Object>> getSampleRemovalConfirmData(String deviceId){
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        // 根据设备信息返回对应的门店id信息
        List<String> storeIdList = getStoreByDeviceId(deviceId);
        List<Sample_Removal_Confirm__c> sdcList = [SELECT Id, Sample_Removal_Code__r.Name, Name, Product_Model__r.Name, Store__r.Name, Number__c, Status__c, Deadline__c
                                                   FROM Sample_Removal_Confirm__c
                                                   WHERE Store__c IN:storeIdList];
        for (Sample_Removal_Confirm__c sdc : sdcList){
            Map<String, Object> temp = new Map<String, Object>();
            temp.put('Sample_Removal_Code__c', sdc.Sample_Removal_Code__r.Name);
            temp.put('Name', sdc.Name);
            temp.put('NameToUrl', System.URL.getOrgDomainUrl().toExternalForm() + '/' + sdc.Id);
            temp.put('Product_Model__c', sdc.Product_Model__r.Name);
            temp.put('Store__c', sdc.Store__r.Name);
            temp.put('Number__c', sdc.Number__c);
            temp.put('Status__c', sdc.Status__c);
            temp.put('Deadline__c', sdc.Deadline__c);

            result.add(temp);
        }
        return result;
    }

    // 根据设备信息返回对应的门店id信息
    public static List<String> getStoreByDeviceId(String deviceId){
        List<String> storeIdList = new List<String>();
        // 通过设备唯一标识查询SubUser_Device__c表是否存在
        List<SubUser_Device__c> subUserDeviceList = getSubUserDeviceId(deviceId);
        if (subUserDeviceList != null && subUserDeviceList.size() > 0){
            // 获取SubUserDevice
            SubUser_Device__c subUserDevice = subUserDeviceList.get(0);
            // 根据SubUserDevice查询SubUserLog表
            List<SubUserLog__c> subUserLogList = getSubUserLog(subUserDevice.Id);
            // 获取对应的门店
            LisqContainer lc = new LisqContainer(subUserLogList);
            storeIdList = lc.SelectSField('StoreId__c');
        }
        return storeIdList;
    }

    // 根据DeviceID查询SubUserLog
    public static List<SubUserLog__c> getSubUserLog(String deviceId){
        return [SELECT Id, SubUser__c, StoreId__c, StoreId__r.Name, Action_Time__c, DeviceID__c
                FROM SubUserLog__c
                WHERE DeviceID__c = :deviceId];
    }

    // 根据设备信息获取SubUserDevice
    public static List<SubUser_Device__c> getSubUserDeviceId(String deviceId){
        return [SELECT Id, SubUserID__c, DeviceID__c, LastUsedTime__c, IsActive__c
                FROM SubUser_Device__c
                WHERE DeviceID__c = :deviceId];
    }

}