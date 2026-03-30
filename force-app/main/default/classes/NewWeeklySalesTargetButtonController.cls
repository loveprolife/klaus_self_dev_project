public with sharing class NewWeeklySalesTargetButtonController {
    
    public class Result{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        System.debug('recordId=' + recordId);
        ConResponse resp = new ConResponse();
        try {

            //查询当前用户信息
            User user = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :UserInfo.getUserId() ];

            Map<String,Object> mso = new Map<String,Object>();

            Weekly_Sales_Target__c weeklySalesTarget = new Weekly_Sales_Target__c();
            if(String.isNotBlank(recordId)){
                weeklySalesTarget = [SELECT Id, Name, Actual_ACH__c, BA_ACH__c, Channel_Item__c, Store__c, Model__c, Model_Name__c,
                                                                Week__c, From_Week__c, To_Week__c,Target__c,Store_Name__c, Channel_Name__c,
                                                                Product_Line__c, RSP__c, Sales_Region__c, Plan_Target__c
                                            FROM Weekly_Sales_Target__c
                                            WHERE Id = :recordId];
            }else{
                weeklySalesTarget.Sales_Region__c = user.Sales_Region__c;
            }

            List<map<String,string >> channelPicklistMap = new List<map<String,string >>();
            List<Channel_Item__c> channels = [Select Id,Name from Channel_Item__c where SBU__C = :user.Sales_Region__c];
            for(Channel_Item__c channel : channels){
                map<String,string > option = new map<String,string >();
                option.put('label', channel.Name);
                option.put('value', channel.Id);
                channelPicklistMap.add(option);
            }
            mso.put('channelOptions', channelPicklistMap);

            List<map<String,string >> picklistMap = new List<map<String,string >>();
            List<Shop__c> stores = [Select Id,Name,Channel_Item__c from Shop__c where Sales_Region__c = :user.Sales_Region__c];
            for(Shop__c store : stores){
                map<String,string > option = new map<String,string >();
                option.put('label', store.Name);
                option.put('value', store.Id);
                option.put('Channel_Item__c', store.Channel_Item__c);
                picklistMap.add(option);
            }
            mso.put('storeOptionAll', picklistMap);
            mso.put('recordId', recordId);
            mso.put('weeklySalesTarger', weeklySalesTarget);
            mso.put('fields', SObjectHelper.getFieldLabelMap('Weekly_Sales_Target__c'));
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static ConResponse saveData(String recordListJson){
        System.debug('recordListJson=' + recordListJson);

        Map<String, String> currencyMap = new Map<String, String>();
        currencyMap.put('Hisense Japan', 'JPY');
        currencyMap.put('Hisense South Africa', 'ZAR');
        currencyMap.put('Hisense USA', 'USD');
        currencyMap.put('Hisense Canada', 'CAD');
        currencyMap.put('Hisense Mexico', 'MXN');
        currencyMap.put('Hisense Peru', 'PEN');
        currencyMap.put('Hisense Chile', 'CLP');
        currencyMap.put('Hisense Argentina', 'ARS');
        currencyMap.put('Hisense Thailand', 'VND');
        currencyMap.put('Hisense Malaysia', 'MYR');
        currencyMap.put('Hisense Indonesia', 'IDR');
        currencyMap.put('Hisense Philippines', 'PHP');
        currencyMap.put('Hisense Singapore', 'SGD');

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try {
            List<Weekly_Sales_Target__c> taskList = (List<Weekly_Sales_Target__c>)JSON.deserialize(recordListJson, List<Weekly_Sales_Target__c>.class);
            Weekly_Sales_Target__c item = taskList.get(0);
            if(String.isNotBlank(item.Id)){
                update item;
            }else{
                item.External_key__c = item.Sales_Region__c + '_' 
                                        + item.Week__c.setScale(0) + '_'
                                        + item.Channel_Item__c + '_'
                                        + item.Store__c + '_'
                                        + item.Product_Line__c + '_'
                                        + item.Model__c + '_' 
                                        + System.now().year();
                List<Weekly_Sales_Target__c> checkAlreadyExist = [Select id from Weekly_Sales_Target__c where External_key__c = :item.External_key__c];
                if(checkAlreadyExist != null && checkAlreadyExist.size() > 0){
                    resp.code = -1;
                    resp.message = System.Label.Data_already_exist;
                    return resp;
                }
                item.From_Week__c = item.Week__c;
                item.To_Week__c = item.Week__c;
                item.CurrencyIsoCode = currencyMap.get(item.Sales_Region__c);

                item.Plan_Target__c = item.Plan_Target__c.setScale(0, System.RoundingMode.HALF_UP);

                Database.insert(item, true);
            }

            mso.put('recordId', item.Id);
            mso.put('weeklySalesTarger', item);
            mso.put('fields', SObjectHelper.getFieldLabelMap('Weekly_Sales_Target__c'));
            resp.data = mso;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static String runBatch(String recordId, String week){
        Result result = new Result();
        result.code = '0';
        if(String.isBlank(recordId)){
            List<Weekly_Sales_Target__c> weeklySalesTarget = [SELECT BA_ACH__c, Channel_Item__c, Store__c, Model__c, Week__c,
            Product_Line__c, Sales_Region__c
            FROM Weekly_Sales_Target__c where year__c = :System.now().year() and  week__c = :Decimal.valueOf(week) ];
            SetSAWeeklySalesTargetBA_ACHBatch ss = new SetSAWeeklySalesTargetBA_ACHBatch(weeklySalesTarget);
            Database.executeBatch(ss, 50);

            result.msg = 'Success';
        }else{
            List<Weekly_Sales_Target__c> weeklySalesTarget = [SELECT BA_ACH__c, Channel_Item__c, Store__c, Model__c, Week__c,
            Product_Line__c, Sales_Region__c
            FROM Weekly_Sales_Target__c
            WHERE Id = :recordId];
            setBA_ACH(weeklySalesTarget);
        }
        
        return JSON.serialize(result);
    }

    public static void setBA_ACH(List<Weekly_Sales_Target__c> taskList){
        List<Weekly_Sales_Target__c> updateList = new List<Weekly_Sales_Target__c>();
        List<Retail_Number__c> updateStoreListRn = new List<Retail_Number__c>();
        for(Weekly_Sales_Target__c item : taskList) {

            Weekly_Sales_Target__c wst = new Weekly_Sales_Target__c();
            wst.id = item.id;

            System.debug('item' + item);
            Map<String, Date> weekStartAndEndDate = getWeekStartAndEndDate(System.now().year(), Integer.valueOf(item.Week__c));
            List<Retail_Number__c> rnResult = new List<Retail_Number__c>();
            if(String.isNotBlank(item.Store__c)){
                rnResult = 
                [   select 
                        id, Weekly_Sales_Target__c, Number__c, CreatedById
                    from Retail_Number__c
                    where Sales_Region__c =:item.Sales_Region__c
                    and   Shop__r.Channel_item__c =:item.Channel_Item__c
                    and   Shop__c = :item.Store__c
                    and   Product_Line__c =:item.Product_Line__c
                    and   Product__c =:item.Model__c
                    and   ReportDate__c >= :weekStartAndEndDate.get('startDate')
                    and   ReportDate__c <= :weekStartAndEndDate.get('endDate')
                    and   Status__c = 'Submitted'
                    order by CreatedDate desc
                ];
            }else{
                continue;
            }
            
            if(rnResult.size() > 0){
                Decimal totalNumber = 0;
                for(Retail_Number__c rnc : rnResult){
                    totalNumber += rnc.Number__c;
                    rnc.Store_Weekly_Sales_Target__c = item.Id;
                    //rnc.Weekly_Sales_Target__c = item.Channel_Weekly_Sales_Target__c;
                    updateStoreListRn.add(rnc);
                }
                wst.BA_ACH__c = totalNumber;
                wst.BA_Name__c = rnResult.get(0).CreatedById;
                
                updateList.add(wst);
            }
        }

        try{

            Database.update(updateList,true);
            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'RetailNumberTriggerHandler');
            if(updateStoreListRn.size() > 0){
                Database.update(updateStoreListRn);
            }
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
        }catch(Exception e){
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
        }
    }

    public static void updateChannelData(Integer year, Integer week) {

        List<AggregateResult> allRecords = new List<AggregateResult>();

        if(year != null && week != null){
            allRecords = [
                SELECT Max(Sales_Region__c) Sales_Region__c, Max(Channel_Item__c) Channel_Item__c, 
                Max(Store__c) Store__c, Max(Product_Line__c) Product_Line__c, Max(Model__c) Model__c, 
                Max(Week__c) Week__c, SUM(Plan_Target__c) targetSum, SUM(BA_ACH__c) actualSum, 
                SUM(Not_completed_last_week__c) nclwSum, SUM(Not_completed_last_cycle__c) nclcSum, 
                Max(CurrencyIsoCode) CurrencyIsoCode, Max(Model_Name__c) Model_Name__c, 
                Max(From_Week__c) From_Week__c, Max(To_Week__c) To_Week__c, Max(Year__c) Year__c
                FROM Weekly_Sales_Target__c
                WHERE Store__c != null And Year__c = :year AND Week__c = :week
                GROUP BY External_key__c
            ];
        }else{
            allRecords = [
                SELECT Max(Sales_Region__c) Sales_Region__c, Max(Channel_Item__c) Channel_Item__c, 
                Max(Store__c) Store__c, Max(Product_Line__c) Product_Line__c, Max(Model__c) Model__c, 
                Max(Week__c) Week__c, SUM(Plan_Target__c) targetSum, SUM(BA_ACH__c) actualSum, 
                SUM(Not_completed_last_week__c) nclwSum, SUM(Not_completed_last_cycle__c) nclcSum, 
                Max(CurrencyIsoCode) CurrencyIsoCode, Max(Model_Name__c) Model_Name__c, 
                Max(From_Week__c) From_Week__c, Max(To_Week__c) To_Week__c, Max(Year__c) Year__c
                FROM Weekly_Sales_Target__c
                WHERE Store__c != null
                GROUP BY External_key__c
            ];
        }

        Map<String, AggregateResult> channelDataMap = new Map<String, AggregateResult>();
        
        for (AggregateResult ar : allRecords) {
            String key = ar.get('Sales_Region__c') + '-' + ar.get('Channel_Item__c') + '-' + ar.get('Product_Line__c') + '-' + ar.get('Model__c') + '-' + ar.get('Week__c');
            channelDataMap.put(key, ar);
        }

        List<Weekly_Sales_Target__c> channelDataList = new List<Weekly_Sales_Target__c>();
        for (AggregateResult ar : channelDataMap.values()) {
            Weekly_Sales_Target__c cd = new Weekly_Sales_Target__c(
                Sales_Region__c = (String)ar.get('Sales_Region__c'),
                Channel_item__c = (String)ar.get('Channel_item__c'),
                Store__c = null,
                Product_Line__c = (String)ar.get('Product_Line__c'),
                Model__c = (String)ar.get('Model__c'),
                Model_Name__c = (String)ar.get('Model_Name__c'),
                CurrencyIsoCode = (String)ar.get('CurrencyIsoCode'),
                Week__c = (Decimal)ar.get('Week__c'),
                From_Week__c = (Decimal)ar.get('From_Week__c'),
                To_Week__c = (Decimal)ar.get('To_Week__c'),
                Not_completed_last_cycle__c = (Decimal)ar.get('nclcSum'),
                Not_completed_last_week__c = (Decimal)ar.get('nclwSum'),
                Plan_Target__c = (Decimal)ar.get('targetSum'),
                BA_ACH__c = (Decimal)ar.get('actualSum')
            );

            cd.External_key__c = cd.Sales_Region__c + '_' 
                + cd.Week__c + '_'
                + cd.Channel_item__c + '_'
                + cd.Product_Line__c + '_'
                + cd.Model__c + '_'
                + ar.get('Year__c');
            channelDataList.add(cd);
        }

        if(channelDataList.size() > 0){
            Database.upsert(channelDataList, Weekly_Sales_Target__c.fields.External_key__c, true);

            // for(Weekly_Sales_Target__c wst : channelDataList){
            //     String jobID = System.enqueueJob(new SetDSChannelWst(wst));
            // }
        }
    }

    //异步调用设置DailySales中的渠道南非周目标
    // public class SetDSChannelWst implements Queueable {
    //     Weekly_Sales_Target__c target;
    //     public SetDSChannelWst(Weekly_Sales_Target__c target){
    //         this.target = target;
    //     }
    //     public void execute(QueueableContext context) {
    //         Map<String, Date> weekStartAndEndDate = getWeekStartAndEndDate(System.now().year(), Integer.valueOf(target.Week__c));
    //         List<Retail_Number__c> rnResult =  [    select 
    //                                                 id
    //                                                 from Retail_Number__c
    //                                                 where Sales_Region__c = :target.Sales_Region__c
    //                                                 and   Shop__r.Channel_item__c = :target.Channel_Item__c
    //                                                 and   Product_Line__c = :target.Product_Line__c
    //                                                 and   Product__c = :target.Model__c
    //                                                 and   ReportDate__c >= :weekStartAndEndDate.get('startDate')
    //                                                 and   ReportDate__c <= :weekStartAndEndDate.get('endDate')
    //                                                 and   Store_Weekly_Sales_Target__c != null
    //                                                 and   Status__c = 'Submitted'
    //                                             ];
    //         if(rnResult.size() > 0){
    //             for(Retail_Number__c rn : rnResult){
    //                 rn.Weekly_Sales_Target__c = target.Id;
    //             }

    //             try{
    //                 //忽略触发器更新
    //                 GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'RetailNumberTriggerHandler');
    //                 Database.update(rnResult);
    //                 //恢复触发器
    //                 Utility.IgnoreAction(false,false,false,'');
    //             }catch(Exception e){
    //                 //恢复触发器
    //                 Utility.IgnoreAction(false,false,false,'');
    //             }
    //         }
    //     }
    // }   

    @AuraEnabled
    public static Map<String, Date> getWeekStartAndEndDate(Integer year, Integer weekNumber) {

        // 创建该年1月1日的日期对象
        Date firstDayOfYear = Date.newInstance(year, 1, 1);

        // 获取1月1日是星期几，1代表星期日，2代表星期一，依此类推
        Integer firstDayWeekday = Integer.valueOf(Datetime.newInstance(firstDayOfYear.year(), firstDayOfYear.month(), firstDayOfYear.day()).addHours(8).format('u'));
        
        Date weekStart;
        Date weekEnd;

        if (weekNumber == 1) {
            // 处理第一周
            weekStart = firstDayOfYear;
            weekEnd = firstDayOfYear.addDays(7 - firstDayWeekday);
        } else {
            // 处理非第一周
            // 找到第一个完整周的起始日期
            Date firstFullWeekStart = firstDayOfYear.addDays(8 - firstDayWeekday);
            weekStart = firstFullWeekStart.addDays((weekNumber - 2) * 7);
            weekEnd = weekStart.addDays(6);
        }

        Map<String, Date> result = new Map<String, Date>();
        result.put('startDate', weekStart);
        result.put('endDate', weekEnd);

        return result;
    }

    public static Integer getWeekOfYear(Date dateParam) {
        // 获取指定日期是当年的第几天
        Integer dayOfYear = dateParam.dayOfYear();
        
        // 获取年初第一天的日期对象
        Date firstDayOfYear = Date.newInstance(dateParam.year(), 1, 1);
        
        // 获取年初第一天是星期几（1代表星期日，2代表星期一，依此类推）
        Integer firstDayWeekday = Integer.valueOf(Datetime.newInstance(firstDayOfYear.year(), firstDayOfYear.month(), firstDayOfYear.day()).addHours(8).format('u'));
        
        // 计算年初不足一周按一周计算的周数
        Integer weekOfYear = (dayOfYear + firstDayWeekday - 2) / 7 + 1;
        
        return weekOfYear;
    }
}