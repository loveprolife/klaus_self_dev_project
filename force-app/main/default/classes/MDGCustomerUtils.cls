public without sharing class MDGCustomerUtils {
    public static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        List<Map<String, String>> valuesMap = new List<Map<String, String>>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeFieldResult fieldResult = targetType.getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('Label', entry.getLabel());
            valueMap.put('Value', entry.getValue());
            valuesMap.add(valueMap);
        }
        return valuesMap;
    }

    public static string getRecordTypeDeveloperName(String recordTypeId) {
        try {
            if (String.isEmpty(recordTypeId)) {
                RecordType rt = [SELECT DeveloperName FROM RecordType WHERE SobjectType = 'Account' LIMIT 1];
                return rt.DeveloperName;
            } else {
                RecordType rt = [SELECT DeveloperName FROM RecordType WHERE Id = :recordTypeId LIMIT 1];
                return rt.DeveloperName;
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}