/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global without sharing class GSSPostProductModelService {
    global static GetProductMappingFromGSS.AppOutPut doPost(String acceptJSON) {

        System.debug(LoggingLevel.INFO, '***acceptJSON : ' +acceptJSON );

        GetProductMappingFromGSS.AppOutPut result = new GetProductMappingFromGSS.AppOutPut();
        result.IsSuccess = 'true';
        result.FailReason = '';
        try {
            RestRequest req = RestContext.request;
            GetProductMappingFromGSS.AppInput acceptObject = (GetProductMappingFromGSS.AppInput)JSON.deserialize(acceptJSON, GetProductMappingFromGSS.AppInput.class);

            // 处理本次调用
            List<Product__c> proList = new List<Product__c>();
            for (GetProductMappingFromGSS.ProMapInfo proSObj : acceptObject.ProductMappingList) {
                Product__c pro = new Product__c();
                pro.Name = proSObj.CustomerModel;
                pro.Product_Line__c = proSObj.ProductLine;
                pro.Product_External_Id__c = proSObj.CustomerModel + '-jp';
                pro.RecordTypeId = CommonConstant.productJapanModelReocrdTypeId;
                proList.add(pro);
            }

            if (!proList.isEmpty()) {
                Database.upsert(proList, Product__c.Product_External_Id__c, true);
            }
        } catch (Exception ex) {
            result.IsSuccess = 'False';
            result.FailReason = ex.getMessage() + '\n\r' + ex.getStackTraceString();
        }

        //写入接口日志
        SFUtility.writeCallLogs(result.IsSuccess, 'GetProductMappingFromGSS', acceptJSON, JSON.serializePretty(result), 'Inbound', result.FailReason);

        return result;
    }
}