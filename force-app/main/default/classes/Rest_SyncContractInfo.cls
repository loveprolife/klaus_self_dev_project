/******************************************************************************
 ************************
 * Name: Rest_SyncContractInfo
 * Description: 同步合同信息
 * TestClassName:  Rest_SyncContractInfoTest
 * Version History: 0.01
 * Date: 2024-11-22
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@RestResource(urlMapping='/SyncContractInfo')
global with sharing class Rest_SyncContractInfo {  

    //接收参数
    global class InputInfo{
        List<ContractInfo> contractList;
    }
    global class ContractInfo{
        String contract_id;
        String contract_filing_id;
        String contract_filing_code;
        String contract_filing_name;
        String contract_filing_type;
        String customer_id;
        String customer_name;
        String contract_filing_start_date;
        String contract_filing_end_date;
        String create_by;
        String contract_filing_status;
        String sap_customer_code;

        String payment_term;

        List<AttachmentInfo> attachmentList;
    }

    public class AttachmentInfo{
        String attachmentName;
        String attachmentLink;
    }

    //返回参数
    global class OutPutInfo{
        public Boolean isSuccess;
        public String msg;
    }

    /**
     * @Param: 
     * @Return: OutPutInfo
     * @Author: lizunxing
     * @Date: 2024-11-22
     * @Description: 接收合同信息，根据Contract_filing_id__c进行upsert操作
     */
    @HttpPost
    global static OutPutInfo doPost() {

        //接收参数
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 

        //返回参数
        OutPutInfo result = new OutPutInfo();
        
        try {
            InputInfo inputInfo = (InputInfo)JSON.deserialize(reqBody, InputInfo.class);

            if(inputInfo != null && inputInfo.contractList != null && inputInfo.contractList.size() > 0){

                Set<String> sapCodes = new Set<String>();
                for(ContractInfo ci : inputInfo.contractList){
                    sapCodes.add(ci.sap_customer_code);
                }
                
                List<Account> accountList = [Select id, SAP_Customer_Code__c from Account where SAP_Customer_Code__c in:sapCodes];
                Map<String, String> accountIdMap = new Map<String, String>();
                for(Account account : accountList){
                    accountIdMap.put(account.SAP_Customer_Code__c, account.Id);
                }

                Map<String, List<AttachmentInfo>> attMap = new Map<String, List<AttachmentInfo>>();

                //更新集合
                List<Contract__c> upsertContractList = new List<Contract__c>();
                
                for(ContractInfo ci : inputInfo.contractList){
                    Contract__c con = new Contract__c();
                    con.Name = ci.contract_filing_code;
                    con.contract_filing_id__c = ci.contract_filing_id;
                    con.contract_filing_name__c = ci.contract_filing_name;
                    con.contract_filing_type__c = ci.contract_filing_type;
                    con.customer_id__c = ci.customer_id;
                    con.customer_name__c = ci.customer_name;
                    if(String.isNotBlank(ci.contract_filing_start_date)){
                        con.contract_filing_start_date__c = Date.valueOf(ci.contract_filing_start_date);
                    }
                    if(String.isNotBlank(ci.contract_filing_end_date)){
                        con.contract_filing_end_date__c =  Date.valueOf(ci.contract_filing_end_date);
                    }
                    
                    con.create_by__c = ci.create_by;
                    con.contract_filing_status__c = ci.contract_filing_status;
                    con.sap_customer_code__c = ci.sap_customer_code;
                    con.payment_term__c = ci.payment_term;

                    con.Customer__c = accountIdMap.get(ci.sap_customer_code);

                    upsertContractList.add(con);
                    attMap.put(con.Name, ci.attachmentList);
                }

                
                if(upsertContractList.size() > 0){
                    //更新插入
                    Database.upsert(upsertContractList,Contract__c.Fields.Contract_filing_id__c,false);
                }
            
                //删除附件，重新插入
                // List<String> contractIds = new List<String>();
                // for(Contract__c c : upsertContractList){
                //     contractIds.add(c.id);
                // }
                // List<Contract_Attachment__c> caList = [select id from Contract_Attachment__c where Contract__c in : contractIds];
                // Database.delete(caList);
                
                // List<Contract_Attachment__c> addList = new List<Contract_Attachment__c>();
                // for(Contract__c c : upsertContractList){
                //     List<AttachmentInfo> atts = attMap.get(c.Name);
                //     if(atts != null && atts.size() > 0){
                //         for(AttachmentInfo att : atts){
                //             Contract_Attachment__c ca = new Contract_Attachment__c();
                //             ca.Contract__c = c.Id;
                //             ca.Attachment_Name__c = '<a href='+att.attachmentLink+' targer=\'_blank\'>'+att.attachmentName+'</a>';
                //             ca.Name = att.attachmentName;
                //             ca.Link__c = att.attachmentLink;
                //             addList.add(ca);
                //         }
                //     }
                    
                // }

                // if(addList.size() > 0){
                //     Database.insert(addList);
                // }
            }

            result.isSuccess = true;
            result.msg = 'Success';

            //插入Log
            Utility.insertLog('Rest_SyncContractInfo', '1', reqBody, '');
        } catch(Exception e) {

            result.isSuccess = false;
            result.msg = e.getMessage();

            //插入Log
            Utility.insertLog('Rest_SyncContractInfo', '0', reqBody, 'failure: SF Rest_SyncContractInfo Failed! ' + e.getMessage() + '-------' + reqBody);
        }

        return result;
    }
    
}