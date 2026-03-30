/**************************************************************************************************
 * SalesTargetButtonHandlerController
 * Purpose:销售目标按钮解锁逻辑
 * Author: Gerry
 * Create Date: 2019-4-18
***************************************************************************************************/
public without sharing class UnlockSalesTarget {
    public static List<Approval.UnlockResult> unLock(List<Sales_Target__c> st){
    	List<Approval.UnlockResult> resultList = Approval.unlock(st,true);
    	return resultList;
    }
}