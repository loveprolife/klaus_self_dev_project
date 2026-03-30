/**********************************************************************
 * Name: GetCustomerInfoFromMQ
 * Object: Account 
 * Purpose: Receive the customer infrormation from MQ
 * Author: Chen Fen
 * Create Date: 2024-11-06
*************************************************************************/
@RestResource(urlMapping='/getCustomerInfoFromMQ')
global without sharing class GetCustomerInfoFromMQ {

    @HttpPost
    global static List<MessageWrapper> mqPost() {
        String result;
        //Req
        RestRequest req = RestContext.request;
        //Res
        RestResponse res = RestContext.response;
    
        //直接处理Blob数据而不是转换为String
        Blob requestBlob = req.requestBody;
        
        String jsonStr = requestBlob.toString();
        
        List<MessageWrapper> messages = null;

        // 事务开始
        System.Savepoint sp = Database.setSavepoint();
        try{
            jsonStr = jsonStr.replace('\\\\', '\\').replace('\\"', '"').replace('\\"', '"');
            //jsonStr = jsonStr.replace('\\"', '"');
            //jsonStr = jsonStr.replace('\\"', '"');
            //jsonStr = jsonStr.replace('\\\\\\\\', '\\\\').replace('\\\\', '\\');
            //jsonStr = jsonStr.replace('\\\\\\\\', '\\\\');
            //jsonStr = jsonStr.replaceAll('\\\\', '');
            
            jsonStr = jsonStr.replace('MSG":"', 'MSG":');
            jsonStr = jsonStr.replace('","MSG_ID', ',"MSG_ID');
            Utility.insertLogAsyn('GetCustomerInfoFromMQ', '2', jsonStr, '');
            System.debug('Request JSON: ' + jsonStr);
            
            List<String> partnerList = new List<String>();
            messages = (List<MessageWrapper>) JSON.deserialize(jsonStr, List<MessageWrapper>.class);
            List<Account> finalUpdate = new List<Account>();
            List<Customer_Extend__c> addCustomerExtendList = new List<Customer_Extend__c>();
            //List<Customer_Banks__c> addCustomerBanksList = new List<Customer_Banks__c>();

            if(!Label.MDG_MQ_FLG.equals('TRUE')){
                return messages;
            }
            
            System.debug('***messages=' + messages);

            Boolean HasIntraPartner = false;
            for(MessageWrapper msw : messages){
                if(msw.MSG.IV_OUTPUT.DATA.PARTNER != null){
                    GetCustomerInfoFromMDG.CustomerInfo customer = msw.MSG.IV_OUTPUT.DATA;
                    if (!customer.PARTNER.startsWith('A') && !customer.PARTNER.startsWith('E')){
                        msw.MSG.IV_OUTPUT.DATA.PARTNER = '00' + msw.MSG.IV_OUTPUT.DATA.PARTNER;
                    }
                    partnerList.add(customer.PARTNER);

                    if('H001'.equals(customer.BU_GROUP)){
                        HasIntraPartner = true;
                    }
                }
            }

            Map<String,Account> getAccountMap = updateAccountMap(partnerList);

            if(!HasIntraPartner && getAccountMap.size() == 0){
                return messages;
            }

            List<Payment_Term__c> paymentList = [SELECT Id,Name FROM Payment_Term__c];
            Map<String, String> paymentMap = new Map<String, String>();
            for(Payment_Term__c pt : paymentList){
                paymentMap.put(pt.Name, pt.Id);
            }

            //库位、销售组、销售办公室map
            Map<String,String> picklistId2CodeMap = new Map<String,String>();
            for(PickList__c plc : [SELECT Id, Name, Value__c, RecordType.Name,belong_to_Loc__c,belong_to_he__c,belong_to_office__c FROM PickList__c WHERE RecordType.Name = 'Master Data(Office)' OR RecordType.Name = 'Master(Location)' OR RecordType.Name = 'Master Data(Team)']){
                if(plc.RecordType.Name == 'Master(Location)'){
                    picklistId2CodeMap.put(plc.RecordType.Name + plc.belong_to_Loc__c + plc.Value__c,plc.Id);
                }
                if(plc.RecordType.Name == 'Master Data(Office)'){
                    picklistId2CodeMap.put(plc.RecordType.Name + plc.belong_to_he__c + plc.Value__c,plc.Id);
                }
                if(plc.RecordType.Name == 'Master Data(Team)'){
                    picklistId2CodeMap.put(plc.RecordType.Name + plc.belong_to_office__c + plc.Value__c,plc.Id);
                }
                
            }
            
            
            //Map<String,Account> accountMap = new Map<String,Account>();
            //if(getAccountMap.size()>0){
                String Intra_Partner = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Intra_Partner').getRecordTypeId();
                for(MessageWrapper msw : messages){
                    if((msw.MSG.IV_OUTPUT.DATA.BU_GROUP == 'H001' && msw.MSG.IV_OUTPUT.DATA.ZZMXLX == '11') || getAccountMap.containsKey(msw.MSG.IV_OUTPUT.DATA.PARTNER)){
                                            
                        //空判断
                        if(msw != null && msw.MSG.IV_OUTPUT != null && String.isNotBlank(msw.MSG.IV_OUTPUT.DATA.PARTNER)){
                            GetCustomerInfoFromMDG.CustomerInfo customer = msw.MSG.IV_OUTPUT.DATA;

                            //更新对象
                            Account mdgAcc = getAccountMap.get(customer.PARTNER);
                            if(mdgAcc == null || String.isBlank(mdgAcc.Id)){
                                mdgAcc = new Account();
                                mdgAcc.recordTypeId = Intra_Partner;
                                mdgAcc.Approval_Status__c = 'Approved';
                                mdgAcc.SAP_Customer_Code__c = customer.PARTNER;
                                mdgAcc.MDG_Customer_Code__c = customer.PARTNER;
                            }

                            //mdgAcc.External_Key__c = mdgAcc.SAP_Customer_Code__c;
                            mdgAcc.Trader_Type__c = customer.BU_GROUP;//客商类型
                            mdgAcc.CustomerDetailType__c = customer.ZZMXLX;//客商明细类型
                            mdgAcc.Customer_Name_Local_Language__c = String.isNotEmpty(customer.NAME_ORG1) ? customer.NAME_ORG1 : '';//Customer Name
                            mdgAcc.Customer_Name_Local_Language_2__c = String.isNotEmpty(customer.NAME_ORG2) ? customer.NAME_ORG2 : '';//Customer Name 2
                            mdgAcc.Name = mdgAcc.Customer_Name_Local_Language__c + mdgAcc.Customer_Name_Local_Language_2__c;//Customer Name
                            mdgAcc.Customer_Name_1__c = String.isNotEmpty(customer.NAME_ORG3) ? customer.NAME_ORG3 : '';//Customer Name 3
                            mdgAcc.Customer_Name_2__c = String.isNotEmpty(customer.NAME_ORG4) ? customer.NAME_ORG4 : '';//Customer Name 4
                            mdgAcc.Customer_Short_Name__c = customer.BU_SORT1;//简称
                            mdgAcc.FormerName__c = String.isNotEmpty(customer.ZZFONM) ? customer.ZZFONM : '';//曾用名
                            mdgAcc.ID_Type__c = String.isNotEmpty(customer.ZZZJLX) ? customer.ZZZJLX : '';//证件类型
                            mdgAcc.Company_Registration_Number__c = customer.ZZRENO;//注册码
                            mdgAcc.VAT_Registration_Number__c = String.isNotEmpty(customer.ZZVAT) ? customer.ZZVAT : '';//VAT编号
                            //mdgAcc.VAT_Registration_Number__c = String.isNotEmpty(customer.ZTAX_STCEG) ? customer.ZTAX_STCEG : '';//VAT编号
                            mdgAcc.DUNS_Number__c = String.isNotEmpty(customer.ZZDUNS) ? customer.ZZDUNS : '';//DUNS编号
                            mdgAcc.Registered_Capital__c = customer.ZZREFD != null ? Decimal.valueOf(customer.ZZREFD?.replaceAll('[^\\d.-]', '')) : null;//注册资金
                            mdgAcc.Paid_In_Funds__c = customer.ZZPDFD != null ? Decimal.valueOf(customer.ZZPDFD?.replaceAll('[^\\d.-]', '')) : null;//实缴资金
                            mdgAcc.Corporate_Representative__c = String.isNotEmpty(customer.ZZLERE) ? customer.ZZLERE : '';//法定代表人
                            mdgAcc.Unit_Nature__c = String.isNotEmpty(customer.ZZCMAT) ? customer.ZZCMAT : ''; //单位性质
                            mdgAcc.Annual_Revenue_Scale__c = customer.ZZANRE != null ? String.valueOf(customer.ZZANRE) : null;//年营业额
                            mdgAcc.Listed_Company_Code__c = String.isNotEmpty(customer.ZZCMCO) ? customer.ZZCMCO : '';//上市公司代码
                            mdgAcc.Language__c = String.isNotEmpty(customer.BU_LANGU) ? customer.BU_LANGU : '';//语言
                            mdgAcc.NumberOfEmployees = customer.ZZEMCN != null ? customer.ZZEMCN : null;//员工人数
                            mdgAcc.Website = String.isNotEmpty(customer.URI_ADDR) ? customer.URI_ADDR : '';//网址
                            mdgAcc.Main_Business_Scope__c = String.isNotEmpty(customer.ZZBNAR) ? customer.ZZBNAR : '';//经营范围
                            mdgAcc.Email_Multiple__c = String.isNotEmpty(customer.SMTP_ADDR) ? customer.SMTP_ADDR : '';//邮箱
                            mdgAcc.Fax = String.isNotEmpty(customer.FAX_NUMBER) ? customer.FAX_NUMBER : '';//传真
                            mdgAcc.Phone = String.isNotEmpty(customer.TEL_NUMBER) ? customer.TEL_NUMBER : '';//电话
                            mdgAcc.Industry_Sector__c = customer.IND_SECTOR;//行业(国标二级)
                            mdgAcc.Customer_Status_MDG__c = String.isNotEmpty(customer.ZZCUSTA) ? customer.ZZCUSTA : '';//客户状态
                            mdgAcc.Customer_Risk_Level__c = String.isNotEmpty(customer.ZZCUSRISL) ? customer.ZZCUSRISL : '';//客户风险等级
                            mdgAcc.Customer_Risk_Type__c = String.isNotEmpty(customer.ZZCUSRITY) ? customer.ZZCUSRITY : '';// 客户风险类型
                            mdgAcc.Unified_customer_group_code__c = String.isNotEmpty(customer.ZZCUSGR) ? customer.ZZCUSGR : '';//统一客户组编码
                            mdgAcc.Channel_Customer_Categories__c = String.isNotEmpty(customer.ZZCHCUSCA) ? customer.ZZCHCUSCA : '';//渠道客户大类
                            mdgAcc.Channel_Customer_Subcategories__c = String.isNotEmpty(customer.ZZCHCUSSU) ? customer.ZZCHCUSSU : '';//渠道客户小类
                            mdgAcc.credit_rating__c = String.isNotEmpty(customer.ZZCRERAT) ? customer.ZZCRERAT : '';//信用等级
                            mdgAcc.Transportation_area__c = String.isNotEmpty(customer.LZONE) ? customer.LZONE : ''; // 运输区域
                            mdgAcc.Overseas_customer_level__c = String.isNotEmpty(customer.ZZHWKHFJ) ? customer.ZZHWKHFJ : ''; //海外客户分级
                            mdgAcc.Sub_account_type__c = String.isNotEmpty(customer.ZZFHLX) ? customer.ZZFHLX : '';//分户类型
                            mdgAcc.Reasons_for_customer_segmentation__c = String.isNotEmpty(customer.ZZFHYY) ? customer.ZZFHYY : '';//分户原因
                            mdgAcc.Global_Location_Number__c = String.isNotEmpty(customer.BBSNR) && String.isNotEmpty(customer.BBBNR) && String.isNotEmpty(customer.BUBKZ) ? customer.BBBNR + customer.BBSNR + customer.BUBKZ : '';//GLN码
                            mdgAcc.E_commerce_Customer_Label__c = String.isNotEmpty(customer.ZZLINE) ? customer.ZZLINE : '';//线上/线下
                            mdgAcc.Tax_Number1__c = String.isNotEmpty(customer.ZTAX_CODE1) ? customer.ZTAX_CODE1 : '';//税码1
                            mdgAcc.Tax_Number2__c = String.isNotEmpty(customer.ZTAX_CODE2) ? customer.ZTAX_CODE2 : '';//税码2
                            mdgAcc.Search_Term2__c = String.isNotEmpty(customer.ZSORT2) ? customer.ZSORT2 : '';//搜索项2
                            mdgAcc.Tax_Number3__c = String.isNotEmpty(customer.ZTAX_CODE3) ? customer.ZTAX_CODE3 : '';//税码3
                            mdgAcc.Tax_Number4__c = String.isNotEmpty(customer.ZTAX_CODE4) ? customer.ZTAX_CODE4 : '';//税码4
                            mdgAcc.Supplier__c = String.isNotEmpty(customer.ZLIFNR) ? customer.ZLIFNR : '';//供应商
                            mdgAcc.Attribute2__c = String.isNotEmpty(customer.ZKATR2) ? customer.ZKATR2 : '';//属性2
                            mdgAcc.Customer_Price_Level__c = String.isNotEmpty(customer.ZKATR3) ? customer.ZKATR3 : '';//客户价格等级
                            // 客户类型
                            if (customer.CUTSOMER_TYPE != null && customer.CUTSOMER_TYPE.size() > 0){
                                mdgAcc.Client_Type__c = String.isNotEmpty(customer.CUTSOMER_TYPE[0].ZZCUSTY) ? customer.CUTSOMER_TYPE[0].ZZCUSTY : '';//客户类型
                            }
                            // 地址信息
                            List<GetCustomerInfoFromMDG.CustomerAddress> addressList = customer.ADDR;
                            if (addressList != null && addressList.size() > 0){
                                for (GetCustomerInfoFromMDG.CustomerAddress addressInfo : addressList){
                                    // 标准地址就是类型01
                                    if (addressInfo.ZZADTY == '01'){
                                        mdgAcc.Guarantor_Country_Code__c = String.isNotEmpty(addressInfo.LAND1) ? addressInfo.LAND1 : '';//国家
                                        mdgAcc.Postal_Code__c = String.isNotEmpty(addressInfo.POST_CODE1) ? addressInfo.POST_CODE1 : '';//邮编
                                        mdgAcc.Street_2__c = String.isNotBlank(addressInfo.STR_SUPPL2) ? addressInfo.STR_SUPPL2 : '';//地址街道2
                                        mdgAcc.Street_3__c = String.isNotBlank(addressInfo.STR_SUPPL3) ? addressInfo.STR_SUPPL3 : '';//地址街道3
                                        mdgAcc.Street_4__c = String.isNotBlank(addressInfo.STR_SUPPL4) ? addressInfo.STR_SUPPL4 : '';//地址街道4
                                        mdgAcc.Street_5__c = String.isNotBlank(addressInfo.STR_LOCATION) ? addressInfo.STR_LOCATION : '';//地址街道5

                                        Map<String, String> countryStateMap = new Map<String, String>();
                                        Set<String> countryStateNameSet = new Set<String>();
                                        if (String.isNotEmpty(addressInfo.REGIO)){
                                            countryStateNameSet.add(addressInfo.REGIO);
                                        }
                                        // 中国地址
                                        if (addressInfo.LAND1 == 'CN'){
                                            // 省、市、区县、乡镇
                                            if (String.isNotEmpty(addressInfo.ORT01)){
                                                countryStateNameSet.add(addressInfo.ORT01);
                                            }
                                            if (String.isNotEmpty(addressInfo.ORT02)){
                                                countryStateNameSet.add(addressInfo.ORT02);
                                            }
                                            if (String.isNotEmpty(addressInfo.ZZTOWN)){
                                                countryStateNameSet.add(addressInfo.ZZTOWN);
                                            }
                                            for (Country_State__c psc : [SELECT Id, Name__c
                                                                        FROM Country_State__c
                                                                        WHERE Name__c IN:countryStateNameSet]){
                                                countryStateMap.put(psc.Name__c, psc.Id);
                                            }
                                            if (String.isNotEmpty(addressInfo.REGIO) && countryStateMap.get(addressInfo.REGIO) != null){
                                                mdgAcc.Province_State__c = countryStateMap.get(addressInfo.REGIO);
                                            }
                                            if (String.isNotEmpty(addressInfo.ORT01) && countryStateMap.get(addressInfo.ORT01) != null){
                                                mdgAcc.City_CN__c = countryStateMap.get(addressInfo.ORT01);
                                            }
                                            if (String.isNotEmpty(addressInfo.ORT02) && countryStateMap.get(addressInfo.ORT02) != null){
                                                mdgAcc.District_CN__c = countryStateMap.get(addressInfo.ORT02);
                                            }
                                            if (String.isNotEmpty(addressInfo.ZZTOWN) && countryStateMap.get(addressInfo.ZZTOWN) != null){
                                                mdgAcc.Township_CN__c = countryStateMap.get(addressInfo.ZZTOWN);
                                            }
                                        } else{
                                            for (Country_State__c psc : [SELECT Id, Name__c
                                                                        FROM Country_State__c
                                                                        WHERE Name__c IN:countryStateNameSet and Belong_To__c =:mdgAcc.Guarantor_Country_Code__c]){
                                                countryStateMap.put(psc.Name__c, psc.Id);
                                            }
                                            if (String.isNotEmpty(addressInfo.REGIO) && countryStateMap.get(addressInfo.REGIO) != null){
                                                mdgAcc.Province_State__c = countryStateMap.get(addressInfo.REGIO);
                                            }
                                            mdgAcc.City__c = String.isNotEmpty(addressInfo.ORT01) ? addressInfo.ORT01 : '';
                                            mdgAcc.District__c = String.isNotEmpty(addressInfo.ORT02) ? addressInfo.ORT02 : '';
                                            mdgAcc.Town__c = String.isNotEmpty(addressInfo.ZZTOWN) ? addressInfo.ZZTOWN : '';
                                        }
                                        break;
                                    }
                                }
                            }
                            
                            System.debug('mdgAcc='+mdgAcc);
                            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
                            // 保存更新客户主数据
                            Database.upsert (mdgAcc);
                            //恢复触发器
                            Utility.IgnoreAction(false,false,false,'');

                            //finalUpdate.add(mdgAcc);  
                            //accountMap.put(mdgAcc.SAP_Customer_Code__c, mdgAcc);   

                            // 公司视图
                            List<GetCustomerInfoFromMDG.CompanyView> companyList = customer.COMPANY;
                            if (companyList != null && companyList.size() > 0){
                                for (GetCustomerInfoFromMDG.CompanyView companyView : companyList){
                                    if(!'810'.equals(companyView.CLIENT)){
                                        continue;
                                    }
                                    Customer_Extend__c company = new Customer_Extend__c();
                                    company.Customer__c = mdgAcc.Id;
                                    company.Extend_or_Not__c = true;
                                    company.Show_Company__c = true;
                                    company.Show_Sales__c = false;
                                    //company.Approval_Status__c = 'Approved';
                                    company.Create_View__c = '1';
                                    
                                    if (companyView.BUKRS != null && String.isNotBlank(Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c').get(companyView.BUKRS))){
                                        company.Hisense_Entity__c = companyView.BUKRS != null ? companyView.BUKRS : '';
                                        company.Reconciliation_Customer__c = companyView.AKONT != null ? companyView.AKONT : '';
                                        company.Account_Remarks__c = companyView.KVERM != null ? companyView.KVERM : '';
                                        company.Company_View_Freeze_markers__c = companyView.NODEL != null ? true : false;
                                        // company.Payment_Method_MDG__c = companyView.ZWELS != null ? companyView.ZWELS : ''; // 只有首个字母对应不上
                                        company.Delete_identification_for_company_region__c = companyView.LOEVM != null ? true : false;
                                        company.EDI_ID__c = companyView.ZZSORT1 != null ? companyView.ZZSORT1 : '';
                                        company.EDI_ID2__c = companyView.ZZSORT2 != null ? companyView.ZZSORT2 : '';
                                        company.Customer_EDI_ID_Type__c = companyView.EDI_TYPE != null ? companyView.EDI_TYPE : '';
                                        company.TV_lisense__c = companyView.ZTV != null ? companyView.ZTV : '';
                                        company.Packing_Type__c = companyView.PACKAGING_TYPE != null ? companyView.PACKAGING_TYPE : '';
                                        company.Add_VAT_Reg_No__c = companyView.ZZSH != null ? companyView.ZZSH : '';
                                        company.VAT_Tax_type__c = companyView.ZKHFL != null ? companyView.ZKHFL : '';
                                        company.ExternalID__c = mdgAcc.Id + '-' + company.Hisense_Entity__c + '--';
                                        if (companyView.ZVALID_TO != null){
                                            String dataString = companyView.ZVALID_TO;
                                            company.Valid_to__c = Date.newInstance(Integer.valueOf(dataString.substring(0, 4)), Integer.valueOf(dataString.substring(4, 6)), Integer.valueOf(dataString.substring(6, 8)));
                                        }
                                        if (companyView.ZTERM != null){
                                            company.Payment_Term__c = paymentMap.get(companyView.ZTERM);
                                        }
                                        if (companyView.ZZLGORT != null){
                                            company.Stor_Location__c = picklistId2CodeMap.get('Master(Location)' + company.Hisense_Entity__c + companyView.ZZLGORT);
                                        }

                                        addCustomerExtendList.add(company);
                                    }
                                }
                            }
                            // 销售视图
                            // 接口税数据，key:TATYP value:TAXKD
                            Map<String, String> taxMap = new Map<String, String>();
                            // Tax_category__c 表的外键
                            Set<String> taxKey = new Set<String>();
                            List<GetCustomerInfoFromMDG.SalesView> salesViewList = customer.SALES;
                            if (salesViewList != null && salesViewList.size() > 0){
                                for (GetCustomerInfoFromMDG.SalesView salesView : salesViewList){
                                    if(!'810'.equals(salesView.CLIENT)){
                                        continue;
                                    }
                                    Customer_Extend__c sales = new Customer_Extend__c();
                                    sales.Customer__c = mdgAcc.Id;
                                    sales.Extend_or_Not__c = true;
                                    sales.Show_Company__c = false;
                                    sales.Show_Sales__c = true;
                                    //sales.Approval_Status__c = 'Approved';
                                    sales.Create_View__c = '2';
                                    if (salesView.VKORG != null && String.isNotBlank(Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c').get(salesView.VKORG))){
                                        sales.Hisense_Entity_Sales__c = salesView.VKORG;
                                        sales.Customer_Group_5__c = salesView.ZKVGR5 != null ? salesView.ZKVGR5 : '';
                                        sales.Customer_Group_4__c = salesView.ZKVGR4 != null ? salesView.ZKVGR4 : '';
                                        sales.Customer_Group_3__c = salesView.ZKVGR3 != null ? salesView.ZKVGR3 : '';
                                        sales.Customer_Group_1__c = salesView.ZKVGR1 != null ? salesView.ZKVGR1 : '';
                                        sales.CurrencyIsoCode = salesView.WAERS != null ? salesView.WAERS : '';
                                        sales.Deliverying_Plant__c = salesView.VWERK != null ? salesView.VWERK : '';
                                        sales.Distribution_Channel__c = salesView.VTWEG != null ? salesView.VTWEG : '';
                                        sales.Shipping_Conditions__c = salesView.VSBED != null ? salesView.VSBED : '';
                                        sales.Related_to_POD__c = salesView.PODKZ != null ? true : false;
                                        sales.Delete_identification_for_company_region__c = salesView.LOEVM != null ? true : false;
                                        sales.Customer_Group2__c = salesView.KVGR2 != null ? salesView.KVGR2 : '';
                                        sales.Account_Assignment_Group__c = salesView.KTGRD != null ? salesView.KTGRD : '';
                                        sales.Price_Group__c = salesView.KONDA != null ? salesView.KONDA : '';
                                        sales.KDGRP__c = salesView.KDGRP != null ? salesView.KDGRP : '';
                                        sales.Customer_pricing_process__c = salesView.KALKS != null ? salesView.KALKS : '';
                                        sales.International_Trade_Terms_2__c = salesView.INCO2_L != null ? salesView.INCO2_L : '';
                                        sales.International_Trade_Terms__c = salesView.INCO1 != null ? salesView.INCO1 : '';
                                        sales.Sales_View_Freeze_markers__c = salesView.AUFSD != null ? true : false;
                                        sales.Our_account_at_the_customer_s_place__c = salesView.EIKTO != null ? salesView.EIKTO : '';
                                        sales.ExternalID__c = mdgAcc.Id + '--' + sales.Hisense_Entity_Sales__c + '-' + sales.Distribution_Channel__c;

                                        if (salesView.ZTERM != null){
                                            sales.Payment_Term_Sales__c = paymentMap.get(salesView.ZTERM);
                                        }

                                        // 销售部门 Sales Office
                                        if (salesView.VKBUR != null){
                                            sales.Sales_Office__c = picklistId2CodeMap.get('Master Data(Office)' + sales.Hisense_Entity_Sales__c + salesView.VKBUR);
                                            // 销售组 Sales Group
                                            if (salesView.VKGRP != null){
                                                System.debug('SalesGroup: ' + 'Master Data(Team)' + salesView.VKBUR + salesView.VKGRP);
                                                sales.Sales_Group__c = picklistId2CodeMap.get('Master Data(Team)' + salesView.VKBUR + salesView.VKGRP);
                                            }
                                        }
                                        // 付款方 Payer__c
                                        if (salesView.PYKUR != null){
                                            List<Account> accountList = [SELECT Id
                                                                        FROM Account
                                                                        WHERE MDG_Customer_Code__c = :salesView.PYKUR];
                                            if (accountList != null && accountList.size() > 0){
                                                sales.Payer__c = accountList[0].Id;
                                            }
                                        }
                                        // 开票方 Receiver__c
                                        if (salesView.BPKUR != null){
                                            List<Account> accountList = [SELECT Id
                                                                        FROM Account
                                                                        WHERE MDG_Customer_Code__c = :salesView.BPKUR];
                                            if (accountList != null && accountList.size() > 0){
                                                sales.Receiver__c = accountList[0].Id;
                                            }
                                        }
                                        addCustomerExtendList.add(sales);
                                        // 税信息处理
                                        List<GetCustomerInfoFromMDG.taxCodn> taxList = salesView.TAXCODN;
                                        if (taxList != null && taxList.size() > 0){
                                            for (GetCustomerInfoFromMDG.taxCodn tax : taxList){
                                                taxKey.add(tax.TATYP + tax.TAXKD);
                                                taxMap.put(tax.TATYP, tax.TAXKD);
                                            }
                                        }
                                    }
                                }
                            }

                            // 保存客户相关数据
                            if (addCustomerExtendList != null && addCustomerExtendList.size() > 0){
                                Database.upsert(addCustomerExtendList,Customer_Extend__c.Fields.ExternalID__c,true);
                            }
                            // if (addCustomerBanksList != null && addCustomerBanksList.size() > 0){
                            //     Database.insert (addCustomerBanksList);
                            // }

                            // 查询税信息
                            if (taxKey != null && taxKey.size() > 0){
                                Map<String, Tax_category__c> taxTempMap = new Map<String, Tax_category__c>();
                                List<Customer_Extend_Tax_category__c> customerExtendTaxCategoryList = [SELECT Id, Tax_category__c, Tax_category_code__c
                                                                                                    FROM Customer_Extend_Tax_category__c
                                                                                                    WHERE Customer_Extend__r.Customer__c = :mdgAcc.Id];
                                List<Tax_category__c> taxCategoryList = [SELECT Id, Name, Tax_category__c, Tax_Catagoery_External_Id__c
                                                                        FROM Tax_category__c
                                                                        WHERE Tax_Catagoery_External_Id__c IN:taxKey];
                                for (Tax_category__c tax : taxCategoryList){
                                    taxTempMap.put(tax.Tax_Catagoery_External_Id__c, tax);
                                }
                                for (Customer_Extend_Tax_category__c cetc : customerExtendTaxCategoryList){
                                    // 根据接口税数据的map获取当前 Tax category 对应的 Tax classification 值
                                    String taxClassification = taxMap.get(cetc.Tax_category_code__c);
                                    // 根据 Tax_category__c 表的外键获取对应的 Tax_category__c 值
                                    if (taxTempMap.get(cetc.Tax_category_code__c + taxClassification) != null){
                                        cetc.Tax_category__c = taxTempMap.get(cetc.Tax_category_code__c + taxClassification).Id;
                                    }
                                }
                                // 保存税信息数据
                                if (customerExtendTaxCategoryList != null && customerExtendTaxCategoryList.size() > 0){
                                    Database.update (customerExtendTaxCategoryList);
                                }
                            }
                        } 
                    }
                }

                //Utility.insertLogAsyn('GetCustomerInfoFromMQ', '1', jsonStr, '');

            //}

        }catch(Exception e) {
            // 回滚事务
            Database.rollback(sp);
            Utility.IgnoreAction(false,false,false,'');
            
            Utility.insertLogAsyn('GetCustomerInfoFromMQ', '0', jsonStr, 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() );
            
        }

        
        return messages;

    }

    /**
	* 将String类型转换成Date
	* @param 要转换的String
	* @return 转换后的Date
	*/
    // public static Date convertStringToDate(String dateString) {
    //     Date reDate;
    //     //位数check
    //     if (dateString.length() == 8 && !dateString.startsWith('0') && !dateString.startsWith('9')) {
            
    //     //年
    //     String year = dateString.substring(0, 4);
    //     //月
    //     String month = dateString.substring(4, 6);
    //     //日
    //     String day = dateString.substring(6, 8);
    //     //String to YYYY-MM-DD
    //     String formattedDate = year + '-' + month + '-' + day;
    //     //String to Date
    //     reDate = Date.valueOf(formattedDate);
    //     }
    //     return reDate;
    // }

    

    public static Map<String,Account> updateAccountMap(List<String> partnerList) {
        // 查询符合条件的 Account 记录
        List<Account> accountsToUpdate = [SELECT Id, Name,MDG_Customer_Code__c,SAP_Customer_Code__c FROM Account WHERE MDG_Customer_Code__c in :partnerList];
        Map<String,Account> accMap = new Map<String,Account>();
        //Account ac;
        if(accountsToUpdate != null && accountsToUpdate.size()>0){
            for(Account upAccount : accountsToUpdate){
             
             accMap.put(upAccount.MDG_Customer_Code__c,upAccount);

            }
        }
        return accMap;      
             
    }

    //异步更新客户邮箱
    // public class AsyncSyncCustomerEmail implements Queueable, Database.AllowsCallouts {
    //     public List<Customer_Email__c> emailList { get; set; }
    //     public AsyncSyncCustomerEmail(List<Customer_Email__c> emails){
    //         emailList = emails;
    //         system.debug('======emailList===='+ emailList);
    //     }
    //     public void execute(QueueableContext context) {
    //         try {
    //             system.debug('======emailList===='+ emailList);
    //             Database.upsert(emailList, Customer_Email__c.Fields.External_key__c, false);
    //         } catch (Exception e) {
    //             Utility.insertLog('AsyncSyncCustomerEmail', '0', '', 'failure: SF Sync Customer Email Failed! ' + e.getMessage() + '-------');
    //         }
    //     }
    // }

    global class RequestWrapper {
        public String MSG;
    }
   
    global class AppOutput{
        InterfaceBody IV_OUTPUT;
    }

    global class InterfaceBody {
        public String SENDER;
        public String INSTID;
        public String PMODE;
        public String PCOMPANY;
        public String USMD_CREQ_TEXT;
        public String TEST;
        public String BU_LANGU;
        public GetCustomerInfoFromMDG.CustomerInfo DATA;
    }

    global class MessageWrapper {
        public AppOutput MSG;
        public String MSG_ID;
    }
    
}