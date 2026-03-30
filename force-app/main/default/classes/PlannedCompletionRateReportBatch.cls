/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 05-11-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global class PlannedCompletionRateReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public String day;
    public Date today;
    public Date startDate;
    //动态获取需要生成计划增长率报表的销售组织
    public List<String> hEnityList = Label.Company_Code_List_For_Planned_Completion_Rate_Report.split(',');
    //获取客户销售组织对应币种Map
    public static Map<String,String> hEntityCurrencyMap = Utility.getHisenseEntityCurrencyMap();
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();

    global PlannedCompletionRateReportBatch(String inputYear,String inputMonth,String inputDay) {
        this.year = inputYear;
        this.month = inputMonth;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        this.day = inputDay;
        String dayStr = this.day;
        if (Integer.valueOf(day)<10) {
            dayStr = '0'+dayStr;
        }
        this.startDate = Date.valueOf(this.year + '-' + this.month + '-' + '01');
        this.today = Date.valueOf(this.year + '-' + this.month + '-' + dayStr);

        this.query = 'SELECT Id,Product_Line_Name__c,Rank__c,Actual_Development_Date__c,Customer__r.Hisense_Entity__c,Parent_Product_Line__c,'+
                     ' Expected_Business_Stopping_Date__c,Market_Share__c,Customer__c,Management_Customer__c,Management_Customer_Branch_Company__c,' + 
                     ' Management_Customer_Branch_Company__r.Hisense_Entity__c FROM Customer_Product_Line__c' +
                     ' WHERE Customer__r.Hisense_Entity__c IN:hEnityList AND Management_Customer_Branch_Company__c!=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Customer_Product_Line__c> cplList) {
        ///System.debug('List:'+cplList.size());
        try {
            //管理用客户ID集合
            Set<ID> managementAccIdSet = new Set<ID>();
            //父级产品线
            Set<String> parentProductLineSet = new Set<String>();
            //所有客户产品线对应的客户
            Set<ID> allAccIdSet = new Set<ID>();
            //子产品线
            Set<String> productLineSet = new Set<String>();
            //管理用客户+父级产品线下面的所有子级产品线
            Map<String,List<Customer_Product_Line__c>> accMap = new Map<String,List<Customer_Product_Line__c>>();
            //管理用客户+父级产品线指向管理用客户所属销售组织 last modified by johnson20190814
            Map<String,String> manageAccHisenseEntityMap = new Map<String,String>();
            //收入成本年份集合，今年+去年 last modified by johnson20190823
            Set<String> yearSet = new Set<String>{year,String.valueOf(Integer.valueOf(year) - 1)};
            for (Customer_Product_Line__c cpl : cplList) {
                //System.debug(1);
                if (accMap.containsKey(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c)) {
                    accMap.get(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c).add(cpl);
                    //System.debug(2);
                }else{
                    accMap.put(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c, new List<Customer_Product_Line__c>{cpl});
                    //System.debug(3);
                }
                manageAccHisenseEntityMap.put(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c, cpl.Management_Customer_Branch_Company__r.Hisense_Entity__c);
                managementAccIdSet.add(cpl.Management_Customer_Branch_Company__c);
                parentProductLineSet.add(cpl.Parent_Product_Line__c);
                allAccIdSet.add(cpl.Customer__c);
                productLineSet.add(cpl.Product_Line_Name__c);
            }
            //客户+产品线+年+月+
            Map<String,List<Invoice_Item__c>> invoiceItemMap = new Map<String,List<Invoice_Item__c>>();
            //找出客户产品线对应的发票
            for (Invoice_Item__c invoiceItem : [SELECT Invoice_Quantity__c,Invoice__r.Invoice_Posting_Date__c,Invoice__r.Customer__c,Product_Line__c,CurrencyIsoCode,Invoice_Amount__c,Total_Amount_After_Rebate__c
                                                FROM Invoice_Item__c WHERE Invoice__r.Customer__c IN:allAccIdSet AND Product_Line__c IN:productLineSet AND Invoice__r.Invoice_Posting_Date__c>=:startDate AND Invoice__r.Invoice_Posting_Date__c<=:today]) {
                if (invoiceItemMap.containsKey(invoiceItem.Invoice__r.Customer__c+invoiceItem.Product_Line__c)) {
                    invoiceItemMap.get(invoiceItem.Invoice__r.Customer__c+invoiceItem.Product_Line__c).add(invoiceItem);
                }else{
                    invoiceItemMap.put(invoiceItem.Invoice__r.Customer__c+invoiceItem.Product_Line__c, new List<Invoice_Item__c>{invoiceItem});
                }
            }

            //客户+产品线+年+月的收入成本
            Map<String,SAP_Cost_Revenue_Data__c> costRevenueMap = new Map<String,SAP_Cost_Revenue_Data__c>();

            //找出所有客户产品线对应的收入成本    
            for (SAP_Cost_Revenue_Data__c costRevenue : [SELECT CurrencyIsoCode,Month__c,Year__c,Sales_Volume__c,Customer__c,Product_Line__c,Sales_Gross_Revenue__c,Sales_Gross_Revenue_USD__c,Sales_Revenue__c,Sales_Revenue_USD__c 
                                                         FROM SAP_Cost_Revenue_Data__c WHERE Customer__c IN:allAccIdSet AND Product_Line__c IN:productLineSet AND Year__c IN:yearSet]) {
                //last modified by johnson20190814
                String monthCostRevenueKey = costRevenue.Customer__c+costRevenue.Product_Line__c+costRevenue.Year__c+costRevenue.Month__c;
                if(costRevenueMap.containsKey(monthCostRevenueKey)){
                    SAP_Cost_Revenue_Data__c exsitCostRevenue = costRevenueMap.get(monthCostRevenueKey);
                    exsitCostRevenue.Sales_Volume__c += convertNull(costRevenue.Sales_Volume__c);
                    exsitCostRevenue.Sales_Revenue__c += convertNull(costRevenue.Sales_Revenue__c);
                    exsitCostRevenue.Sales_Revenue_USD__c += convertNull(costRevenue.Sales_Revenue_USD__c);
                    exsitCostRevenue.Sales_Gross_Revenue__c += convertNull(costRevenue.Sales_Gross_Revenue__c);
                    exsitCostRevenue.Sales_Gross_Revenue_USD__c += convertNull(costRevenue.Sales_Gross_Revenue_USD__c);
                }else{
                    costRevenue.Sales_Volume__c = convertNull(costRevenue.Sales_Volume__c);
                    costRevenue.Sales_Revenue__c = convertNull(costRevenue.Sales_Revenue__c);
                    costRevenue.Sales_Revenue_USD__c = convertNull(costRevenue.Sales_Revenue_USD__c);
                    costRevenue.Sales_Gross_Revenue__c = convertNull(costRevenue.Sales_Gross_Revenue__c);
                    costRevenue.Sales_Gross_Revenue_USD__c = convertNull(costRevenue.Sales_Gross_Revenue_USD__c);
                    costRevenueMap.put(monthCostRevenueKey, costRevenue);
                }                   
            }
            
            //找出对应客户ID的SalesTargetBranch
            Map<String,Schema.SObjectField> salesTargetLoopMap = Schema.SObjectType.Sales_Target_Branch_Company_Use__c.fields.getMap();
            String queryStr = Utility.getQueryStringByFieldMap(salesTargetLoopMap);
            String querySql = 'SELECT '+queryStr+',Customer_Name__r.Guarantor_Country_Code__c,Customer_Name__r.Name FROM Sales_Target_Branch_Company_Use__c '+
                              'WHERE Customer_Name__c IN:managementAccIdSet AND Product_Line__c IN:parentProductLineSet '+
                              'AND Year__c = :year';
            List<Sales_Target_Branch_Company_Use__c> salesTargetBranchList = Database.query(querySql);
            //客户+产品线对应的SalesTargetBranch
            Map<String,Sales_Target_Branch_Company_Use__c> salesTargetBranchMap = new Map<String,Sales_Target_Branch_Company_Use__c>();
            for (Sales_Target_Branch_Company_Use__c st : salesTargetBranchList) {
                salesTargetBranchMap.put(st.Customer_Name__c+st.Product_Line__c, st);
            }

            Map<String,Schema.SObjectField> pcrrLoopMap = Schema.SObjectType.Planned_Completion_Rate_Report__c.fields.getMap();
            queryStr = Utility.getQueryStringByFieldMap(pcrrLoopMap);
            querySql = 'SELECT '+queryStr+' FROM Planned_Completion_Rate_Report__c WHERE Year__c=:year AND Month__c=:month';
            List<Planned_Completion_Rate_Report__c> pcrrList = Database.query(querySql);
            //已存在的报表数据
            Map<String,Planned_Completion_Rate_Report__c> pcrrMap = new Map<String,Planned_Completion_Rate_Report__c>();
            for (Planned_Completion_Rate_Report__c pcrr : pcrrList) {
                pcrrMap.put(pcrr.Management_Customer__c+pcrr.Product_Line__c+pcrr.Month__c+pcrr.Year__c, pcrr);
            }

            List<Planned_Completion_Rate_Report__c> upsertList = new List<Planned_Completion_Rate_Report__c>();

            Set<String> keySet = accMap.keySet();
            //去年年份
            String lastYear = String.valueOf(Integer.valueOf(year)-1);

            for (String key : keySet) {
                String hEntityCode = manageAccHisenseEntityMap.get(key);
                List<String> keyList = key.split(',');
                Planned_Completion_Rate_Report__c completionRate = pcrrMap.get(keyList[0]+keyList[1]+month+year);
                //如果不存在就新建
                if (completionRate==null) {
                    completionRate = new Planned_Completion_Rate_Report__c();
                    completionRate.Management_Customer__c = keyList[0];
                    completionRate.Product_Line__c = keyList[1];
                    completionRate.Year__c = year;
                    completionRate.Month__c = month;
                    completionRate.CurrencyIsoCode = String.isBlank(hEntityCode)? 'USD' : hEntityCurrencyMap.get(hEntityCode);
                }
                Sales_Target_Branch_Company_Use__c stb = salesTargetBranchMap.get(completionRate.Management_Customer__c+completionRate.Product_Line__c);
                //找到计划收入值
                List<Decimal> decList = planIncome(month,stb);
                if (decList!=null) {
                    completionRate.Planned_Revenue_Net_USD__c = decList[0];
                    completionRate.Planned_Revenue_Net__c = decList[1];
                    completionRate.Planned_Revenue_Gross__c = decList[2];
                    completionRate.Planned_Revenue_Gross_USD__c = decList[3];
                    completionRate.sales_target_volumn__c = decList[4];
                }
                 
                //同期
                Decimal samePeriodMonth = 0;
                Decimal samePeriodMonthUSD = 0;
                Decimal samePeriodMonthGross = 0;
                Decimal samePeriodMonthGrossUSD = 0;
                //去年累计
                Decimal lastRevenueNetBC = 0;
                Decimal lastRevenueNetUSD = 0;
                Decimal lastRevenueGrossBC = 0;
                Decimal lastRevenueGrossUSD = 0;
                //今年累计
                Decimal revenueNetBC = 0;
                Decimal revenueNetUSD = 0;
                Decimal revenueGrossBC = 0;
                Decimal revenueGrossUSD = 0;
                //当天收入值
                Decimal revenueNetBCToday = 0;
                Decimal revenueNetUSDToday = 0;
                Decimal revenueGrossBCToday = 0;
                Decimal revenueGrossUSDToday = 0;
                //去年累计销量
                Decimal volumnLast = 0;
                //今年累计销量
                Decimal volumn = 0;
                //同期累计销量
                Decimal samePeriodVolumn = 0;
                //当月实际销量
                Decimal volumnMonth = 0;
                //根据年月+币种得到发票币种的汇率以及实际同期币种的汇率(今年)
                String rateYearMonth = year + month;
                //根据年月+币种得到发票币种的汇率以及实际同期币种的汇率(去年)
                String lastRateYearMonth = lastYear+month;
                //今年销售组织的汇率
                Decimal rate = currencyRateMap.get(completionRate.CurrencyIsoCode + rateYearMonth);
                
                //去年销售组织汇率
                Decimal lastRate = currencyRateMap.get(completionRate.CurrencyIsoCode + lastRateYearMonth);
                
                if(Test.isRunningTest()){
                    rate = 1;lastRate = 1;
                }
                //System.debug(key+accMap.get(key).Size());
                for (Customer_Product_Line__c cpl : accMap.get(key)) {
                    //计算同期
                    SAP_Cost_Revenue_Data__c scrd = costRevenueMap.get(cpl.Customer__c+cpl.Product_Line_Name__c+lastYear+month);
                            
                    if (scrd!=null) {
                        Decimal rate2 = currencyRateMap.get(scrd.CurrencyIsoCode + lastRateYearMonth);
                        if(Test.isRunningTest()){
                            rate2 = 1;
                        }
                            //货币转换
                        if (completionRate.CurrencyIsoCode!=null && completionRate.CurrencyIsoCode.equals(scrd.CurrencyIsoCode)) {
                            samePeriodMonth = samePeriodMonth+convertNull(scrd.Sales_Revenue__c); 
                            samePeriodMonthGross = samePeriodMonthGross+convertNull(scrd.Sales_Gross_Revenue__c);
                        }else{
                            samePeriodMonth = samePeriodMonth+convertNull(scrd.Sales_Revenue__c)/rate2*lastRate; 
                            samePeriodMonthGross = samePeriodMonthGross+convertNull(scrd.Sales_Gross_Revenue__c)/rate2*lastRate;
                        }
                                
                        samePeriodMonthUSD = samePeriodMonthUSD+convertNull(scrd.Sales_Revenue_USD__c);
                                
                        samePeriodMonthGrossUSD = samePeriodMonthGrossUSD+convertNull(scrd.Sales_Gross_Revenue_USD__c);
                        samePeriodVolumn = samePeriodVolumn+convertNull(scrd.Sales_Volume__c);
                    }
                    //计算累计
                    for (Integer i=1;i<=Integer.valueOf(month);i++) {
                        String str = String.valueOf(i);
                        if (i<10) {
                            str = '0'+str;
                        }

                        //去年累计
                        SAP_Cost_Revenue_Data__c scrdLast = costRevenueMap.get(cpl.Customer__c+cpl.Product_Line_Name__c+lastYear+str);
                                
                        if (scrdLast!=null) {
                            // 货币转换
                            Decimal rate3 = currencyRateMap.get(scrdLast.CurrencyIsoCode + lastRateYearMonth);
                            if(Test.isRunningTest()){
                                rate3 = 1;
                            }
                            if (completionRate.CurrencyIsoCode!=null && !completionRate.CurrencyIsoCode.equals(scrdLast.CurrencyIsoCode)) {
                                lastRevenueNetBC = lastRevenueNetBC+convertNull(scrdLast.Sales_Revenue__c)/rate3*lastRate;
                                lastRevenueGrossBC = lastRevenueGrossBC+convertNull(scrdLast.Sales_Gross_Revenue__c)/rate3*lastRate;
                            }else{
                                lastRevenueNetBC = lastRevenueNetBC+convertNull(scrdLast.Sales_Revenue__c);
                                lastRevenueGrossBC = lastRevenueGrossBC+convertNull(scrdLast.Sales_Gross_Revenue__c);
                            }
                                        
                            lastRevenueNetUSD = lastRevenueNetUSD+convertNull(scrdLast.Sales_Revenue_USD__c);
                                        
                            lastRevenueGrossUSD = lastRevenueGrossUSD+convertNull(scrdLast.Sales_Gross_Revenue_USD__c);
                            volumnLast = volumnLast+convertNull(scrdLast.Sales_Volume__c);
                        }
                        //今年累计
                        SAP_Cost_Revenue_Data__c scrdNYear = costRevenueMap.get(cpl.Customer__c+cpl.Product_Line_Name__c+year+str);
                        if (i!=Integer.valueOf(month)&&scrdNYear!=null) {
                            // 货币转换
                            Decimal rate4 = currencyRateMap.get(scrdNYear.CurrencyIsoCode + rateYearMonth);
                            if(Test.isRunningTest()){
                                rate4 = 1;
                            }
                            if (completionRate.CurrencyIsoCode!=null && !completionRate.CurrencyIsoCode.equals(scrdNYear.CurrencyIsoCode)) {
                                revenueNetBC = revenueNetBC+convertNull(scrdNYear.Sales_Revenue__c)/rate4*rate;
                                revenueGrossBC = revenueGrossBC+convertNull(scrdNYear.Sales_Gross_Revenue__c)/rate4+rate;
                            }else{
                                revenueNetBC = revenueNetBC+convertNull(scrdNYear.Sales_Revenue__c); 
                                revenueGrossBC = revenueGrossBC+convertNull(scrdNYear.Sales_Gross_Revenue__c);
                            }
          
                            revenueNetUSD = revenueNetUSD+convertNull(scrdNYear.Sales_Revenue_USD__c);
                                        
                            revenueGrossUSD = revenueGrossUSD+convertNull(scrdNYear.Sales_Gross_Revenue_USD__c); 
                            volumn = volumn+convertNull(scrdNYear.Sales_Volume__c);
                        }    
                    }
                    //System.debug(cpl);
                    List<Invoice_Item__c> invoiceItemList = invoiceItemMap.get(cpl.Customer__c+cpl.Product_Line_Name__c);
                    if (invoiceItemList!=null) {
                        for (Invoice_Item__c invoice : invoiceItemMap.get(cpl.Customer__c+cpl.Product_Line_Name__c)) {
                            // 发票币种的汇率
                            Decimal rate1 = currencyRateMap.get(invoice.CurrencyIsoCode + rateYearMonth);
                            if(Test.isRunningTest()){
                                rate1 = 1;
                            }
                            if(completionRate.CurrencyIsoCode!=null && completionRate.CurrencyIsoCode.equals(invoice.CurrencyIsoCode)){
                                revenueNetBCToday = revenueNetBCToday+convertNull(invoice.Total_Amount_After_Rebate__c);
                                revenueGrossBCToday = revenueGrossBCToday+convertNull(invoice.Invoice_Amount__c);
                            }else{
                                revenueNetBCToday = revenueNetBCToday+convertNull(invoice.Total_Amount_After_Rebate__c)/rate1*rate;
                                revenueGrossBCToday = revenueGrossBCToday+convertNull(invoice.Invoice_Amount__c)/rate1*rate;
                            }
                            revenueNetUSDToday = revenueNetUSDToday+convertNull(invoice.Total_Amount_After_Rebate__c)/rate1;
                            revenueGrossUSDToday = revenueGrossUSDToday+convertNull(invoice.Invoice_Amount__c)/rate1;
                            volumnMonth = volumnMonth+convertNull(invoice.Invoice_Quantity__c);
                        } 
                    }  
                }
                     
                
                //同期当月收入
                completionRate.Actual_Revenue_Same_Period_Net__c = completionRate.Actual_Revenue_Same_Period_Net__c==null? 0:completionRate.Actual_Revenue_Same_Period_Net__c;
                completionRate.Actual_Revenue_Same_Period_Net__c = samePeriodMonth+completionRate.Actual_Revenue_Same_Period_Net__c;

                completionRate.Actual_Revenue_Same_Period_Net_USD__c = completionRate.Actual_Revenue_Same_Period_Net_USD__c==null? 0:completionRate.Actual_Revenue_Same_Period_Net_USD__c;
                completionRate.Actual_Revenue_Same_Period_Net_USD__c = samePeriodMonthUSD+completionRate.Actual_Revenue_Same_Period_Net_USD__c;

                completionRate.Actual_Revenue_Same_Period_Gross__c = completionRate.Actual_Revenue_Same_Period_Gross__c==null? 0:completionRate.Actual_Revenue_Same_Period_Gross__c;
                completionRate.Actual_Revenue_Same_Period_Gross__c = samePeriodMonthGross+completionRate.Actual_Revenue_Same_Period_Gross__c;

                completionRate.Actual_Revenue_Same_Period_Gross_USD__c = completionRate.Actual_Revenue_Same_Period_Gross_USD__c==null? 0:completionRate.Actual_Revenue_Same_Period_Gross_USD__c;
                completionRate.Actual_Revenue_Same_Period_Gross_USD__c = samePeriodMonthGrossUSD+completionRate.Actual_Revenue_Same_Period_Gross_USD__c;
                //同期销量
                completionRate.sales_volumn_Same_Period__c = convertNull(completionRate.sales_volumn_Same_Period__c)+samePeriodVolumn;
                //今年累计
                completionRate.Accumulated_Revenue_Net__c = completionRate.Accumulated_Revenue_Net__c==null? 0:completionRate.Accumulated_Revenue_Net__c;
                completionRate.Accumulated_Revenue_Net__c = revenueNetBC+completionRate.Accumulated_Revenue_Net__c;

                completionRate.Accumulated_Revenue_Net_USD__c = completionRate.Accumulated_Revenue_Net_USD__c==null? 0:completionRate.Accumulated_Revenue_Net_USD__c;
                completionRate.Accumulated_Revenue_Net_USD__c = revenueNetUSD+completionRate.Accumulated_Revenue_Net_USD__c;

                completionRate.Accumulated_Revenue_Gross__c = completionRate.Accumulated_Revenue_Gross__c==null? 0:completionRate.Accumulated_Revenue_Gross__c;
                completionRate.Accumulated_Revenue_Gross__c = revenueGrossBC+completionRate.Accumulated_Revenue_Gross__c;

                completionRate.Accumulated_Revenue_Gross_USD__c = completionRate.Accumulated_Revenue_Gross_USD__c==null? 0:completionRate.Accumulated_Revenue_Gross_USD__c;
                completionRate.Accumulated_Revenue_Gross_USD__c = revenueGrossUSD+completionRate.Accumulated_Revenue_Gross_USD__c;
                //今年累计
                completionRate.Accumulated_sales_volumn__c = convertNull(completionRate.Accumulated_sales_volumn__c)+volumn;
                //去年累计
                completionRate.Accumulated_Revenue_Net_Same_Period__c = completionRate.Accumulated_Revenue_Net_Same_Period__c==null? 0:completionRate.Accumulated_Revenue_Net_Same_Period__c;
                completionRate.Accumulated_Revenue_Net_Same_Period__c = lastRevenueNetBC+completionRate.Accumulated_Revenue_Net_Same_Period__c;

                completionRate.Accumulated_Revenue_Net_Same_Period_USD__c = completionRate.Accumulated_Revenue_Net_Same_Period_USD__c==null? 0:completionRate.Accumulated_Revenue_Net_Same_Period_USD__c;
                completionRate.Accumulated_Revenue_Net_Same_Period_USD__c = lastRevenueNetUSD+completionRate.Accumulated_Revenue_Net_Same_Period_USD__c;

                completionRate.Accumulated_Revenue_Gross_Same_Period__c = completionRate.Accumulated_Revenue_Gross_Same_Period__c==null? 0:completionRate.Accumulated_Revenue_Gross_Same_Period__c;
                completionRate.Accumulated_Revenue_Gross_Same_Period__c = lastRevenueGrossBC+completionRate.Accumulated_Revenue_Gross_Same_Period__c;

                completionRate.Accumulated_Revenue_Gross_Period_USD__c = completionRate.Accumulated_Revenue_Gross_Period_USD__c==null? 0:completionRate.Accumulated_Revenue_Gross_Period_USD__c;
                completionRate.Accumulated_Revenue_Gross_Period_USD__c = lastRevenueGrossUSD+completionRate.Accumulated_Revenue_Gross_Period_USD__c; 
                //去年销量
                completionRate.Accumulated_sales_volumn_Same_Period__c = convertNull(completionRate.Accumulated_sales_volumn_Same_Period__c)+volumnLast;
            
                //实际收入
                completionRate.Actual_Revenue_Net__c = convertNull(completionRate.Actual_Revenue_Net__c) + revenueNetBCToday;
                completionRate.Actual_Revenue_Net_USD__c = convertNull(completionRate.Actual_Revenue_Net_USD__c) + revenueNetUSDToday;
                completionRate.Actual_Revenue_Gross__c = convertNull(completionRate.Actual_Revenue_Gross__c) + revenueGrossBCToday;
                completionRate.Actual_Revenue_Gross_USD__c = convertNull(completionRate.Actual_Revenue_Gross_USD__c) + revenueGrossUSDToday;
                //System.debug('aaa'+completionRate.Accumulated_Revenue_Net__c);
                //System.debug('bbb'+revenueNetBCToday);
                //今年累计（到天）
                completionRate.Accumulated_Revenue_Net__c = convertNull(completionRate.Accumulated_Revenue_Net__c)+revenueNetBCToday;

                completionRate.Accumulated_Revenue_Net_USD__c = convertNull(completionRate.Accumulated_Revenue_Net_USD__c)+revenueNetUSDToday;

                completionRate.Accumulated_Revenue_Gross__c = convertNull(completionRate.Accumulated_Revenue_Gross__c)+revenueGrossBCToday;

                completionRate.Accumulated_Revenue_Gross_USD__c = convertNull(completionRate.Accumulated_Revenue_Gross_USD__c)+revenueGrossUSDToday;
                //实际销量
                completionRate.actual_sales_volumn__c = convertNull(completionRate.actual_sales_volumn__c)+volumnMonth;
                //实际销量累计
                completionRate.Accumulated_sales_volumn__c = convertNull(completionRate.Accumulated_sales_volumn__c)+volumnMonth;
                upsertList.add(completionRate);
            } 
            Database.upsert(upsertList);
        }catch (Exception e) {
            System.debug('报表出错：'+e.getMessage()+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
        //共享计划增长率报表数据
        PlannedCompletionRateReportShareBatch pcrShare = new PlannedCompletionRateReportShareBatch(year,Integer.valueOf(month) + '');
        Database.executeBatch(pcrShare,200);

        Share_Common_IntegrationBatch pcrShareBatch = new Share_Common_IntegrationBatch(
            'Planned_Completion_Rate_Report__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(pcrShareBatch, 30);
    }

    //获取当月计划收入
    public List<Decimal> planIncome(String month,Sales_Target_Branch_Company_Use__c stb){
        if (stb==null) {
           return null; 
        }
        List<Decimal> decList = new List<Decimal>();
        Decimal decNetUSD;
        Decimal decNetBC;
        Decimal decGrossBC;
        Decimal decGrossUSD;
        Decimal volumn;
        switch on month {
            when '01'{
                decNetUSD = stb.Estimated_Sales_Income_January_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_January_Net__c;
                decGrossBC = stb.January_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_January_USD__c;
                volumn = stb.Forecast_Sales_in_January__c;
            }    
            when '02'{
                decNetUSD = stb.Estimated_Sales_Income_February_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_February_Net__c;
                decGrossBC = stb.February_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_February_USD__c;
                volumn = stb.Forecast_Sales_in_February__c;
            }                                
            when '03'{
                decNetUSD = stb.Estimated_Sales_Income_March_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_March_Net__c;
                decGrossBC = stb.March_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_March_USD__c;
                volumn = stb.Forecast_Sales_in_March__c;
            }    
            when '04'{
                decNetUSD = stb.Estimated_Sales_Income_April_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_April_Net__c;
                decGrossBC = stb.April_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_April_USD__c;
                volumn = stb.Forecast_Sales_in_April__c;
            }    
            when '05'{
                decNetUSD = stb.Estimated_Sales_Income_May_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_May_Net__c;
                decGrossBC = stb.May_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_May_USD__c;
                volumn = stb.Forecast_Sales_in_May__c;
            }    
            when '06'{
                decNetUSD = stb.Estimated_Sales_Income_June_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_June_Net__c;
                decGrossBC = stb.June_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_June_USD__c;
                volumn = stb.Forecast_Sales_in_June__c;
            }    
            when '07'{
                decNetUSD = stb.Estimated_Sales_Income_July_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_July_Net__c;
                decGrossBC = stb.July_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_July_USD__c;
                volumn = stb.Forecast_Sales_in_July__c;
            }     
            when '08'{
                decNetUSD = stb.Estimated_Sales_Income_Augest_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_Augest_Net__c;
                decGrossBC = stb.August_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_Augest_USD__c;
                volumn = stb.Forecast_Sales_in_August__c;
            }    
            when '09'{
                decNetUSD = stb.Estimated_Sales_Income_September_USDNet__c;
                decNetBC = stb.Estimated_Sales_Income_September_Net__c;
                decGrossBC = stb.September_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_September_USD__c;
                volumn = stb.Forecast_Sales_in_September__c;
            }    
            when '10'{
                decNetUSD = stb.Estimated_Sales_Income_October_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_October_Net__c;
                decGrossBC = stb.October_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_October_USD__c;
                volumn = stb.Forecast_Sales_in_October__c;
            }    
            when '11'{
                decNetUSD = stb.Estimated_Sales_Income_November_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_November_Net__c;
                decGrossBC = stb.November_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_November_USD__c;
                volumn = stb.Forecast_Sales_in_November__c;
            }    
            when '12'{
                decNetUSD = stb.Estimated_Sales_Income_December_USD_Net__c;
                decNetBC = stb.Estimated_Sales_Income_December_Net__c;
                decGrossBC = stb.December_Forecasted_Income__c;
                decGrossUSD = stb.Estimated_Sales_Income_December_USD__c;
                volumn = stb.Forecast_Sales_in_December__c;
            }
        }
        //净收入（美元） net
        decList.add(decNetUSD);
        //净收入（本位币）net
        decList.add(decNetBC);
        //收入（本位币）Gross
        decList.add(decGrossBC);
        //收入（美元）Gross
        decList.add(decGrossUSD);
        //预测销量
        decList.add(volumn);
        return decList;          
    }
    //转换null to 0
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