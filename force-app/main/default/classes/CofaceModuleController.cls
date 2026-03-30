/*
 * @Author: WFC
 * @Date: 2026-03-06 09:19:43
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-30 17:11:41
 * @Description: Coface class
 * @FilePath: \testuat\force-app\main\default\classes\CofaceModuleController.cls
 */
public with sharing class CofaceModuleController{
    public class CofaceRepositoriesResponse{
        public String slug;
        public Boolean isLegal;
        public String repositoryFormat;
    }

    /**
     * Coface authentication request DTO
     */
    public class CofaceAuthRequest{
        public String username;
        public String password;
        public String grantType;
        public String refreshToken;
    }

    /**
     * Coface authentication response DTO
     */
    public class CofaceAuthResponse{
        public String idToken;
        public String accessToken;
        public String refreshToken;
        public Integer expiresIn;
        public String tokenType;
        public String raw; // full raw response for diagnostics
        public String error; // error message if any
        public Integer statusCode;
    }

    public class CofaceOrderRequest{
        public String externalId;
        public String countryCode;
        public CofaceOrderReportRequest report;
        public String callbackUrl;
        public String notificationCallbackUrl;
        public String key;
    }

    public class CofaceOrderReportRequest{
        public String slug;
        public String language;
        public List<String> format;
        public String proccessingTimeInstruction;
        public String investigationSpeedLevel;
        // 'currency' is a reserved identifier in Apex contexts; use a safe name and map to JSON key later
        public String currencyIso;
    }

    public class MonitoringsReport{
        public String id;
        public String companyId;
        public String externalId;
        public String initialDeliveryId;
        public String orderDate;
        public String startDate;
        public String endDate;
        public String countryCode;
        public String reportSlug;
        public String callbackUrl;
        public String notificationCallbackUrl;
        public String deliveryDate;
        public String expectedDeliveryDate;
        public String language;
        public String format;
        public String status;
        public String channelDelivery;
        public String backendOrderId;
        public String backendMonitOrderId;
        public List<Publications> publications;
    }

    public class Publications{
        public String id;
        public String language;
        public String format;
        public String status;
        public String expectedDeliveryDate;
        public String reportSlug;
        public String backendOrderId;
        public String backendMonitOrderId;
    }

    /**
     * Simple configurable holder. In production, move these to Named Credential + Custom Metadata/Custom Settings.
     * All parameters are defined here to be easily changeable without altering core logic.
     */
    public class CofaceConfig{
        // Base endpoint (no trailing slash)
        public String baseUrl = 'https://api.coface.com';
        // Resource path for token
        public String tokenPath = '/authentication/v1/token';
        public String dataAPIBaseUrl = 'https://icon-api-test.coface.com/dataapi-v1';
        // Header values
        public String apiKeyHeaderName = 'x-api-key';
        public String apiKeyValue = 'J9TDVaIU0M5l0ySI0FJNWLyC0KsFRqb4ANeXECC5';
        public String contentType = 'application/json';
        // Request body values
        public String username = 'salesforceyunwei@hisense.com';
        public String password = 'Hisense2024';
        public String grantType = 'password';
        public String refreshTokenGrantType = 'refresh_token';
        public String refreshToken = 'string';
    }

    /**
     * coface国家前端下拉列表需要
     */
    public class CofaceCountryData{
        @AuraEnabled
        public String label{ get; set; }

        @AuraEnabled
        public String value{ get; set; }

        @AuraEnabled
        public Boolean special{ get; set; }

    }

    /**
     * 获取token方法
     * Performs POST to Coface token endpoint and returns parsed token fields as a JSON string.
     * Note: For production, replace inline config with Named Credential and Custom Metadata.
     */
    @AuraEnabled(cacheable = true)
    public static String getCofaceToken(){
        // Return early pattern
        CofaceAuthResponse out = new CofaceAuthResponse();
        CofaceConfig cfg = new CofaceConfig();

        // Build request body from configurable values
        CofaceAuthRequest reqBody = new CofaceAuthRequest();
        reqBody.username = cfg.username;
        reqBody.password = cfg.password;
        reqBody.grantType = cfg.grantType;
        reqBody.refreshToken = cfg.refreshToken;

        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(cfg.baseUrl + cfg.tokenPath);
            req.setMethod('POST');
            req.setHeader('Content-Type', cfg.contentType);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);
            req.setBody(JSON.serialize(reqBody));

            Http http = new Http();
            HttpResponse res = http.send(req);

            out.statusCode = res.getStatusCode();
            out.raw = res.getBody();

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300){
                // Parse successful response
                CofaceAuthResponse parsed = (CofaceAuthResponse)JSON.deserialize(res.getBody(), CofaceAuthResponse.class);
                // Copy parsed to out while preserving raw/statusCode
                out.idToken = parsed.idToken;
                out.accessToken = parsed.accessToken;
                out.refreshToken = parsed.refreshToken;
                out.expiresIn = parsed.expiresIn;
                out.tokenType = parsed.tokenType;

                // For demonstration: also "打印" each parameter by composing a human-readable message in JSON
                Map<String, Object> printable = new Map<String, Object>{ 'idToken' => out.idToken, 'accessToken' => out.accessToken, 'refreshToken' => out.refreshToken, 'expiresIn' => out.expiresIn, 'tokenType' => out.tokenType, 'statusCode' => out.statusCode };
                return JSON.serialize(printable);
            } else{
                // Attempt to parse error body, but return structured error
                out.error = 'Coface token request failed. HTTP ' + res.getStatus() + ' (' + res.getStatusCode() + ')';
                return JSON.serialize(out);
            }
        } catch (Exception ex){
            out.error = 'Exception during Coface token request: ' + ex.getMessage();
            return JSON.serialize(out);
        }
    }

    /**
     * @Param: 获取token接口返回的refreshToken
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-06 10:13:10
     * @Description: 刷新token方法
     */
    @AuraEnabled(cacheable = false)
    public static String refreshToken(String refreshToken){
        // Return early pattern
        CofaceAuthResponse out = new CofaceAuthResponse();
        CofaceConfig cfg = new CofaceConfig();

        // Build request body from configurable values
        CofaceAuthRequest reqBody = new CofaceAuthRequest();
        reqBody.grantType = cfg.refreshTokenGrantType;
        reqBody.refreshToken = refreshToken;

        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(cfg.baseUrl + cfg.tokenPath);
            req.setMethod('POST');
            req.setHeader('Content-Type', cfg.contentType);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);
            req.setBody(JSON.serialize(reqBody));

            Http http = new Http();
            HttpResponse res = http.send(req);

            out.statusCode = res.getStatusCode();
            out.raw = res.getBody();

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300){
                // Parse successful response
                CofaceAuthResponse parsed = (CofaceAuthResponse)JSON.deserialize(res.getBody(), CofaceAuthResponse.class);
                // Copy parsed to out while preserving raw/statusCode
                out.idToken = parsed.idToken;
                out.accessToken = parsed.accessToken;
                out.refreshToken = parsed.refreshToken;
                out.expiresIn = parsed.expiresIn;
                out.tokenType = parsed.tokenType;

                // For demonstration: also "打印" each parameter by composing a human-readable message in JSON
                Map<String, Object> printable = new Map<String, Object>{ 'idToken' => out.idToken, 'accessToken' => out.accessToken, 'refreshToken' => out.refreshToken, 'expiresIn' => out.expiresIn, 'tokenType' => out.tokenType, 'statusCode' => out.statusCode };
                return JSON.serialize(printable);
            } else{
                // Attempt to parse error body, but return structured error
                out.error = 'Coface token request failed. HTTP ' + res.getStatus() + ' (' + res.getStatusCode() + ')';
                return JSON.serialize(out);
            }
        } catch (Exception ex){
            out.error = 'Exception during Coface token request: ' + ex.getMessage();
            return JSON.serialize(out);
        }
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-06 14:47:24
     * @Description: 获取coface所有的国家，前端下拉框选择国家使用
     */
    @AuraEnabled(cacheable = true)
    public static List<CofaceCountryData> getCofaceCountry(){
        List<CofaceCountryData> cofaceCountryDataResult = new List<CofaceCountryData>();
        List<Coface_Country__c> cofaceCountryList = [SELECT Id, Name, Country_Name__c, Special__c, ISO_3__c
                                                     FROM Coface_Country__c
                                                     ORDER BY Country_Name__c];
        if (cofaceCountryList != null && cofaceCountryList.size() > 0){
            for (Coface_Country__c cofaceCountry : cofaceCountryList){
                CofaceCountryData cofaceCountryData = new CofaceCountryData();
                cofaceCountryData.label = cofaceCountry.Country_Name__c;
                cofaceCountryData.value = cofaceCountry.Name;
                cofaceCountryData.special = cofaceCountry.Special__c;
                cofaceCountryDataResult.add(cofaceCountryData);
            }
        }
        return cofaceCountryDataResult;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-16 09:46:01
     * @Description: 根据过滤条件查询公司信息
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> handleSearchCompanyByFilters(String idToken, String lastQueriedFilters){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        // 查询公司信息
        try{
            CofaceConfig cfg = new CofaceConfig();
            Map<String, Object> filetersMap = (Map<String, Object>)JSON.deserializeUntyped(lastQueriedFilters);
            List<String> searchUrlList = new List<String>();
            // 拼接url
            String requestUrl = cfg.dataAPIBaseUrl + '/companies';
            if (areStringAndObjectEqual('COMPANY_NAME', filetersMap.get('mode'))){
                requestUrl += '?countryCode=' + String.valueOf(filetersMap.get('country')) + '&companyName=' + String.valueOf(filetersMap.get('companyName')) + '&city=' + String.valueOf(filetersMap.get('city')) + '&postalCode=' + String.valueOf(filetersMap.get('postalCode'));
                searchUrlList.add(requestUrl);
            } else{
                // 按照识别号查询时，是否选择Legal id，选择Legal id则先查询有
                if (areStringAndObjectEqual('legalId', filetersMap.get('identifierType'))){
                    List<CofaceRepositoriesResponse> repositoriesList = handleSearchCompanyRepositories(idToken, String.valueOf(filetersMap.get('country')));
                    for (CofaceRepositoriesResponse crr : repositoriesList){
                        requestUrl = cfg.dataAPIBaseUrl + '/companies';
                        if (crr.isLegal){
                            requestUrl += '?countryCode=' + String.valueOf(filetersMap.get('country')) + '&externalId=' + crr.slug + '%23' + String.valueOf(filetersMap.get('identifierValue'));
                            searchUrlList.add(requestUrl);
                        }
                    }
                } else{
                    requestUrl += '?countryCode=' + String.valueOf(filetersMap.get('country')) + '&externalId=' + String.valueOf(filetersMap.get('identifierType')) + '%23' + String.valueOf(filetersMap.get('identifierValue'));
                    searchUrlList.add(requestUrl);
                }
            }
            // 遍历查询url，查询所有公司数据，由于查询唯一值，不存在多个参数接口返回数据叠加情况
            String responseBody = '';
            for (String reqUrl : searchUrlList){
                HttpRequest req = new HttpRequest();
                req.setEndpoint(reqUrl);
                req.setMethod('GET');
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    responseBody = res.getBody();
                    break;
                }
            }

            result.put('companyData', responseBody);
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-16 17:52:42
     * @Description: 根据国家编码查询ExternalIds哪些可用
     */
    public static List<CofaceRepositoriesResponse> handleSearchCompanyRepositories(String idToken, String countryCode){
        CofaceConfig cfg = new CofaceConfig();
        String requestUrl = cfg.dataAPIBaseUrl + '/companies/repositories?countryCode=' + countryCode;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setMethod('GET');
        req.setHeader('authorization', idToken);
        req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        List<CofaceRepositoriesResponse> responseBodyList = (List<CofaceRepositoriesResponse>)JSON.deserialize(responseBody, List<CofaceRepositoriesResponse>.class);
        return responseBodyList;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-19 11:18:29
     * @Description: 选中公司，查询report信息
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> searchReportDataByIconNumber(String idToken, String iconNumber, String countryCode){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        try{
            CofaceConfig cfg = new CofaceConfig();
            // 拼接url
            String requestUrl = cfg.dataAPIBaseUrl + '/companies/products?countryCode=' + countryCode + '&externalId=icon%23' + iconNumber;

            String responseBody = '';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                responseBody = res.getBody();
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取Report信息失败,请联系管理员!');
            }
            result.put('reportData', responseBody);
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-19 18:08:48
     * @Description: 查询公司详情
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> searchCompanyByIconNumber(String idToken, String iconNumber, String countryCode){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        // 查询公司信息
        try{
            CofaceConfig cfg = new CofaceConfig();
            // 拼接url
            String requestUrl = cfg.dataAPIBaseUrl + '/companies?countryCode=' + countryCode + '&externalId=icon%23' + iconNumber;

            String responseBody = '';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                responseBody = res.getBody();
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取公司信息失败,请联系管理员!');
            }
            result.put('companyInformation', responseBody);
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    // 比较object和string类型的是否相等
    public static Boolean areStringAndObjectEqual(String str, Object obj){
        if (str == null && obj == null)
            return true;
        if (str == null || obj == null)
            return false;
        return str.equals(String.valueOf(obj));
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-26 11:19:38
     * @Description: 查询历史订单，提醒是否可重复下单
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> checkHistoricalReportOrder(String iconNumber, String countryCode, String reportTypeSlug){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isHaveReport', false);
        result.put('isHaveMonitorable', false);
        // 查询coface订单数据表，是否存在对应类型的未完成监控订单，存在则不让再次下单
        List<Coface_Report__c> monitorableReport = [SELECT Id, Availability__c, Order_Date__c, Start_Date__c, End_Date__c, Monitorable__c
                                                    FROM Coface_Report__c
                                                    WHERE Coface_Company__r.Icon_Number__c = :iconNumber AND Coface_Company__r.Country_Code__c = :countryCode AND Report_Slug__c = :reportTypeSlug AND End_Date__c > :Date.today() AND Monitorable__c = true
                                                    ORDER BY End_Date__c DESC];
        if (monitorableReport != null && !monitorableReport.isEmpty()){
            result.put('isHaveReport', true);
            result.put('isHaveMonitorable', true);
            result.put('reportData', monitorableReport[0]);
        } else{
            List<Coface_Report__c> orderReport = [SELECT Id, Availability__c, Order_Date__c, Start_Date__c, End_Date__c, Monitorable__c
                                                  FROM Coface_Report__c
                                                  WHERE Coface_Company__r.Icon_Number__c = :iconNumber AND Coface_Company__r.Country_Code__c = :countryCode AND Report_Slug__c = :reportTypeSlug AND (Monitorable__c = false OR (Monitorable__c = true AND End_Date__c < :Date.today()))
                                                  ORDER BY Order_Date__c DESC];
            if (orderReport != null && !orderReport.isEmpty()){
                result.put('isHaveReport', true);
                result.put('reportData', orderReport[0]);
            }
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-20 18:09:14
     * @Description: 订购report
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> saveReportOrder(String idToken, String reportParam){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);

        // 解析 reportParam 参数
        Map<String, Object> reportParamMap = (Map<String, Object>)JSON.deserializeUntyped(reportParam);
        // 是否有监控服务
        Boolean monitorable = (Boolean) reportParamMap.get('isMonitorable');
        // iconNumber
        String iconNumber = (String) reportParamMap.get('iconNumber');
        // 是否是34个特殊国家
        Boolean countrySpecial = (String) reportParamMap.get('countrySpecial') == 'true';
        // 订单类型
        String reportTypeSlug = (String) reportParamMap.get('reportTypeSlug');
        String reportType = (String) reportParamMap.get('reportType');
        // 货币是否选择当地的,当地货币则传null
        Boolean isLocalCurrency = 'Local'.equals((String) reportParamMap.get('currencyValue'));
        // 选择语言
        String languageValue = (String) reportParamMap.get('languageValue');
        // 货币
        String currencyValue = (String) reportParamMap.get('currencyValue');
        // 即时报告或者调查报告
        String availabilityValue = (String) reportParamMap.get('availabilityValue');
        // 国家code
        String countryCode = (String) reportParamMap.get('country');
        // 国家名称
        String countryName = (String) reportParamMap.get('countryName');
        // 选择的公司信息
        Map<String, Object> companyMap = (Map<String, Object>)reportParamMap.get('selectItemOriginal');
        // 获取站点信息
        Site site = [SELECT Id
                     FROM Site
                     WHERE Name = 'Coface_Call_Back'
                     LIMIT 1];
        SiteDetail siteDetail = [SELECT SecureUrl
                                 FROM SiteDetail
                                 WHERE DurableId = :site.Id
                                 LIMIT 1];
        try{
            CofaceConfig cfg = new CofaceConfig();
            String requestUrl = cfg.dataAPIBaseUrl;
            List<CofaceOrderRequest> corList = new List<CofaceOrderRequest>();

            // 特殊国家分开下单
            if (countrySpecial && 'full-report'.equals(reportTypeSlug)){
                CofaceOrderReportRequest corr = new CofaceOrderReportRequest();
                corr.slug = reportTypeSlug;
                corr.language = languageValue;
                corr.format = new List<String>{ 'json' };
                corr.currencyIso = currencyValue;
                corr.investigationSpeedLevel = 'normal';
                // corr.proccessingTimeInstruction = 'immediate_if_available_inquiry_otherwise';
                corr.proccessingTimeInstruction = availabilityValue;
                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);

                CofaceOrderRequest cor = new CofaceOrderRequest();
                cor.externalId = 'icon#' + iconNumber;
                cor.countryCode = countryCode;
                cor.report = corr;
                cor.callbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/' + h;
                cor.notificationCallbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/notification/' + h;
                cor.key = h;

                CofaceOrderReportRequest corr1 = new CofaceOrderReportRequest();
                corr1.slug = reportTypeSlug;
                corr1.language = languageValue;
                corr1.format = new List<String>{ 'pdf' };
                corr1.currencyIso = currencyValue;
                corr1.investigationSpeedLevel = 'normal';
                // corr1.proccessingTimeInstruction = 'immediate_if_available_inquiry_otherwise';
                corr1.proccessingTimeInstruction = availabilityValue;

                // 生成唯一值
                Blob b1 = Crypto.GenerateAESKey(128);
                String h1 = EncodingUtil.ConvertTohex(b1);
                CofaceOrderRequest cor1 = new CofaceOrderRequest();
                cor1.externalId = 'icon#' + iconNumber;
                cor1.countryCode = countryCode;
                cor1.report = corr1;
                cor1.callbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/' + h1;
                cor1.notificationCallbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/notification/' + h1;
                cor1.key = h1;

                corList.add(cor);
                corList.add(cor1);
            } else{
                CofaceOrderReportRequest corr = new CofaceOrderReportRequest();
                corr.slug = reportTypeSlug;
                corr.language = languageValue;
                corr.format = new List<String>{ 'pdf', 'json' };
                corr.currencyIso = currencyValue;
                corr.investigationSpeedLevel = 'normal';
                // corr.proccessingTimeInstruction = 'immediate_if_available_inquiry_otherwise';
                corr.proccessingTimeInstruction = availabilityValue;
                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);

                CofaceOrderRequest cor = new CofaceOrderRequest();
                cor.externalId = 'icon#' + iconNumber;
                cor.countryCode = countryCode;
                cor.report = corr;
                cor.callbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/' + h;
                cor.notificationCallbackUrl = siteDetail.SecureUrl + '/services/apexrest/callback/notification/' + h;
                cor.key = h;

                corList.add(cor);
            }

            if (monitorable){
                requestUrl += '/monitorings/orders';
            } else{
                requestUrl += '/publications/orders';
            }
            for (CofaceOrderRequest cor : corList){
                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type', cfg.contentType);
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                // Build request body map to preserve API field names (including 'currency')
                Map<String, Object> reqMap = new Map<String, Object>{ 'externalId' => cor.externalId, 'countryCode' => cor.countryCode, 'callbackUrl' => cor.callbackUrl, 'notificationCallbackUrl' => cor.notificationCallbackUrl, 'report' => new Map<String, Object>{ 'slug' => cor.report != null ? cor.report.slug : null, 'language' => cor.report != null ? cor.report.language : null, 'format' => cor.report != null ? cor.report.format : null, 'proccessingTimeInstruction' => cor.report != null ? cor.report.proccessingTimeInstruction : null, 'investigationSpeedLevel' => cor.report != null ? cor.report.investigationSpeedLevel : null, 'currency' => isLocalCurrency ? null : cor.report.currencyIso } };
                req.setBody(JSON.serialize(reqMap));
                req.setTimeout(120000);
                system.debug('wwww----' + JSON.serialize(reqMap));
                Http http = new Http();
                String responseBody = '';
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    responseBody = res.getBody();
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                    // iconNumber唯一值，生成公司信息
                    Coface_Company__c cofaceCompany = new Coface_Company__c();
                    cofaceCompany.Icon_Number__c = iconNumber;
                    if (companyMap.get('address') != null){
                        Map<String, Object> addressMap = (Map<String, Object>)companyMap.get('address');
                        cofaceCompany.Address__c = addressMap.get('address1') != null ? (String) addressMap.get('address1') : '';
                        cofaceCompany.City__c = addressMap.get('city') != null ? (String) addressMap.get('city') : '';
                        cofaceCompany.Postal_Code__c = addressMap.get('postalCode') != null ? (String) addressMap.get('postalCode') : '';
                    }
                    if (companyMap.get('legalForm') != null){
                        Map<String, Object> legalFormMap = (Map<String, Object>)companyMap.get('legalForm');
                        cofaceCompany.Legal_Form__c = legalFormMap.get('label') != null ? (String) legalFormMap.get('label') : '';
                    }
                    String companyName = companyMap.get('name') != null ? (String) companyMap.get('name') : '';
                    cofaceCompany.Company_Name__c = companyName;
                    // 取公司名称80字符
                    cofaceCompany.Name = String.isNotBlank(companyName) ? companyName.length() > 80 ? companyName.substring(0, 80) : companyName : iconNumber;
                    cofaceCompany.International_Name__c = companyMap.get('internationalName') != null ? (String) companyMap.get('internationalName') : '';
                    cofaceCompany.Last_Major_Update__c = companyMap.get('lastMajorUpdate') != null ? (String) companyMap.get('lastMajorUpdate') : '';
                    cofaceCompany.Registration_Date__c = companyMap.get('registrationDate') != null ? (String) companyMap.get('registrationDate') : '';
                    cofaceCompany.Country__c = countryName;
                    cofaceCompany.Country_Code__c = countryCode;
                    cofaceCompany.Country_Special__c = countrySpecial;
                    // selectItemOriginal 是一个 Map，需要序列化为字符串再存储
                    Object selectItemOriginalObj = reportParamMap.get('selectItemOriginal');
                    if (selectItemOriginalObj != null){
                        try{
                            cofaceCompany.Company_Json__c = JSON.serialize(selectItemOriginalObj);
                        } catch (Exception e){
                            // 兜底：强转失败时存放 toString 结果
                            cofaceCompany.Company_Json__c = String.valueOf(selectItemOriginalObj);
                        }
                    } else{
                        cofaceCompany.Company_Json__c = null;
                    }

                    Database.upsert (cofaceCompany, Coface_Company__c.Fields.Icon_Number__c, true);
                    // 保存数据到数据库中
                    if (monitorable){
                        // 监控服务
                        Coface_Report__c cofaceReport = new Coface_Report__c();
                        cofaceReport.Coface_Company__c = cofaceCompany.Id;
                        if (!isLocalCurrency){
                            cofaceReport.CurrencyIsoCode = currencyValue;
                        }
                        cofaceReport.Report_Slug__c = reportTypeSlug;
                        cofaceReport.Report_Type__c = reportType;
                        cofaceReport.Language__c = languageValue;
                        cofaceReport.Country__c = countryName;
                        cofaceReport.Country_Code__c = countryCode;
                        cofaceReport.Country_Special__c = countrySpecial;
                        cofaceReport.Availability__c = availabilityValue;
                        cofaceReport.Is_SF_Created__c = true;
                        cofaceReport.Url_Id__c = cor.key;
                        cofaceReport.Call_Back_Url__c = cor.callbackUrl;
                        cofaceReport.Notification_Callback_Url__c = cor.notificationCallbackUrl;
                        cofaceReport.Document_Type__c = String.join(cor.report.format, ';');
                        cofaceReport.Report_Request__c = cofaceCompany.Company_Json__c;
                        cofaceReport.Monitorable__c = monitorable;
                        cofaceReport.Order_Date__c = (String) responseMap.get('orderDate');
                        cofaceReport.Report_Response__c = responseBody;

                        // Parse monitorings array safely and map dates/ids
                        List<Object> monitorings = (List<Object>)responseMap.get('monitorings');
                        if (monitorings != null && !monitorings.isEmpty()){
                            Map<String, Object> mon0 = (Map<String, Object>)monitorings[0];
                            String startDateStr = (String) mon0.get('startDate');     // e.g. '2026-03-20'
                            String endDateStr = (String) mon0.get('endDate');         // e.g. '2027-03-20'
                            String expectedDelivery = (String) mon0.get('expectedDeliveryDate');
                            String initialDeliveryId = (String) mon0.get('initialDeliveryId');
                            String orderReportId = (String) mon0.get('id');

                            // Convert YYYY-MM-DD to Date
                            if (String.isNotBlank(startDateStr)){
                                cofaceReport.Start_Date__c = Date.valueOf(startDateStr);
                            }
                            if (String.isNotBlank(endDateStr)){
                                cofaceReport.End_Date__c = Date.valueOf(endDateStr);
                            }
                            cofaceReport.Expected_Delivery_Date__c = expectedDelivery;
                            cofaceReport.Initial_Delivery_Id__c = initialDeliveryId;
                            cofaceReport.Order_Report_Id__c = orderReportId;
                            cofaceReport.Status__c = (String) mon0.get('status');
                        }
                        insert cofaceReport;
                    } else{
                        Coface_Report__c cofaceReport = new Coface_Report__c();
                        cofaceReport.Coface_Company__c = cofaceCompany.Id;
                        if (!isLocalCurrency){
                            cofaceReport.CurrencyIsoCode = currencyValue;
                        }
                        cofaceReport.Report_Slug__c = reportTypeSlug;
                        cofaceReport.Report_Type__c = reportType;
                        cofaceReport.Language__c = languageValue;
                        cofaceReport.Country__c = countryName;
                        cofaceReport.Country_Code__c = countryCode;
                        cofaceReport.Country_Special__c = countrySpecial;
                        cofaceReport.Availability__c = availabilityValue;
                        cofaceReport.Is_SF_Created__c = true;
                        cofaceReport.Url_Id__c = cor.key;
                        cofaceReport.Call_Back_Url__c = cor.callbackUrl;
                        cofaceReport.Notification_Callback_Url__c = cor.notificationCallbackUrl;
                        cofaceReport.Document_Type__c = String.join(cor.report.format, ';');
                        cofaceReport.Report_Request__c = cofaceCompany.Company_Json__c;
                        cofaceReport.Monitorable__c = monitorable;

                        // Publications flow fields
                        String orderDateIso = (String) responseMap.get('orderDate');
                        String overallExpected = (String) responseMap.get('deliveryDate');
                        String overallStatus = (String) responseMap.get('status');
                        String orderReportId = (String) responseMap.get('id');

                        cofaceReport.Order_Date__c = orderDateIso;
                        cofaceReport.Report_Response__c = responseBody;
                        cofaceReport.Order_Report_Id__c = orderReportId;
                        cofaceReport.Delivery_Date__c = overallExpected;

                        // publications array details
                        List<Object> publications = (List<Object>)responseMap.get('publications');
                        if (publications != null && !publications.isEmpty()){
                            Map<String, Object> pub0 = (Map<String, Object>)publications[0];
                            // expectedDeliveryDate and status at item level may override overall
                            String pubExpected = (String) pub0.get('expectedDeliveryDate');
                            String pubStatus = (String) pub0.get('status');
                            // Set details to object
                            cofaceReport.Expected_Delivery_Date__c = pubExpected;
                            cofaceReport.Status__c = String.isNotBlank(pubStatus) ? pubStatus : overallStatus;
                            // Use publication id as initial delivery id equivalent for non-monitorable
                            cofaceReport.Initial_Delivery_Id__c = (String) pub0.get('id');

                        }
                        insert cofaceReport;
                    }
                } else{
                    result.put('isSuccess', false);
                    result.put('message', Json.serialize(res.getBody()) + ' 订购失败,请联系管理员!');
                }
            }
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-23 11:07:59
     * @Description: 获取所有的监控订单
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> getAllMonitoringsReport(String idToken){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        System.Savepoint sp = null;
        try{
            CofaceConfig cfg = new CofaceConfig();
            // 拼接url
            String requestUrl = cfg.dataAPIBaseUrl + '/monitorings';
            String responseBody = '';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){

                responseBody = res.getBody();
                // 解析数据保存到数据库中
                List<MonitoringsReport> reportList = (List<MonitoringsReport>)JSON.deserialize(responseBody, List<MonitoringsReport>.class);
                if (reportList != null && !reportList.isEmpty()){
                    sp = Database.setSavepoint();
                    List<Coface_Report__c> addList = new List<Coface_Report__c>();
                    List<Coface_Company__c> cofaceCompanyList = new List<Coface_Company__c>();
                    // 解析数据获取iconNumber，匹配所有的公司信息
                    Set<String> iconNumberSet = new Set<String>();
                    for (MonitoringsReport report : reportList){
                        String iconNumber = report.externalId.substringAfter('icon#');
                        // 接口数据公司去重
                        if (!iconNumberSet.contains(iconNumber)){
                            Coface_Company__c cofaceCompany = new Coface_Company__c();
                            cofaceCompany.Icon_Number__c = iconNumber;
                            cofaceCompany.Country_Code__c = report.countryCode;
                            cofaceCompanyList.add(cofaceCompany);
                            iconNumberSet.add(iconNumber);
                        }
                    }
                    Database.upsert (cofaceCompanyList, Coface_Company__c.Fields.Icon_Number__c);

                    // 公司map集合，key：iconNumber
                    Map<String, SObject> cofaceCompanyMap = new LisqContainer(cofaceCompanyList).toMapS('Icon_Number__c');
                    for (MonitoringsReport report : reportList){
                        Coface_Report__c cofaceReport = new Coface_Report__c();
                        cofaceReport.Coface_Company__c = cofaceCompanyMap.get(report.externalId.substringAfter('icon#')).Id;
                        cofaceReport.Order_Report_Id__c = report.id;
                        cofaceReport.Company_Id__c = report.companyId;
                        cofaceReport.Initial_Delivery_Id__c = report.initialDeliveryId;
                        cofaceReport.Order_Date__c = report.orderDate;
                        cofaceReport.Start_Date__c = Date.valueOf(report.startDate);
                        cofaceReport.End_Date__c = Date.valueOf(report.endDate);
                        cofaceReport.Country_Code__c = report.countryCode;
                        cofaceReport.Report_Slug__c = report.reportSlug;
                        cofaceReport.Call_Back_Url__c = report.callbackUrl;
                        cofaceReport.Notification_Callback_Url__c = report.notificationCallbackUrl;
                        cofaceReport.Expected_Delivery_Date__c = report.expectedDeliveryDate;
                        cofaceReport.Language__c = report.language;
                        cofaceReport.Document_Type__c = 'json;pdf';
                        cofaceReport.Status__c = report.status;
                        cofaceReport.Channel_Delivery__c = report.channelDelivery;
                        cofaceReport.Backend_Order_Id__c = report.backendOrderId;
                        cofaceReport.Backend_Monit_Order_Id__c = report.backendMonitOrderId;
                        cofaceReport.Monitorable__c = true;

                        addList.add(cofaceReport);
                    }
                    Database.upsert (addList, Coface_Report__c.Fields.Order_Report_Id__c);
                }
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取所有监控订单信息失败,请联系管理员!');
            }
        } catch (Exception ex){
            Database.rollback(sp);
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-23 14:35:10
     * @Description: 获取所有非监控订单
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> getAllPublicationsReport(String idToken){
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        try{
            CofaceConfig cfg = new CofaceConfig();
            // 拼接url
            String requestUrl = cfg.dataAPIBaseUrl + '/publications/orders';
            String responseBody = '';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                List<Coface_Report__c> addList = new List<Coface_Report__c>();
                responseBody = res.getBody();
                // 解析数据保存到数据库中
                List<MonitoringsReport> reportList = (List<MonitoringsReport>)JSON.deserialize(responseBody, List<MonitoringsReport>.class);
                for (MonitoringsReport report : reportList){
                    if ('cancelled'.equals(report.status)){
                        continue;
                    }
                    Coface_Report__c cofaceReport = new Coface_Report__c();
                    cofaceReport.Order_Report_Id__c = report.id;
                    cofaceReport.Company_Id__c = report.companyId;
                    // cofaceReport.Icon_Number__c = report.externalId.substringAfter('icon#');
                    cofaceReport.Order_Date__c = report.orderDate;
                    cofaceReport.Status__c = report.status;
                    cofaceReport.Document_Type__c = 'json;pdf';
                    cofaceReport.Channel_Delivery__c = report.channelDelivery;
                    cofaceReport.Delivery_Date__c = report.deliveryDate;
                    cofaceReport.Monitorable__c = false;

                    List<Publications> publications = report.publications;
                    if (publications != null && !publications.isEmpty()){
                        Publications pub0 = publications[0];
                        cofaceReport.Initial_Delivery_Id__c = pub0.id;
                        cofaceReport.Language__c = pub0.language;
                        cofaceReport.Report_Slug__c = pub0.reportSlug;
                        cofaceReport.Backend_Order_Id__c = pub0.backendOrderId;
                        cofaceReport.Backend_Monit_Order_Id__c = pub0.backendMonitOrderId;
                        cofaceReport.Expected_Delivery_Date__c = pub0.expectedDeliveryDate;
                    }
                    addList.add(cofaceReport);
                }

                Database.upsert (addList, Coface_Report__c.Fields.Order_Report_Id__c);
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取所有非监控订单信息失败,请联系管理员!');
            }
            result.put('reportData', responseBody);
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-23 16:04:30
     * @Description: 获取订单数据
     */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> getOrderDataByReportId(String idToken, String reportId){
        System.debug('wwwww------获取订单数据getOrderDataByReportId');
        Map<String, Object> result = new Map<String, Object>();
        result.put('isSuccess', true);
        // idToken是否为空，为空则表示前端没有获取coface token，需重新获取
        if (String.isBlank(idToken)){
            // 调用token接口获取
            String tokenData = getCofaceToken();
            Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
            if (tokenMap.get('idToken') != null){
                idToken = String.valueOf(tokenMap.get('idToken'));
            } else{
                result.put('isSuccess', false);
                result.put('message', '获取token失败,请联系管理员!');
            }
        }
        try{
            CofaceConfig cfg = new CofaceConfig();
            // 查询订单是监控还是非监控
            Coface_Report__c cr = [SELECT Id, Monitorable__c, Order_Report_Id__c, Status__c
                                   FROM Coface_Report__c
                                   WHERE Id = :reportId
                                   LIMIT 1];
            // 订单可以下载标记
            Boolean flag = false;
            if (cr.Monitorable__c){
                // 拼接url
                String requestUrl = cfg.dataAPIBaseUrl + '/monitorings/' + cr.Order_Report_Id__c;
                String responseBody = '';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('GET');
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    responseBody = res.getBody();
                    // 解析数据保存到数据库中
                    MonitoringsReport report = (MonitoringsReport)JSON.deserialize(responseBody, MonitoringsReport.class);

                    if (!cr.Status__c.equals(report.status)){
                        if (String.isNotBlank(report.id))
                            cr.Order_Report_Id__c = report.id;
                        if (String.isNotBlank(report.initialDeliveryId))
                            cr.Initial_Delivery_Id__c = report.initialDeliveryId;
                        if (String.isNotBlank(report.orderDate))
                            cr.Order_Date__c = report.orderDate;
                        if (String.isNotBlank(report.startDate))
                            cr.Start_Date__c = Date.valueOf(report.startDate);
                        if (String.isNotBlank(report.endDate))
                            cr.End_Date__c = Date.valueOf(report.endDate);
                        if (String.isNotBlank(report.countryCode))
                            cr.Country_Code__c = report.countryCode;
                        if (String.isNotBlank(report.reportSlug))
                            cr.Report_Slug__c = report.reportSlug;
                        if (String.isNotBlank(report.callbackUrl))
                            cr.Call_Back_Url__c = report.callbackUrl;
                        if (String.isNotBlank(report.notificationCallbackUrl))
                            cr.Notification_Callback_Url__c = report.notificationCallbackUrl;
                        if (String.isNotBlank(report.expectedDeliveryDate))
                            cr.Expected_Delivery_Date__c = report.expectedDeliveryDate;
                        if (String.isNotBlank(report.language))
                            cr.Language__c = report.language;
                        if (String.isNotBlank(report.status))
                            cr.Status__c = report.status;
                        if (String.isNotBlank(report.channelDelivery))
                            cr.Channel_Delivery__c = report.channelDelivery;
                        if (String.isNotBlank(report.backendOrderId))
                            cr.Backend_Order_Id__c = report.backendOrderId;
                        if (String.isNotBlank(report.backendMonitOrderId))
                            cr.Backend_Monit_Order_Id__c = report.backendMonitOrderId;
                        cr.Monitorable__c = true;
                    }
                    if ('monitoring_active'.equals(report.status)){
                        flag = true;
                    }
                } else{
                    result.put('isSuccess', false);
                    result.put('message', '获取监控订单信息失败,请联系管理员!');
                }
            } else{
                // 拼接url
                String requestUrl = cfg.dataAPIBaseUrl + '/publications/orders?id=' + cr.Order_Report_Id__c;
                String responseBody = '';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('GET');
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    responseBody = res.getBody();
                    // 解析数据保存到数据库中
                    List<MonitoringsReport> reportList = (List<MonitoringsReport>)JSON.deserialize(responseBody, List<MonitoringsReport>.class);
                    if (reportList != null && !reportList.isEmpty()){
                        MonitoringsReport report = reportList[0];
                        if (!cr.Status__c.equals(report.status)){
                            if (String.isNotBlank(report.id))
                                cr.Order_Report_Id__c = report.id;
                            if (String.isNotBlank(report.companyId))
                                cr.Company_Id__c = report.companyId;
                            if (String.isNotBlank(report.orderDate))
                                cr.Order_Date__c = report.orderDate;
                            if (String.isNotBlank(report.status))
                                cr.Status__c = report.status;
                            if (String.isNotBlank(report.channelDelivery))
                                cr.Channel_Delivery__c = report.channelDelivery;
                            if (String.isNotBlank(report.deliveryDate))
                                cr.Delivery_Date__c = report.deliveryDate;
                            cr.Monitorable__c = false;

                            List<Publications> publications = report.publications;
                            if (publications != null && !publications.isEmpty()){
                                Publications pub0 = publications[0];
                                if (String.isNotBlank(pub0.id))
                                    cr.Initial_Delivery_Id__c = pub0.id;
                                if (String.isNotBlank(pub0.language))
                                    cr.Language__c = pub0.language;
                                if (String.isNotBlank(pub0.reportSlug))
                                    cr.Report_Slug__c = pub0.reportSlug;
                                if (String.isNotBlank(pub0.backendOrderId))
                                    cr.Backend_Order_Id__c = pub0.backendOrderId;
                                if (String.isNotBlank(pub0.backendMonitOrderId))
                                    cr.Backend_Monit_Order_Id__c = pub0.backendMonitOrderId;
                                if (String.isNotBlank(pub0.expectedDeliveryDate))
                                    cr.Expected_Delivery_Date__c = pub0.expectedDeliveryDate;
                            }
                        }
                        if ('ready'.equals(report.status)){
                            flag = true;
                        }
                    }
                } else{
                    result.put('isSuccess', false);
                    result.put('message', '获取非监控订单信息失败,请联系管理员!');
                }
            }
            Database.upsert (cr);
            if (flag){
                // 异步调用接口获取pdf和json数据
                System.enqueueJob(new CofaceDownloadPDFJob(reportId));
            }
        } catch (Exception ex){
            result.put('isSuccess', false);
            result.put('message', ex.getMessage());
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-23 16:38:40
     * @Description: 下载pdf数据
     */
    @future(callout = true)
    public static void downloadPDFByReportId(String reportId){
        System.debug('wwwww------下载pdf数据downloadPDFByReportId');
        // 调用token接口获取
        String tokenData = getCofaceToken();
        String idToken = '';
        Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
        if (tokenMap.get('idToken') != null){
            idToken = String.valueOf(tokenMap.get('idToken'));
            Coface_Report__c cr = [SELECT Id, Order_Report_Id__c, Initial_Delivery_Id__c, Coface_Company__r.Icon_Number__c
                                   FROM Coface_Report__c
                                   WHERE Id = :reportId
                                   LIMIT 1];
            try{
                CofaceConfig cfg = new CofaceConfig();
                // 拼接url
                String requestUrl = cfg.dataAPIBaseUrl + '/publications?id=' + cr.Initial_Delivery_Id__c + '&format=pdf';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('GET');
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    try{
                        // 仅保留最新 PDF：删除该记录上已有的 Coface_Report.pdf 文件
                        delectDocumentByRecordId(cr.Id, new List<String>{'PDF'});
                        // 保存文件并挂在 Coface_Report__c 记录上（仅最新）
                        Blob pdfContent = res.getBodyAsBlob();
                        String titel = 'Coface_Report_' + String.valueOf(Date.today());
                        String pathOnClient = 'Coface_Report_'+ String.valueOf(Date.today()) +'.pdf';
                        saveDocumentToRecord(pdfContent, titel, pathOnClient, cr.Id);
                    } catch (Exception fileEx){
                        // 可根据需要记录日志
                        System.debug('保存pdf数据 Error : ' + fileEx.getMessage() + fileEx.getLineNumber());
                    }
                }
            } catch (Exception ex){
                System.debug('下载pdf数据 Error : ' + ex.getMessage() + ex.getLineNumber());
            }
        }
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-23 16:44:05
     * @Description: 下载json数据
     */
    @future(callout = true)
    public static void downloadJsonByReportId(String reportId){
        System.debug('wwwww------下载json数据downloadJsonByReportId');
        // 调用token接口获取
        String tokenData = getCofaceToken();
        String idToken = '';
        Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
        if (tokenMap.get('idToken') != null){
            idToken = String.valueOf(tokenMap.get('idToken'));
            Coface_Report__c cr = [SELECT Id, Order_Report_Id__c, Initial_Delivery_Id__c, Coface_Company__r.Icon_Number__c
                                   FROM Coface_Report__c
                                   WHERE Id = :reportId
                                   LIMIT 1];
            try{
                CofaceConfig cfg = new CofaceConfig();
                // 拼接url
                String requestUrl = cfg.dataAPIBaseUrl + '/publications?id=' + cr.Initial_Delivery_Id__c + '&format=json';
                String responseBody = '';
                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('GET');
                req.setHeader('authorization', idToken);
                req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                req.setTimeout(120000);

                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                    responseBody = res.getBody();
                    try{
                        // 仅保留最新 JSON：删除该记录上已有的 Coface_Report.json 文件
                        delectDocumentByRecordId(cr.Id, new List<String>{'JSON'});
                        // 保存最新 JSON 为文件并挂在 Coface_Report__c 上
                        Blob jsonBlob = Blob.valueOf(responseBody);
                        String titel = 'Coface_Report_JSON_' +  String.valueOf(Date.today());
                        String pathOnClient = 'Coface_Report_JSON_' + String.valueOf(Date.today()) + '.json';
                        saveDocumentToRecord(jsonBlob, titel, pathOnClient, cr.Id);
                    } catch (Exception fileEx){
                        // 可根据需要记录日志
                    }
                }
            } catch (Exception ex){
                System.debug('下载json数据 Error : ' + ex.getMessage() + ex.getLineNumber());
            }
        }
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2026-03-27 17:01:00
     * @Description: 删除数据对应的文件，区分pdf和json
     */
    public static void delectDocumentByRecordId(String recordId, List<String> fileType){
        List<ContentDocumentLink> existingLinks = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title
                                                    FROM ContentDocumentLink
                                                    WHERE LinkedEntityId = :recordId AND ContentDocument.FileType IN :fileType];
        if (!existingLinks.isEmpty()){
            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink l : existingLinks){
                docIds.add(l.ContentDocumentId);
            }
            // 先删除链接
            Database.delete (existingLinks, AccessLevel.USER_MODE);
            // 再删除文档
            if (!docIds.isEmpty()){
                List<ContentDocument> docs = [SELECT Id
                                                FROM ContentDocument
                                                WHERE Id IN:docIds];
                if (!docs.isEmpty()){
                    Database.delete (docs, AccessLevel.USER_MODE);
                }
            }
        }
    }
    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2026-03-27 18:30:51
     * @Description: 保存文件
     */
    public static void saveDocumentToRecord(Blob dataBlob, String title, String pathOnClient, String recordId){
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.VersionData = dataBlob;
        cv.IsMajorVersion = true;
        Database.SaveResult sr = Database.insert (cv, AccessLevel.USER_MODE);
        if (sr.isSuccess()){
            Id contentVersionId = sr.getId();
            ContentVersion insertedCv = [SELECT ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :contentVersionId
                                            LIMIT 1];
            if (insertedCv != null && insertedCv.ContentDocumentId != null){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = insertedCv.ContentDocumentId;
                cdl.LinkedEntityId = recordId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                Database.insert (cdl, AccessLevel.USER_MODE);
            }
        }
    }

}