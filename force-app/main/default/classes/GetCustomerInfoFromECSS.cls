/**********************************************************************
* Name: ECSS获取用户快速扫描接口
* Object: 
* Purpose: 
* Author: 
* Create Date: 
*************************************************************************/
public class GetCustomerInfoFromECSS {

    public class ResInfo {
        List<ResDeta> scanningResults;
    }
    
    public class ResDeta {
        String dataSupplierCode;
        String dataSupplierName;
        String type;
        String referenceId;
        String lawsAndRegulation;
        String listType;
        String name;
        String country;
        String city;
        String street;
        String zip;
        String matchedResult;
    }

    //全量数据谨慎执行(手动触发至中间表：命中表)
    // public static void syncCustomerInfoFromEcss() {
    //     List<Account> accounts = [SELECT id,name,Postal_Code__c,Address__c,City__c,Guarantor_Country_Code__c from Account];
    //     List<Ecss_Hit_Record__c> hit = [SELECT Id,Data_Name__c FROM Ecss_Hit_Record__c];
    //     //list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c];
    //     //Database.delete(mciListDel);
    //     // if(hit.size() > 0) {
            
    //     //     Database.delete(hit);
    //     // }
    //     // if(dl.size() > 0) {
    //     //     System.debug('ECSS全量删除' + dl.size());
    //     //     Database.delete(dl);
    //     // }        

    //     List<Ecss_Customer_Info__c> mciList = new List<Ecss_Customer_Info__c>();
    //     List<Ecss_Customer_Info__c> mciListDel = new List<Ecss_Customer_Info__c>();
    //     List<Ecss_Hit_Record__c> eciList = new List<Ecss_Hit_Record__c>();
    //     List<Ecss_Hit_Record__c> eciListDel = new List<Ecss_Hit_Record__c>();
    //     System.debug('全量数据条数' + accounts.size());
    //     for (Account acc : accounts) {
    //         System.debug('查询全量客户数据' + acc.Name);
    //         //List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getCustomerInfoFromEcssApi(acc.Name);
    //         // List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getEcssInfoTestApi(acc.Name,acc.Guarantor_Country_Code__c,acc.City__c,acc.Postal_Code__c,acc.Address__c);
    //         List<Ecss_Customer_Info__c> ecssInfoFromApi = new List<Ecss_Customer_Info__c>();

    //         if (ecssInfoFromApi.size() > 0) {
    //             for (Ecss_Customer_Info__c ecssInfos : ecssInfoFromApi) {
    //                 System.debug('获取接口返回数据' + ecssInfos);
    //                 if (String.isNotBlank(ecssInfos.name__c)) {
    //                     System.debug('判断名称不为空预备放入数据库' + ecssInfos);
    //                     //List<Ecss_Hit_Record__c> hit = [SELECT Id,Data_Name__c FROM Ecss_Hit_Record__c WHERE Customer__c =: acc.Id];
    //                     Ecss_Hit_Record__c h = new Ecss_Hit_Record__c();
                        
    //                         h.Data_Name__c = acc.Name;
    //                         h.Customer__c = acc.Id;
    //                         h.Hit_State__c = true;
    //                         if (hit.size() > 0) {
    //                             for (Ecss_Hit_Record__c t : hit) {
    //                                 eciListDel.add(t);
    //                             }
                                
    //                         //     Database.delete(hit);
    //                         //     Database.upsert(h);
    //                         // } else {
    //                         //     Database.upsert(h);
    //                         }
    //                         eciList.add(h);
                        
    //                     //list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : ecssInfos.name__c];
    //                     //Database.delete(dl);
    //                     // if (dl.size() > 0) {
    //                     //     for (Ecss_Customer_Info__c ci : dl) {
    //                     //         mciListDel.add(ecssInfos);
    //                     //     }
    //                     // }
                        
    //                     mciList.add(ecssInfos);
    //                 }
    //             }
    //         }           
    //     }

    //     //进行异步的upert 测验
    //     // InsertEcss bulkorderProduct = new InsertEcss(orderInsertList,mciList,tempOrderProMap);
    //     // ID jobID = System.enqueueJob(bulkorderProduct);
    //     // System.debug('数量：'+orderInsertList.size());
    //     // System.debug('数量2：'+orderProductList.size());

    //     System.debug('最终数据操作的条数' + mciList.size());
    //     Database.upsert(mciList); 
    //     Database.upsert(eciList);  
       
