/**********************************************************************
 * function:获取来自GSS系统的RefrigerProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: RefrigerProductInfo
 * date:2019-03-08
*************************************************************************/
@RestResource(urlMapping='/getRefrigeratorProductFromGSS')
global with sharing class GetRefrigeratorProductFromGSS {
    global class AppInput{
        
        List<RefrigerProductInfo> ProductList;
    }
    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }
    global class RefrigerProductInfo{
        public String FactoryModel; 
        public String HighEnd;
        public String ExportModel;
        public String BasicProduct;
        public String CustomerType;
        public String DoorNumber;
        public String IsFrequencyConversion;
        public String CoolingMethod;
        public String ColumeCegment;
        public String TemperatureControlMode;
        public String BottlingAmount;
        public String Refrigerant;
        public String VoltageFrequency;
        public String ClimateType;
        public String PowerConsumption;
        public String EnergyRequirements;
        public String FreezingAbility;
        public String PowerLineRequirements;
        public String VendorBrand;
        public String BoundaryDimensionW;
        //public String BoundaryDimensionD;
        //public String BoundaryDimensionH;
        //public String FreezingChamberDrawer;
        //public String FreezingChamberShelf;
        //public String FreezingChamberStoragerack;
        //public String FreezingChamberIcemaking;
        //public String ColdClosetShelf;
        //public String ColdClosetStoragRack;
        //public String ColdClosetFruitBox;
        public String TotalVolume;
        public String ColdStorageVolume;
        public String FrozenVolume;
        public String RefrigeratingDoorConfiguration;
        public String RefrigeratingShelf;
        public String RefrigeratingFruitBoxCover;
        public String FreezingDoorConfiguration;
        public String FreezingRoomConfiguration;
        public String PanelPattern;
        public String HandleAppearance;
        public String WaterFeatures;
        public String IRCompleteDate;
        public String RefrigeratorType;
    }

    @HttpPost
    global static GetRefrigeratorProductFromGSS.AppOutPut adoPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        system.debug('doPost now, body : ' + reqBody);

        AppInput input = new AppInput();
        GetRefrigeratorProductFromGSS.AppOutPut result = new GetRefrigeratorProductFromGSS.AppOutPut();
        try{
            input = (GetRefrigeratorProductFromGSS.AppInput) JSON.deserialize(reqBody, GetRefrigeratorProductFromGSS.AppInput.class);
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
                
                for (GetRefrigeratorProductFromGSS.RefrigerProductInfo reqR : input.ProductList) {
                    //把服务器上的值依次放到实体上去
                    Product__c refrigerator = new Product__c();
                    refrigerator.Product_Line__c = 'Refrigerator';
                    refrigerator.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Refrigerator Product RecordType').getRecordTypeId();
                    refrigerator.Name = String.isBlank(reqR.FactoryModel) ? null:reqR.FactoryModel;
                    refrigerator.Middle_High_Low_End__c = String.isBlank(reqR.HighEnd) ? null:reqR.HighEnd;
                    refrigerator.Export_model__c = String.isBlank(reqR.ExportModel) ? null:reqR.ExportModel;
                    refrigerator.Basic_product__c = String.isBlank(reqR.BasicProduct) ? null:reqR.BasicProduct;
                    refrigerator.Customer_Type__c = String.isBlank(reqR.CustomerType) ? null:reqR.CustomerType;
                    refrigerator.Product_level_door_number_of_doors__c = String.isBlank(reqR.DoorNumber) ? null:reqR.DoorNumber;
                    refrigerator.Product_level_frequency_conversion_Y_N__c = String.isBlank(reqR.IsFrequencyConversion) ? null:reqR.IsFrequencyConversion;
                    refrigerator.Product_level_cooling_method_product__c = String.isBlank(reqR.CoolingMethod) ? null:reqR.CoolingMethod;
                    refrigerator.Product_level_volume_segment_volume__c = String.isBlank(reqR.ColumeCegment) ? null:reqR.ColumeCegment;
                    refrigerator.Product_category_temperature_control_mo__c = String.isBlank(reqR.TemperatureControlMode) ? null:reqR.TemperatureControlMode;
                    refrigerator.Product_category_bottling_amount__c = String.isBlank(reqR.BottlingAmount) ? null:reqR.BottlingAmount;
                    refrigerator.Refrigerant_Refrigerant__c = String.isBlank(reqR.Refrigerant) ? null:reqR.Refrigerant;
                    refrigerator.Voltage_Frequency_Voltage_Frequency__c = String.isBlank(reqR.VoltageFrequency) ? null:reqR.VoltageFrequency;
                    refrigerator.Climate_type__c = String.isBlank(reqR.ClimateType) ? null:reqR.ClimateType;
                    refrigerator.Power_consumption__c = String.isBlank(reqR.PowerConsumption) ? null:reqR.PowerConsumption;
                    refrigerator.Energy_requirements__c = String.isBlank(reqR.EnergyRequirements) ? null:reqR.EnergyRequirements;
                    refrigerator.Freezing_ability__c = String.isBlank(reqR.FreezingAbility) ? null:reqR.FreezingAbility;
                    refrigerator.Power_cord_requirements__c = String.isBlank(reqR.PowerLineRequirements) ? null:reqR.PowerLineRequirements;
                    refrigerator.Vendor_Brand__c = reqR.VendorBrand;
                    refrigerator.Boundary_Dimension_WDH__c = reqR.BoundaryDimensionW;
                    // refrigerator.Freezing_Chamber_Drawer__c = reqR.FreezingChamberDrawer;
                    // refrigerator.Freezing_Chamber_Shelf__c = reqR.FreezingChamberShelf;
                    // refrigerator.Freezing_Chamber_Storage_Rack__c = reqR.FreezingChamberStoragerack;
                    // refrigerator.Freezing_Chamber_Ice_Making__c = reqR.FreezingChamberIcemaking;
                    //refrigerator.Cold_Closet_Shelf__c = reqR.ColdClosetShelf;
                    //refrigerator.Cold_Closet_Storag_Rack__c = reqR.ColdClosetStoragRack;
                    //refrigerator.Cold_Closet_Fruit_Box__c = reqR.ColdClosetFruitBox;
                    refrigerator.Total_Volume__c = reqR.TotalVolume;//Decimal.valueOf(reqR.TotalVolume)修改为文本 Modified by Johnson 04/17
                    refrigerator.Cold_Storage_Volume__c = reqR.ColdStorageVolume;//Decimal.valueOf(reqR.ColdStorageVolume)修改为文本 Modified by Johnson 04/17
                    refrigerator.Frozen_Volume__c = reqR.FrozenVolume;//Decimal.valueOf(reqR.FrozenVolume)修改为文本 Modified by Johnson 04/17
                    refrigerator.Refrigerating_Door_Configuration__c = reqR.RefrigeratingDoorConfiguration;
                    refrigerator.Refrigerating_Shelf__c = reqR.RefrigeratingShelf;
                    refrigerator.Refrigerating_Fruit_Box_Cover__c = reqR.RefrigeratingFruitBoxCover;
                    refrigerator.Freezing_Door_Configuration__c = reqR.FreezingDoorConfiguration;
                    refrigerator.Freezing_Room_Configuration__c = reqR.FreezingRoomConfiguration;
                    refrigerator.Panel_Pattern__c = reqR.PanelPattern;
                    refrigerator.Handle_Appearance__c = reqR.HandleAppearance;
                    refrigerator.Water_Features__c = reqR.WaterFeatures;
                    refrigerator.IR_Complete_Date__c = reqR.IRCompleteDate;
                    refrigerator.Refrigerator_Type__c = reqR.RefrigeratorType;
                    refrigerator.Product_External_Id__c = reqR.FactoryModel;
                    inserList.add(refrigerator);
                }

                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetRefrigeratorProductFromGSS';
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
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetRefrigeratorProductFromGSS';
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