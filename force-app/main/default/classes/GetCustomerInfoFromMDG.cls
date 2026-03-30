/**********************************************************************
* Name: GetCustomerInfoFromMDG
* Object: Account 
* Purpose: Query Customer Information from MDG when create a new Customer
* Author: Chen Fen
* Create Date: 2024-10-31
*************************************************************************/
public without sharing class GetCustomerInfoFromMDG {

    //接口主信息
    public class InterfaceInfo {

        public String INSTID;
        public String SYNSTATUS;
        public String SYNRESULT;
        public String LINECOUNT;
        public String CODE;
        public List<DATA> DATA;

    }

    //客户主数据
    public class DATA {        
        public CustomerInfo DATA;
        
    }
    
    public class CustomerInfo {
        public String PARTNER;
        public String BU_GROUP;
        public String ZZMXLX;
        public String AUFSD;
        public String NAME_LO;
        public String NAME_EN;
        public String BU_SORT1;
        public String ZZFONM;
        public String ZZZJLX;
        public String ZZRENO;
        public String ZZDUNS;
        public String ZZVAT;
        public String ZTAX_STCEG;
        public String ZZBLED;
        public String FOUND_DAT;
        public String ZZREFD;
        public String ZZPDFD;
        public String ZZLERE;
        public String ZZCMAT;
        public Integer ZZANRE;
        public String ZZIFCM;
        public String ZZCMCO;
        public String BU_LANGU;
        public Integer ZZEMCN;
        public String URI_ADDR;
        public String ZZBNAR;
        public String SMTP_ADDR;
        public String FAX_NUMBER;
        public String TEL_NUMBER;
        public String IND_SECTOR;
        public String ZZCVCO;
        public String ZZCUSTA;
        public String ZZCUSRISL;
        public String ZZCUSRITY;
        public String ZZCUSGR;
        public String ZZCHCUSCA;
        public String ZZCHCUSSU;
        public String ZZCRERAT;
        public String ZZHWKHFJ;
        public String TAXKD;
        public String LZONE;
        public String ZZFHLX;
        public String ZZFHYY;
        public String BBBNR;
        public String BBSNR;
        public String BUBKZ;
        public String ZZLINE;
        public String ZKATR2;
        public String ZKATR3;
        public String ZTAX_CODE1;
        public String ZTAX_CODE2;
        public String ZTAX_JUR;
        public List<GetCustomerInfoFromMDG.CustomerAddress> ADDR;
        public List<GetCustomerInfoFromMDG.CustomerType> CUTSOMER_TYPE;
        public List<GetCustomerInfoFromMDG.BankDetail> BANKDETAIL;
        public List<GetCustomerInfoFromMDG.CompanyView> COMPANY;
        public List<GetCustomerInfoFromMDG.SalesView> SALES;
        // 客户新增字段 （wfc 2025-02-08）
        public String ZSORT2;
        public String ZTAX_CODE3;
        public String ZTAX_CODE4;
        public String ZLIFNR;
        public String NAME_ORG1;
        public String NAME_ORG2;
        public String NAME_ORG3;
        public String NAME_ORG4;
    }
    //地址信息ADDR
    public class CustomerAddress {
        public String ZZADTY;
        public String LAND1;
        public String REGIO;
        public String ORT01;
        public String ORT02;
        public String ZZTOWN;
        public String POST_CODE1;
        public String FSTRAS;
        public String STR_SUPPL2;
        public String STR_SUPPL3;
        public String STR_SUPPL4;
        public String STR_LOCATION;
    }
    //客户类型
    public class CustomerType{
        public string PARTNER;
        public string ZZCUSTY;
    }
    //银行信息
    public class BankDetail{
        public string PMODE;
        public String BANKN;
        public String BANKL;
        public String BANKS;
        public String IBAN;
        public String ACCNAME;
        public String ZZACCNAME;
        public String ZZWAERS;
        public String BKONT;

    }
    //公司视图
    public class CompanyView{
        public String CLIENT;
        public String BUKRS;
        public String ZTERM;
        public String AKONT;
        public String SREGL;
        public String KVERM;
        public String NODEL;
        public String ZWELS;
        public String ZZLINE;
        public String LOEVM;
        public String ZZLGORT;
        public String ZZSORT1;
        public String ZZSORT2;
        public String EDI_TYPE;
        public String ZTV;
        public String ZVALID_TO;
        public String PACKAGING_TYPE;
        public String ZZSH;
        public String ZKHFL;

    }
    //销售视图
    public class SalesView{
        public String EIKTO;
        public String CLIENT;
        public String VKORG;
        public String SPART;
        public String VTWEG;
        public String KALKS;
        public String ZTERM;
        public String BZIRK;
        public String LOEVM;
        public String AUFSD;
        public String KONDA;
        public String VKBUR;
        public String VKGRP;
        public String PODKZ;
        public String INCO1;
        public String INCO2_L;
        public String INCO3_L;
        public String WAERS;
        public String KTGRD;
        public String KDGRP;
        public String VSBED;
        public String VWERK;
        public String KVGR2;
        public String TATYP;
        // 客户新增销售视图字段 （wfc 2025-02-08）
        public String ZKVGR1;
        public String ZKVGR3;
        public String ZKVGR4;
        public String ZKVGR5;
        public String PYKUR;
        public String BPKUR;
        public List<taxCodn> TAXCODN;
    }

    public class taxCodn {
        public String ALAND;
        public String TATYP;
        public String TAXKD;
    }

    public static  GetCustomerInfoFromMDG.CustomerInfo getCustomerInformationFromMDG(String counCode,String traderType,String tax) {

        String countryCode = counCode;
        String customerType = traderType;
        String taxCode = tax;
        Datetime currentTime = Datetime.now();

        System.debug('countryCode='+countryCode);
        System.debug('customerType='+customerType);
        System.debug('taxCode='+taxCode);
        //String url = 'https://open-apisix-test.hisense.com/mdg-cuscx/sap/bc/zmdg?app_id=7qywqbrk&app_key=qqe45ospdl9afhzaltpiw6ugyloj5ckw&if_id=Customer_query&sap-client=300';
        //String appid = '7qywqbrk';
        //String clientId = '300';
        //String if_id = 'Customer_query';
        //String secretKey = 'qqe45ospdl9afhzaltpiw6ugyloj5ckw';

        String url = MDG_Interface__c.getValues('CustomerQuery').Url__c;
        String appid = MDG_Interface__c.getValues('CustomerQuery').AppId__c;
        String clientId = MDG_Interface__c.getValues('CustomerQuery').ClientId__c;
        String if_id = MDG_Interface__c.getValues('CustomerQuery').If_Id__c;
        String secretKey = MDG_Interface__c.getValues('CustomerQuery').SecretKey__c;
        String server = MDG_Interface__c.getValues('CustomerQuery').Server__c;
        String datatime = '&if_id='+ if_id + '&sap-client=' + clientId;
        String message = 'POST\n'+
                server+'\n'+
                // '/mdg-cus-ucx/sap/bc/zmdg\n'+
                'app_id='+appid+'&app_key=' + secretKey + datatime+'\n'+
                appid+'\n'+
                'Mon, 01 Apr 2024 03:55:01 GMT\n';
        String sender = 'S0218';
        String Instid = currentTime.format('yyyyMMddHHmmss');

        //String body = '{"IS_BASE": {"SENDER": "S0001","INSTID": "Thu Oct 31 06:15:32 GMT 2024","BU_LANGU": "ZH"},"IT_SAPNUM": [{"SIGN": "I","OPTION": "EQ","LOW": "","HIGH": ""}]}';
        String body;
        String bodyStr;
        String bodyRes;
        if(counCode != null && counCode != ''){
            bodyStr = '"IT_LAND1": [{"SIGN": "I","OPTION": "EQ","LOW": "'+ counCode +'","HIGH": ""}],';
        }
        if(customerType != null && customerType != ''){
            bodyStr += '"IT_BUGRP": [{"SIGN": "I","OPTION": "EQ","LOW": "'+customerType+'","HIGH": ""}],';
        }
        if(taxCode != null && taxCode != ''){
            bodyStr += '"IT_TAXNUM": [{"SIGN": "I","OPTION": "EQ","LOW": "'+taxCode+'","HIGH": ""}]';
        }
            body = '{"IS_BASE": {"SENDER": "'+ sender +'","INSTID": "'+ Instid +'","BU_LANGU": ""},' + bodyStr +'}';

        System.debug('body='+body);

        GetCustomerInfoFromMDG.InterfaceInfo input = new GetCustomerInfoFromMDG.InterfaceInfo();
        CustomerInfo customerInfo = new CustomerInfo();
        InterfaceLog__c ic = new InterfaceLog__c();
        
        
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            Integer statusCode = response.getStatusCode();
            System.debug('status='+statusCode);
            input =(GetCustomerInfoFromMDG.InterfaceInfo)JSON.deserialize(bodyRes,GetCustomerInfoFromMDG.InterfaceInfo.class );
            System.debug('input='+input);
            if(input.SYNSTATUS == 'S'){
                
                if(input.DATA != null && input.DATA.size() > 0){

                    // 解析返回值
                    List<DATA> resultList = input.DATA;
                    for(DATA result : resultList){
                        if(result.DATA.ZZRENO == taxCode){
                            customerInfo = result.DATA;
                            break;
                        }
                    }
                    System.debug('DATA=' + customerInfo);

                    // customerInfo = input.DATA[0].DATA;
                    // System.debug('size='+input.DATA[0].DATA);
                }
                Utility.insertLogAsyn('GetCustomerInfoFromMDG', '1', body, bodyRes);
                // SFUtility.writeCallLogs('true', 'GetCustomerInfoFromMDG', body, bodyRes, 'Outbound', '成功');
            }else {
                //log
                Utility.insertLogAsyn('GetCustomerInfoFromMDG', '0', body, input.SYNRESULT);
                // SFUtility.writeCallLogs('false', 'GetCustomerInfoFromMDG', body, input.SYNRESULT, 'Outbound', '失败');
                
            }      

            }catch(Exception e) {
                //Integration Log
                Utility.insertLogAsyn('GetCustomerInfoFromMDG', '0', '', 'failure: SF GetCustomerInfoFromMDG Failed! ' + e.getMessage());
                // SFUtility.writeCallLogs('false', 'GetCustomerInfoFromMDG', body, 'failure: SF GetCustomerInfoFromMDG Failed! ' + e.getMessage(), 'Outbound', '错误');
            }

            System.debug('customerInfo='+customerInfo);
            return customerInfo;
        

    }

        //String updateTime = uptime.format('yyyyMMddHHmmss');
    public static  List<GetCustomerInfoFromMDG.DATA> getCustomerInformationByDateTimeFromMDG(String updateTime) {

        //String updateTime = upTime.format('yyyyMMddHHmmss');
        //String updateTime = '202409081234';
        Datetime currentTime = Datetime.now();

        String url = MDG_Interface__c.getValues('CustomerQuery').Url__c;
        String appid = MDG_Interface__c.getValues('CustomerQuery').AppId__c;
        String clientId = MDG_Interface__c.getValues('CustomerQuery').ClientId__c;
        String if_id = MDG_Interface__c.getValues('CustomerQuery').If_Id__c;
        String secretKey = MDG_Interface__c.getValues('CustomerQuery').SecretKey__c;
        String datatime = '&if_id='+ if_id + '&sap-client=' + clientId;
        String message = 'POST\n'+
                '/mdg-cuscx/sap/bc/zmdg\n'+
                'app_id='+appid+'&app_key=' + secretKey + datatime+'\n'+
                appid+'\n'+
                'Mon, 01 Apr 2024 03:55:01 GMT\n';
        String sender = 'S0218';
        String Instid = currentTime.format('yyyyMMddHHmmss');

        //String body = '{"IS_BASE": {"SENDER": "S0001","INSTID": "Thu Oct 31 06:15:32 GMT 2024","BU_LANGU": "ZH"},"IT_SAPNUM": [{"SIGN": "I","OPTION": "EQ","LOW": "","HIGH": ""}]}';
        String body;
        String bodyStr;
        String bodyRes;
        if(updateTime != null && updateTime != ''){
            bodyStr = '"IT_CRDAT": [{"SIGN": "I","OPTION": "GT","LOW": "'+ updateTime +'","HIGH": ""}]';
        }
        
            body = '{"IS_BASE": {"SENDER": "'+ sender +'","INSTID": "'+ Instid +'","BU_LANGU": ""},' + bodyStr +'}';

        System.debug('body='+body);
        
        GetCustomerInfoFromMDG.InterfaceInfo input = new GetCustomerInfoFromMDG.InterfaceInfo();
        List<DATA> dataList = new List<DATA>();
        
        
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            Integer statusCode = response.getStatusCode();
            System.debug('status='+statusCode);
            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){

                input =(GetCustomerInfoFromMDG.InterfaceInfo)JSON.deserialize(bodyRes,GetCustomerInfoFromMDG.InterfaceInfo.class );
                System.debug('size='+input.DATA[0].DATA);
                if(input.DATA != null && input.DATA.size() > 0){
                   
                    dataList = input.DATA;

                    
                }
                Utility.insertLogAsyn('GetCustomerInfoFromMDG', '1', body, '');
            }

            }catch(Exception e) {
                //Integration Log
                Utility.insertLogAsyn('GetCustomerInfoFromMDG', '0', '', 'failure: SF GetCustomerInfoFromMDG Failed! ' + e.getMessage());
            }
            System.debug('dataList='+dataList);
            return dataList;
        

    }
    public static String generateHmacSha256(String message, String secretKey){
        System.debug('message' + message);
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        String sigture = EncodingUtil.base64Encode(mac);
        System.debug('sigture' + sigture);
        return sigture;
    }

   
}