    // }

    // public static void syncBankInfoFromEcss() {
    //     //银行数据
    //     List<Customer_Banks__c> banks = [SELECT id,Bank_Name__c, Bank_Country__c FROM Customer_Banks__c];
    //     List<Ecss_Customer_Info__c> mciBankList = new List<Ecss_Customer_Info__c>();
    //     for (Customer_Banks__c acc : banks) {
    //         System.debug('查询全量银行数据' + acc.Bank_Name__c);
    //         List<Ecss_Customer_Info__c> ecssBankInfoFromApi = GetCustomerInfoFromECSS.getEcssInfoTestApi(acc.Bank_Name__c,acc.Bank_Country__c,'','','');
    //         if (ecssBankInfoFromApi.size() > 0) {
    //             for (Ecss_Customer_Info__c ecssInfos : ecssBankInfoFromApi) {
    //                 System.debug('获取接口返回数据' + ecssInfos);

    //                 if (String.isNotBlank(ecssInfos.name__c)) {
    //                     System.debug('判断名称不为空预备放入数据库' + ecssInfos);
    //                     list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : ecssInfos.name__c];
    //                     Database.delete(dl);
    //                     mciBankList.add(ecssInfos);
    //                 }
    //             }
    //         }           
    //     }
    //     Database.upsert(mciBankList);
    // }

    //触发获取某一条客户数据
    @future(callout=true)
    public static void GetCustomerInfoFromECSS(String nameString) {
        List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getCustomerInfoFromEcssApi(nameString);
        System.debug('实际数据的量SIZE' +  ecssInfoFromApi.size());
        List<Account> creditList = [SELECT Id,Name,Guarantor_Country_Code__c FROM Account WHERE Id =: nameString];
        Account credit;
        if (ecssInfoFromApi.size() > 0) {
            String nameParam = '%' + nameString + '%';

            
           // List<Ecss_Hit_Record__c> hit = [SELECT Id,Data_Name__c FROM Ecss_Hit_Record__c WHERE Customer__c =: credit.Id];
            //是否命中
            Ecss_Hit_Record__c h = new Ecss_Hit_Record__c();
            if (!creditList.isEmpty()) {
                credit = creditList[0];
                h.Data_Name__c = credit.Name;
                h.Customer__c = credit.Id;
                h.ExternalID__c =  credit.Id + credit.Guarantor_Country_Code__c;          
                h.Hit_State__c = true;
                System.debug('进行DML执行==>外键数据' + credit.Id + credit.Guarantor_Country_Code__c);
                Database.upsert(h, Ecss_Hit_Record__c.Fields.ExternalID__c, false);

            }
            // list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : nameParam];
            // Database.delete(dl);
            System.debug('验证外键值' + ecssInfoFromApi.get(0).ExternalID__c);
            Database.upsert(ecssInfoFromApi,Ecss_Customer_Info__c.Fields.ExternalID__C,false);
        } else {
            //为空时账户账号为正常状态
            if (!creditList.isEmpty()) {
                Account aResult = creditList[0];
                String reqParam = aResult.Name + aResult.Id;
                System.debug('验证数值' + aResult.Name + aResult.Id);
                Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
                m.Req_Name__c = reqParam;
                m.ExternalID__c = aResult.Name;
                m.ecss_result__c = 'ECSS Scan Result Passed';    
                Database.upsert(m, Ecss_Customer_Info__c.Fields.ExternalID__C,false);
            }
            
            // if (credit != null) {
            //     credit.Ecss_Result__c = 'ECSS Scan Result Passed';
            //     update credit;
            // }
        }
    }
    //单条银行数据
    @future(callout=true)
    public static void GetBankInfoFromECSS(String nameString) {
        List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getBankInfoFromEcssApi(nameString);
        System.debug('实际数据的量SIZE' +  ecssInfoFromApi.size());
        if (ecssInfoFromApi.size() > 0) {
            String nameParam = '%' + nameString + '%';
            List<Customer_Banks__c> credit = [SELECT Id,Bank_Name__c FROM Customer_Banks__c WHERE Bank_Name__c =: nameString ];            
            System.debug('获取银行库表数据' + credit);            
            System.debug('数据入库----');
            // list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : nameParam];
            // Database.delete(dl);
            Database.upsert(ecssInfoFromApi,Ecss_Customer_Info__c.Fields.ExternalID__C,false);
        } else {
            //为空时账户账号为正常状态
            Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
            m.Req_Name__c = nameString;
            m.ExternalID__c = nameString;
            m.ecss_result__c = 'ECSS Scan Result Passed';    
            Database.upsert(m, Ecss_Customer_Info__c.Fields.ExternalID__C,false);
            // if (credit != null) {
            //     credit.Ecss_Result__c = 'ECSS Scan Result Passed';
            //     update credit;
            // }
        }
    }

