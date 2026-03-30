/*
 * @Author: WFC
 * @Date: 2024-08-09 15:16:37
 * @LastEditors: WFC
 * @LastEditTime: 2024-08-21 15:34:28
 * @Description: 门店规模等级 取一个季度的数据
 StoreLevelTempBatch sir = new StoreLevelTempBatch();
 Database.executeBatch(sir,200);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\StoreLevelTempBatch.cls
 */
global class StoreLevelTempBatch implements Database.Batchable<sObject>{
    public String query;
    public List<String> salesRegionList;
    public List<String> salesRegionSpecialList;
    public List<String> productLineList;
    public String status;
    public Date startDate;
    public Date endDate;

    global StoreLevelTempBatch(){
        this.salesRegionList = new List<String>{ 'Hisense Indonesia', 'Hisense Malaysia', 'Hisense Vietnam', 'Hisense Philippines' };
        this.salesRegionSpecialList = new List<String>{ 'Hisense Thailand' };
        this.productLineList = new List<String>{ 'TV', 'Refrigerator', 'WM', 'AC' };
        this.status = 'Submitted';
        this.startDate = Date.today().addMonths(-3);
        this.endDate = Date.today();
        this.query = ' SELECT Id, CurrencyIsoCode, TotalPrice__c, Product_Line__c, Shop__c ' + 
                 ' FROM Retail_Number__c WHERE (( Shop__r.Sales_Region__c IN :salesRegionList AND Status__c = :status) ' + 
                 ' OR Shop__r.Sales_Region__c IN :salesRegionSpecialList )' +
                 ' AND Product_Line__c IN :productLineList ' + 
                 ' AND ReportDate__c >= :startDate ' + 
                 ' AND ReportDate__c < :endDate ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Retail_Number__c> dailySalesList){
        // 汇率
        Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
        Decimal rateCNY = currencyRateMap.get('CNY');
        // 查询门店等级临时表
        List<Store_Level_Temp__c> sltList = [SELECT Id, Store__c, Key__c, AC_Sales__c, Refrigerator_Sales__c, WM_Sales__c, TV_Sales__c
                                             FROM Store_Level_Temp__c];
        Map<String, SObject> sltMap = new LisqContainer(sltList).ToMapS('Key__c');
        // 遍历daily sales，销售数据更新到临时表中
        for (Retail_Number__c rn : dailySalesList){
            // 销售转换成人民币
            Decimal rate = currencyRateMap.get(rn.CurrencyIsoCode);
            Decimal totalPrice = rn.TotalPrice__c / rate * rateCNY;
            Store_Level_Temp__c slt;
            // 临时表已存在数据
            if (sltMap.get(rn.Shop__c) != null){
                slt = (Store_Level_Temp__c) sltMap.get(rn.Shop__c);
            } else{
                // 临时表不存在
                slt = new Store_Level_Temp__c();
                slt.Store__c = rn.Shop__c;
                slt.Key__c = rn.Shop__c;
            }
            switch  on rn.Product_Line__c{
                when 'TV'{
                    slt.TV_Sales__c = (slt.TV_Sales__c == null ? 0:slt.TV_Sales__c) + totalPrice;
                }
                when 'Refrigerator'{
                    slt.Refrigerator_Sales__c = (slt.Refrigerator_Sales__c == null ? 0:slt.Refrigerator_Sales__c) + totalPrice;
                }
                when 'WM'{
                    slt.WM_Sales__c = (slt.WM_Sales__c == null ? 0:slt.WM_Sales__c) + totalPrice;
                }
                when 'AC'{
                    slt.AC_Sales__c = (slt.AC_Sales__c == null ? 0:slt.AC_Sales__c) + totalPrice;
                }
            }
            sltMap.put(rn.Shop__c, slt);
        }
        Database.upsert (sltMap.values(), Store_Level_Temp__c.Fields.Key__c, true);
    }

    global void finish(Database.BatchableContext BC){
        StoreLevelTempStatisticsBatch sir = new StoreLevelTempStatisticsBatch();
        Database.executeBatch(sir, 200);
    }

}