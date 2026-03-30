@RestResource(urlMapping='/receiveDataFromWithout')
global class ReceiveDataFromWithout {
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

        // System.debug('option' + opinion);
        String approvalState;
        if(opinion.contains('auditNote')) {

            List<AuditRecord> records = new List<AuditRecord>();
        
            // 去掉首尾的括号
            if(opinion.contains('(')) {
                opinion = opinion.substring(1, opinion.length() - 1);
            }
            
            List<String> recordStrings = opinion.split('\\}, \\{');
            System.debug('optionX' + recordStrings);
            for (String recordString : recordStrings) {
                Map<String, String> fields = new Map<String, String>();
                // 去掉记录的首尾括号
                recordString = recordString.startsWith('{') ? recordString.substring(1) : recordString;
                recordString = recordString.endsWith('}') ? recordString.substring(0, recordString.length() - 1) : recordString;
    
                // 按照逗号分隔字段
                List<String> fieldStrings = recordString.split(', ');
                for (String fieldString : fieldStrings) {
                    // 按照等号分隔键和值
                    List<String> keyValue = fieldString.split('=');
                    fields.put(keyValue[0].trim(), keyValue[1].trim());
                }
    
                // 创建 AuditRecord 对象
                AuditRecord record = new AuditRecord();
                record.auditNote = fields.get('auditNote');
                record.auditTime = fields.get('auditTime');
                record.fdActionKey = fields.get('fdActionKey');
                record.fdFactNodeId = fields.get('fdFactNodeId');
                record.fdFactNodeName = fields.get('fdFactNodeName');
                record.fdLoginName = fields.get('fdLoginName');
                record.fdName = fields.get('fdName');
    
                records.add(record);
            }
            System.debug('WWW' + records.size()); 
    
            Boolean departmentAgreed = false;
            Boolean regionAgreed = false;
            if(records.size() == 2) {
                if(records[0].fdFactNodeName.contains('部门') && records[0].auditNote == '同意') {departmentAgreed = true;}
                if(records[1].fdFactNodeName.contains('部门') && records[1].auditNote == '同意') {departmentAgreed = true;}
                if(records[0].fdFactNodeName.contains('大区') && records[0].auditNote == '同意') {regionAgreed = true;}
                if(records[1].fdFactNodeName.contains('大区') && records[1].auditNote == '同意') {regionAgreed = true;}
                if(departmentAgreed && regionAgreed) {
                    approvalState = '分管领导/大区总通过';
                } else if(!regionAgreed && departmentAgreed){
                    approvalState = '分管领导/大区总驳回';
                } else if (!regionAgreed) {
                    approvalState = '部门审批驳回';
                }
            } else
            if(records.size() == 1) {
                //两道节点审批
                if(records[0].fdFactNodeName.contains('部门') && docStatus == '30') {approvalState = '部门审批通过';}
                if(records[0].fdFactNodeName.contains('大区') && docStatus == '30') {approvalState = '分管领导/大区总通过';}
                if(records[0].fdFactNodeName.contains('部门') && docStatus == '11') {approvalState = '部门审批驳回';}
                if(records[0].fdFactNodeName.contains('大区') && docStatus == '11') {approvalState = '分管领导/大区总驳回';}
                System.debug('单独的审批状态' + approvalState);
            }
            
        }

        
        
        

        // List<Map<String, Object>> auditList = (List<Map<String, Object>>) JSON.deserializeUntyped(opinion);

        // // 初始化结果变量
        // Boolean departmentAgreed = false;
        // Boolean regionAgreed = false;

        // // 遍历解析后的数据
        // for (Map<String, Object> audit : auditList) {
        //     // 获取 fdFactNodeName 和 auditNote 字段
        //     String nodeName = (String) audit.get('fdFactNodeName');
        //     String auditNote = (String) audit.get('auditNote');
        
        //     // 根据关键字判断
        //     if (nodeName.contains('部门') && auditNote == '同意') {
        //         departmentAgreed = true;
        //     } else if (nodeName.contains('大区') && auditNote == '同意') {
        //         regionAgreed = true;
        //     }
        // }

        // // 输出结果
        // System.debug('部门负责人是否同意：' + departmentAgreed); // 部门负责人是否同意：true
        // System.debug('大区经理是否同意：' + regionAgreed);

        ResponseDataModel responseDataModel = new ResponseDataModel();
        try {
            System.debug('fdTemplateId:'+fdTemplateId);
            System.debug('fdId:'+fdId);
            System.debug('docStatus:'+docStatus);
            if (String.isNotBlank(fdId)) {
                List<Internal_Registration__c> insertList = new List<Internal_Registration__c>();
                List<Internal_Registration__c> intRegList = [SELECT Id, Approval_Cycle__c
                                                        FROM Internal_Registration__c 
                                                        WHERE Approval_FDID__c =: fdId];
                for (Internal_Registration__c intr : intRegList) {
                    Internal_Registration__c insertInt = new Internal_Registration__c();
                    if(docStatus == '30'){
                        insertInt.Id = intr.Id;
                        insertInt.Approval_Status__c = String.isEmpty(approvalState) ? '部门审批通过' : approvalState;
                        // insertInt.Approval_Cycle__c = intr.Approval_Cycle__c + 1;
                        insertInt.Approval_Opinion__c = opinion;
                        
                    }
                    if (docStatus == '11') {
                        insertInt.Id = intr.Id;
                        // insertInt.Approval_Status__c = '部门审批驳回';
                        insertInt.Approval_Status__c = String.isEmpty(approvalState) ? '部门审批驳回' : approvalState;

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
        ic.Class__c = 'ReceiveDataFromWithout';
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

    public class AuditRecord {
        public String auditNote;
        public String auditTime;
        public String fdActionKey;
        public String fdFactNodeId;
        public String fdFactNodeName;
        public String fdLoginName;
        public String fdName;
    }
    
}