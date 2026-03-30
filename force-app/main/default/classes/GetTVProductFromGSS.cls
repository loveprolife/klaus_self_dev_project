/**********************************************************************
 * function:获取来自GSS系统的TVProduct信息
 * @author:annaliao
 * @url: /services/apexrest/rest
 * @data: TVProductInfo
 * date:2019-03-06
*************************************************************************/
@RestResource(urlMapping = '/getTVProductFromGSS')
global with sharing class GetTVProductFromGSS {

    global class AppInput{
        List<GetTVProductFromGSS.TVProductInfo> ProductList;
    }

    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }

    global class TVProductInfo{
        String FactoryModel;
        String HighEnd;
        String Size;
        String ScreenType;
        String PanelType;
        String MovementName;
        String BatchTargetTime;
        String EXWTarget;
        String EXWActual;
        String DRTime;
        String IRTime;
        String FrontCaseColor;
        String BackCoverColor;
        String PedestalColor;
        String PanelManufacturers;
        String CustomerModel;
        String MajorFunction;
        String EstimatedDRTime;
        String EstimatedIRTime;
        String SalesSeries;
        String TVType1;
        String TVType2;
        String TVType3;
        String TVType4;
        String PlaneSurface;
        String RefreshRate;
    }

    @HttpPost
    global static GetTVProductFromGSS.AppOutPut dopost(){
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring();
        System.debug('do post now ,reqBody:'+reqBody);

        AppInput input = new appInput();
        GetTVProductFromGSS.AppOutPut result = new GetTVProductFromGSS.AppOutPut();

        try{
            input = (GetTVProductFromGSS.AppInput)JSON.deserialize(reqBody,GetTVProductFromGSS.AppInput.class);
            System.debug('input===>:' + input);
            if (input.ProductList == null || input.ProductList.isEmpty()) {
                // System.debug('DeletedOrder_interface_error:' + msr.FailReason);
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
                // System.debug('DeletedOrder_interface_error:' + msr.FailReason);
                //正确数据
            }else{
                //是否涉及到update还是insert的问题？
                
                List<Product__c> inserList = new List<Product__c>();
                List<Product__c> updateList = new List<Product__c>();//暂时没有找到考虑该因素的关键字段， 
                // 过滤重复外键
                Map<String, Product__c> pMap = new Map<String, Product__c>();
                
                for (GetTVProductFromGSS.TVProductInfo reqTV : input.ProductList) {
                    //把服务器上的值依次放到实体上去
                    Product__c tv = new Product__c();
                    tv.Product_Line__c = 'TV';
                    tv.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV Product RecordType').getRecordTypeId();
                    tv.Name = reqTV.FactoryModel;   
                    tv.Middle_High_Low_End__c = String.isBlank(reqTV.HighEnd) ?null :reqTV.HighEnd;
                    tv.Size__c = String.isBlank(reqTV.Size) ?null:reqTV.Size;
                    tv.Screen_model__c = String.isBlank(reqTV.ScreenType) ?null:reqTV.ScreenType;
                    tv.Panel_Model__c = String.isBlank(reqTV.PanelType) ?null:reqTV.PanelType;
                    tv.Movement_Model__c = String.isBlank(reqTV.MovementName) ?null:reqTV.MovementName;
                    tv.Target_Batch_Time__c = String.isBlank(reqTV.BatchTargetTime) ?null:reqTV.BatchTargetTime;
                    tv.Target_EXW__c = String.isBlank(reqTV.EXWTarget) ?null:reqTV.EXWTarget;
                    tv.Actual_EXW__c = String.isBlank(reqTV.EXWActual) ?null:reqTV.EXWActual;
                    tv.DR_Time__c = String.isBlank(reqTV.DRTime) ?null:reqTV.DRTime;
                    tv.IR_Time__c = String.isBlank(reqTV.IRTime) ?null:reqTV.IRTime;
                    tv.Front_Shell_Color__c = String.isBlank(reqTV.FrontCaseColor) ?null:reqTV.FrontCaseColor;
                    tv.Back_Shell_Color__c = String.isBlank(reqTV.BackCoverColor) ?null:reqTV.BackCoverColor;
                    tv.Base_Color__c = String.isBlank(reqTV.PedestalColor) ?null:reqTV.PedestalColor;
                    tv.Panel_Manufacturer__c = String.isBlank(reqTV.PanelManufacturers) ?null:reqTV.PanelManufacturers;
                    tv.Customer_Type__c = String.isBlank(reqTV.CustomerModel) ?null:reqTV.CustomerModel;
                    tv.Main_Function__c = String.isBlank(reqTV.MajorFunction) ?null:reqTV.MajorFunction;
                    tv.Estimated_DR_Time__c = String.isBlank(reqTV.EstimatedDRTime) ?null:reqTV.EstimatedDRTime;
                    tv.Expected_IR_Time__c = String.isBlank(reqTV.EstimatedIRTime) ?null:reqTV.EstimatedIRTime;
                    tv.Sales_Series__c = reqTV.SalesSeries;
                    tv.TV_Type1__c = reqTV.TVType1;
                    tv.TV_Type2__c = reqTV.TVType2;
                    tv.TV_Type3__c = reqTV.TVType3;
                    tv.TV_Type4__c = reqTV.TVType4;
                    tv.Plane_Surface__c = reqTV.PlaneSurface;
                    tv.Refresh_rate_HZ_rating_Type_rating__c = reqTV.RefreshRate;
                    tv.Product_External_Id__c = reqTV.FactoryModel;

                    if(!pMap.containsKey(tv.Product_External_Id__c)){
                        inserList.add(tv);
                        pMap.put(tv.Product_External_Id__c, tv);
                    }
                    
                }

                Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetTVProductFromGSS';
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
            ic.Class__c = 'GetTVProductFromGSS';
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