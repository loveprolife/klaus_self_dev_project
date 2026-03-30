/**********************************************************************
* Name: SAPGetInvoiceLog
* Object: Invoice 
* Purpose: 
* SAP中的发票信息每天定时，以增量的形式传递给salesforce
* Author: Gerry
* Create Date: 2019-03-06
*qinyanhao Update 2019-3-21
*************************************************************************/
public with sharing class SAPGetInvoiceLog {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_INVOICE_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    
   //private static String url = 'https://crmxid.hisense.com:8443/RESTAdapter/' + 'CC_REST_INVOICE_SEND';
   //private static String user = 'SFUSER';
   //private static String password = 'hisense2019';
    

    public class Output{
        List<String> CompanyCodeList;
        String SyncStartDate;
        String SyncEndDate;
        List<String> OrderTypeCodeList;
    }

    @Future(callout =true)
    public static void getInvoiceFromSAP(List<String> CompanyCodeList,String SyncStartDate,String SyncEndDate,List<String> orderTypeCodeList ){
        // 方法执行开始时间
        DateTime mint = System.Now();
        system.debug('mint:' + mint);

        Output out = new Output();
        out.CompanyCodeList = CompanyCodeList;
        out.SyncStartDate = SyncStartDate;
        out.SyncEndDate = SyncEndDate;
        out.OrderTypeCodeList = orderTypeCodeList;
        String body = JSON.serialize(out); 
        System.debug('bodybodybody ...'+body );
        String bodyRes_login;
        String bodyUserNotExist = '';
        // SAPInvoiceParsingSchedulable.Input input = new SAPInvoiceParsingSchedulable.Input();
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
            bodyRes_login = response.getBody();
            System.debug('bodyRes:11111' + bodyRes_login);
            // input =(SAPInvoiceParsingSchedulable.Input)JSON.deserialize(bodyRes_login,SAPInvoiceParsingSchedulable.Input.class );         
            // System.debug('inputinput..'+input);

            // 发送预警邮件
            try {
                if(bodyRes_login.length() > 1024 * 1024 * 6){
                    sendingEmail2Submitter(CompanyCodeList, SyncStartDate, SyncEndDate, orderTypeCodeList);
                }
            } catch (Exception e) {
                
            }

             // 当前时间N分钟，下一次定时时间
            DateTime reTime = System.Now().addMinutes(2);
            Integer minute = reTime.minute();
            Integer hour = reTime.hour();  
            String con = '0 ' + minute + ' ' + hour + ' * * ?';

            // 生成唯一值
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            System.schedule(h, con, new SAPInvoiceParsingSchedulable(bodyRes_login, h));
            // System.schedule(h, con, new SAPInvoiceParsingSchedulable(input, h));
            
            // 方法执行结束时间
            DateTime maxt = System.Now();
            system.debug('maxt:' + maxt);
            Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
            // 日志内容
            Utility.insertLog('SAPGetInvoiceLog', '1', body, ',sfdc调用获取发票信息接口成功！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');  
        }
        catch (Exception e) {
            DateTime maxt = System.Now();
            Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
            //日志内容
            String errorMsg = 'sfdc调用获取发票信息接口失败！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒';
            Utility.insertLog('SAPGetInvoiceLog', '0', body, errorMsg);

            // sendingEmail2Submitter(CompanyCodeList, SyncStartDate, SyncEndDate, orderTypeCodeList);
            
            return; 
        }


    }

    private static void sendingEmail2Submitter(List<String> CompanyCodeList,String SyncStartDate,String SyncEndDate,List<String> orderTypeCodeList){
        // List<String> pIdList = new List<String>();
        // for(Profile p : [select id,name from Profile where name in ('System Admin','System Administrator')]){
        //     pIdList.add(p.Id);
        // }
    
        List<string> emailList = new List<string>();
        // for(User u : [select Id,Name,Email from User where ProfileId in: pIdList]){
        //     emailList.add(u.Email);
        // } 
        emailList.add('qinyanhao@hisense.com');
        //Email list
        Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
        String emailBody = '<span style="display: inline-block; width:28px;">国家编号：</span> ' + CompanyCodeList.toString()  + '<br/> ' +
        '<span style="display: inline-block; width:28px;">订单类型：</span> ' + orderTypeCodeList.toString()  + '<br/> '+
        '<span style="display: inline-block; width:28px;">开始时间：</span> ' + SyncStartDate  + '<br/> '+
        '<span style="display: inline-block; width:28px;">结束时间：</span> ' + SyncEndDate;
        mail.setToAddresses(emailList);
        mail.setSenderDisplayName('CRM System Reminder');
        mail.setSubject('SAP拉取发票数量过多预警！');
        mail.setHtmlBody(emailBody);
        theEmails.add(mail);
            //}
        Messaging.Email[] allMails = new Messaging.Email[]{};
        for(Integer j = 0; j < theEmails.size(); j++) {
            allMails.add(theEmails.get(j));
        }

        System.debug('allMails:: '+allMails);
            // Print error information
        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
        System.debug('results... '+results);
        Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
        String emailErrorReport = '';
        for(Messaging.SendEmailResult currentResult : results) {
            errors = currentResult.getErrors();
            if(null != errors) {
                for(Messaging.SendEmailError currentError : errors) {
                emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
                System.debug('emailErrorReport... '+emailErrorReport);
                }
            }
        }
    }

}