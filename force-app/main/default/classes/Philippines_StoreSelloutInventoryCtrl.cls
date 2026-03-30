public without sharing class Philippines_StoreSelloutInventoryCtrl {

    public Class DataInfo{
        public String productLine;
        public Integer quantity;
        public Integer tStock;
        public Integer aStock;
        public Integer transit;
        public String chatId;
    }

    public Class DetailInfo{
        public String create_dt;
        public String productLine;
        public String cust_model;
        public Integer act_qty;
        public Integer Tot_SOH;
        public Integer Avl_SOH;
        // public Integer st_intr;
        public Decimal Supportable_Days;
        public String Stock_Status;

        //暂时按照 ID（LookUp）记录
        public String shopId;
        public String channelId;
        public Decimal price;

        // 新增字段展示当月submitted的sellout数量 YYL 20250116
        public Decimal MTDSales;
    }

    public Class InitDataWarp{
        public List<DataInfo> dataList;
        public List<DetailInfo> detailList;
    }

    @AuraEnabled 
    public static String initDetail(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.detailList = new List<DetailInfo>();
        Map<String, String> prdln = Utility.getPicklistValueMap('Product__c','Product_Line__c');
        Date nowE = Date.today().addDays(1);
        
        // 获取当月的第一天
        Date nowS = Date.today().addDays(-28);
        // Date nowS = Date.newInstance(nowE.year(), nowE.month(), 1);

        System.debug('数据集nowS' + nowS);
        System.debug('数据集nowE' + nowE);
        // List<Shop__c> store = [Select Id,Sales_Region__c From Shop__c Where Id =: accId];
        list<Retail_Number__c> soiList = [Select ReportDate__c,PromoterDailyReport__r.Report_Date__c,Shop__c, Shop__r.Channel_item__c,ProductLine__c,Product_Model__c,Number__c,Price__c,Total_Stock__c,Available_Stock__c,Stock_In_Transit__c,Supportable_Days__c,Stock_Status__c,TotalPrice__c From Retail_Number__c where Shop__c =: accId And Product_Model__c != null And Status__c = 'Submitted' And PromoterDailyReport__r.Report_Date__c >=: nowS And PromoterDailyReport__r.Report_Date__c <=: nowE order by PromoterDailyReport__r.Report_Date__c desc];
        List<Promotional_Stock__c> stocks = [select Id,Product_Model__c, Promoter_Daily_Report__r.Report_Date__c, Product_Model__r.Name, Product_Line__c,SaveDate__c, ReportDate__c, Promoter_Daily_Report__c, Quantities__c, Store__c,Status__c from Promotional_Stock__c where Store__c =: accId And Status__c = 'Submitted' And SaveDate__c >=: nowS And SaveDate__c <=: nowE];
 
        System.debug('数据集Num' + soiList);
        System.debug('数据集Sto' + stocks);
        // 用于存储结果的Map，键为ProductName，值为最新的Number
        Map<String, Decimal> latestNumberByProductName = new Map<String, Decimal>();
        
        // 用于存储每个ProductName中Date最新的记录
        Map<String, Promotional_Stock__c> latestStockByProductName = new Map<String, Promotional_Stock__c>();
        
        // 遍历所有记录，找出每个ProductName中Date最新的记录
        for (Promotional_Stock__c stock : stocks) {
            if (!latestStockByProductName.containsKey(stock.Product_Model__r.Name) || 
                stock.SaveDate__c > latestStockByProductName.get(stock.Product_Model__r.Name).SaveDate__c) {
                latestStockByProductName.put(stock.Product_Model__r.Name, stock);
            }
        }
        
        // 提取每个ProductName最新的Number
        for (String productName : latestStockByProductName.keySet()) {
            latestNumberByProductName.put(productName, latestStockByProductName.get(productName).Quantities__c);
        }
    
        Map<String, Retail_Number__c> maxMap = new Map<String, Retail_Number__c>();
        for (Retail_Number__c stock : soiList) {
            if (maxMap.containsKey(stock.Product_Model__c)) {

                Retail_Number__c productLineTotals = maxMap.get(stock.Product_Model__c);
                Decimal numTotal = maxMap.get(stock.Product_Model__c).Number__c + stock.Number__c;
                productLineTotals.Number__c = numTotal;

                //2025-4-3 Sales volume计算合计TotalPrice__c
                Decimal numTotalPrice = productLineTotals.TotalPrice__c + stock.TotalPrice__c;
                productLineTotals.TotalPrice__c = numTotalPrice;

                maxMap.put(stock.Product_Model__c, productLineTotals);
            } else {
                maxMap.put(stock.Product_Model__c, stock);
            }
        }

        Map<String, Promotional_Stock__c> filterAfter = filterMaps(maxMap,latestStockByProductName);
        System.debug('latestNumberByProductName' + latestNumberByProductName);
        for (String key : maxMap.keySet()) {
            Retail_Number__c value = maxMap.get(key);
            DetailInfo di = new DetailInfo();
            DateTime myDateTime = value.PromoterDailyReport__r.Report_Date__c; // 将Date转换为DateTime
            String formattedDate = myDateTime.format('yyyy-MM-dd');
            // di.create_dt = (value.PromoterDailyReport__r.Report_Date__c).format();
            di.create_dt = formattedDate;

            di.productLine = value.ProductLine__c;
            di.cust_model = value.Product_Model__c;
            Decimal totNum;
            if(latestNumberByProductName.get(value.Product_Model__c) != null) {
                totNum = latestNumberByProductName.get(value.Product_Model__c);
            } else {
                totNum = 0;
            }
            
            System.debug('totNum' + totNum);
            if(value.Number__c != null){
                di.act_qty = value.Number__c.intValue();
            }else{
                di.act_qty = 0;
            }
            if(totNum != 0){
                di.Tot_SOH = totNum.intValue();
            }else{
                di.Tot_SOH = 0;
            }

            di.price = value.TotalPrice__c;
            di.shopId = value.Shop__c;
            di.channelId = value.Shop__r.Channel_item__c;
            //计算 28天的总数
            //Date createdt4 = Date.valueOf(value.ReportDate__c).addDays(-28);
            //list<Retail_Number__c> retailList = [Select ReportDate__c,Shop__c, Shop__r.Channel_item__c,ProductLine__c,Product_Model__c,Number__c,Price__c,Total_Stock__c,Available_Stock__c,Stock_In_Transit__c,Supportable_Days__c,Stock_Status__c from Retail_Number__c where Shop__c = :accid and ReportDate__c >= :createdt4 and Product_Model__c != null];
            
            //Integer Inventoryw4 = Philippines_StoreSelloutInventoryCtrl.getSumInt(value.Product_Model__c, createdt4, retailList);
            Integer Inventoryw4 = di.act_qty;
            Decimal w4;
            Decimal oneDayByW4;
            if(Inventoryw4 > 0 && totNum > 0) {
                w4 = (Decimal)Inventoryw4 / 28;
                w4 = w4.setScale(2);
                oneDayByW4 = ((Decimal)totNum / w4);
                oneDayByW4 = oneDayByW4.setScale(2); 
            } else {
                w4 = Decimal.valueOf('0');
                oneDayByW4 = Decimal.valueOf('0');
            }
            
            System.debug('result' + oneDayByW4 + ':' + 'w4' + w4);

            Decimal DaysofInventoryw4 = 0;
            // if(w4 < 1){
            //     DaysofInventoryw4 = 0;
            //     di.Supportable_Days = Decimal.valueOf('0');
            // }else{
            //     DaysofInventoryw4 = oneDayByW4;
            //     di.Supportable_Days = oneDayByW4;
            // } 
            // 移除原本逻辑,修改为库存/28平均数 YYL 20250116
            DaysofInventoryw4 = oneDayByW4;
            di.Supportable_Days = oneDayByW4;

            // 计算当前整个月的总数 YYL 20250116
            Date startDate = Date.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + '01');
            Date endDate = startDate.addMonths(1);
            list<Retail_Number__c> retailListMonth = [SELECT ReportDate__c,
                                                             Shop__c, 
                                                             Shop__r.Channel_item__c,
                                                             ProductLine__c,
                                                             Product_Model__c,
                                                             Number__c,
                                                             Price__c,
                                                             Total_Stock__c,
                                                             Available_Stock__c,
                                                             Stock_In_Transit__c,
                                                             Supportable_Days__c,
                                                             Stock_Status__c 
                                                             FROM Retail_Number__c 
                                                             WHERE Shop__c =:accid 
                                                             AND ReportDate__c >= :startDate 
                                                             AND ReportDate__c < :endDate 
                                                             AND Product_Model__c != null];

            Integer InventoryMonth = getSumInt(value.Product_Model__c, startDate, retailListMonth);
            di.MTDSales = InventoryMonth;
            // 修改计算规则 Available stock = Inventory -  MTD sales YYL 20250116
            Integer availableStock = di.Tot_SOH - InventoryMonth;
            di.Avl_SOH = availableStock >= 0?availableStock:0;

            System.debug('W4' + w4 + 'DaysofInventoryw4' +':'+ DaysofInventoryw4 +':'+ 'Supportable_Days' + di.Supportable_Days +'totNum:'+ totNum);
            
            if(w4 > 0){
                if(Integer.valueOf(totNum) <= w4){
                    di.Stock_Status = 'Out of Stock';
                }else if(Integer.valueOf(totNum) > (w4 * 3)){
                    di.Stock_Status = 'Normal';
                }else{
                    di.Stock_Status = 'Replenishment';
                }
            }else if(totNum > 0 && w4 == 0){
                di.Stock_Status = 'Normal';
            }else if(totNum == 0){
                di.Stock_Status = 'Out of Stock';
            }else {
                di.Stock_Status = 'Replenishment';
            }

            initData.detailList.add(di);
        }

        for (String key : filterAfter.keySet()) {
            Promotional_Stock__c value = filterAfter.get(key);
            DetailInfo di = new DetailInfo();
            // Datetime timeOne = value.Report_Date__c;
            // String formattedDate = timeOne.format('yyyy-MM-dd');
            // di.create_dt = (value.Promoter_Daily_Report__r.Report_Date__c).format();
            DateTime myDateTime = value.Promoter_Daily_Report__r.Report_Date__c; // 将Date转换为DateTime
            String formattedDate = myDateTime.format('yyyy-MM-dd');
            // di.create_dt = (value.PromoterDailyReport__r.Report_Date__c).format();
            di.create_dt = formattedDate;
            di.productLine = value.Product_Line__c;
            di.cust_model = value.Product_Model__r.Name;
            di.act_qty = 0;
            di.Tot_SOH = (value.Quantities__c).intValue();
            di.shopId = value.Store__c;
            di.Avl_SOH = di.Tot_SOH;
            di.Supportable_Days = di.Tot_SOH;
            di.Stock_Status = 'Normal';

            initData.detailList.add(di);
        }
        List<Inventory_Sales_Report__c> inventList = new List<Inventory_Sales_Report__c>();
        for (DetailInfo detail : initData.detailList) {
            Inventory_Sales_Report__c invent = new Inventory_Sales_Report__c();

            invent.Product_Line__c = detail.productLine;
            invent.Product_Model__c = detail.cust_model;
            invent.Date__c =  Date.valueOf(detail.create_dt);
            invent.Store__c = detail.shopId;
            invent.Channel__c = detail.channelId;
            invent.Quantity__c = detail.act_qty;
            invent.Inventory__c = detail.Tot_SOH;
            invent.MTD_Sales__c = detail.MTDSales;
            invent.Sales_volume__c = detail.price;
            invent.Available_stock__c = detail.Avl_SOH;
            invent.Stock_Status__c = detail.Stock_Status;
            invent.Stock_in_transit__c = detail.Tot_SOH;
            invent.Unavailable_stock__c = 0;
            invent.Days_of_support__c = detail.Supportable_Days;
            invent.ExternalID__c = detail.shopId + detail.productLine + detail.cust_model;
            inventList.add(invent);
             
        }
        // if(inventList.size()>0 && store[0].Sales_Region__c.equals('Hisense Philippines')) {
        //     Database.upsert(inventList,Inventory_Sales_Report__c.Fields.ExternalID__C,false);
        // }
        if(inventList.size()>0) {
            Database.upsert(inventList,Inventory_Sales_Report__c.Fields.ExternalID__C,false);
        }

        System.debug('initDetail==>>>' +initData);
        return JSON.serialize(initData);
    
    }
    @AuraEnabled 
    public static String initData(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.dataList = new List<DataInfo>();

        // List<Promoter_Daily_Report__c> soiList = [Select Product_Line__c,Report_Date__c,Sales_Quantity__c,Total_Stock__c,Available_Stock__c,Stock_In_Transit__c from Promoter_Daily_Report__c Where Shop__c =: accId And Product_Line__c != null];

        Date nowE = Date.today().addDays(1);
        
        // 获取当月的第一天
        Date nowS = Date.today().addDays(-28);
        // Date nowS = Date.newInstance(nowE.year(), nowE.month(), 1);

        System.debug('数据集nowS' + nowS);
        System.debug('数据集nowE' + nowE);
        List<Promotional_Stock__c> stocks = [select Id,Product_Model__c,  Product_Model__r.Name, Product_Line__c, ReportDate__c,SaveDate__c,Promoter_Daily_Report__r.Report_Date__c, Promoter_Daily_Report__c, Quantities__c, Store__c,Status__c from Promotional_Stock__c where Store__c =: accId And Status__c = 'Submitted' And SaveDate__c >=: nowS And SaveDate__c <=: nowE];
        list<Retail_Number__c> numList = [Select ReportDate__c,ProductLine__c,Product_Model__c,Number__c,Total_Stock__c,Available_Stock__c,Stock_In_Transit__c,Supportable_Days__c,Stock_Status__c From Retail_Number__c where Shop__c =: accId And Product_Model__c != null  And Status__c = 'Submitted' And ReportDate__c >=: nowS And ReportDate__c <=: nowE order by ReportDate__c desc];

        // System.debug('数据集Report' + soiList);
        System.debug('数据集Sto' + stocks);
        System.debug('数据集Num' + numList);


        Map<String, Decimal> productLineSumsByNum = sumNumbersByProductLine(numList);

        // 打印结果
        for (String productLine : productLineSumsByNum.keySet()) {
            System.debug('ProductLine: ' + productLine + ', Total Number: ' + productLineSumsByNum.get(productLine));
        }
        
        // Map<String, Date> maxMap = new Map<String, Date>();
        Map<String, Retail_Number__c> maxMap = new Map<String, Retail_Number__c>();


        //根据产品线获取产品线下型号最近一次的型号数量进行累计加和就是当前门店的产品线的总库存
        Map<String, Date> productLineMaxMap = new Map<String, Date>();
        //销量已累计加和（公式字段）
        
        // 用于存储结果的Map，键为ProductLine，值为Number之和
        Map<String, Decimal> productLineSums = new Map<String, Decimal>();
        
        // 用于存储每个ProductLine中Date最新的记录的parentId
        Map<String, Id> latestParentIdByProductLine = new Map<String, Id>();
        
        // // 首先找出每个ProductLine中Date最新的记录的parentId
        // for (Promotional_Stock__c stock : stocks) {
        //     Promotional_Stock__c latestStock = latestParentIdByProductLine.containsKey(stock.Product_Line__c) ? 
        //                            findLatestStockByProductLine(stocks, stock.Product_Line__c, latestParentIdByProductLine.get(stock.Product_Line__c)) : 
        //                            null;
            
        //     if (latestStock == null || stock.ReportDate__c > latestStock.ReportDate__c) {
        //         latestParentIdByProductLine.put(stock.Product_Line__c, stock.Promoter_Daily_Report__c);
        //     }
        // }
        
        // // 遍历所有记录，累加Number
        // for (Promotional_Stock__c stock : stocks) {
        //     // 如果当前记录的parentId与最新记录的parentId相同
        //     if (latestParentIdByProductLine.containsKey(stock.Product_Line__c) && 
        //         stock.Promoter_Daily_Report__c == latestParentIdByProductLine.get(stock.Product_Line__c)) {
                
        //         // 累加Number
        //         if (productLineSums.containsKey(stock.Product_Line__c)) {
        //             productLineSums.put(stock.Product_Line__c, productLineSums.get(stock.Product_Line__c) + stock.Quantities__c);
        //         } else {
        //             productLineSums.put(stock.Product_Line__c, stock.Quantities__c);
        //         }
        //     }
        // }

        // 存储每个产品线的最新Number
        Map<String, Promotional_Stock__c> latestStocksByMode = new Map<String, Promotional_Stock__c>();

        // 找出每个productMode的最新日期记录
        for (Promotional_Stock__c stock : stocks) {
            if (!latestStocksByMode.containsKey(stock.Product_Model__c) || 
                stock.SaveDate__c > latestStocksByMode.get(stock.Product_Model__c).SaveDate__c) {
                latestStocksByMode.put(stock.Product_Model__c, stock);
            }
        }

        // 存储每个产品线的Number总和
        // Map<String, Decimal> productLineTotals = new Map<String, Decimal>();

        // 对每个产品线的Number进行求和
        for (Promotional_Stock__c latestStock : latestStocksByMode.values()) {
            if (productLineSums.containsKey(latestStock.Product_Line__c)) {
                productLineSums.put(latestStock.Product_Line__c, 
                productLineSums.get(latestStock.Product_Line__c) + latestStock.Quantities__c);
            } else {
                productLineSums.put(latestStock.Product_Line__c, latestStock.Quantities__c);
            }
        }

        // return productLineTotals;
    

        for (Retail_Number__c stock : numList) {
            if (maxMap.containsKey(stock.ProductLine__c)) {

                Retail_Number__c productLineTotals = maxMap.get(stock.ProductLine__c);
                Decimal numTotal = maxMap.get(stock.ProductLine__c).Number__c + stock.Number__c;
                productLineTotals.Number__c = numTotal;
                maxMap.put(stock.ProductLine__c, productLineTotals);
            } else {
                maxMap.put(stock.ProductLine__c, stock);
            }
        }

        Set<String> plSet = new Set<String>();
        Map<String, Decimal> c = new Map<String, Decimal>();
        for (String key : productLineSums.keySet()) {
            if (!maxMap.containsKey(key)) {
                C.put(key, productLineSums.get(key));
            }
        }
        

        for (String key : maxMap.keySet()) {
            Retail_Number__c value = maxMap.get(key);
            DataInfo di = new DataInfo();
            di.productLine = value.ProductLine__c;
            di.quantity = (value.Number__c).intValue();
            di.transit = 0;
            di.tStock = Integer.valueOf(productLineSums.get(value.ProductLine__c));
            di.aStock = Integer.valueOf(productLineSums.get(value.ProductLine__c));
            // di.chatId = report.Id;
            initData.dataList.add(di);

        }

        for (String key : c.keySet()) {
            DataInfo di = new DataInfo();
            di.productLine = key;
            di.quantity = 0;
            di.transit = 0;
            di.tStock = Integer.valueOf(c.get(key));
            di.aStock = Integer.valueOf(c.get(key));
            // di.chatId = report.Id;
            initData.dataList.add(di);
        }

        Map<String, String> prdln = Utility.getPicklistValueMap('Product__c','Product_Line__c');
        List<DataInfo> resultDataList = new List<DataInfo>();
        
        for(DataInfo di : initData.dataList){
            if(String.isNotBlank(prdln.get(di.productLine))){
                di.productLine = prdln.get(di.productLine);
                resultDataList.add(di);
            }
        }

        initData.dataList = resultDataList;

        
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }

    public static Integer getSumInt(String cust_model, Date startDt, list<Retail_Number__c> soiList){
        Integer i = 0;
        for(Retail_Number__c soi : soiList){
            if(soi.Product_Model__c.equals(cust_model) && soi.Number__c != null){
                i += Integer.valueOf(soi.Number__c);
            }
        }
        return i;

    }

    // private static Promotional_Stock__c  findLatestStockByProductLine(List<Promotional_Stock__c> stocks, String productLine, Id parentId) {
    //     Promotional_Stock__c  latestStock = null;
    //     for (Promotional_Stock__c  stock : stocks) {
    //         if (stock.Product_Line__c == productLine && stock.Promoter_Daily_Report__c == parentId && (latestStock == null || stock.SaveDate__c > latestStock.SaveDate__c)) {
    //             latestStock = stock;
    //         }
    //     }
    //     return latestStock;
    // }


    public static Map<String, Promotional_Stock__c> filterMaps(Map<String, Retail_Number__c> A, Map<String, Promotional_Stock__c> B) {
        Map<String, Promotional_Stock__c> C = new Map<String, Promotional_Stock__c>();
        for (String key : B.keySet()) {
            if (!A.containsKey(key)) {
                C.put(key, B.get(key));
            }
        }
        return C;
    }

    public static Map<String, Decimal> sumNumbersByProductLine(List<Retail_Number__c> stocks) {
        Map<String, Decimal> productLineSums = new Map<String, Decimal>();
        for (Retail_Number__c stock : stocks) {
            if (productLineSums.containsKey(stock.ProductLine__c)) {
                productLineSums.put(stock.ProductLine__c, productLineSums.get(stock.ProductLine__c) + stock.Number__c);
            } else {
                productLineSums.put(stock.ProductLine__c, stock.Number__c);
            }
        }

        return productLineSums;
    }
}