    public static String generateHmacSha256(String message, String secretKey){
        System.debug('message' + message);
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        String sigture = EncodingUtil.base64Encode(mac);
        System.debug('sigture' + sigture);
        return sigture;
    }

    
    public static List<Ecss_Customer_Info__c> getCustomerInfoFromEcssApi(String nameString) {
        String url = 'https://open-apisix.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search?app_id=suzltiqi&app_key=upqr2zykjo230phlejsqk6me3ma9ehu5';
        String appid = 'suzltiqi';
        String secretKey = 'upqr2zykjo230phlejsqk6me3ma9ehu5';
        String feederSystemToken = 'x0fysFfIxK3QRgj6tDNxB4RHWLzsWV4T5p5bfxznuzVqClDqgEGu1wYRk5HnlGVU';
        String authValue = 'gd9SFs5QnEcGksJo';
        String message = 'POST\n'+
        '/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\n'+
        'app_id='+appid+'&app_key=' + secretKey +'\n'+
        appid+'\n'+
        'Mon, 01 Apr 2024 03:55:01 GMT\n';

        // String url = 'https://open-apisix-test.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search?app_id=eyw0mfdc&app_key=t56xipj5pwqrgumsoo2lskkkqh6fpgep';
        // String appid = 'eyw0mfdc';
        // String secretKey = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';
        // String feederSystemToken = 'BexUudNNRA2C5MWVeBh9dCE2DhjgUhjsYy8NIa6h6Q27I0Nm0HnSERRHEUH5FW4T';
        // String authValue = 'iLGhytX3CiRAxJuZ'; 
        // String message = 'POST\n'+
        // '/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\n'+
        // 'app_id='+appid+'&app_key=' + secretKey +'\n'+
        // appid+'\n'+
        // 'Mon, 01 Apr 2024 03:55:01 GMT\n';
        Datetime currentTime = Datetime.now();
        String formattedTime = currentTime.format('EEE MMM dd HH:mm:ss z yyyy', 'GMT');
        System.debug('Current GMT Time: ' + formattedTime);
        
        System.debug('用户Name==' +  System.UserInfo.getName());
        //System.debug('获取用户语言信息' +  System.UserInfo.getLanguage());
        List<Account> accList = [SELECT Id,name,Postal_Code__c,Address__c,City__c,Guarantor_Country_Code__c FROM Account WHERE Id = :nameString];
        //System.debug('打印库表数据' + acc);
        String param1 = 'eyw0mfdc';
        String param2 = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';   
        String userNameString = System.UserInfo.getName();    
        String queryParameters = 'app_id=' + EncodingUtil.urlEncode(param1, 'UTF-8') + '&app_key=' + EncodingUtil.urlEncode(param2, 'UTF-8');
        String body;
        String keys;
        Account acc;
        String EcssResult;
        String country;
        String city;
        String zip;
        String street;
        String name;
        if(!accList.isEmpty()) {
            acc = accList[0];
            keys = acc.id + acc.Guarantor_Country_Code__c;
            
            if(String.isNotBlank(acc.Guarantor_Country_Code__c)) {
                country = '["'+acc.Guarantor_Country_Code__c+'"]';
            } else {
                country = '[]';
            }
            if(String.isNotBlank(acc.City__c)) {
                city = '["'+acc.City__c+'"]';
            } else {
                city = '[]';
            }
            if(String.isNotBlank(acc.Postal_Code__c)) {
                zip = '["'+acc.Postal_Code__c+'"]';
            } else {
                zip = '[]';
            }
            if(String.isNotBlank(acc.Address__c)) {
                street = '["'+acc.Address__c+'"]';
            } else {
                street = '[]';
            }
            name = acc.Name;
            if(name.contains('"')) {
                name = name.replace('"', '');
            }
            body = '{"attribute": {"name": ["'+GetCustomerInfoFromECSS.replaceChar(name)+'"],"entityType": 1,"country": '+GetCustomerInfoFromECSS.replaceChar(country)+',"city": '+GetCustomerInfoFromECSS.replaceChar(city)+',"zip": '+GetCustomerInfoFromECSS.replaceChar(zip)+',"street": '+GetCustomerInfoFromECSS.replaceChar(street)+'},"username": "'+GetCustomerInfoFromECSS.replaceChar(userNameString)+'"}'; 
        } else {
            //keys = nameString;
            body = '{"attribute": {"name": ["'+GetCustomerInfoFromECSS.replaceChar(userNameString)+'"],"entityType": 1,"country": [],"city": [],"zip": [],"street": []},"username": "'+GetCustomerInfoFromECSS.replaceChar(userNameString)+'"}'; 
        }
        System.debug('请求体参数' + body);


        String bodyRes;        
        List<Ecss_Customer_Info__c> mciList = new List<Ecss_Customer_Info__c>();
        //List<InterfaceLog__c> icList = new List<InterfaceLog__c>();
        //log
        InterfaceLog__c ic = new InterfaceLog__c();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
           // request.setEndpoint(url + '?' + queryParameters);
            //request.setEndpoint(url);
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('X-FeederSystem-Token', feederSystemToken);
            request.setHeader('X-Auth-Value', authValue);           
            request.setHeader('X-Lang-Id', 'en');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+ response);
            Integer statusCode = response.getStatusCode();
            bodyRes = response.getBody();
            //System.debug('bodyRes:' + bodyRes);
            System.debug('response.getStatusCode()==>' + response.getStatusCode());
            System.debug('response.getStatusCode().equals("200")==>' + (statusCode == 200) );
            
