global class ChannelSalesCountSchedulable implements Schedulable{

    // 是否区分渠道
    Boolean flag;
    // 区组
    private String salesRegion;
    // 年份
    private Integer dateYear;
    // 月份 
    private Integer dateMonth;
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();

    public ChannelSalesCountSchedulable(String salesRegion,Integer dateYear,Integer dateMonth,Boolean flag) {
        this.salesRegion = salesRegion;
        this.dateYear = dateYear;
        this.dateMonth = dateMonth;
        this.flag = flag;
    }

    global void execute(SchedulableContext sc){
        String newYearMonth = String.valueOf(dateYear) + dateMonth;
        List<Channel_Sales_Count__c> delList = new List<Channel_Sales_Count__c>();
        if(flag){
            delList = [SELECT Id FROM Channel_Sales_Count__c where Date__c =: newYearMonth AND Sales_Region__c =: salesRegion AND type__c = 'yes'];
        }else{
            delList = [SELECT Id FROM Channel_Sales_Count__c where Date__c =: newYearMonth AND Sales_Region__c =: salesRegion AND type__c = 'no'];
        }
        if(delList != null && delList.size() > 0){
            Database.delete(delList);        
        }
        List<Channel_Sales_Count__c> data = channelSalesCountDateHandling();
        Database.insert(data);
    }

    private List<Channel_Sales_Count__c> channelSalesCountDateHandling(){
        // 汇总统计信息
        List<Channel_Sales_Count__c> channelSalesCountDate = new List<Channel_Sales_Count__c>();

        // 根据条件查询DailySales
        List<Retail_Number__c> dailySalesList = [SELECT Id,
                                                        Reportyear__c,
                                                        Sales_Region__c,
                                                        Reportmonth__c,
                                                        Shop__c,
                                                        Product_Line__c,
                                                        TotalPrice__c,Number__c,
                                                        CurrencyIsoCode 
                                                        FROM Retail_Number__c 
                                                        where Shop__c != null 
                                                        AND Sales_Region__c =: salesRegion
                                                        AND Reportyear__c =: dateYear 
                                                        AND Reportmonth__c =: dateMonth];

        if(Test.isRunningTest()){
            dailySalesList = [SELECT Id,
                                    Reportyear__c,
                                    Sales_Region__c,
                                    Reportmonth__c,
                                    Shop__c,
                                    Product_Line__c,
                                    TotalPrice__c,Number__c, 
                                    CurrencyIsoCode
                                    FROM Retail_Number__c];
        }
        if(dailySalesList != null && dailySalesList.size() > 0){

            // 转换当前数据的汇率
            for(Retail_Number__c itemRate : dailySalesList){
                Decimal rate = currencyRateMap.get(itemRate.CurrencyIsoCode);
                Decimal sales = itemRate.TotalPrice__c / rate;
                itemRate.TotalPrice__c = sales;
            }

            LisqContainer lcDaily = new LisqContainer(dailySalesList);
            // 获取去重后的店铺id
            Set<String> shopId = new Set<String>();
            Map<string,LisqContainer> shopIdLc = lcDaily.GroupByS('Shop__c');
            shopId = shopIdLc.keySet();

            // 获取所有门店信息
            List<Shop__c> shopList = [SELECT Id,
                                            Account__c,
                                            Account_Name__c,
                                            Sales_Region__c,
                                            Channel_Code_Formula__c,
                                            Channel_Name_Formula__c,
                                            Number_Of_Store_Staff__c 
                                            FROM Shop__c 
                                            where id IN: shopId];
            LisqContainer lcShop = new LisqContainer(shopList);

            // 根据id分组门店信息
            Map<String,SObject> shopMap = lcShop.ToMapS('Id');

            // 根据客户ID分组门店信息
            Map<String,SObject> shopAcMap = lcShop.ToMapS('Account__c');

            // 根据渠道code分组门店信息
            Map<String,SObject> shopCaMap = lcShop.ToMapS('Channel_Code_Formula__c');

            if(flag){
                // 存放根据客户分组的daily sales详情信息
            Map<String,List<Retail_Number__c>> lcShopOb = new Map<String,List<Retail_Number__c>>();
            // 根据客户分组
            for(Retail_Number__c item : dailySalesList){
                List<Retail_Number__c> itemRn = new List<Retail_Number__c>();
                // 获取当前daily sales门店详情信息
                Shop__c shopc = (Shop__c)shopMap.get(item.Shop__c);
                String accountId = shopc.Account__c;
                if(lcShopOb.get(accountId) == null){
                    itemRn.add(item);
                    lcShopOb.put(accountId,itemRn);
                }else{
                    List<Retail_Number__c> oldList = lcShopOb.get(accountId);
                    oldList.add(item);
                    lcShopOb.put(accountId,oldList);
                }
            }

            // 根据渠道分组
            for(String itemAccount : lcShopOb.keySet()){

                // 存放根据渠道分组的daily sales详情信息
                Map<String,List<Retail_Number__c>> lcChannelOb = new Map<String,List<Retail_Number__c>>();

                List<Retail_Number__c> channelRn = lcShopOb.get(itemAccount);
                for(Retail_Number__c itemChannel : channelRn){
                    List<Retail_Number__c> itemRn = new List<Retail_Number__c>();
                    // 获取当前daily sales门店详情信息
                    Shop__c shopc = (Shop__c)shopMap.get(itemChannel.Shop__c);
                    String channelCode = shopc.Channel_Code_Formula__c;
                    if(lcChannelOb.get(channelCode) == null){
                        itemRn.add(itemChannel);
                        lcChannelOb.put(channelCode,itemRn);
                    }else{
                        List<Retail_Number__c> oldList = lcChannelOb.get(channelCode);
                        oldList.add(itemChannel);
                        lcChannelOb.put(channelCode,oldList);
                    }
                }

                Map<String,LisqContainer> channelMap = new Map<String,LisqContainer>();
                // 转换成对应的Map<String,LisqContainer>格式
                for(String itemChannel : lcChannelOb.keySet()){
                    channelMap.put(itemChannel, new LisqContainer(lcChannelOb.get(itemChannel)));
                }

                for(String channelCode : channelMap.keySet()){
                    LisqContainer lcCname = channelMap.get(channelCode);

                    // 根据客户Id获取渠道名称信息
                    String accountName = '';
                    Shop__c shopAc = (Shop__c)shopAcMap.get(itemAccount);
                    if(shopAc != null){
                        accountName = shopAc.Account_Name__c;
                    }

                    // 根据渠道编码获取渠道名称信息
                    String channelName = '';
                    Shop__c shopCa = (Shop__c)shopCaMap.get(channelCode);
                    if(shopCa != null){
                        channelName = shopCa.Channel_Name_Formula__c;
                    }
            
                    channelSalesStats(lcCname,shopMap,'yes',channelName,accountName,channelSalesCountDate);
                }
            }
            }else{
                // 不区分客户渠道信息
                channelSalesStats(lcDaily,shopMap,'no','','',channelSalesCountDate);  
            }
        }
        return channelSalesCountDate;
    }

    public void channelSalesStats(LisqContainer lc,
                                    Map<String,SObject> shop,String type,
                                    String channelName,String accountName,
                                    List<Channel_Sales_Count__c> dateList){
        Map<String,LisqContainer> lcProductLine = lc.GroupByS('Product_Line__c');
        for(String productLine : lcProductLine.keySet()){

            LisqContainer lcPl = lcProductLine.get(productLine);

            // 汇总销售额
            Decimal totalPriceCount = 0;
            List<String> totalPrice = lcPl.SelectSField('TotalPrice__c');
            for(String price : totalPrice){
                totalPriceCount += Decimal.valueOf(price);
            }
            
            // 汇总销售量
            Decimal quantitiesCount = 0;
            List<String> quantities = lcPl.SelectSField('Number__c');
            for(String quan : quantities){
                quantitiesCount += Decimal.valueOf(quan);
            }

            Map<String,SObject> shopToMap = lcPl.ToMapS('Shop__c');
            // 汇总当前分组下Daily sales的门店数
            Integer shopNum = shopToMap.size();

            // 汇总当前daily sales门店下所有人员
            Decimal spmQty = 0;
            for(String shopItem : shopToMap.keySet()){
                Shop__c shopItemO = (Shop__c)shop.get(shopItem);
                spmQty += shopItemO.Number_Of_Store_Staff__c;
            }

            // 计算店均
            Decimal storeAverage = 0;
            if(shopNum != 0){
                storeAverage = totalPriceCount/shopNum;
            }

            // 计算人均
            Decimal perCapita = 0;
            if(spmQty != 0){
                perCapita = totalPriceCount/spmQty;
            }

            Channel_Sales_Count__c data = new Channel_Sales_Count__c();
            data.Type__c = type;
            data.Sales_region__c = salesRegion;
            data.Date__c = String.valueOf(dateYear) + dateMonth;
            data.Customer_Name__c = accountName;
            data.Channel_Name__c = channelName;
            data.Product_Line__c = productLine;
            data.Sales_Revenue__c = totalPriceCount;
            data.Sales_Volume__c = quantitiesCount;
            data.Shop_Num__c = shopNum;
            data.Spm_Qty__c = spmQty;
            data.Store_Average__c = storeAverage;
            data.Per_Capita__c = perCapita;
            data.CurrencyIsoCode = 'USD';
            dateList.add(data);
        }
    }

}