/**********************************************************************
 * function:获取来自GSS系统的WMProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: WMProductInfo
 * date:2019-03-08
*************************************************************************/
@RestResource(urlMapping='/getWMProductFromGSS')
global with sharing class GetWMProductFromGSS {
    global class AppInput{
        
        List<WMProductInfo> ProductList;
    }
    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }
    global class WMProductInfo{
        public String FactoryModel; 
        public String HighEnd;
        public String ISFrequencyConversion;
        public String MotorType;
        public String OperatingVoltage;
        public String EnvironmentalInformation;
        public String CertificationInformation;
        public String EnergyEfficiencyRating;
        public String ProductNetSize;
        public String PackageSize;
        public String PowerLineRequirements;
        public String WashingCapacity;
        public String DryingCapacity;
        //public String ControlType;
        public String DisplayMode;
        public String Heating;
        public String DoorLockType;
        public String BoxColor;
        public String KnockerType;
        public String KnockerColor;
        public String InnerDrumVolume;
        public String RotateSpeedRPM;
        public String WaterConsumptionLevel;
        public String WaterConsumption;
        public String WaterInlet;
        public String DrainageMethod;
        public String WMType;
    }

    @HttpPost
    global static GetWMProductFromGSS.AppOutPut adoPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        system.debug('doPost now, body : ' + reqBody);
        // String reqBody = '{"ProductList": [{"FactoryModel": "WFHM8012-KUS001","HighEnd": "中档","ISFrequencyConversion": "定速","MotorType": "串激电机","OperatingVoltage": "220-240","EnvironmentalInformation": "RoHS+REACH+PAHs+邻苯","CertificationInformation": "CE；CB","EnergyEfficiencyRating": "A+++","ProductNetSize": "595×595×850","PackageSize": "660X655X890","PowerLineRequirements": "法式双圆插","WashingCapacity": 8,"DryingCapacity": 0,"DisplayMode": "DISPLAYTYPE003","Heating": "YES","DoorLockType": "PTC","BoxColor": "OUTCOLOR005","KnockerType": "助力","KnockerColor": "双色门环，外环银色，内圈黑色","InnerDrumVolume": 57,"RotateSpeedRPM": 1200,"WaterConsumptionLevel": "WATERCONREQUIREMENTS006","WaterConsumption": "","WaterInlet": "普通欧式进水管","DrainageMethod": "上排水"}],"access_token": "Bearer 00D0p0000008bDG!ARoAQJaLz0L__Qqvdgx3WZpoivQeu1qLe2B4.PGCFd703Co69r6nFacguxG9fd87rGxd23siXPA2YVj8w0QzWK4JFK_EakyA"}';

        AppInput input = new AppInput();
        GetWMProductFromGSS.AppOutPut result = new GetWMProductFromGSS.AppOutPut();
        try{
            input = (GetWMProductFromGSS.AppInput) JSON.deserialize(reqBody, GetWMProductFromGSS.AppInput.class);
            System.debug('input===>:' + input);
            //空数据
            if (input.ProductList == null || input.ProductList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            //正确数据
            }else{
                //是否涉及到update还是insert的问题？
                List<Product__c> inserList = new List<Product__c>();
                List<Product__c> updateList = new List<Product__c>();//暂时没有找到考虑该因素的关键字段， 
                
                for (GetWMProductFromGSS.WMProductInfo reqWM : input.ProductList) {
                    //把服务器上的值依次放到实体上去
                    Product__c wm = new Product__c();
                    wm.Product_Line__c = 'WM';
                    wm.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('WM Product RecordType').getRecordTypeId();
                    wm.Name = reqWM.FactoryModel;
                    wm.Middle_High_Low_End__c = String.isBlank(reqWM.HighEnd) ? null :reqWM.HighEnd;
                    wm.Frequency_conversion_Y_N__c = String.isBlank(reqWM.ISFrequencyConversion) ? null :reqWM.ISFrequencyConversion;
                    wm.Motor_type__c = String.isBlank(reqWM.MotorType) ? null :reqWM.MotorType;
                    wm.Operating_Voltage__c = String.isBlank(reqWM.OperatingVoltage) ? null :reqWM.OperatingVoltage;
                    wm.Environmental_information__c = String.isBlank(reqWM.EnvironmentalInformation) ? null :reqWM.EnvironmentalInformation;
                    wm.Certification_Information__c = String.isBlank(reqWM.CertificationInformation) ? null :reqWM.CertificationInformation;
                    wm.Energy_Efficiency_Rating__c = String.isBlank(reqWM.EnergyEfficiencyRating) ? null :reqWM.EnergyEfficiencyRating;
                    wm.Product_net_size_W_D_H_mm__c = String.isBlank(reqWM.ProductNetSize) ? null :reqWM.ProductNetSize;
                    wm.Package_size_W_D_H_mm__c = String.isBlank(reqWM.PackageSize) ? null :reqWM.PackageSize;
                    wm.Power_cord_requirements__c = String.isBlank(reqWM.PowerLineRequirements) ? null :reqWM.PowerLineRequirements;
                    wm.Washing_Capacity__c = reqWM.WashingCapacity;
                    wm.Drying_Capacity__c = reqWM.DryingCapacity; 
                    //wm.Control_Type__c = reqWM.ControlType;
                    wm.Display_Mode__c = reqWM.DisplayMode;
                    wm.Heating__c = reqWM.Heating;
                    wm.Door_Lock_Type__c = reqWM.DoorLockType;
                    wm.Box_Color__c = reqWM.BoxColor;
                    wm.Knocker_Type__c = reqWM.KnockerType;
                    wm.Knocker_Color__c = reqWM.KnockerColor;
                    if (String.isNotBlank(reqWM.InnerDrumVolume)) {
                        wm.Inner_Drum_Volume__c = reqWM.InnerDrumVolume;//Decimal.valueOf(reqWM.InnerDrumVolume)修改为文本 Modified by Johnson 04/17
                    }
                    wm.Rotate_Speed_RPM__c = reqWM.RotateSpeedRPM;
                    wm.Water_Consumption_Level__c = reqWM.WaterConsumptionLevel;
                    if (String.isNotBlank(reqWM.WaterConsumption)) {
                        wm.Water_Consumption__c = reqWM.WaterConsumption;//Decimal.valueOf(reqWM.WaterConsumption)修改为文本 Modified by Johnson 04/17
                    }
                    wm.Water_Inlet__c = reqWM.WaterInlet;
                    wm.Drainage_Method__c = reqWM.DrainageMethod;
                    wm.WM_Type__c = reqWM.WMType;
                    wm.Product_External_Id__c = reqWM.FactoryModel;
                    inserList.add(wm);
                }

                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetWMProductFromGSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = '';
                insert ic;

                result.IsSuccess = 'true';
                result.FailReason = '';
                return result;

            }
        //错误数据   
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetWMProductFromGSS';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage()+e.getLineNumber();
            insert ic;
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;
        }
        
    }
}