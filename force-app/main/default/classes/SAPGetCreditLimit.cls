/*
 * @Author: WFC
 * @Date: 2022-03-08 15:21:14
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-28 17:55:29
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\classes\SAPGetCreditLimit.cls
 */
/**********************************************************************
Name:  InterfaceUtility
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL                                
1.0 -    Pierre            2019-03-02         Created
***********************************************************************/
public without sharing class SAPGetCreditLimit {
    // Get SAP credit limit info
    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CREDITINFO_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    
    //private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_CREDITINFO_SEND';
    //private static String user = 'xiaxiaoyang';
    //private static String password = 'hs123456';
    
    /**
    方法名: syncCreditLimitOverdueFromSAP
    功能说明: 通过rest调用的方式从SAP获取客户信用额度以及超期未回款信息
    参数说明：customerSAPCode是客户的SAP编码吗
    返回值：InterfaceLog__c
    作者: Pierre
    日期: 2019-03-02
    **/
    public static String syncCreditLimitOverdueFromSAP(String customerSAPCode) {
        HisenseInterfaceObject.SyncCreditLimitCondition syncCond = new HisenseInterfaceObject.SyncCreditLimitCondition();
        syncCond.SAPCustomerCode = customerSAPCode; 
        
        String jsonPost = json.serialize(syncCond);
        system.debug('客户同步请求参数 : ' + jsonPost);
        system.debug('jsonPost : ' + jsonPost);

        HisenseInterfaceObject.SyncCreditLimitResult result = new HisenseInterfaceObject.SyncCreditLimitResult();

        try{ 
        //登陆获取token
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            //信息同步
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();              
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setBody(jsonPost);
            req.setTimeout(120000); // timeout in milliseconds
            String jsonRep;
            if(Test.isRunningTest()){
                result = new HisenseInterfaceObject.SyncCreditLimitResult();
                result.SAPCustomerCode = 'testcode0011';
                result.TotalQuota = '1000';
                result.UsedQuota = '700';
                result.RemainQuota = '900';
                result.TotalOverdueAmount = '500';
                result.CreditCurrency = '1000';
                result.OverdueCurrency = '1000';
                result.IsSuccess = 'True';
                result.FailReason = 'error';
                result.rst = 'rst';
                result.rstMsg = 'msg';
                result.token = 'token';
                jsonRep = JSON.serialize(result);
            }else{
                res = http.send(req);
                jsonRep = res.getBody();
                System.debug('jsonRep:' + jsonRep);
                result = (HisenseInterfaceObject.SyncCreditLimitResult)JSON.deserialize(jsonRep, HisenseInterfaceObject.SyncCreditLimitResult.class);
            }
            //更新客户Credit信息
     
            System.debug('result::; '+result);

            if(result.IsSuccess == 'True'){

                Map<String, Decimal> currencyRateMap = new Map<String, Decimal>();
                for(CurrencyType ct : [SELECT  IsoCode, ConversionRate FROM CurrencyType Where IsActive = true]){
                    currencyRateMap.put(ct.IsoCode,ct.ConversionRate);
                }
                Account updateAccount = [SELECT ID, CurrencyIsoCode, SAP_Credit_Limit__c, Used_Credit_Limit__c,Overdue_Amount__c,Avaliable_Credit_Limit__c,
                                     Credit_Currency__c, Overdue_Currency__c,Payback_Y_N__c,Credit_Account_Code__c,Credit_Account_Name__c,Owner.Username 
                                     FROM Account WHERE SAP_Customer_Code__c =: customerSAPCode];

                Decimal rate = currencyRateMap.get(updateAccount.CurrencyIsoCode);
                Decimal rateZAR = currencyRateMap.get('ZAR');
                if(rate == null){
                    rate = 1;
                }
                if(rateZAR == null){
                    rateZAR = 1;
                }
                updateAccount.SAP_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim());
                updateAccount.SAP_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim()) * rate;
                updateAccount.SAP_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim()) * rateZAR;
                //updateAccount.SAP_Credit_Limit__c = 9999999.00;                         
                updateAccount.Used_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim());
                updateAccount.Used_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim()) * rate;
                updateAccount.Used_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim()) * rateZAR;
                //updateAccount.Used_Credit_Limit__c = 1554.80;
                updateAccount.Avaliable_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim());
                updateAccount.Avaliable_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim()) * rate;
                updateAccount.Avaliable_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim()) * rateZAR;
                //updateAccount.Avaliable_Credit_Limit__c = 9998444.20; 
                updateAccount.Overdue_Amount__c = Decimal.valueOf(String.isBlank(result.TotalOverdueAmount.trim())? '0':result.TotalOverdueAmount.trim());
                //updateAccount.Overdue_Amount__c = 0.00; 
                updateAccount.Credit_Currency__c = result.CreditCurrency.trim();
                updateAccount.Overdue_Currency__c = result.OverdueCurrency.trim();
                if(updateAccount.Overdue_Amount__c != 0){
                    updateAccount.Payback_Y_N__c = True;
                }else{
                    updateAccount.Payback_Y_N__c = False; 
                }
                
                
                //Roy updated on 20190924
                updateAccount.Credit_Account_Code__c = result.CreditAccountCode;
                updateAccount.Credit_Account_Name__c = result.CreditAccountName;
                
                System.debug('updateAccount::;' + updateAccount);

                update updateAccount;

                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'syncCreditLimitOverdueFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = jsonRep;
                ic.ErrorMsg__c = '';
                insert ic;
                
                return 'SUCCESS';
            } else {
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'syncCreditLimitOverdueFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = jsonRep;
                ic.ErrorMsg__c = 'res fail:   ' + result.FailReason;
                insert ic;
                return ic.ErrorMsg__c;
            }
        }catch(Exception e){  
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'syncCreditLimitOverdueFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = jsonPost;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'dml fail:   ' + e.getMessage();
            insert ic;
            return ic.ErrorMsg__c;
        } 
        
    }

    @future(callout=true)
    public static void syncCreditLimitOverdueFromSAPSchedulable(String customerSAPCode, Boolean sendEmailFlag, String country) {
        HisenseInterfaceObject.SyncCreditLimitCondition syncCond = new HisenseInterfaceObject.SyncCreditLimitCondition();
        syncCond.SAPCustomerCode = customerSAPCode; 
        
        String jsonPost = json.serialize(syncCond);
        system.debug('客户同步请求参数 : ' + jsonPost);
        system.debug('jsonPost : ' + jsonPost);

        HisenseInterfaceObject.SyncCreditLimitResult result = new HisenseInterfaceObject.SyncCreditLimitResult();

        try{ 
        //登陆获取token
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            //信息同步
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();              
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setBody(jsonPost);
            req.setTimeout(12000); // timeout in milliseconds
            String jsonRep;
            if(Test.isRunningTest()){
                result = new HisenseInterfaceObject.SyncCreditLimitResult();
                result.SAPCustomerCode = 'testcode0011';
                result.TotalQuota = '1000';
                result.UsedQuota = '700';
                result.RemainQuota = '900';
                result.TotalOverdueAmount = '500';
                result.CreditCurrency = '1000';
                result.OverdueCurrency = '1000';
                result.IsSuccess = 'True';
                result.FailReason = 'error';
                result.rst = 'rst';
                result.rstMsg = 'msg';
                result.token = 'token';
                jsonRep = JSON.serialize(result);
            }else{
                res = http.send(req);
                jsonRep = res.getBody();
                System.debug('jsonRep:' + jsonRep);
                result = (HisenseInterfaceObject.SyncCreditLimitResult)JSON.deserialize(jsonRep, HisenseInterfaceObject.SyncCreditLimitResult.class);
            }
            //更新客户Credit信息
     
            System.debug('result::; '+result);

            if(result.IsSuccess == 'True'){
                Map<String, Decimal> currencyRateMap = new Map<String, Decimal>();
                for(CurrencyType ct : [SELECT  IsoCode, ConversionRate FROM CurrencyType Where IsActive = true]){
                    currencyRateMap.put(ct.IsoCode,ct.ConversionRate);
                }
                Account updateAccount = [SELECT ID, CurrencyIsoCode, SAP_Credit_Limit__c, Used_Credit_Limit__c,Overdue_Amount__c,Avaliable_Credit_Limit__c,
                                     Credit_Currency__c, Overdue_Currency__c,Payback_Y_N__c,Credit_Account_Code__c,Credit_Account_Name__c,Owner.Username,Owner.Email 
                                     FROM Account WHERE SAP_Customer_Code__c =: customerSAPCode];

                Decimal rate = currencyRateMap.get(updateAccount.CurrencyIsoCode);
                Decimal rateZAR = currencyRateMap.get('ZAR');
                if(rate == null){
                    rate = 1;
                }
                if(rateZAR == null){
                    rateZAR = 1;
                }
                updateAccount.SAP_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim());
                updateAccount.SAP_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim()) * rate;
                updateAccount.SAP_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.TotalQuota.trim())? '0':result.TotalQuota.trim()) * rateZAR;
                //updateAccount.SAP_Credit_Limit__c = 9999999.00;                         
                updateAccount.Used_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim());
                updateAccount.Used_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim()) * rate;
                updateAccount.Used_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.UsedQuota.trim())? '0':result.UsedQuota.trim()) * rateZAR;
                //updateAccount.Used_Credit_Limit__c = 1554.80;
                updateAccount.Avaliable_Credit_Limit__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim());
                updateAccount.Avaliable_Credit_Limit_Currency__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim()) * rate;
                updateAccount.Avaliable_Credit_Limit_ZAR__c = Decimal.valueOf(String.isBlank(result.RemainQuota.trim())? '0':result.RemainQuota.trim()) * rateZAR;
                //updateAccount.Avaliable_Credit_Limit__c = 9998444.20; 
                updateAccount.Overdue_Amount__c = Decimal.valueOf(String.isBlank(result.TotalOverdueAmount.trim())? '0':result.TotalOverdueAmount.trim());
                //updateAccount.Overdue_Amount__c = 0.00; 
                updateAccount.Credit_Currency__c = result.CreditCurrency.trim();
                updateAccount.Overdue_Currency__c = result.OverdueCurrency.trim();
                if(updateAccount.Overdue_Amount__c != 0){
                    updateAccount.Payback_Y_N__c = True;
                }else{
                    updateAccount.Payback_Y_N__c = False; 
                }
                
                
                //Roy updated on 20190924
                updateAccount.Credit_Account_Code__c = result.CreditAccountCode;
                updateAccount.Credit_Account_Name__c = result.CreditAccountName;
                
                System.debug('updateAccount::;' + updateAccount);

                update updateAccount;

                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'syncCreditLimitOverdueFromSAPSchedulable';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = jsonRep;
                ic.ErrorMsg__c = '';
                insert ic;

                // 判断是否发送预警邮件
                if(updateAccount.SAP_Credit_Limit__c != 0 && sendEmailFlag){
                    if((updateAccount.Used_Credit_Limit__c / updateAccount.SAP_Credit_Limit__c) * 100 >= 50){
                        // 日本客户
                        if(country == 'JP'){
                            List<String> labelEmailAddress = Label.CreditLimitWarningEmailAddress.split(',');
                            labelEmailAddress.add(updateAccount.Owner.Username);
                            sendEmailWithTextTemplateUseMergeField(updateAccount.id, labelEmailAddress, 'Credit_limit_alert_email');
                        }else if(country == 'SA'){
                            List<String> labelEmailAddress = Label.CreditLimitWarningEmailAddressSA.split(',');
                            labelEmailAddress.add(updateAccount.Owner.Email);
                            // 获取客户team邮箱
                            // List<AccountTeamMember> atmList = [SELECT User.Email,User.IsActive from AccountTeamMember WHERE AccountId =: updateAccount.Id];
                            // for (AccountTeamMember atm : atmList) {
                            //     if(atm.User.IsActive){
                            //         labelEmailAddress.add(atm.User.Email);
                            //     }
                            // }
                            sendEmailWithTextTemplateUseMergeField(updateAccount.id, labelEmailAddress, 'Credit_limit_alert_email_SA');
                        }
                       
                    }
                }
            } else {
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'syncCreditLimitOverdueFromSAPSchedulable';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = jsonRep;
                ic.ErrorMsg__c = 'res fail:   ' + result.FailReason;
                insert ic;
            }
        }catch(Exception e){  
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'syncCreditLimitOverdueFromSAPSchedulable';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = jsonPost;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'dml fail:   ' + e.getMessage();
            insert ic;
        } 
        
    }

    

    /**
    * @description 使用邮件模板发送电子邮件
    * @author wfc | 02-25-2022 
    * @param whatId 
    * @param toAddresses 
    **/
    public static void sendEmailWithTextTemplateUseMergeField(Id whatId, List<String> toAddresses, String emailTemplateName) {
        EmailTemplate temp =  [
            SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId
            FROM EmailTemplate
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1
        ];

        Contact contact = [SELECT ID FROM Contact WHERE Email  = 'qinyanhao@hisense.com'];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // 设置邮件的发件人的显示名称；
        email.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);

        // 当使用email template时，此方法是必须使用的
        email.setTargetObjectId(contact.id);

        // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
        email.setTreatTargetObjectAsRecipient(false);

        // 如果设置了targetObjectId,则需要对它赋值为false，默认为true；
        email.setSaveAsActivity(false);
        
        // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
        email.setWhatId(whatId);

        // 设置email的template
        email.setTemplateId(temp.Id);
        // 设置接收人的email地址
        email.setToAddresses(toAddresses);
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});

        Utility.insertLog('SendEmailCreditLimitOverdue', '1', toAddresses.toString(), whatId);

    }
}