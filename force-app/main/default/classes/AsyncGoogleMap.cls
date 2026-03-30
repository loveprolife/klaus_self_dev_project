/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-05-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
//异步调用Google map接口
    public class AsyncGoogleMap implements Queueable, Database.AllowsCallouts {
        /*// public String shopId { get; set; }
        // public String addressNew { get; set; }
        public Map<String, String> shopMap { get; set; }
        public AsyncGoogleMap(Map<String, String> shopMap){
            // this.shopId = shopId;
            // this.addressNew = addressNew;
            this.shopMap = shopMap;
        }
        public void execute(QueueableContext context) {
            System.debug('www-' + shopMap);
            // 要更新的门店
            Map<String, List<Decimal>> latlngMap = new Map<String, List<Decimal>>();
            List<Shop__c> shopList = [select id,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s from Shop__c where id in :shopMap.keySet()];

            for(String shopId : shopMap.keySet()){
                String addressNew = shopMap.get(shopId);
                Map<String, Object> locationMap = Utility.geolocationGetLatLng(addressNew);
                Decimal lat;
                Decimal lng;
                if(locationMap != null){
                    if(locationMap.get('lat') != null){
                        lat = Decimal.valueOf(locationMap.get('lat') + '');
                    }
                    if(locationMap.get('lng') != null){
                        lng = Decimal.valueOf(locationMap.get('lng') + '');
                    }
                }
                latlngMap.put(shopId, new List<Decimal>{lat, lng});
            }

            for(Shop__c shop : shopList){
                shop.Shop_Center_Location__Latitude__s = latlngMap.get(shop.id)[0];
                shop.Shop_Center_Location__Longitude__s = latlngMap.get(shop.id)[1];
            }

            // Map<String, Object> locationMap = Utility.geolocationGetLatLng(addressNew);
            // Shop__c shop = [select id,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s from Shop__c where id = :shopId];
            // if(locationMap != null){
            //     if(locationMap.get('lat') != null){
            //         shop.Shop_Center_Location__Latitude__s = Decimal.valueOf(locationMap.get('lat') + '');
            //     }
            //     if(locationMap.get('lng') != null){
            //         shop.Shop_Center_Location__Longitude__s = Decimal.valueOf(locationMap.get('lng') + '');
            //     }
            // }

            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ShopTriggerHandler');
            UPDATE shopList;
            
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
        }*/

        public Map<Integer, List<Shop__c>> shopJobListMap;
        public Integer index;
        public AsyncGoogleMap(Map<Integer, List<Shop__c>> shopJobListMap, Integer index){
            // this.shopId = shopId;
            // this.addressNew = addressNew;
            this.shopJobListMap = shopJobListMap;
            this.index = index;
        }
        public void execute(QueueableContext context) {
            // 要更新的门店
            Map<String, List<Decimal>> latlngMap = new Map<String, List<Decimal>>();
            if (shopJobListMap.containsKey(index)) {
                List<Shop__c> updateShopList = new List<Shop__c>();
                for (Shop__c shop : shopJobListMap.get(index)) {
                    Shop__c newShop = new Shop__c();
                    Map<String, Object> locationMap = Utility.geolocationGetLatLng(shop.City__c + shop.Address1__c);
                    System.debug(LoggingLevel.INFO, '*** locationMap: ' + locationMap);
                    if(locationMap != null){
                        Decimal lat;
                        Decimal lng;
                        if(locationMap.get('lat') != null){
                            lat = Decimal.valueOf(locationMap.get('lat') + '');
                        }
                        if(locationMap.get('lng') != null){
                            lng = Decimal.valueOf(locationMap.get('lng') + '');
                        }
                        //Add By Ethan 20230922 增加省份 S 
                        String district = locationMap.get('administrative_area_level_1') != NULL ? String.valueOf(locationMap.get('administrative_area_level_1')) : NULL;
                        newShop.District__c = district;
                        //Add By Ethan 20230922 增加省份 E 
                        
                        newShop.Id = shop.Id;
                        newShop.Shop_Center_Location__Latitude__s = lat;
                        newShop.Shop_Center_Location__Longitude__s = lng;
                        updateShopList.add(newShop);
                    }
                }

                if (!updateShopList.isEmpty()) {
                    //忽略触发器更新
                    GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ShopTriggerHandler');
                    UPDATE updateShopList;
                    
                    //恢复触发器
                    Utility.IgnoreAction(false,false,false,'');
                    if (shopJobListMap.containsKey(index + 1) && index + 1 < 50) {
                        System.enqueueJob(new AsyncGoogleMap(shopJobListMap, index + 1));
                    }
                }
            }
        }
    }