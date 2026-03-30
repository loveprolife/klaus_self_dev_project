/**********************************************************************
 * function:get product relation from GSS system
 * @author:Roy
 * @url: /services/apexrest/rest
 * @data: ProMapInfo
 * date:2019-03-20
*************************************************************************/
@RestResource(urlMapping='/getProductMappingFromGSS')
global with sharing class GetProductMappingFromGSS {
    global class AppInput{
        // global String InterfaceName;
        global List<ProMapInfo> ProductMappingList;

        global AppInput() {
            // this.InterfaceName = '';
            this.ProductMappingList = new List<ProMapInfo>();
        }
    }
    
    global class AppOutPut{
        global String FailReason;
        global String IsSuccess;
    }
    global class ProMapInfo{
        public String CustomerModel;
        public String FactoryModel;
        public String Country;
        public String ProductLine;
        public String Brand;
        public String ExportModel;
        public String GSSSalesRegion;
    }

    @HttpPost
    global static GetProductMappingFromGSS.AppOutPut adoPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring();
        //String reqBody = '{"ProductMappingList":[{"CustomerModel":"32L5865","FactoryModel":"HX32A5610HWTS","Country":"俄罗斯联邦","ProductLine":"TV","brand":"TOSHIBA","ExportModel":"HX32A5610HWTS","GSSSalesRegion":"俄罗斯分公司"},{"CustomerModel":"43L5865","FactoryModel":"HX43A5610FWTS","Country":"俄罗斯联邦","ProductLine":"TV","brand":"TOSHIBA","ExportModel":"HX43A5610FWTS","GSSSalesRegion":"俄罗斯分公司"},{"CustomerModel":"43U5865","FactoryModel":"HX43A6126UWTS","Country":"俄罗斯联邦","ProductLine":"TV","brand":"TOSHIBA","ExportModel":"HX43A6126UWTS","GSSSalesRegion":"俄罗斯分公司"},{"CustomerModel":"50U5865","FactoryModel":"HX50A6126UWTS","Country":"俄罗斯联邦","ProductLine":"TV","brand":"TOSHIBA","ExportModel":"HX50A6126UWTS","GSSSalesRegion":"俄罗斯分公司"},{"CustomerModel":"55U5865","FactoryModel":"HX55A6126UWTS","Country":"俄罗斯联邦","ProductLine":"TV","brand":"TOSHIBA","ExportModel":"HX55A6126UWTS","GSSSalesRegion":"俄罗斯分公司"},{"CustomerModel":"HF-N91SA+","FactoryModel":"BC-92/HC4(EAE5)","Country":"罗马尼亚","ProductLine":"Refrigerator ","brand":"HEINNER","ExportModel":"RS-12DR4SUA/CPA1-008","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"HS43N1810UWB(1501)t","FactoryModel":"HS43N1810UWB(1501)","Country":"厄瓜多尔","ProductLine":"TV","brand":"GLOBAL","ExportModel":"HS43N1810UWB(1501)","GSSSalesRegion":"电视大客户部"},{"CustomerModel":"HS50N1810UWB(1501)","FactoryModel":"HS50N1810UWB(1501)","Country":"厄瓜多尔","ProductLine":"TV","brand":"GLOBAL","ExportModel":"HS50N1810UWB(1501)","GSSSalesRegion":"电视大客户部"},{"CustomerModel":"KCV3143WIT","FactoryModel":"BCD-171/HC4(EAU4)KCGZ","Country":"荷兰","ProductLine":"Refrigerator ","brand":"ETNA","ExportModel":"RD-23DC4SCA/CPA2-007","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"KF 1205-90","FactoryModel":"BCD-205A/HC4(E1)","Country":"芬兰","ProductLine":"Refrigerator ","brand":"GRAM","ExportModel":"RD-27DR4SLB/CPA2-001","GSSSalesRegion":"冰冷洗欧洲二区"},{"CustomerModel":"KF 1205-90","FactoryModel":"BCD-205A/HC4(E2)","Country":"丹麦","ProductLine":"Refrigerator ","brand":"GRAM","ExportModel":"RD-27DR4SLB/CPA2-001","GSSSalesRegion":"冰冷洗欧洲二区"},{"CustomerModel":"KVV3128ZIL","FactoryModel":"BC-169/HC4(EAA2)KCGZ","Country":"荷兰","ProductLine":"Refrigerator ","brand":"ETNA","ExportModel":"RS-22DR4SNA/CPA2-010","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"KVV3128ZWA","FactoryModel":"BC-169/HC4(EAB2)KCGZ","Country":"荷兰","ProductLine":"Refrigerator ","brand":"ETNA","ExportModel":"RS-22DR4SNA/CPA2-009","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"LC-433H","FactoryModel":"SC-222FLD/HC(E)-03ALA.VNM01","Country":"越南","ProductLine":"Freezer","brand":"ALASKA","ExportModel":"FL-30FC4SAC/NBN-005","GSSSalesRegion":"冰冷洗亚太区"},{"CustomerModel":"MTZ60235FF","FactoryModel":"BD-235WY/HC2(HAJ1)","Country":"法国","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RS-31WC4SBA/CPA1-007","GSSSalesRegion":"法国公司"},{"CustomerModel":"NFD 486","FactoryModel":"BCD-486WP/HC4(EAA3)YJ","Country":"法国","ProductLine":"Refrigerator ","brand":"TEKA","ExportModel":"RM-63WC4SHA/CG1-001(样机)","GSSSalesRegion":"冰冷洗欧洲二区"},{"CustomerModel":"RF 752 W","FactoryModel":"BCD-132/HC1(EAA1)","Country":"巴拿马","ProductLine":"Refrigerator ","brand":"SANKEY","ExportModel":"RD-17DR1SBA/NPS-002","GSSSalesRegion":"冰冷洗美洲区"},{"CustomerModel":"RQ82-BGKI","FactoryModel":"BCD-620WPAZ/HC4(HAB1)","Country":"以色列","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RC-81WC4SHA/CGA1-003","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"RQ82-SKI","FactoryModel":"BCD-620WPZ/HC4(HAA1)","Country":"以色列","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RC-81WC4SHA/CVA1-002","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"RQ82-WGKI","FactoryModel":"BCD-620WPAZ/HC4(HAA1)","Country":"以色列","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RC-81WC4SHA/CGA1-002","GSSSalesRegion":"冰冷洗欧洲一区"},{"CustomerModel":"RR63D6WGX","FactoryModel":"BC-176A/HC1(HAF1)","Country":"巴巴多斯","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RS-23DR1SHA/NPS-008","GSSSalesRegion":"墨西哥公司"},{"CustomerModel":"RS670N4ASU","FactoryModel":"BCD-518WY/HC4(HAA54)","Country":"阿联酋","ProductLine":"Refrigerator ","brand":"HISENSE","ExportModel":"RC-67WS4SHA/CVA1-001","GSSSalesRegion":"迪拜公司"},{"CustomerModel":"SVHFZ1000WDC","FactoryModel":"BD-200NP/H(E)-03SAV.LBN01","Country":"黎巴嫩","ProductLine":"Freezer","brand":"SAVO","ExportModel":"FC-25DD4HEA/BPN-001","GSSSalesRegion":"冰冷洗中东非区"},{"CustomerModel":"WFKV8014","FactoryModel":"WFKV8014-KUW001AEH","Country":"阿联酋","ProductLine":"WM","brand":"HISENSE","ExportModel":"WFKV8014-KUW001","GSSSalesRegion":"迪拜公司"},{"CustomerModel":"WFKV8014T","FactoryModel":"WFKV8014-KUT001AEH","Country":"阿联酋","ProductLine":"WM","brand":"HISENSE","ExportModel":"WFKV8014-KUT001","GSSSalesRegion":"迪拜公司"},{"CustomerModel":"WTX1602T","FactoryModel":"WTOX162-AET003ZAH","Country":"南非","ProductLine":"WM","brand":"HISENSE","ExportModel":"WTOX162-AET003","GSSSalesRegion":"南非公司"},{"CustomerModel":"无","FactoryModel":"BCD-486WP/HC4(HAB3)YJ","Country":"法国","ProductLine":"Refrigerator ","brand":"VALBERG","ExportModel":"RM-63WC4SHA/CVA1-005","GSSSalesRegion":"冰冷洗欧洲二区"}],"access_token":"Bearer 00D0o000001BdQ5!ARMAQFMQgL.wBWQF0Sg6pWYGVg154FxbLSj5pcdRfxxop1QgTCjr5COp9t6MHYNcKEo9G4S9lQEFTkECG4fujVT75ER9sM4b"}';
        system.debug('doPost now, body : ' + reqBody);

        AppInput input = new AppInput();
        GetProductMappingFromGSS.AppOutPut result = new GetProductMappingFromGSS.AppOutPut();
        try{
            input = (GetProductMappingFromGSS.AppInput) JSON.deserialize(reqBody, GetProductMappingFromGSS.AppInput.class);
            System.debug('input===>:' + input);
            if (input.ProductMappingList == null || input.ProductMappingList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{

                //日本产品单独处理 2022/02/15
                Boolean isJapan = false;
                for (GetProductMappingFromGSS.ProMapInfo reqR : input.ProductMappingList) {
                    if (reqR.GSSSalesRegion == 'JPProduct') {
                        isJapan = true;
                        break;
                    }
                }
                if (isJapan) {
                    result = GSSPostProductModelService.doPost(reqBody);
                    return result;
                }

                List<Customer_Model_Product__c> customerModelUpsertList = new List<Customer_Model_Product__c>();
                List<Product_Relation__c> relationUpsertList = new List<Product_Relation__c>();
                //List<String> noExistCustomerModelList = new List<String>();
                //List<String> noExistRelationModelList = new List<String>();
                Set<String> countryCodeSet = new Set<String>();
                Set<String> customerModelSet = new Set<String>();
                Set<String> exportModelSet = new Set<String>();
                Set<String> gssSalesRegionSet = new Set<String>();
                Map<String,String> customerModelMap = new Map<String,String>();
                Map<String,String> customerModelMapVar = new Map<String,String>();
                Map<String,String> exportModelnMap = new Map<String,String>();
                List<String> noExistExportModelList = new List<String>();
                List<ProMapInfo> pMList = new List<ProMapInfo>();

                //构造一系列的set
                System.debug('input.ProductMappingList:: '+ input.ProductMappingList);
                for (GetProductMappingFromGSS.ProMapInfo reqR : input.ProductMappingList) {
                    customerModelSet.add(reqR.CustomerModel);
                    exportModelSet.add(reqR.ExportModel);
                    exportModelSet.add(reqR.FactoryModel);
                    countryCodeSet.add(reqR.Country);
                    gssSalesRegionSet.add(reqR.GSSSalesRegion);
                }

                //客户型号map构造
                for(Customer_Model_Product__c cModel : [SELECT Id,Name,Country_Code__c FROM Customer_Model_Product__c WHERE Name IN:customerModelSet]){
                    customerModelMap.put(cModel.Name + cModel.Country_Code__c,cModel.Id);
                }

                //出口型号map构造
                for(Product__c pro : [SELECT Id,Name FROM Product__c WHERE Name IN: exportModelSet]){
                    exportModelnMap.put(pro.Name,pro.Id);
                }
                //map countryCode to Hisense Entity
                Map<String,String> GSSSalesRegion2SFSalesRegion = new Map<String,String>();
                for(Mapping__c mapp : [SELECT Id,Name,Original_Name__c,Mapping_Name__c,Mapping_Code__c FROM Mapping__c WHERE recordtype.DeveloperName = 'GSS_Sales_Region_and_Sales_Region_Mapping' and Name IN: gssSalesRegionSet]){
                    GSSSalesRegion2SFSalesRegion.put(mapp.Name ,mapp.Mapping_Code__c);
                }
                for (GetProductMappingFromGSS.ProMapInfo reqR : input.ProductMappingList) {
                    String model;
                    String errorMsg;
                    //如果关联关系在目前系统中的产品中找不到（出口型号/工厂型号），那么报错。而且插入不进去

                    if ('Laser TV'.equals(reqR.ProductLine)||'TV'.equals(reqR.ProductLine)||'Mobile'.equals(reqR.ProductLine)) {
                        model = reqR.FactoryModel;
                        errorMsg = 'FactoryModel:';
                    }else{
                        model = reqR.ExportModel;
                        errorMsg = 'ExportModel:';
                    }
                    //不存在的出口型号的map
                    if(!exportModelnMap.containsKey(model)){
                        noExistExportModelList.add(errorMsg + model + ', CustomerModel:  ' + reqR.CustomerModel + ', GSSSalesRegion:  ' + reqR.GSSSalesRegion + ',ProductLine: ' + reqR.ProductLine);
                        continue;
                    }
                    String customerModelID;
                    //拼接customermodel relationId
                    if(GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) == null){
                        customerModelID = reqR.CustomerModel ;
                    }else{
                        customerModelID = reqR.CustomerModel + GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) ;
                    }
                    System.debug('customerModelID... '+customerModelID);
                    String relationID;
                    //拼接relationId
                    if(GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) == null){
                        relationID = reqR.CustomerModel + reqR.FactoryModel + reqR.ExportModel ;
                    }else{
                        relationID = reqR.CustomerModel + reqR.FactoryModel + reqR.ExportModel + GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) ;
                    }
                    
                    Customer_Model_Product__c customerModel = new Customer_Model_Product__c();
                    customerModel.ExternalId__c = customerModelID;
                    customerModel.Name = reqR.CustomerModel;
                    customerModel.Product_Line__c = reqR.ProductLine;
                    if(GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) == null){
                        customerModel.Country_Code__c = '' ;
                    }else{
                        customerModel.Country_Code__c = GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) ;
                    }

                    customerModel.Brand__c = reqR.Brand;
                    //customerModelUpsertList.add(customerModel);//Modified by johnson0516
                    System.debug('customerModelMap... '+customerModelMap);
                    if(customerModelMap.get(customerModelID) == null){
                        customerModelUpsertList.add(customerModel);//Modified by johnson0516
                        pMList.add(reqR);
                    }else{
                        Product_Relation__c productRelation = new Product_Relation__c();
                        productRelation.Customer_Model__c = customerModelMap.get(customerModelID);
                        String product = reqR.ProductLine;
                        //如果产品线为Laser TV 或者 TV 或者 Mobile的时候通过工厂型号去匹配Product
                        if ('Laser TV'.equals(product)||'TV'.equals(product)||'Mobile'.equals(product)) {
                            productRelation.Factory_Model__c = exportModelnMap.get(reqR.FactoryModel);
                        }else{
                            //除此之外的产品线用出口型号去匹配
                            productRelation.Factory_Model__c = exportModelnMap.get(reqR.ExportModel);
                        }
                        productRelation.Brand__c = reqR.Brand;
                        productRelation.Product_Line__c = reqR.ProductLine;
                        if(GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion) == null){
                            productRelation.Salesforce_Sales_Region__c = '';
                        }else{
                            productRelation.Salesforce_Sales_Region__c = GSSSalesRegion2SFSalesRegion.get(reqR.GSSSalesRegion);
                        }
                        productRelation.Product_Export_Model__c = reqR.FactoryModel;
                        productRelation.GSS_Country_Name__c = reqR.Country;
                        productRelation.GSS_Sales_Region__c = reqR.GSSSalesRegion;
                        productRelation.External_ID__c = relationID;
                        relationUpsertList.add(productRelation);
                    }
                }
                //System.debug('noExistRelationModelList::: '+noExistRelationModelList);
                System.debug('relationUpsertList::; '+relationUpsertList);
                System.debug('customerModelUpsertList::; '+customerModelUpsertList);
                Map<String,Customer_Model_Product__c> cmpcMap = new Map<String,Customer_Model_Product__c>();

                if(customerModelUpsertList !=null & !customerModelUpsertList.isEmpty()){
                    for(Customer_Model_Product__c cmpc : customerModelUpsertList){
                        cmpcMap.put(cmpc.Name + cmpc.Country_Code__c , cmpc);
                    }

                    customerModelUpsertList.clear();
                    for(String key : cmpcMap.keySet()){
                        customerModelUpsertList.add(cmpcMap.get(key));
                    }

                    //customerModelUpsertList = (List<Customer_Model_Product__c>) JSON.deserialize('{"ProductMappingList": [{"CustomerModel": "KF 1205-90","FactoryModel": "BCD-205A/HC4(E1)","Country": "芬兰","ProductLine": "Refrigerator ","brand": "GRAM","ExportModel": "RD-49WR4SHA/OVA1-001","GSSSalesRegion": "冰冷洗欧洲二区"}, {"CustomerModel": "KF 1205-90","FactoryModel": "BCD-205A/HC4(E2)","Country": "丹麦","ProductLine": "Refrigerator ","brand": "GRAM","ExportModel": "RD-49WR4SHA/OVA1-001","GSSSalesRegion": "冰冷洗欧洲二区"}],"access_token": "Bearer 00D0o000001BdQ5!ARMAQFMQgL.wBWQF0Sg6pWYGVg154FxbLSj5pcdRfxxop1QgTCjr5COp9t6MHYNcKEo9G4S9lQEFTkECG4fujVT75ER9sM4b"}', Customer_Model_Product__c.class);
                    System.debug('customerModelUpsertList.. '+customerModelUpsertList);

                    //更新客户型号对象记录
                    Database.upsert(customerModelUpsertList,Customer_Model_Product__c.Fields.ExternalId__c,false);
                }
                if(relationUpsertList !=null & !relationUpsertList.isEmpty()){
                System.debug('relationUpsertList.1.. '+relationUpsertList);
                String aaaaaa = JSON.serialize(relationUpsertList);
                System.debug('mmmmmmmmmmm..  '+aaaaaa );
                    //更新产品关联对象
                    Database.upsert(relationUpsertList,Product_Relation__c.Fields.External_ID__c,false);
                }
                
                List<Product_Relation__c> prListVar = new List<Product_Relation__c>();
                System.debug('customerModelSet...  '+customerModelSet);

                //对于客户型号，除了小家电，手机产品线以外，其他的都是按照客户型号+sales region找
                for(Customer_Model_Product__c cmpc : [SELECT Id,Name,Country_Code__c FROM Customer_Model_Product__c WHERE Name IN:customerModelSet]){
                    if(cmpc.Country_Code__c == null){
                        customerModelMapVar.put(cmpc.Name,cmpc.Id);
                    }else{
                        customerModelMapVar.put(cmpc.Name + cmpc.Country_Code__c,cmpc.Id);
                    }
                }
                System.debug('customerModelMapVar::: '+customerModelMapVar);
                System.debug('pMList... '+pMList);

                //对于pMList处理
                for(GetProductMappingFromGSS.ProMapInfo pr : pMList){
                    Product_Relation__c productRelation = new Product_Relation__c();
                    if(GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion) == null){
                        productRelation.Customer_Model__c = customerModelMapVar.get(pr.CustomerModel);
                    }else{
                        productRelation.Customer_Model__c = customerModelMapVar.get(pr.CustomerModel + GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion));
                    }
                    if ('Laser TV'.equals(pr.ProductLine)||'TV'.equals(pr.ProductLine)||'Mobile'.equals(pr.ProductLine)) {
                        //电视手机查找的是工厂型号
                        productRelation.Factory_Model__c = exportModelnMap.get(pr.FactoryModel);
                    }else{
                        //其他产品线查找的是出口型号
                         productRelation.Factory_Model__c = exportModelnMap.get(pr.ExportModel);
                     }
                    productRelation.Brand__c = pr.Brand;
                    productRelation.Product_Line__c = pr.ProductLine;
                    productRelation.GSS_Country_Name__c = pr.Country;
                    productRelation.GSS_Sales_Region__c = pr.GSSSalesRegion;
                    if(GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion) == null){
                        productRelation.Salesforce_Sales_Region__c = '';
                    }else{
                        productRelation.Salesforce_Sales_Region__c = GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion);
                    }
                    productRelation.Product_Export_Model__c = pr.FactoryModel;
                    //构建relation的外键
                    if(GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion) == null){
                        productRelation.External_ID__c = pr.CustomerModel + pr.FactoryModel + pr.ExportModel;
                    }else{
                        productRelation.External_ID__c = pr.CustomerModel + pr.FactoryModel + pr.ExportModel + GSSSalesRegion2SFSalesRegion.get(pr.GSSSalesRegion);
                    }


                    
                    prListVar.add(productRelation);
                }
                System.debug('prListVar::: ' + prListVar);
                Database.upsert(prListVar,Product_Relation__c.Fields.External_ID__c,false);
                System.debug('Sync Successfully !');

                if(noExistExportModelList.size() != 0 & noExistExportModelList != null){
                    //如果查找的工厂/出口型号在salesforce中没有维护，则这部分数据不插入，并且报错
                    String errorString = JSON.serialize(noExistExportModelList);
                    System.debug('noExistExportModelList.size()::: '+noExistExportModelList.size());
                    System.debug('errorString::: '+errorString);
                    System.debug('noExistExportModelList::: '+noExistExportModelList);
                    //日志内容
                    InterfaceLog__c ic = new InterfaceLog__c();
                    ic.Class__c = 'GetProductMappingFromGSS';
                    ic.Time__c = System.Now();
                    ic.ReturnCode__c = '0';
                    ic.Req_Json__c = reqBody;
                    ic.ErrorMsg__c = '部分数据插入成功，报错信息如下 : '+ errorString;
                    insert ic;

                    result.IsSuccess = 'False';
                    result.FailReason = '部分数据插入成功，报错信息如下 : FactoryModel & CustomerModel & Country'+ errorString;
                    return result;

                }else{
                //日志内容
                    InterfaceLog__c ic = new InterfaceLog__c();
                    ic.Class__c = 'GetProductMappingFromGSS';
                    ic.Time__c = System.Now();
                    ic.ReturnCode__c = '1';
                    ic.Req_Json__c = reqBody;
                    ic.ErrorMsg__c = '';
                    insert ic;

                    result.IsSuccess = 'true';
                    result.FailReason = '';
                    return result;
                }
            }
        //错误数据   
        }catch(Exception e){
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetProductMappingFromGSS';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage() + '****' + e.getLineNumber();
            insert ic;
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage()+ '****' + e.getLineNumber();
            return result;
        }
        
    }
}