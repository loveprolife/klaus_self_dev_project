/*
 * @Author: WFC
 * @Date: 2024-08-09 16:54:29
 * @LastEditors: WFC
 * @LastEditTime: 2024-08-19 10:29:49
 * @Description: 计算等级信息
 StoreLevelTempStatisticsBatch sir = new StoreLevelTempStatisticsBatch();
 Database.executeBatch(sir,200);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\StoreLevelTempStatisticsBatch.cls
 */
global class StoreLevelTempStatisticsBatch implements Database.Batchable<sObject>{
    public String query;

    global StoreLevelTempStatisticsBatch(){
        this.query = ' SELECT Id, Store__c, Store__r.Sales_Region__c, TV_Sales__c, Refrigerator_Sales__c, WM_Sales__c, AC_Sales__c ' + 
                 ' FROM Store_Level_Temp__c ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Store_Level_Temp__c> sltList){
        List<Shop__c> updateShopList = new List<Shop__c>();
        for (Store_Level_Temp__c slt : sltList){
            // sales region
            String salesRegion = slt.Store__r.Sales_Region__c;
            // total number
            Decimal num = 0;
            // total score
            Decimal score = 0;
            // 赋值
            if (slt.TV_Sales__c != null){
                // 万元
                Decimal sales = slt.TV_Sales__c * 4 / 10000;
                Store_Level__c sl = Store_Level__c.getValues(salesRegion + '-TV');
                if (sales >= sl.Level_S__c){
                    slt.TV_Level__c = 'S';
                    score += sl.Level_S_Score__c;
                } else if (sales >= sl.Level_A__c){
                    slt.TV_Level__c = 'A';
                    score += sl.Level_A_Score__c;
                } else if (sales >= sl.Level_B__c){
                    slt.TV_Level__c = 'B';
                    score += sl.Level_B_Score__c;
                } else if (sales >= sl.Level_C__c){
                    slt.TV_Level__c = 'C';
                    score += sl.Level_C_Score__c;
                } else{
                    slt.TV_Level__c = 'D';
                    score += sl.Level_D_Score__c;
                }
                num++;
            }
            if (slt.Refrigerator_Sales__c != null){
                // 万元
                Decimal sales = slt.Refrigerator_Sales__c * 4 / 10000;
                Store_Level__c sl = Store_Level__c.getValues(salesRegion + '-Refrigerator');
                if (sales >= sl.Level_S__c){
                    slt.Refrigerator_Level__c = 'S';
                    score += sl.Level_S_Score__c;
                } else if (sales >= sl.Level_A__c){
                    slt.Refrigerator_Level__c = 'A';
                    score += sl.Level_A_Score__c;
                } else if (sales >= sl.Level_B__c){
                    slt.Refrigerator_Level__c = 'B';
                    score += sl.Level_B_Score__c;
                } else if (sales >= sl.Level_C__c){
                    slt.Refrigerator_Level__c = 'C';
                    score += sl.Level_C_Score__c;
                } else{
                    slt.Refrigerator_Level__c = 'D';
                    score += sl.Level_D_Score__c;
                }
                num++;
            }
            if (slt.WM_Sales__c != null){
                // 万元
                Decimal sales = slt.WM_Sales__c * 4 / 10000;
                Store_Level__c sl = Store_Level__c.getValues(salesRegion + '-WM');
                if (sales >= sl.Level_S__c){
                    slt.WM_Level__c = 'S';
                    score += sl.Level_S_Score__c;
                } else if (sales >= sl.Level_A__c){
                    slt.WM_Level__c = 'A';
                    score += sl.Level_A_Score__c;
                } else if (sales >= sl.Level_B__c){
                    slt.WM_Level__c = 'B';
                    score += sl.Level_B_Score__c;
                } else if (sales >= sl.Level_C__c){
                    slt.WM_Level__c = 'C';
                    score += sl.Level_C_Score__c;
                } else{
                    slt.WM_Level__c = 'D';
                    score += sl.Level_D_Score__c;
                }
                num++;
            }
            if (slt.AC_Sales__c != null){
                // 万元
                Decimal sales = slt.AC_Sales__c * 4 / 10000;
                Store_Level__c sl = Store_Level__c.getValues(salesRegion + '-AC');
                if (sales >= sl.Level_S__c){
                    slt.AC_Level__c = 'S';
                    score += sl.Level_S_Score__c;
                } else if (sales >= sl.Level_A__c){
                    slt.AC_Level__c = 'A';
                    score += sl.Level_A_Score__c;
                } else if (sales >= sl.Level_B__c){
                    slt.AC_Level__c = 'B';
                    score += sl.Level_B_Score__c;
                } else if (sales >= sl.Level_C__c){
                    slt.AC_Level__c = 'C';
                    score += sl.Level_C_Score__c;
                } else{
                    slt.AC_Level__c = 'D';
                    score += sl.Level_D_Score__c;
                }
                num++;
            }

            if (num != 0){
                slt.Is_New__c = true;
                slt.Total_Level__c = Store_Score_Level__c.getValues(String.valueOf(Math.floor(score / num))).Level__c;

                Shop__c shop = new Shop__c();
                shop.Id = slt.Store__c;
                shop.Shop_Level__c = slt.Total_Level__c;

                updateShopList.add(shop);
            }
        }
        Database.update (sltList, false);
        Database.update (updateShopList, false);
    }

    global void finish(Database.BatchableContext BC){
        Utility.refreshReportCustom('StoreLevelTempClearBatch');
    }

}