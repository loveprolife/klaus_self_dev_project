global class AseanProductSummaryBatch implements Database.Batchable<sObject> {
    //预置国家
    public String[] aseanSales = new String[] {'Hisense Thailand', 'Hisense Malaysia', 'Hisense Indonesia', 'Hisense Vietnam', 'Hisense Philippines', 'Hisense Singapore'};

    /* 用于判断“今天” */
    private final Date TODAY = Date.today();

    private final Date LASTTODAY = Date.today().addMonths(Integer.valueOf(Label.Asean_Statistics_Buff));

    /* 起始：拉所有明细 */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('日期解析' + LASTTODAY);
        return Database.getQueryLocator([
            SELECT Sales_Region__c,
                   ReportDate__c,
                   Product_Line__c,
                   Number__c
            FROM   Retail_Number__c
            WHERE  ReportDate__c != null
            AND    Product__r.High_End_Model_Asean__c = 'High-End' 
            AND ReportDate__c >=: LASTTODAY And ReportDate__c <=: TODAY 
            AND Status__c ='Submitted' 
            And Sales_Region__c IN:(aseanSales)
        ]);
    }

    /* Max:100SQL;50000rows */
    public void execute(Database.BatchableContext bc, List<Retail_Number__c> scope) {
        System.debug('数据量' + scope.size());
        /* 1. 汇总容器 */
        Map<String, ASEAN_Product_Daily__c>   dayMap   = new Map<String, ASEAN_Product_Daily__c>();
        Map<String, ASEAN_Product_Summary__c> monthMap = new Map<String, ASEAN_Product_Summary__c>();

        /* 2. 先跑一遍 scope 累加日/月基础量 */
        for (Retail_Number__c r : scope) {
            String leftPaddedMonth = String.valueOf(r.ReportDate__c.month()).leftPad(2, '0');

            String dayKey   = r.Sales_Region__c + '|' + r.ReportDate__c.format();
            String monthKey = r.Sales_Region__c + '|' + r.ReportDate__c.year() + '-' +
                  leftPaddedMonth;
            // System.debug('逻辑年月' + monthKey);    
            /* 日表对象 */
            if (!dayMap.containsKey(dayKey)) {
                dayMap.put(dayKey, new ASEAN_Product_Daily__c(
                    SBU__c        = r.Sales_Region__c,
                    ReportDate__c = r.ReportDate__c,
                    ExternalKey__c = dayKey,
                    TV_Qty__c = 0, WM_Qty__c = 0,
                    AC_Qty__c = 0, Ref_Qty__c = 0,
                    Last_Sync__c = System.now()
                ));
            }

            /* 月表对象 —— 只初始化一次 */
            if (!monthMap.containsKey(monthKey)) {
                monthMap.put(monthKey, new ASEAN_Product_Summary__c(
                    SBU__c        = r.Sales_Region__c,
                    YearMonth__c  = monthKey.split('\\|')[1],
                    ExternalKey__c = monthKey,
                    TV_Today_Qty__c = 0, TV_Month_Qty__c = 0,
                    TV_Month_Qty_LY__c = 0, TV_Year_Qty__c = 0, TV_Year_Qty_LY__c = 0,
                    WM_Today_Qty__c = 0, WM_Month_Qty__c = 0, WM_Month_Qty_LY__c = 0,
                    WM_Year_Qty__c = 0, WM_Year_Qty_LY__c = 0,
                    AC_Today_Qty__c = 0, AC_Month_Qty__c = 0, AC_Month_Qty_LY__c = 0,
                    AC_Year_Qty__c = 0, AC_Year_Qty_LY__c = 0,
                    Ref_Today_Qty__c = 0, Ref_Month_Qty__c = 0, Ref_Month_Qty_LY__c = 0,
                    Ref_Year_Qty__c = 0, Ref_Year_Qty_LY__c = 0,
                    Total_Today_Qty__c = 0, Total_Month_Qty__c = 0, Total_Month_Qty_LY__c = 0,
                    Total_Year_Qty__c = 0, Total_Year_Qty_LY__c = 0,
                    Last_Sync__c = System.now()
                ));
            }

            ASEAN_Product_Daily__c   day   = dayMap.get(dayKey);
            ASEAN_Product_Summary__c month = monthMap.get(monthKey);

            /* 通用累加方法 */
            addQty(day, month, r);
        }

        /*  收集区域、年份用于同比查询 */
        Set<String> regions = new Set<String>();
        Set<Integer> years = new Set<Integer>();
        for (String mk : monthMap.keySet()) {
            String[] p = mk.split('\\|');
            regions.add(p[0]);
            years.add(Integer.valueOf(p[1].substring(0, 4)));
        }
        // System.debug('收集年月' + years);    
        Map<String, Decimal> lastYearMonthMap = new Map<String, Decimal>();

        List<Integer> yearList = new List<Integer>(years);
        yearList.sort();                      
        // Integer maxYear = yearList[yearList.size() - 1];
        // Integer lastYear = maxYear - 1;


        String query1 = 'SELECT CreatedBy.Sales_Region__c reg, CALENDAR_YEAR(ReportDate__c) yr, ' +
                        'Product__r.Product_Line__c pl, ' +
                        'CALENDAR_MONTH(ReportDate__c) mth, SUM(Number__c) qty ' +
                        'FROM Retail_Number__c ' +
                        'WHERE CreatedBy.Sales_Region__c IN :regions ' +
                        'AND Product__r.High_End_Model_Asean__c = \'High-End\' ' +
                        'AND Status__c = \'Submitted\' ' +
                        'AND CALENDAR_YEAR(ReportDate__c) IN (' + String.join(yearList, ',') + ')' +
                        ' GROUP BY CreatedBy.Sales_Region__c,Product__r.Product_Line__c, CALENDAR_YEAR(ReportDate__c), CALENDAR_MONTH(ReportDate__c)';

        System.debug('Constructed Query 1: ' + query1);
        // Map<String,Decimal> totalMonthMap = new Map<String,Decimal>(); 
        for (AggregateResult ar : Database.query(query1)) {
            String reg = (String)ar.get('reg');
            String pl = (String)ar.get('pl');
            Integer yr = (Integer)ar.get('yr');
            Integer mth = (Integer)ar.get('mth');
            String leftPaddedMonth = String.valueOf(mth).leftPad(2, '0');
            String key = reg + '|' + (yr + 1) + '-' + leftPaddedMonth;
            if(!lastYearMonthMap.containsKey(key)) {
                lastYearMonthMap.put(key, (Decimal)ar.get('qty'));
            } else {
                lastYearMonthMap.put(key, lastYearMonthMap.get(key) + (Decimal)ar.get('qty'));
            }
            
            // lastYearMonthMap.put(key, (Decimal)ar.get('qty'));
            lastYearMonthMap.put(reg + '|' + (yr + 1) + leftPaddedMonth + '-' + pl, (Decimal)ar.get('qty'));
        }

        /* 本年累计 & 去年全年累计（用于年同比）*/
        // Map<String, Decimal> yearToDateMap = new Map<String, Decimal>();
        Map<String, Decimal> lastYearTotalMap = new Map<String, Decimal>();

        String query2 = 'SELECT CreatedBy.Sales_Region__c reg, ' +
                        'Product__r.Product_Line__c pl, ' +
                        'CALENDAR_YEAR(ReportDate__c) yr, ' +
                        'SUM(Number__c) qty ' +
                        'FROM Retail_Number__c ' +
                        'WHERE CreatedBy.Sales_Region__c IN :regions ' +
                        'AND Product__r.High_End_Model_Asean__c = \'High-End\' ' +
                        'AND Status__c = \'Submitted\' ' +
                        'AND CALENDAR_YEAR(ReportDate__c) IN (' + String.join(yearList, ',') + ')' +
                        ' GROUP BY CreatedBy.Sales_Region__c,Product__r.Product_Line__c, CALENDAR_YEAR(ReportDate__c)';

        System.debug('Constructed Query 2: ' + query2);


        for (AggregateResult ar : Database.query(query2)) {
            String reg = (String)ar.get('reg');
            Integer yr = (Integer)ar.get('yr');
            Decimal qty = (Decimal)ar.get('qty');
            String pl = (String)ar.get('pl');
            String key = reg + '|' + (yr + 1);
            // if (yearList.containsyr) {
            //     yearToDateMap.put(reg + '|' + yr, qty);
            // } else {
                lastYearTotalMap.put(reg + '|' + (yr + 1)  + '-' + pl, qty);
            // }
            if(!lastYearTotalMap.containsKey(key)) {
                lastYearTotalMap.put(key, (Decimal)ar.get('qty'));
            } else {
                lastYearTotalMap.put(key, lastYearTotalMap.get(key) + (Decimal)ar.get('qty'));
            }
            // lastYearTotalMap.put(reg + '|' + yr, qty);

        }

        /*  回填月表同比字段 */
        for (ASEAN_Product_Summary__c m : monthMap.values()) {
            String[] p = m.ExternalKey__c.split('\\|');
            String reg = p[0];
            String ym  = p[1];
            Integer yr = Integer.valueOf(ym.substring(0, 4));
            System.debug('解析过去数据月' + lastYearMonthMap);
            System.debug('解析过去数据年' + lastYearTotalMap);
            calculateYearOverYear(m, reg, yr, ym, lastYearMonthMap, lastYearTotalMap, 'TV_');
            calculateYearOverYear(m, reg, yr, ym, lastYearMonthMap, lastYearTotalMap, 'WM_');
            calculateYearOverYear(m, reg, yr, ym, lastYearMonthMap, lastYearTotalMap, 'AC_');
            calculateYearOverYear(m, reg, yr, ym, lastYearMonthMap, lastYearTotalMap, 'Ref_');
            calculateTotalYearOverYear(m, reg, yr, ym, lastYearMonthMap, lastYearTotalMap);
        }

        /* 7. 批量 upsert */
        if (!dayMap.isEmpty()) upsert dayMap.values() ExternalKey__c;
        if (!monthMap.isEmpty()) upsert monthMap.values() ExternalKey__c;
    }


    public void finish(Database.BatchableContext bc) {
        Utility.refreshReportCustom('AseanProductSummaryBatch');
    }

    private void calculateYearOverYear(ASEAN_Product_Summary__c m,
                                       String reg,
                                       Integer yr,
                                       String ym,
                                       Map<String, Decimal> lastYearMonthMap,
                                       Map<String, Decimal> lastYearTotalMap,
                                       String productPrefix) {
        // String leftPaddedMonth = String.valueOf(r.ReportDate__c.month()).leftPad(2, '0');
        String key = productPrefix.contains('Ref') ? 'Refrigerator' : productPrefix.substringBefore('_');
        System.debug('获取的Kay' + reg + '|' + yr + ym.substring(5) + '-' + key);
        Decimal lyMonth = lastYearMonthMap.get(reg + '|' + yr + ym.substring(5) + '-' + key);
        lyMonth = (lyMonth == null ? 0 : lyMonth);
        
        Decimal lyTotal = lastYearTotalMap.get(reg + '|' + yr + '-' + key);
        lyTotal = (lyTotal == null ? 0 : lyTotal);
        System.debug('过去月数据 + 过去年数据'  + lyMonth + ':' + lyTotal);
        m.put(productPrefix + 'Month_Qty_LY__c', lyMonth);
        m.put(productPrefix + 'Year_Qty_LY__c', lyTotal);

        Decimal currentMonthQty = (Decimal)m.get(productPrefix + 'Month_Qty__c');
        Decimal currentYearQty = (Decimal)m.get(productPrefix + 'Year_Qty__c');

        m.put(productPrefix + 'YoY_Month__c', (lyMonth == 0 ? null : ((currentMonthQty - lyMonth) / lyMonth) ));
        m.put(productPrefix + 'YoY_Year__c', (lyTotal == 0 ? null : ((currentYearQty - lyTotal) / lyTotal) ));
    }

    private void calculateTotalYearOverYear(ASEAN_Product_Summary__c m,
                                            String reg,
                                            Integer yr,
                                            String ym,
                                            Map<String, Decimal> lastYearMonthMap,
                                            Map<String, Decimal> lastYearTotalMap) {
        Decimal lyMonth = lastYearMonthMap.get(reg + '|' + yr + '-' + ym.substring(5));
        lyMonth = (lyMonth == null ? 0 : lyMonth);

        Decimal lyTotal = lastYearTotalMap.get(reg + '|' + yr);
        lyTotal = (lyTotal == null ? 0 : lyTotal);

        m.Total_Month_Qty_LY__c = lyMonth;
        m.Total_Year_Qty_LY__c = lyTotal;

        Decimal currentMonthQty = m.Total_Month_Qty__c;
        Decimal currentYearQty = m.Total_Year_Qty__c;

        m.Total_YoY_Month__c = (lyMonth == 0 ? null : ((currentMonthQty - lyMonth) / lyMonth) );
        m.Total_YoY_Year__c = (lyTotal == 0 ? null : ((currentYearQty - lyTotal) / lyTotal) );
    }

    /* 通用累加逻辑 */
    private void addQty(ASEAN_Product_Daily__c d,
                        ASEAN_Product_Summary__c m,
                        Retail_Number__c r) {

        String prod = r.Product_Line__c;
        Decimal qty = r.Number__c;
        Decimal totalQty = 0;

        /* 日表累加 */
        if (prod == 'TV')          d.TV_Qty__c  += qty;
        else if (prod == 'WM')     d.WM_Qty__c  += qty;
        else if (prod == 'AC')     d.AC_Qty__c  += qty;
        else if (prod == 'Refrigerator') d.Ref_Qty__c += qty;

        /* 月表累加  todo 精简*/
        if (prod == 'TV') {
            m.TV_Month_Qty__c += qty;
            m.TV_Year_Qty__c  += qty;
            if (r.ReportDate__c == TODAY) {
                m.TV_Today_Qty__c += qty;
                totalQty += m.TV_Today_Qty__c;
            }
        } else if (prod == 'WM') {
            m.WM_Month_Qty__c += qty;
            m.WM_Year_Qty__c  += qty;
            if (r.ReportDate__c == TODAY) {
                m.WM_Today_Qty__c += qty;
                totalQty += m.WM_Today_Qty__c;
            }
        } else if (prod == 'AC') {
            m.AC_Month_Qty__c += qty;
            m.AC_Year_Qty__c  += qty;
            if (r.ReportDate__c == TODAY) {
                m.AC_Today_Qty__c += qty;
                totalQty += m.AC_Today_Qty__c;
            }
        } else if (prod == 'Refrigerator') {
            m.Ref_Month_Qty__c += qty;
            m.Ref_Year_Qty__c  += qty;
            if (r.ReportDate__c == TODAY) {
                m.Ref_Today_Qty__c += qty;
                totalQty += m.Ref_Today_Qty__c;
            }
        }

        m.Total_Today_Qty__c = totalQty;
        m.Total_Month_Qty__c = m.Ref_Month_Qty__c + m.AC_Month_Qty__c + m.WM_Month_Qty__c + m.TV_Month_Qty__c;
        m.Total_Year_Qty__c = m.Ref_Year_Qty__c + m.AC_Year_Qty__c + m.WM_Year_Qty__c + m.TV_Year_Qty__c;
    }



}