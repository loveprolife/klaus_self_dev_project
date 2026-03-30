/**********************************************************************
* Name: GetAUAvailableInventoryFromSAP
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2024-04-24
*************************************************************************/
public without sharing class GetAUAvailableInventoryFromSAP {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_Available_Inventory_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    public class ReqInfo {
        List<Map<String,String>> MATNRS = new List<Map<String,String>>();
        List<Map<String,String>> ZCUSMODELS = new List<Map<String,String>>();
        List<Map<String,String>> WERKSS = new List<Map<String,String>>();
        List<Map<String,String>> LGORTS = new List<Map<String,String>>();
        List<Map<String,String>> SPARTS = new List<Map<String,String>>();
    }

    public class ResDeta {
        String ean11;
        String zcusmodel;
        String lgort;
        String werks;
        String matnr;
        String charg;
        String ersda;
        String labst;
        String zkykc;
        String soqty;
        String dnqty;
        String brqty;
        String ubqty;
        String mtart;
    }

    public class ResInfo {
        List<ResDeta> itab;
    }

    @future(callout=true)
    public static void getAUAvailableInventoryFromSAP() {
        ReqInfo reqInfo = new ReqInfo();
        Map<String,String> dMap = new Map<String,String>();
        dMap.put('WERKS','8200');
        reqInfo.WERKSS.add(dMap);

        Map<String,String> sMap1 = new Map<String,String>();
        sMap1.put('SPART','61');
        reqInfo.SPARTS.add(sMap1);
        Map<String,String> sMap2 = new Map<String,String>();
        sMap2.put('SPART','66');
        reqInfo.SPARTS.add(sMap2);
        Map<String,String> sMap3 = new Map<String,String>();
        sMap3.put('SPART','67');
        reqInfo.SPARTS.add(sMap3);

        Map<String,String> lMap1 = new Map<String,String>();
        lMap1.put('LGORT','VC00');
        reqInfo.LGORTS.add(lMap1);
        Map<String,String> lMap2 = new Map<String,String>();
        lMap2.put('LGORT','NC00');
        reqInfo.LGORTS.add(lMap2);
        Map<String,String> lMap3 = new Map<String,String>();
        lMap3.put('LGORT','WC00');
        reqInfo.LGORTS.add(lMap3);
        Map<String,String> lMap4 = new Map<String,String>();
        lMap4.put('LGORT','QC00');
        reqInfo.LGORTS.add(lMap4);

        String body = JSON.serialize(reqInfo);
        System.debug('body:: ' + body); 

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
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
                GetAUAvailableInventoryFromSAP.ResInfo input_login = new GetAUAvailableInventoryFromSAP.ResInfo();
                input_login = (GetAUAvailableInventoryFromSAP.ResInfo) JSON.deserialize(bodyRes, GetAUAvailableInventoryFromSAP.ResInfo.class);
                System.debug('input_login '+input_login);

                List<Product_Available_Inventory__c> paiList = new List<Product_Available_Inventory__c>();
                Set<String> modelSet = new Set<String>();
                Map<String, Product_Available_Inventory__c> paiMap = new Map<String, Product_Available_Inventory__c>();

                List<Product_Available_Inventory__c> paiAll = [select id,name,zkykc__c,lgort__c from Product_Available_Inventory__c where WERKS__c = '8200'];

                for(Product_Available_Inventory__c p : paiAll){
                    p.zkykc__c = 0;
                    p.lgort__c = '';
                    paiMap.put(p.name,p);
                }

                for(ResDeta rd : input_login.itab){

                    if(paiMap.containsKey(rd.zcusmodel)){
                        paiMap.get(rd.zcusmodel).zkykc__c = paiMap.get(rd.zcusmodel).zkykc__c + Integer.valueOf(rd.zkykc);

                        String oldL = paiMap.get(rd.zcusmodel).lgort__c;
                        String newL = rd.lgort;
                        if(!oldL.contains(newL)){
                            if(oldL == ''){
                                paiMap.get(rd.zcusmodel).lgort__c = newL;
                            }else{
                                paiMap.get(rd.zcusmodel).lgort__c = oldL + ',' + newL;
                            }
                            
                        }
                    }else{
                        Product_Available_Inventory__c pai = new Product_Available_Inventory__c();
                        pai.name = rd.zcusmodel;
                        pai.ean11__c = rd.ean11;
                        pai.zcusmodel__c = rd.zcusmodel;
                        pai.lgort__c = rd.lgort;
                        pai.werks__c = rd.werks;
                        pai.matnr__c = rd.matnr;
                        pai.charg__c = rd.charg;
                        pai.ersda__c = Date.valueOf(rd.ersda);
                        pai.labst__c = Integer.valueOf(rd.labst);
                        pai.zkykc__c = Integer.valueOf(rd.zkykc);
                        pai.soqty__c = Integer.valueOf(rd.soqty);
                        pai.dnqty__c = Integer.valueOf(rd.dnqty);
                        pai.brqty__c = Decimal.valueOf(rd.brqty);
                        pai.ubqty__c = Decimal.valueOf(rd.ubqty);
                        pai.mtart__c = rd.mtart;
                        paiMap.put(rd.zcusmodel,pai);
                    }
                }

                for(Product_Available_Inventory__c pai : paiMap.values()){
                    paiList.add(pai);
                }

                // List<Product_Available_Inventory__c> delList = [select id from Product_Available_Inventory__c];
                // Database.delete(delList);

                Database.upsert(paiList);
            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('GetAUAvailableInventoryFromSAP', '0', body, 'failure: SF GetAUAvailableInventoryFromSAP Failed! ' + e.getMessage() + '-------' + bodyRes);
        }
    }
}