/**********************************************************************
* Name: GetProductStockInfoFromSAP 
* 从SAP中取库存数据

Salesforce Output
1   ProductCustomerModel    产品的客户型号
2   CompanyCode 公司代码
        
Salesforce Input        
1   FailReason  失败原因
2   IsSuccess   是否成功
3   TotalStock  在库库存
4   AvailableStock  可用库存

*************************************************************************/
public with sharing class GetProductStockInfoFromSAP {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_PRODUCTSTOCKINFO_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    //private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_PRODUCTSTOCKINFO_SEND';
    //private static String user = 'xiaxiaoyang';
    //private static String password = 'hs123456';

    public class ProductStockInfoOutput{
        public String ProductCustomerModel;//产品的客户型号
        public String CompanyCode;//公司代码
        public List<String> StorageLocationList;//库存位置
    }

    public class ProductStockInfoInput{
        public String SalesOrganization;//销售组织
        public String CustomerModel;//客户型号
        public String failReason;//失败原因
        public String isSuccess;//是否成功                          
        public List<ProductStockLine> ProductStock;//库存List，分库位                          
    }
    public class ProductStockLine{
        public String StorageLocation;//库位
        public String StockinWhse;//系统库位库存
        public String ActualSOQty;//实际订单占用
        public String EDIVOQty;//EDI订单+VO订单占用
        public String DNQty;//交货单占用
        public String AvailableQtyExEDIVO;//可用库存（不含B/O) 
        public String AvailableQtyIncEDIVO;//可用库存（包含B/O)
    }


    public static GetProductStockInfoFromSAP.ProductStockInfoInput getData(String productCustomerModel,String companyCode,List<String> storageLocationList){
    //public static GetProductStockInfoFromSAP.ProductStockInfoInput GetRevenueCostInfoFromSAP(){
        GetProductStockInfoFromSAP.ProductStockInfoInput result = new GetProductStockInfoFromSAP.ProductStockInfoInput();//创建返回对象
       
        
        ProductStockInfoOutput out = new ProductStockInfoOutput();
        out.ProductCustomerModel = productCustomerModel;
        out.CompanyCode = companyCode;
        out.StorageLocationList = storageLocationList;

        //out.ProductCustomerModel = '432H';
        //out.CompanyCode= '8001';
        
        String body = JSON.serialize(out);
        sYSTEM.debug('body：：： '+body);
        String bodyRes;
        GetProductStockInfoFromSAP.ProductStockInfoInput input = new GetProductStockInfoFromSAP.ProductStockInfoInput();        
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //登陆获取token
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();              
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            response = http_login.send(request);
            String bodyRes_login = response.getBody();
            System.debug('bodyRes:' + bodyRes_login);
            input =(GetProductStockInfoFromSAP.ProductStockInfoInput)JSON.deserialize(bodyRes_login,GetProductStockInfoFromSAP.ProductStockInfoInput.class );
            System.debug('~~~~~~~~~~~~~~' + input);              
            
            if (input.isSuccess == 'False') {
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetProductStockInfoFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = input.failReason;
                insert ic;
            }else {
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetProductStockInfoFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = input.failReason;
                insert ic;
            }
            return input;
        }
        catch (Exception e) {
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetProductStockInfoFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = 'sfdc调用库存收入信息接口失败'+e.getMessage()  + ' Line Number:' + e.getLineNumber();
            insert ic;
            input.isSuccess = 'False';
            input.failReason = 'Interface Error, Error Reason: ' + e.getMessage();
            return input;
        }
    }   
}