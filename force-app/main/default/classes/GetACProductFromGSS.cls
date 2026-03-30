/**********************************************************************
 * function:获取来自GSS系统的ACProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: ACProductInfo
 * date:2019-03-07
*************************************************************************/
@RestResource(urlMapping='/getACProductFromGSS')
global with sharing class GetACProductFromGSS {

    global class AppInput{
        List<ACProductInfo> ProductList;
    }
    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }
    global class ACProductInfo{
         public String FactoryModel;  
         public String HighEnd;
         public String OutdoorProductModel;
         public String IndoorEnclosure;
         public String RemoteControlModel;
         public String OutdoorProductionModel;
         public String PressModel;
         public String WiFIModuleRequirements;
         public String OutdoorEnclosure;
         public String IDUSize;
         public String ODUSize;
         public String IDUPackageSize;
         public String ODUPackageSize;
    }   
      
    @HttpPost
    global static GetACProductFromGSS.AppOutPut adoPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"ProductList": [{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "B","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"}],"access_token": "Bearer SESSION_ID_REMOVED"}';
        system.debug('doPost now, body : ' + reqBody);

        AppInput input = new AppInput();
        GetACProductFromGSS.AppOutPut result = new GetACProductFromGSS.AppOutPut();
        try{
            input = (GetACProductFromGSS.AppInput) JSON.deserialize(reqBody, GetACProductFromGSS.AppInput.class);
            System.debug('input===>:' + input);
            //空数据
            if (input.ProductList == null || input.ProductList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{
                List<Product__c> inserList = new List<Product__c>();
                List<Product__c> updateList = new List<Product__c>();
                List<GetACProductFromGSS.ACProductInfo> newProductList = new List<GetACProductFromGSS.ACProductInfo>();
                
                //工厂型号与产品对象的map
                Map<String,GetACProductFromGSS.ACProductInfo> factoryModel2ProductMap = new Map<String,GetACProductFromGSS.ACProductInfo>();
                for (GetACProductFromGSS.ACProductInfo reqAC : input.ProductList) {
                    factoryModel2ProductMap.put(reqAC.FactoryModel,reqAC);
                }

                System.debug('factoryModel2ProductMap... '+factoryModel2ProductMap);
                for(String keyValue : factoryModel2ProductMap.keySet()){
                    newProductList.add(factoryModel2ProductMap.get(keyValue));
                }
                System.debug('newProductList,,, '+newProductList);
                System.debug('input.ProductListlll '+input.ProductList);
                input.ProductList.clear();
                System.debug('input.ProductList222 '+input.ProductList);
                for(GetACProductFromGSS.ACProductInfo newProduct :newProductList){
                    input.ProductList.add(newProduct);
                }

                //同步的产品
                System.debug('input.ProductList... '+input.ProductList);
                for (GetACProductFromGSS.ACProductInfo reqAC : input.ProductList) {
                    Product__c ac = new Product__c();
                    ac.Product_Line__c = 'AC';
                    ac.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('AC Product RecordType').getRecordTypeId();
                    ac.Name = reqAC.FactoryModel;   
                    ac.Middle_High_Low_End__c = reqAC.HighEnd == null ? '' :reqAC.HighEnd;
                    ac.Outdoor_product_model__c = reqAC.OutdoorProductModel == null ? '' :reqAC.OutdoorProductModel;
                    ac.Indoor_enclosure__c = reqAC.IndoorEnclosure == null ? '':reqAC.IndoorEnclosure;
                    ac.Remote_control_model__c = reqAC.RemoteControlModel == null ? '' :reqAC.RemoteControlModel;
                    ac.Outdoor_unit_production_model__c = reqAC.OutdoorProductionModel == null ? '' :reqAC.OutdoorProductionModel;
                    ac.Press_model__c = reqAC.PressModel == null ? null:reqAC.PressModel;
                    ac.WiFI_module_requirements__c = reqAC.WiFIModuleRequirements == null ? '' :reqAC.WiFIModuleRequirements;        
                    ac.Outdoor_enclosure__c = reqAC.OutdoorEnclosure == null ? '' :reqAC.OutdoorEnclosure;
                    ac.IDU_Size__c = reqAC.IDUSize;
                    ac.ODU_Size__c = reqAC.ODUSize;
                    ac.IDU_Package_Size__c = reqAC.IDUPackageSize;
                    ac.ODU_Package_Size__c = reqAC.ODUPackageSize;
                    ac.Product_External_Id__c = reqAC.FactoryModel;
                    inserList.add(ac);
                }

                System.debug(inserList.size());
                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);

                System.debug('同步成功！');
              
                //日志内容
                // InterfaceLog__c ic = new InterfaceLog__c();
                // ic.Class__c = 'GetACProductFromGSS';
                // ic.Time__c = System.Now();
                // ic.ReturnCode__c = '1';
                // ic.Req_Json__c = reqBody;
                // ic.ErrorMsg__c = '';
                // insert ic;

                result.IsSuccess = 'true';
                result.FailReason = '';
                System.debug(result);
                return result;

            }
        //错误数据   
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetACProductFromGSS';
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