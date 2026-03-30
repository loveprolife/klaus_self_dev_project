/**********************************************************************
* Name: GetResponsiblePersonFROMSAP 
* Object: Responsible_Person__c 
* Purpose: 获取门店巡店员
* Author: Gerry
* Create Date: 2020-02-17
*************************************************************************/
public with sharing class GetResponsiblePersonFROMSAP {
	
	public class Result {
		public String FAILREASON;
		public String ISSUCCESS;
		public List<ResponseData> itab;
	}
	public class ResponseData {
		public String KUNWE;
		public String ZPDBM;
		public String ZPDDD;
		public String ERDAT;
		public String ERNAM;
		public String ERZET;
	}	

	public class RequestData {
		public String BUKRS;
		public String ISDATE;
		public String IEDATE;
		public String KUNWE;
	}   

	@Future(callout =true)
	public static void getPersonInfo (String BUKRS, String ISDATE, String IEDATE) {
		String responseBody;
		String requestBody;
		try {
			RequestData requestData = new RequestData();
			requestData.KUNWE = '';
			requestData.BUKRS = BUKRS;
			requestData.ISDATE = ISDATE;
			requestData.IEDATE = IEDATE;	 

			requestBody = JSON.serialize(requestData);
			Blob headerValue = Blob.valueOf(Interface_Url__c.getValues('SAPResponsiblePerson').User_Name__c + ':' + Interface_Url__c.getValues('SAPResponsiblePerson').Password__c);
	        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	        HttpRequest request = new HttpRequest();
	        request.setEndpoint(Interface_Url__c.getValues('SAPResponsiblePerson').Basic_Url__c);
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
	        	Result result  =(Result)JSON.deserialize(responseBody,Result.class );
	        	if (result.ISSUCCESS == 'True') {
	        		List<Responsible_Person__c> personList = new List<Responsible_Person__c>();
	        		String dateString;
					String timeString;
	        		for (ResponseData re : result.itab) {
	        			Responsible_Person__c person = new Responsible_Person__c();
	        			person.SAPCreate__c = re.ERNAM;
	        			dateString = String.valueOf(re.ERDAT);
						timeString = String.valueOf(re.ERZET);
	        			person.SAPCreateTime__c = dateString.substring(0, 4)+'-'+dateString.substring(4, 6)+'-'+dateString.substring(6)+' '+timeString.substring(0, 2)+':'+timeString.substring(2, 4)+':'+timeString.substring(4);		
	        			person.SAPExternal__c = re.KUNWE + '-' + re.ZPDBM;
						person.SAPUserName__c = re.ZPDDD;
						person.RecordType__c = '巡店员';
						person.Shop_Id__c = re.KUNWE;
						person.Shop_Name__r = new Shop__c(External_Key_ID__c = re.KUNWE);
						personList.add(person);
					}		
					String bodyUserNotExist = '';
	        		if (personList.size()>0) {

						//忽略触发器更新
						GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'GetResponsiblePersonFROMSAP');

						List<Database.upsertResult> resultsOrder = Database.upsert(personList, Responsible_Person__c.Fields.SAPExternal__c, false);
						
						//恢复触发器
						Utility.IgnoreAction(false,false,false,'');

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
						SFUtility.writeCallLogs(String.valueOf(isSucceed), 'GetResponsiblePersonFROMSAP', requestBody, responseBody, 'Outbound', errorMessage);
	        		}
		            return ;
	        	}else{
					//插入日志
					SFUtility.writeCallLogs('false', 'GetResponsiblePersonFROMSAP', requestBody, responseBody, 'Outbound', '返回ISSUCCESS为false：' + responseBody);
		            return ;
	        	}	
	        }else{
				//插入日志
				SFUtility.writeCallLogs('false', 'GetResponsiblePersonFROMSAP', requestBody, responseBody, 'Outbound', '调用外部接口失败：' + responseBody);
	            return ;
	        }    
		}
		catch (Exception e) {
			String errorMsg = e.getMessage() + 'Line:  ' + e.getLineNumber();

            //插入日志
            SFUtility.writeCallLogs('false', 'GetResponsiblePersonFROMSAP', requestBody, responseBody, 'Outbound', errorMsg);
            return ;     
		}
	}  
}