/**********************************************************************
* Name: GetProductModelFROMSAP 
* Object: Product__c 
* Purpose: 获取产品
* Author: Gerry
* Create Date: 2020-02-17
*************************************************************************/
public with sharing class GetProductModelFROMSAP {
	public class RequestData{
		public String ZCUSMODEL;
		public String ISDATE;
		public String IEDATE;
	}  

	public class ResultData{
		public String FAILREASON;
		public String ISSUCCESS;
		public List<ResponseData> itab;	
	} 

	public class ResponseData {
		public String ZCUSMODEL;
		public String ZCPCC;
		public String ZCPDC;
		public String ZCPJD;
		public String ZCPXL;
		public String ZCPFL;
		public String MNGYN;
		public String ZXSYN;
		public String ERDAT;
		public String ERNAM;
		public String ERZET;	
	} 

	@Future(callout =true)
	public static void getProduct(String ISDATE, String IEDATE) {
		// Savepoint sp=Database.setSavepoint();
		String responseBody;
		String requestBody;
		try {
			RequestData requestData = new RequestData();
			requestData.ZCUSMODEL = '';
			requestData.ISDATE = ISDATE;
			requestData.IEDATE = IEDATE;	 

			requestBody = JSON.serialize(requestData);
			Blob headerValue = Blob.valueOf(Interface_Url__c.getValues('SAPProductModel').User_Name__c + ':' + Interface_Url__c.getValues('SAPProductModel').Password__c);
	        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	        HttpRequest request = new HttpRequest();
	        request.setEndpoint(Interface_Url__c.getValues('SAPProductModel').Basic_Url__c);
	        request.setMethod('POST');
	        request.setTimeout(120000);
	        request.setHeader('Content-Type', 'application/json');
	        request.setHeader('Authorization', authorizationHeader);
	        request.setBody(requestBody);
	        HttpResponse response = new HttpResponse();
	        Http http = new Http(); 
	        response = http.send(request);
	        responseBody = response.getBody();

	        System.debug('responseBody:' + responseBody);

	        if (response.getStatusCode()==200) {
	        	ResultData result  =(ResultData)JSON.deserialize(responseBody,ResultData.class);
                System.debug(LoggingLevel.INFO, '*** result: ' + result);
                if (result.FAILREASON.equals('No data')) {
                    //插入日志
                    SFUtility.writeCallLogs('false', 'GetProductModelFROMSAP', requestBody, responseBody, 'Outbound', 'No data');
                    return ;
                }

                List<Product__c> productList = new List<Product__c>();
                for (ResponseData re : result.itab) {
                    Product__c product = new Product__c();
                    product.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('ALL Product RecordType - Japan').getRecordTypeId();
                    product.Name = re.ZCUSMODEL;//客户型号
                    product.Product_External_Id__c = re.ZCUSMODEL + '-jp';//客户型号
                    product.Size_Japan__c = re.ZCPCC;//产品尺寸
                    product.Level__c = re.ZCPDC;//产品档次
                    product.Stage__c = re.ZCPJD;//产品阶段
                    product.Series__c = re.ZCPXL;//产品系列
                    product.Category__c = re.ZCPFL;//产品分类
                    product.Quantity_Calculate__c = re.MNGYN;//数量カウント(Y/N)
                    product.Sales_Unit__c = re.ZXSYN;//売り上げカウント(Y/N)
                    product.SAPCreate__c = re.ERNAM;//创建对象的人员名称 
                    String dateString = String.valueOf(re.ERDAT);//记录的创建日期 
                    String timeString = String.valueOf(re.ERZET);//输入时间
                    product.SAPCreateTime__c = dateString.substring(0, 4)+'-'+dateString.substring(4, 6)+'-'+dateString.substring(6)+' '+timeString.substring(0, 2)+':'+timeString.substring(2, 4)+':'+timeString.substring(4);		
                    productList.add(product);
                }
                if (!productList.isEmpty()) {
                    List<Database.upsertResult> resultsOrder = Database.upsert(productList,Product__c.Fields.Product_External_Id__c);
                    String errorMessage = '';
                    Boolean isSucceed = true;
                    for (Database.UpsertResult sr : resultsOrder) {
                        if (sr.isSuccess()) {

                        }else {
                            for(Database.Error err : sr.getErrors()) {
                                isSucceed = false;
                                errorMessage = errorMessage + err;
                                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }

                    //插入日志
                    SFUtility.writeCallLogs(String.valueOf(isSucceed), 'GetProductModelFROMSAP', requestBody, responseBody, 'Outbound', errorMessage);
                }
                return ;
	        }else{

                //插入日志
                SFUtility.writeCallLogs('false', 'GetProductModelFROMSAP', requestBody, responseBody, 'Outbound', '调用外部接口失败：' + responseBody);
	            return ;
	        }    
		}
		catch (Exception e) {
            String errorMsg = e.getMessage() + 'Line:  ' + e.getLineNumber();

            //插入日志
            SFUtility.writeCallLogs('false', 'GetProductModelFROMSAP', requestBody, responseBody, 'Outbound', errorMsg);
	        return ;
		}
	}
}