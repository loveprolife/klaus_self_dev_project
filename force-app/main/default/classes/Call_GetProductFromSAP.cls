/******************************************************************************
 ************************
 * Name: Call_GetProductFromSAP
 * Description: 获取SAP产品信息
 * TestClassName:  Call_GetProductFromSAPTest
 * Version History: 0.01
 * Date: 2024-11-15
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public without sharing class Call_GetProductFromSAP{
    
    private static String url = Interface_Url__c.getValues('正式oldSAP').Basic_Url__c + 'CC_REST_GET_MATERIAL_SENDER'; //URL 
    private static String user = Interface_Url__c.getValues('正式oldSAP').User_Name__c; //账号
    private static String password = Interface_Url__c.getValues('正式oldSAP').Password__c; //密码

    //请求参数
    public class ReqInfo {
        public String DATE_FROM; //开始日期
        public String DATE_TO; //结束日期
        public String ZCUSMODEL; //客户型号
        public List<String> VKORG; //销售组织
        public String VTWEG; //分销渠道
        public String SPART; //产品组
        public String ZBRAND; //品牌
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-15
     * @Description: 获取SAP产品信息，根据External_key__c进行upsert操作
     */
    @future(callout = true)
    public static void getProductFromSAPAll(String DATE_FROM, String DATE_TO, Integer index, Boolean allDateFlg, Boolean allHeFlg) {
        
        List<String> hisenseEntity = System.Label.GET_SAP_PRODUCT_HISENSE_ENTITY.split(',');

        List<String> VKORGS = new List<String>();
        if(index < hisenseEntity.size()){
            VKORGS.add(hisenseEntity[index]);
        }else{
            if(allDateFlg){

                if(isCurrentDate(DATE_TO)){
                    return;
                }

                // 当前时间N分钟，下一次定时时间
                DateTime reTime = System.Now().addSeconds(10);
                Integer second = reTime.second();
                Integer minute = reTime.minute();
                Integer hour = reTime.hour();  
                String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                System.schedule(h, con, new GetSapProductSchedulable(h, DATE_TO, incrementDateByOneDay(DATE_TO), 0, allDateFlg, allHeFlg));
                return;
            }else{
                return;
            }
        }
                
        //请求参数
        ReqInfo reqInfo = new ReqInfo();
        reqInfo.DATE_FROM = DATE_FROM;
        reqInfo.DATE_TO = DATE_TO;
        reqInfo.VKORG = VKORGS;
        String body = JSON.serialize(reqInfo);
        System.debug('body:: ' + body); 

        //返回参数
        String bodyRes;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds

            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response::: '+response);

            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            if(String.isNotBlank(bodyRes) && !bodyRes.equals('""')){

                list<Mapping__c> ppList = [select Id, Name from Mapping__c where RecordType.name = 'SAP Product Line and Product Line Mapping'];
                Map<String, Sobject> ppMap = new LisqContainer(ppList).toMapS('Name');

                list<Mapping__c> brandList = [select Id, Name from Mapping__c where RecordType.name = 'Brand Code and Name Mapping'];
                Map<String, Sobject> brandMap = new LisqContainer(brandList).toMapS('Name');

                //返回参数序列化
                Map<String, Object> resInfo = (Map<String, Object>) JSON.deserializeUntyped(bodyRes);

                if(resInfo != null && resInfo.get('MATERIALS') != null && ((List<Object>)resInfo.get('MATERIALS')).size() > 0){
                    
                    //产品集合
                    List<SAP_Product__c> upsertList = new List<SAP_Product__c>();
                    //物料集合
                    //List<MAKTX__c> upsertMAKTXList = new List<MAKTX__c>();

                    //Map<String, SAP_Product__c> extKeyMap = new Map<String, SAP_Product__c>();
                    
                    for(Object obj : (List<Object>)resInfo.get('MATERIALS')){
                        
                        Map<String, Object> sp = (Map<String, Object>) obj;

                        SAP_Product__c spc = new SAP_Product__c();
                        if(sp.get('ZCUSMODEL') != null && String.isNotBlank(String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0)))){
                            spc.ZCUSMODEL__c = String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0));
                            spc.Name = String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0));
                        }else{
                            continue;
                        }

                        try{
                            if(sp.get('SPART') != null){
                                spc.SPART__c = String.valueOf(((List<Object>)sp.get('SPART')).get(0));
                                spc.Product_Line__c = ppMap.get(spc.SPART__c).Id == null ? null : ppMap.get(spc.SPART__c).Id;
                            }
                        }catch(Exception e){}
                        try{
                            if(sp.get('ZBRAND') != null){
                                spc.ZBRAND__c = String.valueOf(((List<Object>)sp.get('ZBRAND')).get(0));
                                spc.Brand__c = brandMap.get(spc.ZBRAND__c).Id == null ? null : brandMap.get(spc.ZBRAND__c).Id;
                            }
                        }catch(Exception e){}
                        
                        spc.MATKL__c = String.valueOf(sp.get('MATKL'));
                        spc.ZMMDTYPE__c = String.valueOf(sp.get('ZMMDTYPE'));
                        spc.ZTYPEDSCEN__c = String.valueOf(sp.get('ZTYPEDSCEN'));
                        spc.LAENG__c = String.isBlank(String.valueOf(sp.get('LAENG'))) ? null : Decimal.valueOf(String.valueOf(sp.get('LAENG')));
                        spc.BREIT__c = String.isBlank(String.valueOf(sp.get('BREIT'))) ? null : Decimal.valueOf(String.valueOf(sp.get('BREIT')));
                        spc.HOEHE__c = String.isBlank(String.valueOf(sp.get('HOEHE'))) ? null : Decimal.valueOf(String.valueOf(sp.get('HOEHE')));
                        spc.MEABM__c = String.valueOf(sp.get('MEABM'));
                        spc.BRGEW__c = String.isBlank(String.valueOf(sp.get('BRGEW'))) ? null : Decimal.valueOf(String.valueOf(sp.get('BRGEW')));
                        spc.NTGEW__c = String.isBlank(String.valueOf(sp.get('NTGEW'))) ? null : Decimal.valueOf(String.valueOf(sp.get('NTGEW')));
                        spc.GEWEI__c = String.valueOf(sp.get('GEWEI'));
                        spc.VOLUM__c = String.isBlank(String.valueOf(sp.get('VOLUM'))) ? null : Decimal.valueOf(String.valueOf(sp.get('VOLUM')));
                        spc.VOLEH__c = String.valueOf(sp.get('VOLEH'));
                        spc.GROES__c = String.valueOf(sp.get('GROES'));
                        spc.EAN11__c = String.valueOf(sp.get('EAN11'));
                        spc.NUMTP__c = String.valueOf(sp.get('NUMTP'));
                        spc.ZPMTMODEL__c = String.valueOf(sp.get('ZPMTMODEL'));
                        spc.ZNJWJ__c = String.valueOf(sp.get('ZNJWJ'));
                        spc.ZZPRODH1__c = String.valueOf(sp.get('ZZPRODH1'));
                        spc.ZZPRODH2__c = String.valueOf(sp.get('ZZPRODH2'));
                        spc.ZZPRODH3__c = String.valueOf(sp.get('ZZPRODH3'));
                        spc.ZZPRODH4__c = String.valueOf(sp.get('ZZPRODH4'));
                        spc.ZZPRODH5__c = String.valueOf(sp.get('ZZPRODH5'));
                        spc.ZZPRODH6__c = String.valueOf(sp.get('ZZPRODH6'));
                        spc.GSBER__c = String.valueOf(sp.get('GSBER'));
                        spc.ZDATE__c = String.valueOf(sp.get('ZDATE'));
                        spc.Hisense_Entity__c = VKORGS[0];

                        spc.External_key__c = spc.ZCUSMODEL__c + '-' + spc.SPART__c + '-' + spc.ZBRAND__c;

                        //物料信息
                        // if(sp.get('MAKTX') != null){
                        //     List<Object> MAKTXList = (List<Object>)sp.get('MAKTX');
                        //     for(Object obje : MAKTXList){
                        //         Map<String, Object> m = (Map<String, Object>) obje;

                        //         MAKTX__c mc = new MAKTX__c();
                        //         mc.SPRAS__c = String.valueOf(m.get('SPRAS'));

                        //         if(m.get('VKORG') != null){
                        //             mc.VKORG__c = String.valueOf(((List<Object>)m.get('VKORG')).get(0));
                        //         }
                        //         mc.MAKTX__c = String.valueOf(m.get('MAKTX'));
                        //         mc.External_key__c =  mc.VKORG__c + spc.ZCUSMODEL__c + '-' + mc.MAKTX__c;
                        //         upsertMAKTXList.add(mc);

                        //         //设置产品外键
                        //         spc.External_key__c = mc.VKORG__c + spc.ZCUSMODEL__c;

                        //         extKeyMap.put(mc.External_key__c, spc);
                        //     }
                            
                        // }else{
                        //     spc.External_key__c = spc.ZCUSMODEL__c;
                        // }

                        upsertList.add(spc);
                    }

                    //更新插入产品
                    Database.upsert(upsertList,SAP_Product__c.Fields.External_key__c,false);

                    //Batch_SapProductCreate ss  = new Batch_SapProductCreate();
		            //Database.executeBatch(ss);
                    
                    // for(MAKTX__c m : upsertMAKTXList){
                    //     //设置物料关联字段
                    //     m.SAP_Product__c = extKeyMap.get(m.External_key__c).Id;
                    // }
                    // //更新插入物料
                    // Database.upsert(upsertMAKTXList,MAKTX__c.Fields.External_key__c,false);
                }
            }
            
            //插入Log
            Utility.insertLog('Call_GetProductFromSAP', '1', body, '');
        } catch(Exception e) {
            //插入Log
            Utility.insertLog('Call_GetProductFromSAP', '0', body, 'failure: SF Call_GetProductFromSAP Failed! ' + e.getMessage());
        }finally{
            if(allHeFlg){
                // 当前时间N分钟，下一次定时时间
                DateTime reTime = System.Now().addSeconds(10);
                Integer second = reTime.second();
                Integer minute = reTime.minute();
                Integer hour = reTime.hour();  
                String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                System.schedule(h, con, new GetSapProductSchedulable(h, DATE_FROM, DATE_TO, index + 1, allDateFlg, allHeFlg));
            }
        }
    }

    @future(callout = true)
    public static void getProductFromSAP(String DATE_FROM, String DATE_TO, List<String> VKORGS) {
        
        //请求参数
        ReqInfo reqInfo = new ReqInfo();
        reqInfo.DATE_FROM = DATE_FROM;
        reqInfo.DATE_TO = DATE_TO;
        reqInfo.VKORG = VKORGS;
        String body = JSON.serialize(reqInfo);
        System.debug('body:: ' + body); 

        //返回参数
        String bodyRes;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds

            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response::: '+response);

            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            if(String.isNotBlank(bodyRes) && !bodyRes.equals('""')){

                list<Mapping__c> ppList = [select Id, Name from Mapping__c where RecordType.name = 'SAP Product Line and Product Line Mapping'];
                Map<String, Sobject> ppMap = new LisqContainer(ppList).toMapS('Name');

                list<Mapping__c> brandList = [select Id, Name from Mapping__c where RecordType.name = 'Brand Code and Name Mapping'];
                Map<String, Sobject> brandMap = new LisqContainer(brandList).toMapS('Name');

                //返回参数序列化
                Map<String, Object> resInfo = (Map<String, Object>) JSON.deserializeUntyped(bodyRes);

                if(resInfo != null && resInfo.get('MATERIALS') != null && ((List<Object>)resInfo.get('MATERIALS')).size() > 0){
                    
                    //产品集合
                    List<SAP_Product__c> upsertList = new List<SAP_Product__c>();
                    //物料集合
                    //List<MAKTX__c> upsertMAKTXList = new List<MAKTX__c>();

                    //Map<String, SAP_Product__c> extKeyMap = new Map<String, SAP_Product__c>();
                    
                    for(Object obj : (List<Object>)resInfo.get('MATERIALS')){
                        
                        Map<String, Object> sp = (Map<String, Object>) obj;

                        SAP_Product__c spc = new SAP_Product__c();
                        if(sp.get('ZCUSMODEL') != null && String.isNotBlank(String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0)))){
                            spc.ZCUSMODEL__c = String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0));
                            spc.Name = String.valueOf(((List<Object>)sp.get('ZCUSMODEL')).get(0));
                        }else{
                            continue;
                        }

                        try{
                            if(sp.get('SPART') != null){
                                spc.SPART__c = String.valueOf(((List<Object>)sp.get('SPART')).get(0));
                                spc.Product_Line__c = ppMap.get(spc.SPART__c).Id == null ? null : ppMap.get(spc.SPART__c).Id;
                            }
                        }catch(Exception e){}
                        try{
                            if(sp.get('ZBRAND') != null){
                                spc.ZBRAND__c = String.valueOf(((List<Object>)sp.get('ZBRAND')).get(0));
                                spc.Brand__c = brandMap.get(spc.ZBRAND__c).Id == null ? null : brandMap.get(spc.ZBRAND__c).Id;
                            }
                        }catch(Exception e){}
                        
                        spc.MATKL__c = String.valueOf(sp.get('MATKL'));
                        spc.ZMMDTYPE__c = String.valueOf(sp.get('ZMMDTYPE'));
                        spc.ZTYPEDSCEN__c = String.valueOf(sp.get('ZTYPEDSCEN'));
                        spc.LAENG__c = String.isBlank(String.valueOf(sp.get('LAENG'))) ? null : Decimal.valueOf(String.valueOf(sp.get('LAENG')));
                        spc.BREIT__c = String.isBlank(String.valueOf(sp.get('BREIT'))) ? null : Decimal.valueOf(String.valueOf(sp.get('BREIT')));
                        spc.HOEHE__c = String.isBlank(String.valueOf(sp.get('HOEHE'))) ? null : Decimal.valueOf(String.valueOf(sp.get('HOEHE')));
                        spc.MEABM__c = String.valueOf(sp.get('MEABM'));
                        spc.BRGEW__c = String.isBlank(String.valueOf(sp.get('BRGEW'))) ? null : Decimal.valueOf(String.valueOf(sp.get('BRGEW')));
                        spc.NTGEW__c = String.isBlank(String.valueOf(sp.get('NTGEW'))) ? null : Decimal.valueOf(String.valueOf(sp.get('NTGEW')));
                        spc.GEWEI__c = String.valueOf(sp.get('GEWEI'));
                        spc.VOLUM__c = String.isBlank(String.valueOf(sp.get('VOLUM'))) ? null : Decimal.valueOf(String.valueOf(sp.get('VOLUM')));
                        spc.VOLEH__c = String.valueOf(sp.get('VOLEH'));
                        spc.GROES__c = String.valueOf(sp.get('GROES'));
                        spc.EAN11__c = String.valueOf(sp.get('EAN11'));
                        spc.NUMTP__c = String.valueOf(sp.get('NUMTP'));
                        spc.ZPMTMODEL__c = String.valueOf(sp.get('ZPMTMODEL'));
                        spc.ZNJWJ__c = String.valueOf(sp.get('ZNJWJ'));
                        spc.ZZPRODH1__c = String.valueOf(sp.get('ZZPRODH1'));
                        spc.ZZPRODH2__c = String.valueOf(sp.get('ZZPRODH2'));
                        spc.ZZPRODH3__c = String.valueOf(sp.get('ZZPRODH3'));
                        spc.ZZPRODH4__c = String.valueOf(sp.get('ZZPRODH4'));
                        spc.ZZPRODH5__c = String.valueOf(sp.get('ZZPRODH5'));
                        spc.ZZPRODH6__c = String.valueOf(sp.get('ZZPRODH6'));
                        spc.GSBER__c = String.valueOf(sp.get('GSBER'));
                        spc.ZDATE__c = String.valueOf(sp.get('ZDATE'));
                        spc.Hisense_Entity__c = VKORGS[0];

                        spc.External_key__c = spc.ZCUSMODEL__c + '-' + spc.SPART__c + '-' + spc.ZBRAND__c;

                        //物料信息
                        // if(sp.get('MAKTX') != null){
                        //     List<Object> MAKTXList = (List<Object>)sp.get('MAKTX');
                        //     for(Object obje : MAKTXList){
                        //         Map<String, Object> m = (Map<String, Object>) obje;

                        //         MAKTX__c mc = new MAKTX__c();
                        //         mc.SPRAS__c = String.valueOf(m.get('SPRAS'));

                        //         if(m.get('VKORG') != null){
                        //             mc.VKORG__c = String.valueOf(((List<Object>)m.get('VKORG')).get(0));
                        //         }
                        //         mc.MAKTX__c = String.valueOf(m.get('MAKTX'));
                        //         mc.External_key__c =  mc.VKORG__c + spc.ZCUSMODEL__c + '-' + mc.MAKTX__c;
                        //         upsertMAKTXList.add(mc);

                        //         //设置产品外键
                        //         spc.External_key__c = mc.VKORG__c + spc.ZCUSMODEL__c;

                        //         extKeyMap.put(mc.External_key__c, spc);
                        //     }
                            
                        // }else{
                        //     spc.External_key__c = spc.ZCUSMODEL__c;
                        // }

                        upsertList.add(spc);
                    }

                    //更新插入产品
                    Database.upsert(upsertList,SAP_Product__c.Fields.External_key__c,false);

                    //Batch_SapProductCreate ss  = new Batch_SapProductCreate();
		            //Database.executeBatch(ss);
                    
                    // for(MAKTX__c m : upsertMAKTXList){
                    //     //设置物料关联字段
                    //     m.SAP_Product__c = extKeyMap.get(m.External_key__c).Id;
                    // }
                    // //更新插入物料
                    // Database.upsert(upsertMAKTXList,MAKTX__c.Fields.External_key__c,false);
                }
            }
            
            //插入Log
            Utility.insertLog('Call_GetProductFromSAP', '1', body, '');
        } catch(Exception e) {
            //插入Log
            Utility.insertLog('Call_GetProductFromSAP', '0', body, 'failure: SF Call_GetProductFromSAP Failed! ' + e.getMessage());
        }
    }

    public static String incrementDateByOneDay(String dateStr) {
        // 将字符串转换为日期
        Date inputDate = Date.valueOf(dateStr.substring(0, 4) + '-' + dateStr.substring(4, 6) + '-' + dateStr.substring(6, 8));
        // 增加一天
        Date newDate = inputDate.addDays(1);
        // 将Date转换为DateTime以便使用format方法
        DateTime newDateTime = DateTime.newInstance(newDate.year(), newDate.month(), newDate.day());
        // 将新日期转换回字符串
        return newDateTime.format('yyyyMMdd');
    }

    public static Boolean isCurrentDate(String dateStr) {
        // 将字符串转换为日期
        Date inputDate = Date.valueOf(dateStr.substring(0, 4) + '-' + dateStr.substring(4, 6) + '-' + dateStr.substring(6, 8));
        // 获取当前日期
        Date currentDate = Date.today();
        // 比较两个日期
        return inputDate == currentDate;
    }
}