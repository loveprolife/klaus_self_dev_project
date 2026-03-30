/**********************************************************************
 * function:获取来自GSS系统的MobileProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: 
 * date:2019-03-07
*************************************************************************/
@RestResource(urlMapping='/getMobileProductFromGSS')
global with sharing class GetMobileProductFromGSS {

    global class AppInput{
        List<mobileProductInfo> ProductList;
    }
    global class AppOutput{
        String IsSuccess;
        String FailReason;
    }
    global class mobileProductInfo{
        String FactoryModel;
        String HighEnd;
        String ProjectType;
        String ProductManager;
        String BandGSM;
        String BandWCDMA;
        String BandCDMA;
        String BandLTE;
        String LCDTPSize;
        String LCDTPResolution;
        String CPUPlatform;
        String MemoryROM;
        String MemoryRAM;
        String MainPixel;
        String SubPixel;
        String PackagingBoxType;
        String AndroidVersion;
        String ProductionBase;
        String ExportModel;
    }

    @HttpPost
    global static GetMobileProductFromGSS.AppOutput doPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        // String reqBody = '{"ProductList": [{"FactoryModel": "1","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "A"},{"FactoryModel": "1","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "A"},{"FactoryModel": "1","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": "B"},{"FactoryModel": "1","HighEnd": "1","ProjectType": "1","ProductManager": "1","BandGSM": "1","BandWCDMA": "1","BandCDMA": "1","BandLTE": "1","LCDTPSize": "1","LCDTPResolution": "1","CPUPlatform": "1","MemoryROM": "1","MemoryRAM": "1","MainPixel": "1","SubPixel": "1","Packaging BoxType": "1","AndroidVersion": "1","ProductionBase": "1","ExportModel": ""}]}';
        System.debug('do post now , body :' + reqBody);

        GetMobileProductFromGSS.AppInput input = new GetMobileProductFromGSS.AppInput();
        GetMobileProductFromGSS.AppOutput result = new GetMobileProductFromGSS.AppOutput();

        try{
            input = (GetMobileProductFromGSS.AppInput)JSON.deserialize(reqBody, GetMobileProductFromGSS.AppInput.class);
            System.debug('input====>'+input);
            if (input.ProductList == null || input.ProductList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{

                List<Product__c> inserList = new List<Product__c>();
                List<Product__c> updateList = new List<Product__c>();//暂时没有找到考虑该因素的关键字段， 
                // Modified by Johnson 05/14
                // Map<String,GetMobileProductFromGSS.mobileProductInfo> reqMobMap = new Map<String,GetMobileProductFromGSS.mobileProductInfo>();
                // for (GetMobileProductFromGSS.mobileProductInfo reqMob: input.ProductList) {
                //     if (String.isBlank(reqMob.ExportModel)) {
                //         continue;
                //     }
                //     reqMobMap.put(reqMob.ExportModel, reqMob);
                // }

                for (GetMobileProductFromGSS.mobileProductInfo reqMob: input.ProductList) {
                    // GetMobileProductFromGSS.mobileProductInfo reqMob = reqMobMap.get(key);
                    Product__c mobile = new Product__c();
                    mobile.Product_Line__c = 'Mobile';
                    //设置记录类型
                    mobile.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Mobile Product RecordType').getRecordTypeId();
                    mobile.Name = reqMob.FactoryModel;
                    //mobile.Name = reqMob.ExportModel;
                    mobile.Middle_High_Low_End__c = String.isBlank(reqMob.HighEnd) ? null :reqMob.HighEnd; 
                    mobile.Project_Type__c = String.isBlank(reqMob.ProjectType) ? null :reqMob.ProjectType;
                    mobile.Product_Manager__c  = String.isBlank(reqMob.ProductManager) ? null :reqMob.ProductManager;
                    mobile.Hardware_Band_GSM__c = String.isBlank(reqMob.BandGSM) ? null :reqMob.BandGSM;
                    mobile.Hardware_band_WCDMA__c = String.isBlank(reqMob.BandWCDMA) ? null :reqMob.BandWCDMA;
                    mobile.Hardware_band_CDMA__c = String.isBlank(reqMob.BandCDMA) ? null :reqMob.BandCDMA;
                    mobile.Hardware_band_LTE__c = String.isBlank(reqMob.BandLTE) ? null :reqMob.BandLTE;
                    mobile.Hardware_LCD_TP_size__c = String.isBlank(reqMob.LCDTPSize) ? null :reqMob.LCDTPSize;
                    mobile.Hardware_LCD_TP_resolution__c = String.isBlank(reqMob.LCDTPResolution) ? null :reqMob.LCDTPResolution;
                    mobile.Hardware_CPU_platform__c = String.isBlank(reqMob.CPUPlatform) ? null :reqMob.CPUPlatform;
                    mobile.Hardware_memory_ROM_unit_GB__c = String.isBlank(reqMob.MemoryROM) ? null :reqMob.MemoryROM;
                    mobile.Hardware_Memory_RAM_in_GB__c = String.isBlank(reqMob.MemoryRAM) ? null :reqMob.MemoryRAM;
                    mobile.Hardware_main_camera_pixel_in_MP__c = String.isBlank(reqMob.MainPixel) ? null :reqMob.MainPixel;
                    mobile.Hardware_sub_camera_pixel_unit_MP__c = String.isBlank(reqMob.SubPixel) ? null :reqMob.SubPixel;
                    mobile.Packaging_material_box_type__c = String.isBlank(reqMob.PackagingBoxType) ? null :reqMob.PackagingBoxType;
                    mobile.Software_android_version__c = String.isBlank(reqMob.AndroidVersion) ? null :reqMob.AndroidVersion;
                    mobile.Production_base__c = String.isBlank(reqMob.ProductionBase) ? null :reqMob.ProductionBase;
                    mobile.Export_model__c = String.isBlank(reqMob.FactoryModel) ? null :reqMob.FactoryModel;
                    mobile.Product_External_Id__c = reqMob.FactoryModel;
                    inserList.add(mobile);
                }
                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
                System.debug('inserList:'+inserList);
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetMobileProductFromGSS';
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
            System.debug(e.getMessage()+e.getLineNumber());
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetMobileProductFromGSS';
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