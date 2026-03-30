public without sharing class PromoterDailyReportHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            for (Promoter_Daily_Report__c pdrItem : (List<Promoter_Daily_Report__c>)Trigger.new ){

                // 根据虚拟问题拼接唯一值 YYL 20250313
                if (pdrItem.ExternalId__c == null){
                    if (pdrItem.SubUser__c != null){
                        pdrItem.ExternalId__c = pdrItem.Shop__c + '_' + pdrItem.OwnerId + '_' + pdrItem.SubUser__c + '_' + pdrItem.Report_Date__c;
                    } else{
                        pdrItem.ExternalId__c = pdrItem.Shop__c + '_' + pdrItem.OwnerId + '_' + pdrItem.Report_Date__c;
                    }
                }

                // // 外键逻辑剔除掉泰国 YYL
                // Shop__c shop = [SELECT Id,Name,Sales_Region__c FROM Shop__c WHERE Id =:pdrItem.Shop__c];
                // if(shop.Sales_Region__c == 'Hisense Thailand'){
                //     if(pdrItem.ExternalId_Thailand__c == null){
                //         pdrItem.ExternalId_Thailand__c = pdrItem.Shop__c + '_' + pdrItem.OwnerId + '_' + pdrItem.SubUser__c + '_' + pdrItem.Report_Date__c;
                //     }
                // }else{
                //     if(pdrItem.ExternalId__c == null){
                //         pdrItem.ExternalId__c = pdrItem.Shop__c + '_' + pdrItem.OwnerId + '_' + pdrItem.Report_Date__c;
                //     }
                // }
            }
        }

        if (Trigger.isAfter && Trigger.isInsert){
            List<Promoter_Daily_Report__Share> addList = new List<Promoter_Daily_Report__Share>();
            Set<String> shopIdSet = new Set<String>();
            Map<String, List<Promoter_Daily_Report__c>> pdrMap = new Map<String, List<Promoter_Daily_Report__c>>();
            for (Promoter_Daily_Report__c pdrItem : (List<Promoter_Daily_Report__c>)Trigger.new ){
                shopIdSet.add(pdrItem.Shop__c);
                if (pdrMap.containsKey(pdrItem.Shop__c)){
                    pdrMap.get(pdrItem.Shop__c).add(pdrItem);
                } else{
                    pdrMap.put(pdrItem.Shop__c, new List<Promoter_Daily_Report__c>{ pdrItem });
                }
            }
            // 查询岗位配置的门店关系
            List<Position_Permissions__c> ppList = [SELECT Id, Position__r.GroupId__c, Shop__c
                                                    FROM Position_Permissions__c
                                                    WHERE Shop__c IN:shopIdSet];

            if (!ppList.isEmpty()){
                for (Position_Permissions__c pp : ppList){
                    List<Promoter_Daily_Report__c> haveReportList = pdrMap.get(pp.Shop__c);
                    for (Promoter_Daily_Report__c temp : haveReportList){
                        Promoter_Daily_Report__Share pdrShare = new Promoter_Daily_Report__Share();
                        pdrShare.RowCause = 'Special_Share__c';
                        pdrShare.ParentId = temp.Id;
                        pdrShare.UserOrGroupId = pp.Position__r.GroupId__c;
                        pdrShare.AccessLevel = 'Read';

                        addList.add(pdrShare);
                    }
                }
            }
            if (!addList.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new AsyncSyncShareReport(addList));
            }
        }
    }

    // 异步调用接口同步ECSS扫描数据到库表
    public class AsyncSyncShareReport implements Queueable, Database.AllowsCallouts{
        public List<Promoter_Daily_Report__Share> shareReportList{ get; set; }

        public AsyncSyncShareReport(List<Promoter_Daily_Report__Share> shareList){
            shareReportList = shareList;
        }

        public void execute(QueueableContext context){
            Database.insert (shareReportList, true);
        }

    }

    /*
     public override void beforeInsert(){
     }
     public override void afterInsert(){
     String errorMsg = '';
     try{
     }catch(Exception e){
     errorMsg = Utility.getProperErrorMessage(e.getMessage())+';'+e.getLineNumber();
     system.debug(e.getStackTraceString());
     system.debug(e.getMessage());
     }
     if(String.isNotBlank(errorMsg)){
     for(Promoter_Daily_Report__c recTemp :(List<Promoter_Daily_Report__c>)Trigger.new){
     recTemp.addError(errorMsg);
     }
     }
     }
     public override void beforeUpdate(){
     }
     public override void afterUpdate(){
     String errorMsg = '';
     try{
     }catch(Exception e){
     errorMsg = Utility.getProperErrorMessage(e.getMessage())+';'+e.getLineNumber();
     system.debug(e.getStackTraceString());
     system.debug(e.getMessage());
     }
     if(String.isNotBlank(errorMsg)){
     for(Promoter_Daily_Report__c recTemp :(List<Promoter_Daily_Report__c>)Trigger.new){
     recTemp.addError(errorMsg);
     }
     }
     }
     */
}