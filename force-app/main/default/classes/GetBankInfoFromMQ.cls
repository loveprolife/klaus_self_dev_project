/**********************************************************************
 * Name: GetBankInfoFromMQ
 * Object: Account 
 * Purpose: Receive the bank infrormation from MQ
 * Author: lzx
 * Create Date: 2024-01-178
*************************************************************************/
@RestResource(urlMapping='/getBankInfoFromMQ')
global without sharing class GetBankInfoFromMQ {

    global class MessageWrapper {
        public AppOutput MSG;
        public String MSG_ID;
    }

    global class AppOutput{
        InterfaceBody IV_OUTPUT;
    }

    global class InterfaceBody {
        public String SENDER;
        public String INSTID;
        public String REQUESTTIME;
        public List<BankDetail> DATA;
    }

    //银行信息
    global class BankDetail{
        public string BANKS;
        public String ZYHDM;
        public String ZYHBB;
        public String BANKL;
        public String SPRAS;
        public string BANKA;
        public String ZLYXT;
        public string ZLYBM;
        public String SWIFT;
        public string PROVZ;
        public String ORT01;
        public string ZCSBM;
        public String STRAS;
        public string ZYZBM;
        public string SORT1;
        public string ZYHFH;
        public string ZQSBM;
        public string ZTJJG;
        public string LOEVM;
        public string ZQCSJ;
        public string ZYHLB;
        public string CRDAT;
        public string CRTIM;
        public string CRNAM;
        public string AEDAT;
        public string AETIM;
        public string AENAM;
        //public List<INVERInfo> INVER;
        //public List<VENDORInfo> VENDOR;
    }

    global class INVERInfo{
        public string NATION;
        public string BANKA;
        public string ORT01;
        public string STRAS;
    }

    global class VENDORInfo{
        public string ZLYXT;
        public string PARTNER;
    }

    @HttpPost
    global static List<MessageWrapper> mqPost() {
        String result;
        //Req
        RestRequest req = RestContext.request;
        //Res
        RestResponse res = RestContext.response;
                
        //直接处理Blob数据而不是转换为String
        Blob requestBlob = req.requestBody;
        
        String jsonStr = requestBlob.toString();

        List<MessageWrapper> messages = null;
        try{
            jsonStr = jsonStr.replace('\\\\', '\\').replace('\\"', '"').replace('\\"', '"');
            
            jsonStr = jsonStr.replace('MSG":"', 'MSG":');
            jsonStr = jsonStr.replace('","MSG_ID', ',"MSG_ID');
            Utility.insertLogAsyn('GetBankInfoFromMQ', '2', jsonStr, '');
            System.debug('Request JSON: ' + jsonStr);
        
            messages = (List<MessageWrapper>) JSON.deserialize(jsonStr, List<MessageWrapper>.class);
            List<MDG_Bank__c> finalUpdate = new List<MDG_Bank__c>();
       
            System.debug('***messages=' + messages);

            for(MessageWrapper msw : messages){

                if(msw == null || msw.MSG.IV_OUTPUT == null){
                    return messages;
                }

                if(msw.MSG.IV_OUTPUT.DATA != null && msw.MSG.IV_OUTPUT.DATA.size() > 0){
                    for( BankDetail bd  : msw.MSG.IV_OUTPUT.DATA){
                        if(String.isNotBlank(bd.ZYHDM) && String.isNotBlank(bd.ZYHBB)){
                            MDG_Bank__c acc = new MDG_Bank__c();
                            acc.BANKS__c = bd.BANKS;
                            acc.ZYHDM__c = bd.ZYHDM;
                            acc.ZYHBB__c = bd.ZYHBB;
                            acc.BANKL__c = bd.BANKL;
                            acc.SPRAS__c = bd.SPRAS;
                            acc.BANKA__c = bd.BANKA;
                            acc.ZLYXT__c = bd.ZLYXT;
                            acc.ZLYBM__c = bd.ZLYBM;
                            acc.SWIFT__c = bd.SWIFT;
                            acc.PROVZ__c = bd.PROVZ;
                            acc.ORT01__c = bd.ORT01;
                            acc.ZCSBM__c = bd.ZCSBM;
                            acc.STRAS__c = bd.STRAS;
                            acc.ZYZBM__c = bd.ZYZBM;
                            acc.SORT1__c = bd.SORT1;
                            acc.ZYHFH__c = bd.ZYHFH;
                            acc.ZQSBM__c = bd.ZQSBM;
                            acc.ZTJJG__c = bd.ZTJJG;
                            acc.LOEVM__c = bd.LOEVM;
                            acc.ZQCSJ__c = bd.ZQCSJ;
                            acc.ZYHLB__c = bd.ZYHLB;
                            acc.CRDAT__c = bd.CRDAT;
                            acc.CRTIM__c = bd.CRTIM;
                            acc.CRNAM__c = bd.CRNAM;
                            acc.AEDAT__c = bd.AEDAT;
                            acc.AETIM__c = bd.AETIM;
                            acc.AENAM__c = bd.AENAM;
                            acc.Name = bd.ZQSBM;
                            acc.External_key__c = bd.ZYHDM + bd.ZYHBB;
                            System.debug('acc='+acc);
                            finalUpdate.add(acc);   
                            
                        } 
                    }
                }
            }

        
            System.debug('finalUpdate='+finalUpdate);
            // 执行更新操作
            if(finalUpdate.size() > 0){
                //Database.upsert(finalUpdate);
                Database.upsert(finalUpdate,MDG_Bank__c.Fields.External_key__c,false);
            }

        }catch(Exception e) {
            Utility.insertLogAsyn('GetBankInfoFromMQ', '0', jsonStr, 'failure: SF Sync Bank Information from MDG Failed! ' + e.getMessage() );
        }
        
        return messages;

    }

    /**
	* 将String类型转换成Date
	* @param 要转换的String
	* @return 转换后的Date
	*/
    public static Date convertStringToDate(String dateString) {
        Date reDate;
        //位数check
        if (dateString.length() == 8 && !dateString.startsWith('0') && !dateString.startsWith('9')) {
            
        //年
        String year = dateString.substring(0, 4);
        //月
        String month = dateString.substring(4, 6);
        //日
        String day = dateString.substring(6, 8);
        //String to YYYY-MM-DD
        String formattedDate = year + '-' + month + '-' + day;
        //String to Date
        reDate = Date.valueOf(formattedDate);
        }
        return reDate;
    }

    

    // public static Map<String,MDG_Bank__c> updateBankMap(List<String> banklList) {
    //     // 查询符合条件的 Account 记录
    //     List<MDG_Bank__c> banskToUpdate = [SELECT Id, Name, External_key__c FROM MDG_Bank__c WHERE External_key__c in :banklList];
    //     Map<String,MDG_Bank__c> bankMap = new Map<String,MDG_Bank__c>();
    //     //Account ac;
    //     if(banskToUpdate != null && banskToUpdate.size()>0){
    //         for(MDG_Bank__c upBank : banskToUpdate){
    //             bankMap.put(upBank.External_key__c, upBank);
    //         }
    //     }
    //     return bankMap;      
    // }

    // public static Map<String,MDG_BANK_INVER__c> updateBankInverMap(List<String> banklList) {
    //     // 查询符合条件的 Account 记录
    //     List<MDG_BANK_INVER__c> banskToUpdate = [SELECT Id, Name, External_key__c FROM MDG_BANK_INVER__c WHERE External_key__c in :banklList];
    //     Map<String,MDG_BANK_INVER__c> bankMap = new Map<String,MDG_BANK_INVER__c>();
    //     //Account ac;
    //     if(banskToUpdate != null && banskToUpdate.size()>0){
    //         for(MDG_BANK_INVER__c upBank : banskToUpdate){
    //             bankMap.put(upBank.External_key__c, upBank);
    //         }
    //     }
    //     return bankMap;      
    // }

    // public static Map<String,MDG_Bank_VENDOR__c> updateBankVendorMap(List<String> banklList) {
    //     // 查询符合条件的 Account 记录
    //     List<MDG_Bank_VENDOR__c> banskToUpdate = [SELECT Id, Name, External_key__c FROM MDG_Bank_VENDOR__c WHERE External_key__c in :banklList];
    //     Map<String,MDG_Bank_VENDOR__c> bankMap = new Map<String,MDG_Bank_VENDOR__c>();
    //     //Account ac;
    //     if(banskToUpdate != null && banskToUpdate.size()>0){
    //         for(MDG_Bank_VENDOR__c upBank : banskToUpdate){
    //             bankMap.put(upBank.External_key__c, upBank);
    //         }
    //     }
    //     return bankMap;      
    // }
    
}