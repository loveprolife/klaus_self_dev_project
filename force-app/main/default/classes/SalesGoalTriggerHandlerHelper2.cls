public without sharing class SalesGoalTriggerHandlerHelper2 {
    
    public static RecordTypeInfo monthRecordTypeInfo = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Month');
    public static RecordTypeInfo dayRecordTypeInfo = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Day');
    private static Map<String, List<SalesGoal__c>> splitMap = new Map<String, List<SalesGoal__c>>();

    public static void splitMonthlySalesTarget(List<SalesGoal__c> newList) {
        
        List<SalesGoal__c> splitList = new List<SalesGoal__c>();
        for (SalesGoal__c target : newList) {
            if (!target.IsSplit__c) {
                continue;
            }

            if (monthRecordTypeInfo.getRecordTypeId() == target.RecordTypeId) {
                
                if (!splitMap.containsKey(target.DataIndexDayF__c)) {
                    splitMap.put(target.DataIndexDayF__c, new List<SalesGoal__c>());
                }
                Integer year = Integer.valueOf(target.Year__c);
                Integer month = Integer.valueOf(target.Month__c);
                Integer days = Date.newInstance(year, month, 1).addMonths(1).addDays(-1).day();
                for (Integer i = 0; i < days; i++) {
                    splitMap.get(target.DataIndexDayF__c).add(new SalesGoal__c(
                        IsActive__c = target.IsActive__c,
                        Year__c = target.Year__c,
                        Month__c = target.Month__c,
                        Day__c = i + 1,
                        TargetDay__c = Date.newInstance(year, month, i + 1),
                        Store__c = target.Store__c,
                        ResponsiblePerson__c = target.ResponsiblePerson__c,
                        ProductLine__c = target.ProductLine__c,
                        Product__c = target.Product__c,
                        Amounts__c = (i == (days - 1)) ? getSplitLastNumber(target.Amounts__c, days) : getSplitNumber(target.Amounts__c, days),
                        Quantities__c = (i == (days - 1)) ? getSplitLastNumber(target.Quantities__c, days) : getSplitNumber(target.Quantities__c, days),
                        RecordTypeId = dayRecordTypeInfo.getRecordTypeId()
                    ));
                }
                target.IsActive__c = false;
            }
        }
        for (String key : splitMap.keySet()) {
            System.debug('key=' + key);
            for (SalesGoal__c target : splitMap.get(key)) {
                System.debug('target=' + target);
            }
        }
    }

    public static void saveMonthlySalesTarget(List<SalesGoal__c> newList) {
        if (splitMap.size() == 0) {
            System.debug('splitMap.size() == 0');
            return;
        }
        List<SalesGoal__c> needSaveList = new List<SalesGoal__c>();
        for (SalesGoal__c target : newList) {
            System.debug('DataIndexDayF__c= ' + target.DataIndexDayF__c);
            if (splitMap.containsKey(target.DataIndexDayF__c)) {
                for (SalesGoal__c t : splitMap.get(target.DataIndexDayF__c)) {
                    t.parent__c = target.Id;
                }
                needSaveList.addAll(splitMap.get(target.DataIndexDayF__c));
            }
        }

        System.debug('needSaveList.size=' + needSaveList.size());
        if (needSaveList.size() > 0) {
            splitMap.clear();
            insert needSaveList;
        }
    }

    public static Integer getSplitNumber(Decimal total, Integer num) {
        if (total == null) {
            return null;
        }

        if (total < 0 || num <= 0) {
            return 0;
        }

        Integer d = Math.round(total / num);
        return d;
    }

    public static Decimal getSplitLastNumber(Decimal total, Integer num) {
        if (total == null) {
            return null;
        }

        if (total < 0 || num <= 0) {
            return 0;
        }

        Decimal d = total - getSplitNumber(total, num) * (num - 1);
        return d;
    }
}