            if (statusCode == 200) {
                ic.Class__c = 'GetCustomerInfoFromECSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = body;
                
                ic.ErrorMsg__c = '';
                //insert ic;
            } else {
                ic.Class__c = 'GetCustomerInfoFromECSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = '';
                ic.ErrorMsg__c = bodyRes;
                //insert ic;
            }
            
                       
            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
                System.debug('满足条件');
                GetCustomerInfoFromECSS.ResInfo input_login = new GetCustomerInfoFromECSS.ResInfo();
                input_login = (GetCustomerInfoFromECSS.ResInfo) JSON.deserialize(bodyRes, GetCustomerInfoFromECSS.ResInfo.class);
                System.debug('input_loginsize '+input_login.scanningResults.size());
                if(input_login.scanningResults != null && input_login.scanningResults.size() > 0){
                    for(Integer i = 0; i < input_login.scanningResults.size(); i++){
                        String req = acc.Name + acc.Id;
                        ResDeta rd = input_login.scanningResults.get(i);
                        Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
                        m.dataSupplierCode__c = rd.dataSupplierCode;
                        m.dataSupplierName__c = rd.dataSupplierName;
                        m.type__c = rd.type;
                        m.referenceId__c = rd.referenceId;
                        m.lawsAndRegulation__c = rd.lawsAndRegulation;
                        m.listType__c = rd.listType;
                        m.name__c = rd.name;
                        m.Req_Name__c = req;
                        m.country__c = rd.country;
                        m.city__c = rd.city;
                        m.street__c = rd.street;
                        m.zip__c = rd.zip;
                        m.matchedResult__c = rd.matchedResult;
                        m.ecss_result__c = 'ECSS Scan Result Fails';
                        m.ExternalID__c = keys + rd.name;                                             
                        mciList.add(m);
                        
                        // System.debug('进行DML执行==>外键数据' + keys);
                    }
                    ic.Res_Json__c = input_login.scanningResults.size() + '';
                    EcssResult = 'ECSS Scan Result Fails';
                } else {
                    ic.Res_Json__c = input_login.scanningResults.size() + '';
                    EcssResult = 'ECSS Scan Result Passed';
                }             
            }           
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetCustomerInfoFromECSS', '0', '', 'failure: SF GetCustomerInfoFromECSS Failed! ' + e.getMessage());
        }
        if(!accList.isEmpty()) {
            Account aInfo = accList[0];
            aInfo.Ecss_Result__c = EcssResult;
            System.debug('update Account Ecss');
            update aInfo;
        }
        Database.upsert(ic);
        return mciList;
    }
    //银行数据
    public static List<Ecss_Customer_Info__c> getBankInfoFromEcssApi(String nameString) {
        String url = 'https://open-apisix.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search?app_id=suzltiqi&app_key=upqr2zykjo230phlejsqk6me3ma9ehu5';
        String appid = 'suzltiqi';
        String secretKey = 'upqr2zykjo230phlejsqk6me3ma9ehu5';
        String feederSystemToken = 'x0fysFfIxK3QRgj6tDNxB4RHWLzsWV4T5p5bfxznuzVqClDqgEGu1wYRk5HnlGVU';
        String authValue = 'gd9SFs5QnEcGksJo';
        String message = 'POST\n'+
        '/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\n'+
        'app_id='+appid+'&app_key=' + secretKey +'\n'+
        appid+'\n'+
        'Mon, 01 Apr 2024 03:55:01 GMT\n';
        // String url = 'https://open-apisix-test.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search?app_id=eyw0mfdc&app_key=t56xipj5pwqrgumsoo2lskkkqh6fpgep';
        // String appid = 'eyw0mfdc';
        // String secretKey = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';
        // String feederSystemToken = 'BexUudNNRA2C5MWVeBh9dCE2DhjgUhjsYy8NIa6h6Q27I0Nm0HnSERRHEUH5FW4T';
        // String authValue = 'iLGhytX3CiRAxJuZ'; 
        // String message = 'POST\n'+
        // '/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\n'+
        // 'app_id='+appid+'&app_key=' + secretKey +'\n'+
        // appid+'\n'+
        // 'Mon, 01 Apr 2024 03:55:01 GMT\n';
        Datetime currentTime = Datetime.now();
        String formattedTime = currentTime.format('EEE MMM dd HH:mm:ss z yyyy', 'GMT');
        System.debug('Current GMT Time: ' + formattedTime);        
        List<Customer_Banks__c> bankList = [SELECT id,Bank_Name__c, Bank_Country__c FROM Customer_Banks__c WHERE Bank_Name__c =:nameString];
        System.debug('用户Name==' +  System.UserInfo.getName());
        System.debug('获取用户语言信息' +  System.UserInfo.getLanguage());
        String param1 = 'eyw0mfdc';
        String param2 = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';   
        String userNameString = System.UserInfo.getName();    
        String queryParameters = 'app_id=' + EncodingUtil.urlEncode(param1, 'UTF-8') + '&app_key=' + EncodingUtil.urlEncode(param2, 'UTF-8');
        String body;
        String keys;
        Customer_Banks__c bank;
        String EcssResult;
        String country;

        if(!bankList.isEmpty()) {
            bank = bankList[0];
            keys = bank.id + bank.Bank_Country__c;
            if(String.isNotBlank(bank.Bank_Country__c)) {
                country = '["'+bank.Bank_Country__c+'"]';
            } else {
                country = '[]';
            }
            if(nameString.contains('"')) {
                nameString = nameString.replace('"', '');
            }            
            body = '{"attribute": {"name": ["'+GetCustomerInfoFromECSS.replaceChar(nameString)+'"],"entityType": 1,"country": '+GetCustomerInfoFromECSS.replaceChar(country)+',"city": [],"zip": [],"street": []},"username": "'+GetCustomerInfoFromECSS.replaceChar(userNameString)+'"}'; 
        } else {
            body = '{"attribute": {"name": ["'+GetCustomerInfoFromECSS.replaceChar(nameString)+'"],"entityType": 1,"country": [],"city": [],"zip": [],"street": []},"username": "'+GetCustomerInfoFromECSS.replaceChar(userNameString)+'"}'; 
        }
        System.debug('请求体参数' + body);
        String bodyRes;        
        List<Ecss_Customer_Info__c> mciList = new List<Ecss_Customer_Info__c>();
        //List<InterfaceLog__c> icList = new List<InterfaceLog__c>();
        InterfaceLog__c ic = new InterfaceLog__c();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
           // request.setEndpoint(url + '?' + queryParameters);
            //request.setEndpoint(url);
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('X-FeederSystem-Token', feederSystemToken);
            request.setHeader('X-Auth-Value', authValue);           
            request.setHeader('X-Lang-Id', 'en');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+ response);
            bodyRes = response.getBody();
            Integer statusCode = response.getStatusCode();
            bodyRes = response.getBody();
            //System.debug('bodyRes:' + bodyRes);
            System.debug('response.getStatusCode()==>' + response.getStatusCode());
            System.debug('response.getStatusCode().equals("200")==>' + (statusCode == 200) );
            
            if (statusCode == 200) {
                ic.Class__c = 'GetCustomerInfoFromECSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = body;
                
                ic.ErrorMsg__c = '';
                //insert ic;
            } else {
                ic.Class__c = 'GetCustomerInfoFromECSS';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = '';
                ic.ErrorMsg__c = bodyRes;
                //insert ic;
            }
            
            
            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
                System.debug('满足条件 '+ bodyRes);
                GetCustomerInfoFromECSS.ResInfo input_login = new GetCustomerInfoFromECSS.ResInfo();
                input_login = (GetCustomerInfoFromECSS.ResInfo) JSON.deserialize(bodyRes, GetCustomerInfoFromECSS.ResInfo.class);
                System.debug('input_loginsize '+input_login.scanningResults.size());
                if(input_login.scanningResults != null && input_login.scanningResults.size() > 0){
                    for(Integer i = 0; i < input_login.scanningResults.size(); i++){

                        ResDeta rd = input_login.scanningResults.get(i);
                        Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
                        m.dataSupplierCode__c = rd.dataSupplierCode;
                        m.dataSupplierName__c = rd.dataSupplierName;
                        m.type__c = rd.type;
                        m.referenceId__c = rd.referenceId;
                        m.lawsAndRegulation__c = rd.lawsAndRegulation;
                        m.listType__c = rd.listType;
                        m.name__c = rd.name;
                        m.Req_Name__c = nameString;
                        m.country__c = rd.country;
                        m.city__c = rd.city;
                        m.street__c = rd.street;
                        m.zip__c = rd.zip;
                        m.matchedResult__c = rd.matchedResult;
                        m.ecss_result__c = 'ECSS Scan Result Fails';
                        m.ExternalID__c = keys + rd.name;                                              
                        mciList.add(m);
                    }
                    ic.Res_Json__c = input_login.scanningResults.size() + '';
                    EcssResult = 'ECSS Scan Result Fails';
                } else {
                    ic.Res_Json__c = input_login.scanningResults.size() + '';
                    EcssResult = 'ECSS Scan Result Passed';
                }                     
            }           
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetCustomerInfoFromECSS', '0', '', 'failure: SF GetCustomerInfoFromECSS Failed! ' + e.getMessage());
        }
        if(bank != null) {
            bank.Ecss_Result__c = EcssResult;
            update bank;
        }

        Database.upsert(ic);
        return mciList;
    }

    // public static List<Ecss_Customer_Info__c> getEcssInfoTestApi(String nameString, String countryString,String city,String zip,String street) {
    //     //String url = 'https://open-apisix-test.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search';
    //     String url = 'https://open-apisix-test.hisense.com/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search?app_id=eyw0mfdc&app_key=t56xipj5pwqrgumsoo2lskkkqh6fpgep';
    //     String appid = 'eyw0mfdc';
    //     String secretKey = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';
    //     String feederSystemToken = 'BexUudNNRA2C5MWVeBh9dCE2DhjgUhjsYy8NIa6h6Q27I0Nm0HnSERRHEUH5FW4T';
    //     String authValue = 'iLGhytX3CiRAxJuZ'; 
    //     //String message = 'POST\n/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\napp_id=eyw0mfdc&app_key=t56xipj5pwqrgumsoo2lskkkqh6fpgep\n' + appid + '\nMon, 01 Apr 2024 03:55:01 GMT' + '\n';            
    //     String message = 'POST\n'+
    //     '/ecss/zte-grc-ecss-feedersystemapi/pub-api/v1/easy-search/for-easy-search\n'+
    //     'app_id='+appid+'&app_key=' + secretKey +'\n'+
    //     appid+'\n'+
    //     'Mon, 01 Apr 2024 03:55:01 GMT\n';
    //     Datetime currentTime = Datetime.now();
    //     String formattedTime = currentTime.format('EEE MMM dd HH:mm:ss z yyyy', 'GMT');
    //     System.debug('nameString全量' + nameString + 'Name长度' + nameString.length());
    //     Integer maxLength = 255; // 限定的最大长度
    //     if(nameString.length() > maxLength) {
    //         //system.debug('超出长度' + nameString);
    //         nameString = nameString.substring(0, maxLength); // 截取字符串
    //         system.debug('截断' + nameString);
    //     }

    //     System.debug('Current GMT Time: ' + formattedTime);        
    //     //Customer_Banks__c bank = [SELECT id,Bank_Name__c, Bank_Country__c FROM Customer_Banks__c WHERE Bank_Name__c =:nameString LIMIT 1];
    //     System.debug('用户Name==' +  System.UserInfo.getName());
    //     System.debug('获取用户语言信息' +  System.UserInfo.getLanguage());
    //     String param1 = 'eyw0mfdc';
    //     String param2 = 't56xipj5pwqrgumsoo2lskkkqh6fpgep';   
    //     String userNameString = System.UserInfo.getName();
    //     System.debug('stree参数' + GetCustomerInfoFromECSS.replaceChar(street)); 
    //     String queryParameters = 'app_id=' + EncodingUtil.urlEncode(param1, 'UTF-8') + '&app_key=' + EncodingUtil.urlEncode(param2, 'UTF-8');
    //     String body = '{"attribute": {"name": ["'+ GetCustomerInfoFromECSS.replaceChar(nameString) +'"],"entityType": 1,"country": ["'+ GetCustomerInfoFromECSS.replaceChar(countryString) +'"],"city": ["'+ GetCustomerInfoFromECSS.replaceChar(city) +'"],"zip": ["'+ GetCustomerInfoFromECSS.replaceChar(zip) +'"],"street": ["'+ GetCustomerInfoFromECSS.replaceChar(street) +'"]},"username": "'+ GetCustomerInfoFromECSS.replaceChar(userNameString) +'"}'; 
    //     String bodyRes; 
    //     System.debug('请求体参数' + body);
    //     List<Ecss_Customer_Info__c> mciList = new List<Ecss_Customer_Info__c>();
    //     List<InterfaceLog__c> icList = new List<InterfaceLog__c>();
    //     InterfaceLog__c ic = new InterfaceLog__c();
    //     try {
    //         HttpRequest request = new HttpRequest();
    //         HttpResponse response = new HttpResponse();
    //         Http http_login = new Http();
    //        // request.setEndpoint(url + '?' + queryParameters);
    //         //request.setEndpoint(url);
    //         request.setEndpoint(url.replace(' ','%20'));
    //         request.setMethod('POST');
    //         request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
    //         request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
    //         request.setHeader('X-HMAC-ACCESS-KEY', appid);
    //         request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
    //         request.setHeader('X-FeederSystem-Token', feederSystemToken);
    //         request.setHeader('X-Auth-Value', authValue);           
    //         request.setHeader('X-Lang-Id', 'zh');
    //         request.setHeader('Content-Type', 'application/json');
    //         request.setBody(body);
    //         request.setTimeout(120000); // timeout in milliseconds
            
    //         System.debug('request::: '+request);
    //         response = http_login.send(request);
    //         //System.debug('response '+ response);
    //         bodyRes = response.getBody();
    //         Integer statusCode = response.getStatusCode();
    //         //System.debug('bodyRes:' + bodyRes);
    //         System.debug('response.getStatusCode()==>' + response.getStatusCode());
    //         System.debug('response.getStatusCode().equals("200")==>' + (statusCode == 200) );
            
    //         if (statusCode == 200) {
    //             ic.Class__c = 'GetCustomerInfoFromECSS';
    //             ic.Time__c = System.Now();
    //             ic.ReturnCode__c = '1';
    //             ic.Req_Json__c = body;
                
    //             ic.ErrorMsg__c = '';
    //             //insert ic;
    //         } else {
    //             ic.Class__c = 'GetCustomerInfoFromECSS';
    //             ic.Time__c = System.Now();
    //             ic.ReturnCode__c = '0';
    //             ic.Req_Json__c = body;
    //             ic.Res_Json__c = '';
    //             ic.ErrorMsg__c = bodyRes;
    //             //insert ic;
    //         }
    //         if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
    //             System.debug('满足条件 '+ bodyRes);
    //             GetCustomerInfoFromECSS.ResInfo input_login = new GetCustomerInfoFromECSS.ResInfo();
    //             input_login = (GetCustomerInfoFromECSS.ResInfo) JSON.deserialize(bodyRes, GetCustomerInfoFromECSS.ResInfo.class);
    //             System.debug('input_loginsize '+input_login.scanningResults.size());
    //             if(input_login.scanningResults != null && input_login.scanningResults.size() > 0){
    //                 for(Integer i = 0; i < input_login.scanningResults.size(); i++){

    //                     ResDeta rd = input_login.scanningResults.get(i);
    //                     Ecss_Customer_Info__c m = new Ecss_Customer_Info__c();
    //                     m.dataSupplierCode__c = rd.dataSupplierCode;
    //                     m.dataSupplierName__c = rd.dataSupplierName;
    //                     m.type__c = rd.type;
    //                     m.referenceId__c = rd.referenceId;
    //                     m.lawsAndRegulation__c = rd.lawsAndRegulation;
    //                     m.listType__c = rd.listType;
    //                     m.name__c = rd.name;
    //                     m.country__c = rd.country;
    //                     m.city__c = rd.city;
    //                     m.street__c = rd.street;
    //                     m.zip__c = rd.zip;
    //                     m.matchedResult__c = rd.matchedResult;                                              
    //                     mciList.add(m);
    //                 }
    //             }              
    //         }           
    //     }catch(Exception e) {
    //         //Integration Log
    //         Utility.insertLog('GetCustomerInfoFromECSS', '0', '', 'failure: SF GetCustomerInfoFromECSS Failed! ' + e.getMessage());
    //     }

    //     Database.upsert(ic);
    //     return mciList;
    // }

    // //手动触发获取某一条客户/银行数据 测试用例专用
    // @future(callout=true)
    // public static void getEcssInfoTest(String nameString, String countryString,String city,String zip,String street) {
    //     List<Ecss_Customer_Info__c> ecssInfoFromApi = new List<Ecss_Customer_Info__c>();
    //     System.debug('传入的参数===' + '<名称>:' + nameString + '<国家>:' + countryString + '<城市>:' + city + '<邮编>:' + zip + '<详细地址>:' + street);
    //     if (String.isNotBlank(countryString) && (countryString.equals('RU') || countryString.equals('UA'))) {           
    //         if (String.isBlank(city) || String.isBlank(zip) || String.isBlank(street)) {
    //             System.debug('非全参不触发扫描');
    //         } else {
    //             ecssInfoFromApi = GetCustomerInfoFromECSS.getEcssInfoTestApi(nameString,countryString,city,zip,street);
    //         }
    //     } else if(countryString.equals('LT')) {          
    //         System.debug('国家为立陶宛LT，触发扫描失败');            
    //     }else {
    //          ecssInfoFromApi = GetCustomerInfoFromECSS.getEcssInfoTestApi(nameString,countryString,city,zip,street);
    //     }    
    //     System.debug('实际数据的量SIZE' +  ecssInfoFromApi.size());
    //     if (ecssInfoFromApi.size() > 0) {
    //         String nameParam = '%' + nameString + '%';
    //         list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : nameParam];
    //         Database.delete(dl);
    //         Database.upsert(ecssInfoFromApi);
    //     }
    // }

    //命中表用于定时获取道琼斯数据
    // public static void syncHitInfoFromEcss() {
    //     List<Ecss_Hit_Record__c> hits = [SELECT Id,Data_Name__c FROM Ecss_Hit_Record__c];
    //     List<Ecss_Customer_Info__c> mciList = new List<Ecss_Customer_Info__c>();
    //     if(hits.size() > 0) {
    //         for (Ecss_Hit_Record__c hit : hits) {
    //             System.debug('查询命中表客户数据' + hit.Data_Name__c);
    //             List<Ecss_Customer_Info__c> ecssInfoFromApi = GetCustomerInfoFromECSS.getCustomerInfoFromEcssApi(hit.Data_Name__c);
    //             if (ecssInfoFromApi.size() > 0) {
    //                 for (Ecss_Customer_Info__c ecssInfos : ecssInfoFromApi) {
    //                     System.debug('获取接口返回数据' + ecssInfos);
    //                     if (String.isNotBlank(ecssInfos.name__c)) {
    //                         System.debug('判断名称不为空预备放入命中数据库' + ecssInfos);                     
    //                         list<Ecss_Customer_Info__c> dl = [SELECT Id, name__c FROM Ecss_Customer_Info__c WHERE name__c LIKE : ecssInfos.name__c];
    //                         Database.delete(dl);
    //                         mciList.add(ecssInfos);
    //                     }
    //                 }
    //             }           
    //         }
    //         Database.upsert(mciList);      
    //     }
         
    // }

    //TJP 20241112 新增方法对字段包含的转义字符进行置换
    public static String replaceChar(String charString) {
        String replacedString = charString.replace('\r\n', ' ');
        replacedString = replacedString.replace('\r', ' ');
        replacedString = replacedString.replace('\n', ' ');
        return replacedString;
    }

}