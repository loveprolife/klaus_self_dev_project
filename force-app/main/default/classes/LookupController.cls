public without sharing class LookupController {

    public interface ICustomLookup {
        List<Sobject> getData(string searchKey , string objName, Map<String, Object> option);
    }

    public interface IOfficeCustomLookup {
        List<Sobject> getOfficeData(string salesRegion,string searchKey , string objName, Map<String, Object> option);
    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    

    @AuraEnabled(cacheable=true)
    public static list<sObject> getLookupData(string searchKey , string objName, string optionJson) {
        System.debug('optionJson=' + optionJson);
        try {
            Map<String, Object> option = (Map<String, Object>) JSON.deserializeUntyped(optionJson);
            String lookup = String.valueOf(option.get('lookup'));
            option.remove('lookup');
            return ((ICustomLookup)Type.forName(lookup).newInstance()).getData(searchKey, objName, option);
        } catch (Exception e) {
            System.debug(e.getmessage());
          
            System.debug(e.getStackTraceString());
            return fetchLookupData(searchKey, objName);    
        }
    }
    // TJP 20241111 新增总部的产品找到方法
    @AuraEnabled(cacheable=true)
    public static list<sObject> getOfficeLookupData(string salesRegion, string searchKey , string objName, string optionJson) {
        System.debug('optionJson=' + optionJson);
        // try {
            Map<String, Object> option = (Map<String, Object>) JSON.deserializeUntyped(optionJson);
            String lookup = String.valueOf(option.get('lookup'));
            option.remove('lookup');
            System.debug('XXXXXlookupXX' +':'+ lookup);

            System.debug('XXXXXXXX' +':'+ salesRegion + ':' + searchKey + ':' + objName + ':' + option);
            return ((IOfficeCustomLookup)Type.forName(lookup).newInstance()).getOfficeData(salesRegion,searchKey, objName, option);
        // } catch (Exception e) {
        //     System.debug(e.getmessage());
        //     System.debug(e.getLineNumber());
        //     System.debug(e.getStackTraceString());
        //     return fetchLookupData(searchKey, objName);    
        // }
    }

    @AuraEnabled
    public static ConResponse getDefaultRecord(string recordId, String objName) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        if(!String.isBlank(recordId)) {
            Id sRecId = Id.valueOf(recordId);
            objName = sRecId.getSobjectType().getDescribe().getName();
            mso.put('objName', objName);
            String sQuery = 'Select Id,Name From ' + objName + ' Where Id = :sRecId LIMIT 1';

            // YYL 新增关于渠道搜索框逻辑 20250410
            if(objName.equals('Channel_item__c')){
                sQuery = 'Select Id,Channel_Name__c From ' + objName + ' Where Id = :sRecId LIMIT 1';
            }
            
            system.debug('query=' + sQuery);
            for (sObject obj: database.query(sQuery)) {
                mso.put('data', obj);
                break;
            }
        }
        mso.put('objName', objName);
        mso.put('iconName', getIconName(objName));
        return resp;
    }

    private static String getIconName(String sObjectName){
        system.debug('sObjectName:: '+sObjectName);
        String u;
        Schema.SObjectType st = Schema.getGlobalDescribe().get(sObjectName);
        if (st == null) {
            return null;
        }

        if (!st.getDescribe().isCustom()) {
            return 'standard:' + sObjectName.toLowerCase();
        }
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        System.debug('tabSetDesc.size=' + tabSetDesc.size());
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
        System.debug('tabDesc.size=' + tabDesc.size());
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    u = 'standard:' + sObjectName.toLowerCase();
                    system.debug('iconName:: '+u);
                    return u;
                }
            }
        }
        System.debug('iconDesc.size=' + iconDesc.size());
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                system.debug('iconName:: '+u);
                return u;
            }
        }

        List<IconDefinition> icons = [
            select 
                id, 
                Url, 
                DurableId,
                ContentType,  
                Theme 
            from IconDefinition 
            where TabDefinition.SobjectName = :sObjectName
        ];
        System.debug('icons.size=' + icons.size());
        for (IconDefinition icon : icons) {
            System.debug('icon=' + icon);
            if (icon.ContentType == 'image/svg+xml' && !String.isBlank(icon.Url)) {
                try {
                    String[] ss = icon.Url.split('/');
                    u = ss.get(ss.size()-2) + ':' + ss.get(ss.size()-1).replace('.svg', '');
                    system.debug('iconName:: '+u);
                    return u;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    System.debug(e.getStackTraceString());
                }
            }
        }
        
        
        return u;
    }
}