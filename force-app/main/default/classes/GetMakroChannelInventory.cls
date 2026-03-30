/**********************************************************************
* Name: APEX_南非Makro渠道库存明细-国际营销
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2024-05-07
*************************************************************************/
public without sharing class GetMakroChannelInventory {

    public class ResDeta {
        String vendor;
        String vendor_name;
        String vendor_prod_code;
        String p_term;
        String future_promo;
        String seq_no;
        String article;
        String none1;
        String article_desc;
        String barcode;
        String bmc;
        String bmc_description;
        String pbc;
        String order_unit;
        String week_l4;
        String week_l3;
        String week_l2;
        String week_l1;
        String week_current;
        String week_n1;
        String week_ly;
        String curr_ys;

        //String class;
    }

    public class ResDeta1{
        String uom;
        String compo;
        String site;
        String site_name;
        String status;
        String rp;
        String soh;
        String soo;
        String sit;
        String pr_qty;
        String mac;
        String stock_margin;
        String list_price;
        String net_cost;
        String end_date;
        String product_margin;
        String planned_margin;
        String incl_sp;
        String so_qty;
        String atp;
        String dist_prof;
        String week;
        String loaddt;
        String datatime;
        String load_dt;
    }

    public class ResInfo1 {
        List<ResDeta1> DATA;
    }
    public class ResInfo {
        List<ResDeta> DATA;
    }

    public static void getAll(){

        // DeleteMakroChannelBatch ss  = new DeleteMakroChannelBatch('Makro_Channel_Inventory__c');
        // Database.executeBatch(ss);

        Datetime d = Datetime.valueOf('2024-01-01 08:00:00');      
        while (d < Date.today()) {
            GetMakroChannelInventory(d);
            d = d.addDays(7);
        }
    }

    @future(callout=true)
    public static void GetMakroChannelInventory(Datetime today) {

        Integer dayOfWeek = getDayOfWeek(today);
        Datetime startOfWeekDate = today.addDays(1-dayOfWeek);
        Datetime endOfWeekDate = today.addDays(7-dayOfWeek);
        String datatime = '&datatime=' + startOfWeekDate.format('dd.MM.yyyy') + 'to' + endOfWeekDate.format('dd.MM.yyyy');
        //datatime = '&datatime=26.02.2024to03.03.2024';

        String url = 'https://open-apisix.hisense.com/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_total_makro_za_week_dispo?app_id=up4rxclo&app_key=wue4bt6cvjyo4kguyvw51ijdeuzgawwb' + datatime;

        String appid = 'up4rxclo';
        String secretKey = 'wue4bt6cvjyo4kguyvw51ijdeuzgawwb';
        String message = 'GET\n'+
        '/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_total_makro_za_week_dispo\n'+
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
                GetMakroChannelInventory.ResInfo input_login = new GetMakroChannelInventory.ResInfo();
                input_login = (GetMakroChannelInventory.ResInfo) JSON.deserialize(bodyRes, GetMakroChannelInventory.ResInfo.class);

                GetMakroChannelInventory.ResInfo1 input_login1 = new GetMakroChannelInventory.ResInfo1();
                input_login1 = (GetMakroChannelInventory.ResInfo1) JSON.deserialize(bodyRes, GetMakroChannelInventory.ResInfo1.class);

                System.debug('input_login '+input_login);
                System.debug('input_login1 '+input_login1);

                List<Makro_Channel_Inventory__c> mciList = new List<Makro_Channel_Inventory__c>();

                if(input_login.DATA != null && input_login.DATA.size() > 0){
                    for(Integer i = 0; i < input_login.DATA.size(); i++){

                        ResDeta rd = input_login.DATA.get(i);

                        Makro_Channel_Inventory__c m = new Makro_Channel_Inventory__c();
                        m.vendor__c = rd.vendor;
                        m.vendor_name__c = rd.vendor_name;
                        m.vendor_prod_code__c = rd.vendor_prod_code;
                        m.p_term__c = rd.p_term;
                        m.future_promo__c = rd.future_promo;
                        m.seq_no__c = rd.seq_no;
                        m.article__c = rd.article;
                        m.none1__c = rd.none1;
                        m.article_desc__c = rd.article_desc;
                        m.barcode__c = rd.barcode;
                        m.bmc__c = rd.bmc;
                        m.bmc_description__c = rd.bmc_description;
                        m.pbc__c = rd.pbc;
                        m.order_unit__c = rd.order_unit;
                        m.week_l4__c = rd.week_l4;
                        m.week_l3__c = rd.week_l3;
                        m.week_l2__c = rd.week_l2;
                        m.week_l1__c = rd.week_l1;
                        m.week_current__c = rd.week_current;
                        m.week_n1__c = rd.week_n1;
                        m.week_ly__c = rd.week_ly;
                        m.curr_ys__c = rd.curr_ys;
                        
                        ResDeta1 rd1 = input_login1.DATA.get(i);
                        m.uom__c = rd1.uom;
                        m.compo__c = rd1.compo;
                        m.site__c = rd1.site;
                        m.site_name__c = rd1.site_name;
                        m.status__c = rd1.status;
                        m.rp__c = rd1.rp;
                        m.soh__c = rd1.soh;
                        m.soo__c = rd1.soo;
                        m.sit__c = rd1.sit;
                        m.pr_qty__c = rd1.pr_qty;
                        m.mac__c = rd1.mac;
                        m.stock_margin__c = rd1.stock_margin;
                        m.list_price__c = rd1.list_price;
                        m.net_cost__c = rd1.net_cost;
                        m.end_date__c = rd1.end_date;
                        m.product_margin__c = rd1.product_margin;
                        m.planned_margin__c = rd1.planned_margin;
                        m.incl_sp__c = rd1.incl_sp;
                        m.so_qty__c = rd1.so_qty;
                        m.atp__c = rd1.atp;
                        m.dist_prof__c = rd1.dist_prof;
                        m.week__c = rd1.week;
                        m.loaddt__c = rd1.loaddt;
                        m.datatime__c = rd1.datatime;
                        m.load_dt__c = rd1.load_dt;
        
                        mciList.add(m);
                    }
                }

                Database.upsert(mciList);
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetMakroChannelInventory', '0', '', 'failure: SF GetMakroChannelInventory Failed! ' + e.getMessage());
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