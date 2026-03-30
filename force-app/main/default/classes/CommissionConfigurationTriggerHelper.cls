public without sharing class CommissionConfigurationTriggerHelper {
    
    public static boolean validateOOO(List<CommissionConfiguration__c> newList) {
        Formula.recalculateFormulas(newList);
        LisqContainer lc = new LisqContainer(newList);
        List<String> ids = lc.SelectSField('Id');
        LisqContainer exsits = new LisqContainer([
            SELECT
                Id,
                ResponsiblePerson__c,
            	DataIndex__c,
                StartDate__c,
                EndDate__c
            FROM CommissionConfiguration__c
            WHERE
                DataIndex__c IN :lc.SelectSField('DataIndex__c')
            	AND IsActive__c = true
                AND Id NOT IN :ids
        ]);
        System.debug('exsits.size=' + exsits.Size());
        Map<String, LisqContainer> msl = exsits.GroupByS('DataIndex__c');
        for (CommissionConfiguration__c cc : newList) {
            if(!cc.IsActive__c || !msl.containsKey(cc.DataIndex__c)) {
                system.debug('!cc.IsActive__c || !msl.containsKey(cc.DataIndex__c)' + (!cc.IsActive__c) + (!msl.containsKey(cc.DataIndex__c)));
                continue;
            }
            
            // LisqContainer tempLc = msl.get(cc.DataIndex__c).Filter(new LisqUtils.NotFilter(
            //         new LisqUtils.OrFilters(new Object[]{
            //             'EndDate__c', '<', cc.StartDate__c,
            //             'StartDate__c', '>', cc.EndDate__c
            //         })
            // ));
            List<CommissionConfiguration__c> tempList = msl.get(cc.DataIndex__c).ToSobjectList();
            for(CommissionConfiguration__c temp : tempList) {
                system.debug(cc.StartDate__c > temp.EndDate__c);
                system.debug(cc.EndDate__c < temp.StartDate__c);
                if(cc.DataIndex__c == temp.DataIndex__c && !(
                	(temp.StartDate__c == null && temp.EndDate__c != null && cc.StartDate__c > temp.EndDate__c)
                    || (temp.StartDate__c != null && temp.EndDate__c != null && (cc.StartDate__c > temp.EndDate__c || cc.EndDate__c < temp.StartDate__c))
                    || (temp.StartDate__c != null && temp.EndDate__c == null && cc.EndDate__c < temp.StartDate__c)
                )){
                    System.debug('cc.DataIndex__c(' + cc.DataIndex__c + ') == temp.DataIndex__c(' + temp.DataIndex__c +')');
                    cc.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{temp.Id}));
                	return false;
                }
            }
            // if (tempLc.Size() > 0) {
            //     cc.addError('重复:' + ((sobject)tempLc.get(0)).Id);
            //     return false;
            // }
        }
        
        return true;
    }
    
    public static void reviseValue(List<CommissionConfiguration__c> newList) {
        for(CommissionConfiguration__c cc : newList) {
            cc.Total__c = handlePercent(cc.Total__c);
            cc.TV__c = handlePercent(cc.TV__c);
            cc.HA__c = handlePercent(cc.HA__c);
            // cc.WM__c = handlePercent(cc.WM__c);
            // cc.Ref__c = handlePercent(cc.Ref__c);
            cc.HighEnd__c = handlePercent(cc.HighEnd__c);
            cc.Elements7__c = handlePercent(cc.Elements7__c);
            cc.Reporting__c = handlePercent(cc.Reporting__c);
            System.debug(cc.Total__c);
            System.debug(cc.TV__c);
            System.debug(cc.HA__c);
            // System.debug(cc.WM__c);
            // System.debug(cc.Ref__c);
            System.debug(cc.HighEnd__c);
            System.debug(cc.Elements7__c);
            System.debug(cc.Reporting__c);
            System.debug(cc.Total__c 
                         + cc.TV__c 
                         + cc.HA__c 
                        //  + cc.WM__c 
                        //  + cc.Ref__c 
                         + cc.HighEnd__c
                         + cc.Elements7__c
                         + cc.Reporting__c);
            if(cc.IsActived__c != true && cc.IsActive__c) {
                cc.IsActived__c = true;
            }
        }
    }
    
    static integer handlePercent(decimal p) {
        return p == null ? 0 : (integer)p;
    }
}