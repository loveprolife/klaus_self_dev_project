public class PhaseIIIUtility {

    private static Map<String, Boolean> buffer = new Map<String, Boolean>();

    private static Map<String, Boolean> bufferUser = new Map<String, Boolean>();
    
    public static Boolean isPhaseIIIUser() {
        return isPhaseIIIUser(UserInfo.getUserId());
    }

    public static Boolean isPhaseUser() {
        return isPhaseUser(UserInfo.getUserId());
    }
    public static Boolean isPhaseIIIUser(String uid) {
        if(buffer.containsKey(uid)) {
            return buffer.get(uid);
        }
        
        User userinfo = [SELECT Id, Country__c,sales_region__c,Profile.Name FROM User WHERE Id =: uid];
        // 'Hisense Japan',
        //增加三期国家已经发布正式环境  BY lizunxing 20231101
        String[] salesRegions = new String[] {'Hisense South Africa','Hisense Indonesia', 'Hisense Chile', 'Hisense Japan', 'Hisense Peru',
            'Hisense Colombia', 'Hisense Argentina', 'Hisense West Africa', 'Hisense Saudi', 'Hisense Canada',
            'Hisense USA', 'Hisense Mexico', 'Hisense Thailand', 'Hisense Vietnam', 'Hisense Malaysia', 'Hisense Philippines'};
        //'Japan',
        //增加三期国家已经发布正式环境  BY lizunxing 20231101
        String[] countries = new String[] {'South Africa','Indonesia', 'Chile', 'Colombia', 'Argentina', 'West Africa', 'Saudi', 'Canada', 'Japan', 'Peru',
            'USA', 'Mexico', 'Thailand', 'Vietnam', 'Malaysia', 'Philippines'};
        System.debug('userinfo-----'+userinfo);
        System.debug('salesRegions.contains(userinfo.sales_region__c)-----'+salesRegions.contains(userinfo.sales_region__c));
        System.debug('countries.contains(userinfo.Country__c)-----'+countries.contains(userinfo.Country__c));
        Boolean b = salesRegions.contains(userinfo.sales_region__c) || countries.contains(userinfo.Country__c) ;
        buffer.put(uid, b);
        return b;
    }

    public static Boolean isPhaseIIIUserUpdate(String salesRegion) {
        // 'Hisense Japan',
        //增加三期国家已经发布正式环境  BY lizunxing 20231101
        String[] salesRegions = new String[] {'Hisense South Africa','Hisense Indonesia', 'Hisense Chile', 'Hisense Japan', 'Hisense Peru',
            'Hisense Colombia', 'Hisense Argentina', 'Hisense West Africa', 'Hisense Saudi', 'Hisense Canada',
            'Hisense USA', 'Hisense Mexico', 'Hisense Thailand', 'Hisense Vietnam', 'Hisense Malaysia', 'Hisense Philippines'};
        System.debug('salesRegion三期-----'+salesRegion);
        System.debug('salesRegions.contains(salesRegion)三期-----'+salesRegions.contains(salesRegion));
        Boolean b = salesRegions.contains(salesRegion);
        return b;
    }

    public static Boolean isPhaseUser(String uid) {
        if(bufferUser.containsKey(uid)) {
            return bufferUser.get(uid);
        }
        
        User userinfo = [SELECT Id, Country__c,sales_region__c,Profile.Name FROM User WHERE Id =: uid];
        String[] salesRegions = new String[] {'Hisense Canada','Hisense USA','Hisense Peru','Hisense International','Hisense Mexico','Hisense Argentina','Hisense Chile','Hisense Australia'};
        String[] countries = new String[] {'Canada','USA','Peru','International','Mexico','Argentina','Chile'};
        System.debug('userinfo-----'+userinfo);
        System.debug('salesRegions.contains(userinfo.sales_region__c)-----'+salesRegions.contains(userinfo.sales_region__c));
        System.debug('countries.contains(userinfo.Country__c)-----'+countries.contains(userinfo.Country__c));
        Boolean b = salesRegions.contains(userinfo.sales_region__c) || countries.contains(userinfo.Country__c);
        bufferUser.put(uid, b);
        return b;
    }

    public static Boolean isPhaseUserUpdate(String salesRegion) {
        List<String> salesRegions = System.Label.IIII_Sales_Region.split(',');
        // String[] salesRegions = new String[] {'Hisense Canada','Hisense USA','Hisense Peru','Hisense International','Hisense Mexico','Hisense Argentina','Hisense Chile','Hisense Australia'};
        // String[] countries = new String[] {'Canada','USA','Peru','International','Mexico','Argentina','Chile'};
        System.debug('salesRegion四期-----'+salesRegion);
        System.debug('salesRegions.contains(salesRegion)四期-----'+salesRegions.contains(salesRegion));
        // System.debug('countries.contains(userinfo.Country__c)-----'+countries.contains(userinfo.Country__c));
        Boolean b = salesRegions.contains(salesRegion);
        return b;
    }

    public static Boolean isPhaseIIIData(String recordIdStr) {
        Boolean phase = false;
        try {
            Id recordId = (Id)recordIdStr;
            SObjectType objectType = recordId.getSObjectType();
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            
            if (describeResult.fields.getMap().containsKey('OwnerId')) {
                String query = 'SELECT OwnerId FROM ' + describeResult.getName() + ' WHERE Id = :recordId LIMIT 1';
                SObject record = Database.query(query);
                String ownerId = (String)record.get('OwnerId');
                phase = isPhaseIIIUser(ownerId);
                
                //因日本巡店员日报数据中二期三期都有，增加此判断  BY lizunxing 20231018
                if('Daily_Inspection_Report__c'.equals(describeResult.getName())){
                    User userinfo = [SELECT Id, Country__c,sales_region__c,Profile.Name FROM User WHERE Id =: ownerId];
                    if('Hisense Japan'.equals(userinfo.sales_region__c) || 'Japan'.equals(userinfo.Country__c)){
                        //日本判断进入二期/三期页面
                        List<Inspection_Shop_Task__c> dir = [SELECT id FROM Inspection_Shop_Task__c where StoreMaintain__c != null and Daily_Inspection_Report__c = :recordIdStr];
                        phase = (dir == null || dir.size() == 0);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return phase;
    }

    public static Boolean isPhaseData(String recordIdStr) {
        Boolean phase = false;
        try {
            Id recordId = (Id)recordIdStr;
            SObjectType objectType = recordId.getSObjectType();
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            // wfc 去日报的Sales_Region__c，区分三期四期页面
            if (describeResult.fields.getMap().containsKey('OwnerId')) {
                // 增加 日期判断  BY tjp 20250514
                String query = 'SELECT OwnerId, Sales_Region__c,CreatedDate FROM ' + describeResult.getName() + ' WHERE Id = :recordId LIMIT 1';
                SObject record = Database.query(query);
                Boolean isArgentina = getArgentinaPage(record);
                if(isArgentina) {
                    phase = isArgentina;
                } else {
                    Object ob = record.get('Sales_Region__c');
                    if(ob != null){
                        String salesRegion = String.valueOf(ob);
                        List<String> salesRegions = System.Label.IIII_Sales_Region.split(',');
                        // String[] salesRegions = new String[] {'Hisense Canada','Hisense USA','Hisense Peru','Hisense International','Hisense Mexico','Hisense Chile','Hisense Australia'};
                        phase = salesRegions.contains(salesRegion);
                    }else {
                        String ownerId = (String)record.get('OwnerId');
                        phase = isPhaseUser(ownerId);
                    }
    
                }
                
                //因日本巡店员日报数据中二期三期都有，增加此判断  BY lizunxing 20231018
                // if('Daily_Inspection_Report__c'.equals(describeResult.getName())){
                //     User userinfo = [SELECT Id, Country__c,sales_region__c,Profile.Name FROM User WHERE Id =: ownerId];
                //     if('Hisense Japan'.equals(userinfo.sales_region__c) || 'Japan'.equals(userinfo.Country__c)){
                //         //日本判断进入二期/三期页面
                //         List<Inspection_Shop_Task__c> dir = [SELECT id FROM Inspection_Shop_Task__c where StoreMaintain__c != null and Daily_Inspection_Report__c = :recordIdStr];
                //         phase = (dir == null || dir.size() == 0);
                //     }
                // }
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return phase;
    }

    public static Boolean getArgentinaPage(SObject sobj) {
        return sobj != null && String.valueof(sobj.get('Sales_Region__c')) == 'Hisense Argentina' && 
        (Datetime) sobj.get('CreatedDate') > Datetime.newInstanceGmt(2025, 5, 15, 00, 00, 0);
    }
    
    public static Boolean isChile(SObject sobj) {
        return sobj != null && String.valueof(sobj.get('Sales_Region__c')) == 'Hisense Chile';
    }
    
    public static Boolean isIndonesia(SObject sobj) {
        return sobj != null && String.valueof(sobj.get('Sales_Region__c')) == 'Hisense Indonesia';
    }
    
    public static Boolean isSouthAfrica(SObject sobj) {
        return sobj != null && String.valueof(sobj.get('Sales_Region__c')) == 'Hisense South Africa';
    }
}