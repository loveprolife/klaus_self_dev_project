/**********************************************************************
* Name: CustomerVolumeRevenueReportBatch
* Object: Strategy Customer Volume&Revenue Report
* Purpose: 
* 战略客户数量收入汇总报表
* Author: Gerry
* Create Date: 2019-03-27
*************************************************************************/
global class CustomerVolumeRevenueReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global CustomerVolumeRevenueReportBatch(String year,String month) {
        this.year = year;
        this.month = month;
        this.query = 'SELECT Id,Product_Line_Name__c,Rank__c,Customer__r.Name,Customer__c,Customer__r.Sales_Region__c,Customer__r.ParentId,'+
                     'Customer__r.Guarantor_Country_Code__c,Rank_Of_Last_Year__c,Rank_Of_The_Year_Before_Last__c,Customer__r.Type,Management_Customer__c '+
                     'FROM Customer_Product_Line__c WHERE Rank__c = \'Strategy Customer\' OR Rank_Of_Last_Year__c =\'Strategy Customer\' '+
                     'OR Rank_Of_The_Year_Before_Last__c = \'Strategy Customer\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Customer_Product_Line__c> customerProductList) {
        System.debug('customerProductList:'+customerProductList.size());
        //国家和产品线为key的map
        Map<String,List<Customer_Product_Line__c>> cpMap = new Map<String,List<Customer_Product_Line__c>>();
        //Customer_Product_Line__c的客户ID集合
        Set<String> customerNameSet = new Set<String>();
        //Customer_Product_Line__c的产品线集合
        Set<String> productNameSet = new Set<String>(); 
        //Customer_Product_Line__c的salesRegion集合
        Set<String> countrySet = new Set<String>();
        //管理客户Id集合
        Set<Id> managementId = new Set<Id>();
        List<Customer_Product_Line__c> cplList = new List<Customer_Product_Line__c>();
        for (Customer_Product_Line__c cpl : customerProductList) {
            //只要母公司或管理客户的客户产品线
            if (cpl.Customer__c==cpl.Management_Customer__c&&cpl.Customer__r.ParentId==null) {
                cplList.add(cpl);
                //获取为管理客户的客户Id
                if ('Management'.equals(cpl.Customer__r.Type)) {
                    managementId.add(cpl.Customer__c);
                }
            }
        }
        System.debug('cplList:'+cplList.size());
        System.debug('managementId:'+managementId.size());
        //对应管理客户下面的小客户个数
        Map<String,Integer> countMap = new Map<String,Integer>();
        for (AggregateResult ar : [SELECT Count(Id),Management_Customer__c FROM Customer_Product_Line__c WHERE Management_Customer__c IN: managementId Group BY Management_Customer__c]) {
            countMap.put(String.valueOf(ar.get('Management_Customer__c')), Integer.valueOf(ar.get('expr0')));
        }
        System.debug('countMap:'+countMap);

        for (Customer_Product_Line__c cpl : cplList) {
            if (cpMap.containsKey(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c)) {
                cpMap.get(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c).add(cpl);
            }else{
                cpMap.put(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c, new List<Customer_Product_Line__c>{cpl});
            }
            customerNameSet.add(cpl.Customer__c);
            productNameSet.add(cpl.Product_Line_Name__c);
            countrySet.add(cpl.Customer__r.Sales_Region__c);
        }
        String year = this.year;
        String month = this.month;
        if ('1'.equals(month)) {
            month = '12';
            year = String.valueOf(Integer.valueOf(year)-1);
        }else{
            year = this.year;
            month = String.valueOf(Integer.valueOf(month)-1);
        }

        // month = '3';
        // year = '2018';
        //获取系统中对应的Revenue_Statement_Report__c
        Map<String,Revenue_Statement_Report__c> rsrMap = new Map<String,Revenue_Statement_Report__c>();
        for (Revenue_Statement_Report__c rsr : [SELECT  N_Year_Actual_Accumulated_Revenue_USD__c,N_1_Year_s_Actual_Revenue_USD__c,Actual_Revenue_Same_Period_USD__c,Product_Line__c,Customer__c,N_2_Year_s_Actual_Revenue_USD__c  
                                                FROM Revenue_Statement_Report__c 
                                                WHERE Customer__c IN :customerNameSet AND Product_Line__c IN :productNameSet AND Year__c =:year AND Month__c =:month]) {
            rsrMap.put(rsr.Customer__c+rsr.Product_Line__c, rsr);
        }
        System.debug('Map:'+rsrMap.size());

        //获取系统中已存在的Strategy_Customer_Volume_Revenue_Report__c
        Map<String,Schema.SObjectField> ocrLoopMap = Schema.SObjectType.Strategy_Customer_Volume_Revenue_Report__c.fields.getMap();
        String queryStr = Utility.getQueryStringByFieldMap(ocrLoopMap);
        String querySql = 'SELECT '+queryStr+' FROM Strategy_Customer_Volume_Revenue_Report__c WHERE Country__c IN :countrySet AND '+
                          'Product_Line__c IN :productNameSet AND Year__c=:year AND Month__c=:month';
        List<Strategy_Customer_Volume_Revenue_Report__c> ocrListSelect = Database.query(querySql);
        Map<String,Strategy_Customer_Volume_Revenue_Report__c> scvMap = new Map<String,Strategy_Customer_Volume_Revenue_Report__c>();
        for (Strategy_Customer_Volume_Revenue_Report__c scv : ocrListSelect) {
            scvMap.put(scv.Country__c+scv.Product_Line__c, scv);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            List<Strategy_Customer_Volume_Revenue_Report__c> scvList = new List<Strategy_Customer_Volume_Revenue_Report__c>();
            for (String key : cpMap.keySet()) {
                List<String> strList = key.split(',');
                Strategy_Customer_Volume_Revenue_Report__c scv = scvMap.get(key);
                //如果系统中已经存在对应的Strategy_Customer_Volume_Revenue_Report__c就用系统中的，如果不存在则新建
                if (scv==null) {
                    scv = new Strategy_Customer_Volume_Revenue_Report__c();
                    scv.Country__c = strList[0];
                    scv.Product_Line__c = strlist[1];
                    scv.Year__c = year;
                    scv.Month__c = month;
                    scv.CurrencyIsoCode = 'USD';
                    scvMap.put(key,scv);
                }
                
                //当前年的战略客户数量
                Integer customerNum = 0;
                //去年的战略客户数量
                Integer lastCustomerNum = 0;
                //前年的战略客户数量
                Integer beforeLastCustomerNum = 0;
                //N-2年的战略客户全年收入总和
                Decimal beforeLastRevenue = 0;
                //n-1年的战略客户全年收入总和
                Decimal lastCustomerRevenue = 0;
                //n年的战略客户累计收入
                Decimal totalRevenue = 0;
                //同期的战略客户累计收入
                Decimal lastTotalRevenue = 0;
                for (Customer_Product_Line__c cpl : cpMap.get(key)) {
                    ID coustomerId = cpl.Customer__c;
                    Decimal dec;
                    Revenue_Statement_Report__c rsr = rsrMap.get(coustomerId+cpl.Product_Line_Name__c);
                    //当前年的客户数量
                    if ('Strategy Customer'.equals(cpl.Rank__c)) {
                        //如果时管理客户要取下面所有的客户数量
                        if ('Management'.equals(cpl.Customer__r.Type)) {
                            customerNum = customerNum+countMap.get(String.valueOf(cpl.Customer__c))-1;
                        }else{  
                            customerNum = customerNum+1;
                        }
                        dec = rsr==null? 0:rsr.N_Year_Actual_Accumulated_Revenue_USD__c;
                        dec = dec==null? 0:dec;
                        totalRevenue = totalRevenue + dec;
                    }
                    System.debug('Rank_Of_Last_Year__c:'+cpl.Rank_Of_Last_Year__c);
                    //去年的客户数量
                    if ('Strategy Customer'.equals(cpl.Rank_Of_Last_Year__c)) {
                        if ('Management'.equals(cpl.Customer__r.Type)) {
                            lastCustomerNum = lastCustomerNum+countMap.get(cpl.Customer__c)-1;
                        }else{  
                            lastCustomerNum = lastCustomerNum+1;
                        }
                        dec = rsr==null? 0:rsr.N_1_Year_s_Actual_Revenue_USD__c;
                        dec = dec==null? 0:dec;
                        lastCustomerRevenue = lastCustomerRevenue + dec;
                        dec = rsr==null? 0:rsr.Actual_Revenue_Same_Period_USD__c;
                        dec = dec==null? 0:dec;
                        lastTotalRevenue = lastTotalRevenue + dec;
                    }
                    //前年的客户数量
                    if ('Strategy Customer'.equals(cpl.Rank_Of_The_Year_Before_Last__c)) {
                        if ('Management'.equals(cpl.Customer__r.Type)) {
                            beforeLastCustomerNum = beforeLastCustomerNum+countMap.get(cpl.Customer__c)-1;
                        }else{  
                            beforeLastCustomerNum = beforeLastCustomerNum+1;
                        }
                        dec = rsr==null? 0:rsr.N_2_Year_s_Actual_Revenue_USD__c;
                        dec = dec==null? 0:dec;
                        beforeLastRevenue = beforeLastRevenue + dec;
                    }
                }
                scv.N_M2_Year_Strategy_Customer_Qty__c = scv.N_M2_Year_Strategy_Customer_Qty__c==null? 0:scv.N_M2_Year_Strategy_Customer_Qty__c;
                scv.N_M2_Year_Strategy_Customer_Qty__c = beforeLastCustomerNum+scv.N_M2_Year_Strategy_Customer_Qty__c;
                scv.N_M1_Year_Strategy_Customer_Qty__c = scv.N_M1_Year_Strategy_Customer_Qty__c==null? 0:scv.N_M1_Year_Strategy_Customer_Qty__c;
                scv.N_M1_Year_Strategy_Customer_Qty__c = lastCustomerNum+scv.N_M1_Year_Strategy_Customer_Qty__c;
                scv.N_Year_Strategy_Customer_Qty__c = scv.N_Year_Strategy_Customer_Qty__c==null? 0:scv.N_Year_Strategy_Customer_Qty__c;
                scv.N_Year_Strategy_Customer_Qty__c = customerNum+scv.N_Year_Strategy_Customer_Qty__c;
                scv.N_M2_Year_Strategy_Customer_Revenue__c = scv.N_M2_Year_Strategy_Customer_Revenue__c==null? 0:scv.N_M2_Year_Strategy_Customer_Revenue__c;
                scv.N_M2_Year_Strategy_Customer_Revenue__c = beforeLastRevenue+scv.N_M2_Year_Strategy_Customer_Revenue__c;
                scv.N_M1_Year_Strategy_Customer_Revenue__c = scv.N_M1_Year_Strategy_Customer_Revenue__c==null? 0:scv.N_M1_Year_Strategy_Customer_Revenue__c;
                scv.N_M1_Year_Strategy_Customer_Revenue__c = lastCustomerRevenue+scv.N_M1_Year_Strategy_Customer_Revenue__c;
                scv.N_Year_Strategy_Customer_Revenue__c = scv.N_Year_Strategy_Customer_Revenue__c==null? 0:scv.N_Year_Strategy_Customer_Revenue__c;
                scv.N_Year_Strategy_Customer_Revenue__c = totalRevenue+scv.N_Year_Strategy_Customer_Revenue__c;
                scv.N_M1_Year_Strategy_Customer_Rev_Same_Per__c = scv.N_M1_Year_Strategy_Customer_Rev_Same_Per__c==null? 0:scv.N_M1_Year_Strategy_Customer_Rev_Same_Per__c;
                scv.N_M1_Year_Strategy_Customer_Rev_Same_Per__c = lastTotalRevenue+scv.N_M1_Year_Strategy_Customer_Rev_Same_Per__c;
                scvList.add(scv);
            }
            Database.upsert(scvList); 
            System.debug('scvList:'+scvList.size());
            System.debug('插入数据成功');
        }
        catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('CustomerVolumeRevenueReportBatch', errorMsg);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}