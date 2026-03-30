/*
 * @Author: WFC
 * @Date: 2025-05-08 16:59:13
 * @LastEditors: WFC
 * @LastEditTime: 2025-10-20 16:30:51
 * @Description: 客户所有相关数据同步MDG接口
 SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG('001A200000JmhqwIAB'); 
 * @FilePath: \testuat\force-app\main\default\classes\SyncCustomerInfoToMDGPro.cls
 */
public without sharing class SyncCustomerInfoToMDGPro {

    //接口主信息
    public class InterfaceInfo {
        public InterfaceBody IV_INPUT;
    }

    public class InterfaceBody {
        public String SENDER;
        public String INSTID;
        public String PMODE;
        public String PCOMPANY;
        public String USMD_CREQ_TEXT;
        public String TEST;
        public String BU_LANGU;

        public CustomerInfo DATA;

    }

    //客户主数据
    public class CustomerInfo {
        public String PARTNER;
        public String BU_GROUP;
        public String ZZMXLX;
        public String NAME_LO;
        public Boolean NAME_LO_X;
        public String NAME_EN;
        public Boolean NAME_EN_X;
        public String BU_SORT1;
        public Boolean BU_SORT1_X;
        public String ZZFONM;
        public Boolean ZZFONM_X;
        public String ZZZJLX;
        public Boolean ZZZJLX_X;
        public String ZZRENO;
        public Boolean ZZRENO_X;
        public String ZZDUNS;
        public Boolean ZZDUNS_X;
        public String ZZVAT;
        public Boolean ZZVAT_X;
        public String ZZBLED;
        public Boolean ZZBLED_X;
        public String FOUND_DAT;
        public Boolean FOUND_DAT_X;
        public Decimal ZZREFD;
        public Boolean ZZREFD_X;
        public Decimal ZZPDFD;
        public Boolean ZZPDFD_X;
        public String ZZLERE;
        public Boolean ZZLERE_X;
        public String ZZCMAT;
        public Boolean ZZCMAT_X;
        public String ZZANRE;
        public Boolean ZZANRE_X;
        public Boolean ZZIFCM;
        public Boolean ZZIFCM_X;
        public String ZZCMCO;
        public Boolean ZZCMCO_X;
        public String BU_LANGU;
        public Boolean BU_LANGU_X;
        public Integer ZZEMCN;
        public Boolean ZZEMCN_X;
        public String URI_ADDR;
        public Boolean URI_ADDR_X;
        public String ZZBNAR;
        public Boolean ZZBNAR_X;
        public String SMTP_ADDR;
        public Boolean SMTP_ADDR_X;
        public String FAX_NUMBER;
        public Boolean FAX_NUMBER_X;
        public String TEL_NUMBER;
        public Boolean TEL_NUMBER_X;
        public String IND_SECTOR;
        public Boolean IND_SECTOR_X;
        public String ZZCVCO;
        public Boolean ZZCVCO_X;
        public String ZZCUSTA;
        public Boolean ZZCUSTA_X;
        public String ZZCUSRISL;
        public Boolean ZZCUSRISL_X;
        public String ZZCUSRITY;
        public Boolean ZZCUSRITY_X;
        public String ZZINCAT;
        public Boolean ZZINCAT_X;
        public String ZZINSUB;
        public Boolean ZZINSUB_X;
        public String ZZCUSGR;
        public Boolean ZZCUSGR_X;
        public String ZZCHCUSCA;
        public Boolean ZZCHCUSCA_X;
        public String ZZCHCUSSU;
        public Boolean ZZCHCUSSU_X;
        public String ZZCRERAT;
        public Boolean ZZCRERAT_X;
        public String ZZCHMACLA;
        public Boolean ZZCHMACLA_X;
        public String ZZHWKHFJ;
        public Boolean ZZHWKHFJ_X;
        public String LZONE;
        public Boolean LZONE_X;
        public String ZZFHLX;
        public Boolean ZZFHLX_X;
        public String ZZFHYY;
        public Boolean ZZFHYY_X;
        public String BBBNR;
        public Boolean BBBNR_X;
        public String BBSNR;
        public Boolean BBSNR_X;
        public String BUBKZ;
        public Boolean BUBKZ_X;
        public String ZZLINE;
        public Boolean ZZLINE_X;
        public String ZKATR2;
        public Boolean ZKATR2_X;
        public String ZKATR3;
        public Boolean ZKATR3_X;
        public String ZTAX_CODE1;
        public Boolean ZTAX_CODE1_X;
        public String ZTAX_CODE2;
        public Boolean ZTAX_CODE2_X;
        public String ZTAX_JUR;
        public Boolean ZTAX_JUR_X;
        public String ZTAX_STCEG;
        public Boolean ZTAX_STCEG_X;

        public List<CustomerAddress> ADDR;
        public List<CustomerType> CUTSOMER_TYPE;
        public List<BankDetail> BANKDETAIL = new List<BankDetail>();
        public List<CompanyView> COMPANY;
        public List<SalesView> SALES;

        public String ZLIFNR;
        public Boolean ZLIFNR_X;
        public String ZSORT2;
        public Boolean ZSORT2_X;
        public String ZTAX_CODE3;
        public Boolean ZTAX_CODE3_X;
        public String ZTAX_CODE4;
        public Boolean ZTAX_CODE4_X;
        
        public String NAME_ORG1;
        public Boolean NAME_ORG1_X;
        public String NAME_ORG2;
        public Boolean NAME_ORG2_X;
        public String NAME_ORG3;
        public Boolean NAME_ORG3_X;
        public String NAME_ORG4;
        public Boolean NAME_ORG4_X;
    }
    //地址信息ADDR
    public class CustomerAddress {
        
        public String ZZADTY;
        public String LAND1;
        public Boolean LAND1_X;
        public String REGIO;
        public Boolean REGIO_X;
        public String ORT01;
        public Boolean ORT01_X;
        public String ORT02;
        public Boolean ORT02_X;
        public String ZZTOWN;
        public Boolean ZZTOWN_X;
        public String POST_CODE1;
        public Boolean POST_CODE1_X;
        public String FSTRAS;
        public Boolean FSTRAS_X;

        public String STR_SUPPL2;
        public Boolean STR_SUPPL2_X;
        public String STR_SUPPL3;
        public Boolean STR_SUPPL3_X;
        public String STR_SUPPL4;
        public Boolean STR_SUPPL4_X;
        public String STR_LOCATION;
        public Boolean STR_LOCATION_X;
    }
    //客户类型
    public class CustomerType{
        public string PARTNER;
        public string ZZCUSTY;
    }
    //银行信息
    public class BankDetail{
        public string PMODE;
        public String BANKN;
        public String BANKL;
        public String BANKS;
        public String IBAN;
        public Boolean IBAN_X;
        public String ACCNAME;
        public Boolean ACCNAME_X;
        public String ZZACCNAME;
        public Boolean ZZACCNAME_X;
        public String ZZWAERS;
        public Boolean ZZWAERS_X;
        public String BKONT;
        public Boolean BKONT_X;
    }
    //公司视图
    public class CompanyView{

        public String BUKRS;
        public String ZTERM;
        public Boolean ZTERM_X;
        public String AKONT;
        public Boolean AKONT_X;
        public String SREGL;
        public Boolean SREGL_X;
        public String KVERM;
        public Boolean KVERM_X;
        public String NODEL;
        public Boolean NODEL_X;
        public String ZWELS;
        public Boolean ZWELS_X;
        public String ZZLINE;
        public Boolean ZZLINE_X;
        public Boolean LOEVM;
        public Boolean LOEVM_X;
        public String ZZLGORT;
        public Boolean ZZLGORT_X;
        public String ZZSORT1;
        public Boolean ZZSORT1_X;
        public String ZZSORT2;
        public Boolean ZZSORT2_X;
        public String EDI_TYPE;
        public Boolean EDI_TYPE_X;
        public String ZTV;
        public Boolean ZTV_X;
        public String ZVALID_TO;
        public Boolean ZVALID_TO_X;
        public String PACKAGING_TYPE;
        public Boolean PACKAGING_TYPE_X;
        public String ZZSH;
        public Boolean ZZSH_X;
        public String ZKHFL;
        public Boolean ZKHFL_X;
    }
    //销售视图
    public class SalesView{
        public String EIKTO;
        public Boolean EIKTO_X;
        public String VKORG;
        public String SPART;
        public String VTWEG;
        public String KALKS;
        public Boolean KALKS_X;
        public String ZTERM;
        public Boolean ZTERM_X;
        public String BZIRK;
        public Boolean BZIRK_X;
        public Boolean LOEVM;
        public Boolean LOEVM_X;
        //public String TAXKD;
        //public Boolean TAXKD_X;
        public String AUFSD;
        public Boolean AUFSD_X;
        public String KONDA;
        public Boolean KONDA_X;
        public String PLTYP;
        public Boolean PLTYP_X;
        public String VKBUR;
        public Boolean VKBUR_X;
        public String VKGRP;
        public Boolean VKGRP_X;
        public Boolean PODKZ;
        public Boolean PODKZ_X;
        public String INCO1;
        public Boolean INCO1_X;
        public String INCO2_L;
        public Boolean INCO2_L_X;
        public String INCO3_L;
        public Boolean INCO3_L_X;
        public String WAERS;
        public Boolean WAERS_X;
        public String KTGRD;
        public Boolean KTGRD_X;
        public String KDGRP;
        public Boolean KDGRP_X;
        public String VSBED;
        public Boolean VSBED_X;
        public String VWERK;
        public Boolean VWERK_X;
        public String KVGR2;
        public Boolean KVGR2_X;
        public List<taxCodn> TAXCODN;
        public String BPKUR;
        public Boolean BPKUR_X;
        public String PYKUR;
        public Boolean PYKUR_X;

        public String ZKVGR1;
        public String ZKVGR3;
        public String ZKVGR4;
        public String ZKVGR5;
        public Boolean ZKVGR1_X;
        public Boolean ZKVGR3_X;
        public Boolean ZKVGR4_X;
        public Boolean ZKVGR5_X;
    }
    public class taxCodn {
        public String ALAND;
        public String TATYP;
        //public Boolean TATYP_X;
        public String TAXKD;
        public Boolean TAXKD_X;
    }
    public class ResDeta {
        public String INSTID;
        public String SYNSTATUS;
        public String SYNRESULT;
        public String PARTNER;
        public String CODE;
    }

    public static String postCustomerInfomationToMDG(String customerId) {

        //String url = 'https://open-apisix-test.hisense.com/mdg-cuswh/sap/bc/zmdg?app_id=3ctplhsk&app_key=jv290shesn0wtdgy0ld2t41w9iv1uckl&if_id=Customer_maintain&sap-client=300';
        //String appid = '3ctplhsk';
        //String clientId = '300';
        //String if_id = 'Customer_maintain';
        //String secretKey = 'jv290shesn0wtdgy0ld2t41w9iv1uckl';
        
        String url = MDG_Interface__c.getValues('CustomerMaintain').Url__c;
        String appid = MDG_Interface__c.getValues('CustomerMaintain').AppId__c;
        String clientId = MDG_Interface__c.getValues('CustomerMaintain').ClientId__c;
        String if_id = MDG_Interface__c.getValues('CustomerMaintain').If_Id__c;
        String secretKey = MDG_Interface__c.getValues('CustomerMaintain').SecretKey__c;
        String server = MDG_Interface__c.getValues('CustomerMaintain').Server__c;
        String datatime = '&if_id='+ if_id + '&sap-client=' + clientId;
        String message = 'POST\n'+
                          server+'\n'+
                        //  '/mdg-cus-uwh/sap/bc/zmdg\n'+
                         'app_id='+appid+'&app_key=' + secretKey + datatime+'\n'+
                          appid+'\n'+
                         'Mon, 01 Apr 2024 03:55:01 GMT\n';

        //根据id判断是客户Account还是Customer Extend表
        Id cid= Id.valueOf(customerId);
        String objectName = cid.getSObjectType().getDescribe().getName();
        DateTime dtStart = Datetime.now();
        Id paymentId;
        
        InterfaceInfo interfaceInfo = new InterfaceInfo();
        InterfaceBody IV_INPUT = new InterfaceBody();
        CustomerInfo customerInfo = new CustomerInfo();
        List<CustomerAddress> addrList = new List<CustomerAddress>();
        CustomerAddress addr = new CustomerAddress();
        List<CompanyView> companyViewList = new List<CompanyView>();
        CompanyView companyView = new CompanyView();
        SalesView salesView = new SalesView();
        List<SalesView> saleViewList = new List<SalesView>();
        Customer_Banks__c customerBank = new Customer_Banks__c();
        String emailAddress = '';
        List<CustomerType> customerTypeList = new List<CustomerType>();
        List<taxCodn> taxCodnList = new List<taxCodn>();
        Boolean isUpdate = True;
        String extendId;
        List<Customer_Extend_Tax_category__c> extendTaxList = new List<Customer_Extend_Tax_category__c>();
        List<Customer_Tax_category__c> accountTaxList = new List<Customer_Tax_category__c>();
        List<Customer_Address_Tax_category__c> addressTaxList = new List<Customer_Address_Tax_category__c>();

        // 根据客户id查询客户主信息，公司视图，销售视图，银行信息
        Account account = [SELECT Id,RecordType.Name,RecordType.DeveloperName,MDG_Customer_Code__c,SAP_Customer_Code__c,Trader_Type__c,CustomerDetailType__c,Name,Customer_Short_Name__c,
            Street_2__c, Street_3__c, Street_4__c, Street_5__c, 
            Customer_Name_1__c,Customer_Name_2__c,Customer_Name_Local_Language__c,Customer_Name_Local_Language_2__c,
            FormerName__c,ID_Type__c,Company_Registration_Number__c,DUNS_Number__c,VAT_Registration_Number__c,
            License_Expiration_Date__c,Payer__r.MDG_Customer_Code__c,Receiver__r.MDG_Customer_Code__c,
            Registration_Date__c,Registered_Capital__c,Paid_In_Funds__c,Corporate_Representative__c,Unit_Nature__c,Annual_Revenue_Scale__c,ParentCustomerOfSubAcc__c,
            Is_Listed_Company__c,Listed_Company_Code__c,Language__c,NumberOfEmployees,Website,Main_Business_Scope__c,Email__c,Fax,Phone,
            Industry_Sector__c,Belonged_Customer_Code__c,Customer_Status__c,Customer_Status_MDG__c,Customer_Risk_Level__c,Customer_Risk_Type__c,Unified_customer_group_code__c,
            Channel_Customer_Categories__c,Channel_Customer_Subcategories__c,Tax_Classification__c,Reconciliation_Customer__c,Payment_Method_MDG__c,
            Sub_account_type__c,Reasons_for_customer_segmentation__c,Tax_Number1__c,Tax_Number2__c,Guarantor_Country_Code__c,Province_State__c, City__c,
            Transportation_area__c, Supplier__c, Search_Term2__c, Tax_Number3__c, Tax_Number4__c,
            District__c,Town__c,Postal_Code__c,Address__c,Hisense_Entity__c,Distribution_Channel__c,Product_Group__c,Customer_pricing_process__c,
            Payment_Term__c,Sales_Region__c,Sales_Office__c, Sales_Group__c,Related_to_POD__c,International_Trade_Terms__c,International_Trade_Terms_2__c,
            Customer_Group_1__c, Customer_Group_3__c, Customer_Group_4__c, Customer_Group_5__c,
            CurrencyIsoCode,Account_Assignment_Group__c,KDGRP__c,Shipping_Conditions__c,
            Deliverying_Plant__c,VAT_Tax_type__c,Customer_Group2__c,Channel_Management_Classification__c,
            Client_Type__c,Global_Location_Number__c,E_commerce_Customer_Label__c,Customer_Price_Level__c,Attribute2__c,Sales_area_deletion_flag__c,Price_Group__c,credit_rating__c,Overseas_customer_level__c,
            City_CN__c,District_CN__c,Township_CN__c,Selection_Rules__c,Account_Remarks__c,Delete_identification_for_company_region__c,EDI_ID__c,EDI_ID2__c,Customer_EDI_ID_Type__c,
            TV_lisense__c,Valid_to__c,Packing_Type__c,Add_VAT_Reg_No__c,Company_View_Freeze_markers__c,
            Sales_View_Freeze_markers__c,Stor_Location__c,Hisense_Entity_Sales__c,Payment_Term_Sales__c,
            Email_Multiple__c,Address_Description__c,Customer_Management_Name__c,Customer_Management_Name__r.Name,
            // 分户的主户字段
            ParentCustomerOfSubAcc__r.MDG_Customer_Code__c,
            // 地址类客户的主户字段
            Sold_to__r.Language__c,Sold_to__r.MDG_Customer_Code__c,Sold_to__r.Hisense_Entity__c,Sold_to__r.Product_Group__c,Sold_to__r.Distribution_Channel__c,Sold_to__r.Customer_pricing_process__c,
            Sold_to__r.Payment_Term__c,Sold_to__r.Sales_Region__c,Sold_to__r.Sales_area_deletion_flag__c,
            Sold_to__r.Tax_Classification__c,Sold_to__r.Price_Group__c,Sold_to__r.Sales_Office__c,Sold_to__r.Hisense_Entity_Sales__c,Sold_to__r.Payment_Term_Sales__c,
            Sold_to__r.Sales_Group__c,Sold_to__r.Related_to_POD__c,Sold_to__r.International_Trade_Terms__c,Sold_to__r.International_Trade_Terms_2__c,
            Sold_to__r.CurrencyIsoCode,Sold_to__r.Account_Assignment_Group__c,Sold_to__r.KDGRP__c,Sold_to__r.Shipping_Conditions__c,
            Sold_to__r.Deliverying_Plant__c,Sold_to__r.VAT_Tax_type__c,Sold_to__r.Customer_Group2__c,
            Sold_to__r.Customer_Name_1__c,Sold_to__r.Customer_Name_2__c,Sold_to__r.Customer_Name_Local_Language__c,Sold_to__r.Customer_Name_Local_Language_2__c,
            Sold_to__r.Reconciliation_Customer__c,Sold_to__r.Payment_Method_MDG__c,Sold_to__r.Sales_View_Freeze_markers__c,Sold_to__r.Company_View_Freeze_markers__c,
            Sold_to__r.Selection_Rules__c,Sold_to__r.Account_Remarks__c,Sold_to__r.Delete_identification_for_company_region__c,
            Sold_to__r.EDI_ID__c,Sold_to__r.EDI_ID2__c,Sold_to__r.Customer_EDI_ID_Type__c,
            Sold_to__r.Street_2__c, Sold_to__r.Street_3__c, Sold_to__r.Street_4__c, Sold_to__r.Street_5__c,
            Sold_to__r.TV_lisense__c,Sold_to__r.Valid_to__c,Sold_to__r.Packing_Type__c,Sold_to__r.Address__c,Sold_to__r.Stor_Location__c,
            Sold_to__r.Add_VAT_Reg_No__c,Sold_to__r.Guarantor_Country_Code__c,Sold_to__r.Province_State__c,Sold_to__r.City_CN__c,Sold_to__r.District_CN__c,
            Sold_to__r.Township_CN__c,Sold_to__r.Postal_Code__c,Sold_to__r.Address_Description__c,Sold_to__r.City__c,Sold_to__r.District__c,Sold_to__r.Town__c
            FROM Account 
            WHERE Id = :customerId];

        List<Customer_Extend__c> companyList = [SELECT Id,Name,Customer__c,Shipping_Conditions__c,Related_to_POD__c,Payment_Method_MDG__c,
            E_commerce_Customer_Label__c,Delete_identification_for_company_region__c,
            EDI_ID__c,EDI_ID2__c,Customer_EDI_ID_Type__c,TV_lisense__c,Valid_to__c,Packing_Type__c,Add_VAT_Reg_No__c,
            Customer_Pricing_Process__c,Customer_Statistics_Group__c,Hisense_Entity__c,Reconciliation_Customer__c,Payment_Term__c,VAT_Tax_type__c,
            Selection_Rule__c,Account_Remarks__c,Sales_Region__c,Sales_area_deletion_flag__c,Tax_Classification__c,
            Price_Group__c,Sales_Office__c,Sales_Group__c,Company_View_Freeze_markers__c,Sales_View_Freeze_markers__c,Product_Group__c,
            International_Trade_Terms__c,International_Trade_Terms_2__c,CurrencyIsoCode,Account_Assignment_Group__c,KDGRP__c,
            Customer_Group_1__c, Customer_Group_3__c, Customer_Group_4__c, Customer_Group_5__c,
            Deliverying_Plant__c,Customer_Group2__c,Price_List__c,Receiver__c,Payback_Overdue_Number__c,Payer__c,Distribution_Channel__c,
            Hisense_Entity_Sales__c,Payment_Term_Sales__c,Stor_Location__c,
            Receiver__r.SAP_Customer_Code__c,Receiver__r.MDG_Customer_Code__c,Payer__r.SAP_Customer_Code__c,Payer__r.MDG_Customer_Code__c
            FROM Customer_Extend__c
            WHERE Customer__c =: customerId AND Show_Company__c = true];

        List<Customer_Extend__c> salesList = [SELECT Id,Name,Customer__c,Shipping_Conditions__c,Related_to_POD__c,Payment_Method_MDG__c,
            E_commerce_Customer_Label__c,Delete_identification_for_company_region__c,
            EDI_ID__c,EDI_ID2__c,Customer_EDI_ID_Type__c,TV_lisense__c,Valid_to__c,Packing_Type__c,Add_VAT_Reg_No__c,
            Customer_Pricing_Process__c,Customer_Statistics_Group__c,Hisense_Entity__c,Reconciliation_Customer__c,Payment_Term__c,VAT_Tax_type__c,
            Selection_Rule__c,Account_Remarks__c,Sales_Region__c,Sales_area_deletion_flag__c,Tax_Classification__c,
            Price_Group__c,Sales_Office__c,Sales_Group__c,Company_View_Freeze_markers__c,Sales_View_Freeze_markers__c,Product_Group__c,
            International_Trade_Terms__c,International_Trade_Terms_2__c,CurrencyIsoCode,Account_Assignment_Group__c,KDGRP__c,
            Customer_Group_1__c, Customer_Group_3__c, Customer_Group_4__c, Customer_Group_5__c,
            Deliverying_Plant__c,Customer_Group2__c,Price_List__c,Receiver__c,Payback_Overdue_Number__c,Payer__c,Distribution_Channel__c,
            Hisense_Entity_Sales__c,Payment_Term_Sales__c,Stor_Location__c,Our_account_at_the_customer_s_place__c,
            Receiver__r.SAP_Customer_Code__c,Receiver__r.MDG_Customer_Code__c,Payer__r.SAP_Customer_Code__c,Payer__r.MDG_Customer_Code__c,
            (Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Extend_Tax_category__r)
            FROM Customer_Extend__c
            WHERE Customer__c =: customerId AND Show_Sales__c = true];

        List<Customer_Banks__c> customerBankList = [SELECT Id,Name,Customer__c,Bank_Account__c,Bank_Account_Holder__c,Bank_Code__c,Bank_Control_Code__c,Bank_Country__c,Bank_Name__c,
            Swift_Code__c, Reference_Detail__c,Bank_name_local_language__c,Bank_name_in_English__c,CurrencyIsoCode,IBAN__c
            FROM Customer_Banks__c
            WHERE Customer__c =: customerId];

        //国家省市map
        Map<String,String> countryStateMap = new Map<String,String>();
        Set<String> countryStateSet = new Set<String>();
        if (String.isNotBlank(account.Province_State__c)) {
            countryStateSet.add(account.Province_State__c);
        }
        if (String.isNotBlank(account.City_CN__c)) {
            countryStateSet.add(account.City_CN__c);
        }
        if (String.isNotBlank(account.District_CN__c)) {
            countryStateSet.add(account.District_CN__c);
        }
        if (String.isNotBlank(account.Township_CN__c)) {
            countryStateSet.add(account.Township_CN__c);
        }
        if (String.isNotBlank(account.Sold_to__r.Province_State__c)) {
            countryStateSet.add(account.Sold_to__r.Province_State__c);
        }
        if (String.isNotBlank(account.Sold_to__r.City_CN__c)) {
            countryStateSet.add(account.Sold_to__r.City_CN__c);
        }
        if (String.isNotBlank(account.Sold_to__r.District_CN__c)) {
            countryStateSet.add(account.Sold_to__r.District_CN__c);
        }
        if (String.isNotBlank(account.Sold_to__r.Township_CN__c)) {
            countryStateSet.add(account.Sold_to__r.Township_CN__c);
        }
        
        for(Country_State__c psc : [SELECT Id,Name__c FROM Country_State__c WHERE id IN: countryStateSet]){
            countryStateMap.put(psc.Id,psc.Name__c);
        }

        //销售组、销售办公室map
        Map<String,String> picklistId2CodeMap = new Map<String,String>();
        for(PickList__c plc : [SELECT Id, Name, Value__c FROM PickList__c WHERE RecordType.Name = 'Master Data(Office)' OR RecordType.Name = 'Master(Location)' OR RecordType.Name = 'Master(Storage Location)' OR RecordType.Name = 'Master Data(team)']){
            picklistId2CodeMap.put(plc.Id,plc.Value__c);
        }

        //账期的ID和Code的Map
        Map<String,String> paymentTermIdCodeMap = new Map<String,String>();
        Set<String> paymentTermIdSet = new Set<String>();
        for(Customer_Extend__c customerExtend : companyList){
            if (String.isNotBlank(customerExtend.Payment_Term__c)) {
                paymentTermIdSet.add(customerExtend.Payment_Term__c);
            }
            if (String.isNotBlank(customerExtend.Payment_Term_Sales__c)) {
                paymentTermIdSet.add(customerExtend.Payment_Term_Sales__c);
            }
        }
        for(Customer_Extend__c customerExtend : salesList){
            if (String.isNotBlank(customerExtend.Payment_Term__c)) {
                paymentTermIdSet.add(customerExtend.Payment_Term__c);
            }
            if (String.isNotBlank(customerExtend.Payment_Term_Sales__c)) {
                paymentTermIdSet.add(customerExtend.Payment_Term_Sales__c);
            }
        }
        for(Payment_Term__c ptc : [SELECT Id, Name FROM Payment_Term__c WHERE Id IN: paymentTermIdSet]){
            paymentTermIdCodeMap.put(ptc.Id, ptc.Name);
        }
        
        // 处理数据
        //发送方系统ID
        IV_INPUT.SENDER = 'S0218';
        //接口唯一ID
        IV_INPUT.INSTID = account.Id + dtStart.format('yyyyMMddHHmmss');
        //处理模式
        if(account.MDG_Customer_Code__c == null || account.MDG_Customer_Code__c == ''){
            IV_INPUT.PMODE = 'I';
            isUpdate = false;
        }else{
            IV_INPUT.PMODE = 'M';
        }
        //Sap Client
        IV_INPUT.PCOMPANY = MDG_Interface__c.getValues('CustomerMaintain').PCOMPANY__c;
        //申请/修改原因和备注
        IV_INPUT.USMD_CREQ_TEXT = '';
        //预校验
        IV_INPUT.TEST = '';
        //语言
        IV_INPUT.BU_LANGU = '';
        //客商编码
        customerInfo.PARTNER = account.MDG_Customer_Code__c == null ? '': account.MDG_Customer_Code__c;
        // 员工类客户，客商编码直接使用E+注册号（员工号）进行新建 第一轮测试 2014.12.06 MDG最新规则
        if (String.isEmpty(customerInfo.PARTNER) && account.recordtype.Name == 'Staff' && String.isNotBlank(account.Company_Registration_Number__c)) {
            customerInfo.PARTNER = 'E' + account.Company_Registration_Number__c;
        }
        //客商类型
        customerInfo.BU_GROUP = account.Trader_Type__c == null ? '': account.Trader_Type__c;
        //客商明细类型
        customerInfo.ZZMXLX = account.CustomerDetailType__c == null ? '': account.CustomerDetailType__c;
        
        //客商名称（当地语言）MDG把原来的NameEN和NameLocal对换 2025.1.16
        customerInfo.NAME_LO= account.Customer_Name_Local_Language__c == null ? '': account.Customer_Name_Local_Language__c;
        if(String.isNotBlank(customerInfo.NAME_LO)){
            customerInfo.NAME_LO += account.Customer_Name_Local_Language_2__c == null ? '': ' ' + account.Customer_Name_Local_Language_2__c;
        }else{
            customerInfo.NAME_LO += account.Customer_Name_Local_Language_2__c == null ? '': account.Customer_Name_Local_Language_2__c;
        }
                                
        //客商名称（当地语言）修改标识
        customerInfo.NAME_LO_X = isUpdate;
        //客商名称（英文）
        customerInfo.NAME_EN = account.Customer_Name_1__c == null ? '': account.Customer_Name_1__c;
        if(String.isNotBlank(customerInfo.NAME_EN)){
            customerInfo.NAME_EN += account.Customer_Name_2__c == null ? '': ' ' + account.Customer_Name_2__c;
        }else{
            customerInfo.NAME_EN += account.Customer_Name_2__c == null ? '': account.Customer_Name_2__c;
        }
        //客商名称（英文）修改标识
        customerInfo.NAME_EN_X = isUpdate;

        //名称1 必填
        customerInfo.NAME_ORG1 = account.Customer_Name_Local_Language__c == null ? '': account.Customer_Name_Local_Language__c;
        //名称1修改标识
        customerInfo.NAME_ORG1_X = isUpdate;
        //名称2
        customerInfo.NAME_ORG2 = account.Customer_Name_Local_Language_2__c == null ? '': account.Customer_Name_Local_Language_2__c;
        //名称2修改标识
        customerInfo.NAME_ORG2_X = isUpdate;
        //名称3
        customerInfo.NAME_ORG3 = account.Customer_Name_1__c == null ? '': account.Customer_Name_1__c;
        //名称3修改标识
        customerInfo.NAME_ORG3_X = isUpdate;
        //名称4
        customerInfo.NAME_ORG4 = account.Customer_Name_2__c == null ? '': account.Customer_Name_2__c;
        //名称4修改标识
        customerInfo.NAME_ORG4_X = isUpdate;
        
        //简称
        customerInfo.BU_SORT1 = account.Customer_Short_Name__c == null ? '': account.Customer_Short_Name__c;
        //简称1修改标识
        customerInfo.BU_SORT1_X = isUpdate;
        //曾用名
        customerInfo.ZZFONM = account.FormerName__c == null ? '': account.FormerName__c;
        //曾用名修改标识
        customerInfo.ZZFONM_X = isUpdate;
        //证件类型
        customerInfo.ZZZJLX = account.ID_Type__c == null ? '': account.ID_Type__c;
        //证件类型修改标识
        customerInfo.ZZZJLX_X = isUpdate;
        //注册码
        customerInfo.ZZRENO = account.Company_Registration_Number__c == null ? '': account.Company_Registration_Number__c;
        //注册码修改标识
        customerInfo.ZZRENO_X = isUpdate;
        //DUNS编号
        customerInfo.ZZDUNS = account.DUNS_Number__c == null ? '': account.DUNS_Number__c;
        //DUNS编号修改标识
        customerInfo.ZZDUNS_X = isUpdate;
        //VAT编号
        customerInfo.ZZVAT = account.VAT_Registration_Number__c == null ? '': account.VAT_Registration_Number__c;
        //VAT编号修改标识
        customerInfo.ZZVAT_X = isUpdate;

        //VAT编号
        customerInfo.ZTAX_STCEG = account.VAT_Registration_Number__c == null ? '': account.VAT_Registration_Number__c;
        //VAT编号修改标识ZTAX_STCEG
        customerInfo.ZTAX_STCEG_X = isUpdate;

        if(account.License_Expiration_Date__c != null){
            //营业执照到日期
            customerInfo.ZZBLED = SyncCustomerInfoToMDG.dateToString(account.License_Expiration_Date__c);
            //营业执照到日期修改标识
            customerInfo.ZZBLED_X = isUpdate;
        }
        
        if(account.Registration_Date__c != null){
            //注册日期
            customerInfo.FOUND_DAT = SyncCustomerInfoToMDG.dateToString(account.Registration_Date__c);
            //注册日期修改标识
            customerInfo.FOUND_DAT_X = isUpdate;
        }
        
        //注册资金
        customerInfo.ZZREFD = account.Registered_Capital__c;
        //注册资金修改标识
        customerInfo.ZZREFD_X = isUpdate;
        //实缴资金
        customerInfo.ZZPDFD = account.Paid_In_Funds__c;
        //实缴资金修改标识
        customerInfo.ZZPDFD_X = isUpdate;
        //法定代表人
        customerInfo.ZZLERE = account.Corporate_Representative__c == null ? '': account.Corporate_Representative__c;
        //法定代表人修改标识
        customerInfo.ZZLERE_X = isUpdate;
        //单位性质
        customerInfo.ZZCMAT = account.Unit_Nature__c == null ? '': account.Unit_Nature__c;
        //单位性质修改标识
        customerInfo.ZZCMAT_X = isUpdate;
        //年度营业收入规模
        customerInfo.ZZANRE = account.Annual_Revenue_Scale__c == null ? '': account.Annual_Revenue_Scale__c;
        //年度营业收入规模修改标识
        customerInfo.ZZANRE_X = isUpdate;
        //是否上市公司
        customerInfo.ZZIFCM = account.Is_Listed_Company__c;
        //是否上市公司修改标识
        customerInfo.ZZIFCM_X = isUpdate;
        //上市公司代码
        customerInfo.ZZCMCO = account.Listed_Company_Code__c == null ? '': account.Listed_Company_Code__c;
        //上市公司代码修改标识
        customerInfo.ZZCMCO_X = isUpdate;
        //语言
        customerInfo.BU_LANGU = account.Language__c == null ? '': account.Language__c;
        //语言修改标识
        customerInfo.BU_LANGU_X = isUpdate;
        //员工人数
        customerInfo.ZZEMCN = account.NumberOfEmployees;
        //员工人数修改标识
        customerInfo.ZZEMCN_X = isUpdate;
        //公司网站
        customerInfo.URI_ADDR = account.Website == null ? '': account.Website;
        //公司网站修改标识
        customerInfo.URI_ADDR_X = isUpdate;
        //经营范围
        customerInfo.ZZBNAR = account.Main_Business_Scope__c == null ? '': account.Main_Business_Scope__c;
        //经营范围修改标识
        customerInfo.ZZBNAR_X= isUpdate;
        //官方邮箱
        customerInfo.SMTP_ADDR = account.Email_Multiple__c == null ? '': account.Email_Multiple__c;
        //官方邮箱修改标识
        customerInfo.SMTP_ADDR_X = isUpdate;
        //传真号码
        customerInfo.FAX_NUMBER = account.Fax == null ? '': account.Fax;
        //传真号码修改标识
        customerInfo.FAX_NUMBER_X = isUpdate;
        //联系电话
        customerInfo.TEL_NUMBER = account.Phone == null ? '': account.Phone;
        //联系电话修改标识
        customerInfo.TEL_NUMBER_X = isUpdate;
        //行业(国标二级)
        customerInfo.IND_SECTOR = account.Industry_Sector__c == null ? '': account.Industry_Sector__c;
        //行业(国标二级)修改标识
        customerInfo.IND_SECTOR_X = isUpdate;
        if(account.RecordType.DeveloperName == 'Customer_Address'){
            //所属客商编码
            customerInfo.ZZCVCO = account.Sold_to__r.MDG_Customer_Code__c == null ? '': account.Sold_to__r.MDG_Customer_Code__c;
            //所属客商编码修改标识
            customerInfo.ZZCVCO_X = isUpdate;
        }else {
            //所属客商编码
            customerInfo.ZZCVCO = account.Belonged_Customer_Code__c == null ? '': account.Belonged_Customer_Code__c;
            //所属客商编码修改标识
            customerInfo.ZZCVCO_X = isUpdate;
        }
        //客户状态
        customerInfo.ZZCUSTA = account.Customer_Status_MDG__c == null ? '': account.Customer_Status_MDG__c;
        //客户状态修改标识
        customerInfo.ZZCUSTA_X = isUpdate;
        //客户风险等级
        customerInfo.ZZCUSRISL = account.Customer_Risk_Level__c == null ? '': account.Customer_Risk_Level__c;
        //客户风险等级修改标识
        customerInfo.ZZCUSRISL_X = isUpdate;
        //客户风险类型
        customerInfo.ZZCUSRITY = account.Customer_Risk_Type__c == null ? '': account.Customer_Risk_Type__c;
        //客户风险类型修改标识
        customerInfo.ZZCUSRITY_X = isUpdate;
        //统一客户组编码
        customerInfo.ZZCUSGR = account.Unified_customer_group_code__c == null ? '': account.Unified_customer_group_code__c;
        //统一客户组编码修改标识
        customerInfo.ZZCUSGR_X = isUpdate;
        //渠道客户大类
        customerInfo.ZZCHCUSCA = account.Channel_Customer_Categories__c == null ? '': account.Channel_Customer_Categories__c;
        //渠道客户大类修改标识
        customerInfo.ZZCHCUSCA_X = isUpdate;
        //渠道客户小类
        customerInfo.ZZCHCUSSU = account.Channel_Customer_Subcategories__c == null ? '': account.Channel_Customer_Subcategories__c;
        //渠道客户小类修改标识
        customerInfo.ZZCHCUSSU_X = isUpdate;
        //信用等级
        customerInfo.ZZCRERAT = account.credit_rating__c == null ? '': account.credit_rating__c;
        //信用等级修改标识
        customerInfo.ZZCRERAT_X = isUpdate;
        //渠道管理分类
        customerInfo.ZZCHMACLA = '10';
        //渠道管理分类修改标识
        customerInfo.ZZCHMACLA_X = isUpdate;
        //海外客户分级
        customerInfo.ZZHWKHFJ = account.Overseas_customer_level__c == null ? '': account.Overseas_customer_level__c;
        //海外客户分级修改标识
        customerInfo.ZZHWKHFJ_X = isUpdate;
        //运输区域
        customerInfo.LZONE = account.Transportation_area__c == null ? '': account.Transportation_area__c;
        //运输区域修改标识
        customerInfo.LZONE_X = isUpdate;

        // lzx - 2025-02-08新增字段  2025-08-08 取消供应商修改
        //供应商
        customerInfo.ZLIFNR = account.Supplier__c == null ? '': account.Supplier__c;
        //供应商修改标识
        customerInfo.ZLIFNR_X = isUpdate;
        //搜索项2
        customerInfo.ZSORT2 = account.Search_Term2__c == null ? '': account.Search_Term2__c;
        //搜索项2修改标识
        customerInfo.ZSORT2_X = isUpdate;
        //税号3
        customerInfo.ZTAX_CODE3 = account.Tax_Number3__c == null ? '': account.Tax_Number3__c;
        //税号3修改标识
        customerInfo.ZTAX_CODE3_X = isUpdate;
        //税号4
        customerInfo.ZTAX_CODE4 = account.Tax_Number4__c == null ? '': account.Tax_Number4__c;
        //税号4修改标识
        customerInfo.ZTAX_CODE4_X = isUpdate;

        //分户类型
        customerInfo.ZZFHLX = account.Sub_account_type__c == null ? '': account.Sub_account_type__c;
        //分户类型修改标识
        customerInfo.ZZFHLX_X = isUpdate;
        //分户原因
        customerInfo.ZZFHYY = account.Reasons_for_customer_segmentation__c == null ? '': account.Reasons_for_customer_segmentation__c;
        //分户原因修改标识
        customerInfo.ZZFHYY_X = isUpdate;
        //GLN码-1
        customerInfo.BBBNR = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(0,7);
        //GLN码-1修改标识
        customerInfo.BBBNR_X = isUpdate;
        //GLN码-2
        customerInfo.BBSNR = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(7,12);
        //GLN码-2修改标识
        customerInfo.BBSNR_X = isUpdate;
        //GLN码-3
        customerInfo.BUBKZ = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(12,13);
        //GLN码-3修改标识
        customerInfo.BUBKZ_X = isUpdate;
        //线上/线下
        customerInfo.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
        //线上/线下修改标识
        customerInfo.ZZLINE_X = isUpdate;
        //属性2 lizunxing - 2025-10-22新增字段
        customerInfo.ZKATR2 = account.Attribute2__c == null ? '': account.Attribute2__c;
        //属性2修改标识
        customerInfo.ZKATR2_X = isUpdate;
        //客户价格等级
        customerInfo.ZKATR3 = account.Customer_Price_Level__c == null ? '': account.Customer_Price_Level__c;
        //客户价格等级修改标识
        customerInfo.ZKATR3_X = isUpdate;
        //税码1
        customerInfo.ZTAX_CODE1 = account.Tax_Number1__c == null ? '': account.Tax_Number1__c;
        //税码1修改标识
        customerInfo.ZTAX_CODE1_X = isUpdate;
        //税码2
        customerInfo.ZTAX_CODE2 = account.Tax_Number2__c == null ? '': account.Tax_Number2__c;
        //税码2修改标识
        customerInfo.ZTAX_CODE2_X = isUpdate;
        //税码3
        //customerInfo.ZTAX_CODE3 = account.Tax_Number3__c == null ? '': account.Tax_Number3__c;
        //税码3修改标识
        //customerInfo.ZTAX_CODE3_X = isUpdate;
        
        if('BR'.equals(account.Guarantor_Country_Code__c)){
            //税管辖区域 2026-01-09 李涛要求巴西税管辖区域默认和地区一致
            customerInfo.ZTAX_JUR = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
            //税管辖区域修改标识
            customerInfo.ZTAX_JUR_X = isUpdate;
        }else{
            //税管辖区域
            customerInfo.ZTAX_JUR  = '';
            //税管辖区域修改标识
            customerInfo.ZTAX_JUR_X = isUpdate;
        }

        // MDG创建规则是如果要带地址，必须要有个01的标准地址，02是不能单独存在的。
        // 地址类客户也是一个客户，客户就需要有一个标准地址就是类型01.  自己本身的送货地址是类型02.   01和02 所有结构都相同，就是使用类型不同
        // 2024.12.26 MDG最新同步的地址类客户创建规则
        if(account.RecordType.DeveloperName == 'Customer_Address'){
            CustomerAddress basicAddr = new CustomerAddress();
            basicAddr.ZZADTY = '01';
            //国家
            basicAddr.LAND1 = String.isNotBlank(account.Guarantor_Country_Code__c) ? account.Guarantor_Country_Code__c : '';
            //国家修改标识
            basicAddr.LAND1_X = isUpdate;
            //省份
            basicAddr.REGIO = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
            //省份修改标识
            basicAddr.REGIO_X = isUpdate;
            if ('CN'.equals(account.Guarantor_Country_Code__c)) {
                //城市
                basicAddr.ORT01 = account.City_CN__c == null ? '': countryStateMap.get(account.City_CN__c);
                //城市修改标识
                basicAddr.ORT01_X = isUpdate;
                //区县
                basicAddr.ORT02 = account.District_CN__c == null ? '': countryStateMap.get(account.District_CN__c);
                //区县修改标识
                basicAddr.ORT02_X = isUpdate;
                //乡镇
                basicAddr.ZZTOWN = account.Township_CN__c == null ? '': countryStateMap.get(account.Township_CN__c);
                //乡镇修改标识
                basicAddr.ZZTOWN_X = isUpdate;
            } else {
                //城市
                basicAddr.ORT01 = account.City__c == null ? '': account.City__c;
                //城市修改标识
                basicAddr.ORT01_X = isUpdate;
                //区县
                basicAddr.ORT02 = account.District__c == null ? '': account.District__c;
                //区县修改标识
                basicAddr.ORT02_X = isUpdate;
                //乡镇
                basicAddr.ZZTOWN = account.Town__c == null ? '': account.Town__c;
                //乡镇修改标识
                basicAddr.ZZTOWN_X = isUpdate;
            }
            //邮编 新表中没有
            basicAddr.POST_CODE1 = account.Postal_Code__c == null ? '': account.Postal_Code__c;
            //邮编修改标识
            basicAddr.POST_CODE1_X = isUpdate;
            //地址描述
            basicAddr.FSTRAS = String.isNotBlank(account.Address__c) ? account.Address__c : '';
            //地址描述修改标识
            basicAddr.FSTRAS_X = isUpdate;

            //地址街道2
            basicAddr.STR_SUPPL2 = String.isNotBlank(account.Street_2__c) ? account.Street_2__c : '';
            //地址街道2修改标识
            basicAddr.STR_SUPPL2_X = isUpdate;
            //地址街道3
            basicAddr.STR_SUPPL3 = String.isNotBlank(account.Street_3__c) ? account.Street_3__c : '';
            //地址街道3修改标识
            basicAddr.STR_SUPPL3_X = isUpdate;
            //地址街道4
            basicAddr.STR_SUPPL4 = String.isNotBlank(account.Street_4__c) ? account.Street_4__c : '';
            //地址街道4修改标识
            basicAddr.STR_SUPPL4_X = isUpdate;
            //地址街道5
            basicAddr.STR_LOCATION = String.isNotBlank(account.Street_5__c) ? account.Street_5__c : '';
            //地址街道5修改标识
            basicAddr.STR_LOCATION_X = isUpdate;

            addrList.add(basicAddr);

            // 地质类客户是发货用的，地址类型是02 2024/12/26
            addr.ZZADTY = '02';
            //国家
            addr.LAND1 = String.isNotBlank(account.Guarantor_Country_Code__c) ? account.Guarantor_Country_Code__c : '';
            //国家修改标识
            addr.LAND1_X = isUpdate;
            //省份
            addr.REGIO = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
            //省份修改标识
            addr.REGIO_X = isUpdate;
            if ('CN'.equals(account.Guarantor_Country_Code__c)) {
                //城市
                addr.ORT01 = account.City_CN__c == null ? '': countryStateMap.get(account.City_CN__c);
                //城市修改标识
                addr.ORT01_X = isUpdate;
                //区县
                addr.ORT02 = account.District_CN__c == null ? '': countryStateMap.get(account.District_CN__c);
                //区县修改标识
                addr.ORT02_X = isUpdate;
                //乡镇
                addr.ZZTOWN = account.Township_CN__c == null ? '': countryStateMap.get(account.Township_CN__c);
                //乡镇修改标识
                addr.ZZTOWN_X = isUpdate;
            } else {
                //城市
                addr.ORT01 = account.City__c == null ? '': account.City__c;
                //城市修改标识
                addr.ORT01_X = isUpdate;
                //区县
                addr.ORT02 = account.District__c == null ? '': account.District__c;
                //区县修改标识
                addr.ORT02_X = isUpdate;
                //乡镇
                addr.ZZTOWN = account.Town__c == null ? '': account.Town__c;
                //乡镇修改标识
                addr.ZZTOWN_X = isUpdate;
            }
            //邮编 新表中没有
            addr.POST_CODE1 = account.Postal_Code__c == null ? '': account.Postal_Code__c;
            //邮编修改标识
            addr.POST_CODE1_X = isUpdate;
            //地址描述
            addr.FSTRAS = String.isNotBlank(account.Address_Description__c) ? account.Address_Description__c : '';
            //地址描述修改标识
            addr.FSTRAS_X = isUpdate;

            //地址街道2
            addr.STR_SUPPL2 = String.isNotBlank(account.Street_2__c) ? account.Street_2__c : '';
            //地址街道2修改标识
            addr.STR_SUPPL2_X = isUpdate;
            //地址街道3
            addr.STR_SUPPL3 = String.isNotBlank(account.Street_3__c) ? account.Street_3__c : '';
            //地址街道3修改标识
            addr.STR_SUPPL3_X = isUpdate;
            //地址街道4
            addr.STR_SUPPL4 = String.isNotBlank(account.Street_4__c) ? account.Street_4__c : '';
            //地址街道4修改标识
            addr.STR_SUPPL4_X = isUpdate;
            //地址街道5
            addr.STR_LOCATION = String.isNotBlank(account.Street_5__c) ? account.Street_5__c : '';
            //地址街道5修改标识
            addr.STR_LOCATION_X = isUpdate;
        }else {
            //地址类型 员工类客户不传值 2024.12.3
            // 员工类客户，就是地址视图还是要，地址类型固定01，只带国家和语言，其他地址视图的字段不需要 2024.12.27 MDG规则更新
            addr.ZZADTY = '01';
            // addr.ZZADTY = account.recordtype.Name == 'Staff' ? '' : '01';
            //国家
            addr.LAND1 = account.Guarantor_Country_Code__c == null ? '': account.Guarantor_Country_Code__c;
            //国家修改标识
            addr.LAND1_X = isUpdate;
            //2025-06-24 王传斌要求传递员工地址
            //if (account.recordtype.Name != 'Staff') {
                //省份
                addr.REGIO = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
                //省份修改标识
                addr.REGIO_X = isUpdate;
                if(account.Guarantor_Country_Code__c == 'CN'){
                    //城市
                    addr.ORT01 = account.City_CN__c == null ? '': countryStateMap.get(account.City_CN__c);
                    //城市修改标识
                    addr.ORT01_X = isUpdate;
                    //区县
                    addr.ORT02 = account.District_CN__c == null ? '': countryStateMap.get(account.District_CN__c);
                    //区县修改标识
                    addr.ORT02_X = isUpdate;
                    //乡镇
                    addr.ZZTOWN = account.Township_CN__c == null ? '': countryStateMap.get(account.Township_CN__c);
                    //乡镇修改标识
                    addr.ZZTOWN_X = isUpdate;

                }else{
                    //城市
                    addr.ORT01 = account.City__c == null ? '': account.City__c;
                    //城市修改标识
                    addr.ORT01_X = isUpdate;
                    //区县
                    addr.ORT02 = account.District__c == null ? '': account.District__c;
                    //区县修改标识
                    addr.ORT02_X = isUpdate;
                    //乡镇
                    addr.ZZTOWN = account.Town__c == null ? '': account.Town__c;
                    //乡镇修改标识
                    addr.ZZTOWN_X = isUpdate;
                }
                //邮编
                addr.POST_CODE1 = account.Postal_Code__c == null ? '': account.Postal_Code__c;
                //邮编修改标识
                addr.POST_CODE1_X = isUpdate;
                //地址描述
                addr.FSTRAS = account.Address__c == null ? '': account.Address__c;
                //地址描述修改标识
                addr.FSTRAS_X = isUpdate;
                //地址街道2
                addr.STR_SUPPL2 = String.isNotBlank(account.Street_2__c) ? account.Street_2__c : '';
                //地址街道2修改标识
                addr.STR_SUPPL2_X = isUpdate;
                //地址街道3
                addr.STR_SUPPL3 = String.isNotBlank(account.Street_3__c) ? account.Street_3__c : '';
                //地址街道3修改标识
                addr.STR_SUPPL3_X = isUpdate;
                //地址街道4
                addr.STR_SUPPL4 = String.isNotBlank(account.Street_4__c) ? account.Street_4__c : '';
                //地址街道4修改标识
                addr.STR_SUPPL4_X = isUpdate;
                //地址街道5
                addr.STR_LOCATION = String.isNotBlank(account.Street_5__c) ? account.Street_5__c : '';
                //地址街道5修改标识
                addr.STR_LOCATION_X = isUpdate;
            //}
        }

        if (companyList != null && companyList.size() > 0) {
            for(Customer_Extend__c customerExtend : companyList){
                companyView = new CompanyView();
                //公司代码
                companyView.BUKRS = customerExtend.Hisense_Entity__c == null ? '': customerExtend.Hisense_Entity__c;
                //付款条件
                companyView.ZTERM = customerExtend.Payment_Term__c == null ? '': paymentTermIdCodeMap.get(customerExtend.Payment_Term__c);
                //付款条件修改标识
                companyView.ZTERM_X = isUpdate;
                //统驭科目
                companyView.AKONT = customerExtend.Reconciliation_Customer__c == null ? '': customerExtend.Reconciliation_Customer__c;
                //统驭科目修改标识
                companyView.AKONT_X = isUpdate;
                //选择规则
                companyView.SREGL = account.Selection_Rules__c == null ? '': account.Selection_Rules__c;
                //选择规则修改标识
                companyView.SREGL_X = isUpdate;
                //账户备注
                companyView.KVERM = customerExtend.Account_Remarks__c == null ? '': customerExtend.Account_Remarks__c;
                //账户备注修改标识
                companyView.KVERM_X = isUpdate;
                //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                companyView.NODEL = customerExtend.Company_View_Freeze_markers__c ? 'X' : '';
                //冻结标记修改标识
                companyView.NODEL_X = isUpdate;
                //支付方式
                companyView.ZWELS = customerExtend.Payment_Method_MDG__c == null ? '': customerExtend.Payment_Method_MDG__c.substring(0,1);
                //支付方式修改标识
                companyView.ZWELS_X = isUpdate;
                //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
                // companyView.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
                //线上/线下修改标识
                // companyView.ZZLINE_X = isUpdate;
                //公司区域删除标识
                companyView.LOEVM = customerExtend.Delete_identification_for_company_region__c;
                //公司区域删除标识修改标识
                companyView.LOEVM_X = isUpdate;
                //客户EDI 默认库位 默认库位使用旧字段Stor_Location__c 2024/12/30 优化
                companyView.ZZLGORT = customerExtend.Stor_Location__c == null ? '': picklistId2CodeMap.get(customerExtend.Stor_Location__c);
                //客户EDI 默认库位修改标识
                companyView.ZZLGORT_X = isUpdate;
                //客户EDI ID
                companyView.ZZSORT1 = customerExtend.EDI_ID__c == null ? '': customerExtend.EDI_ID__c;
                //客户EDI ID修改标识
                companyView.ZZSORT1_X = isUpdate;
                //客户EDI ID2
                companyView.ZZSORT2 = customerExtend.EDI_ID2__c == null ? '': customerExtend.EDI_ID2__c;
                //客户EDI ID2修改标识
                companyView.ZZSORT2_X = isUpdate;
                //客户EDI 类型
                companyView.EDI_TYPE = customerExtend.Customer_EDI_ID_Type__c == null ? '': customerExtend.Customer_EDI_ID_Type__c;
                //客户EDI 类型修改标识
                companyView.EDI_TYPE_X = isUpdate;
                //TV lisense
                companyView.ZTV = customerExtend.TV_lisense__c == null ? '': customerExtend.TV_lisense__c;
                //TV lisense修改标识
                companyView.ZTV_X = isUpdate;
                if(customerExtend.Valid_to__c != null){
                    //Valid to
                    companyView.ZVALID_TO = SyncCustomerInfoToMDG.dateToString(customerExtend.Valid_to__c);
                    //Valid to修改标识
                    companyView.ZVALID_TO_X = isUpdate;
        
                }
                //包装类型
                companyView.PACKAGING_TYPE = customerExtend.Packing_Type__c == null ? '': customerExtend.Packing_Type__c;
                //包装类型修改标识
                companyView.PACKAGING_TYPE_X = isUpdate;
                //VAT 号
                companyView.ZZSH = customerExtend.Add_VAT_Reg_No__c == null ? '': customerExtend.Add_VAT_Reg_No__c;
                //VAT 号修改标识
                companyView.ZZSH_X = isUpdate;
                //VAT  类型
                companyView.ZKHFL = customerExtend.VAT_Tax_type__c == null ? '': customerExtend.VAT_Tax_type__c;
                //VAT  类型修改标识
                companyView.ZKHFL_X = isUpdate;

                companyViewList.add(companyView);
            }
        }

        //  MDG最新规则同步 2024.12.26   员工类客户不创建销售视图逻辑取消  2025-12-02
        if (salesList != null && salesList.size() > 0) {
            for(Customer_Extend__c customerExtend : salesList){
                salesView = new SalesView();
                taxCodnList = new List<taxCodn>(); 
                //销售组织
                salesView.VKORG = customerExtend.Hisense_Entity_Sales__c == null ? '': customerExtend.Hisense_Entity_Sales__c;
                //产品组（产品中类）
                salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
                //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
                salesView.VTWEG = customerExtend.Distribution_Channel__c == null ? '': customerExtend.Distribution_Channel__c;
                //客户定价过程
                salesView.KALKS = customerExtend.Customer_pricing_process__c == null ? '': customerExtend.Customer_pricing_process__c;
                //客户定价过程修改标识
                salesView.KALKS_X = isUpdate;
                //付款条件
                salesView.ZTERM = customerExtend.Payment_Term_Sales__c == null ? '': paymentTermIdCodeMap.get(customerExtend.Payment_Term_Sales__c);
                //付款条件修改标识
                salesView.ZTERM_X = isUpdate;
                //销售区域删除标志
                salesView.LOEVM = customerExtend.Sales_area_deletion_flag__c;
                //销售区域删除标志修改标识
                salesView.LOEVM_X = isUpdate;
                //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                salesView.AUFSD = customerExtend.Sales_View_Freeze_markers__c ? 'X' : '';
                //冻结标记修改标识
                salesView.AUFSD_X = isUpdate;
                //价格组
                salesView.KONDA = customerExtend.Price_Group__c == null ? '': customerExtend.Price_Group__c;
                //价格组修改标识
                salesView.KONDA_X = isUpdate;
                //价格单
                salesView.PLTYP = customerExtend.Price_List__c == null ? '': customerExtend.Price_List__c;
                //价格单修改标识
                salesView.PLTYP_X = isUpdate;
                //销售部门
                salesView.VKBUR = customerExtend.Sales_Office__c == null ? '': picklistId2CodeMap.get(customerExtend.Sales_Office__c);
                //销售部门修改标识
                salesView.VKBUR_X = isUpdate;
                //销售组
                salesView.VKGRP = customerExtend.Sales_Group__c == null ? '': picklistId2CodeMap.get(customerExtend.Sales_Group__c);
                //销售组修改标识
                salesView.VKGRP_X = isUpdate;
                //与POD相关
                salesView.PODKZ = customerExtend.Related_to_POD__c;
                //与POD相关修改标识
                salesView.PODKZ_X = isUpdate;
                //国际贸易条款
                salesView.INCO1 = customerExtend.International_Trade_Terms__c == null ? '': customerExtend.International_Trade_Terms__c;
                //国际贸易条款修改标识
                salesView.INCO1_X = isUpdate;
                //国际贸易条款2
                salesView.INCO2_L = customerExtend.International_Trade_Terms_2__c == null ? '': customerExtend.International_Trade_Terms_2__c;
                //国际贸易条款2修改标识
                salesView.INCO2_L_X = isUpdate;

                //客户组1
                salesView.ZKVGR1 = customerExtend.Customer_Group_1__c == null ? '': customerExtend.Customer_Group_1__c;
                //客户组1修改标识
                salesView.ZKVGR1_X = isUpdate;
                //客户组3
                salesView.ZKVGR3 = customerExtend.Customer_Group_3__c == null ? '': customerExtend.Customer_Group_3__c;
                //客户组3修改标识
                salesView.ZKVGR3_X = isUpdate;
                //客户组4
                salesView.ZKVGR4 = customerExtend.Customer_Group_4__c == null ? '': customerExtend.Customer_Group_4__c;
                //客户组4修改标识
                salesView.ZKVGR4_X = isUpdate;
                //客户组5
                salesView.ZKVGR5 = customerExtend.Customer_Group_5__c == null ? '': customerExtend.Customer_Group_5__c;
                //客户组5修改标识
                salesView.ZKVGR5_X = isUpdate;

                //货币
                salesView.WAERS = customerExtend.CurrencyIsoCode == null ? '': customerExtend.CurrencyIsoCode;
                //货币修改标识
                salesView.WAERS_X = isUpdate;
                //账户分配组
                salesView.KTGRD = customerExtend.Account_Assignment_Group__c == null ? '': customerExtend.Account_Assignment_Group__c;
                //账户分配组修改标识
                salesView.KTGRD_X = isUpdate;
                //客户组
                salesView.KDGRP = customerExtend.KDGRP__c == null ? '': customerExtend.KDGRP__c;
                //客户组修改标识
                salesView.KDGRP_X = isUpdate;
                //运输条件
                salesView.VSBED = customerExtend.Shipping_Conditions__c == null ? '': customerExtend.Shipping_Conditions__c;
                //运输条件修改标识
                salesView.VSBED_X = isUpdate;
                //发货工厂
                salesView.VWERK = customerExtend.Deliverying_Plant__c == null ? '': customerExtend.Deliverying_Plant__c;
                //发货工厂修改标识
                salesView.VWERK_X = isUpdate;
                //客户组2
                salesView.KVGR2 = customerExtend.Customer_Group2__c == null ? '': customerExtend.Customer_Group2__c;
                //客户组2修改标识
                salesView.KVGR2_X = isUpdate;
                //客户处我方账户
                salesView.EIKTO = customerExtend.Our_account_at_the_customer_s_place__c == null ? '': customerExtend.Our_account_at_the_customer_s_place__c;
                //客户处我方账户修改标识
                salesView.EIKTO_X = isUpdate;
                //1202 追加
                if (!customerExtend.Customer_Extend_Tax_category__r.isEmpty() & customerExtend.Customer_Extend_Tax_category__r != null) {
                    for (Customer_Extend_Tax_category__c ctc : customerExtend.Customer_Extend_Tax_category__r) {
                        taxCodn tc = new taxCodn();
                        // 国家地区代码 例：国内CN
                        tc.ALAND = ctc.CountryCodeAndCustomerIdF__c == null ? '': ctc.CountryCodeAndCustomerIdF__c;
                        // 税收条件类型 例：NWST
                        tc.TATYP = ctc.Tax_category_code__c == null ? '': ctc.Tax_category_code__c;
                        //税分类 1或者0
                        tc.TAXKD = ctc.Tax_category__r.Name == null ? '': ctc.Tax_category__r.Name;
                        //税分类修改标识符
                        tc.TAXKD_X = isUpdate;
                        taxCodnList.add(tc);
                    }
                }
                salesView.TAXCODN = taxCodnList;
                // 21.同步接口中追加Payer和Bill to两个字段的同步逻辑，Payer对应付款方，Bill to对应开票方 2024.12.31 优化
                // 1.主户和主户拓展，payer就是默认他自己(传空，MDG会默认成自己)，bill放开自己选择，不选择的话传MDG空。
                // BPKUR 开票方
                salesView.BPKUR = customerExtend.Receiver__r == null ? '': customerExtend.Receiver__r.MDG_Customer_Code__c;
                // 开票方修改标识
                salesView.BPKUR_X = isUpdate;
                // PYKUR 付款方
                salesView.PYKUR = customerExtend.Payer__r == null ? '' : customerExtend.Payer__r.MDG_Customer_Code__c;
                // 付款放修改标识
                salesView.PYKUR_X = isUpdate;
                // 分户：payer 默认主户，bill 放开自己选择，如果不选，传mdg  X (wfc:2025-01-26)
                if(account.recordtype.DeveloperName == 'Sub_Account'){
                    // PYKUR 付款方
                    salesView.PYKUR = account.ParentCustomerOfSubAcc__r.MDG_Customer_Code__c;
                    // 付款放修改标识
                    salesView.PYKUR_X = isUpdate;
                    // BPKUR 开票方
                    salesView.BPKUR = customerExtend.Receiver__c == null ? 'X': customerExtend.Receiver__r.MDG_Customer_Code__c;
                    // 开票方修改标识
                    salesView.BPKUR_X = isUpdate;
                }
                if(String.isNotEmpty(salesView.VKORG)){
                    saleViewList.add(salesView);
                }
            }
        }
        
        addrList.add(addr);
        if (addrList != null && addrList.size() > 0) {
            customerInfo.ADDR = addrList;
        }

        if (companyViewList != null && companyViewList.size() > 0) {
            customerInfo.COMPANY = companyViewList;
        }
        if (saleViewList != null && saleViewList.size() > 0) {
            customerInfo.SALES = saleViewList;
        }

        //客户类型
        //拆分客户类型传给MDG
        System.debug('Client_Type__c='+ account.Client_Type__c);
        if(account.Client_Type__c != null && objectName != 'Customer_Address__c'){
            
            List<String> clientTypes = account.Client_Type__c.split(';');
            System.debug('clientTypes='+clientTypes);
            for (String clientType : clientTypes) {
                CustomerType cutomerType = new  CustomerType();
                cutomerType.ZZCUSTY = clientType;
                customerTypeList.add(cutomerType);
            }

        }
        customerInfo.CUTSOMER_TYPE = customerTypeList;

        for (Customer_Banks__c cbc : customerBankList) {
            BankDetail bank = new  BankDetail();
            //处理模式
            bank.PMODE = '';
            //银行账号
            bank.BANKN = cbc.Bank_Account__c;
            //银行行号
            bank.BANKL = cbc.Bank_Code__c;
            //银行国家
            bank.BANKS = cbc.Bank_Country__c;
            //2025-02-10 lzx 崔杰要求不传
            //IBAN编码
            //bank.IBAN = cbc.IBAN__c;
            //IBAN编码修改标识
            //bank.IBAN_X = isUpdate;
            //2025-04-14  刘平华说：此字段传客户local_name
            //银行账户名称（当地语言）
            bank.ACCNAME= account.Customer_Name_Local_Language__c == null ? '': account.Customer_Name_Local_Language__c;
            if(String.isNotBlank(account.Customer_Name_Local_Language_2__c)){
                bank.ACCNAME += account.Customer_Name_Local_Language_2__c == null ? '': account.Customer_Name_Local_Language_2__c;
            }
            //bank.ACCNAME = cbc.Bank_name_local_language__c;
            //银行账户名称（当地语言）修改标识
            bank.ACCNAME_X = isUpdate;
            //银行账户名称（英文）
            bank.ZZACCNAME = cbc.Bank_name_in_English__c;
            //银行账户名称（英文）修改标识
            bank.ZZACCNAME_X = isUpdate;
            //银行账户币种
            bank.ZZWAERS = cbc.CurrencyIsoCode;
            //银行账户币种修改标识
            bank.ZZWAERS_X = isUpdate;
            //银行控制代码
            bank.BKONT = cbc.Bank_Control_Code__c;
            //银行控制代码修改标识
            bank.BKONT_X = isUpdate;

            customerInfo.BANKDETAIL.add(bank);
        }
        IV_INPUT.DATA = customerInfo;
        interfaceInfo.IV_INPUT = IV_INPUT;

        String body = JSON.serialize(interfaceInfo);
        System.debug(LoggingLevel.DEBUG,'body:: ' + body); 

        // try{
        //     if(!Test.isRunningTest()){
        //         //先通过SAP校验
        //         if(String.isBlank(IV_INPUT.DATA.PARTNER)){
        //             if('H001'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = 'AZZZZZ';
        //             }else if('H002'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = '0029999999';
        //             }else if('H003'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = '0099999999';
        //             }else if('H004'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = 'E99999999';
        //             }else if('H005'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = '0059999999';
        //             }else if('H006'.equals(IV_INPUT.DATA.BU_GROUP)){
        //                 IV_INPUT.DATA.PARTNER = '0079999999';
        //             }
        //         }
        //         //String sapCheckResult = SyncCustomerInfoCheckToSAP.syncCustomerInfoCheckToSAP(IV_INPUT, customerId);
        //         // if(!'SUCCESS'.equals(sapCheckResult)){
        //         //     return sapCheckResult;
        //         // }
        //     }
        // }catch(Exception e){}

        ResDeta input = new ResDeta();
        String bodyRes;

        InterfaceLog__c ic = new InterfaceLog__c();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', SyncCustomerInfoToMDG.generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            System.debug('********:');
            SyncCustomerInfoToMDG.ResDeta input_login = new SyncCustomerInfoToMDG.ResDeta();
            input_login = (SyncCustomerInfoToMDG.ResDeta) JSON.deserialize(bodyRes, SyncCustomerInfoToMDG.ResDeta.class);
            System.debug('input_login:'+input_login);
            
            if (input_login.SYNSTATUS == 'S' ) {

                System.debug('input_login.PARTNER='+input_login.PARTNER);
                System.debug('input_login.INSTID='+input_login.INSTID);
                //同步成功，更改记录类型，解锁部分字段
                if(objectName == 'Account'){
                    //update account SAPCode information
                    // Account accountTmp = new Account();
                    // Account accountTmp = [SELECT Id, Name, MDG_Customer_Code__c, SAP_Customer_Code__c, Approval_Status__c 
                    //                         FROM Account 
                    //                         WHERE Id =: cid 
                    //                         LIMIT 1];
                    // 历史数据的SAP编码保持不变
                    // 非A和E开头的客商编码,MDG客商编码前2位0补位 2024/12/2 18:00 start
                    // MDG可以同时接收补位和不补位的客商编码
                    if (!input_login.PARTNER.startsWith('A') && !input_login.PARTNER.startsWith('E')) {
                        account.MDG_Customer_Code__c = '00' + input_login.PARTNER;
                        // 历史数据的SAP编码保持不变
                        if (String.isEmpty(account.SAP_Customer_Code__c)) {
                            account.SAP_Customer_Code__c = '00' + input_login.PARTNER;
                        }
                    } else {
                        account.MDG_Customer_Code__c = input_login.PARTNER;
                        if (String.isEmpty(account.SAP_Customer_Code__c)) {
                            account.SAP_Customer_Code__c = input_login.PARTNER;
                        }
                    }

                    // 客户同步最新版本字段更改
                    // 生成唯一值
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    // 版本
                    account.Latest_Version__c = h;
                    account.Approval_Status__c = 'Approved';

                    if (companyList != null && companyList.size() > 0) {
                        for(Customer_Extend__c ce : companyList){
                            ce.Extend_or_Not__c = True;
                        }
                    }
                    if (salesList != null && salesList.size() > 0) {
                        for(Customer_Extend__c ce : salesList){
                            ce.Extend_or_Not__c = True;
                        }
                    }
                    if (customerBankList != null && customerBankList.size() > 0) {
                        for(Customer_Banks__c cb : customerBankList){
                            cb.Extend_or_Not__c = True;
                        }
                    }

                    //忽略触发器更新
                    GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
                    Database.update(account);
                    if (companyList != null && companyList.size() > 0) {
                        Database.update(companyList);
                    }
                    if (salesList != null && salesList.size() > 0) {
                        Database.update(salesList);
                    }
                    if (customerBankList != null && customerBankList.size() > 0) {
                        Database.update(customerBankList);
                    }
                    //恢复触发器
                    Utility.IgnoreAction(false,false,false,'');
                }
                insCustomerHistory(account, companyList, salesList);

                // 记录当前同步客户相关数据
                CustomerHistoryQueueable customerHistoryQueueable = new CustomerHistoryQueueable(customerId);
                ID jobID = System.enqueueJob(customerHistoryQueueable);
                Utility.insertLog('SyncCustomerInfoToMDGPro', '1', body, bodyRes);
            }else {
                //log
                Utility.insertLog('SyncCustomerInfoToMDGPro', '0', body, input_login.SYNRESULT);

                if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
                    List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
                    Utility.sendMail('SyncCustomerInfoToMDGPro接口失败：' + customerId, input_login.SYNRESULT, toAddress, 'Salesforce System', '');
                }
                // GetCustomerInfoFromECSS.GetCustomerInfoFromECSS(customerId);
                return input_login.SYNRESULT;
            }      
        }catch(Exception e) {
            Utility.IgnoreAction(false,false,false,'');
            //Integration Log
            Utility.insertLog('SyncCustomerInfoToMDGPro', '0', body, 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() + '-------' + bodyRes);

            if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
                List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
                Utility.sendMail('SyncCustomerInfoToMDG接口失败：' + customerId, 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() + '-------' + bodyRes, toAddress, 'Salesforce System', '');
            }
            
            // GetCustomerInfoFromECSS.GetCustomerInfoFromECSS(customerId);
            return 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage();
        }
        GetCustomerInfoFromECSS.GetCustomerInfoFromECSS(customerId);
        return 'SUCCESS'; 
    }

    public static void insCustomerHistory(Account account, List<Customer_Extend__c> companyList, List<Customer_Extend__c> salesList) {
        List<Customer_Sync_History__c> addList = new List<Customer_Sync_History__c>();
        if (account != null) {
            if(companyList != null && companyList.size() > 0){
                for(Customer_Extend__c ce : companyList){
                    Customer_Sync_History__c csHistory = new Customer_Sync_History__c();
                    csHistory.Customer__c = account.Id;
                    csHistory.CustomerContents__c = JSON.serialize(account);
                    csHistory.Customer_Extend__c = ce.Id;
                    csHistory.CustomerExtendContents__c = JSON.serialize(ce);
                    addList.add(csHistory);
                }
            }
            if(salesList != null && salesList.size() > 0){
                for(Customer_Extend__c ce : salesList){
                    Customer_Sync_History__c csHistory = new Customer_Sync_History__c();
                    csHistory.Customer__c = account.Id;
                    csHistory.CustomerContents__c = JSON.serialize(account);
                    csHistory.Customer_Extend__c = ce.Id;
                    csHistory.CustomerExtendContents__c = JSON.serialize(ce);
                    addList.add(csHistory);
                }
            }
        }
        if (addList != null) {
            insert addList;
        }
   }
}