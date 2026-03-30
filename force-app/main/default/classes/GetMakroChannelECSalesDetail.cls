/**********************************************************************
* Name: APEX_南非Makro渠道电商销售明细-国际营销
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2024-05-07
*************************************************************************/
public without sharing class GetMakroChannelECSalesDetail {

    public class ResInfo {
        List<Map<String, String>> DATA;
    }

    public static void getAll(){

        // DeleteMakroChannelBatch ss  = new DeleteMakroChannelBatch('Makro_Channel_EC_Sales_Detail__c');
        // Database.executeBatch(ss);

        Datetime d = Datetime.valueOf('2024-01-01 08:00:00');      
        while (d < Date.today()) {
            GetMakroChannelECSalesDetail(d);
            d = d.addDays(7);
        }
    }

    @future(callout=true)
    public static void GetMakroChannelECSalesDetail(Datetime today) {

        Integer dayOfWeek = getDayOfWeek(today);
        Datetime startOfWeekDate = today.addDays(1-dayOfWeek);
        Datetime endOfWeekDate = today.addDays(7-dayOfWeek);

        String datatime = '&datatime=' + startOfWeekDate.format('dd.MM.yyyy') + 'to' + endOfWeekDate.format('dd.MM.yyyy');
        //datatime = '&datatime=26.02.2024to03.03.2024';

        String url = 'https://open-apisix.hisense.com/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_imec_makro_za_week_sale?app_id=kv1koest&app_key=rgozsfxy09emictvbfdtpumrngqnc6qd' + datatime;

        String appid = 'kv1koest';
        String secretKey = 'rgozsfxy09emictvbfdtpumrngqnc6qd';
        String message = 'GET\n'+
        '/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_imec_makro_za_week_sale\n'+
        'app_id='+appid+'&app_key=' + secretKey +datatime+'\n'+
        appid+'\n'+
        'Mon, 01 Apr 2024 03:55:01 GMT\n';

        String bodyRes;
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('GET');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
                GetMakroChannelECSalesDetail.ResInfo input_login = new GetMakroChannelECSalesDetail.ResInfo();
                input_login = (GetMakroChannelECSalesDetail.ResInfo) JSON.deserialize(bodyRes, GetMakroChannelECSalesDetail.ResInfo.class);

                System.debug('input_login '+input_login);

                List<Makro_Channel_EC_Sales_Detail__c> mciList = new List<Makro_Channel_EC_Sales_Detail__c>();

                for(Map<String, String> rd : input_login.DATA){

                    Makro_Channel_EC_Sales_Detail__c m = new Makro_Channel_EC_Sales_Detail__c();
                    m.billing_type__c = rd.get('billing_type');
                    m.billing_type_name__c = rd.get('billing_type_name');
                    m.group__c = rd.get('group_');
                    m.group_name__c = rd.get('group_name');
                    m.article__c = rd.get('article');
                    m.article_name__c = rd.get('article_name');
                    m.vendor_article_numbe__c = rd.get('vendor_article_numbe');
                    m.act_sales__c = rd.get('act_sales');
                    m.ly_sales__c = rd.get('ly_sales');
                    m.act_sales_qty_bu__c = rd.get('act_sales_qty_bu');
                    m.ly_sales_qty_bu__c = rd.get('ly_sales_qty_bu');
                    m.week__c = rd.get('week');
                    m.loaddt__c = rd.get('loaddt');
                    m.datatime__c = rd.get('datatime');
                    m.load_dt__c = rd.get('load_dt');
                    
                    mciList.add(m);
                }

                Database.upsert(mciList);
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetMakroChannelECSalesDetail', '0', '', 'failure: SF GetMakroChannelECSalesDetail Failed! ' + e.getMessage());
        }
    }

    public static String generateHmacSha256(String message, String secretKey){
        // 'GET\n'+
        // '/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_total_makro_za_week_dispo\n'+
        // 'app_id=vadyskme&app_key=8thzb2cugghhukjjgdnpuntyeflummbx&datatime=26.02.2024to03.03.2024\n'+
        // 'vadyskme\n'+
        // 'Mon, 01 Apr 2024 03:55:01 GMT\n';

        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        return EncodingUtil.base64Encode(mac);
    }

    public static Integer getDayOfWeek(Datetime dateItem) {
        Datetime datetimeItem = dateItem;
        return  Integer.valueOf(datetimeItem.format('u'));

    }
}