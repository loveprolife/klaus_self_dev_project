public without sharing class AccountCreditChange{

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CUSTOMER_CREDIT_CHANGE_REQ';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    public class CustomerInfo {
        public String CustomerCode; //客户编号
        public String CreditControlArea; //信贷控制范围
        public String CreditLimit; //信贷限额
        public String RiskCategory; //风险类型
        public String CreditGroup; //信贷组
        public String CreditInfoNumber; //信用信息号
        public String CreditNo2; //信用号2
    }

    public class ResDeta {
        public String FailReason;
        public String IsSuccess;
    }

    @InvocableMethod
    public static void AccountCreditChange(List<String> accIdList) {
        futureCallout(accIdList);
    }

    @future(callout=true)
    public static void futureCallout(List<String> accIdList) {
        //Trader_Type__c：002 或者 Trader_Type__c：006并且CustomerDetailType__c：18并且Credit_Management__c：1
        Account acc = [SELECT Id, SAP_Customer_Code__c, Trader_Type__c, Credit_Management__c, CustomerDetailType__c,Hisense_Entity__c,(select Hisense_Entity__c from customer_extends__r where Hisense_Entity__c != null order by CreatedDate limit 1) FROM Account  WHERE Id IN :accIdList LIMIT 1];
        if('H002'.equals(acc.Trader_Type__c) || 
            ('H006'.equals(acc.Trader_Type__c) && '18'.equals(acc.CustomerDetailType__c) && '1'.equals(acc.Credit_Management__c)) ||
            ('H006'.equals(acc.Trader_Type__c) && !'18'.equals(acc.CustomerDetailType__c))){

        }else{
            return;
        }
        //获取税分类组织mapping
        Map<String, CreditGroup__c> creditGroup = CreditGroup__c.getAll();
        String credit = '';
        if(String.isNotBlank(acc.Hisense_Entity__c)){
            credit = creditGroup.get(acc.Hisense_Entity__c).Credit__c;
        }else{
            if(acc.customer_extends__r != null && acc.customer_extends__r.size() > 0){
                credit = creditGroup.get(acc.customer_extends__r.get(0).Hisense_Entity__c).Credit__c;
            }
        }
        CustomerInfo customerInfo = new CustomerInfo();
        customerInfo.CustomerCode = acc.SAP_Customer_Code__c;
        customerInfo.CreditControlArea = '8888';
        customerInfo.CreditLimit = '0';
        customerInfo.RiskCategory = '001';
        customerInfo.CreditGroup = credit;
        customerInfo.CreditInfoNumber = '';
        customerInfo.CreditNo2 = '';

        String body = JSON.serialize(customerInfo);
        System.debug('body:: ' + body); 

        ResDeta input = new ResDeta();
        String bodyRes;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            AccountCreditChange.ResDeta input_login = new AccountCreditChange.ResDeta();
            input_login = (AccountCreditChange.ResDeta) JSON.deserialize(bodyRes, AccountCreditChange.ResDeta.class);
            System.debug('~~~~~~~~~~~~~~');
            System.debug('input_login '+input_login);

            //handle log
            if (input_login.IsSuccess == 'S') {
                Utility.insertLog('AccountCreditChange', '1', body, bodyRes);
            } else {
                Utility.insertLog('AccountCreditChange', '0', body, bodyRes);
            }
        } catch(Exception e) {
            //Integration Log
            Utility.insertLog('AccountCreditChange', '0', body, 'failure: SF Sync Customer Information to SAP Failed! ' + e.getMessage() + '-------' + bodyRes);
        }
    }
    
}