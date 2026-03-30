/**********************************************************************
 * function:将Product推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendProductToBigData')
global with sharing class SendProductToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<ProductInfo> productInfoList;
    }

    public class ProductInfo {
        public String id;
        public String CreatedDate;
        public String LastModifiedDate;
        public String Name;
        public String ACType;
        public String ActualEXW;
        public String Appearance;
        public String Applicationnumber;
        public String BackShellColor;
        public String BackShellDesign;
        public String BaseColor;
        public String BaseForm;
        public String Basicproduct;
        public String Bluetooth;
        public String BorderMaterial;
        public String BoundaryDimensionD;
        public String BoundaryDimensionH;
        public String BoundaryDimensionWDH;
        public String BoxColor;
        public String Brand;
        public String BrightnessNIT;
        public String BuitiWIFI;
        public String CategoryTVType;
        public String Category;
        public String Categorys;
        public String CertificationInformation;
        public String Channel1;
        public String Channel2;
        public String Climatetype;
        public String ColdClosetFruitBox;
        public String ColdClosetHumidityFunction;
        public String ColdClosetShelf;
        public String ColdClosetStoragRack;
        public String ColdClosetZeroDegreeRoom;
        public String ColdStorageVolume;
        public String CompetitiveBrand;
        public String ControlMode;
        public String ControlType;
        public String Controlboardheight;
        public String CoolingCapacity;
        public String CoolingPower;
        public String Country;
        public String CustomerType;
        public String DRTime;
        public String DisplayMode;
        public String DoorDiameter;
        public String DoorLockType;
        public String DoorLock;
        public String DoorMaterial;
        public String Doorlamp;
        public String DrainageMethod;
        public String DryingCapacity;
        public String EnergyConsumption;
        public String EnergyEfficiencyRating;
        public String EnergyEfficiencyRatio;
        public String EnergyefficiencyratingTV;
        public String Energyrequirements;
        public String Environmentalinformation;
        public String EstimatedDRTime;
        public String ExpectedIRTime;
        public String Exportmodel;
        public String Exportmodelnamefirst7digits;
        public String FreezingChamberDrawer;
        public String FreezingChamberIceMaking;
        public String FreezingChamberShelf;
        public String FreezingChamberStorageRack;
        public String FreezingDoorConfiguration;
        public String FreezingRoomConfiguration;
        public String Freezingability;
        public String FrequencyconversionYN;
        public String FrontShellColor;
        public String FrozenVolume;
        public String GuidingPrice;
        public String HDMI;
        public String HDR;
        public String HandleAppearance;
        public String HandleForm;
        public String HandleType;
        public String HardwareBandGSM;
        public String HardwareCPUplatform;
        public String HardwareLCDTPresolution;
        public String HardwareLCDTPsize;
        public String HardwareMemoryRAMinGB;
        public String HardwarebandCDMA;
        public String HardwarebandLTE;
        public String HardwarebandWCDMA;
        public String HardwaremaincamerapixelinMP;
        public String HardwarememoryROMunitGB;
        public String HardwaresubcamerapixelunitMP;
        public String HeatingCapacityUnit;
        public String HeatingCapacity;
        public String HeatingEfficiencyUnit;
        public String HeatingEfficiency;
        public String Heating;
        public String HighColorGamut;
        public String IDUPackageSize;
        public String IDUSize;
        public String IRCompleteDate;
        public String IRTime;
        public String IndicatorFunction;
        public String Indoorenclosure;
        public String InnerContainerRequirements;
        public String InnerDrumVolume;
        public String InnerGlassDoor;
        public String IntelligentSystem;
        public String InternalExternalCondenser;
        public String IsActive;
        public String IsInMyRegion;
        public String Keyproducts;
        public String KnockerColor;
        public String KnockerType;
        public String Level;
        public String Lightboxlight;
        public String LoadingCapacity;
        public String LoadingPickup;
        public String LoadingQuantity40HC20HC;
        public String LocalDimmingBackLightControl;
        public String MEMC;
        public String MainFunction;
        public String MiddleHighLowEnd;
        public String Motortype;
        public String MovementModel;
        public String Narrowborder;
        public String Netvolume;
        public String Noise;
        public String Nominalcertification;
        public String Nominalenergyconsumption;
        public String NumberofBasket;
        public String NumberofSpeakers;
        public String ODUPackageSize;
        public String ODUSize;
        public String OpenAngle;
        public String OperatingVoltage;
        public String Outdoorenclosure;
        public String Outdoorproductmodel;
        public String Outdoorunitproductionmodel;
        public String POPFoldingImage;
        public String PackagesizeWDHmm;
        public String Packagingmaterialboxtype;
        public String PanelManufacturer;
        public String PanelModel;
        public String PanelPattern;
        public String PlaneSurface;
        public String Powerconsumption;
        public String Powercordrequirements;
        public String Pressmodel;
        public String Price1;
        public String Price2;
        public String ProductExternalId;
        public String ProductImage;
        public String ProductLine;
        public String ProductManager;
        public String ProductModel;
        public String ProductPositioning;
        public String Product;
        public String Productcategorybottlingamount;
        public String Productcategorytemperaturecontrolmo;
        public String Productdimensionswidthdepthheig;
        public String Productlevelcoolingmethod;
        public String Productlevelcoolingmethodproduct;
        public String Productleveldoor;
        public String Productleveldoornumberofdoors;
        public String ProductlevelfrequencyconversionYN;
        public String Productleveltemperaturecontrolmode;
        public String Productlevelvolumesegment;
        public String Productlevelvolumesegmentvolume;
        public String Productloading;
        public String ProductnetsizeWDHmm;
        public String Productionbase;
        public String ProjectType;
        public String QuantityCalculate;
        public String QuantumDotsQuantumDot;
        public String RefreshrateHZratingTyperating;
        public String RefrigerantRefrigerant;
        public String RefrigeratingCapacityUnit;
        public String RefrigeratingCapacity;
        public String RefrigeratingDoorConfiguration;
        public String RefrigeratingEfficiencyUnit;
        public String RefrigeratingEfficiency;
        public String RefrigeratingFluid;
        public String RefrigeratingFruitBoxCover;
        public String RefrigeratingShelf;
        public String RefrigeratorType;
        public String Remotecontrolmodel;
        public String Resource;
        public String RetailPricePrice;
        public String RotateSpeedRPM;
        public String SAPCreateTime;
        public String SAPCreate;
        public String SaleCurrency1;
        public String SaleCurrency2;
        public String SalesSeries;
        public String SalesUnit;
        public String SalesVolume;
        public String ScreePixelResolution;
        public String Screenmodel;
        public String SellingPoints;
        public String Series;
        public String ShopName;
        public String SizeJapan;
        public String Size;
        public String Softwareandroidversion;
        public String SoundTechnology;
        public String Stage;
        public String Store;
        public String TTM;
        public String TVAppStore;
        public String TVType1;
        public String TVType2;
        public String TVType3;
        public String TVType4;
        public String TargetBatchTime;
        public String TargetEXW;
        public String TotalVolume;
        public String Type;
        public String USB;
        public String Usage;
        public String VGA;
        public String VendorBrand;
        public String Vendor;
        public String VideoAggregation;
        public String VoiceControl;
        public String VoltageFrequencyVoltageFrequency;
        public String Voltagefrequency;
        public String WMType;
        public String WarrantyYear;
        public String Warranty;
        public String WashingCapacity;
        public String WaterConsumptionLevel;
        public String WaterConsumption;
        public String WaterFeatures;
        public String WaterInlet;
        public String WiFImodulerequirements;
        public String X3DTypeActiveorPassive;
        public String bottomspragTypeQuantity;
        public String salesregion;
        public String High_End_Model_Asean;

    }

    @HttpPost
    global static SendProductToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendProductToBigData.AppInput appInput = new SendProductToBigData.AppInput();
        
        SendProductToBigData.AppOutPut result = new SendProductToBigData.AppOutPut();
        
        try{
            appInput = (SendProductToBigData.AppInput)JSON.deserialize(reqBody, SendProductToBigData.AppInput.class);

            if(String.isBlank(appInput.startTime) || String.isBlank(appInput.endTime)){
                return result;
            }

            if(String.isBlank(appInput.pageIndex)){
                appInput.pageIndex = '1';
            }

            if(String.isBlank(appInput.pageSize) || Integer.valueOf(appInput.pageSize) < 200){
                appInput.pageSize = '200';
            }

            appInput.startTime = Utility.increaseHoursInStringDate(appInput.startTime,8).replace(' ','T') + '.000+0000';
            appInput.endTime = Utility.increaseHoursInStringDate(appInput.endTime,8).replace(' ','T') + '.000+0000';

            String sql = 'select '+
            'id,'+
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Name,'+
            'AC_Type__c,'+
            'Actual_EXW__c,'+
            'Appearance__c,'+
            'Application_number__c,'+
            'Back_Shell_Color__c,'+
            'Back_Shell_Design__c,'+
            'Base_Color__c,'+
            'Base_Form__c,'+
            'Basic_product__c,'+
            'Bluetooth__c,'+
            'Border_Material__c,'+
            'Boundary_Dimension_D__c,'+
            'Boundary_Dimension_H__c,'+
            'Boundary_Dimension_WDH__c,'+
            'Box_Color__c,'+
            'Brand__c,'+
            'Brightness_NIT__c,'+
            'Buit_iWIFI__c,'+
            'Category_TV_Type__c,'+
            'Category__c,'+
            'Categorys__c,'+
            'Certification_Information__c,'+
            'Channel_1__c,'+
            'Channel_2__c,'+
            'Climate_type__c,'+
            'Cold_Closet_Fruit_Box__c,'+
            'Cold_Closet_Humidity_Function__c,'+
            'Cold_Closet_Shelf__c,'+
            'Cold_Closet_Storag_Rack__c,'+
            'Cold_Closet_Zero_Degree_Room__c,'+
            'Cold_Storage_Volume__c,'+
            'Competitive_Brand__c,'+
            'Control_Mode__c,'+
            'Control_Type__c,'+
            'Control_board_height__c,'+
            'Cooling_Capacity__c,'+
            'Cooling_Power__c,'+
            'Country__c,'+
            'Customer_Type__c,'+
            'DR_Time__c,'+
            'Display_Mode__c,'+
            'Door_Diameter__c,'+
            'Door_Lock_Type__c,'+
            'Door_Lock__c,'+
            'Door_Material__c,'+
            'Door_lamp__c,'+
            'Drainage_Method__c,'+
            'Drying_Capacity__c,'+
            'Energy_Consumption__c,'+
            'Energy_Efficiency_Rating__c,'+
            'Energy_Efficiency_Ratio__c,'+
            'Energy_efficiency_rating_TV__c,'+
            'Energy_requirements__c,'+
            'Environmental_information__c,'+
            'Estimated_DR_Time__c,'+
            'Expected_IR_Time__c,'+
            'Export_model__c,'+
            'Export_model_name_first_7_digits__c,'+
            'Freezing_Chamber_Drawer__c,'+
            'Freezing_Chamber_Ice_Making__c,'+
            'Freezing_Chamber_Shelf__c,'+
            'Freezing_Chamber_Storage_Rack__c,'+
            'Freezing_Door_Configuration__c,'+
            'Freezing_Room_Configuration__c,'+
            'Freezing_ability__c,'+
            'Frequency_conversion_Y_N__c,'+
            'Front_Shell_Color__c,'+
            'Frozen_Volume__c,'+
            'Guiding_Price__c,'+
            'HDMI__c,'+
            'HDR__c,'+
            'Handle_Appearance__c,'+
            'Handle_Form__c,'+
            'Handle_Type__c,'+
            'Hardware_Band_GSM__c,'+
            'Hardware_CPU_platform__c,'+
            'Hardware_LCD_TP_resolution__c,'+
            'Hardware_LCD_TP_size__c,'+
            'Hardware_Memory_RAM_in_GB__c,'+
            'Hardware_band_CDMA__c,'+
            'Hardware_band_LTE__c,'+
            'Hardware_band_WCDMA__c,'+
            'Hardware_main_camera_pixel_in_MP__c,'+
            'Hardware_memory_ROM_unit_GB__c,'+
            'Hardware_sub_camera_pixel_unit_MP__c,'+
            'Heating_Capacity_Unit__c,'+
            'Heating_Capacity__c,'+
            'Heating_Efficiency_Unit__c,'+
            'Heating_Efficiency__c,'+
            'Heating__c,'+
            'High_Color_Gamut__c,'+
            'IDU_Package_Size__c,'+
            'IDU_Size__c,'+
            'IR_Complete_Date__c,'+
            'IR_Time__c,'+
            'Indicator_Function__c,'+
            'Indoor_enclosure__c,'+
            'Inner_Container_Requirements__c,'+
            'Inner_Drum_Volume__c,'+
            'Inner_Glass_Door__c,'+
            'Intelligent_System__c,'+
            'Internal_External_Condenser__c,'+
            'IsActive__c,'+
            'IsInMyRegion__c,'+
            'Key_products__c,'+
            'Knocker_Color__c,'+
            'Knocker_Type__c,'+
            'Level__c,'+
            'Light_box_light__c,'+
            'Loading_Capacity__c,'+
            'Loading_Pickup__c,'+
            'Loading_Quantity_40HC_20HC__c,'+
            'Local_Dimming_Back_Light_Control__c,'+
            'MEMC__c,'+
            'Main_Function__c,'+
            'Middle_High_Low_End__c,'+
            'Motor_type__c,'+
            'Movement_Model__c,'+
            'Narrow_border__c,'+
            'Net_volume__c,'+
            'Noise__c,'+
            'Nominal_certification__c,'+
            'Nominal_energy_consumption__c,'+
            'Number_of_Basket__c,'+
            'Number_of_Speakers__c,'+
            'ODU_Package_Size__c,'+
            'ODU_Size__c,'+
            'Open_Angle__c,'+
            'Operating_Voltage__c,'+
            'Outdoor_enclosure__c,'+
            'Outdoor_product_model__c,'+
            'Outdoor_unit_production_model__c,'+
            'POP_Folding_Image__c,'+
            'Package_size_W_D_H_mm__c,'+
            'Packaging_material_box_type__c,'+
            'Panel_Manufacturer__c,'+
            'Panel_Model__c,'+
            'Panel_Pattern__c,'+
            'Plane_Surface__c,'+
            'Power_consumption__c,'+
            'Power_cord_requirements__c,'+
            'Press_model__c,'+
            'Price_1__c,'+
            'Price_2__c,'+
            'Product_External_Id__c,'+
            'Product_Image__c,'+
            'Product_Line__c,'+
            'Product_Manager__c,'+
            'Product_Model__c,'+
            'Product_Positioning__c,'+
            'Product__c,'+
            'Product_category_bottling_amount__c,'+
            'Product_category_temperature_control_mo__c,'+
            'Product_dimensions_width_depth_heig__c,'+
            'Product_level_cooling_method__c,'+
            'Product_level_cooling_method_product__c,'+
            'Product_level_door__c,'+
            'Product_level_door_number_of_doors__c,'+
            'Product_level_frequency_conversion_Y_N__c,'+
            'Product_level_temperature_control_mode__c,'+
            'Product_level_volume_segment__c,'+
            'Product_level_volume_segment_volume__c,'+
            'Product_loading__c,'+
            'Product_net_size_W_D_H_mm__c,'+
            'Production_base__c,'+
            'Project_Type__c,'+
            'Quantity_Calculate__c,'+
            'Quantum_Dots_Quantum_Dot__c,'+
            'Refresh_rate_HZ_rating_Type_rating__c,'+
            'Refrigerant_Refrigerant__c,'+
            'Refrigerating_Capacity_Unit__c,'+
            'Refrigerating_Capacity__c,'+
            'Refrigerating_Door_Configuration__c,'+
            'Refrigerating_Efficiency_Unit__c,'+
            'Refrigerating_Efficiency__c,'+
            'Refrigerating_Fluid__c,'+
            'Refrigerating_Fruit_Box_Cover__c,'+
            'Refrigerating_Shelf__c,'+
            'Refrigerator_Type__c,'+
            'Remote_control_model__c,'+
            'Resource__c,'+
            'Retail_Price_Price__c,'+
            'Rotate_Speed_RPM__c,'+
            'SAPCreateTime__c,'+
            'SAPCreate__c,'+
            'Sale_Currency_1__c,'+
            'Sale_Currency_2__c,'+
            'Sales_Series__c,'+
            'Sales_Unit__c,'+
            'Sales_Volume__c,'+
            'ScreePixel_Resolution__c,'+
            'Screen_model__c,'+
            'Selling_Points__c,'+
            'Series__c,'+
            'Shop_Name__c,'+
            'Size_Japan__c,'+
            'Size__c,'+
            'Software_android_version__c,'+
            'Sound_Technology__c,'+
            'Stage__c,'+
            'Store__c,'+
            'TTM__c,'+
            'TV_App_Store__c,'+
            'TV_Type1__c,'+
            'TV_Type2__c,'+
            'TV_Type3__c,'+
            'TV_Type4__c,'+
            'Target_Batch_Time__c,'+
            'Target_EXW__c,'+
            'Total_Volume__c,'+
            'Type__c,'+
            'USB__c,'+
            'Usage__c,'+
            'VGA__c,'+
            'Vendor_Brand__c,'+
            'Vendor__c,'+
            'Video_Aggregation__c,'+
            'Voice_Control__c,'+
            'Voltage_Frequency_Voltage_Frequency__c,'+
            'Voltage_frequency__c,'+
            'WM_Type__c,'+
            'Warranty_Year__c,'+
            'Warranty__c,'+
            'Washing_Capacity__c,'+
            'Water_Consumption_Level__c,'+
            'Water_Consumption__c,'+
            'Water_Features__c,'+
            'Water_Inlet__c,'+
            'WiFI_module_requirements__c,'+
            'X3D_Type_Active_or_Passive__c,'+
            'bottom_sprag_Type_Quantity__c,'+
            'High_End_Model_Asean__c,'+
            'sales_region__c'+

            ' from Product__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Product__c> ProductList = (List<Product__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Product__c> ProductList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));

            List<ProductInfo> ProductInfoList = new List<ProductInfo>();

            for(Product__c a : ProductList){
                ProductInfo c = new ProductInfo();
                c.id = checkNull(a.id + '');
                c.Name = checkNull(a.Name + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.ACType = checkNull(a.AC_Type__c + '');
                c.ActualEXW = checkNull(a.Actual_EXW__c + '');
                c.Appearance = checkNull(a.Appearance__c + '');
                c.Applicationnumber = checkNull(a.Application_number__c + '');
                c.BackShellColor = checkNull(a.Back_Shell_Color__c + '');
                c.BackShellDesign = checkNull(a.Back_Shell_Design__c + '');
                c.BaseColor = checkNull(a.Base_Color__c + '');
                c.BaseForm = checkNull(a.Base_Form__c + '');
                c.Basicproduct = checkNull(a.Basic_product__c + '');
                c.Bluetooth = checkNull(a.Bluetooth__c + '');
                c.BorderMaterial = checkNull(a.Border_Material__c + '');
                c.BoundaryDimensionD = checkNull(a.Boundary_Dimension_D__c + '');
                c.BoundaryDimensionH = checkNull(a.Boundary_Dimension_H__c + '');
                c.BoundaryDimensionWDH = checkNull(a.Boundary_Dimension_WDH__c + '');
                c.BoxColor = checkNull(a.Box_Color__c + '');
                c.Brand = checkNull(a.Brand__c + '');
                c.BrightnessNIT = checkNull(a.Brightness_NIT__c + '');
                c.BuitiWIFI = checkNull(a.Buit_iWIFI__c + '');
                c.CategoryTVType = checkNull(a.Category_TV_Type__c + '');
                c.Category = checkNull(a.Category__c + '');
                c.Categorys = checkNull(a.Categorys__c + '');
                c.CertificationInformation = checkNull(a.Certification_Information__c + '');
                c.Channel1 = checkNull(a.Channel_1__c + '');
                c.Channel2 = checkNull(a.Channel_2__c + '');
                c.Climatetype = checkNull(a.Climate_type__c + '');
                c.ColdClosetFruitBox = checkNull(a.Cold_Closet_Fruit_Box__c + '');
                c.ColdClosetHumidityFunction = checkNull(a.Cold_Closet_Humidity_Function__c + '');
                c.ColdClosetShelf = checkNull(a.Cold_Closet_Shelf__c + '');
                c.ColdClosetStoragRack = checkNull(a.Cold_Closet_Storag_Rack__c + '');
                c.ColdClosetZeroDegreeRoom = checkNull(a.Cold_Closet_Zero_Degree_Room__c + '');
                c.ColdStorageVolume = checkNull(a.Cold_Storage_Volume__c + '');
                c.CompetitiveBrand = checkNull(a.Competitive_Brand__c + '');
                c.ControlMode = checkNull(a.Control_Mode__c + '');
                c.ControlType = checkNull(a.Control_Type__c + '');
                c.Controlboardheight = checkNull(a.Control_board_height__c + '');
                c.CoolingCapacity = checkNull(a.Cooling_Capacity__c + '');
                c.CoolingPower = checkNull(a.Cooling_Power__c + '');
                c.Country = checkNull(a.Country__c + '');
                c.CustomerType = checkNull(a.Customer_Type__c + '');
                c.DRTime = checkNull(a.DR_Time__c + '');
                c.DisplayMode = checkNull(a.Display_Mode__c + '');
                c.DoorDiameter = checkNull(a.Door_Diameter__c + '');
                c.DoorLockType = checkNull(a.Door_Lock_Type__c + '');
                c.DoorLock = checkNull(a.Door_Lock__c + '');
                c.DoorMaterial = checkNull(a.Door_Material__c + '');
                c.Doorlamp = checkNull(a.Door_lamp__c + '');
                c.DrainageMethod = checkNull(a.Drainage_Method__c + '');
                c.DryingCapacity = checkNull(a.Drying_Capacity__c + '');
                c.EnergyConsumption = checkNull(a.Energy_Consumption__c + '');
                c.EnergyEfficiencyRating = checkNull(a.Energy_Efficiency_Rating__c + '');
                c.EnergyEfficiencyRatio = checkNull(a.Energy_Efficiency_Ratio__c + '');
                c.EnergyefficiencyratingTV = checkNull(a.Energy_efficiency_rating_TV__c + '');
                c.Energyrequirements = checkNull(a.Energy_requirements__c + '');
                c.Environmentalinformation = checkNull(a.Environmental_information__c + '');
                c.EstimatedDRTime = checkNull(a.Estimated_DR_Time__c + '');
                c.ExpectedIRTime = checkNull(a.Expected_IR_Time__c + '');
                c.Exportmodel = checkNull(a.Export_model__c + '');
                c.Exportmodelnamefirst7digits = checkNull(a.Export_model_name_first_7_digits__c + '');
                c.FreezingChamberDrawer = checkNull(a.Freezing_Chamber_Drawer__c + '');
                c.FreezingChamberIceMaking = checkNull(a.Freezing_Chamber_Ice_Making__c + '');
                c.FreezingChamberShelf = checkNull(a.Freezing_Chamber_Shelf__c + '');
                c.FreezingChamberStorageRack = checkNull(a.Freezing_Chamber_Storage_Rack__c + '');
                c.FreezingDoorConfiguration = checkNull(a.Freezing_Door_Configuration__c + '');
                c.FreezingRoomConfiguration = checkNull(a.Freezing_Room_Configuration__c + '');
                c.Freezingability = checkNull(a.Freezing_ability__c + '');
                c.FrequencyconversionYN = checkNull(a.Frequency_conversion_Y_N__c + '');
                c.FrontShellColor = checkNull(a.Front_Shell_Color__c + '');
                c.FrozenVolume = checkNull(a.Frozen_Volume__c + '');
                c.GuidingPrice = checkNull(a.Guiding_Price__c + '');
                c.HDMI = checkNull(a.HDMI__c + '');
                c.HDR = checkNull(a.HDR__c + '');
                c.HandleAppearance = checkNull(a.Handle_Appearance__c + '');
                c.HandleForm = checkNull(a.Handle_Form__c + '');
                c.HandleType = checkNull(a.Handle_Type__c + '');
                c.HardwareBandGSM = checkNull(a.Hardware_Band_GSM__c + '');
                c.HardwareCPUplatform = checkNull(a.Hardware_CPU_platform__c + '');
                c.HardwareLCDTPresolution = checkNull(a.Hardware_LCD_TP_resolution__c + '');
                c.HardwareLCDTPsize = checkNull(a.Hardware_LCD_TP_size__c + '');
                c.HardwareMemoryRAMinGB = checkNull(a.Hardware_Memory_RAM_in_GB__c + '');
                c.HardwarebandCDMA = checkNull(a.Hardware_band_CDMA__c + '');
                c.HardwarebandLTE = checkNull(a.Hardware_band_LTE__c + '');
                c.HardwarebandWCDMA = checkNull(a.Hardware_band_WCDMA__c + '');
                c.HardwaremaincamerapixelinMP = checkNull(a.Hardware_main_camera_pixel_in_MP__c + '');
                c.HardwarememoryROMunitGB = checkNull(a.Hardware_memory_ROM_unit_GB__c + '');
                c.HardwaresubcamerapixelunitMP = checkNull(a.Hardware_sub_camera_pixel_unit_MP__c + '');
                c.HeatingCapacityUnit = checkNull(a.Heating_Capacity_Unit__c + '');
                c.HeatingCapacity = checkNull(a.Heating_Capacity__c + '');
                c.HeatingEfficiencyUnit = checkNull(a.Heating_Efficiency_Unit__c + '');
                c.HeatingEfficiency = checkNull(a.Heating_Efficiency__c + '');
                c.Heating = checkNull(a.Heating__c + '');
                c.HighColorGamut = checkNull(a.High_Color_Gamut__c + '');
                c.IDUPackageSize = checkNull(a.IDU_Package_Size__c + '');
                c.IDUSize = checkNull(a.IDU_Size__c + '');
                c.IRCompleteDate = checkNull(a.IR_Complete_Date__c + '');
                c.IRTime = checkNull(a.IR_Time__c + '');
                c.IndicatorFunction = checkNull(a.Indicator_Function__c + '');
                c.Indoorenclosure = checkNull(a.Indoor_enclosure__c + '');
                c.InnerContainerRequirements = checkNull(a.Inner_Container_Requirements__c + '');
                c.InnerDrumVolume = checkNull(a.Inner_Drum_Volume__c + '');
                c.InnerGlassDoor = checkNull(a.Inner_Glass_Door__c + '');
                c.IntelligentSystem = checkNull(a.Intelligent_System__c + '');
                c.InternalExternalCondenser = checkNull(a.Internal_External_Condenser__c + '');
                c.IsActive = checkNull(a.IsActive__c + '');
                c.IsInMyRegion = checkNull(a.IsInMyRegion__c + '');
                c.Keyproducts = checkNull(a.Key_products__c + '');
                c.KnockerColor = checkNull(a.Knocker_Color__c + '');
                c.KnockerType = checkNull(a.Knocker_Type__c + '');
                c.Level = checkNull(a.Level__c + '');
                c.Lightboxlight = checkNull(a.Light_box_light__c + '');
                c.LoadingCapacity = checkNull(a.Loading_Capacity__c + '');
                c.LoadingPickup = checkNull(a.Loading_Pickup__c + '');
                c.LoadingQuantity40HC20HC = checkNull(a.Loading_Quantity_40HC_20HC__c + '');
                c.LocalDimmingBackLightControl = checkNull(a.Local_Dimming_Back_Light_Control__c + '');
                c.MEMC = checkNull(a.MEMC__c + '');
                c.MainFunction = checkNull(a.Main_Function__c + '');
                c.MiddleHighLowEnd = checkNull(a.Middle_High_Low_End__c + '');
                c.Motortype = checkNull(a.Motor_type__c + '');
                c.MovementModel = checkNull(a.Movement_Model__c + '');
                c.Narrowborder = checkNull(a.Narrow_border__c + '');
                c.Netvolume = checkNull(a.Net_volume__c + '');
                c.Noise = checkNull(a.Noise__c + '');
                c.Nominalcertification = checkNull(a.Nominal_certification__c + '');
                c.Nominalenergyconsumption = checkNull(a.Nominal_energy_consumption__c + '');
                c.NumberofBasket = checkNull(a.Number_of_Basket__c + '');
                c.NumberofSpeakers = checkNull(a.Number_of_Speakers__c + '');
                c.ODUPackageSize = checkNull(a.ODU_Package_Size__c + '');
                c.ODUSize = checkNull(a.ODU_Size__c + '');
                c.OpenAngle = checkNull(a.Open_Angle__c + '');
                c.OperatingVoltage = checkNull(a.Operating_Voltage__c + '');
                c.Outdoorenclosure = checkNull(a.Outdoor_enclosure__c + '');
                c.Outdoorproductmodel = checkNull(a.Outdoor_product_model__c + '');
                c.Outdoorunitproductionmodel = checkNull(a.Outdoor_unit_production_model__c + '');
                c.POPFoldingImage = checkNull(a.POP_Folding_Image__c + '');
                c.PackagesizeWDHmm = checkNull(a.Package_size_W_D_H_mm__c + '');
                c.Packagingmaterialboxtype = checkNull(a.Packaging_material_box_type__c + '');
                c.PanelManufacturer = checkNull(a.Panel_Manufacturer__c + '');
                c.PanelModel = checkNull(a.Panel_Model__c + '');
                c.PanelPattern = checkNull(a.Panel_Pattern__c + '');
                c.PlaneSurface = checkNull(a.Plane_Surface__c + '');
                c.Powerconsumption = checkNull(a.Power_consumption__c + '');
                c.Powercordrequirements = checkNull(a.Power_cord_requirements__c + '');
                c.Pressmodel = checkNull(a.Press_model__c + '');
                c.Price1 = checkNull(a.Price_1__c + '');
                c.Price2 = checkNull(a.Price_2__c + '');
                c.ProductExternalId = checkNull(a.Product_External_Id__c + '');
                c.ProductImage = checkNull(a.Product_Image__c + '');
                c.ProductLine = checkNull(a.Product_Line__c + '');
                c.ProductManager = checkNull(a.Product_Manager__c + '');
                c.ProductModel = checkNull(a.Product_Model__c + '');
                c.ProductPositioning = checkNull(a.Product_Positioning__c + '');
                c.Product = checkNull(a.Product__c + '');
                c.Productcategorybottlingamount = checkNull(a.Product_category_bottling_amount__c + '');
                c.Productcategorytemperaturecontrolmo = checkNull(a.Product_category_temperature_control_mo__c + '');
                c.Productdimensionswidthdepthheig = checkNull(a.Product_dimensions_width_depth_heig__c + '');
                c.Productlevelcoolingmethod = checkNull(a.Product_level_cooling_method__c + '');
                c.Productlevelcoolingmethodproduct = checkNull(a.Product_level_cooling_method_product__c + '');
                c.Productleveldoor = checkNull(a.Product_level_door__c + '');
                c.Productleveldoornumberofdoors = checkNull(a.Product_level_door_number_of_doors__c + '');
                c.ProductlevelfrequencyconversionYN = checkNull(a.Product_level_frequency_conversion_Y_N__c + '');
                c.Productleveltemperaturecontrolmode = checkNull(a.Product_level_temperature_control_mode__c + '');
                c.Productlevelvolumesegment = checkNull(a.Product_level_volume_segment__c + '');
                c.Productlevelvolumesegmentvolume = checkNull(a.Product_level_volume_segment_volume__c + '');
                c.Productloading = checkNull(a.Product_loading__c + '');
                c.ProductnetsizeWDHmm = checkNull(a.Product_net_size_W_D_H_mm__c + '');
                c.Productionbase = checkNull(a.Production_base__c + '');
                c.ProjectType = checkNull(a.Project_Type__c + '');
                c.QuantityCalculate = checkNull(a.Quantity_Calculate__c + '');
                c.QuantumDotsQuantumDot = checkNull(a.Quantum_Dots_Quantum_Dot__c + '');
                c.RefreshrateHZratingTyperating = checkNull(a.Refresh_rate_HZ_rating_Type_rating__c + '');
                c.RefrigerantRefrigerant = checkNull(a.Refrigerant_Refrigerant__c + '');
                c.RefrigeratingCapacityUnit = checkNull(a.Refrigerating_Capacity_Unit__c + '');
                c.RefrigeratingCapacity = checkNull(a.Refrigerating_Capacity__c + '');
                c.RefrigeratingDoorConfiguration = checkNull(a.Refrigerating_Door_Configuration__c + '');
                c.RefrigeratingEfficiencyUnit = checkNull(a.Refrigerating_Efficiency_Unit__c + '');
                c.RefrigeratingEfficiency = checkNull(a.Refrigerating_Efficiency__c + '');
                c.RefrigeratingFluid = checkNull(a.Refrigerating_Fluid__c + '');
                c.RefrigeratingFruitBoxCover = checkNull(a.Refrigerating_Fruit_Box_Cover__c + '');
                c.RefrigeratingShelf = checkNull(a.Refrigerating_Shelf__c + '');
                c.RefrigeratorType = checkNull(a.Refrigerator_Type__c + '');
                c.Remotecontrolmodel = checkNull(a.Remote_control_model__c + '');
                c.Resource = checkNull(a.Resource__c + '');
                c.RetailPricePrice = checkNull(a.Retail_Price_Price__c + '');
                c.RotateSpeedRPM = checkNull(a.Rotate_Speed_RPM__c + '');
                c.SAPCreateTime = checkNull(a.SAPCreateTime__c + '');
                c.SAPCreate = checkNull(a.SAPCreate__c + '');
                c.SaleCurrency1 = checkNull(a.Sale_Currency_1__c + '');
                c.SaleCurrency2 = checkNull(a.Sale_Currency_2__c + '');
                c.SalesSeries = checkNull(a.Sales_Series__c + '');
                c.SalesUnit = checkNull(a.Sales_Unit__c + '');
                c.SalesVolume = checkNull(a.Sales_Volume__c + '');
                c.ScreePixelResolution = checkNull(a.ScreePixel_Resolution__c + '');
                c.Screenmodel = checkNull(a.Screen_model__c + '');
                c.SellingPoints = checkNull(a.Selling_Points__c + '');
                c.Series = checkNull(a.Series__c + '');
                c.ShopName = checkNull(a.Shop_Name__c + '');
                c.SizeJapan = checkNull(a.Size_Japan__c + '');
                c.Size = checkNull(a.Size__c + '');
                c.Softwareandroidversion = checkNull(a.Software_android_version__c + '');
                c.SoundTechnology = checkNull(a.Sound_Technology__c + '');
                c.Stage = checkNull(a.Stage__c + '');
                c.Store = checkNull(a.Store__c + '');
                c.TTM = checkNull(a.TTM__c + '');
                c.TVAppStore = checkNull(a.TV_App_Store__c + '');
                c.TVType1 = checkNull(a.TV_Type1__c + '');
                c.TVType2 = checkNull(a.TV_Type2__c + '');
                c.TVType3 = checkNull(a.TV_Type3__c + '');
                c.TVType4 = checkNull(a.TV_Type4__c + '');
                c.TargetBatchTime = checkNull(a.Target_Batch_Time__c + '');
                c.TargetEXW = checkNull(a.Target_EXW__c + '');
                c.TotalVolume = checkNull(a.Total_Volume__c + '');
                c.Type = checkNull(a.Type__c + '');
                c.USB = checkNull(a.USB__c + '');
                c.Usage = checkNull(a.Usage__c + '');
                c.VGA = checkNull(a.VGA__c + '');
                c.VendorBrand = checkNull(a.Vendor_Brand__c + '');
                c.Vendor = checkNull(a.Vendor__c + '');
                c.VideoAggregation = checkNull(a.Video_Aggregation__c + '');
                c.VoiceControl = checkNull(a.Voice_Control__c + '');
                c.VoltageFrequencyVoltageFrequency = checkNull(a.Voltage_Frequency_Voltage_Frequency__c + '');
                c.Voltagefrequency = checkNull(a.Voltage_frequency__c + '');
                c.WMType = checkNull(a.WM_Type__c + '');
                c.WarrantyYear = checkNull(a.Warranty_Year__c + '');
                c.Warranty = checkNull(a.Warranty__c + '');
                c.WashingCapacity = checkNull(a.Washing_Capacity__c + '');
                c.WaterConsumptionLevel = checkNull(a.Water_Consumption_Level__c + '');
                c.WaterConsumption = checkNull(a.Water_Consumption__c + '');
                c.WaterFeatures = checkNull(a.Water_Features__c + '');
                c.WaterInlet = checkNull(a.Water_Inlet__c + '');
                c.WiFImodulerequirements = checkNull(a.WiFI_module_requirements__c + '');
                c.X3DTypeActiveorPassive = checkNull(a.X3D_Type_Active_or_Passive__c + '');
                c.bottomspragTypeQuantity = checkNull(a.bottom_sprag_Type_Quantity__c + '');
                c.salesregion = checkNull(a.sales_region__c + '');
                c.High_End_Model_Asean = checkNull(a.High_End_Model_Asean__c + '');

                ProductInfoList.add(c);
            }
            result.ProductInfoList = ProductInfoList;
            String sql1 = 'select count(id) totalNumber from Product__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendProductToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendProductToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            return result; 
        }
    }

    public static String checkNull(String str){
        if(String.isBlank(str)){
            return '';
        }else if('null'.equals(str)){
            return '';
        }else{
            return str;
        }
    }
}