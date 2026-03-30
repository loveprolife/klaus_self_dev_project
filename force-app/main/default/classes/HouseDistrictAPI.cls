@RestResource(urlMapping='/HouseDistrict/*')
global with sharing class HouseDistrictAPI {
    
    @HttpGet
    global static List<HouseWrapper> doGet() {
        List<HouseWrapper> houseList = new List<HouseWrapper>();
        
        // Query House__c records with their associated District__c information
        List<House__c> houses = [
            SELECT Id, Name, Area__c, UnitPrice__c, TotalPrice__c, Floors__c, 
                   DecorationStyle__c, HasGarage__c, HasPool__c, Notes__c,
                   District__r.Id, District__r.Province__c, District__r.City__c, 
                   District__r.County__c, District__r.Town__c, District__r.Street__c
            FROM House__c
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
        
        for (House__c h : houses) {
            HouseWrapper hw = new HouseWrapper();
            hw.houseId = h.Id;
            hw.houseNumber = h.Name;
            hw.area = h.Area__c;
            hw.unitPrice = h.UnitPrice__c;
            hw.totalPrice = h.TotalPrice__c;
            hw.floors = h.Floors__c;
            hw.decorationStyle = h.DecorationStyle__c;
            hw.hasGarage = h.HasGarage__c;
            hw.hasPool = h.HasPool__c;
            hw.notes = h.Notes__c;
            
            if (h.District__r != null) {
                DistrictWrapper dw = new DistrictWrapper();
                dw.districtId = h.District__r.Id;
                dw.province = h.District__r.Province__c;
                dw.city = h.District__r.City__c;
                dw.county = h.District__r.County__c;
                dw.town = h.District__r.Town__c;
                dw.street = h.District__r.Street__c;
                hw.district = dw;
            }
            
            houseList.add(hw);
        }
        
        return houseList;
    }
    
    @HttpPost
    global static ResponseWrapper doPost(DistrictWrapper district, HouseWrapper house) {
        // ... (existing doPost implementation)
        ResponseWrapper response = new ResponseWrapper();
        Savepoint sp = Database.setSavepoint();
        try {
            District__c distObj = new District__c();
            if (district != null) {
                distObj.Province__c = district.province;
                distObj.City__c = district.city;
                distObj.County__c = district.county;
                distObj.Town__c = district.town;
                distObj.Street__c = district.street;
            }
            insert distObj;
            
            House__c houseObj = new House__c();
            if (house != null) {
                houseObj.Area__c = house.area;
                houseObj.UnitPrice__c = house.unitPrice;
                houseObj.TotalPrice__c = house.totalPrice;
                houseObj.Floors__c = house.floors;
                houseObj.DecorationStyle__c = house.decorationStyle;
                houseObj.HasGarage__c = house.hasGarage;
                houseObj.HasPool__c = house.hasPool;
                houseObj.Notes__c = house.notes;
            }
            houseObj.District__c = distObj.Id;
            insert houseObj;
            
            response.isSuccess = true;
            response.districtId = distObj.Id;
            response.houseId = houseObj.Id;
            response.message = 'Success';
        } catch(Exception e) {
            Database.rollback(sp);
            response.isSuccess = false;
            response.message = e.getMessage();
        }
        return response;
    }
    
    global class DistrictWrapper {
        global String districtId {get; set;}
        global String province {get; set;}
        global String city {get; set;}
        global String county {get; set;}
        global String town {get; set;}
        global String street {get; set;}
    }
    
    global class HouseWrapper {
        global String houseId {get; set;}
        global String houseNumber {get; set;}
        global Decimal area {get; set;}
        global Decimal unitPrice {get; set;}
        global Decimal totalPrice {get; set;}
        global Decimal floors {get; set;}
        global String decorationStyle {get; set;}
        global Boolean hasGarage {get; set;}
        global Boolean hasPool {get; set;}
        global String notes {get; set;}
        global DistrictWrapper district {get; set;}
    }
    
    global class ResponseWrapper {
        global Boolean isSuccess {get; set;}
        global String message {get; set;}
        global String districtId {get; set;}
        global String houseId {get; set;}
    }
}