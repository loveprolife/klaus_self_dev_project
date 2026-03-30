/*
 * @Author: WFC
 * @Date: 2024-03-14 10:21:50
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-02 09:44:05
 * @Description: 样机报表与daily sales关联
 PrototypeReportDailySalesBatch pr = new PrototypeReportDailySalesBatch();
 Database.executeBatch(pr,100);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\PrototypeReportDailySalesBatch.cls
 */
global class PrototypeReportDailySalesBatch implements Database.Batchable<sObject>{
    public String query;

    global PrototypeReportDailySalesBatch(){
        this.query = ' SELECT id, Sampling_Detail__c, Sampling_Detail__r.Shop__c, Sampling_Detail__r.Product__c,Sampling_Detail__r.CreatedDate  ' + 
                 ' FROM Prototype_Report__c WHERE Sampling_Detail__r.Shop__c != null AND Sampling_Detail__r.Product__c != null ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Prototype_Report__c> prototypeReportList){
        // 导入数据集合
        List<Prototype_Report_Daily_Sales__c> addList = new List<Prototype_Report_Daily_Sales__c>();

        // Sampling Detail Id集合
        Set<Id> sdId = new Set<Id>();
        for (Prototype_Report__c pr : prototypeReportList){
            sdId.add(pr.Sampling_Detail__c);
        }
        // 查询Sampling_Detail_Display_Time__c表
        List<Sampling_Detail_Display_Time__c> sddtList = [SELECT Id, Display_Time__c, Hidden_Time__c, Sampling_Detail__c
                                                          FROM Sampling_Detail_Display_Time__c
                                                          WHERE Sampling_Detail__c IN:sdId
                                                          ORDER BY CreatedDate];
        for (Prototype_Report__c pr : prototypeReportList){
            // 门店id
            Id shopId = pr.Sampling_Detail__r.Shop__c;
            // 产品id
            Id productId = pr.Sampling_Detail__r.Product__c;
            // 出样id
            Id samplingDetailId = pr.Sampling_Detail__c;

            // 出样开始时间
            String startTime = pr.Sampling_Detail__r.CreatedDate.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone()));
            // 当前sampling detail 下所有的上下架时间信息
            List<Sampling_Detail_Display_Time__c> sddtListTemp = new LisqContainer(sddtList).WhereOne('Sampling_Detail__c', '=', samplingDetailId).ToSobjectList();
            String sql = ' SELECT Id, TotalPrice__c, Number__c, CurrencyIsoCode, ReportDate__c FROM Retail_Number__c WHERE Shop__c = \'' + shopId + '\' AND Product__c = \'' + productId + '\' AND ';
            String reportDateSql = '';
            if (sddtListTemp != null && sddtListTemp.size() > 0){
                // 出样下架过
                // 只有一条下架数据
                if (sddtListTemp.size() == 0){
                    reportDateSql += ' ( ReportDate__c >= ' + startTime + ' AND ReportDate__c <= ' + sddtListTemp[0].Hidden_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                    // 下架后重新上架
                    if (sddtListTemp[0].Display_Time__c != null){
                        reportDateSql += ' OR ( ReportDate__c >= ' + sddtListTemp[0].Display_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                    }
                } else{
                    // 有多条下架数据
                    for (Integer i = 0; i < sddtListTemp.size(); i++){
                        if (i == 0){
                            reportDateSql += ' ( ReportDate__c >= ' + startTime + ' AND ReportDate__c <= ' + sddtListTemp[i].Hidden_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                        } else if (i < sddtListTemp.size() - 1){
                            reportDateSql += ' OR ( ReportDate__c >= ' + sddtListTemp[i - 1].Display_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' AND ReportDate__c <= ' + sddtListTemp[i].Hidden_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                        } else if (i == sddtListTemp.size() - 1){
                            reportDateSql += ' OR ( ReportDate__c >= ' + sddtListTemp[i - 1].Display_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' AND ReportDate__c <= ' + sddtListTemp[i].Hidden_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                            // 下架后重新上架
                            if (sddtListTemp[i].Display_Time__c != null){
                                reportDateSql += ' OR ( ReportDate__c >= ' + sddtListTemp[i].Display_Time__c.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())) + ' ) ';
                            }
                        }
                    }
                }
            } else{
                // 出样没有下架过
                reportDateSql = ' ReportDate__c >= ' + startTime;
            }
            sql = sql + '(' + reportDateSql + ')';
            // 查询所有相关的daily sales
            List<Retail_Number__c> dailySalesList = Database.query(sql);
            for (Retail_Number__c dailySales : dailySalesList){
                Prototype_Report_Daily_Sales__c prds = new Prototype_Report_Daily_Sales__c();
                prds.Prototype_Report__c = pr.id;
                prds.Daily_Sales__c = dailySales.id;
                prds.Total_Price__c = dailySales.TotalPrice__c;
                prds.Number__c = dailySales.Number__c;
                prds.CurrencyIsoCode = dailySales.CurrencyIsoCode;
                // 统计标记设置
                Date dailySalesDate = dailySales.ReportDate__c;
                if (dailySalesDate >= Date.newInstance(System.today().year(), System.today().month(), 1)){
                    prds.Is_Current_Month__c = true;
                }
                if (dailySalesDate >= System.today().addMonths(-3)){
                    prds.Is_Last_3_Month__c = true;
                }
                if (dailySalesDate >= System.today().addMonths(-6)){
                    prds.Is_Last_6_Month__c = true;
                }
                if (dailySalesDate >= System.today().addYears(-1)){
                    prds.Is_Last_12_Month__c = true;
                }
                addList.add(prds);
            }
        }

        insert addList;
    }

    global void finish(Database.BatchableContext BC){
        // 修改自定义报表状态
        // List<Report_Custom__c> reportCustomList = [SELECT Id, Last_Update_Time__c, Report_Status__c
        //                                            FROM Report_Custom__c
        //                                            WHERE Batch_Class__c = 'PrototypeReportDeleteBatch'];
        // if (reportCustomList != null && reportCustomList.size() > 0){
        //     Report_Custom__c rc = reportCustomList[0];
        //     rc.Last_Update_Time__c = System.now();
        //     rc.Report_Status__c = 'Update complete';
        //     update rc;
        // }
        Utility.refreshReportCustom('PrototypeReportDeleteBatch');
    }

}