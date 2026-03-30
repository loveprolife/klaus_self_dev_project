global without sharing class CalculateCommissionBatch extends LinkedListBatch {

    Date day = null;
    Date exeDay {
        get {
            return day.addDays(-1);
        }
    }
    Integer year {
        get {
            return exeDay.year();
        }
    }
    Integer month {
        get {
            return exeDay.month();
        }
    }

    String yearStr {
        get {
            return year + '';
        }
    }
    String monthStr {
        get {
            return month + '';
        }
    }
    Date exeStartDate {
        get {
            return Date.newInstance(year, month, 1);
        }
    }

    String[] userIds = null;
    global CalculateCommissionBatch() {
        day = System.today();
    }

    global CalculateCommissionBatch(Date d) {
        this.day = d == null ? System.today() : d;
    }

    global CalculateCommissionBatch(String[] userIds) {
        this();
        this.userIds = userIds;
    }

    global CalculateCommissionBatch(Date d, String[] userIds) {
        this(d);
        this.userIds = userIds;
        System.debug('day=' + day);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID, ResponsiblePerson__c FROM CommissionDetail__c ';
        query += 'WHERE Year__c = :yearStr AND Month__c = :monthStr ';
        if (userIds != null) {
            query += ' AND ResponsiblePerson__r.Principal__c IN :userIds ';
        }
        System.debug('query=' + query);
        System.debug('userIds=' + userIds);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CommissionDetail__c> sobjectList) {
        System.debug('CalculateCommissionBatch execute');
        LisqContainer lc = new LisqContainer(sobjectList);
        Map<String, LisqContainer> moduleMap = new LisqContainer([
            SELECT
                ID,
                RecordType.DeveloperName,
                CommissionDetail__r.CommissionConfiguration__r.Total__c,
                CommissionDetail__r.CommissionConfiguration__r.TV__c,
                CommissionDetail__r.CommissionConfiguration__r.HA__c,
                CommissionDetail__r.CommissionConfiguration__r.HighEnd__c,
                CommissionDetail__r.CommissionConfiguration__r.Elements7__c,
                CommissionDetail__r.CommissionConfiguration__r.Reporting__c,
                CommissionDetail__r.ResponsiblePerson__c,
                CurrencyIsoCode
            FROM CommissionModule__c
            WHERE CommissionDetail__c IN :(lc.toIds())
                AND RecordType.DeveloperName NOT IN ('Elements7', 'Reporting')
        ]).groupByS('CommissionDetail__c');
        
        List<String> personIds = lc.SelectSField('ResponsiblePerson__c');
        System.debug('personIds=' + personIds);
        SYstem.debug('day=' + day);
        SYstem.debug('exeStartDate=' + exeStartDate);
        SYstem.debug('exeDay=' + exeDay);
        List<Retail_Number__c> dailySales = [
            SELECT
                ID,
                Number__c,
                IsHighEnd__c,
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
            WHERE ResponsiblePerson__c IN :personIds
                AND ReportDate__c >= :exeStartDate
                AND ReportDate__c <= :exeDay
        ];
        System.debug('dailySales.size=' + dailySales.size());
        LisqContainer dailySalesLc = new LisqContainer(dailySales);
        Map<String, LisqContainer> dailySalesMap = dailySalesLc.groupByS('ResponsiblePerson__c');
        System.debug('dailySalesMap.keySet()=' + dailySalesMap.keySet());
        Map<String, SObject> productCommissions = new LisqContainer([
            SELECT
                ID,
                Product__c,
                Amount__c,
                CurrencyIsoCode
            FROM ProductCommission__c 
            WHERE Product__c IN :(dailySalesLc.SelectSField('Product__c'))
        ]).ToMapS('Product__c');

        List<SalesGoal__c> targets = [
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
                CurrencyIsoCode
            FROM SalesGoal__c
            WHERE ResponsiblePerson__c IN :personIds
                AND Year__c = :yearStr
                AND Month__c = :monthStr
        ];
        Map<String, LisqContainer> targetsMap = new LisqContainer(targets).groupByS('ResponsiblePerson__c');
        List<CommissionModule__c> needUpdates = new List<CommissionModule__c>();
        for (String cdId : moduleMap.keySet()) {
            List<CommissionModule__c> modules = moduleMap.get(cdId).ToSobjectList();
            needUpdates.addAll(modules);
            for (CommissionModule__c module : modules) {
                List<String> errs = new List<String>();
                List<String> targetIds = new List<String>();
                List<String> salesIds = new List<String>();
                Map<String, List<String>> infos = new Map<String, List<String>> {
                    'errs' => errs,
                    'targetIds' => targetIds,
                    'salesIds' => salesIds
                };
                String rtName = module.RecordType.DeveloperName;
                System.debug('rtName=' + rtName);
                Decimal amount = 0;
                Decimal targetNumber = 0;
                Decimal completeNumber = 0;
                System.debug('module.CommissionDetail__r.ResponsiblePerson__c=' + module.CommissionDetail__r.ResponsiblePerson__c);
                LisqContainer ds = dailySalesMap.containsKey(module.CommissionDetail__r.ResponsiblePerson__c) ? dailySalesMap.get(module.CommissionDetail__r.ResponsiblePerson__c) : LisqContainer.NewEmpty();
                LisqContainer tgs = targetsMap.containsKey(module.CommissionDetail__r.ResponsiblePerson__c) ? targetsMap.get(module.CommissionDetail__r.ResponsiblePerson__c) : LisqContainer.NewEmpty();
                if (ds.size() == 0) {
                    System.debug('ds.size() == 0');
                    continue;
                }

                List<Retail_Number__c> tempRNs = null;
                List<SalesGoal__c> tempSgs = null;
                if (rtName == 'Total') {
                    tempRNs = ds.ToSobjectList();
                    tempSgs = tgs.ToSobjectList();
                } else if (rtName == 'TV'){
                    tempRNs = ds.where1('Product_Line__c', '=', 'TV').ToSobjectList();
                    tempSgs = tgs.where1('ProductLine__c', '=', 'TV').ToSobjectList();
                } else if (rtName == 'HA') {
                    tempRNs = ds.where1('Product_Line__c', 'IN', new String[] {'Refrigerator', 'WM', 'AC'}).ToSobjectList();
                    tempSgs = tgs.where1('ProductLine__c', 'IN', new String[] {'Refrigerator', 'WM', 'AC'}).ToSobjectList();
                } 

                if (new String[] {'Total', 'TV', 'HA'}.contains(rtName)) {
                    SYstem.debug('tempRNs.size=' + tempRNs.size());
                    for (Retail_Number__c rn : tempRNs) {
                        if (!productCommissions.containsKey(rn.Product__c)) {
                            errs.add('Product ' + rn.Product__c + ' has no commission.');
                            System.debug('Product ' + rn.Product__c + ' has no commission.');
                            continue;
                        }
                        ProductCommission__c pc = (ProductCommission__c)productCommissions.get(rn.Product__c);
                        salesIds.add(rn.Id);
                        amount += rn.Number__c * pc.Amount__c * CurrencyRateHelper.getConversionRate(pc.CurrencyIsoCode, module.CurrencyIsoCode);
                        System.debug('amount=' + amount);
                    }
                    for (SalesGoal__c tg : tempSgs) {
                        targetNumber += tg.Amounts__c;
                        completeNumber += tg.CompletedSales__c;
                        targetIds.add(tg.Id);
                    }
                    
                } else if (rtName == 'HighEnd') {
                    tempRNs = ds.where1('IsHighEnd__c', '=', true).ToSobjectList();
                    tempSgs = tgs.where1('IsHighEnd__c', '=', true).ToSobjectList();
                    for (Retail_Number__c rn : tempRNs) {
                        if (!productCommissions.containsKey(rn.Product__c)) {
                            errs.add('Product ' + rn.Product__c + ' has no commission.');
                            System.debug('Product ' + rn.Product__c + ' has no commission.');
                            continue;
                        }
                        ProductCommission__c pc = (ProductCommission__c)productCommissions.get(rn.Product__c);
                        salesIds.add(rn.Id);
                        amount += rn.Number__c * pc.Amount__c * CurrencyRateHelper.getConversionRate(pc.CurrencyIsoCode, module.CurrencyIsoCode);
                        System.debug('amount=' + amount);
                    }
                    for (SalesGoal__c tg : tempSgs) {
                        targetNumber += tg.Quantities__c;
                        completeNumber += tg.CompletedQuantities__c;
                        targetIds.add(tg.Id);
                    }
                    
                } else {
                    
                }
                module.Amount__c = amount;
                module.CompleteRate__c = module.CompleteRateReal__c = targetNumber == 0 ? 1 : completeNumber / targetNumber;
                module.Info__c = JSON.serialize(infos);
            }
        }

        Formula.recalculateFormulas(needUpdates);
        if (day.day() == 1) {
            System.debug('first day user reverse rate');
            for (CommissionModule__c cm : needUpdates) {
                cm.CompleteRate__c = cm.CompleteRateRevised__c;
                System.debug(cm);
            }
            Formula.recalculateFormulas(needUpdates);
        }
        
        for (CommissionModule__c cm : needUpdates) {
            cm.ModuleCompleteRate__c = cm.ModuleCompleteRateF__c;
            System.debug(cm);
        }
        
        System.debug('needUpdates.size=' + needUpdates.size());
        update needUpdates;
        // Map<String, CommissionConfiguration__c> scMap = new Map<String, CommissionConfiguration__c>();
        // List<String> commissionDataIndexList = new List<String>();
        // List<CommissionDetail__c> needCreateCommissionDetailList = new List<CommissionDetail__c>();
        // for (CommissionConfiguration__c cf : sobjectList) {
        //     scMap.put(getCommsionDetailDataIndexByConfig(cf, today), cf);
        //     commissionDataIndexList.add(getCommissionDataIndexByConfig(cf, today));
        // }
        
        // System.debug('commissionDataIndexList=' + commissionDataIndexList);
        // if (commissionDataIndexList.size() == 0) {
        //     return;
        // }

        // Map<String, sobject> commissionMap = CalculateCommissionHelper.getCommissionMap(commissionDataIndexList, today);
        // Map<String, SObject> existCDMap = CalculateCommissionHelper.getCommissionDetailMap(scMap.keySet());
        // for (String key : scMap.keySet()) {
        //     if (existCDMap.containsKey(key)) {
        //         System.debug(key + ' exists in existCDMap');
        //         continue;
        //     }

        //     CommissionConfiguration__c cc = scMap.get(key);
        //     if (!commissionMap.containsKey(getCommissionDataIndexByConfig(cc, today))) {
        //         System.debug(getCommissionDataIndexByConfig(cc, today) + ' is not found in commissionMap');
        //         continue;
        //     }

        //     needCreateCommissionDetailList.add(CalculateCommissionHelper.handleCommissionDetail(new CommissionDetail__c(
        //         Commission__c = commissionMap.get(getCommissionDataIndexByConfig(cc, today)).Id,
        //         CommissionConfiguration__c = cc.Id,
        //         Store__c = cc.ResponsiblePerson__r.Shop_Name__c,
        //         ResponsiblePerson__c = cc.ResponsiblePerson__c
        //     )));
            
        // }
        
        // system.debug('needCreateCommissionDetailList.size=' + needCreateCommissionDetailList.size());
        // insert needCreateCommissionDetailList;
    }
}