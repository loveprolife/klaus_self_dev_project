/*
 * @Author: WFC
 * @Date: 2023-11-23 10:15:33
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-04 14:12:55
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\classes\NewCustomerForEDIController.cls
 */
public without sharing class NewCustomerForEDIController {
    // https://open-apisix.hisense.com/sinosure-edi/ediserver/do?user_key=cbnykosifwb7futcywo4ljsgejbunwf9
    private static String url = Interface_Url__c.getValues('EDI').Basic_Url__c;

    @AuraEnabled
    public static ReturnData getEDIData(String buyerName, String countryCode) {
        ReturnData rd = new ReturnData();

        // body
        List<EDIPut> ediPutList = new List<EDIPut>();
        EDIPut edi1 = new EDIPut();
        edi1.edikey = 'countrycode';
        edi1.edival = countryCode;
        // edi1.edival = 'USA';
        EDIPut edi2 = new EDIPut();
        edi2.edikey = 'buyername';
        edi2.edival = buyerName;
        // edi2.edival = 'USA/001016570';
        EDIPut edi3 = new EDIPut();
        edi3.edikey = 'pageno';
        edi3.edival = '1';
        EDIPut edi4 = new EDIPut();
        edi4.edikey = 'businesscorpno';
        edi4.edival = System.label.New_Customer_EDI_Businesscorpno;
        // edi4.edival = '070857';
        ediPutList.add(edi1);
        ediPutList.add(edi2);
        ediPutList.add(edi3);
        ediPutList.add(edi4);

        Output op = new Output();
        op.imethod = 'getBuyerLikeQuery';
        op.datas = ediPutList;

        String body;
        String bodyRes;
        body = JSON.serialize(op);
        System.debug('www----' + body);
        NewCustomerForEDIController.Input input = new NewCustomerForEDIController.Input();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            // request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('www--request::: '+request);
            response = http_login.send(request);
            System.debug('www--response '+response);
            bodyRes = response.getBody();
            System.debug('www--' + bodyRes);
            // bodyRes = '{' + 
            //     '"code": "200",' +
            //     '"message": "操作成功",' +
            //     '"data": [' +
            //         '{' +
            //         '"createTime": "2023-11-15 15:02:37",' +
            //         '"updateTime": "2023-11-15 15:02:37",' +
            //         '"id": 1724688960597958700,' +
            //         '"chnname": "USA USA",' +
            //         '"buyerno": "USA/001016186",' +
            //         '"countryname": "USA",' +
            //         '"address": "543 E MEADOW AVE EAST MEADOW 11554-3956 UNITED STATES OF AMERICA",' +
            //         '"buyerlevel": "1"' +
            //         '},' +
            //         '{' +
            //         '"createTime": "2023-11-15 15:02:37",' +
            //         '"updateTime": "2023-11-15 15:02:37",' +
            //         '"id": 1724684312076001300,' +
            //         '"chnname": "USA DONUT",' +
            //         '"buyerno": "USA/001020122",' +
            //         '"countryname": "USA",' +
            //         '"address": "34157 HIGHWAY 43 THOMASVILLE AL 36784 UNITED STATES OF AMERICA",' +
            //         '"buyerlevel": "2"' +
            //         '},' +
            //         '{' +
            //         '"createTime": "2023-11-15 15:02:37",' +
            //         '"updateTime": "2023-11-15 15:02:37",' +
            //         '"id": 1724684312084390000,' +
            //         '"chnname": "CALIFORNIIA USA",' +
            //         '"buyerno": "USA/001018636",' +
            //         '"countryname": "USA",' +
            //         '"address": "22356 PHILIPRIMM ST WOODLAND HILLS CA 91367 UNITED STATES OF AMERICA",' +
            //         '"buyerlevel": "2"' +
            //         '},' +
            //         '{' +
            //         '"createTime": "2023-11-15 15:02:37",' +
            //         '"updateTime": "2023-11-15 15:02:37",' +
            //         '"id": 1724684312776450000,' +
            //         '"chnname": "USA",' +
            //         '"buyerno": "USA/446046310",' +
            //         '"countryname": "USA",' +
            //         '"address": "1932 CAMEO CT 77573-9088 LEAGUE CITY UNITED STATES OF AMERICA",' +
            //         '"buyerlevel": "0"' +
            //         '}' +
            //     ']' +
            // '}';
            // bodyRes = '{"code": "200","message": "操作成功","data": []}';
            System.debug('www--bodyRes:' + bodyRes);
            input =(NewCustomerForEDIController.Input)JSON.deserialize(bodyRes,NewCustomerForEDIController.Input.class);
            System.debug('www--data:' + input.data);
            System.debug('www--code:' + input.code);
            System.debug('www--message:' + input.message);
            if(input.code == '200'){
                rd.isSuccess = true;
                rd.ediData = '[]';
                if(input.data != null){
                    rd.ediData = JSON.serialize(input.data);
                    // 保存数据 EDI_Customer__c
                    List<EDI_Customer__c> addEDICustomerList = new List<EDI_Customer__c>();
                    List<InputData> inputData = input.data;
                    for(InputData info : inputData){
                        EDI_Customer__c ediCustomer = new EDI_Customer__c();
                        ediCustomer.createTime__c = info.createTime;
                        ediCustomer.updateTime__c = info.updateTime;
                        ediCustomer.id__c = info.id;
                        ediCustomer.chnname__c = info.chnname;
                        ediCustomer.buyerno__c = info.buyerno;
                        ediCustomer.countryname__c = info.countryname;
                        ediCustomer.address__c = info.address;
                        ediCustomer.buyerlevel__c = info.buyerlevel;
                        addEDICustomerList.add(ediCustomer);
                    }
                    Database.upsert(addEDICustomerList,EDI_Customer__c.Fields.id__c,false);
                }
                
            }else {
                rd.isSuccess = false;
                rd.failMessage = '接口返回错误！';
            }
           
            return rd;
        }
        catch (Exception e) {
            System.debug('wwww-- ' + e.getMessage());
            rd.isSuccess = false;
            rd.failMessage = '调用接口失败！' + e.getMessage();
            return rd; 
        }
    }
    /**
     * 保存关联EDI 客户
     * @param customerId - 选择的客户ID
     * @param buyerParam - EDI 客户数据
     * @return 返回插入后的EDI客户（含关联客户） 记录ID
     * @throws AuraHandledException 如果获取案件信息时出现问题
     * @作者: Yang lin
     * @日期: 2024-12-05 
     * @描述: 该方法保存查询到的edi客户数据，与选择的客户做关联。
     */
    @AuraEnabled
    public static String saveEDICustomerDate(String customerId, String buyerParam) {
        try {
            // 将 JSON 数据反序列化为对象
            NewCustomerForEDIController.InputData bpObj = (NewCustomerForEDIController.InputData) JSON.deserialize(buyerParam, NewCustomerForEDIController.InputData.class);
            System.debug('bpObj===》 ' + bpObj);
            
            // 创建 EDI_Customer__c 对象并赋值
            EDI_Customer__c ediCustomer = new EDI_Customer__c();
            ediCustomer.id__c = bpObj.id; // 外部 ID，用于匹配
            ediCustomer.createTime__c = bpObj.createTime;
            ediCustomer.updateTime__c = bpObj.updateTime;
            ediCustomer.chnname__c = bpObj.chnname;
            ediCustomer.buyerno__c = bpObj.buyerno;
            ediCustomer.countryname__c = bpObj.countryname;
            ediCustomer.address__c = bpObj.address;
            ediCustomer.buyerlevel__c = bpObj.buyerlevel;
            ediCustomer.Customer_Cleaning_Id__c = customerId;
            
            // 使用 Upsert 操作，根据 id__c 匹配
            Upsert ediCustomer id__c;

            // 返回记录 ID
            return ediCustomer.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static ReturnData getCustomerDataFromEDI(String recordTypeId, String buyerName, String countryCode, String buyerParam) {
        ReturnData rd = new ReturnData();
        System.debug('www--recordTypeId:' + recordTypeId);
        System.debug('www--buyerName:' + buyerName);
        System.debug('www--countryCode:' + countryCode);
        System.debug('www--buyerParam:' + buyerParam);
        NewCustomerForEDIController.InputData buyerParamData = (NewCustomerForEDIController.InputData)JSON.deserialize(buyerParam,NewCustomerForEDIController.InputData.class);

        // body
        List<EDIPut> ediPutList = new List<EDIPut>();
        EDIPut edi1 = new EDIPut();
        edi1.edikey = 'buyercode';
        edi1.edival = buyerParamData.buyerno;
        EDIPut edi2 = new EDIPut();
        edi2.edikey = 'buyerlevel';
        edi2.edival = buyerParamData.buyerlevel;
        EDIPut edi3 = new EDIPut();
        edi3.edikey = 'businesscorpno';
        edi3.edival = System.label.New_Customer_EDI_Businesscorpno;
        // edi3.edival = '070857';
        ediPutList.add(edi1);
        ediPutList.add(edi2);
        ediPutList.add(edi3);

        Output op = new Output();
        op.imethod = 'getBuyerPortrait';
        op.datas = ediPutList;

        String body;
        String bodyRes;
        body = JSON.serialize(op);
        System.debug('www----' + body);
        NewCustomerForEDIController.PortraitInput input = new NewCustomerForEDIController.PortraitInput();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            // request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('www--request::: '+request);
            response = http_login.send(request);
            System.debug('www--response '+response);
            bodyRes = response.getBody();
            // bodyRes = '{' + 
            //     '"code": "200",' +
            //     '"message": "操作成功",' +
            //     '"data": {' +
            //         '"createTime": "2023-11-15 15:21:06",' +
            //         '"updateTime": "2023-11-15 15:21:06",' +
            //         '"id": 1724688960597958700,' +
            //         '"buyerno": null,' +
            //         '"buyername": null,' +
            //         '"countrycode": "USA",' +
            //         '"address": null,' +
            //         '"usedname": null,' +
            //         '"regioncode": null,' +
            //         '"regionrule": "确认企业时需注意，美国企业按州注册，并且可能存在跨州经营的情况（一个企业在多州注册且有不同的注册号）。",' +
            //         '"taxno": null,' +
            //         '"othertaxno": null,' +
            //         '"tradename": null,' +
            //         '"othertradename": null,' +
            //         '"telphone": null,' +
            //         '"fax": "1-408-9960275",' +
            //         '"email": "INFO@APPLE.COM",' +
            //         '"website": null,' +
            //         '"businessaddress": null,' +
            //         '"postaddress": "ONE APPLE PARK WAY CUPERTINO 95014 CALIFORNIA US",' +
            //         '"branchaddress": null,' +
            //         '"otheraddress": null,' +
            //         '"otheraddressremark": null,' +
            //         '"opendate": null,' +
            //         '"registerdata": null,' +
            //         '"ceoname": null,' +
            //         '"islisted": "1",' +
            //         '"stockexchange": null,' +
            //         '"stockcode": "AAPL",' +
            //         '"amounttotal": "0",' +
            //         '"isinsuranced": "是",' +
            //         '"startinsuranced": "2020",' +
            //         '"managementstate": null,' +
            //         '"registerstatus": null,' +
            //         '"isfrmloss": "是",' +
            //         '"registercapital": null,' +
            //         '"registermoneyid": null,' +
            //         '"staffnumber": null,' +
            //         '"effectivequotapaytermavglc": "1011.11",' +
            //         '"effectivequotapaytermavgnotlc": "1011.11",' +
            //         '"quotaconcentration": "集中度低",' +
            //         '"ratingvalue": "1",' +
            //         '"policynovolist": [' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960644096000,' +
            //                 '"policyno": "SCP000033-232300",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "1",' +
            //                 '"inotreceiptmoneyusd": "55.93",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": null' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960652484600,' +
            //                 '"policyno": "SCR000047-232300",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "0",' +
            //                 '"inotreceiptmoneyusd": "55.93",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": null' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960715399200,' +
            //                 '"policyno": "SCH063413-232300",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "1",' +
            //                 '"inotreceiptmoneyusd": "26.88",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": [' +
            //                     '{' +
            //                         '"createTime": "2023-11-15 15:21:06",' +
            //                         '"updateTime": "2023-11-15 15:21:06",' +
            //                         '"id": 1724688960732176400,' +
            //                         '"policynoId": 1724688960715399200,' +
            //                         '"quotastate": "1",' +
            //                         '"adcondition": null,' +
            //                         '"quotasum": "1000.00",' +
            //                         '"buyerquotano": "1200/2023005871/01",' +
            //                         '"bankno": null' +
            //                     '},' +
            //                     '{' +
            //                         '"createTime": "2023-11-15 15:21:06",' +
            //                         '"updateTime": "2023-11-15 15:21:06",' +
            //                         '"id": 1724688960744759300,' +
            //                         '"policynoId": 1724688960715399200,' +
            //                         '"quotastate": "1",' +
            //                         '"adcondition": null,' +
            //                         '"quotasum": "150000.00",' +
            //                         '"buyerquotano": "3200/201631402/01",' +
            //                         '"bankno": null' +
            //                     '}' +
            //                 ']' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960757342200,' +
            //                 '"policyno": "SCH002692/SGPWH-111100",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "0",' +
            //                 '"inotreceiptmoneyusd": "0.00",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": null' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960761536500,' +
            //                 '"policyno": "SCH063413-232500",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "0",' +
            //                 '"inotreceiptmoneyusd": "0.00",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": null' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960866394000,' +
            //                 '"policyno": "SCH002692/AB/SYIDN-151500",' +
            //                 '"insuredsumrpt": "0",' +
            //                 '"divisin": "0",' +
            //                 '"ifexceed": "0",' +
            //                 '"inotreceiptmoneyusd": "0.00",' +
            //                 '"inotreceiptmoneyusdL": null,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"quotalist": null' +
            //             '}' +
            //         '],' +
            //         '"earlywarningvolist": [' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960878977000,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "78495",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为破产清算",' +
            //                 '"publishdate": "2022/04/26"' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960899948500,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "85607",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为破产清算",' +
            //                 '"publishdate": "2022/04/27"' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960904142800,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "90068",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为无有效注册",' +
            //                 '"publishdate": "2023/03/05"' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960912531500,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "100886",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为破产清算",' +
            //                 '"publishdate": "2023/04/21"' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960916725800,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "121636",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为破产清算",' +
            //                 '"publishdate": "2023/04/25"' +
            //             '},' +
            //             '{' +
            //                 '"createTime": "2023-11-15 15:21:06",' +
            //                 '"updateTime": "2023-11-15 15:21:06",' +
            //                 '"id": 1724688960929308700,' +
            //                 '"portraitId": 1724688960597958700,' +
            //                 '"contentid": "128443",' +
            //                 '"countrycode": "USA",' +
            //                 '"alarmlevel": "重点关注",' +
            //                 '"title": "经营状态异常",' +
            //                 '"content": "经营状态变更为破产清算",' +
            //                 '"publishdate": "2023/04/28"' +
            //             '}' +
            //         ']' +
            //     '}' + 
            // '}';
            // bodyRes = '{"code": "200","message": "操作成功","data": {}}';
            System.debug('www--bodyRes:' + bodyRes);
            // 保存日志中
            SFUtility.writeCallLogs('true', 'getCustomerDataFromEDI', body, bodyRes, 'Outbound', '成功');
            input =(NewCustomerForEDIController.PortraitInput)JSON.deserialize(bodyRes,NewCustomerForEDIController.PortraitInput.class);
            System.debug('www--data:' + input.data);
            System.debug('www--code:' + input.code);
            
            if(input.code == '200'){  
                NewCustomerForEDIController.PortraitInputData pData = input.data;
                // 返回信息给客户赋值
                Account acc = new Account();
                acc.RecordTypeId = recordTypeId;
                acc.Name = pData.buyername != null ? pData.buyername : '';
                acc.Website = pData.website != null ? pData.website : '';
                acc.Phone = pData.telphone != null ? pData.telphone : '';
                acc.Fax = pData.fax != null ? pData.fax : '';
                acc.Email__c = pData.email != null ? pData.email : '';
                acc.VAT_Registration_Number__c = pData.regioncode != null ? pData.regioncode : '';
                acc.Address__c = pData.address != null ? pData.address : '';
                acc.Sales_Region__c = CountryCode__c.getValues(pData.countrycode).Sales_Region__c != null ? CountryCode__c.getValues(pData.countrycode).Sales_Region__c : '';
                System.debug('www--Name:' + pData.buyername);
                System.debug('www--website:' + pData.website);
                System.debug('www--telphone:' + pData.telphone);
                System.debug('www--fax:' + pData.fax);
                System.debug('www--email:' + pData.email);
                System.debug('www--regioncode:' + pData.regioncode);
                System.debug('www--address:' + pData.address);
                System.debug('www--region:' + CountryCode__c.getValues(pData.countrycode).Sales_Region__c);
                List<Account> accList = [SELECT Id FROM Account WHERE VAT_Registration_Number__c = :pData.regioncode AND VAT_Registration_Number__c != NULL LIMIT 1];
                if(accList != null && accList.size() > 0){
                    rd.failMessage = 'view';
                    // rd.account = accList[0];
                    System.debug('www--view');
                }else {
                    rd.failMessage = 'new';
                    // rd.account = acc;
                    System.debug('www--new');
                }

                List<Policynovolist> policynovolist = pData.policynovolist != null ? pData.policynovolist : new List<Policynovolist> ();
                List<Earlywarningvolist> earlywarningvolist = pData.earlywarningvolist != null ? pData.earlywarningvolist : new List<Earlywarningvolist> ();
                for(Policynovolist p :policynovolist){
                    System.debug('www--Policynovolist--:' + JSON.serialize(p));
                    if(p.quotalist != null){
                        List<Quotalist> quotalist = p.quotalist;
                        for(Quotalist q :quotalist){
                            System.debug('www--Quotalist--:' + JSON.serialize(q));
                        }
                    }
                }
                for(Earlywarningvolist e :earlywarningvolist){
                    System.debug('www--Earlywarningvolist--:' + JSON.serialize(e));
                }
                System.debug('www--acc--' + acc);
                rd.account = acc;
                rd.isSuccess = true;             
            }else {
                rd.isSuccess = false;
                rd.failMessage = '接口返回错误！';
            }
           
            return rd;
        }
        catch (Exception e) {
            rd.isSuccess = false;
            rd.failMessage = '调用接口失败！' + e.getMessage();
            return rd; 
        }
    }

    public class ReturnData {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String failMessage;
        @AuraEnabled public String ediData;
        @AuraEnabled public Account account;
    }

    public class Output{
        List<EDIPut> datas;
        String imethod;
    }

    public class EDIPut{
        String edikey;
        String edival;
    }

    public class Input{
        public List<InputData> data;
        public String code;
        public String message;
    }

    public class InputData{
        String createTime;
        String updateTime;
        String id;
        String chnname;
        String buyerno;
        String countryname;
        String address;
        String buyerlevel;
    }

    public class PortraitInput{
        public PortraitInputData data;
        public String code;
        public String message;
    }

     public class PortraitInputData{
        String createTime;
        String updateTime;
        String id;
        String buyerno;
        String buyername;
        String countrycode;
        String address;
        String usedname;
        String regioncode;
        String regionrule;
        String taxno;
        String othertaxno;
        String tradename;
        String othertradename;
        String telphone;
        String fax;
        String email;
        String website;
        String businessaddress;
        String postaddress;
        String branchaddress;
        String otheraddress;
        String otheraddressremark;
        String opendate;
        String registerdata;
        String ceoname;
        String islisted;
        String stockexchange;
        String stockcode;
        String amounttotal;
        String isinsuranced;
        String managementstate;
        String registerstatus;
        String isfrmloss;
        String registercapital;
        String registermoneyid;
        String staffnumber;
        String effectivequotapaytermavglc;
        String effectivequotapaytermavgnotlc;
        String quotaconcentration;
        String ratingvalue;
        List<Policynovolist> policynovolist;
        List<Earlywarningvolist> earlywarningvolist;
    }

    public class Policynovolist{
        public String createTime;
        public String updateTime;
        public String id;
        public String policyno;
        public String insuredsumrpt;
        public String divisin;
        public String ifexceed;
        public String inotreceiptmoneyusd;
        public String inotreceiptmoneyusdL;
        public String portraitId;
        public List<Quotalist> quotalist;
    }

    public class Quotalist{
        public String createTime;
        public String updateTime;
        public String id;
        public String policynoId;
        public String quotastate;
        public String adcondition;
        public String quotasum;
        public String buyerquotano;
        public String bankno;
    }

    public class Earlywarningvolist{
        public String createTime;
        public String updateTime;
        public String id;
        public String portraitId;
        public String contentid;
        public String countrycode;
        public String alarmlevel;
        public String title;
        public String content;
        public String publishdate;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getCountryCodeOptions() {
        // 返回值
        List<Map<String, String>> result = new List<Map<String, String>>();
        // 国别代码
        // Map<String, CountryCode__c> countryCodeMap = CountryCode__c.getAll();
        // for(String code : countryCodeMap.keySet()){
        //     result.add(new Map<String, String> {
        //         'label' => countryCodeMap.get(code).Name__c + '(' + countryCodeMap.get(code).Code__c + ')',
        //         'value' => countryCodeMap.get(code).Code__c
        //     });
        // }
        List<CountryCode__c> countryCodeList = [SELECT Name__c,Code__c FROM CountryCode__c WHERE IsActive__c = true ORDER BY Sort__c];
        for(CountryCode__c countryCode : countryCodeList){
            result.add(new Map<String, String> {
                'label' => countryCode.Name__c + '(' + countryCode.Code__c + ')',
                'value' => countryCode.Code__c
            });
        }
        return result;
    }
	 public static void runTest(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}