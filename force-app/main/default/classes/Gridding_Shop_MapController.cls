/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-05-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public without sharing class Gridding_Shop_MapController {
    public static String netWorkUrl;
    public static List<Markers> markersList{GET;SET;}
    public string lexOrigin { 
        get { 
            return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        } 
        set;
    }

    @AuraEnabled(cacheable = true)
    public static string getVisualforceOrigin() {
        string visualOrigin;
        string baseUrl = URL.getOrgDomainUrl().toExternalForm(); 
        visualOrigin = baseUrl.split('.my.')[0] + '--c.' + 'visualforce.com';
        return visualOrigin;
    }

    @AuraEnabled
    public static InitDataClass searchShopData(String recordId) {
        InitDataClass ic = new InitDataClass();
        
        //获取当前网格下所有的门店
        List<Shop__c> shopList = [SELECT Name, 
                                         Shop_Center_Location__c,
                                         Shop_Center_Location__Latitude__s,
                                         Shop_Center_Location__Longitude__s,
                                         Shop_External_Key__c,
                                         Account__c
                                  FROM Shop__c 
                                  WHERE Grid__c = :recordId];
        if (shopList.isEmpty()) {
            return ic;
        }

        //组织所有门店的点位
        List<Markers> mkList = new List<Markers>();
        for (Shop__c shop : shopList) {
            Position pos = new Position();
            Markers mk = new Markers();
            mk.shopName = shop.Name;
            pos.lat = shop.Shop_Center_Location__Latitude__s;
            pos.lng = shop.Shop_Center_Location__Longitude__s;
            mk.position = pos;
            if (pos.lat != null && pos.lng != null) {
                mkList.add(mk);
            }
        }
        ic.markersList = mkList;
        System.debug(LoggingLevel.INFO, '*** : mkList' + mkList);
        return ic;
    }

    public class InitDataClass {
        @AuraEnabled public Boolean isError{GET;SET;}
        @AuraEnabled public String msg{GET;SET;}
        @AuraEnabled public List<Markers> markersList{GET;SET;}  // 门店点位信息

        public InitDataClass(){
            this.isError = false;
            this.msg = '';
            this.markersList = new List<Markers>();
        }
    }

    public class Markers {
        @AuraEnabled public Position position{GET;SET;}
        @AuraEnabled public String shopName{GET;SET;}
        public Markers(){
            this.position = new Position();
            this.shopName = '';
        }
    }

    public class Position {
        @AuraEnabled public Decimal lat{GET;SET;}
        @AuraEnabled public Decimal lng{GET;SET;}
        public Position(){
            this.lat = null;
            this.lng = null;
        }
    }
}