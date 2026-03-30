/**
 * Customer_Product_Line__c,Customer_Information__c
 * 插入数据时跑一次
 * 更新客户产品线
 */
 
//UpdateCustomerProductLineBatch
//Customer_Information__c



global class UpdateCustomerProductLineBatch implements Database.Batchable<sObject> {
    public String query;
    // public String year;
    // public String month;


    global UpdateCustomerProductLineBatch() {
        this.query = 'select Id,Customer__r.Id,Customer__r.SAP_Customer_Code__c,Product_Line_Name__c from Customer_Product_Line__c '+
                     ' where Customer__c != null and Customer__r.SAP_Customer_Code__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Product_Line__c> cplList) {

        //更新产品线
        List<Customer_Product_Line__c> updateList = new List<Customer_Product_Line__c>();
        List<Account> accountList = new List<Account>();
        Set<String> cplKeys = new Set<String>();
        Set<String> accountKeys = new Set<String>();

        try {
            //产品线
            Map<String,String> pl = new Map<String,String>();

            pl.put('电视','TV'); //与translate不同 多媒体-电视(LED)
            pl.put('家空','AC'); //与translate不同 多媒体-电视(LED)
            pl.put('洗衣机','WM'); //与translate不同 多媒体-电视(LED)
            pl.put('手机','Mobile');
            pl.put('冰箱','Refrigerator'); //与translate不同 多媒体-电视(LED)
            pl.put('冷柜','Freezer'); //与translate不同 多媒体-电视(LED)
            pl.put('激光影院','Laser TV');
            pl.put('轻商','LCAC');
            pl.put('小家电','Small Domestic Home Appliances');
            pl.put('炉灶具','Cooking');
            pl.put('洗碗机','Dishwasher');
            pl.put('Sound Bar','Sound Bar');
            pl.put('Hitachi Commercial AC','Hitachi Commercial AC');
            pl.put('Medical Device','Medical Device');
            pl.put('商用显示器','B-Monitor');

            Map<String,String> industryPositionMap = new Map<String,String>();
            industryPositionMap.put('TOP客户','Top Channel');
            industryPositionMap.put('非TOP客户','Non-Top Channel');

            Map<String,String> cooperationLevelMap = new Map<String,String>();
            cooperationLevelMap.put('战略客户','Strategic customer');
            cooperationLevelMap.put('优质客户','Advance customer');
            cooperationLevelMap.put('普通客户','Ordinary customer');

            Map<String,String> customerCategoryMap = new Map<String,String>();
            customerCategoryMap.put('电器连锁','Electrical chains');
            customerCategoryMap.put('电商','eCommerce');
            customerCategoryMap.put('超市大卖场/杂货店','Supermarket');
            customerCategoryMap.put('其他','others');
            customerCategoryMap.put('专业渠道','Professional channels');
            customerCategoryMap.put('百货','Department store');
            customerCategoryMap.put('品牌代理','Agent');
            customerCategoryMap.put('OEM','OEM');
            customerCategoryMap.put('Brand Agents','Agent');
            customerCategoryMap.put('独立客户','Independent');
            customerCategoryMap.put('采购集团','Buying group');
            customerCategoryMap.put('批发商','Wholesaler');

            Map<String,String> channelLevelMap = new Map<String,String>();
            channelLevelMap.put('中高端渠道','Mid-High Level');
            channelLevelMap.put('非中高端渠道','Non Mid-High Level');

            List<String> brandList = new List<String>();
            brandList.add('Hisense');
            brandList.add('TOSHIBA');
            brandList.add('SHARP');
            brandList.add('Gorenje');
            brandList.add('ASKO');
            brandList.add('KELON');
            brandList.add('Other（OEM）');
            brandList.add('HITACHI');
            brandList.add('Ronshen');
            brandList.add('YORK');
            brandList.add('Vidda');
            brandList.add('SANDEN');
            brandList.add('聚好看');
            brandList.add('赛维');
            brandList.add('VIDAA');

            //客户管理名称和产品线为key
            Map<String,Customer_Product_Line__c> plMap = new Map<String,Customer_Product_Line__c>();
            
            for(Customer_Product_Line__c cpl : cplList){
                String key = cpl.Customer__r.SAP_Customer_Code__c + cpl.Product_Line_Name__c;
                plMap.put(key, cpl);
            }

            List<Customer_Information__c> ciList = [select Id,Customer_Code__c,Product_Line__c,Customer_Type__c,Channel_Level__c,Store_Number__c,Cooperative_Brand__c,
                    Market_share_in_customer_s_home_country__c,Industry_Position__c,Industry_Rank__c,Cooperation_Level__c,Annual_sales_scale__c,
                    Actual_Sales_Income_Ratio_21_Year__c,Actual_Sales_Income_Ratio_22_Year__c
                    from Customer_Information__c where Customer_Code__c != null];

            for(Customer_Information__c ci : ciList){

                List<String> sapCodes = ci.Customer_Code__c.split('/');

                for(String sapCode : sapCodes){
                    
                    Customer_Product_Line__c cpl = plMap.get(sapCode + pl.get(ci.Product_Line__c));
                    if(cpl != null){
                        //更新客户/客户产品线赋值

                        Account c = new Account();
                        c.Id = cpl.Customer__r.Id;
                        if(customerCategoryMap.get(ci.Customer_Type__c) != null){
                            c.Customer_Category__c = customerCategoryMap.get(ci.Customer_Type__c);
                        }
                        if(channelLevelMap.get(ci.Channel_Level__c) != null){
                            c.Channel_Level__c = channelLevelMap.get(ci.Channel_Level__c);
                        }
                        if(ci.Store_Number__c != null){
                            c.Total_Store_Quantity__c = Integer.valueOf(ci.Store_Number__c);
                        }

                        if(accountKeys.add(c.Id)){
                            accountList.add(c);
                        }

                        if(ci.Industry_Rank__c != null){
                            cpl.Industry_Rank__c = ci.Industry_Rank__c;
                        }
                        if(ci.Market_share_in_customer_s_home_country__c != null){
                            cpl.Market_Share__c = Double.valueOf(ci.Market_share_in_customer_s_home_country__c.replace('%', ''));
                        }
                        if(industryPositionMap.get(ci.Industry_Position__c) != null){
                            cpl.Industry_Position__c = industryPositionMap.get(ci.Industry_Position__c);
                        }
                        if(ci.Annual_sales_scale__c != null){
                            cpl.Annual_sales_scale__c = Double.valueOf(ci.Annual_sales_scale__c);
                        }
                        if(ci.Cooperative_Brand__c != null){
                            List<String> brands = ci.Cooperative_Brand__c.split(';');
                            String b = '';
                            for(String brand : brands){
                                if(containsIgnoreCase(brand,brandList)){
                                    b += brand + ';';
                                }else{
                                    b += 'Other（OEM）;';
                                }
                            }
                            cpl.Brand_work_with_Hisense__c = b.substring(0,b.length() - 1);
                        }


                        if(cooperationLevelMap.get(ci.Cooperation_Level__c) != null){
                            cpl.Cooperation_Level__c = cooperationLevelMap.get(ci.Cooperation_Level__c);
                        }
                        if(ci.Actual_Sales_Income_Ratio_21_Year__c != null){
                            cpl.Actual_Sales_Income_Ratio_N_1_Year__c = Double.valueOf(ci.Actual_Sales_Income_Ratio_21_Year__c.replace('%', ''));
                        }

                        if(ci.Actual_Sales_Income_Ratio_22_Year__c != null){
                            cpl.Actual_Sales_Income_Ratio_N_Year__c = Double.valueOf(ci.Actual_Sales_Income_Ratio_22_Year__c.replace('%', ''));
                        }

                        if(cplKeys.add(cpl.Id)){
                            updateList.add(cpl);
                        }
                    }
                }
            }
            System.debug('更新数据：' + accountList);
            System.debug('更新条数：' + accountList.size());
            Database.update(accountList);

            System.debug('更新数据：' + updateList);
            System.debug('更新条数：' + updateList.size());
            Database.update(updateList);
        }catch (Exception e) {
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'UpdateCustomerProductLineBatch';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = '出错:' + updateList;
            insert ic;
            System.debug('出错：'+e.getMessage()+e.getLineNumber());
        }
    }

    private boolean containsIgnoreCase(String s, List<String> l){
        for (String str : l){
           if (str.equalsIgnoreCase(s)){
               return true;
            }
        }
       return false;
     }

    global void finish(Database.BatchableContext BC) {
    }
}