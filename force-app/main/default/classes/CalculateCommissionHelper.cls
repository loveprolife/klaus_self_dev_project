public without sharing class CalculateCommissionHelper {

    /**
     *@description 获取并生成Commission__c
     *@param	commissionDataIndexList	需要查到的commission的DataIndex列表
     *@param	today	日期
     *@return	type	返回意义
    */
    public static Map<String, sobject> getCommissionMap(List<String> commissionDataIndexList, Date today) {
        System.debug('commissionDataIndexList.size=' + commissionDataIndexList.size());
        commissionDataIndexList = new List<String>(new Set<String>(commissionDataIndexList));
        System.debug('commissionDataIndexList.size=' + commissionDataIndexList.size());
        for (String cdi : commissionDataIndexList) {
            System.debug(cdi);
        }
        Map<String, sobject> commissionMap = new LisqContainer([
            SELECT
                ID,
                DataIndex__c
            FROM Commission__c
            WHERE DataIndex__c IN :commissionDataIndexList
        ]).toMapS('DataIndex__c');
        List<Commission__c> newCommissions = new List<Commission__c>();
        List<String> ownerIds = new List<String>();
        for (String di : commissionDataIndexList) {
            ownerIds.add(di.split('_')[0]);
        }
        Map<Id, User> msu = new Map<Id, User>([
            SELECT
                ID,
                CurrencyIsoCode,
                DefaultCurrencyIsoCode
            FROM User
            WHERE ID IN :ownerIds
                AND IsActive = true
        ]);
        for (String di : commissionDataIndexList) {
            String ownerId = di.split('_')[0];
            if (!commissionMap.containsKey(di) && msu.containsKey(ownerId)) {
                newCommissions.add(handleCommission(new Commission__c(
                    Year__c = today.year() + '',
                    Month__c = today.month() + '',
                    OwnerId = ownerId,
                    CurrencyIsoCode = msu.get(ownerId).DefaultCurrencyIsoCode
                )));
            }
        }
        // Formula.recalculateFormulas(newCommissions);
        System.debug('newCommissions=' + newCommissions);
        system.debug('newCommissions.size=' + newCommissions.size());
        insert newCommissions;
        commissionMap.putAll(new LisqContainer(newCommissions).toMapS('DataIndex__c'));
        System.debug('newCommissions=' + newCommissions);

        return commissionMap;
    }

    public static Commission__c handleCommission(Commission__c cd) {
        List<Commission__c> tl = new List<Commission__c>{cd};
        Formula.recalculateFormulas(tl);
        cd.ExternalID__c = cd.DataIndex__c;
        System.debug('ExternalID__c' + cd.ExternalID__c);
        return cd;
    }

    public static CommissionDetail__c handleCommissionDetail(CommissionDetail__c cd) {
        List<CommissionDetail__c> tl = new List<CommissionDetail__c>{cd};
        Formula.recalculateFormulas(tl);
        cd.ExternalID__c = cd.DataIndex__c;
        System.debug('ExternalID__c' + cd.ExternalID__c);
        return cd;
    }

    public static Map<String, SObject> getCommissionDetailMap(Set<String> dataIndexSet) {

        return new LisqContainer([
            SELECT
                ID,
                DataIndex__c
            FROM CommissionDetail__c
            WHERE DataIndex__c IN :dataIndexSet
        ]).toMapS('DataIndex__c');
    }
}