/*
 * @Author: WFC
 * @Date: 2023-10-26 17:03:52
 * @LastEditors: WFC
 * @LastEditTime: 2023-12-08 18:29:43
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\InsertDailySalesQueueable.cls
 */
public class InsertDailySalesQueueable implements Queueable {

    public static User currentUser = [SELECT Id,Sales_Region__c FROM User WHERE Id =:UserInfo.getUserId()]; 
    
    private List<Promoter_Daily_Report__c> addReportList;
    private Map<String,List<Retail_Number__c>> tempMap;
    
    public InsertDailySalesQueueable (List<Promoter_Daily_Report__c> addReportList, Map<String,List<Retail_Number__c>> tempMap) {
        this.addReportList = addReportList;
        this.tempMap = tempMap;
    }

    public void execute(QueueableContext context) {
        system.Debug('======== addReportList ===' + addReportList.size());
        Database.Upsert(addReportList, Promoter_Daily_Report__c.Fields.ExternalId__c, true);
        List<Retail_Number__c> addList = new List<Retail_Number__c>();
        //进行关联
        for (Promoter_Daily_Report__c pdr : addReportList) {
            String key = '';
            if(pdr.Shop__c != null){
                key = pdr.Shop__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c;
            }else {
                key = pdr.Customer__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c;
            }
            if(tempMap.get(key) != null){
                for (Retail_Number__c rn : tempMap.get(key)) {
                    rn.PromoterDailyReport__c = pdr.Id;
                    addList.add(rn);
                }
            }
        }
        system.Debug('======== addList ===' + addList.size());
        Database.insert(addList);
    }   
}