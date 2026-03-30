/*
 * @Author: WFC
 * @Date: 2022-10-13 16:58:52
 * @LastEditors: WFC
 * @LastEditTime: 2023-08-17 09:34:17
 * @Description: 星星评级处理
 * @FilePath: \Hitest_2022\force-app\main\default\classes\StarRatingController.cls
 */
public without sharing class StarRatingController {

    @AuraEnabled
	public static String initData(String dataId) {
        Id cid= Id.valueOf(dataId);
        //获取对象的API名称
        String objectName = cid.getSObjectType().getDescribe().getName();
        String sql = 'SELECT Rating__c FROM ' + objectName + ' WHERE Id = :dataId  LIMIT 1';
        Sobject sObj = Database.query(sql);
        return String.valueOf(sObj.get('Rating__c'));
	}

    @AuraEnabled
	public static Boolean updateRating(String dataId, String ratingValue, String oldRatingValue) {
        Id cid= Id.valueOf(dataId);
        //获取对象的API名称
        String objectName = cid.getSObjectType().getDescribe().getName();
        SObject sObj = (SObject)Type.forName(objectName).newInstance();
        sObj.Id = dataId;
        System.debug('wwww--' + ratingValue);
        System.debug('wwww--' + oldRatingValue);
        if(ratingValue != oldRatingValue){
            sObj.put('Rating__c', ratingValue);
        }else {
            sObj.put('Rating__c', '0');
        }
       
        //忽略触发器更新
        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'StarRating-' + objectName);
        if(!Test.isRunningTest()){
            update sObj;
        }
        //恢复触发器
        Utility.IgnoreAction(false,false,false,'');
        return true;
    }
    
}