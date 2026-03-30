public without sharing class BulkApi {

    private static String url = Interface_Url__c.getValues('BulkApi').Basic_Url__c;

    public class OutPut1{
        public String id;
        public String operation;
        // public String object;
        public String createdById;
        public String createdDate;
        public String systemModstamp;
        public String state;
        public String concurrencyMode;
        public String contentType;
        public String apiVersion;
        public String contentUrl;
        public String lineEnding;
        public String columnDelimiter;
    }

    // public static void bulkApiTest(Blob fileUploadBody){
        @Future(callout=true)
        public static void bulkApiTest(String erdat){
        try{  
            Date erdatNew = Date.parse(erdat);
            String year1 = erdatNew.year() + '';
            String month1 = erdatNew.month() < 10 ? 0+''+erdatNew.month() : erdatNew.month() + '';
            String day1 = erdatNew.day() < 10 ? 0 +''+erdatNew.day() : erdatNew.day() + '';
            erdat = year1 + month1 + day1;
            // 远程调用获取csv数据
            //String url = 'https://open-gw.hisense.com:443/apex/ords/edw_apex/sf/odss810_zhd_zgrt14?user_key=50f64716821be158f8c7fe7e45efa711';
            url = url + '&erdat=' + erdat;
            HttpRequest reqFile = new HttpRequest();
            HttpResponse resFile = new HttpResponse();
            Http http = new Http();              
            reqFile.setMethod('GET');
            // reqFile.setEndpoint('https://open-gw.hisense.com:443/apex/ords/edw_apex/sf/odss810_zhd_zgrt14?erdat=20211101&aedat=20211102&user_key=50f64716821be158f8c7fe7e45efa711');
            reqFile.setEndpoint(url);
            reqFile.setTimeout(120000); // timeout in milliseconds
            resFile = http.send(reqFile);
            String resStr;
            if(resFile.getStatusCode() == 200){
                resStr = resFile.getBody();
            }else {
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'bulkApiTest';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = url;
                ic.Res_Json__c = resFile.getStatus();
                ic.ErrorMsg__c = '调用大数据接口失败！';
                insert ic;
                return;
            }
            String baseURL = 'https://hisenseint.my.salesforce.com/';//URL.getSalesforceBaseUrl().toExternalForm()
            string RESOURCE_URI = 'services/data/v53.0/jobs/ingest';
        
            // 第一步
            String endpoint = baseURL + RESOURCE_URI;   
            //"externalIdFieldName" : "vbeln__c"     
            String reqBody ='{"operation" : "insert", "object" : "ZGRT14Report__c", "contentType" : "CSV","lineEnding" : "LF"}';//CRLF LF
            HttpRequest req = new HttpRequest();  
            req.setMethod('POST');
            req.setEndpoint(endpoint);   
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setBody(reqBody); 
            
            Http httpReq = new Http();  
            HTTPResponse res = new HttpResponse();
       
            res = httpReq.send(req);   
            OutPut1 outPut1 = new OutPut1();
            outPut1 = (BulkApi.OutPut1) JSON.deserialize(res.getBody(), BulkApi.OutPut1.class);

            //第二步 添加数据
            String jobPoint = baseURL + outPut1.contentUrl;
            HttpRequest req2 = new HttpRequest();  
            req2.setMethod('PUT');
            req2.setEndpoint(jobPoint);   
            req2.setHeader('Content-Type', 'text/csv');
            req2.setHeader('Accept', 'application/json');
            req2.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
           
            //文件第一行添加sf字段
            // Integer num = 224;
            // String str = '';
            // for(Integer i = 1 ; i <= num ; i++){
            //     str += 'field' + i + '__c,';
            // }
            // str = str.substring(0, str.length() - 1);
            // str += '\n';

            String str = 'Interface_Date__c,mandt__c,vkorg__c,vbeln__c,posnr__c,pdate__c,aedat__c,zvkburt__c,zvkgrpt__c,belnr__c,gjahr__c,fkart__c,rfbsk__c,fksto__c,sfakn__c,xblnr__c,kunag__c,name1__c,land1__c,kunrg__c,name_kunrg__c,matnr__c,maktx__c,zcusmodel__c,zfacmodel__c,zmodel__c,ean11__c,charg__c,zbranddesc__c,ztype__c,spartext__c,zspec__c,znjwj__c,lgortxt__c,fkimg__c,waerk__c,kpein__c,kbetr__c,kbetr_bwb__c,zs84__c,zxszj__c,netwr__c,zxszj_bwb__c,zs99__c,ztjyf__c,ztjsxf__c,ztjcj__c,zs21__c,zs22__c,erdat_dn__c,erdat__c,wadat_ist__c,fkdat__c,zdqr__c,aubel__c,auart__c,vgbel__c,bstkd__c,bstkd_e__c,bezei1__c,bezei2__c,zterm__c,vtext__c,ywms__c,augru_txt__c,kwert_wl__c,kwert_we__c,mwsk1__c,mwsbp__c,zhszj__c,kunnr__c,name_dl__c,zyj__c,zyjzd__c,zyjsg__c,zfl__c,zfl_kwert__c,zflzd__c,zflsg__c,zs12__c,kwert_it__c,kbetr_it__c,kwert_itzd__c,kwert_itsg__c,zjtfl__c,zjtflzd__c,zjtflsg__c,zwlzc__c,zwlzcsg__c,zwlzczd__c,zndfl__c,zndflsg__c,zndflzd__c,zjdfl__c,zjdflsg__c,zjdflzd__c,zxsjl__c,zxsjlzd__c,zxsjlsg__c,kwert_wlfl__c,kwert_wlfzf__c,kwert_wezf__c,kraus__c,klimk__c,dbrtg__c,kunnr_sdf__c,name_sdf__c,sort1__c,land_sdf__c,regio__c,ort01__c,pstlz__c,ntgew__c,gewei__c,volum__c,voleh__c,remark__c,swift__c,kwert_zs31__c,kwert_zs32__c,kwert_zs33__c,kwert_zs27__c,kwert_zs28__c,kwert_zs29__c,kwert_zs30__c,kwert_zs19__c,kwert_zs19_sg__c,kwert_zs19_zd__c,kwert_zs20__c,kwert_zgrd__c,kwert_zs41__c,kwert_zs55__c,kwert_zs56__c,kunnr_dlxsj__c,name1_dlxsj__c,kwert_zs40__c,str_sdf__c,vdatu__c,werks__c,kurrf__c,kmprs__c,kdmat__c,kwert_zs43__c,kwert_zs44__c,kwert_it_45__c,kwert_itzd_45__c,kwert_itsg_45__c,kwert_itsg_46__c,kwert_it_47__c,kwert_itzd_47__c,kwert_itsg_47__c,kwert_it_48__c,kwert_itzd_48__c,kwert_itsg_48__c,sort2__c,kwert_bqs__c,kwert_ljs__c,zd03__c,inco1__c,inco2__c,kunag_s__c,kunag_r__c,zuonr__c,matkl__c,wgbez__c,zcpdl__c,ddtext__c,zs13__c,zs36__c,zs36_kwert__c,zs40__c,zs40_hb__c,zs49__c,invno__c,bstdk__c,u_cost__c,t_cost__c,zjshj__c,zkpdj__c,zs62__c,zs60__c,zs60_t__c,z014__c,z005__c,zs59__c,kzwi1__c,sales_type__c,zs52__c,zs61__c,kwert_yj__c,zsc5__c,zs38__c,zs38_kwert__c,zow1__c,zsc2__c,zs09__c,zs09_zd__c,zs09_sg__c,vbeln_sub__c,kwert_it_46__c,zsource__c,zsourcedesc__c,zs63__c,zs66__c,promotionno__c,kunnr_re__c,name_re__c,wavwr__c,zmle__c,zmll__c,policy_type__c,zcrm04p__c,s_manager__c,c_group3__c,c_group4__c,pltyp_desc__c,zs15__c,zs16__c,zs17__c,zzprodh1__c,zzprodh2__c,zzprodh3__c,zzprodh4__c,zzprodh5__c,load_dt__c';
            str += '\n';
            str += resStr;

            req2.setBodyAsBlob(Blob.valueOf(str));
            Http httpReq2 = new Http();  
            HTTPResponse res2 = new HttpResponse();

            res2 = httpReq2.send(req2);   

            //第三步 开始工作
            String startPoint = baseURL + RESOURCE_URI + '/' + outPut1.id;

            HttpRequest req3 = new HttpRequest();  
            req3.setMethod('PATCH');
            req3.setEndpoint(startPoint);   
            req3.setHeader('Content-Type', 'application/json');
            req3.setHeader('Accept', 'application/json');
            req3.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req3.setBody('{"state" : "UploadComplete"}'); 
            Http httpReq3 = new Http();  
            HTTPResponse res3 = new HttpResponse();

            res3 = httpReq3.send(req3);   

            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'bulkApiTest';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = url;
            insert ic;
        }catch(System.CalloutException e) {

        }

    }       


    // public transient Blob fileUploadBody{get;set;}

    // public String fileUploadName{get;set;}

    // public void uploadFile() {
    //     Boolean needInsert = false;
    //     if(fileUploadBody != null && fileUploadBody.size() > 0) {
    //         needInsert = true;
    //     }

    //     if(needInsert) {
    //         try {
    //             // bulkApiTest(fileUploadBody);
    //             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'上传成功'));
    //         } catch(DmlException e) {
    //             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'上传失败'));
    //         }
    //     } else {
    //         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,'无上传内容'));
    //     }
    // }


    // public static String bitToString(Blob input, String inCharset){
    //     //转换成16进制
    //     String hex = EncodingUtil.convertToHex(input);
    //     //一个String类型两个字节 32位（bit）,则一个String长度应该为两个16进制的长度，所以此处向右平移一个单位，即除以2
    //     //向右平移一个单位在正数情况下等同于除以2，负数情况下不等
    //     //eg 9  00001001  >>1 00000100   结果为4
    //     final Integer bytesCount = hex.length() >> 1;
    //     //声明String数组，长度为16进制转换成字符串的长度
    //     String[] bytes = new String[bytesCount];
    //     for(Integer i = 0; i < bytesCount; ++i) {
    //         //将相邻两位的16进制字符串放在一个String中
    //         bytes[i] =  hex.mid(i << 1, 2);
    //     }
    //     //解码成指定charset的字符串
    //     return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    // }
}