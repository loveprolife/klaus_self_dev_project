@isTest
private class GetWMProductFromGSSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ProductList": [{"FactoryModel": "WFHM8012-KUS001","HighEnd": "中档","ISFrequencyConversion": "定速","MotorType": "串激电机","OperatingVoltage": "220-240","EnvironmentalInformation": "RoHS+REACH+PAHs+邻苯","CertificationInformation": "CE；CB","EnergyEfficiencyRating": "A+++","ProductNetSize": "595×595×850","PackageSize": "660X655X890","PowerLineRequirements": "法式双圆插","WashingCapacity": 8,"DryingCapacity": 0,"DisplayMode": "DISPLAYTYPE003","Heating": "YES","DoorLockType": "PTC","BoxColor": "OUTCOLOR005","KnockerType": "助力","KnockerColor": "双色门环，外环银色，内圈黑色","InnerDrumVolume": 57,"RotateSpeedRPM": 1200,"WaterConsumptionLevel": "WATERCONREQUIREMENTS006","WaterConsumption": "3L","WaterInlet": "普通欧式进水管","DrainageMethod": "上排水"}],"access_token": "Bearer 00D0p0000008bDG!ARoAQJaLz0L__Qqvdgx3WZpoivQeu1qLe2B4.PGCFd703Co69r6nFacguxG9fd87rGxd23siXPA2YVj8w0QzWK4JFK_EakyA"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetWMProductFromGSS.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"ProductList": []}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetWMProductFromGSS.adoPost();
        Test.stopTest();
    }
     //传错误数据
    static testMethod void testMethod3() {
    	Test.startTest();
        String jsonStr = '"fudgs"';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetWMProductFromGSS.adoPost();
        Test.stopTest();
    }
}