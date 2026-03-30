global with sharing class LocationController{
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];
    // public String latitude { get; set; }
    // public String longitude { get; set; }
    // public LocationController() {
    //     // 从 URL 中获取参数
    //     latitude = ApexPages.currentPage().getParameters().get('param1');
    //     longitude = ApexPages.currentPage().getParameters().get('param2');
    // }
    @RemoteAction
    global static List<Shop__c> getShop(Double latitude, Double longitude, Integer distance){
        return [SELECT Id, Name, Shop_Center_Location__Latitude__s, Shop_Center_Location__Longitude__s, Address1__c, City__c, State_Province__c
                FROM Shop__c
                WHERE Shop_Center_Location__Latitude__s != NULL AND Shop_Center_Location__Longitude__s != null AND DISTANCE(Shop_Center_Location__c, GEOLOCATION( :latitude,  :longitude), 'km') < :distance
                ORDER BY DISTANCE(Shop_Center_Location__c, GEOLOCATION( :latitude,  :longitude), 'mi')];
    }

    // 保存门店
    @AuraEnabled
    public static ConResponse saveShop(String recordJson){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        try{
            Shop__c shop = (Shop__c) JSON.deserialize(recordJson, Shop__c.class);
            System.debug('shop参数' + shop);
            Map<String, SObject> keyMap = new LisqContainer([
				select Id, Name_Saels_Region__c FROM Shop__c WHERE Sales_Region__c =: shop.Sales_Region__c AND Id !=: shop.Id
			]).ToMapS('Name_Saels_Region__c');
			
			if(keyMap.containsKey(shop.Name + shop.Sales_Region__c)){
				resp.code = -1;
                resp.message = Label.Name_SalesRegion_Exist;
			} else {
                upsert shop;
            }
			
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    // 查询门店
    @AuraEnabled
    public static Shop__c searchShop(String shopId){

        return [SELECT Id, Name, Sales_Region__c, Account__c, Grid__c, Address1__c, Shop_Level__c
                FROM Shop__c
                WHERE Id = :shopId];
    }

    @AuraEnabled
    public static ConResponse getShopDetail(String shopId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Shop__c shop = [SELECT Id, Name, Sales_Region__c, Account__c, Grid__c, Address1__c, Shop_Level__c, Channel_Name__c, SAP_Code__c,Exhibition_Format__c,Shop_Code__c,Country__c,
                Shop_Code_Text__c,Store_No_from_Account__c,State_Province__c,City__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s,Shop_Center_Location__c,
                Sub_Shop_Type__c, Address2__c, Postal__c, Suburb__c, Sub_Region__c, Region_Type__c, Metro_Type__c, Region__c, Storage_Location__c, Province_State__c, Channel_item__c
                FROM Shop__c
                WHERE Id = :shopId];
        mso.put('shopDetail', shop);
        if(String.isNotBlank(shop.Country__c) && String.isNotBlank(shop.State_Province__c)) {
            List<Country_State__c> CountryStates = [SELECT Id FROM Country_State__c WHERE Belong_To__c =: shop.Country__c AND Name =: shop.State_Province__c Limit 1];
        // return CountryStates.size() > 0 ? CountryStates[0].Id : '';
            String provinceId = CountryStates.size() > 0 ? CountryStates[0].Id : '';
            mso.put('provinceId', provinceId);
        } else {
            mso.put('provinceId', '');
        }
        return resp;
    }

    @AuraEnabled
    public static Account getAddress(String sapCodeId){

        return [SELECT Province_State__r.Nationality__c,Province_State__r.Name,City__c,Address__c
                FROM Account
                WHERE Id = :sapCodeId];
    }

    @AuraEnabled
    public static Boolean getCustomChannel(){
        List<Account> customList = [SELECT Id,Name FROM Account WHERE Sales_Region__c =: user.Sales_Region__c AND (Marketing_Model__c = '1'  OR Marketing_Model__c = '2') AND Channel_Name__c != NULL];
        return customList.size() > 0;
    }

    //构建方法用于通过名称 还原州省Id
    @AuraEnabled
    public static String getCountryStateId(String countryCode, String ProvinceName){
        List<Country_State__c> CountryStates = [SELECT Id FROM Country_State__c WHERE Belong_To__c =: countryCode AND Name =: ProvinceName];
        if(CountryStates != null && CountryStates.size() > 0){
            return CountryStates[0].Id;
        }else {
            return '';
        }
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT Id, Name, Profile.Name
                FROM User
                WHERE Id = :UserInfo.getUserId()];
    }

}