/**************************************************************************************************
 * SalesTargetButtonHandlerController
 * Purpose:销售目标按钮逻辑处理
 * Author: Gerry
 * Create Date: 2019-4-18
***************************************************************************************************/
global with sharing class SalesTargetButtonHandlerController {

	public class ReturnResult{
		public String code;
		public String msg;
	}
    
    @AuraEnabled 
    //锁定纪录
    public static String lockRecord(String salesTargetTitleId){
    	ReturnResult result = new ReturnResult();
    	result.code = '0';
    	result.msg = Label.Lock_SalesTarget_Sucess;
    	//没有被锁定的纪录
    	List<Sales_Target__c> notLockedSales = new List<Sales_Target__c>();
    	//查询出头下面的所有行
    	List<Sales_Target__c> salesTargetList = [SELECT Id,Sales_Target_Title__c FROM Sales_Target__c WHERE Sales_Target_Title__c=:salesTargetTitleId];
    	System.debug('salesTargetList:'+salesTargetList);
        if (salesTargetList==null||salesTargetList.size()==0) {
    		result.code = '1';
    		result.msg = Label.Lock_SalesTarget_No_SalesTarget_Lock;
    		return JSON.serialize(result);
    	}
    	for (Sales_Target__c salesTarget : salesTargetList) {
    		if (!Approval.isLocked(salesTarget.Id)) {
    			notLockedSales.add(salesTarget);
    		}
    	}
        //判断是否已经锁定
    	if (notLockedSales.size()==0) {
    		result.code = '1';
    		result.msg = Label.Lock_SalesTarget_Locked_Record;
    		return JSON.serialize(result);
    	}
        for (Sales_Target__c st : notLockedSales) {
            st.Lock__c = 'False';
        }
        Database.update(notLockedSales);
    	List<Approval.LockResult> resultList = Approval.lock(notLockedSales,true);
    	for (Approval.LockResult lr : resultList) {
    		if (!lr.isSuccess()) {
    			result.code = '1';
    			result.msg = Label.Lock_SalesTarget_API_Error;
    			return JSON.serialize(result);
    		}
    	}
    	return JSON.serialize(result);
    }

    @AuraEnabled 
    //解锁纪录
    public static String unlockRecord(String salesTargetTitleId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = Label.Unlock_SalesTarget_Sucess;
        //被锁定的纪录
        List<Sales_Target__c> lockedSales = new List<Sales_Target__c>();
        //查询出头下面的所有行
        List<Sales_Target__c> salesTargetList = [SELECT Id,Sales_Target_Title__c FROM Sales_Target__c WHERE Sales_Target_Title__c=:salesTargetTitleId];
        System.debug('salesTargetList:'+salesTargetList);
        if (salesTargetList==null||salesTargetList.size()==0) {
            result.code = '1';
            result.msg = Label.Unlock_SalesTarget_No_SalesTarget_Unock;
            return JSON.serialize(result);
        }
        for (Sales_Target__c salesTarget : salesTargetList) {
            if (Approval.isLocked(salesTarget.Id)) {
                lockedSales.add(salesTarget);
            }
        }
        //判断纪录是否解锁
        if (lockedSales.size()==0) {
            result.code = '1';
            result.msg = Label.Unlock_SalesTarget_Unlocked_SalesTarget;
            return JSON.serialize(result);
        }
        List<Approval.UnlockResult> resultList = UnlockSalesTarget.unLock(lockedSales);
        for (Approval.UnlockResult ur : resultList) {
            if (!ur.isSuccess()) {
                result.code = '1';
                result.msg = Label.Unlock_SalesTarget_API_Error;
                return JSON.serialize(result);
            }
        }
        return JSON.serialize(result);
    }
}