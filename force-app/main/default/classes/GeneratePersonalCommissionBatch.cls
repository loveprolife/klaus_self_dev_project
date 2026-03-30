global with sharing class GeneratePersonalCommissionBatch extends LinkedListBatch{
    
    String[] userIds = null;
    Date today = null;
    Date exeDay {
        get {
            return today.addDays(-1);
        }
    }
    
    global GeneratePersonalCommissionBatch() {
        today = System.today();
    }

    global GeneratePersonalCommissionBatch(Date d) {
        today = d == null ? System.today() : d;
    }

    global GeneratePersonalCommissionBatch(String[] userIds) {
        this();
        this.userIds = userIds;
    }

    global GeneratePersonalCommissionBatch(Date d, String[] userIds) {
        this(d);
        this.userIds = userIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('GeneratePersonalCommissionBatch start');
        String query = 'SELECT ID, ResponsiblePerson__c, ResponsiblePerson__r.Principal__c, ResponsiblePerson__r.Shop_Name__c FROM CommissionConfiguration__c WHERE (StartDate__c = NULL or StartDate__c <= :exeDay) AND (EndDate__c = NULL OR EndDate__c >= :exeDay) AND IsActive__c = TRUE AND ResponsiblePerson__c != NULL AND ResponsiblePerson__r.Principal__r.IsActive = true AND RecordType.DeveloperName = \'HisenseIndonesia\'';
        if (userIds != null) {
            query += ' AND ResponsiblePerson__r.Principal__c IN :userIds ';
        }
        System.debug('query=' + query);
        System.debug('userIds=' + userIds);
        return Database.getQueryLocator(query);
    }

    static String getCommsionDetailDataIndexByConfig(CommissionConfiguration__c cc, Date d) {
        return cc.ResponsiblePerson__c + '_' + d.year() + '_' + d.month();
    }

    static String getCommissionDataIndexByConfig(CommissionConfiguration__c cc, Date d) {
        return cc.ResponsiblePerson__r.Principal__c + '_' + d.year() + '_' + d.month();
    }

    global void execute(Database.BatchableContext BC, List<CommissionConfiguration__c> sobjectList) {
        
        Map<String, CommissionConfiguration__c> scMap = new Map<String, CommissionConfiguration__c>();
        List<String> commissionDataIndexList = new List<String>();
        List<CommissionDetail__c> needCreateCommissionDetailList = new List<CommissionDetail__c>();
        for (CommissionConfiguration__c cf : sobjectList) {
            scMap.put(getCommsionDetailDataIndexByConfig(cf, exeDay), cf);
            commissionDataIndexList.add(getCommissionDataIndexByConfig(cf, exeDay));
        }
        
        System.debug('commissionDataIndexList=' + commissionDataIndexList);
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

            CommissionConfiguration__c cc = scMap.get(key);
            if (!commissionMap.containsKey(getCommissionDataIndexByConfig(cc, exeDay))) {
                System.debug(getCommissionDataIndexByConfig(cc, exeDay) + ' is not found in commissionMap');
                continue;
            }

            needCreateCommissionDetailList.add(CalculateCommissionHelper.handleCommissionDetail(new CommissionDetail__c(
                Commission__c = commissionMap.get(getCommissionDataIndexByConfig(cc, exeDay)).Id,
                CommissionConfiguration__c = cc.Id,
                Store__c = cc.ResponsiblePerson__r.Shop_Name__c,
                ResponsiblePerson__c = cc.ResponsiblePerson__c,
                CurrencyIsoCode = ((Commission__c)commissionMap.get(getCommissionDataIndexByConfig(cc, exeDay))).CurrencyIsoCode
            )));
            
        }
        
        system.debug('needCreateCommissionDetailList.size=' + needCreateCommissionDetailList.size());
        insert needCreateCommissionDetailList;
    }

}