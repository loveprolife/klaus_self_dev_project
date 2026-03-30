/**********************************************************************
* Name: BIPT_sell out和库存数据表
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2024-07-30
*************************************************************************/
public without sharing class GetSellOutInventory {

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
        //String fac_model;
        //String export_model;
        String prdln;
        String sub_prdln;
        String sz;
        String sgmt;
        Integer act_amt_usd;
        Integer act_amt_rmb;
        Integer act_amt_lcc;
        Integer act_qty;
        String data_source;
        //String load_dt;
        // String tar_amt_usd;
        // String tar_amt_rmb;
        // String tar_amt_lcc;
        // String tar_qty;
        // String dsource;
        // String act_price_lcc;
        // String act_price_usd;
        // String act_price_rmb;
        Integer tot_soh;
        Integer avl_soh;
        Integer stock_on_order;
        // String tot_soh_usd;
        // String tot_soh_rmb;
        // String tot_soh_lcc;
        // String avl_soh_usd;
        // String avl_soh_rmb;
        // String avl_soh_lcc;
        String ch_store_name;
        String ch_store_no;
        String curr;
        Integer st_intr;
        String ean_code;
        //String rnum;
    }

    public class ResInfo {
        List<ResDeta> DATA;
    }

    @future(callout=true)
    public static void GetSellOutInventory(String startdate, String enddate, Integer row_count, Integer row_offset, Boolean today, String data_source, String sub) {
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
            
            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){

                GetSellOutInventory.ResInfo input_login = new GetSellOutInventory.ResInfo();

                input_login = (GetSellOutInventory.ResInfo) JSON.deserialize(bodyRes, GetSellOutInventory.ResInfo.class);

                System.debug('input_login '+input_login);

                
                insertData(input_login.DATA);
                Utility.insertLog('GetSellOutInventory', '1', startdate + '---' + enddate, '');

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
                    System.schedule(h, con, new GetSellOutInventorySchedulable(h, startdate, row_count, row_offset + row_count, today, data_source, sub));
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
                        System.schedule(h, con, new GetSellOutInventorySchedulable(h, String.valueOf(s.addDays(1)).substring(0,10).replace('-', ''), row_count, 0, today, data_source, sub));
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
                        System.schedule(h, con, new SetActQtyBatchSchedulable(h));
                    }
                }
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetSellOutInventory', '0', '', startdate + 'failure: SF GetSellOutInventory Failed! ' + e.getMessage());

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
                System.schedule(h, con, new GetSellOutInventorySchedulable(h, startdate, row_count, row_offset, today, data_source, sub));
            }
        }

        System.debug('wwww---- 1'+ System.now());
    }

    public static void insertData(List<ResDeta> data){
        List<Sell_out_Inventory__c> mciList = new List<Sell_out_Inventory__c>();
        if(data != null && data.size() > 0){
            
            List<Shop__c> storeList = [select id, Store_No_from_Account__c from Shop__c];
            Map<Integer, String> storeMap = new Map<Integer, String>();
            for(Shop__c store : storeList){
                if(String.isNotBlank(store.Store_No_from_Account__c)){
                    storeMap.put(Integer.valueOf(store.Store_No_from_Account__c), store.id);
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

                
                Sell_out_Inventory__c m = new Sell_out_Inventory__c();

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
                //m.rnum__c = rd.rnum;

                if(String.isNotBlank(m.ch_store_no__c)){
                    if(String.isNotBlank(storeMap.get(Integer.valueOf(m.ch_store_no__c)))){
                        m.Store__c = storeMap.get(Integer.valueOf(m.ch_store_no__c));
                    }
                }

                m.ch_store_name__c = rd.ch_store_name;
                m.stock_on_order__c = rd.stock_on_order;
                m.ean_code__c = rd.ean_code;
                
                mciList.add(m);

            }
        }
        // list<Sell_out_Inventory__c> dl = [select id from Sell_out_Inventory__c where create_dt__c = :deleteStrDate];
        // Database.delete(dl);
        Database.upsert(mciList);
        
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

    // public static void readTextAndInsert(String deleteStrDate){

    //     List<GetSellOutInventory.ResDeta> taskList = new List<GetSellOutInventory.ResDeta>();

    //     String fieldName = '%BIPT' + deleteStrDate + '%';
    //     List<ContentVersion> d = [select id, Title, VersionData, ContentDocumentId from ContentVersion where Title like :fieldName order by Title];
        
    //     if(d != null && d.size() > 1){
    //         String s = '';
    //         ContentVersion dd = d[0];

    //         String str = dd.VersionData.toString();
    //         Integer startNum = str.indexOf('{');

    //         if(startNum != -1 && startNum != 0){
    //             s += str.substring(0, startNum);
    //         }

    //         if(d.size() > 2){
    //             Integer endNum = str.lastIndexOf('},') + 1;
    //             s += str.substring(endNum + 1, str.length());
    //             str = str.substring(startNum, endNum);
    //         }else{
    //             str = str.substring(startNum, str.length());
    //         }


    //         taskList = (List<GetSellOutInventory.ResDeta>)JSON.deserialize('[' + str + ']', List<GetSellOutInventory.ResDeta>.class);
    //         //insertData(taskList, deleteStrDate);

    //         ContentDocument cc = new ContentDocument();
    //         cc.id = dd.ContentDocumentId;
    //         delete cc;

    //         ContentVersion zz = d.get(d.size() - 1);
    //         s = zz.VersionData.toString() + s;

    //         ContentDocument cc1 = new ContentDocument();
    //         cc1.id = zz.ContentDocumentId;
    //         delete cc1;

    //         ContentVersion cvjoin = new ContentVersion(
    //             Title = 'BIPT' + deleteStrDate + 'ZZZ',
    //             PathOnClient = 'BIPT' + deleteStrDate + 'ZZZ' + '.txt',
    //             VersionData = Blob.valueOf(s),
    //             IsMajorVersion = true
    //         );
    //         insert cvjoin;

            
    //     }else if(d != null && d.size() == 1){
    //         ContentVersion zz = d.get(0);
    //         String s = zz.VersionData.toString();

    //         taskList = (List<GetSellOutInventory.ResDeta>)JSON.deserialize(s.substring(0, s.length() - 1) + ']', List<GetSellOutInventory.ResDeta>.class);
    //         //insertData(taskList, deleteStrDate);

    //         ContentDocument cc = new ContentDocument();
    //         cc.id = zz.ContentDocumentId;
    //         delete cc;
    //     }else{
    //         //stop
    //         return;
    //     }

    //     // 当前时间N分钟，下一次定时时间
    //     DateTime reTime = System.Now().addSeconds(5);
    //     Integer second = reTime.second();
    //     Integer minute = reTime.minute();
    //     Integer hour = reTime.hour();  
    //     String con = second + ' ' + minute + ' ' + hour + ' * * ?';

    //     // 生成唯一值
    //     Blob b = Crypto.GenerateAESKey(128);
    //     String h = EncodingUtil.ConvertTohex(b) + 'read';
    //     //System.schedule(h, con, new InsertSellOutInventoryFileSchedulable(h, deleteStrDate));
        
    // }
 
    // public static void saveText(String bodyRes, String deleteStrDate){
       
    //     Integer num = bodyRes.length();
    //     Integer temp = num / 1000000;
    //     List<String> charList = new List<String>{
    //         'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    //     };
    //     for(Integer i = 0 ; i < temp ; i++ ){
    //         String aa;
    //         if(i == 0){
    //             aa = bodyRes.substring(i * 1000000 + 9, i * 1000000 + 1000000 );
    //         }else {
    //             aa = bodyRes.substring(i * 1000000, i * 1000000 + 1000000 );
    //         }
                
    //         Blob b = Blob.valueOf(aa);
    //         ContentVersion cv = new ContentVersion(
    //             Title = 'BIPT' + deleteStrDate + charList[i],
    //             PathOnClient = 'BIPT' + deleteStrDate + i + '.txt',
    //             VersionData = b,
    //             IsMajorVersion = true
    //         );
    //         insert cv;
    //     }
    //     if(num > temp * 1000000){
    //         String aa = bodyRes.substring(temp * 1000000, num - 2);
    //         Blob b = Blob.valueOf(aa);
    //         ContentVersion cv = new ContentVersion(
    //             Title = 'BIPT' + deleteStrDate + charList[temp],
    //             PathOnClient = 'BIPT' + deleteStrDate + temp + '.txt',
    //             VersionData = b,
    //             IsMajorVersion = true
    //         );
    //         insert cv;
    //     }

    //     ContentVersion cvjoin = new ContentVersion(
    //         Title = 'BIPT' + deleteStrDate + 'ZZZ',
    //         PathOnClient = 'BIPT' + deleteStrDate + 'ZZZ' + '.txt',
    //         VersionData = Blob.valueOf('['),
    //         IsMajorVersion = true
    //     );
    //     insert cvjoin;
    // }
}