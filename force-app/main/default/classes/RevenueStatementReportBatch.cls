/**********************************************************************
* Name: RevenueStatementReportBatch
* Object: Revenue Statement Report 
* Purpose: 
* 损益表
* Author: Gerry
* Create Date: 2019-03-14
*************************************************************************/
global class RevenueStatementReportBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public String year;
    public String month;
    public Decimal monthInsert;

    global RevenueStatementReportBatch(String year,String month) {
        this.year = year;
        this.month = month;
        this.query = 'SELECT Id,Customer_Status__c,Hisense_Entity__c,Customer_Category__c,Actual_Sales_Income_Ratio_N_1_Year__c,Hisense_Actual_Sales_Income_Ratio_N_Year__c,Coverage__c,Sales_Region__c,Name,Type,Payment_Term__r.Name,Payment_Term__r.Average_Payment_Days__c,Rank__c,Total_Store_Quantity__c,'+
                     'Cooperated_Store_Quantity__c,Payback_Overdue_Number__c,(SELECT Id,Product_Line_Name__c,Rank__c,Actual_Development_Date__c,'+
                     'Expected_Business_Stopping_Date__c,Market_Share__c,Customer__c,Management_Customer__c FROM Account_Product_Lines__r),' + 
                     '(SELECT Id,Credit_Rating__c FROM Credit_Limit_Application__r) FROM Account';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> RevenueStatementList) {
        //客户Id集合
        Set<ID> accIdList = new Set<ID>();
        //管理用客户集合(非自己)
        Set<String> manageCustomerIdSet = new Set<String>();
        //报表统计的客户Map 
        Map<String,Account> reportAccMap = new Map<String,Account>();
        for (Account acc : RevenueStatementList) {
            for (Customer_Product_Line__c cpl : acc.Account_Product_Lines__r) {
                //用客户产品线的管理用客户进行报表的收益统计
                if (cpl.Management_Customer__c != null) {
                    accIdList.add(cpl.Management_Customer__c);
                    if(acc.Id.equals(cpl.Management_Customer__c)){
                        reportAccMap.put(cpl.Management_Customer__c,acc);
                    }else{
                        manageCustomerIdSet.add(cpl.Management_Customer__c);
                    }
                    
                }   
            }
        }
        String manageAccQuery = this.query + ' where Id IN:manageCustomerIdSet';
        List<Account> manageAccList = Database.query(manageAccQuery);
        Map<String,Account> manageAccMap = new Map<String,Account>(manageAccList);
        reportAccMap.putAll(manageAccMap);
        //获取salesTarget所有的字段
        Map<String,Schema.SObjectField> salesTargetLoopMap = Schema.SObjectType.Sales_Target__c.fields.getMap();
        String queryStr = Utility.getQueryStringByFieldMap(salesTargetLoopMap);
        String querySql = 'SELECT '+queryStr+',Customer_Name__r.Sales_Region__c,Customer_Name__r.Name FROM Sales_Target__c '+
                          'WHERE Customer_Name__c IN:accIdList';
        List<Sales_Target__c> salesTargetList = Database.query(querySql);                  

        //根据Account的ID map salesTarget
        Map<Id,List<Sales_Target__c>> stMap = new Map<Id,List<Sales_Target__c>>();
        for (Sales_Target__c st : salesTargetList) {
            if (stMap.containsKey(st.Customer_Name__c)) {
                stMap.get(st.Customer_Name__c).add(st);
            }else{
                stMap.put(st.Customer_Name__c, new List<Sales_Target__c>{st});
            }
        }
        
        Decimal year = Decimal.valueOf(this.year);
        Decimal month = Decimal.valueOf(this.month);
        //当为1月份的时候，取上一年的12月份
        if ('1'.equals(String.valueOf(month))) {
            year = year-1;
            monthInsert = 12;
        }else{
            year = year;
            monthInsert = month-1;
        }
        //获取客户组织币种
        Map<String,String> hEntityCurrencyMap = getHisenseEntityCurrencyMap();
        List<Revenue_Statement_Report__c> newRevenueList = new List<Revenue_Statement_Report__c>();
        Savepoint sp = Database.setSavepoint();
        try {
            for (String accId : reportAccMap.keySet()) {
                if(reportAccMap.get(accId) == null){
                   continue;
                }
                Account acc = reportAccMap.get(accId);
                //如果客户下面没有产品线进入下一次循环
                if (!(acc.Account_Product_Lines__r!=null && acc.Account_Product_Lines__r.size()>0)) {
                    continue;
                }
                //System.debug(LoggingLevel.INFO,acc.Id);
                //account下的每个产品线都要新添一条revenuestatementreport纪录
                for (Customer_Product_Line__c cpl : acc.Account_Product_Lines__r) {
                    //当前年的salestarget
                    Sales_Target__c salesTargetNow;
                    //前一年sleasTarget
                    Sales_Target__c salesTargetM1;
                    //前两年salesTarget
                    Sales_Target__c salesTargetM2;
                    
                    Revenue_Statement_Report__c rsr = new Revenue_Statement_Report__c();
                    if (stMap.get(cpl.Customer__c)!=null) {
                        for (Sales_Target__c st : stMap.get(cpl.Customer__c)) {
                            if (st.Product_Line__c.equals(cpl.Product_Line_Name__c)&&String.valueOf(year).equals(st.Year__c)) {
                                salesTargetNow = st;
                                continue;
                            }
                            if (st.Product_Line__c.equals(cpl.Product_Line_Name__c)&&String.valueOf(year-1).equals(st.Year__c)) {
                                salesTargetM1 = st;
                                continue;
                            }
                            if (st.Product_Line__c.equals(cpl.Product_Line_Name__c)&&String.valueOf(year-2).equals(st.Year__c)) {
                                salesTargetM2 = st;
                                continue;
                            }
                        }
                    }
                    rsr.Customer_Product_Line__c = cpl.Id;
                    rsr.Month__c = String.valueOf(monthInsert);
                    rsr.CurrencyIsoCode = String.isBlank(acc.Hisense_Entity__c)? null : hEntityCurrencyMap.get(acc.Hisense_Entity__c);
                    rsr.Year__c = String.valueOf(year);
                    rsr.N_P1_Year_Target_of_Gross_Profit_Ratio__c = salesTargetNow==null? null:salesTargetNow.Gross_Profit_Margin_Target__c;
                    rsr.Customer_Status__c = acc.Customer_Status__c;
                    rsr.Customer_Rank__c = cpl.Rank__c;
                    rsr.Sales_Region__c = acc.Sales_Region__c;
                    rsr.Product_Line__c = cpl.Product_Line_Name__c;
                    rsr.Customer__c = acc.Id;
                    rsr.Customer_Type__c = acc.Customer_Category__c;
                    rsr.Account_Period__c = acc.Payment_Term__r.Name;
                    rsr.Average_Payment_Days__c = acc.Payment_Term__r.Average_Payment_Days__c;
                    rsr.Cooperate_Start_Date__c = cpl.Actual_Development_Date__c;
                    rsr.Planned_Eliminate_Date__c = cpl.Expected_Business_Stopping_Date__c;
                    rsr.Industry_Ranking__c = acc.Rank__c;
                    rsr.Market_Share__c = cpl.Market_Share__c;
                    rsr.Store_Qty__c = acc.Total_Store_Quantity__c;
                    rsr.Cooperated_Store_Qty__c = acc.Cooperated_Store_Quantity__c;
                    rsr.N_Year_Actual_Inhouse_Share__c = acc.Hisense_Actual_Sales_Income_Ratio_N_Year__c;
                    rsr.N_P1_Year_Target_Of_Inhouse_Share__c = acc.Actual_Sales_Income_Ratio_N_1_Year__c;
                    Credit_Limit_Application__c[] cla = acc.Credit_Limit_Application__r;
                    if (cla!=null&&cla.size()>0) {
                        rsr.Credit_Rank__c = cla[0].Credit_Rating__c;
                    }
                    rsr.Collection_Overdue_Times__c = acc.Payback_Overdue_Number__c;
                    rsr.N_Year_Planned_Revenue__c = salesTargetNow==null? null:salesTargetNow.Forecast_Total_Income__c;
                    rsr.N_Year_s_Planned_Revenue_USD__c = salesTargetNow==null? null:salesTargetNow.Total_Estimated_Sales_Income_USD__c;
                    rsr.N_M1_Year_Actual_Revenue__c = salesTargetM1==null? null:salesTargetM1.Total_Actual_Income__c;
                    rsr.N_1_Year_s_Actual_Revenue_USD__c = salesTargetM1==null? null:salesTargetM1.Total_Actual_Sales_Income_USD__c;
                    rsr.N_M2_Year_Actual_Revenue__c = salesTargetM2==null? null:salesTargetM2.Total_Actual_Income__c;
                    rsr.N_2_Year_s_Actual_Revenue_USD__c = salesTargetM2==null? null:salesTargetM2.Total_Actual_Sales_Income_USD__c;
                    //如果月份为1月份
                    if (month==1) {
                        rsr.N_Year_Actual_Accumulated_Revenue__c = salesTargetNow==null? null:salesTargetNow.Total_Actual_Income__c;
                        rsr.N_Year_Actual_Accumulated_Revenue_USD__c = salesTargetNow==null? null:salesTargetNow.Total_Actual_Sales_Income_USD__c;
                        rsr.N_Year_Planned_Accumulated_Revenue__c = salesTargetNow==null? null:salesTargetNow.Forecast_Total_Income__c;
                        rsr.N_Year_Planned_Accumulated_Revenue_US__c = salesTargetNow==null? null:salesTargetNow.Total_Estimated_Sales_Income_USD__c;
                        rsr.Actual_Revenue_Same_Period__c = salesTargetM1==null? null:salesTargetM1.Total_Actual_Income__c;
                        rsr.Actual_Revenue_Same_Period_USD__c = salesTargetM1==null? null:salesTargetM1.Total_Actual_Sales_Income_USD__c;
                    }else{//为其他月份时
                        if (salesTargetNow!=null) {
                            //调用计算收入的方法
                            List<Decimal> deListNow = totalRevenue(month,salesTargetNow);
                            rsr.N_Year_Planned_Accumulated_Revenue__c = deListNow[1];
                            rsr.N_Year_Planned_Accumulated_Revenue_US__c = deListNow[3];
                            rsr.N_Year_Actual_Accumulated_Revenue__c = deListNow[0];
                            rsr.N_Year_Actual_Accumulated_Revenue_USD__c = deListNow[2];
                        }
                        if (salesTargetM1!=null) {
                            List<Decimal> deListM1 = totalRevenue(month,salesTargetM1);
                            rsr.Actual_Revenue_Same_Period__c = deListM1[0];
                            rsr.Actual_Revenue_Same_Period_USD__c = deListM1[2];
                        } 
                    }
                    Decimal cost = 0;
                    if (salesTargetNow!=null) {
                        if (month==1) {
                            cost = salesTargetNow.Cost_Back_End_Field__c;
                        }else{
                            //调用计算cost的方法
                            cost = cost(salesTargetNow,month);
                        }
                        if (Math.abs(rsr.N_Year_Actual_Accumulated_Revenue__c) > 1) {
                            //计算实际累计毛利率
                            Decimal profit = (rsr.N_Year_Actual_Accumulated_Revenue__c-cost).divide(rsr.N_Year_Actual_Accumulated_Revenue__c,3);
                            rsr.N_Year_Accumulated_Gross_Profit_Ratio__c = profit * 100;
                        }
                    }
                    
                    if (salesTargetM1!=null) {
                        if (month==1) {
                            cost = salesTargetM1.Cost_Back_End_Field__c;
                        }else{
                            cost = cost(salesTargetM1,month);
                        }
                        if (Math.abs(rsr.Actual_Revenue_Same_Period__c) > 1) {
                            Decimal profit = (rsr.Actual_Revenue_Same_Period__c-cost).divide(rsr.Actual_Revenue_Same_Period__c,3);
                            rsr.N_M1_Year_Accumulated_Gross_Profit_Ratio__c =profit * 100;
                        }
                    }
                    if(cost!=0){
                        rsr.Total_Cost__c = cost;
                    }
                    newRevenueList.add(rsr);
                }
            }
            Database.insert(newRevenueList);
            System.debug(LoggingLevel.INFO,'插入成功,数量:'+newRevenueList.size());
        }catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            System.debug(e.getMessage() + 'Line Number: '+ e.getLineNumber());
            Utility.insertBatchLog('RevenueStatementReportBatch', errorMsg);
        }
    }

    global void finish(Database.BatchableContext BC) {
        //Revenue Statement Report权限Share
        RevenueStatementReportManualShareBatch rsrShare = new RevenueStatementReportManualShareBatch(year,String.valueOf(monthInsert));
        Database.executeBatch(rsrShare,200);

        // Revenue Statement Report权限Share
        Share_Common_IntegrationBatch rsrShareBatch = new Share_Common_IntegrationBatch(
            'Revenue_Statement_Report__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(rsrShareBatch, 30);
    }

    //计算实际收入和目标收入
    public static List<Decimal> totalRevenue(Decimal month,Sales_Target__c st){
        List<Decimal> totalRevenueList = new List<Decimal>();
        Decimal actualRevenue = 0;
        Decimal forecastedRevenue = 0;
        Decimal actualRevenueUSD = 0;
        Decimal forecastedRevenueUSD = 0;
        if (st!=null) {

            List<Decimal> actualIncomeMonth = new List<Decimal>();
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_January__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_February__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_March__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_April__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_May__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_June__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_July__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_August__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_September__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_October__c));
            actualIncomeMonth.add(convertNull(st.Actual_Income_in_November__c));
            List<Decimal> forecastedIncomeMonth = new List<Decimal>();
            forecastedIncomeMonth.add(convertNull(st.January_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.February_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.March_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.April_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.May_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.June_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.July_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.August_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.September_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.October_Forecasted_Income__c));
            forecastedIncomeMonth.add(convertNull(st.November_Forecasted_Income__c));
            List<Decimal> actualIncomeMonthUSD = new List<Decimal>();
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_January_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_February_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_March_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_April_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_May_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_June_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_July_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_Augest_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_September_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_October_USD__c));
            actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_November_USD__c));
            List<Decimal> forecastedIncomeMonthUSD = new List<Decimal>();
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_January_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_February_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_March_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_April_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_May_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_June_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_July_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_Augest_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_September_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_October_USD__c));
            forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_November_USD__c));
            //当前月之前所有的值的合
            for (Integer i=2 ; i<=month ; i++ ) {
                actualRevenue = actualIncomeMonth[i-2] + actualRevenue;
                forecastedRevenue = forecastedIncomeMonth[i-2] + forecastedRevenue;
                actualRevenueUSD = actualIncomeMonthUSD[i-2] + actualRevenueUSD;
                forecastedRevenueUSD = forecastedIncomeMonthUSD[i-2] + forecastedRevenueUSD;
            } 
        }
        totalRevenueList.add(actualRevenue);
        totalRevenueList.add(forecastedRevenue);
        totalRevenueList.add(actualRevenueUSD);
        totalRevenueList.add(forecastedRevenueUSD);
        return totalRevenueList;
    }
    public static Map<String,String> getHisenseEntityCurrencyMap(){
        Map<String,String> hEntityMap = new Map<String,String>();
        for (Mapping__c mp : [SELECT Id,CurrencyIsoCode,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c 
                             WHERE RecordType.DeveloperName =:Label.Business_Orgnization_and_Name_Mapping]){
            hEntityMap.put(mp.Name, mp.CurrencyIsoCode);
        }
        return hEntityMap;
    }

    //计算成本
    public static Decimal cost(Sales_Target__c st,Decimal month){
        Decimal costM1 = 0;
        if (st!=null) {
            List<Decimal> costList = new List<Decimal>();
            costList.add(convertNull(st.Cost_January__c));
            costList.add(convertNull(st.Cost_February__c));
            costList.add(convertNull(st.Cost_March__c));
            costList.add(convertNull(st.cost_April__c));
            costList.add(convertNull(st.Cost_May__c));
            costList.add(convertNull(st.Cost_June__c));
            costList.add(convertNull(st.Cost_July__c));
            costList.add(convertNull(st.Cost_Augest__c));
            costList.add(convertNull(st.Cost_September__c));
            costList.add(convertNull(st.Cost_October__c));
            costList.add(convertNull(st.Cost_November__c));
            costList.add(convertNull(st.Cost_December__c));
            List<String> monthList = new List<String>();
            //统计要计算那几个月份的cost
            for (Integer i=1;i<month;i++ ) {
                costM1 = costM1 + costList[i-1];
            }  
        }
        return costM1;
    }

    //转换'' to 0
    private static Decimal convertNull(Decimal num) {
        Decimal strConvert;
        if(num == null) {
            strConvert = 0;
        }else{
            strConvert = num;
        } 
        return strConvert;
    }
}