global with sharing class GenerateCommonCommissionBatch  extends LinkedListBatch{
    
    String[] userIds = null;
    Date today = null;
    Date exeDay {
        get {
            return today.addDays(-1);
        }
    }

    global GenerateCommonCommissionBatch() {
        today = System.today();
    }
    
    global GenerateCommonCommissionBatch(Date d) {
        today = d == null ? System.today() : d;
    }

    global GenerateCommonCommissionBatch(String[] userIds) {
        this();
        this.userIds = userIds;
    }

    global GenerateCommonCommissionBatch(Date d, String[] userIds) {
        this(d);
        this.userIds = userIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('GenerateCommonCommissionBatch start');
        String query = 'SELECT ID, Principal__c, Shop_Name__c, Shop_Name__r.Sales_Region__c FROM Responsible_Person__c WHERE Shop_Name__r.Sales_Region__c = \'Hisense Indonesia\' AND RecordType__c = \'促销员\'';
        if (userIds != null) {
            query += ' AND Principal__c IN :userIds ';
        }
        System.debug('query=' + query);
        System.debug('userIds=' + userIds);
        return Database.getQueryLocator(query);
    }

    static String getCommsionDetailDataIndexByPerson(Responsible_Person__c cc, Date d) {
        return cc.Id + '_' + d.year() + '_' + d.month();
    }

    static String getCommissionDataIndexByPerson(Responsible_Person__c cc, Date d) {
        return cc.Principal__c + '_' + d.year() + '_' + d.month();
    }

    global void execute(Database.BatchableContext BC, List<Responsible_Person__c> sobjectList) {
        
        LisqContainer psersonLc = new LisqContainer(sobjectList);
        CommissionConfiguration__c cc = (CommissionConfiguration__c)SobjectHelper.first([SELECT ID FROM CommissionConfiguration__c WHERE (StartDate__c = NULL OR StartDate__c <= :exeDay) AND (EndDate__c = NULL OR EndDate__c >= :exeDay) AND IsActive__c = TRUE AND ResponsiblePerson__c = NULL AND RecordType.DeveloperName = 'HisenseIndonesia']);
        if (cc == null) {
            System.debug('cc=null');
            return;
        }
        Map<String, Responsible_Person__c> scMap = new Map<String, Responsible_Person__c>();
        List<String> commissionDataIndexList = new List<String>();
        List<CommissionDetail__c> needCreateCommissionDetailList = new List<CommissionDetail__c>();
        for (Responsible_Person__c cf : sobjectList) {
            scMap.put(getCommsionDetailDataIndexByPerson(cf, exeDay), cf);
            commissionDataIndexList.add(getCommissionDataIndexByPerson(cf, exeDay));
        }

        if (commissionDataIndexList.size() == 0) {
            return;
        }

        Map<String, sobject> commissionMap = CalculateCommissionHelper.getCommissionMap(commissionDataIndexList, exeDay);
        Map<String, SObject> existCDMap = CalculateCommissionHelper.getCommissionDetailMap(scMap.keySet());
        for (String key : scMap.keySet()) {
            if (existCDMap.containsKey(key)) {
                System.debug(key + ' exists in existCDMap');
                continue;
            }

            Responsible_Person__c rp = scMap.get(key);
            if (!commissionMap.containsKey(getCommissionDataIndexByPerson(rp, exeDay))) {
                System.debug(getCommissionDataIndexByPerson(rp, exeDay) + ' is not found in commissionMap');
                continue;
            }

            needCreateCommissionDetailList.add(CalculateCommissionHelper.handleCommissionDetail(new CommissionDetail__c(
                Commission__c = commissionMap.get(getCommissionDataIndexByPerson(rp, exeDay)).Id,
                CommissionConfiguration__c = cc.Id,
                Store__c = rp.Shop_Name__c,
                ResponsiblePerson__c = rp.Id,
                CurrencyIsoCode = ((Commission__c)commissionMap.get(getCommissionDataIndexByPerson(rp, exeDay))).CurrencyIsoCode
            )));
        }
        
        system.debug('needCreateCommissionDetailList.size=' + needCreateCommissionDetailList.size());
        insert needCreateCommissionDetailList;
    }

}