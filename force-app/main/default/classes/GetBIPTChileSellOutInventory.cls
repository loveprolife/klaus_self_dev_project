/**********************************************************************
* Name: BIPT_智利sell out和库存数据表
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2024-05-07
*************************************************************************/
public without sharing class GetBIPTChileSellOutInventory {

    public class ResDeta {
        String create_mnth;
        String create_yr;
        String create_week;
        String create_dt;
        String cust_name;
        String cust_no;
        String brand;
        String onln_offln;
        String store_name;
        String store_no;
        String sub;
        String channel_model;
        String cust_model;
        String fac_model;
        String export_model;
        String prdln;
        String sub_prdln;
        String sz;
        String sgmt;
        String act_amt_usd;
        String act_amt_rmb;
        String act_amt_lcc;
        String act_qty;
        String data_source;
        String load_dt;
        String tar_amt_usd;
        String tar_amt_rmb;
        String tar_amt_lcc;
        String tar_qty;
        String dsource;
        String act_price_lcc;
        String act_price_usd;
        String act_price_rmb;
        String tot_soh;
        String avl_soh;
        String stock_on_order;
        String tot_soh_usd;
        String tot_soh_rmb;
        String tot_soh_lcc;
        String avl_soh_usd;
        String avl_soh_rmb;
        String avl_soh_lcc;
        String ch_store_name;
        String ch_store_no;
        String curr;
        String st_intr;
    }

    public class ResInfo {
        List<ResDeta> DATA;
    }

    @future(callout=true)
    public static void GetBIPTChileSellOutInventory(String today1) {


        String datatime = '&create_dt=' + today1;

        String url = 'https://open-apisix.hisense.com/apex/ords/edw_apex/hs/dwfi_im_tf_sellout_amt_detail?app_id=tsphzxmm&app_key=zvhjdoocr0cyock937sgdonz6m4xt3nv' + datatime;

        String appid = 'tsphzxmm';
        String secretKey = 'zvhjdoocr0cyock937sgdonz6m4xt3nv';
        String message = 'GET\n'+
        '/apex/ords/edw_apex/hs/dwfi_im_tf_sellout_amt_detail\n'+
        'app_id='+appid+'&app_key=' + secretKey +datatime+'\n'+
        appid+'\n'+
        'Mon, 01 Apr 2024 03:55:01 GMT\n';

        String bodyRes;
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
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
                GetBIPTChileSellOutInventory.ResInfo input_login = new GetBIPTChileSellOutInventory.ResInfo();
                input_login = (GetBIPTChileSellOutInventory.ResInfo) JSON.deserialize(bodyRes, GetBIPTChileSellOutInventory.ResInfo.class);

                System.debug('input_login '+input_login);

                List<BIPT_Chile_sell_out_Inventory__c> mciList = new List<BIPT_Chile_sell_out_Inventory__c>();

                if(input_login.DATA != null && input_login.DATA.size() > 0){
                    for(Integer i = 0; i < input_login.DATA.size(); i++){

                        ResDeta rd = input_login.DATA.get(i);

                        if('0'.equals(rd.act_amt_usd) && '0'.equals(rd.act_amt_rmb) && '0'.equals(rd.act_amt_lcc) && '0'.equals(rd.act_qty) && '0'.equals(rd.tot_soh)){
                            continue;
                        }

                        BIPT_Chile_sell_out_Inventory__c m = new BIPT_Chile_sell_out_Inventory__c();
                        m.create_yr__c = rd.create_yr;
                        m.act_amt_rmb__c = rd.act_amt_rmb;
                        m.act_amt_usd__c = rd.act_amt_usd;
                        m.sgmt__c = rd.sgmt;
                        m.sz__c = rd.sz;
                        m.sub_prdln__c = rd.sub_prdln;
                        m.prdln__c = rd.prdln;
                        m.export_model__c = rd.export_model;
                        m.fac_model__c = rd.fac_model;
                        m.cust_model__c = rd.cust_model;
                        m.channel_model__c = rd.channel_model;
                        m.sub__c = rd.sub;
                        m.store_no__c = rd.store_no;
                        m.store_name__c = rd.store_name;
                        m.onln_offln__c = rd.onln_offln;
                        m.brand__c = rd.brand;
                        m.cust_no__c = rd.cust_no;
                        m.cust_name__c = rd.cust_name;
                        m.create_week__c = rd.create_week;
                        m.create_dt__c = rd.create_dt;
                        m.create_mnth__c = rd.create_mnth;
                        m.st_intr__c = rd.st_intr;
                        m.curr__c = rd.curr;
                        m.ch_store_no__c = rd.ch_store_no;
                        m.ch_store_name__c = rd.ch_store_name;
                        m.avl_soh_lcc__c = rd.avl_soh_lcc;
                        m.avl_soh_rmb__c = rd.avl_soh_rmb;
                        m.avl_soh_usd__c = rd.avl_soh_usd;
                        m.tot_soh_lcc__c = rd.tot_soh_lcc;
                        m.tot_soh_rmb__c = rd.tot_soh_rmb;
                        m.tot_soh_usd__c = rd.tot_soh_usd;
                        m.stock_on_order__c = rd.stock_on_order;
                        m.avl_soh__c = rd.avl_soh;
                        m.tot_soh__c = rd.tot_soh;
                        m.act_price_rmb__c = rd.act_price_rmb;
                        m.act_price_usd__c = rd.act_price_usd;
                        m.act_price_lcc__c = rd.act_price_lcc;
                        m.dsource__c = rd.dsource;
                        m.tar_qty__c = rd.tar_qty;
                        m.tar_amt_lcc__c = rd.tar_amt_lcc;
                        m.tar_amt_rmb__c = rd.tar_amt_rmb;
                        m.tar_amt_usd__c = rd.tar_amt_usd;
                        m.load_dt__c = rd.load_dt;
                        m.data_source__c = rd.data_source;
                        m.act_qty__c = rd.act_qty;
                        m.act_amt_lcc__c = rd.act_amt_lcc;
                        m.create_dt_date__c = Date.valueOf(rd.create_dt.substring(0,10));
                        
                        mciList.add(m);
                    }
                }

                list<BIPT_Chile_sell_out_Inventory__c> dl = [select id from BIPT_Chile_sell_out_Inventory__c where create_dt__c = :today1];
                Database.delete(dl);
                Database.upsert(mciList);
                Utility.insertLog('GetBIPTChileSellOutInventory', '1', today1, '');
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetBIPTChileSellOutInventory', '0', '', 'failure: SF GetBIPTChileSellOutInventory Failed! ' + e.getMessage());
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
}