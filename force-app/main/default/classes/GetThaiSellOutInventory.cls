public with sharing class GetThaiSellOutInventory {

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
        String prdln;
        String sub_prdln;
        String sz;
        String sgmt;
        String act_amt_usd;
        String act_amt_rmb;
        String act_amt_lcc;
        String act_qty;
        String data_source;
        String tot_soh;
        String avl_soh;
        String stock_on_order;
        String ch_store_name;
        String ch_store_no;
        String curr;
        String st_intr;
        String ean_code;
        String rnum;
    }

    public class ResInfo {
        List<ResDeta> DATA;
    }

    @future(callout=true) //用于泰国取数 data_source = 'RPA' sub = 'D002010'
    public static void GetThaiSellOutInventory(String startdate, String enddate, Integer row_count, Integer row_offset, Boolean today, String data_source, String sub) {
        System.debug('wwww---- '+ System.now());
        String datatime = '&data_source=' + data_source + '&enddate='+enddate+'&row_count='+row_count+'&row_offset='+row_offset+'&startdate='+startdate + '&sub=' + sub;

        String url = 'https://open-apisix.hisense.com/apex/ords/edw_apex/hs/dwfi_im_tf_1_sellout_amt_detail?app_id=y2yzpbne&app_key=rfypfo25xnectugyzuciq7bxpxinyimt' + datatime;

        String appid = 'y2yzpbne';
        String secretKey = 'rfypfo25xnectugyzuciq7bxpxinyimt';
        String message = 'GET\n'+
        '/apex/ords/edw_apex/hs/dwfi_im_tf_1_sellout_amt_detail\n'+
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
            System.debug('bodyRes:' + bodyRes.length());
            // System.debug('bodyResDetail:' + bodyRes.toString());

            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){

                GetThaiSellOutInventory.ResInfo input_login = new GetThaiSellOutInventory.ResInfo();

                input_login = (GetThaiSellOutInventory.ResInfo) JSON.deserialize(bodyRes, GetThaiSellOutInventory.ResInfo.class);

                System.debug('input_login '+input_login.DATA.size());
            
                insertData(input_login.DATA);
                Utility.insertLog('GetThaiSellOutInventory', '1', startdate + '---' + enddate, '');

                if(input_login.DATA != null && input_login.DATA.size() > 0){
                    // 当前时间N分钟，下一次定时时间
                    DateTime reTime = System.Now().addSeconds(5);
                    Integer second = reTime.second();
                    Integer minute = reTime.minute();
                    Integer hour = reTime.hour();  
                    String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                    // 生成唯一值
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    System.debug('第一个条件定时参数:' + h + '定时参数:' + startdate + '定时参数:' + row_count + '定时参数:' +  row_offset  + '定时参数:' +  row_count + '定时参数:' +  today + '定时参数:' +  data_source + '定时参数:' +  sub);
                    System.schedule(h, con, new GetThaiSellOutInventorySchedulable(h, startdate, row_count, row_offset + row_count, today, data_source, sub));
                }else{
                    
                    Date s = Date.valueOf(startdate.substring(0,4) + '-' + startdate.substring(4,6) + '-' + startdate.substring(6,8));
                    if(s < System.today() && !today){
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(5);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.debug('第二个条件定时参数:' + h + '定时参数:' + con + '定时参数:' + String.valueOf(s.addDays(1)).substring(0,10).replace('-', '') + '定时参数:' + row_count + '定时参数:' +  0  + '定时参数:' +  today + '定时参数:' +  data_source + '定时参数:' +  sub);

                        System.schedule(h, con, new GetThaiSellOutInventorySchedulable(h, String.valueOf(s.addDays(1)).substring(0,10).replace('-', ''), row_count, 0, today, data_source, sub));
                    }else{
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(30);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.debug('第三个条件定时参数:' + h + '定时参数:' + con);

                        System.schedule(h, con, new SetThaiActQtyBatchSchedulable(h));
                    }
                }
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetThaiSellOutInventory', '0', '', startdate + 'failure: SF GetThaiSellOutInventory Failed! ' + e.getMessage());

            if('Premature EOF'.equals(e.getMessage())){
                // 当前时间N分钟，下一次定时时间
                DateTime reTime = System.Now().addSeconds(5);
                Integer second = reTime.second();
                Integer minute = reTime.minute();
                Integer hour = reTime.hour();  
                String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                System.debug('报错时定时参数:' + h + '定时参数:' + startdate + '定时参数:' + row_count + '定时参数:' +  row_offset  + '定时参数:' +  row_count + '定时参数:' +  today + '定时参数:' +  data_source + '定时参数:' +  sub);
                System.schedule(h, con, new GetThaiSellOutInventorySchedulable(h, startdate, row_count, row_offset, today, data_source, sub));
            }
        }

        System.debug('wwww---- 1'+ System.now());
    }

    public static void insertData(List<ResDeta> data){
        List<Thai_Sell_out_Inventory__c> mciList = new List<Thai_Sell_out_Inventory__c>();
        if(data != null && data.size() > 0){
            
            List<Shop__c> storeList = [select id, Store_No_from_Account__c from Shop__c];
            Map<String, String> storeMap = new Map<String, String>();
            for(Shop__c store : storeList){
                if(String.isNotBlank(store.Store_No_from_Account__c)){
                    storeMap.put(store.Store_No_from_Account__c, store.id);
                }
            }

            List<Channel_item__c> ciList = [select id, Channel_Name__c from Channel_item__c];
            Map<String, String> ciMap = new Map<String, String>();
            for(Channel_item__c ci : ciList){
                if(String.isNotBlank(ci.Channel_Name__c)){
                    ciMap.put(ci.Channel_Name__c, ci.id);
                }
            }
            
            for(Integer i = 0; i < data.size(); i++){

                
                Thai_Sell_out_Inventory__c m = new Thai_Sell_out_Inventory__c();

                ResDeta rd = data.get(i);

                m.create_mnth__c = rd.create_mnth;
                m.create_yr__c = rd.create_yr;
                m.create_week__c = rd.create_week;
                m.create_dt__c = rd.create_dt;
                m.create_dt_date__c = Date.valueOf(rd.create_dt.substring(0,10));
                m.cust_name__c = rd.cust_name;
                if(String.isNotBlank(m.cust_name__c)){
                    if(String.isNotBlank(ciMap.get(m.cust_name__c))){
                        m.Channel_item__c = ciMap.get(m.cust_name__c);
                    }
                }

                m.cust_no__c = rd.cust_no;
                m.brand__c = rd.brand;
                m.onln_offln__c = rd.onln_offln;
                m.store_name__c = rd.store_name;
                m.store_no__c = rd.store_no;
                m.sub__c = rd.sub;
                m.channel_model__c = rd.channel_model;
                m.cust_model__c = rd.cust_model;
                m.prdln__c = rd.prdln;
                m.act_amt_rmb__c = rd.act_amt_rmb;
                m.act_amt_usd__c = rd.act_amt_usd;
                m.sgmt__c = rd.sgmt;
                m.sz__c = rd.sz;
                m.sub_prdln__c = rd.sub_prdln;
                m.act_amt_lcc__c = rd.act_amt_lcc;
                m.act_qty__c = rd.act_qty;
                m.data_source__c = rd.data_source;
                m.tot_soh__c = rd.tot_soh;
                m.avl_soh__c = rd.avl_soh;
                m.st_intr__c = rd.st_intr;
                m.curr__c = rd.curr;
                m.ch_store_no__c = rd.ch_store_no;
                m.rnum__c = rd.rnum;

                if(String.isNotBlank(m.ch_store_no__c)){
                    if(String.isNotBlank(storeMap.get(m.ch_store_no__c))){
                        m.Store__c = storeMap.get(m.ch_store_no__c);
                    }
                }

                m.ch_store_name__c = rd.ch_store_name;
                m.stock_on_order__c = rd.stock_on_order;
                m.ean_code__c = rd.ean_code;
                
                mciList.add(m);

            }
        }
        Database.upsert(mciList);
        
    }

    public static String generateHmacSha256(String message, String secretKey){
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        System.debug('SHA256' + EncodingUtil.base64Encode(mac));
        return EncodingUtil.base64Encode(mac);
    }
}