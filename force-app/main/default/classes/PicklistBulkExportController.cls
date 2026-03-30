public with sharing class PicklistBulkExportController {
    /* 最大输出行保护，防止日志/内存爆表 */
    private static final Integer MAX_ROWS = 9000;

    @AuraEnabled(cacheable=true)
    public static String exportPicklists(String objectNames){
        if(String.isBlank(objectNames)){
            return '';
        }

        List<String> csv   = new List<String>();
        csv.add('Object,Field,Label,Value');          // 表头
        Integer rowCount   = 0;

        for(String obj : objectNames.split(',')){
            obj = obj.trim();
            if(String.isBlank(obj)) continue;

            Schema.SObjectType sot = Schema.getGlobalDescribe().get(obj);
            if(sot == null){
                csv.add(obj+',ERROR,ERROR,Invalid object');
                rowCount++;
                continue;
            }

            Map<String,Schema.SObjectField> fm = sot.getDescribe().fields.getMap();
            for(Schema.SObjectField fld : fm.values()){
                Schema.DescribeFieldResult d = fld.getDescribe();
                if(d.getType() != Schema.DisplayType.Picklist) continue;

                String fieldApi = d.getName();
                List<Schema.PicklistEntry> ple = d.getPicklistValues();

                if(ple.isEmpty()){
                    csv.add(obj+','+fieldApi+','+d.getLabel()+',(Empty)');
                    if(++rowCount > MAX_ROWS) break;
                }else{
                    for(Schema.PicklistEntry pe : ple){
                        csv.add(obj+','+fieldApi+','+d.getLabel()+','+
                                '"'+pe.getValue()+'"');
                        if(++rowCount > MAX_ROWS) break;
                    }
                }
                if(rowCount > MAX_ROWS) break;
            }
            if(rowCount > MAX_ROWS) break;
        }

        return String.join(csv, '\n');
    }
}