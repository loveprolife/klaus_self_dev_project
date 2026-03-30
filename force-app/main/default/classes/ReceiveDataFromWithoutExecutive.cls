@RestResource(urlMapping='/approveExecutiveForHead')
global class ReceiveDataFromWithoutExecutive {
    @HttpPost
    global static void doPost() {
        InterfaceLog__c ic = new InterfaceLog__c();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bodyStrJson = req.requestBody.toString();
        System.debug('bodyStrJson===' + bodyStrJson);
        System.debug('bodyStrJson:' + JSON.deserializeUntyped(bodyStrJson));
        Map<String, Object> JSONText = (Map<String, Object>) JSON.deserializeUntyped(bodyStrJson);
        String fdTemplateId = String.valueOf(JSONText.get('fdTemplateId'));
        String fdId = String.valueOf(JSONText.get('fdId'));
        String docStatus = String.valueOf(JSONText.get('docStatus'));
        String opinion = String.valueOf(JSONText.get('opinion'));
        ResponseDataModel responseDataModel = new ResponseDataModel();
        try {
            System.debug('fdTemplateId:'+fdTemplateId);
            System.debug('fdId:'+fdId);
            System.debug('docStatus:'+docStatus);
            if (String.isNotBlank(fdId)) {
                List<Internal_Registration__c> insertList = new List<Internal_Registration__c>();
                List<Internal_Registration__c> intRegList = [SELECT Id 
                                                        FROM Internal_Registration__c 
                                                        WHERE Approval_FDID__c =: fdId];
                for (Internal_Registration__c intr : intRegList) {
                    Internal_Registration__c insertInt = new Internal_Registration__c();
                    if(docStatus == '30'){
                        insertInt.Id = intr.Id;
                        insertInt.Approval_Status__c = '审批通过';
                        insertInt.Approval_Opinion__c = opinion;
                        
                    }
                    if (docStatus == '11') {
                        insertInt.Id = intr.Id;
                        insertInt.Approval_Status__c = '审批驳回';
                        insertInt.Approval_Opinion__c = opinion;
                    }
                    insertList.add(insertInt);
                }
                if (insertList.size()>0) {
                    update insertList;
                }
                
            }
            
            
            responseDataModel.code = '200';
            responseDataModel.message = 'success';
            ic.ReturnCode__c = '200';
            ic.Res_Json__c = responseDataModel.message;
            ic.IsSuccess__c = true;
        } catch (Exception e) {
            responseDataModel.code = '500';
            responseDataModel.message = e.getMessage() + '[' + e.getLineNumber() + ']' ;
            System.debug('出现错误：' + responseDataModel.message);
            
            ic.ReturnCode__c = '500';
            ic.Res_Json__c = responseDataModel.message;
            ic.IsSuccess__c = false;
        }
        ic.Class__c = 'ReceiveDataFromWithoutExecutive';
        ic.Time__c = System.Now();
        ic.Req_Json__c = bodyStrJson;
        insert ic;
        res.responseBody = Blob.valueOf(JSON.serialize(responseDataModel));
        
    }

    public class OADetailInfo {
        public String docSubject;//展会Id
        public String fdTemplateId;//OA审批模板Id
        public String fdId;//fdId
        public String fdCreateTime;//时间
        public String origin;
        public String docStatus;//状态
        public String docCreator;//审批人
        public String fdKeyword;//
        public String docProperty;//
        public String fdNumber;//
        public String opinion;//
    }

    public class ResponseDataModel {
        public String code; //请求结果状态码
        public String message; //请求结果信息
    }
}