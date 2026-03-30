public without sharing class SalesGoalTriggerHandlerHelper {

    public static string monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
    public static string dayRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Day'].Id;
    public static string customerRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Customer_Target'].Id;
    public static Boolean activeChanged = false;

    /**
     * @description 新建时根据已知字段，自动同步其他字段
     * @param   oldList     旧数据
     * @param   newList     新数据
     * @return
     */
    public static void updateTimeInfoForInsert(List<SalesGoal__c> oldList, List<SalesGoal__c> newList){

        LisqContainer lc = new LisqContainer(newList);
        List<Product__c> productList = [SELECT Id, Name
                                            FROM Product__c 
                                            WHERE Id IN: (lc.selectsField('Product__c'))];
        Map<Id, Product__c> productMap = new Map<Id, Product__c>(productList);

        List<Shop__c> storeList = [SELECT Id, Name, Sales_Region__c, Account__c
                                    FROM Shop__c 
                                    WHERE Id IN: (lc.selectsField('Store__c')) AND Sales_Region__c != null ];
        Map<Id, Shop__c> storeMap = new Map<Id, Shop__c>(storeList);

        List<Responsible_Person__c> personList = [SELECT Id, Name, Shop_Name__c, Principal__c, RecordType__c, Principal__r.Alias
                                                    FROM Responsible_Person__c 
                                                    WHERE Id IN: (lc.selectsField('ResponsiblePerson__c')) AND RecordType__c = '促销员'];
        Map<Id, Responsible_Person__c> personMap = new Map<Id, Responsible_Person__c>(personList);

        for(SalesGoal__c item : newList) {
            item.StoreId__c = item.Store__c;
            item.CompletedSales__c = 0;
            item.ResponsiblePersonId__c = item.ResponsiblePerson__c;
            if(personMap.containsKey(item.ResponsiblePerson__c)) {
                item.Promoter__c = personMap.get(item.ResponsiblePerson__c).Principal__c;
            } else {
                if(item.ResponsiblePerson__c != null) {
                    item.addError('the promoter does not exist under the selected store');
                }
            }

            if(item.RecordTypeId == monthRecordTypeId) {
                Integer numberDays = date.daysInMonth(Integer.valueOf(item.Year__c), Integer.valueOf(item.Month__c));
                String startTime = item.Year__c + '-' + item.Month__c + '-1 00:00:00';
                String endTime = item.Year__c + '-' + item.Month__c + '-' + numberDays + ' 23:59:59';
                System.debug('updateTimeInfo ——> endTime：' + endTime);
                item.StartTime__c  = Datetime.valueOf(startTime);
                item.EndingTime__c = Datetime.valueOf(endTime);

                // Target Name=YYMMDD(if there is no Day, then 01)_Country (Of Store)_Alias(Of Promoter)_ProductLine(if there is)_Prodcut Model(if there is)
                item.Name = String.valueOf(date.newinstance(Integer.valueOf(item.Year__c), Integer.valueOf(item.Month__c), 1));
            } else if(item.RecordTypeId == dayRecordTypeId){
                item.Year__c = String.valueOf(item.TargetDay__c.year());
                item.Month__c = String.valueOf(item.TargetDay__c.month());
                item.Day__c = item.TargetDay__c.day();
                // if(item.TargetDay__c < Date.today()) {
                //     item.addError('error Day value');
                // } else {
                String startTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 00:00:00';
                String endTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 23:59:59';
                item.StartTime__c  = Datetime.valueOf(startTime);
                item.EndingTime__c = Datetime.valueOf(endTime);  
                
                // Target Name=YYMMDD(if there is no Day, then 01)_Country (Of Store)_Alias(Of Promoter)_ProductLine(if there is)_Prodcut Model(if there is)
                item.Name = String.valueOf(item.TargetDay__c);
            }else if(item.RecordTypeId == customerRecordTypeId){
                item.Year__c = String.valueOf(item.TargetDay__c.year());
                item.Month__c = String.valueOf(item.TargetDay__c.month());
                item.Day__c = item.TargetDay__c.day();

                String startTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 00:00:00';
                String endTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 23:59:59';
                item.StartTime__c  = Datetime.valueOf(startTime);
                item.EndingTime__c = Datetime.valueOf(endTime); 
                
                System.debug('wwww 处理Customer Target 字段逻辑');
                // 处理Customer Target 字段逻辑
                CustomerTargetTriggerHandlerHelper.computeAmount(item);

                // 遵循原本逻辑设置为True (avoidDayOrMonthAtSameTime 只校验为IsActive__ctrue的)
                item.IsActive__c = true;
            }

            if(storeMap.containsKey(item.Store__c)) {
                item.Customer__c = storeMap.get(item.Store__c).Account__c;
                item.Name += '_' + storeMap.get(item.Store__c).Sales_Region__c.split(' ')[1];
            }
            
            if(personMap.containsKey(item.ResponsiblePerson__c)) {
                item.Name += '_' + personMap.get(item.ResponsiblePerson__c).Principal__r.Alias;
            }
            if(item.ProductLine__c != null) {
                item.Name += '_' + item.ProductLine__c;
            }
            if(productMap.containsKey(item.Product__c)) {
                item.Name += '_' + productMap.get(item.Product__c).Name;
            }
        }
    }

    /**
     * @description 更改时根据已知字段，自动同步其他字段
     * @param   oldList     旧数据
     * @param   newList     新数据
     * @return
     */
    public static void updateTimeInfoForUpdate(List<SalesGoal__c> oldList, List<SalesGoal__c> newList){
        LisqContainer lc = new LisqContainer(newList);
        List<Id> yearChanged = lc.Where1('Year__c', 'ISCHANGED', oldList).selectsField('Id');
        List<Id> monthChanged = lc.Where1('Month__c', 'ISCHANGED', oldList).selectsField('Id');
        List<Id> dayChanged = lc.Where1('TargetDay__c', 'ISCHANGED', oldList).selectsField('Id');
        List<Id> storeChanged = lc.Where1('Store__c', 'ISCHANGED', oldList).selectsField('Id');
        List<Id> personChanged = lc.Where1('ResponsiblePerson__c', 'ISCHANGED', oldList).selectsField('Id');
        List<Id> completedSalesChanged = lc.Where1('CompletedSales__c', 'ISCHANGED', oldList).selectsField('Id');
        // List<Id> productChanged = lc.Where1('Product__c', 'ISCHANGED', oldList).selectsField('Id');
        // List<Id> amountChanged = lc.Where1('Amounts__c', 'ISCHANGED', oldList).selectsField('Id');

        List<Product__c> productList = [SELECT Id, Name
                                            FROM Product__c 
                                            WHERE Id IN: (lc.selectsField('Product__c'))];
        Map<Id, Product__c> productMap = new Map<Id, Product__c>(productList);
        
        List<Shop__c> storeList = [SELECT Id, Name, Sales_Region__c, Account__c
                                    FROM Shop__c 
                                    WHERE Id IN: (lc.selectsField('Store__c')) AND Sales_Region__c != null ];
        Map<Id, Shop__c> storeMap = new Map<Id, Shop__c>(storeList);

        List<Responsible_Person__c> personList = [SELECT Id, Name, Shop_Name__c, Principal__c, Principal__r.Alias 
                                                FROM Responsible_Person__c 
                                                WHERE Id IN: (lc.selectsField('ResponsiblePerson__c'))];
        Map<Id, Responsible_Person__c> personMap = new Map<Id, Responsible_Person__c>(personList);

        for(SalesGoal__c item : newList) {
            // 目标日期更改
            if(yearChanged.contains(item.Id) || monthChanged.contains(item.Id) || dayChanged.contains(item.Id)) {
                if(item.RecordTypeId == monthRecordTypeId) {
                    Integer numberDays = date.daysInMonth(Integer.valueOf(item.Year__c), Integer.valueOf(item.Month__c));
                    String startTime = item.Year__c + '-' + item.Month__c + '-1 00:00:00';
                    String endTime = item.Year__c + '-' + item.Month__c + '-' + numberDays + ' 23:59:59';
                    System.debug('updateTimeInfo ——> endTime：' + endTime);
                    item.StartTime__c  = Datetime.valueOf(startTime);
                    item.EndingTime__c = Datetime.valueOf(endTime);
                } else if(item.RecordTypeId == dayRecordTypeId){
                    item.Year__c = String.valueOf(item.TargetDay__c.year());
                    item.Month__c = String.valueOf(item.TargetDay__c.month());
                    item.Day__c = item.TargetDay__c.day();
                    // if(item.TargetDay__c < Date.today()) {
                    //     item.addError('error Day value');
                    // } else {
                    String startTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 00:00:00';
                    String endTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 23:59:59';
                    item.StartTime__c  = Datetime.valueOf(startTime);
                    item.EndingTime__c = Datetime.valueOf(endTime);
                }else if(item.RecordTypeId == customerRecordTypeId){
                    item.Year__c = String.valueOf(item.TargetDay__c.year());
                    item.Month__c = String.valueOf(item.TargetDay__c.month());
                    item.Day__c = item.TargetDay__c.day();
    
                    String startTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 00:00:00';
                    String endTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 23:59:59';
                    item.StartTime__c  = Datetime.valueOf(startTime);
                    item.EndingTime__c = Datetime.valueOf(endTime); 
                    
                    // 处理Customer Target 字段逻辑
                    CustomerTargetTriggerHandlerHelper.computeAmount(item);
                }
            }else{
                // 适用于Customer Target 没有更改日期的情况
                if(item.RecordTypeId == customerRecordTypeId){
                    item.Year__c = String.valueOf(item.TargetDay__c.year());
                    item.Month__c = String.valueOf(item.TargetDay__c.month());
                    item.Day__c = item.TargetDay__c.day();
    
                    String startTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 00:00:00';
                    String endTime = item.Year__c + '-' + item.Month__c + '-' + item.Day__c + ' 23:59:59';
                    item.StartTime__c  = Datetime.valueOf(startTime);
                    item.EndingTime__c = Datetime.valueOf(endTime); 
                    
                    // 处理Customer Target 字段逻辑
                    CustomerTargetTriggerHandlerHelper.computeAmount(item);
                }
            }
            // 人员更改
            if(storeChanged.contains(item.Id) || personChanged.contains(item.Id)) {
                item.ResponsiblePersonId__c = item.ResponsiblePerson__c;
                item.StoreId__c = item.Store__c;
                item.Promoter__c = null;
                if((item.ResponsiblePerson__c != null ) && (personMap.containsKey(item.ResponsiblePerson__c))) {
                    item.Promoter__c = personMap.get(item.ResponsiblePerson__c).Principal__c;
                    item.ResponsiblePersonId__c = item.ResponsiblePerson__c;
                }
            }
            // 不同时期更改范围的校验
            // if(!(completedSalesChanged.contains(item.Id))) {
            //     if(item.IsActive__c && (item.EndingTime__c < datetime.now())) {
            //         item.addError('The sales target date has passed and the record cannot be changed!');
            //     } else if(item.IsActive__c && (item.StartTime__c < datetime.now()) && (item.EndingTime__c > datetime.now())) {
            //         item.addError('Sales target in progress, only target amount field can be changed!');
            //     }
            // }
            // Target Name
            if(item.RecordTypeId == monthRecordTypeId) {
                item.Name = String.valueOf(date.newinstance(Integer.valueOf(item.Year__c), Integer.valueOf(item.Month__c), 1));
            } else if(item.RecordTypeId == dayRecordTypeId){
                item.Name = String.valueOf(item.TargetDay__c);
            }
            if(storeMap.containsKey(item.Store__c)) {
                item.Customer__c = storeMap.get(item.Store__c).Account__c;
                item.Name += '_' + storeMap.get(item.Store__c).Sales_Region__c.split(' ')[1];
            }
            if(personMap.containsKey(item.ResponsiblePerson__c)) {
                item.Name += '_' + personMap.get(item.ResponsiblePerson__c).Principal__r.Alias;
            }
            if(item.ProductLine__c != null) {
                item.Name += '_' + item.ProductLine__c;
            }
            if(productMap.containsKey(item.Product__c)) {
                item.Name += '_' + productMap.get(item.Product__c).Name;
            }
        }
    }

    /**
     * @description 新建时，共享销售目标给促销员
     */
    public static void afterInsertHandler(List<SalesGoal__c> oldList, List<SalesGoal__c> newList) {
        List<String> promoterIdList = new LisqContainer(newList).selectsField('Promoter__c');
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :promoterIdList AND IsActive = true]).selectsField('Id');

        List<SalesGoal__c> shareList = new List<SalesGoal__c>();
        for(SalesGoal__c item : newList) {
            if((item.ResponsiblePerson__c != null) && (activeUserIdList.contains(item.Promoter__c))) {
                shareList.add(item);
            }
        }
        sharingRelatedOperations(shareList, 'add');
    }

    public static void afterUpdateHandler(List<SalesGoal__c> oldList, List<SalesGoal__c> newList) {
        LisqContainer lc = new LisqContainer(newList);
        List<Id> promoterIdList = lc.Where1('ResponsiblePerson__c', 'ISCHANGED', oldList).selectsField('Promoter__c');
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :promoterIdList AND IsActive = true]).selectsField('Id');

        List<SalesGoal__c> shareList = new List<SalesGoal__c>();
        for(SalesGoal__c item : oldList) {
            if(activeUserIdList.contains(item.Promoter__c)) {
                shareList.add(item);
            }
        }
        sharingRelatedOperations(shareList, 'delete');
    }

    /**
     * @description 共享销售目标给促销员
     * @param   goalList    要共享的数据
     * @param   operations    操作，add代表新增数据，delete代表删除数据
     */
    public static void sharingRelatedOperations(List<SalesGoal__c> goalList, String operations){
        if(operations == 'add') {
            List<SalesGoal__Share> shareList = new List<SalesGoal__Share>();
            for(SalesGoal__c item : goalList) {
                if(item.Promoter__c == item.OwnerId) {
                    continue;
                }
                if(item.Promoter__c != null) {
                    SalesGoal__Share golaShare = new SalesGoal__Share();
                    golaShare.RowCause = 'Manual';
                    golaShare.ParentId = item.Id;
                    golaShare.UserOrGroupId = item.Promoter__c;
                    golaShare.AccessLevel = 'Read';
                    shareList.add(golaShare);
                }
            }
            if(shareList.size() > 0) {
                insert shareList;
            }
        } else if(operations == 'delete') {
            Map<Id, SalesGoal__c> goalsMap = new Map<Id, SalesGoal__c>(goalList);
            List<SalesGoal__Share> shareList = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
                                                    FROM SalesGoal__Share 
                                                    WHERE ParentId IN :goalsMap.keySet() AND RowCause = 'Manual' AND AccessLevel = 'Read'];
            List<SalesGoal__Share> deleteShareList = new List<SalesGoal__Share>();
            for(SalesGoal__Share item : shareList) {
                if(goalsMap.containsKey(item.ParentId) && goalsMap.get(item.ParentId).Promoter__c == item.UserOrGroupId) {
                    deleteShareList.add(item);
                }
            }
            if(deleteShareList.size() > 0) {
                delete deleteShareList;
            }
        }
        
    }

    /**
     *@description 同一个维度，不能即创建日目标，又创建月目标
    */
    public static Boolean avoidDayOrMonthAtSameTime(List<SalesGoal__c> oldList, List<SalesGoal__c> newList) {
        Boolean b = true;
        LisqContainer newlc = new LisqContainer(newList);
        List<String> dataIndexList = newlc.where1('IsActive__c', '=', true).SelectSField('DataIndexF__c');
        LisqContainer exsitlc = new LisqContainer([
            SELECT
                ID,
                DataIndexF__c,
                DataIndexDayF__c,
                DataIndexCustomerF__c,
                RecordTypeId
            FROM SalesGoal__c
            WHERE ID NOT IN :(newlc.toIds())
                AND IsActive__c = true
                AND DataIndexF__c IN :dataIndexList
        ]);
        Map<String, Sobject> exsitMonthMap = exsitlc.toMapS('DataIndexF__c');
        Map<String, Sobject> exsitMonthMap1 = exsitlc.where1('RecordTypeId', '=', monthRecordTypeId).toMapS('DataIndexF__c');
        //过滤掉RecordTypeId不等于 customerTarget类型的数据
        Map<String, Sobject> exsitCustomerMap = exsitlc.where1('RecordTypeId', '=', customerRecordTypeId).toMapS('DataIndexCustomerF__c');
        System.debug('wwwww exsitCustomerMap' + exsitCustomerMap);
        Map<String, Sobject> exsitDayMap = exsitlc.toMapS('DataIndexDayF__c');

        for (SalesGoal__c sg : newList) {
            if (sg.RecordTypeId == monthRecordTypeId && exsitMonthMap.containsKey(sg.DataIndexF__c)) {
                System.debug('month duplicate');
                sg.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{exsitMonthMap.get(sg.DataIndexF__c).Id}));
                b = false;
            } else if (sg.RecordTypeId == dayRecordTypeId) {
                if (exsitDayMap.containsKey(sg.DataIndexDayF__c)) {
                    System.debug('day duplicate day');
                    sg.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{exsitDayMap.get(sg.DataIndexDayF__c).Id}));
                    b = false;
                }
                
                if (exsitMonthMap1.containsKey(sg.DataIndexF__c)) {
                    System.debug('day duplicate month');
                    sg.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{exsitMonthMap1.get(sg.DataIndexF__c).Id}));
                    b = false;
                }
            }else if(sg.RecordTypeId == customerRecordTypeId && exsitCustomerMap.containsKey(sg.DataIndexCustomerF__c)){
                System.debug('Customer Target duplicate');
                sg.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{exsitCustomerMap.get(sg.DataIndexCustomerF__c).Id}));
                b = false;
            }
        }

        return b;
    }

    /**
     *@description 绑定Daily Sales到销售目标
    */
    public static Boolean bindDailySales(List<SalesGoal__c> oldList, List<SalesGoal__c> newList) {
        if (oldList == null) {
            oldList = new List<SalesGoal__c>();
        }
        
        // 1. 准备数据
        LisqContainer oldlc = new LisqContainer(oldList);
        LisqContainer newlc = new LisqContainer(newList);
        Map<Id, SalesGoal__c> oldMap = new Map<Id, SalesGoal__c>(oldList);
        List<SalesGoal__c> deactiveSGs = new List<SalesGoal__c>();// 禁用的销售目标
        List<SalesGoal__c> activeSGs = new List<SalesGoal__c>();// 启用的销售目标
        List<String> shopIds = new List<String>();
        String year = '0';
        String month = '0';
        Set<String> years = new Set<String>();
        Set<String> months = new Set<String>();
        for (SalesGoal__c sg : newList) {
            if (!oldMap.containsKey(sg.Id) || oldMap.get(sg.Id).IsActive__c != sg.IsActive__c) {
                if (sg.IsActive__c) {
                    activeSGs.add(sg);
                } else {
                    deactiveSGs.add(sg);
                }
                shopIds.add(sg.Store__c);
                years.add(sg.Year__c);
                months.add(sg.Month__c);
                year = sg.Year__c;
                month = sg.Month__c;
            }
        }

        // 2. 基础校验
        // 如果没有销售目标则无需后续逻辑
        if (activeSGs.size() == 0 && deactiveSGs.size() == 0) {
            System.debug('activeSGs.size()=' + activeSGs.size() + ' deactiveSGs.size()=' + deactiveSGs.size());
            return true;
        }

        // 为了防止单次处理数据量过大，不允许一次性处理跨月的数据
        if (years.size() > 1 || months.size() > 1) {
            setError(newList, 'can not modified difference month targets at same time');
            return false;
        }
        Date startDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
        Date endDate = startDate.addMonths(1).addDays(-1);

        // 查询本次销售目标变动影响的Daily Sales的数据量
        List<AggregateResult> ars = [
            SELECT
                Count(ID) cnt
            FROM Retail_Number__c 
            WHERE Shop__c IN :shopIds
                AND ReportDate__c >= :startDate
                AND ReportDate__c <= :endDate
        ];

        if (ars.size() == 0) {
            setError(newList, 'ars size = 0');
            return false;
        }

        // 如果本次销售目标变动影响的数据超过50000将报错
        if ((Integer)ars[0].get('cnt') > 50000) {
            newList.get(0).addError('The number of effective records will be greater than 50000, please reduce modified targets');
            return false;
        }

        // 查询受影响的Daily Sales
        List<Retail_Number__c> dailySales = [
            SELECT
                ID,
                Number__c,
                IsHighEnd__c,
                Shop__c,
                Product_Line__c,
                Product__c,
                Product__r.IsHighEnd__c,
                Product__r.Product_Line__c,
                ResponsiblePerson__c,
                SalesGoal__c,
                SalesGoal__r.Product__c,
                SalesGoal__r.Product__r.IsHighEnd__c,
                SalesGoal__r.ProductLine__c,
                SalesGoal__r.ResponsiblePerson__c,
                CurrencyIsoCode
            FROM Retail_Number__c 
            WHERE Shop__c IN :shopIds
                AND ReportDate__c >= :startDate
                AND ReportDate__c <= :endDate
        ];
        System.debug('shopIds=' + shopIds);
        System.debug('startDate=' + startDate);
        System.debug('endDate=' + endDate);
        System.debug('dailySales.size=' + dailySales.size());
        Map<String, LisqContainer> dailySalesGroup = new LisqContainer(dailySales).groupByS('SalesGoal__c');

        // 查询门店已激活的销售目标
        List<SalesGoal__c> allTargets = [
            SELECT
                ID,
                Product__c,
                Product__r.IsHighEnd__c,
                IsHighEnd__c,
                ProductLine__c,
                ResponsiblePerson__c,
                Amounts__c,
                CompletedSales__c,
                Quantities__c,
                CompletedQuantities__c,
                DataIndexF__c,
                CurrencyIsoCode
            FROM SalesGoal__c
            WHERE Year__c = :year
                AND Month__c = :month
                AND IsActive__c = true
                AND ID NOT IN :oldMap.keySet()
                AND Store__c IN :shopIds
        ];
        allTargets.addAll(activeSGs);
        Map<String, Sobject> allTargetMap = new LisqContainer(allTargets).toMapS('DataIndexF__c');
        List<Retail_Number__c> needUpdates = new List<Retail_Number__c>();
        // 3. 匹配销售目标
        for (Retail_Number__c rn : dailySales) {
            // 按照门店、门店负责人、产品线、产品这几个维度去匹配销售目标，能匹配到越详细越好
            // key1~6分别是当前Daily Sales的匹配的key，数字越小越精确
            String key1 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, rn.Product__c, year, month}, '_');

            String key2 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, '', year, month}, '_');
            String key3 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, '', '', year, month}, '_');

            String key4 = String.join(new String[] { rn.Shop__c, '', rn.Product_Line__c, rn.Product__c, year, month}, '_');
            String key5 = String.join(new String[] { rn.Shop__c, '', rn.Product_Line__c, '', year, month}, '_');

            String key6 = String.join(new String[] { rn.Shop__c, '', '', '', year, month}, '_');

            // String key2 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, rn.Product_Line__c, year, month}, '_');
            // String key3 = String.join(new String[] { rn.Shop__c, rn.ResponsiblePerson__c, year, month}, '_');

            // String key4 = String.join(new String[] { rn.Shop__c, rn.Product_Line__c, rn.Product__c, year, month}, '_');
            // String key5 = String.join(new String[] { rn.Shop__c, rn.Product_Line__c, year, month}, '_');

            // String key6 = String.join(new String[] { rn.Shop__c, year, month}, '_');
            Id newTargetId = null;
            if (allTargetMap.containsKey(key1)) {
                newTargetId = allTargetMap.get(key1).Id;
                System.debug('key1=' + key1);
            } else if (allTargetMap.containsKey(key2)) {
                newTargetId = allTargetMap.get(key2).Id;
                System.debug('key2=' + key2);
            } else if (allTargetMap.containsKey(key3)) {
                newTargetId = allTargetMap.get(key3).Id;
                System.debug('key3=' + key3);
            } else if (allTargetMap.containsKey(key4)) {
                newTargetId = allTargetMap.get(key4).Id;
                System.debug('key4=' + key4);
            } else if (allTargetMap.containsKey(key5)) {
                newTargetId = allTargetMap.get(key5).Id;
                System.debug('key5=' + key5);
            } else if (allTargetMap.containsKey(key6)) {
                System.debug('key6=' + key6);
                newTargetId = allTargetMap.get(key6).Id;
            } else {
                newTargetId = null;
                System.debug('key1=' + key1);
                System.debug('key2=' + key2);
                System.debug('key3=' + key3);
                System.debug('key4=' + key4);
                System.debug('key5=' + key5);
                System.debug('key6=' + key6);
            }

            System.debug('rn.SalesGoal__c=' + rn.SalesGoal__c);
            System.debug('newTargetId=' + newTargetId);
            if (rn.SalesGoal__c != newTargetId) {
                rn.SalesGoal__c = newTargetId;
                needUpdates.add(rn);
            }
        }

        // 更新Daily Sales
        System.debug('needUpdates.size = ' + needUpdates.size());
        if (needUpdates.size() > 0) {
            activeChanged = true;
            update needUpdates;
        }
        
        return true;
    }

    static void setError(List<SalesGoal__c> newList, String error) {
        for (SalesGoal__c sg : newList) {
            sg.addError(error);
        }
    }
}