/**********************************************************************
 * function:获取来自GSS系统的FreezerProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: 
 * date:2019-03-07
*************************************************************************/
@RestResource(urlMapping='/getFreezerProductFromGSS')
global with sharing class GetFreezerProductFromGSS {
    global class AppInput{
        List<FreezerProductInfo> ProductList;
    }
    global class AppOutput{
        String IsSuccess;
        String FailReason;
    }
    global class FreezerProductInfo{
        String FactoryModel;
        String HighEnd;
        String ExportModelName;
        String DoorNumber;
        String CoolingMethod;
        String VolumeSegment;
        String TemperatureControlMode;
        String VoltageFrequency;
        String EnergyEfficiencyRating;
        String NominalEnergyConsumption;
        String NominalCertification;
        String ProductDimensions;
        String PowerLineRequirements;
        String Appearance;
        String LightBoxLight;
        String ClimateType;
        String EnergyConsumption;
        String RefrigeratingCapacity;
        String LoadingPickup;
        String Noise;
        String InternalExternalCondenser;
        String RefrigeratingFluid;
        String ControlMode;
        String HandleType;
    }
    @HttpPost
    global static GetFreezerProductFromGSS.AppOutput doPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        System.debug('do post now , body :' + reqBody);

        GetFreezerProductFromGSS.AppInput input = new GetFreezerProductFromGSS.AppInput();
        GetFreezerProductFromGSS.AppOutput result = new GetFreezerProductFromGSS.AppOutput();

        try{
            //传过来的字符串
            input = (GetFreezerProductFromGSS.AppInput)JSON.deserialize(reqBody, GetFreezerProductFromGSS.AppInput.class);
            System.debug('input====>'+input);
            if (input.ProductList == null || input.ProductList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{
                List<Product__c> inserList = new List<Product__c>();
                List<Product__c> updateList = new List<Product__c>();
                for (GetFreezerProductFromGSS.FreezerProductInfo reqFreezer: input.ProductList) {
                    Product__c freezer = new Product__c();
                    freezer.Product_Line__c = 'Freezer';
                    //设置记录类型
                    freezer.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Freezer Product RecordType').getRecordTypeId();
                    freezer.Name = reqFreezer.FactoryModel;
                    freezer.Middle_High_Low_End__c = String.isBlank(reqFreezer.HighEnd) ? null :reqFreezer.HighEnd; 
                    freezer.Export_model_name_first_7_digits__c = String.isBlank(reqFreezer.ExportModelName) ? null :reqFreezer.ExportModelName;
                    freezer.Product_level_door__c = String.isBlank(reqFreezer.DoorNumber) ? null :reqFreezer.DoorNumber; 
                    freezer.Product_level_cooling_method__c = String.isBlank(reqFreezer.CoolingMethod) ? null :reqFreezer.CoolingMethod; 
                    freezer.Product_level_volume_segment__c = String.isBlank(reqFreezer.VolumeSegment) ? null :reqFreezer.VolumeSegment; 
                    freezer.Product_level_temperature_control_mode__c = String.isBlank(reqFreezer.TemperatureControlMode) ? null :reqFreezer.TemperatureControlMode;
                    freezer.Voltage_frequency__c = String.isBlank(reqFreezer.VoltageFrequency) ? null :reqFreezer.VoltageFrequency;
                    freezer.Energy_Efficiency_Rating__c = String.isBlank(reqFreezer.EnergyEfficiencyRating) ? null :reqFreezer.EnergyEfficiencyRating;
                    freezer.Nominal_energy_consumption__c = String.isBlank(reqFreezer.NominalEnergyConsumption) ? null :reqFreezer.NominalEnergyConsumption;
                    freezer.Nominal_certification__c = String.isBlank(reqFreezer.NominalCertification) ? null :reqFreezer.NominalCertification;
                    freezer.Product_dimensions_width_depth_heig__c = String.isBlank(reqFreezer.ProductDimensions) ? null :reqFreezer.ProductDimensions;
                    freezer.Power_cord_requirements__c = String.isBlank(reqFreezer.PowerLineRequirements) ? null :reqFreezer.PowerLineRequirements;
                    freezer.Appearance__c = String.isBlank(reqFreezer.Appearance) ? null :reqFreezer.Appearance;
                    freezer.Light_box_light__c = String.isBlank(reqFreezer.LightBoxLight) ? null :reqFreezer.LightBoxLight;
                    freezer.Climate_type__c = reqFreezer.ClimateType;
                    freezer.Energy_Consumption__c = reqFreezer.EnergyConsumption;
                    freezer.Refrigerating_Capacity__c = reqFreezer.RefrigeratingCapacity;//Decimal.valueOf(reqFreezer.RefrigeratingCapacity)修改为文本 Modified by Johnson 04/17
                    freezer.Loading_Pickup__c = reqFreezer.LoadingPickup;
                    freezer.Noise__c = reqFreezer.Noise;
                    freezer.Internal_External_Condenser__c = reqFreezer.InternalExternalCondenser;
                    freezer.Refrigerating_Fluid__c = reqFreezer.RefrigeratingFluid;
                    freezer.Control_Mode__c = reqFreezer.ControlMode;
                    freezer.Handle_Type__c = reqFreezer.HandleType;
                    freezer.Product_External_Id__c = reqFreezer.FactoryModel;
                    inserList.add(freezer);
                }
                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetFreezerProductFromGSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = '';
                insert ic;

                result.IsSuccess = 'true';
                result.FailReason = '';
                return result;
            }
        }catch(Exception e){
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetFreezerProductFromGSS';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;
        }

    }
}