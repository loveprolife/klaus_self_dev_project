/**********************************************************************
* Name: OriginalCustomerReportBatch
* Object: Original Customer Revenue Summary Report
* Purpose: 
* 原有战略客户汇总报表
* Author: Gerry
* Create Date: 2019-03-25
*************************************************************************/
global class OriginalCustomerReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global OriginalCustomerReportBatch(String year,String month) {
        this.year = year;
        this.month = month;
        this.query = 'SELECT Id,Product_Line_Name__c,Rank__c,Customer__c,Customer__r.Sales_Region__c,Rank_Of_Last_Year__c,Management_Customer__c,Rank_Of_The_Year_Before_Last__c '+
                     'FROM Customer_Product_Line__c WHERE (Rank__c = \'Strategy Customer\' AND Rank_Of_Last_Year__c = \'Strategy Customer\') '+
                     'OR (Rank_Of_The_Year_Before_Last__c = \'Strategy Customer\' AND Rank_Of_Last_Year__c = \'Strategy Customer\')';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Customer_Product_Line__c> CustomerProductList) {
        System.debug(CustomerProductList.size());
        Set<String> accIdSet = new Set<String>();
        Set<String> overseaCompany = new Set<String>();
        Set<String> productLine = new Set<String>();
        //每种海外公司每种产品线对应的所有产品线
        Map<String,List<Customer_Product_Line__c>> cplMap = new Map<String,List<Customer_Product_Line__c>>();
        Map<String,List<Customer_Product_Line__c>> cplMapLast = new Map<String,List<Customer_Product_Line__c>>();
        List<Customer_Product_Line__c> cplList = new List<Customer_Product_Line__c>();
        for (Customer_Product_Line__c cpl : CustomerProductList) {
            if (cpl.Customer__c==cpl.Management_Customer__c) {
                cplList.add(cpl);
            }
        }
        for (Customer_Product_Line__c cpl : cplList) {
            if ('Strategy Customer'.equals(cpl.Rank__c)&&'Strategy Customer'.equals(cpl.Rank_Of_Last_Year__c)) {
                System.debug(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c);
                if (cplMap.containsKey(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c)) {
                    cplMap.get(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c).add(cpl);
                    System.debug(1);
                }else{
                    cplMap.put(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c,new List<Customer_Product_Line__c>{cpl});
                    System.debug(2);
                }
            }
            if ('Strategy Customer'.equals(cpl.Rank_Of_The_Year_Before_Last__c)&&'Strategy Customer'.equals(cpl.Rank_Of_Last_Year__c)) {
                if (cplMapLast.containsKey(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c)) {
                    cplMapLast.get(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c).add(cpl);
                    System.debug(1);
                }else{
                    cplMapLast.put(cpl.Customer__r.Sales_Region__c+','+cpl.Product_Line_Name__c,new List<Customer_Product_Line__c>{cpl});
                    System.debug(2);
                }
            }
            
            accIdSet.add(cpl.Customer__c); 
            overseaCompany.add(cpl.Customer__r.Sales_Region__c);
            productLine.add(cpl.Product_Line_Name__c);
        }

        Map<String,Schema.SObjectField> salesTargetLoopMap = Schema.SObjectType.Sales_Target__c.fields.getMap();
        String queryStr = Utility.getQueryStringByFieldMap(salesTargetLoopMap);
        String querySql = 'SELECT Customer_Name__r.Guarantor_Country_Code__c,Customer_Name__r.Name,'+queryStr+' FROM Sales_Target__c WHERE '+
                          'Customer_Name__c IN :accIdSet AND Product_Line__c IN :productLine';
        List<Sales_Target__c> salesTargetList = Database.query(querySql);

        //根据Account的ID map salesTarget
        Map<String,List<Sales_Target__c>> stMap = new Map<String,List<Sales_Target__c>>();
        for (Sales_Target__c st : salesTargetList) {
            if (stMap.containsKey(st.Customer_Name__c+st.Product_Line__c)) {
                stMap.get(st.Customer_Name__c+st.Product_Line__c).add(st);
            }else{
                stMap.put(st.Customer_Name__c+st.Product_Line__c, new List<Sales_Target__c>{st});
            }
        }



        String year = this.year;
        Integer month = Integer.valueOf(this.month);
        if ('1'.equals(String.valueOf(month))) {
            year = String.valueOf(Integer.valueOf(year)-1);
            month = 12;
        }else{
            year = this.year;
            month = month-1;
        }

        // month = 1;
        // year = '2018';

        //所有海外公司对应的每种产线名称对应的所有产品线
        Set<String> regionProductSet = cplMap.keySet();

        Map<String,Original_Customer_Revenue_Summary_Report__c> ocrMap = new Map<String,Original_Customer_Revenue_Summary_Report__c>();

        Map<String,Schema.SObjectField> ocrLoopMap = Schema.SObjectType.Original_Customer_Revenue_Summary_Report__c.fields.getMap();
        queryStr = Utility.getQueryStringByFieldMap(ocrLoopMap);
        querySql = 'SELECT '+queryStr+' FROM Original_Customer_Revenue_Summary_Report__c WHERE Oversea_Company__c IN :overseaCompany AND '+
                          'Product_Line__c IN :productLine AND Year__c=:year';
        List<Original_Customer_Revenue_Summary_Report__c> ocrListSelect = Database.query(querySql);

        //查询出Overall Customer Revenue Summary Report对象用对应海外公司对应产品线对应年份的数据
        for(Original_Customer_Revenue_Summary_Report__c ocr : ocrListSelect){
            ocrMap.put(ocr.Oversea_Company__c+ocr.Product_Line__c, ocr);                                                   
        }

        System.debug('几条数据'+regionProductSet.size());
        List<Original_Customer_Revenue_Summary_Report__c> ocrList = new List<Original_Customer_Revenue_Summary_Report__c>();
        
        Decimal dec;
        Savepoint sp = Database.setSavepoint();
        try {
            //每种海外公司中每种产品线对应的产品线
            for (String regionProduct : regionProductSet) {
                Decimal actualRevenue = 0;
                Decimal actualRevenueM1 = 0;
                Decimal plannedRevenue = 0;
                List<String> strList = regionProduct.split(',');
                Original_Customer_Revenue_Summary_Report__c ocr;
                if (ocrMap.get(strList[0]+strList[1]) != null) {
                    ocr = ocrMap.get(strList[0]+strList[1]);
                    // List<Decimal> decimalList = Revenue(month,ocr);
                    // actualRevenue = decimalList[0];
                    // actualRevenueM1 = decimalList[1];
                    // plannedRevenue = decimalList[2];
                }else{
                    ocr = new Original_Customer_Revenue_Summary_Report__c();
                    ocr.Oversea_Company__c = strList[0];
                    ocr.Product_Line__c = strList[1];
                    ocr.Year__c = year;
                    ocr.CurrencyIsoCode = 'USD';
                    ocrMap.put(ocr.Oversea_Company__c+ocr.Product_Line__c, ocr);
                    // actualRevenue = 0;
                    // actualRevenueM1 = 0;
                    // plannedRevenue = 0;
                }
                System.debug('同海外公司同产品线的个数'+cplMap.get(regionProduct).size());
                for (Customer_Product_Line__c cpl : cplMap.get(regionProduct)) {
                    Sales_Target__c salesTargetNow;
                    if (stMap.get(cpl.Customer__c+cpl.Product_Line_Name__c)!=null) {
                        for (Sales_Target__c st : stMap.get(cpl.Customer__c+cpl.Product_Line_Name__c)) {
                            if (year.equals(st.Year__c)) {
                                salesTargetNow = st;
                                continue;
                            }
                        }
                    }
                    actualRevenue = totalRevenue(actualRevenue,month,salesTargetNow,'actual');
                    plannedRevenue = totalRevenue(plannedRevenue,month,salesTargetNow,'');
                }
                if (cplMapLast.get(regionProduct)!=null) {
                    for (Customer_Product_Line__c cpl : cplMapLast.get(regionProduct)) {
                        Sales_Target__c salesTargetMLast;
                        if (stMap.get(cpl.Customer__c+cpl.Product_Line_Name__c)!=null) {
                            for (Sales_Target__c st : stMap.get(cpl.Customer__c+cpl.Product_Line_Name__c)) {
                                if (String.valueOf(Decimal.valueOf(year)-1).equals(st.Year__c)) {
                                    salesTargetMLast = st;
                                    continue;
                                }
                            }
                        }
                        actualRevenueM1 = totalRevenue(actualRevenueM1,month,salesTargetMLast,'actual');
                    } 
                }
                
                switch on month{
                    when 1{
                        ocr.Actual_Revenue_Jan__c = convertNull(ocr.Actual_Revenue_Jan__c);
                        ocr.Actual_Revenue_Jan__c = actualRevenue + ocr.Actual_Revenue_Jan__c;
                        ocr.N_M1_Year_Actual_Revenue_Jan__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Jan__c);
                        ocr.N_M1_Year_Actual_Revenue_Jan__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Jan__c;
                        ocr.Planned_Revenue_Jan__c = convertNull(ocr.Planned_Revenue_Jan__c);
                        ocr.Planned_Revenue_Jan__c = plannedRevenue+ocr.Planned_Revenue_Jan__c;
                    }
                    when 2{
                        ocr.Actual_Revenue_Feb__c = convertNull(ocr.Actual_Revenue_Feb__c);
                        ocr.Actual_Revenue_Feb__c = actualRevenue+ocr.Actual_Revenue_Feb__c;
                        ocr.N_M1_Year_Actual_Revenue_Feb__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Feb__c);
                        ocr.N_M1_Year_Actual_Revenue_Feb__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Feb__c;
                        ocr.Planned_Revenue_Feb__c = convertNull(ocr.Planned_Revenue_Feb__c);
                        ocr.Planned_Revenue_Feb__c = plannedRevenue+ocr.Planned_Revenue_Feb__c;
                    }
                     when 3{
                        ocr.Actual_Revenue_Mar__c = convertNull(ocr.Actual_Revenue_Mar__c);
                        ocr.Actual_Revenue_Mar__c = actualRevenue+ocr.Actual_Revenue_Mar__c;
                        ocr.N_M1_Year_Actual_Revenue_Mar__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Mar__c);
                        ocr.N_M1_Year_Actual_Revenue_Mar__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Mar__c;
                        ocr.Planned_Revenue_Mar__c = convertNull(ocr.Planned_Revenue_Mar__c);
                        ocr.Planned_Revenue_Mar__c = plannedRevenue+ocr.Planned_Revenue_Mar__c;
                    }
                    when 4{
                        ocr.Actual_Revenue_Aprl__c = convertNull(ocr.Actual_Revenue_Aprl__c);
                        ocr.Actual_Revenue_Aprl__c = actualRevenue+ocr.Actual_Revenue_Aprl__c;
                        ocr.N_M1_Year_Actual_Revenue_Aprl__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Aprl__c);
                        ocr.N_M1_Year_Actual_Revenue_Aprl__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Aprl__c;
                        ocr.Planned_Revenue_Aprl__c = convertNull(ocr.Planned_Revenue_Aprl__c);
                        ocr.Planned_Revenue_Aprl__c = plannedRevenue+ocr.Planned_Revenue_Aprl__c;
                    }
                    when 5{
                        ocr.Actual_Revenue_May__c = convertNull(ocr.Actual_Revenue_May__c);
                        ocr.Actual_Revenue_May__c = actualRevenue+ocr.Actual_Revenue_May__c;
                        ocr.N_M1_Year_Actual_Revenue_May__c = convertNull(ocr.N_M1_Year_Actual_Revenue_May__c);
                        ocr.N_M1_Year_Actual_Revenue_May__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_May__c;
                        ocr.Planned_Revenue_May__c = convertNull(ocr.Planned_Revenue_May__c);
                        ocr.Planned_Revenue_May__c = plannedRevenue+ocr.Planned_Revenue_May__c;
                    }
                    when 6{
                        ocr.Actual_Revenue_Jun__c = convertNull(ocr.Actual_Revenue_Jun__c);
                        ocr.Actual_Revenue_Jun__c = actualRevenue+ocr.Actual_Revenue_Jun__c;
                        ocr.N_M1_Year_Actual_Revenue_Jun__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Jun__c);
                        ocr.N_M1_Year_Actual_Revenue_Jun__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Jun__c;
                        ocr.Planned_Revenue_Jun__c = convertNull(ocr.Planned_Revenue_Jun__c);
                        ocr.Planned_Revenue_Jun__c = plannedRevenue+ocr.Planned_Revenue_Jun__c;
                    }
                    when 7{
                        ocr.Actual_Revenue_Jul__c = convertNull(ocr.Actual_Revenue_Jul__c);
                        ocr.Actual_Revenue_Jul__c = actualRevenue+ocr.Actual_Revenue_Jul__c;
                        ocr.N_M1_Year_Actual_Revenue_Jul__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Jul__c);
                        ocr.N_M1_Year_Actual_Revenue_Jul__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Jul__c;
                        ocr.Planned_Revenue_Jul__c = convertNull(ocr.Planned_Revenue_Jul__c);
                        ocr.Planned_Revenue_Jul__c = plannedRevenue+ocr.Planned_Revenue_Jul__c;
                    }
                    when 8{
                        ocr.Actual_Revenue_Aug__c = convertNull(ocr.Actual_Revenue_Aug__c);
                        ocr.Actual_Revenue_Aug__c = actualRevenue+ocr.Actual_Revenue_Aug__c;
                        ocr.N_M1_Year_Actual_Revenue_Aug__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Aug__c);
                        ocr.N_M1_Year_Actual_Revenue_Aug__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Aug__c;
                        ocr.Planned_Revenue_Aug__c = convertNull(ocr.Planned_Revenue_Aug__c);
                        ocr.Planned_Revenue_Aug__c = plannedRevenue+ocr.Planned_Revenue_Aug__c;
                    }
                    when 9{
                        ocr.Actual_Revenue_Sept__c = convertNull(ocr.Actual_Revenue_Sept__c);
                        ocr.Actual_Revenue_Sept__c = actualRevenue+ocr.Actual_Revenue_Sept__c;
                        ocr.N_M1_Year_Actual_Revenue_Sept__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Sept__c);
                        ocr.N_M1_Year_Actual_Revenue_Sept__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Sept__c;
                        ocr.Planned_Revenue_Sept__c = convertNull(ocr.Planned_Revenue_Sept__c);
                        ocr.Planned_Revenue_Sept__c = plannedRevenue+ocr.Planned_Revenue_Sept__c;
                    }
                    when 10{
                        ocr.Actual_Revenue_Oct__c = convertNull(ocr.Actual_Revenue_Oct__c);
                        ocr.Actual_Revenue_Oct__c = actualRevenue+ocr.Actual_Revenue_Oct__c;
                        ocr.N_M1_Year_Actual_Revenue_Oct__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Oct__c);
                        ocr.N_M1_Year_Actual_Revenue_Oct__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Oct__c;
                        ocr.Planned_Revenue_Oct__c = convertNull(ocr.Planned_Revenue_Oct__c);
                        ocr.Planned_Revenue_Oct__c = plannedRevenue+ocr.Planned_Revenue_Oct__c;
                    }
                    when 11{
                        ocr.Actual_Revenue_Nov__c = convertNull(ocr.Actual_Revenue_Nov__c);
                        ocr.Actual_Revenue_Nov__c = actualRevenue+ocr.Actual_Revenue_Nov__c;
                        ocr.N_M1_Year_Actual_Revenue_Nov__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Nov__c);
                        ocr.N_M1_Year_Actual_Revenue_Nov__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Nov__c;
                        ocr.Planned_Revenue_Nov__c = convertNull(ocr.Planned_Revenue_Nov__c);
                        ocr.Planned_Revenue_Nov__c = plannedRevenue+ocr.Planned_Revenue_Nov__c;
                    }
                    when 12{
                        ocr.Actual_Revenue_Dec__c = convertNull(ocr.Actual_Revenue_Dec__c);
                        ocr.Actual_Revenue_Dec__c = actualRevenue+ocr.Actual_Revenue_Dec__c;
                        ocr.N_M1_Year_Actual_Revenue_Dec__c = convertNull(ocr.N_M1_Year_Actual_Revenue_Dec__c);
                        ocr.N_M1_Year_Actual_Revenue_Dec__c = actualRevenueM1+ocr.N_M1_Year_Actual_Revenue_Dec__c;
                        ocr.Planned_Revenue_Dec__c = convertNull(ocr.Planned_Revenue_Dec__c);
                        ocr.Planned_Revenue_Dec__c = plannedRevenue;
                    }
                }
                ocrList.add(ocr);
            }
            Database.upsert(ocrList);
            System.debug('插入成功'+ocrList.size());
        }catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('OriginalCustomerReportBatch', errorMsg);
        } 
    }

    global void finish(Database.BatchableContext BC) {

    }

    public static Decimal totalRevenue(Decimal dec,Integer month,Sales_Target__c st,String type){
        if (st==null) {
            return dec+0;
        }
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
        actualIncomeMonthUSD.add(convertNull(st.Actual_Sales_Income_December_USD__c));
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
        forecastedIncomeMonthUSD.add(convertNull(st.Estimated_Sales_Income_December_USD__c));
        if (type.equals('actual')) {
            dec = dec + actualIncomeMonthUSD[month-1];
        }else{
            dec = dec + forecastedIncomeMonthUSD[month-1];
        }
        return dec;
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

    // public static List<Decimal> Revenue(Integer month,Original_Customer_Revenue_Summary_Report__c ocr){
    //     List<Decimal> decList = new List<Decimal>();
    //     Decimal actualRevenue;
    //     Decimal actualRevenueM1;
    //     Decimal plannedRevenue;
    //     switch on month{
    //                 when 1{
    //                     actualRevenue = ocr.Actual_Revenue_Jan__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Jan__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Jan__c;
    //                 }
    //                 when 2{
    //                     actualRevenue = ocr.Actual_Revenue_Feb__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Feb__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Feb__c;
    //                 }
    //                  when 3{
    //                     actualRevenue = ocr.Actual_Revenue_Mar__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Mar__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Mar__c;
    //                 }
    //                 when 4{
    //                     actualRevenue = ocr.Actual_Revenue_Aprl__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Aprl__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Aprl__c;
    //                 }
    //                 when 5{
    //                     actualRevenue = ocr.Actual_Revenue_May__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_May__c;
    //                     plannedRevenue = ocr.Planned_Revenue_May__c;
    //                 }
    //                 when 6{
    //                     actualRevenue = ocr.Actual_Revenue_Jun__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Jun__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Jun__c;
    //                 }
    //                 when 7{
    //                     actualRevenue = ocr.Actual_Revenue_Jul__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Jul__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Jul__c;
    //                 }
    //                 when 8{
    //                     actualRevenue = ocr.Actual_Revenue_Jul__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Jul__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Jul__c;
    //                 }
    //                 when 9{
    //                     actualRevenue = ocr.Actual_Revenue_Sept__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Sept__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Sept__c;
    //                 }
    //                 when 10{
    //                     actualRevenue = ocr.Actual_Revenue_Oct__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Oct__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Oct__c;
    //                 }
    //                 when 11{
    //                     actualRevenue = ocr.Actual_Revenue_Nov__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Nov__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Nov__c;
    //                 }
    //                 when 12{
    //                     actualRevenue = ocr.Actual_Revenue_Dec__c;
    //                     actualRevenueM1 = ocr.N_M1_Year_Actual_Revenue_Dec__c;
    //                     plannedRevenue = ocr.Planned_Revenue_Dec__c;
    //                 }
    //             }
    //             decList.add(actualRevenue);
    //             decList.add(actualRevenueM1);
    //             decList.add(plannedRevenue);
    //             return decList;
    // }
}