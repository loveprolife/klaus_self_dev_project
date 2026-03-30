/**********************************************************************
* Name: SyncCustomerInfoToMDG
* Object: Account 
* Purpose: When customer get approved from salesforce,customer information
* send to MDG automatically
* Author: Chen Fen
* Create Date: 2024-10-29
*************************************************************************/
public without sharing class SyncCustomerInfoToMDG {

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
        public String ZTAX_CODE1;
        public Boolean ZTAX_CODE1_X;
        public String ZTAX_CODE2;
        public Boolean ZTAX_CODE2_X;
        public String ZTAX_JUR;
        public Boolean ZTAX_JUR_X;

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
        public String EIKTO;
        public Boolean EIKTO_X;

        public String ZKVGR1;
        public String ZKVGR3;
        public String ZKVGR4;
        public String ZKVGR5;
        public Boolean ZKVGR1_X;
        public Boolean ZKVGR3_X;
        public Boolean ZKVGR4_X;
        public Boolean ZKVGR5_X;

        public String PLTYP;
        public Boolean PLTYP_X;
    }
    
    public class taxCodn {
        public String ALAND;
        public String TATYP;
        //public Boolean TATYP_X;
        Public String TAXKD;
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
        Customer_Extend__c customerExtend  = new Customer_Extend__c();
        Customer_Banks__c customerBank = new Customer_Banks__c();
        Customer_Address__c cusAdd = new Customer_Address__c();
        String emailAddress = '';
        List<Customer_Banks__c> customerBankList = new List<Customer_Banks__c>();
        List<CustomerType> customerTypeList = new List<CustomerType>();
        List<taxCodn> taxCodnList = new List<taxCodn>();
        Boolean isUpdate = True;
        String extendId;
        List<Customer_Extend_Tax_category__c> extendTaxList = new List<Customer_Extend_Tax_category__c>();
        List<Customer_Tax_category__c> accountTaxList = new List<Customer_Tax_category__c>();
        List<Customer_Address_Tax_category__c> addressTaxList = new List<Customer_Address_Tax_category__c>();
        

        if(objectName == 'Customer_Extend__c'){
            customerExtend = [SELECT Id,Name,Customer__c,Shipping_Conditions__c,Related_to_POD__c,Payment_Method_MDG__c,E_commerce_Customer_Label__c,Delete_identification_for_company_region__c,
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
                                                  WHERE Id =: customerId];
            customerId = customerExtend.Customer__c;
        }else if(objectName == 'Customer_Banks__c'){
            customerBank = [SELECT Id,Name,Customer__c,Bank_Account__c,Bank_Account_Holder__c,Bank_Code__c,Bank_Control_Code__c,Bank_Country__c,Bank_Name__c,
                                                  Swift_Code__c, Reference_Detail__c,Bank_name_local_language__c,Bank_name_in_English__c,CurrencyIsoCode,IBAN__c
                                                  FROM Customer_Banks__c
                                                  WHERE Id =: customerId];

            customerId = customerBank.Customer__c;
        }else if(objectName == 'Customer_Address__c'){
            //Customer_Address__c检索 Customer_Extend__r.Customer_Status_MDG__c字段没有
            // 追加关联CustomerExtend和Customer上的公司视图字段
            cusAdd = [select id,Name,MDG_Code__c,Customer_Short_Name__c,Customer__c,Customer_Extend__c,Customer_Extend_Sales__c,Address_Description__c,
                        Street_2__c, Street_3__c, Street_4__c, Street_5__c,Transportation_area__c,
                        Country__c,City__c,City_CN__c,Province_State__c,District_CN__c,Township_CN__c,Postal_Code__c,
                        Customer_Name_EN_Language_1__c,Customer_Name_EN_Language_2__c,Customer_Name_Local_Language_1__c,Customer_Name_Local_Language_2__c,
                        Add_VAT_Reg_No__c,Customer_EDI_ID_Type__c,EDI_ID__c,EDI_ID2__c,
                        Global_Location_Number__c,Packing_Type__c,TV_lisense__c,Valid_to__c,VAT_Tax_type__c,
                        Email__c,Fax__c,Phone__c,Hisense_entity__c,Stor_Location__c,Reconciliation_Customer__c,Payment_Method_MDG__c,Create_View__c,Show_Company__c,
                        Trader_Type__c,CustomerDetailType__c,Payment_Term__c,Sales_Region__c,Tax_Number2__c,Tax_Number1__c,
                        District__c,SAP_Customer_Code__c,Search_Term2__c,Tax_Number4__c,VAT_Registration_Number__c,Tax_Number3__c,
                        Approval_Status__c,Hisense_Entity_Sales__c,Distribution_Channel__c,Product_Group__c,International_Trade_Terms__c,International_Trade_Terms_2__c,
                        Sales_Office__c,Sales_Group__c,Shipping_Conditions__c,Payment_Term_Sales__c,CurrencyIsoCode,Company_View_Freeze_markers__c,
                        Delete_identification_for_company_region__c,Sales_area_deletion_flag__c,Sales_View_Freeze_markers__c,Related_to_POD__c,
                        // 地址类客户的Company View 字段 从 Customer_Extend__r取
                        Customer_Extend__r.Company_View_Freeze_markers__c,Customer_Extend__r.Hisense_Entity__c,
                        Customer_Extend__r.Payment_Term__c,Customer_Extend__r.VAT_Tax_type__c,Customer_Extend__r.Stor_Location__c,
                        Customer_Extend__r.Reconciliation_Customer__c,Customer_Extend__r.Account_Remarks__c,Customer_Extend__r.Selection_Rule__c,
                        Customer_Extend__r.Payment_Method_MDG__c,Customer_Extend__r.Delete_identification_for_company_region__c,
                        Customer_Extend__r.EDI_ID__c,Customer_Extend__r.EDI_ID2__c,Customer_Extend__r.Customer_EDI_ID_Type__c,
                        Customer_Extend__r.TV_lisense__c,Customer_Extend__r.Valid_to__c,Customer_Extend__r.Packing_Type__c,Customer_Extend__r.Add_VAT_Reg_No__c,
                        // 地址类客户的Sales View 字段 从 Customer_Extend_Sales__r取
                        Customer_Extend_Sales__r.Hisense_Entity_Sales__c,Customer_Extend_Sales__r.Payment_Term_Sales__c,Customer_Extend_Sales__r.Product_Group__c,Customer_Extend_Sales__r.Distribution_Channel__c,
                        Customer_Extend_Sales__r.Sales_View_Freeze_markers__c,Customer_Extend_Sales__r.Customer_pricing_process__c,Customer_Extend_Sales__r.Sales_area_deletion_flag__c,
                        Customer_Extend_Sales__r.Price_Group__c,Customer_Extend_Sales__r.Sales_Office__c,Customer_Extend_Sales__r.Sales_Group__c,Customer_Extend_Sales__r.Related_to_POD__c,
                        Customer_Extend_Sales__r.International_Trade_Terms__c,Customer_Extend_Sales__r.International_Trade_Terms_2__c,Customer_Extend_Sales__r.CurrencyIsoCode,
                        Customer_Extend_Sales__r.Account_Assignment_Group__c,Customer_Extend_Sales__r.KDGRP__c,Customer_Extend_Sales__r.Shipping_Conditions__c,Customer_Extend_Sales__r.Deliverying_Plant__c,
                        Customer_Extend_Sales__r.Customer_Group2__c,Customer_Extend__r.Sales_Region__c,Customer_Extend__r.Tax_Classification__c,
                        // 地址类客户的主户字段
                        Customer__r.Language__c,Customer__r.MDG_Customer_Code__c,Customer__r.Hisense_Entity__c,Customer__r.Product_Group__c,Customer__r.Distribution_Channel__c,Customer__r.Customer_pricing_process__c,
                        Customer__r.Payment_Term__c,Customer__r.Sales_Region__c,Customer__r.Sales_area_deletion_flag__c,
                        Customer__r.Tax_Classification__c,Customer__r.Price_Group__c,Customer__r.Sales_Office__c,Customer__r.Hisense_Entity_Sales__c,Customer__r.Payment_Term_Sales__c,
                        Customer__r.Sales_Group__c,Customer__r.Related_to_POD__c,Customer__r.International_Trade_Terms__c,Customer__r.International_Trade_Terms_2__c,
                        Customer__r.CurrencyIsoCode,Customer__r.Account_Assignment_Group__c,Customer__r.KDGRP__c,Customer__r.Shipping_Conditions__c,
                        Customer__r.Deliverying_Plant__c,Customer__r.VAT_Tax_type__c,Customer__r.Customer_Group2__c,
                        Customer__r.Customer_Name_1__c,Customer__r.Customer_Name_2__c,Customer__r.Customer_Name_Local_Language__c,Customer__r.Customer_Name_Local_Language_2__c,
                        Customer__r.Reconciliation_Customer__c,Customer__r.Payment_Method_MDG__c,Customer__r.Sales_View_Freeze_markers__c,Customer__r.Company_View_Freeze_markers__c,
                        Customer__r.Selection_Rules__c,Customer__r.Account_Remarks__c,Customer__r.Delete_identification_for_company_region__c,
                        Customer__r.EDI_ID__c,Customer__r.EDI_ID2__c,Customer__r.Customer_EDI_ID_Type__c,
                        Customer__r.Street_2__c, Customer__r.Street_3__c, Customer__r.Street_4__c, Customer__r.Street_5__c,
                        Customer__r.TV_lisense__c,Customer__r.Valid_to__c,Customer__r.Packing_Type__c,Customer__r.Address__c,Customer__r.Stor_Location__c,
                        Customer__r.Add_VAT_Reg_No__c,Customer__r.Guarantor_Country_Code__c,Customer__r.Province_State__c,Customer__r.City_CN__c,Customer__r.City__c,Customer__r.District_CN__c,Customer__r.Township_CN__c,Customer__r.Postal_Code__c,Customer__r.Address_Description__c
                        from Customer_Address__c where Id =: customerId];
            
            //ID设定
            customerId = cusAdd.Customer__c;
            system.debug('cusAdd');
            system.debug(cusAdd);
            // 公司视图和销售视图拆分，税分类只从销售视图上取 2025.1.10更新规则  新建税表1.26 lzx
            if(cusAdd != null){
                addressTaxList = [Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Address_Tax_category__c where Customer__c = :cusAdd.Id];

            }

            //邮箱改为从Customer_Email__c取，格式 xxx@qq.com;xxx@qq.com
            List<Customer_Email__c> emailListAddress = [Select Email__c from Customer_Email__c where Customer_Address__c =:cusAdd.Id order by No__c];
            
            if(emailListAddress != null && emailListAddress.size() > 0){
                for(Customer_Email__c ce : emailListAddress){
                    emailAddress += (String.isNotBlank(ce.Email__c) ? ce.Email__c:'') + ';';
                }
                System.debug('emailAddress: ' + emailAddress);
            }

            
        }

            customerBankList = [SELECT Id,Name,Customer__c,Bank_Account__c,Bank_Account_Holder__c,Bank_Code__c,Bank_Control_Code__c,Bank_Country__c,Bank_Name__c,Bank_Account_Name__c,
                                                  Swift_Code__c, Reference_Detail__c,Bank_name_local_language__c,Bank_name_in_English__c,CurrencyIsoCode,IBAN__c
                                                  FROM Customer_Banks__c
                                                  WHERE Customer__c =: customerId and Approval_Status__c = 'Approved'];

        
        // Query customer data from salesforce.
        Account account = [SELECT Id,RecordType.Name,RecordType.DeveloperName,MDG_Customer_Code__c,Trader_Type__c,CustomerDetailType__c,Name,Customer_Short_Name__c,
        Street_2__c, Street_3__c, Street_4__c, Street_5__c, 
        Customer_Name_1__c,Customer_Name_2__c,Customer_Name_Local_Language__c,Customer_Name_Local_Language_2__c,Receiver__r.SAP_Customer_Code__c,Payer__r.SAP_Customer_Code__c,
        FormerName__c,ID_Type__c,Company_Registration_Number__c,DUNS_Number__c,VAT_Registration_Number__c,License_Expiration_Date__c,Payer__r.MDG_Customer_Code__c,Receiver__r.MDG_Customer_Code__c,
        Registration_Date__c,Registered_Capital__c,Paid_In_Funds__c,Corporate_Representative__c,Unit_Nature__c,Annual_Revenue_Scale__c,ParentCustomerOfSubAcc__c,
        Is_Listed_Company__c,Listed_Company_Code__c,Language__c,NumberOfEmployees,Website,Main_Business_Scope__c,Email__c,Fax,Phone,
        Industry_Sector__c,Belonged_Customer_Code__c,Customer_Status__c,Customer_Status_MDG__c,Customer_Risk_Level__c,Customer_Risk_Type__c,Unified_customer_group_code__c,
        Channel_Customer_Categories__c,Channel_Customer_Subcategories__c,Tax_Classification__c,Reconciliation_Customer__c,Payment_Method_MDG__c,
        Sub_account_type__c,Reasons_for_customer_segmentation__c,Tax_Number1__c,Tax_Number2__c,Guarantor_Country_Code__c,Province_State__c, City__c,
        Transportation_area__c, Supplier__c, Search_Term2__c, Tax_Number3__c, Tax_Number4__c,
        District__c,Town__c,Postal_Code__c,Address__c,Hisense_Entity__c,Distribution_Channel__c,Product_Group__c,Customer_pricing_process__c,
        Payment_Term__c,Sales_Region__c,Sales_Office__c, Sales_Group__c,Related_to_POD__c,International_Trade_Terms__c,International_Trade_Terms_2__c,
        Customer_Group_1__c, Customer_Group_3__c, Customer_Group_4__c, Customer_Group_5__c,Our_account_at_the_customer_s_place__c,
        CurrencyIsoCode,Account_Assignment_Group__c,KDGRP__c,Shipping_Conditions__c,Deliverying_Plant__c,VAT_Tax_type__c,Customer_Group2__c,Channel_Management_Classification__c,
        Client_Type__c,Global_Location_Number__c,E_commerce_Customer_Label__c,Sales_area_deletion_flag__c,Price_Group__c,credit_rating__c,Overseas_customer_level__c,
        City_CN__c,District_CN__c,Township_CN__c,Selection_Rules__c,Account_Remarks__c,Delete_identification_for_company_region__c,EDI_ID__c,EDI_ID2__c,Customer_EDI_ID_Type__c,
    TV_lisense__c,Valid_to__c,Packing_Type__c,Add_VAT_Reg_No__c,Company_View_Freeze_markers__c,Sales_View_Freeze_markers__c,Stor_Location__c,Hisense_Entity_Sales__c,Payment_Term_Sales__c,
        // 分户的Company View 字段 从 Customer_Extend___r取
        Customer_Extend_Sub_Account__r.Hisense_Entity__c,Customer_Extend_Sub_Account__r.Payment_Term__c,Customer_Extend_Sub_Account__r.Stor_Location__c,
        Customer_Extend_Sub_Account__r.Reconciliation_Customer__c,Customer_Extend_Sub_Account__r.Account_Remarks__c,Customer_Extend_Sub_Account__r.Selection_Rule__c,
        Customer_Extend_Sub_Account__r.Payment_Method_MDG__c,Customer_Extend_Sub_Account__r.Delete_identification_for_company_region__c,
        Customer_Extend_Sub_Account__r.EDI_ID__c,Customer_Extend_Sub_Account__r.EDI_ID2__c,Customer_Extend_Sub_Account__r.Customer_EDI_ID_Type__c,
        Customer_Extend_Sub_Account__r.TV_lisense__c,Customer_Extend_Sub_Account__r.Valid_to__c,Customer_Extend_Sub_Account__r.Packing_Type__c,Customer_Extend_Sub_Account__r.Add_VAT_Reg_No__c,
        Customer_Extend_Sub_Account__r.Company_View_Freeze_markers__c,Customer_Extend_Sub_Account__r.VAT_Tax_type__c,
        Customer_Extend_Sub_Account__r.Price_List__c,Customer_Extend_Sub_Account__r.Receiver__c,Customer_Extend_Sub_Account__r.Payback_Overdue_Number__c,Customer_Extend_Sub_Account__r.Payer__c,
        // 分户的Sales View 字段 从 Customer_Extend_Sales__r取
        Customer_Extend_Sales__r.Hisense_Entity_Sales__c,Customer_Extend_Sales__r.Payment_Term_Sales__c,Customer_Extend_Sales__r.Sales_area_deletion_flag__c,
        Customer_Extend_Sales__r.Sales_Region__c,Customer_Extend_Sales__r.Product_Group__c,Customer_Extend_Sales__r.Distribution_Channel__c,
        Customer_Extend_Sales__r.Customer_pricing_process__c,Customer_Extend_Sales__r.Price_Group__c,Customer_Extend_Sales__r.Sales_Office__c,
        Customer_Extend_Sales__r.Sales_Group__c,Customer_Extend_Sales__r.Related_to_POD__c,Customer_Extend_Sales__r.International_Trade_Terms__c,Customer_Extend_Sales__r.International_Trade_Terms_2__c,
        Customer_Extend_Sales__r.CurrencyIsoCode,Customer_Extend_Sales__r.Account_Assignment_Group__c,Customer_Extend_Sales__r.KDGRP__c,Customer_Extend_Sales__r.Shipping_Conditions__c,
        Customer_Extend_Sales__r.Deliverying_Plant__c,Customer_Extend_Sales__r.Customer_Group2__c,Customer_Extend_Sales__r.Sales_View_Freeze_markers__c,
        // 分户的主户字段
        ParentCustomerOfSubAcc__r.Selection_Rules__c,ParentCustomerOfSubAcc__r.Account_Remarks__c,ParentCustomerOfSubAcc__r.Delete_identification_for_company_region__c,
        ParentCustomerOfSubAcc__r.Street_2__c, ParentCustomerOfSubAcc__r.Street_3__c, ParentCustomerOfSubAcc__r.Street_4__c, ParentCustomerOfSubAcc__r.Street_5__c,
        ParentCustomerOfSubAcc__r.EDI_ID__c,ParentCustomerOfSubAcc__r.EDI_ID2__c,ParentCustomerOfSubAcc__r.Customer_EDI_ID_Type__c,
        ParentCustomerOfSubAcc__r.TV_lisense__c,ParentCustomerOfSubAcc__r.Valid_to__c,ParentCustomerOfSubAcc__r.Packing_Type__c,ParentCustomerOfSubAcc__r.Stor_Location__c,
        ParentCustomerOfSubAcc__r.Add_VAT_Reg_No__c,ParentCustomerOfSubAcc__r.VAT_Tax_type__c,ParentCustomerOfSubAcc__r.Company_View_Freeze_markers__c,ParentCustomerOfSubAcc__r.Sales_View_Freeze_markers__c,
        ParentCustomerOfSubAcc__r.credit_rating__c,ParentCustomerOfSubAcc__r.Overseas_customer_level__c,ParentCustomerOfSubAcc__r.Reconciliation_Customer__c,
        ParentCustomerOfSubAcc__r.Trader_Type__c,ParentCustomerOfSubAcc__r.CustomerDetailType__c,ParentCustomerOfSubAcc__r.Name,
        ParentCustomerOfSubAcc__r.Customer_Name_1__c,ParentCustomerOfSubAcc__r.Customer_Name_2__c,ParentCustomerOfSubAcc__r.Customer_Name_Local_Language__c,ParentCustomerOfSubAcc__r.Customer_Name_Local_Language_2__c,
        ParentCustomerOfSubAcc__r.Customer_Short_Name__c,ParentCustomerOfSubAcc__r.FormerName__c,ParentCustomerOfSubAcc__r.ID_Type__c,ParentCustomerOfSubAcc__r.Company_Registration_Number__c,Address_Type__c,
        ParentCustomerOfSubAcc__r.DUNS_Number__c,ParentCustomerOfSubAcc__r.VAT_Registration_Number__c,ParentCustomerOfSubAcc__r.License_Expiration_Date__c,ParentCustomerOfSubAcc__r.Registration_Date__c,
        ParentCustomerOfSubAcc__r.Registered_Capital__c,ParentCustomerOfSubAcc__r.Paid_In_Funds__c,ParentCustomerOfSubAcc__r.Corporate_Representative__c,ParentCustomerOfSubAcc__r.Unit_Nature__c,
        ParentCustomerOfSubAcc__r.Annual_Revenue_Scale__c,ParentCustomerOfSubAcc__r.Is_Listed_Company__c,ParentCustomerOfSubAcc__r.Listed_Company_Code__c,ParentCustomerOfSubAcc__r.Language__c,
        ParentCustomerOfSubAcc__r.NumberOfEmployees,ParentCustomerOfSubAcc__r.Website,ParentCustomerOfSubAcc__r.Main_Business_Scope__c,ParentCustomerOfSubAcc__r.Email__c,ParentCustomerOfSubAcc__r.Fax,
        ParentCustomerOfSubAcc__r.Phone,ParentCustomerOfSubAcc__r.Industry_Sector__c,ParentCustomerOfSubAcc__r.Belonged_Customer_Code__c,ParentCustomerOfSubAcc__r.Customer_Status__c,ParentCustomerOfSubAcc__r.Customer_Status_MDG__c,
        ParentCustomerOfSubAcc__r.Customer_Risk_Level__c,ParentCustomerOfSubAcc__r.Customer_Risk_Type__c,ParentCustomerOfSubAcc__r.Unified_customer_group_code__c,ParentCustomerOfSubAcc__r.Channel_Customer_Categories__c,
        ParentCustomerOfSubAcc__r.Channel_Customer_Subcategories__c,ParentCustomerOfSubAcc__r.Tax_Classification__c,ParentCustomerOfSubAcc__r.Hisense_Entity_Sales__c,ParentCustomerOfSubAcc__r.Payment_Term_Sales__c,
        ParentCustomerOfSubAcc__r.Transportation_area__c,ParentCustomerOfSubAcc__r.Sub_account_type__c,ParentCustomerOfSubAcc__r.Reasons_for_customer_segmentation__c,ParentCustomerOfSubAcc__r.Tax_Number1__c,
        ParentCustomerOfSubAcc__r.Tax_Number2__c,ParentCustomerOfSubAcc__r.Guarantor_Country_Code__c,ParentCustomerOfSubAcc__r.Province_State__c,ParentCustomerOfSubAcc__r.City__c,
        ParentCustomerOfSubAcc__r.District__c,ParentCustomerOfSubAcc__r.Town__c,ParentCustomerOfSubAcc__r.Postal_Code__c,ParentCustomerOfSubAcc__r.Address__c,ParentCustomerOfSubAcc__r.Hisense_Entity__c,
        ParentCustomerOfSubAcc__r.Distribution_Channel__c,ParentCustomerOfSubAcc__r.Payment_Term__c,ParentCustomerOfSubAcc__r.Sales_Region__c,ParentCustomerOfSubAcc__r.Product_Group__c,ParentCustomerOfSubAcc__r.Customer_pricing_process__c,
        ParentCustomerOfSubAcc__r.Sales_Office__c,ParentCustomerOfSubAcc__r.Sales_Group__c,ParentCustomerOfSubAcc__r.Related_to_POD__c,ParentCustomerOfSubAcc__r.International_Trade_Terms__c,
        ParentCustomerOfSubAcc__r.International_Trade_Terms_2__c,ParentCustomerOfSubAcc__r.CurrencyIsoCode,ParentCustomerOfSubAcc__r.Account_Assignment_Group__c,ParentCustomerOfSubAcc__r.KDGRP__c,ParentCustomerOfSubAcc__r.Shipping_Conditions__c,
        ParentCustomerOfSubAcc__r.Deliverying_Plant__c,ParentCustomerOfSubAcc__r.Customer_Group2__c,ParentCustomerOfSubAcc__r.Channel_Management_Classification__c,
        ParentCustomerOfSubAcc__r.Client_Type__c,ParentCustomerOfSubAcc__r.Price_Group__c,ParentCustomerOfSubAcc__r.Address_Type__c,ParentCustomerOfSubAcc__r.Global_Location_Number__c,ParentCustomerOfSubAcc__r.E_commerce_Customer_Label__c,ParentCustomerOfSubAcc__r.Sales_area_deletion_flag__c,
        ParentCustomerOfSubAcc__r.City_CN__c,ParentCustomerOfSubAcc__r.District_CN__c,ParentCustomerOfSubAcc__r.Township_CN__c,ParentCustomerOfSubAcc__r.Payment_Method_MDG__c,
        ParentCustomerOfSubAcc__r.MDG_Customer_Code__c,ParentCustomerOfSubAcc__r.Our_account_at_the_customer_s_place__c,
        (Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Tax_category__r)
        FROM Account Where Id = :customerId];

        //邮箱改为从Customer_Email__c取，格式 xxx@qq.com;xxx@qq.com
        List<Customer_Email__c> emailList = [Select Email__c from Customer_Email__c where Customer__c =:account.Id order by No__c];
        String emailAccount = '';
        if(emailList != null && emailList.size() > 0){
            for(Customer_Email__c ce : emailList){
                emailAccount+= (String.isNotBlank(ce.Email__c) ? ce.Email__c:'') + ';';
            }
            System.debug('emailAccount: ' + emailAccount);
        }
        
        // MDG Account Master Data 获取MDG 代码映射表
        Map<String, MDG_Client_Mapping__mdt> clientMappingMap = new Map<String, MDG_Client_Mapping__mdt>();
        for (MDG_Client_Mapping__mdt mapping : [SELECT Id,MasterLabel, DeveloperName,MDG_SFDC_Name__c,MDG_Description__c, MDG_Code__c, MDG_Sub_Code__c FROM MDG_Client_Mapping__mdt]) {
            clientMappingMap.put(mapping.MDG_SFDC_Name__c, mapping);
        }

        //账期的ID和Code的Map
        Map<String,String> paymentTermId2CodeMap = new Map<String,String>();
        // 主户拆分销售视图的Hisense Entity和Payment Term 2025.1.10
        String paymentSalesId = '';
        if(objectName == 'Customer_Extend__c'){
            paymentId = customerExtend.Payment_Term__c;
            paymentSalesId = customerExtend.Payment_Term_Sales__c == null ? '' : customerExtend.Payment_Term_Sales__c;
        }else{
            if (account.recordtype.DeveloperName == 'Sub_Account') {
                // 地址类客户和分户的公司视图销售视图信息不再从主户取，必须选择公司视图或者销售视图或者都选 2025.1.10
                // if (String.isNotEmpty(account.Customer_Extend_Sub_Account__c)) {
                if (String.isNotEmpty(account.Hisense_Entity__c)) {
                    // paymentId = account.Customer_Extend_Sub_Account__r.Payment_Term__c;
                    paymentId = account.Payment_Term__c;
                } 
                // if (String.isNotEmpty(account.Customer_Extend_Sales__c)) {
                if (String.isNotEmpty(account.Hisense_Entity_Sales__c)) {
                    // paymentSalesId = account.Customer_Extend_Sales__r.Payment_Term_Sales__c;
                    paymentSalesId = account.Payment_Term_Sales__c;
                }
            } else {
                // 地址类客户和分户的公司视图销售视图信息不再从主户取，必须选择公司视图或者销售视图或者都选 2025.1.10
                paymentId = account.Payment_Term__c;
                paymentSalesId = account.Payment_Term_Sales__c;
            }
        }

        // 地址类客户和分户的公司视图销售视图信息不再从主户取，必须选择公司视图或者销售视图或者都选 2025.1.10
        if (objectName == 'Customer_Address__c') {
            if (cusAdd.Payment_Term__c != null) {
                paymentId = cusAdd.Payment_Term__c;
            }
            if (cusAdd.Payment_Term_Sales__c != null) {
                paymentSalesId = cusAdd.Payment_Term_Sales__c;
            }
        }

        // 主户拆分公司视图的Hisense Entity和Payment Term 2025.1.9
        if (String.isNotEmpty(paymentId)) {
            for(Payment_Term__c ptc : [Select id,name from Payment_Term__c where id =: paymentId]){
                paymentTermId2CodeMap.put(ptc.Id, ptc.Name);
            }
        }

        // 主户拆分公司视图的Hisense Entity和Payment Term 2025.1.9
        if (String.isNotEmpty(paymentSalesId)) {
            for(Payment_Term__c ptc : [Select id,name from Payment_Term__c where id =: paymentSalesId]){
                paymentTermId2CodeMap.put(ptc.Id, ptc.Name);
            }    
        }
        //国家省市map
        Map<String,String> countryStateMap = new Map<String,String>();
        List<String> countryStateList = new List<String>();
        if (account.ParentCustomerOfSubAcc__c != null && String.isNotEmpty(account.ParentCustomerOfSubAcc__r.Province_State__c)) {
            countryStateList.add(account.ParentCustomerOfSubAcc__r.Province_State__c);
        }
        if (objectName == 'Customer_Address__c') {
            if (cusAdd.Customer__c != null && String.isNotEmpty(cusAdd.Customer__r.Province_State__c)) {
                countryStateList.add(cusAdd.Customer__r.Province_State__c);
            }
            if (cusAdd.Customer__c != null && String.isNotEmpty(cusAdd.Customer__r.City_CN__c)) {
                countryStateList.add(cusAdd.Customer__r.City_CN__c);
            }
            if (cusAdd.Customer__c != null && String.isNotEmpty(cusAdd.Customer__r.District_CN__c)) {
                countryStateList.add(cusAdd.Customer__r.District_CN__c);
            }
            if (cusAdd.Customer__c != null && String.isNotEmpty(cusAdd.Customer__r.Township_CN__c)) {
                countryStateList.add(cusAdd.Customer__r.Township_CN__c);
            }
            if (String.isNotEmpty(cusAdd.Province_State__c)) {
                countryStateList.add(cusAdd.Province_State__c);
            }
            if (String.isNotEmpty(cusAdd.City_CN__c)) {
                countryStateList.add(cusAdd.City_CN__c);
            }
            if (String.isNotEmpty(cusAdd.District_CN__c)) {
                countryStateList.add(cusAdd.District_CN__c);
            }
            if (String.isNotEmpty(cusAdd.Township_CN__c)) {
                countryStateList.add(cusAdd.Township_CN__c);
            }
        }
        if (String.isNotEmpty(account.Province_State__c)) {
            countryStateList.add(account.Province_State__c);
        }
        if (String.isNotEmpty(account.City_CN__c)) {
            countryStateList.add(account.City_CN__c);
        }
        if (String.isNotEmpty(account.District_CN__c)) {
            countryStateList.add(account.District_CN__c);
        }
        if (String.isNotEmpty(account.Township_CN__c)) {
            countryStateList.add(account.Township_CN__c);
        }
        for(Country_State__c psc : [Select id,Name__c from Country_State__c WHERE id IN: countryStateList]){
            countryStateMap.put(psc.Id,psc.Name__c);
        }
        System.debug('countryStateMap... '+countryStateMap);
        //销售组、销售办公室map
        Map<String,String> picklistId2CodeMap = new Map<String,String>();
        for(PickList__c plc : [select id,name,Value__c from PickList__c WHERE RecordType.Name = 'Master Data(Office)' OR RecordType.Name = 'Master(Location)' OR RecordType.Name = 'Master(Storage Location)' OR RecordType.Name = 'Master Data(team)']){
            picklistId2CodeMap.put(plc.Id,plc.Value__c);
        }
        if (account != null) {
            //发送方系统ID
            IV_INPUT.SENDER = 'S0218';
            
            //接口唯一ID
            IV_INPUT.INSTID = account.Id == null ? '': account.Id + dtStart.format('yyyyMMddHHmmss');
            //处理模式
            if(account.MDG_Customer_Code__c == null || account.MDG_Customer_Code__c == ''){
               IV_INPUT.PMODE = 'I';
               isUpdate = false;
            }else{
                IV_INPUT.PMODE = 'M';
            }

            // 地址类客户的场合
            if (objectName == 'Customer_Address__c') {
                //处理模式
                if(cusAdd.MDG_Code__c == null || cusAdd.MDG_Code__c == ''){
                
                   IV_INPUT.PMODE = 'I';
                   isUpdate = false;
                }else{
                    IV_INPUT.PMODE = 'M';
                }
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
            if (String.isEmpty(customerInfo.PARTNER) && account.recordtype.Name == 'Staff') {
                customerInfo.PARTNER = 'E' + account.Company_Registration_Number__c;
            }
            //客商类型
            customerInfo.BU_GROUP = account.Trader_Type__c == null ? '': account.Trader_Type__c;
            //客商明细类型
            customerInfo.ZZMXLX = account.CustomerDetailType__c == null ? '': account.CustomerDetailType__c;
            
            // Part 1: 分户客户
            //当客户类型是分户时,取分户所属客户信息 ------------- 修改：取分户自身信息 wfc 2025-01-25
            // if(account.recordtype.Name == 'Sub Account' && objectName != 'Customer_Address__c'){
            //     // if(account.recordtype.Name == 'Sub Account' && objectName == 'Account'){

            //     //客商名称（当地语言）MDG把原来的NameEN和NameLocal对换 2025.1.16
            //     customerInfo.NAME_LO=account.Name == null ? '': account.Name;
            //     //客商名称（当地语言）修改标识
            //     customerInfo.NAME_LO_X = isUpdate;
            //     //客商名称（英文）
            //     customerInfo.NAME_EN = account.Customer_Name_Local_Language__c == null ? '': account.Customer_Name_Local_Language__c;
            //     //客商名称（英文）修改标识
            //     customerInfo.NAME_EN_X = isUpdate;
            //     //简称
            //     // customerInfo.BU_SORT1 = account.ParentCustomerOfSubAcc__r.Customer_Short_Name__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_Short_Name__c;
            //     customerInfo.BU_SORT1 = account.Customer_Short_Name__c == null ? '': account.Customer_Short_Name__c;
            //     //简称1修改标识
            //     customerInfo.BU_SORT1_X = isUpdate;
            //     //曾用名
            //     // customerInfo.ZZFONM = account.ParentCustomerOfSubAcc__r.FormerName__c == null ? '': account.ParentCustomerOfSubAcc__r.FormerName__c;
            //     customerInfo.ZZFONM = account.FormerName__c == null ? '': account.FormerName__c;
            //     //曾用名修改标识
            //     customerInfo.ZZFONM_X = isUpdate;
            //     //证件类型
            //     customerInfo.ZZZJLX = account.ID_Type__c == null ? '': account.ID_Type__c;
            //     //证件类型修改标识
            //     customerInfo.ZZZJLX_X = isUpdate;
            //     //注册码
            //     customerInfo.ZZRENO = account.Company_Registration_Number__c == null ? '': account.Company_Registration_Number__c;
            //     //注册码修改标识
            //     customerInfo.ZZRENO_X = isUpdate;
            //     //DUNS编号
            //     // customerInfo.ZZDUNS = account.ParentCustomerOfSubAcc__r.DUNS_Number__c == null ? '': account.ParentCustomerOfSubAcc__r.DUNS_Number__c;
            //     customerInfo.ZZDUNS = account.DUNS_Number__c == null ? '': account.DUNS_Number__c;
            //     //DUNS编号修改标识
            //     customerInfo.ZZDUNS_X = isUpdate;
            //     //VAT编号
            //     customerInfo.ZZVAT = account.VAT_Registration_Number__c == null ? '': account.VAT_Registration_Number__c;
            //     //VAT编号修改标识
            //     customerInfo.ZZVAT_X = isUpdate;
            //     if(account.ParentCustomerOfSubAcc__r.License_Expiration_Date__c != null){
            //     //营业执照到日期
            //     // customerInfo.ZZBLED = dateToString(account.ParentCustomerOfSubAcc__r.License_Expiration_Date__c);
            //     customerInfo.ZZBLED = dateToString(account.License_Expiration_Date__c);
            //     //营业执照到日期修改标识
            //     customerInfo.ZZBLED_X = isUpdate;

            //     }
            //     // if(account.ParentCustomerOfSubAcc__r.Registration_Date__c != null){
            //     if(account.Registration_Date__c != null){
            //     //注册日期
            //     // customerInfo.FOUND_DAT = account.ParentCustomerOfSubAcc__r.Registration_Date__c == null ? '': dateToString(account.ParentCustomerOfSubAcc__r.Registration_Date__c);
            //     customerInfo.FOUND_DAT = account.Registration_Date__c == null ? '': dateToString(account.Registration_Date__c);
            //     //注册日期修改标识
            //     customerInfo.FOUND_DAT_X = isUpdate;

            //     }
            //     //注册资金
            //     // customerInfo.ZZREFD = account.ParentCustomerOfSubAcc__r.Registered_Capital__c;
            //     customerInfo.ZZREFD = account.Registered_Capital__c;
            //     //注册资金修改标识
            //     customerInfo.ZZREFD_X = isUpdate;
            //     //实缴资金
            //     // customerInfo.ZZPDFD = account.ParentCustomerOfSubAcc__r.Paid_In_Funds__c;
            //     customerInfo.ZZPDFD = account.Paid_In_Funds__c;
            //     //实缴资金修改标识
            //     customerInfo.ZZPDFD_X = isUpdate;
            //     //法定代表人
            //     // customerInfo.ZZLERE = account.ParentCustomerOfSubAcc__r.Corporate_Representative__c == null ? '': account.ParentCustomerOfSubAcc__r.Corporate_Representative__c;
            //     customerInfo.ZZLERE = account.Corporate_Representative__c == null ? '': account.Corporate_Representative__c;
            //     //法定代表人修改标识
            //     customerInfo.ZZLERE_X = isUpdate;
            //     //单位性质
            //     // customerInfo.ZZCMAT = account.ParentCustomerOfSubAcc__r.Unit_Nature__c == null ? '': account.ParentCustomerOfSubAcc__r.Unit_Nature__c;
            //     customerInfo.ZZCMAT = account.Unit_Nature__c == null ? '': account.Unit_Nature__c;
            //     //单位性质修改标识
            //     customerInfo.ZZCMAT_X = isUpdate;
            //     //年度营业收入规模
            //     // customerInfo.ZZANRE = account.ParentCustomerOfSubAcc__r.Annual_Revenue_Scale__c == null ? '': account.ParentCustomerOfSubAcc__r.Annual_Revenue_Scale__c;
            //     customerInfo.ZZANRE = account.Annual_Revenue_Scale__c == null ? '': account.Annual_Revenue_Scale__c;
            //     //年度营业收入规模修改标识
            //     customerInfo.ZZANRE_X = isUpdate;
            //     //是否上市公司
            //     // customerInfo.ZZIFCM = account.ParentCustomerOfSubAcc__r.Is_Listed_Company__c;
            //     customerInfo.ZZIFCM = account.Is_Listed_Company__c;
            //     //是否上市公司修改标识
            //     customerInfo.ZZIFCM_X = isUpdate;
            //     //上市公司代码
            //     // customerInfo.ZZCMCO = account.ParentCustomerOfSubAcc__r.Listed_Company_Code__c == null ? '': account.ParentCustomerOfSubAcc__r.Listed_Company_Code__c;
            //     customerInfo.ZZCMCO = account.Listed_Company_Code__c == null ? '': account.Listed_Company_Code__c;
            //     //上市公司代码修改标识
            //     customerInfo.ZZCMCO_X = isUpdate;
            //     //语言
            //     // customerInfo.BU_LANGU = account.ParentCustomerOfSubAcc__r.Language__c == null ? '': account.ParentCustomerOfSubAcc__r.Language__c;
            //     customerInfo.BU_LANGU = account.Language__c == null ? '': account.Language__c;
            //     //语言修改标识
            //     customerInfo.BU_LANGU_X = isUpdate;
            //     //员工人数
            //     // customerInfo.ZZEMCN = account.ParentCustomerOfSubAcc__r.NumberOfEmployees;
            //     customerInfo.ZZEMCN = account.NumberOfEmployees;
            //     //员工人数修改标识
            //     customerInfo.ZZEMCN_X = isUpdate;
            //     //公司网站
            //     // customerInfo.URI_ADDR = account.ParentCustomerOfSubAcc__r.Website == null ? '': account.ParentCustomerOfSubAcc__r.Website;
            //     customerInfo.URI_ADDR = account.Website == null ? '': account.Website;
            //     //公司网站修改标识
            //     customerInfo.URI_ADDR_X = isUpdate;
            //     //经营范围
            //     // customerInfo.ZZBNAR = account.ParentCustomerOfSubAcc__r.Main_Business_Scope__c == null ? '': account.ParentCustomerOfSubAcc__r.Main_Business_Scope__c;
            //     customerInfo.ZZBNAR = account.Main_Business_Scope__c == null ? '': account.Main_Business_Scope__c;
            //     //经营范围修改标识
            //     customerInfo.ZZBNAR_X= isUpdate;
            //     //官方邮箱
            //     //customerInfo.SMTP_ADDR = account.Email__c == null ? '': account.Email__c;
            //     customerInfo.SMTP_ADDR = emailAccount;
            //     //官方邮箱修改标识
            //     customerInfo.SMTP_ADDR_X = isUpdate;
            //     //传真号码
            //     // customerInfo.FAX_NUMBER = account.ParentCustomerOfSubAcc__r.Fax == null ? '': account.ParentCustomerOfSubAcc__r.Fax;
            //     customerInfo.FAX_NUMBER = account.Fax == null ? '': account.Fax;
            //     //传真号码修改标识
            //     customerInfo.FAX_NUMBER_X = isUpdate;
            //     //联系电话
            //     // customerInfo.TEL_NUMBER = account.ParentCustomerOfSubAcc__r.Phone == null ? '': account.ParentCustomerOfSubAcc__r.Phone;
            //     customerInfo.TEL_NUMBER = account.Phone == null ? '': account.Phone;
            //     //联系电话修改标识
            //     customerInfo.TEL_NUMBER_X = isUpdate;
            //     //行业(国标二级)
            //     // customerInfo.IND_SECTOR = account.ParentCustomerOfSubAcc__r.Industry_Sector__c == null ? '': account.ParentCustomerOfSubAcc__r.Industry_Sector__c;
            //     customerInfo.IND_SECTOR = account.Industry_Sector__c == null ? '': account.Industry_Sector__c;
            //     //行业(国标二级)修改标识
            //     customerInfo.IND_SECTOR_X = isUpdate;
            //     //所属客商编码
            //     customerInfo.ZZCVCO = account.Belonged_Customer_Code__c == null ? '': account.Belonged_Customer_Code__c;
            //     //所属客商编码修改标识
            //     customerInfo.ZZCVCO_X = isUpdate;
            //     //客户状态
            //     customerInfo.ZZCUSTA = account.Customer_Status_MDG__c == null ? '': account.Customer_Status_MDG__c;
            //     //客户状态修改标识
            //     customerInfo.ZZCUSTA_X = isUpdate;
            //     //客户风险等级
            //     // customerInfo.ZZCUSRISL = account.ParentCustomerOfSubAcc__r.Customer_Risk_Level__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_Risk_Level__c;
            //     customerInfo.ZZCUSRISL = account.Customer_Risk_Level__c == null ? '': account.Customer_Risk_Level__c;
            //     //客户风险等级修改标识
            //     customerInfo.ZZCUSRISL_X = isUpdate;
            //     //客户风险类型
            //     // customerInfo.ZZCUSRITY = account.ParentCustomerOfSubAcc__r.Customer_Risk_Type__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_Risk_Type__c;
            //     customerInfo.ZZCUSRITY = account.Customer_Risk_Type__c == null ? '': account.Customer_Risk_Type__c;
            //     //客户风险类型修改标识
            //     customerInfo.ZZCUSRITY_X = isUpdate;
            //     //统一客户组编码
            //     // customerInfo.ZZCUSGR = account.ParentCustomerOfSubAcc__r.Unified_customer_group_code__c == null ? '': account.ParentCustomerOfSubAcc__r.Unified_customer_group_code__c;
            //     customerInfo.ZZCUSGR = account.Unified_customer_group_code__c == null ? '': account.Unified_customer_group_code__c;
            //     //统一客户组编码修改标识
            //     customerInfo.ZZCUSGR_X = isUpdate;
            //     //渠道客户大类
            //     // customerInfo.ZZCHCUSCA = account.ParentCustomerOfSubAcc__r.Channel_Customer_Categories__c == null ? '': account.ParentCustomerOfSubAcc__r.Channel_Customer_Categories__c;
            //     customerInfo.ZZCHCUSCA = account.Channel_Customer_Categories__c == null ? '': account.Channel_Customer_Categories__c;
            //     //渠道客户大类修改标识
            //     customerInfo.ZZCHCUSCA_X = isUpdate;
            //     //渠道客户小类
            //     // customerInfo.ZZCHCUSSU = account.ParentCustomerOfSubAcc__r.Channel_Customer_Subcategories__c == null ? '': account.ParentCustomerOfSubAcc__r.Channel_Customer_Subcategories__c;
            //     customerInfo.ZZCHCUSSU = account.Channel_Customer_Subcategories__c == null ? '': account.Channel_Customer_Subcategories__c;
            //     //渠道客户小类修改标识
            //     customerInfo.ZZCHCUSSU_X = isUpdate;
            //     //信用等级
            //     // customerInfo.ZZCRERAT = account.ParentCustomerOfSubAcc__r.credit_rating__c == null ? '': account.ParentCustomerOfSubAcc__r.credit_rating__c;
            //     customerInfo.ZZCRERAT = account.credit_rating__c == null ? '': account.credit_rating__c;
            //     //信用等级修改标识
            //     customerInfo.ZZCRERAT_X = isUpdate;
            //     //渠道管理分类
            //     customerInfo.ZZCHMACLA = '10';
            //     //渠道管理分类修改标识
            //     customerInfo.ZZCHMACLA_X = isUpdate;
            //     //海外客户分级
            //     // customerInfo.ZZHWKHFJ = account.ParentCustomerOfSubAcc__r.Overseas_customer_level__c == null ? '': account.ParentCustomerOfSubAcc__r.Overseas_customer_level__c;
            //     customerInfo.ZZHWKHFJ = account.Overseas_customer_level__c == null ? '': account.Overseas_customer_level__c;
            //     //海外客户分级修改标识
            //     customerInfo.ZZHWKHFJ_X = isUpdate;
            //     //运输区域
            //     // customerInfo.LZONE = account.ParentCustomerOfSubAcc__r.Transportation_area__c == null ? '': account.ParentCustomerOfSubAcc__r.Transportation_area__c;
            //     customerInfo.LZONE = account.Transportation_area__c == null ? '': account.Transportation_area__c;
            //     //运输区域修改标识
            //     customerInfo.LZONE_X = isUpdate;
            //     //分户类型
            //     customerInfo.ZZFHLX = account.Sub_account_type__c == null ? '': account.Sub_account_type__c;
            //     //分户类型修改标识
            //     customerInfo.ZZFHLX_X = isUpdate;
            //     // 分户类型为付款条件分户，填写新的付款条件
            //     if ('13'.equals(account.Sub_account_type__c)) {
            //         //付款条件
            //         customerInfo.ZZFHYY = account.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
            //     } else {
            //         //分户原因
            //         customerInfo.ZZFHYY = account.Reasons_for_customer_segmentation__c == null ? '': account.Reasons_for_customer_segmentation__c;
            //     }
            //     //分户原因修改标识
            //     customerInfo.ZZFHYY_X = isUpdate;
            //     //GLN码-1
            //     customerInfo.BBBNR = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(0,7);
            //     //GLN码-1修改标识
            //     customerInfo.BBBNR_X = isUpdate;
            //     //GLN码-2
            //     customerInfo.BBSNR = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(7,12);
            //     //GLN码-2修改标识
            //     customerInfo.BBSNR_X = isUpdate;
            //     //GLN码-3
            //     customerInfo.BUBKZ = account.Global_Location_Number__c == null ? '': account.Global_Location_Number__c.substring(12,13);
            //     //GLN码-3修改标识
            //     customerInfo.BUBKZ_X = isUpdate;
            //     //线上/线下 
            //     customerInfo.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
            //     //线上/线下修改标识
            //     customerInfo.ZZLINE_X = isUpdate;
            //     //税码1
            //     customerInfo.ZTAX_CODE1 = account.Tax_Number1__c == null ? '': account.Tax_Number1__c;
            //     //税码1修改标识
            //     customerInfo.ZTAX_CODE1_X = isUpdate;
            //     //税码2
            //     customerInfo.ZTAX_CODE2 = account.Tax_Number2__c == null ? '': account.Tax_Number2__c;
            //     //税码2修改标识
            //     customerInfo.ZTAX_CODE2_X = isUpdate;
            //     //税管辖区域
            //     customerInfo.ZTAX_JUR  = '';
            //     //税管辖区域修改标识
            //     customerInfo.ZTAX_JUR_X = isUpdate;
            //     //地址类型
            //     addr.ZZADTY = '01';
            //     //国家
            //     addr.LAND1 = account.Guarantor_Country_Code__c == null ? '': account.Guarantor_Country_Code__c;
            //     //国家修改标识
            //     addr.LAND1_X = isUpdate;
            //     //省份
            //     addr.REGIO = account.Province_State__c == null ? '': countryStateMap.get(account.Province_State__c);
            //     //省份修改标识
            //     addr.REGIO_X = isUpdate;
            //     if(account.Guarantor_Country_Code__c == 'CN'){
            //         //城市
            //         addr.ORT01 = account.City_CN__c == null ? '': countryStateMap.get(account.City_CN__c);
            //         //城市修改标识
            //         addr.ORT01_X = isUpdate;
            //         //区县
            //         addr.ORT02 = account.District_CN__c == null ? '': countryStateMap.get(account.District_CN__c);
            //         //区县修改标识
            //         addr.ORT02_X = isUpdate;
            //         //乡镇
            //         addr.ZZTOWN = account.Township_CN__c == null ? '': countryStateMap.get(account.Township_CN__c);
            //         //乡镇修改标识
            //         addr.ZZTOWN_X = isUpdate;
    
            //     }else{
            //         //城市
            //         addr.ORT01 = account.City__c == null ? '': account.City__c;
            //         //城市修改标识
            //         addr.ORT01_X = isUpdate;
            //         //区县
            //         addr.ORT02 = account.District__c == null ? '': account.District__c;
            //         //区县修改标识
            //         addr.ORT02_X = isUpdate;
            //         //乡镇
            //         addr.ZZTOWN = account.Town__c == null ? '': account.Town__c;
            //         //乡镇修改标识
            //         addr.ZZTOWN_X = isUpdate;
            //     }
            //     //邮编
            //     addr.POST_CODE1 = account.Postal_Code__c == null ? '': account.Postal_Code__c;
            //     //邮编修改标识
            //     addr.POST_CODE1_X = isUpdate;
            //     //地址描述
            //     addr.FSTRAS = account.Address__c == null ? '': account.Address__c;
            //     //地址描述修改标识
            //     addr.FSTRAS_X = isUpdate;

            //     // Part1.1 分户增加字段--Customer Extend，只允许用户选择主户的公司拓展，
            //     // 如果分户上的Customer Extend字段不为空，分户同步时，公司视图和销售视图的信息会从对应的公司拓展上获取
            //     // 2024.12.29 UAT测试时，需求变更

            //     system.debug('account.Customer_Extend_Sub_Account__c');
            //     system.debug(account.Customer_Extend_Sub_Account__c);

            //     // if (account.Customer_Extend_Sub_Account__c != null) {
            //     if (account.Hisense_Entity__c != null) {

            //         companyView = getSubAccountCompanyView(account, paymentTermId2CodeMap, picklistId2CodeMap, isUpdate);
            //         if (String.isNotEmpty(companyView.BUKRS)) {
            //             companyViewList.add(companyView);
            //         }
            //     }
            //     // if (account.Customer_Extend_Sales__c != null) {
            //     if (account.Hisense_Entity_Sales__c != null) {

            //         // extendTaxList = [Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Extend_Tax_category__c where Customer_Extend__c = :account.Customer_Extend_Sales__c];
            //         accountTaxList = [Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Tax_category__c where Customer__c = :account.Id];
            //         salesView = getSubAccountSalesView(account, accountTaxList, paymentTermId2CodeMap, picklistId2CodeMap, isUpdate);
            //     }
            // // 地址类客户
            // } else 
            if (objectName == 'Customer_Address__c'){
                system.debug('---addressAccount---');
                system.debug(account);
                
                //所属客商编码
                customerInfo.ZZCVCO = cusAdd.Customer__r.MDG_Customer_Code__c == null ? '': cusAdd.Customer__r.MDG_Customer_Code__c;
                //所属客商编码修改标识
                customerInfo.ZZCVCO_X = isUpdate;
                //客商编码
                customerInfo.PARTNER = cusAdd.MDG_Code__c == null ? '' : cusAdd.MDG_Code__c;
                //客商类型
                if(!Test.isRunningTest()){
                    customerInfo.BU_GROUP = clientMappingMap.get('Customer_Address').MDG_Code__c;
                    //客商明细类型
                    customerInfo.ZZMXLX = clientMappingMap.get('Customer_Address').MDG_Sub_Code__c;
                }
                //客商名称（当地语言）MDG把原来的NameEN和NameLocal对换 2025.1.16
                customerInfo.NAME_LO= cusAdd.Customer_Name_Local_Language_1__c == null ? '': cusAdd.Customer_Name_Local_Language_1__c;
                if(String.isNotBlank(customerInfo.NAME_LO)){
                    customerInfo.NAME_LO += cusAdd.Customer_Name_Local_Language_2__c == null ? '': ' ' + cusAdd.Customer_Name_Local_Language_2__c;
                }else{
                    customerInfo.NAME_LO += cusAdd.Customer_Name_Local_Language_2__c == null ? '': cusAdd.Customer_Name_Local_Language_2__c;
                }
                                        
                //客商名称（当地语言）修改标识
                customerInfo.NAME_LO_X = isUpdate;
                //客商名称（英文）
                customerInfo.NAME_EN = cusAdd.Customer_Name_EN_Language_1__c == null ? '': cusAdd.Customer_Name_EN_Language_1__c;
                if(String.isNotBlank(customerInfo.NAME_EN)){
                    customerInfo.NAME_EN += cusAdd.Customer_Name_EN_Language_2__c == null ? '': ' ' + cusAdd.Customer_Name_EN_Language_2__c;
                }else{
                    customerInfo.NAME_EN += cusAdd.Customer_Name_EN_Language_2__c == null ? '': cusAdd.Customer_Name_EN_Language_2__c;
                }

                //客商名称（英文）修改标识
                customerInfo.NAME_EN_X = isUpdate;

                //名称1 必填
                customerInfo.NAME_ORG1 = cusAdd.Customer_Name_Local_Language_1__c == null ? '': cusAdd.Customer_Name_Local_Language_1__c;
                //名称1修改标识
                customerInfo.NAME_ORG1_X = isUpdate;
                //名称2
                customerInfo.NAME_ORG2 = cusAdd.Customer_Name_Local_Language_2__c == null ? '': cusAdd.Customer_Name_Local_Language_2__c;
                //名称2修改标识
                customerInfo.NAME_ORG2_X = isUpdate;
                //名称3
                customerInfo.NAME_ORG3 = cusAdd.Customer_Name_EN_Language_1__c == null ? '': cusAdd.Customer_Name_EN_Language_1__c;
                //名称3修改标识
                customerInfo.NAME_ORG3_X = isUpdate;
                //名称4
                customerInfo.NAME_ORG4 = cusAdd.Customer_Name_EN_Language_2__c == null ? '': cusAdd.Customer_Name_EN_Language_2__c;
                //名称4修改标识
                customerInfo.NAME_ORG4_X = isUpdate;

                //简称
                customerInfo.BU_SORT1 = cusAdd.Customer_Short_Name__c == null ? '': cusAdd.Customer_Short_Name__c;
                //简称修改标识
                customerInfo.BU_SORT1_X = isUpdate;
                //语言
                customerInfo.BU_LANGU = cusAdd.Customer__r.Language__c == null ? '': cusAdd.Customer__r.Language__c;
                //语言修改标识
                customerInfo.BU_LANGU_X = isUpdate;
                //官方邮箱
                //customerInfo.SMTP_ADDR = cusAdd.Email__c == null ? '': cusAdd.Email__c;
                customerInfo.SMTP_ADDR = emailAddress;
                //官方邮箱修改标识
                customerInfo.SMTP_ADDR_X = isUpdate;
                //传真号码
                customerInfo.FAX_NUMBER = cusAdd.Fax__c == null ? '': cusAdd.Fax__c;
                //传真号码修改标识
                customerInfo.FAX_NUMBER_X = isUpdate;
                //联系电话
                customerInfo.TEL_NUMBER = cusAdd.Phone__c == null ? '': cusAdd.Phone__c;
                //联系电话修改标识
                customerInfo.TEL_NUMBER_X = isUpdate;

                //搜索项2
                customerInfo.ZSORT2 = cusAdd.Search_Term2__c == null ? '': cusAdd.Search_Term2__c;
                //搜索项2修改标识
                customerInfo.ZSORT2_X = isUpdate;

                //税码1
                customerInfo.ZTAX_CODE1 = cusAdd.Tax_Number1__c == null ? '': cusAdd.Tax_Number1__c;
                //税码1修改标识
                customerInfo.ZTAX_CODE1_X = isUpdate;
                //税码2
                customerInfo.ZTAX_CODE2 = cusAdd.Tax_Number2__c == null ? '': cusAdd.Tax_Number2__c;
                //税码2修改标识
                customerInfo.ZTAX_CODE2_X = isUpdate;
                //税号3
                customerInfo.ZTAX_CODE3 = cusAdd.Tax_Number3__c == null ? '': cusAdd.Tax_Number3__c;
                //税号3修改标识
                customerInfo.ZTAX_CODE3_X = isUpdate;
                //税号4
                customerInfo.ZTAX_CODE4 = cusAdd.Tax_Number4__c == null ? '': cusAdd.Tax_Number4__c;
                //税号4修改标识
                customerInfo.ZTAX_CODE4_X = isUpdate;

                //GLN码-1
                customerInfo.BBBNR = cusAdd.Global_Location_Number__c == null ? '': cusAdd.Global_Location_Number__c.substring(0,7);
                //GLN码-1修改标识
                customerInfo.BBBNR_X = isUpdate;
                //GLN码-2
                customerInfo.BBSNR = cusAdd.Global_Location_Number__c == null ? '': cusAdd.Global_Location_Number__c.substring(7,12);
                //GLN码-2修改标识
                customerInfo.BBSNR_X = isUpdate;
                //GLN码-3
                customerInfo.BUBKZ = cusAdd.Global_Location_Number__c == null ? '': cusAdd.Global_Location_Number__c.substring(12,13);
                //GLN码-3修改标识
                customerInfo.BUBKZ_X = isUpdate;
                //运输区域
                customerInfo.LZONE = cusAdd.Transportation_area__c == null ? '': cusAdd.Transportation_area__c;
                //运输区域修改标识
                customerInfo.LZONE_X = isUpdate;
                
                //地址类型

                // MDG创建规则是如果要带地址，必须要有个01的标准地址，02是不能单独存在的。
                // 地址类客户也是一个客户，客户就需要有一个标准地址就是类型01.  自己本身的送货地址是类型02.   01和02 所有结构都相同，就是使用类型不同
                // 2024.12.26 MDG最新同步的地址类客户创建规则

                CustomerAddress basicAddr = new CustomerAddress();
                basicAddr.ZZADTY = '01';
                //国家
                basicAddr.LAND1 = String.isNotBlank(cusAdd.Country__c) ? cusAdd.Country__c : '';
                //国家修改标识
                basicAddr.LAND1_X = isUpdate;
                //省份
                basicAddr.REGIO = cusAdd.Province_State__c == null ? '': countryStateMap.get(cusAdd.Province_State__c);
                //省份修改标识
                basicAddr.REGIO_X = isUpdate;
                if ('CN'.equals(cusAdd.Country__c)) {
                    //CN 城市
                    basicAddr.ORT01 = cusAdd.City_CN__c == null ? '': countryStateMap.get(cusAdd.City_CN__c);
                } else {
                    //非CN 城市
                    basicAddr.ORT01 = cusAdd.City__c == null ? '': cusAdd.City__c;
                }
                //城市修改标识
                basicAddr.ORT01_X = isUpdate;
                //区县
                basicAddr.ORT02 = cusAdd.District_CN__c == null ? '': countryStateMap.get(cusAdd.District_CN__c);
                //区县修改标识
                basicAddr.ORT02_X = isUpdate;
                //乡镇
                basicAddr.ZZTOWN = cusAdd.Township_CN__c == null ? '': countryStateMap.get(cusAdd.Township_CN__c);
                //乡镇修改标识
                basicAddr.ZZTOWN_X = isUpdate;
                //邮编 新表中没有
                basicAddr.POST_CODE1 = cusAdd.Postal_Code__c == null ? '': cusAdd.Postal_Code__c;
                //邮编修改标识
                basicAddr.POST_CODE1_X = isUpdate;
                //地址描述
                basicAddr.FSTRAS = String.isNotBlank(cusAdd.Address_Description__c) ? cusAdd.Address_Description__c : '';
                //地址描述修改标识
                basicAddr.FSTRAS_X = isUpdate;

                //地址街道2
                basicAddr.STR_SUPPL2 = String.isNotBlank(cusAdd.Street_2__c) ? cusAdd.Street_2__c : '';
                //地址街道2修改标识
                basicAddr.STR_SUPPL2_X = isUpdate;
                //地址街道3
                basicAddr.STR_SUPPL3 = String.isNotBlank(cusAdd.Street_3__c) ? cusAdd.Street_3__c : '';
                //地址街道3修改标识
                basicAddr.STR_SUPPL3_X = isUpdate;
                //地址街道4
                basicAddr.STR_SUPPL4 = String.isNotBlank(cusAdd.Street_4__c) ? cusAdd.Street_4__c : '';
                //地址街道4修改标识
                basicAddr.STR_SUPPL4_X = isUpdate;
                //地址街道5
                basicAddr.STR_LOCATION = String.isNotBlank(cusAdd.Street_5__c) ? cusAdd.Street_5__c : '';
                //地址街道5修改标识
                basicAddr.STR_LOCATION_X = isUpdate;

                addrList.add(basicAddr);

                // 地质类客户是发货用的，地址类型是02 2024/12/26
                addr.ZZADTY = '02';
                //国家
                addr.LAND1 = String.isNotBlank(cusAdd.Country__c) ? cusAdd.Country__c : '';
                //国家修改标识
                addr.LAND1_X = isUpdate;
                //省份
                addr.REGIO = cusAdd.Province_State__c == null ? '': countryStateMap.get(cusAdd.Province_State__c);
                //省份修改标识
                addr.REGIO_X = isUpdate;
                if ('CN'.equals(cusAdd.Country__c)) {
                    //CN 城市
                    addr.ORT01 = cusAdd.City_CN__c == null ? '': countryStateMap.get(cusAdd.City_CN__c);
                } else {
                    //非CN 城市
                    addr.ORT01 = cusAdd.City__c == null ? '': cusAdd.City__c;
                }
                //城市修改标识
                addr.ORT01_X = isUpdate;
                //区县
                addr.ORT02 = cusAdd.District_CN__c == null ? '': countryStateMap.get(cusAdd.District_CN__c);
                //区县修改标识
                addr.ORT02_X = isUpdate;
                //乡镇
                addr.ZZTOWN = cusAdd.Township_CN__c == null ? '': countryStateMap.get(cusAdd.Township_CN__c);
                //乡镇修改标识
                addr.ZZTOWN_X = isUpdate;
                //邮编 新表中没有
                addr.POST_CODE1 = cusAdd.Postal_Code__c == null ? '': cusAdd.Postal_Code__c;
                //邮编修改标识
                addr.POST_CODE1_X = isUpdate;
                //地址描述
                addr.FSTRAS = String.isNotBlank(cusAdd.Address_Description__c) ? cusAdd.Address_Description__c : '';
                //地址描述修改标识
                addr.FSTRAS_X = isUpdate;

                //地址街道2
                addr.STR_SUPPL2 = String.isNotBlank(cusAdd.Street_2__c) ? cusAdd.Street_2__c : '';
                //地址街道2修改标识
                addr.STR_SUPPL2_X = isUpdate;
                //地址街道3
                addr.STR_SUPPL3 = String.isNotBlank(cusAdd.Street_3__c) ? cusAdd.Street_3__c : '';
                //地址街道3修改标识
                addr.STR_SUPPL3_X = isUpdate;
                //地址街道4
                addr.STR_SUPPL4 = String.isNotBlank(cusAdd.Street_4__c) ? cusAdd.Street_4__c : '';
                //地址街道4修改标识
                addr.STR_SUPPL4_X = isUpdate;
                //地址街道5
                addr.STR_LOCATION = String.isNotBlank(cusAdd.Street_5__c) ? cusAdd.Street_5__c : '';
                //地址街道5修改标识
                addr.STR_LOCATION_X = isUpdate;
                
                if(cusAdd.Hisense_Entity__c != null || cusAdd.Hisense_Entity_Sales__c != null){
                    
                    if (cusAdd.Hisense_Entity__c != null) {
                        
                        // 地址类客户同步公司信息，如果有关联Customer_Extend 2024.12.26
                        companyView = new CompanyView();
                        //公司代码
                        companyView.BUKRS = cusAdd.Hisense_Entity__c == null ? '': cusAdd.Hisense_Entity__c;
                        //付款条件
                        companyView.ZTERM = cusAdd.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(cusAdd.Payment_Term__c);
                        //付款条件修改标识
                        companyView.ZTERM_X = isUpdate;
                        //统驭科目
                        companyView.AKONT = cusAdd.Reconciliation_Customer__c == null ? '': cusAdd.Reconciliation_Customer__c;
                        //统驭科目修改标识
                        companyView.AKONT_X = isUpdate;
                        //选择规则
                        //companyView.SREGL = cusAdd.Customer_Extend__r.Selection_Rule__c == null ? '': cusAdd.Customer_Extend__r.Selection_Rule__c;
                        //选择规则修改标识
                        //companyView.SREGL_X = isUpdate;
                        //账户备注
                        //companyView.KVERM = cusAdd.Customer_Extend__r.Account_Remarks__c == null ? '': cusAdd.Customer_Extend__r.Account_Remarks__c;
                        //账户备注修改标识
                        //companyView.KVERM_X = isUpdate;
                        //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                        companyView.NODEL = cusAdd.Company_View_Freeze_markers__c ? 'X' : '';
                        //冻结标记修改标识
                        companyView.NODEL_X = isUpdate;
                        //支付方式
                        companyView.ZWELS = cusAdd.Payment_Method_MDG__c == null ? '': cusAdd.Payment_Method_MDG__c.substring(0,1);
                        //支付方式修改标识
                        companyView.ZWELS_X = isUpdate;
                        //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
                        // companyView.ZZLINE = customerExtend.E_commerce_Customer_Label__c == null ? '': customerExtend.E_commerce_Customer_Label__c;
                        //线上/线下修改标识
                        // companyView.ZZLINE_X = isUpdate;
                        //公司区域删除标识
                        companyView.LOEVM = cusAdd.Delete_identification_for_company_region__c;
                        //公司区域删除标识修改标识
                        companyView.LOEVM_X = isUpdate;
                        //客户EDI 默认库位
                        companyView.ZZLGORT = cusAdd.Stor_Location__c == null ? '': picklistId2CodeMap.get(cusAdd.Stor_Location__c);
                        //客户EDI 默认库位修改标识
                        companyView.ZZLGORT_X = isUpdate;
                        //客户EDI ID
                        companyView.ZZSORT1 = cusAdd.EDI_ID__c == null ? '': cusAdd.EDI_ID__c;
                        //客户EDI ID修改标识
                        companyView.ZZSORT1_X = isUpdate;
                        //客户EDI ID2
                        companyView.ZZSORT2 = cusAdd.EDI_ID2__c == null ? '': cusAdd.EDI_ID2__c;
                        //客户EDI ID2修改标识
                        companyView.ZZSORT2_X = isUpdate;
                        //客户EDI 类型
                        companyView.EDI_TYPE = cusAdd.Customer_EDI_ID_Type__c == null ? '': cusAdd.Customer_EDI_ID_Type__c;
                        //客户EDI 类型修改标识
                        companyView.EDI_TYPE_X = isUpdate;
                        //TV lisense
                        companyView.ZTV = cusAdd.TV_lisense__c == null ? '': cusAdd.TV_lisense__c;
                        //TV lisense修改标识
                        companyView.ZTV_X = isUpdate;
                        if(cusAdd.Valid_to__c != null){
            
                            //Valid to
                            companyView.ZVALID_TO = dateToString(cusAdd.Valid_to__c);
                            //Valid to修改标识
                            companyView.ZVALID_TO_X = isUpdate;
                
                        }
                        //包装类型
                        companyView.PACKAGING_TYPE = cusAdd.Packing_Type__c == null ? '': cusAdd.Packing_Type__c;
                        //包装类型修改标识
                        companyView.PACKAGING_TYPE_X = isUpdate;
                        //VAT 号
                        companyView.ZZSH = cusAdd.Add_VAT_Reg_No__c == null ? '': cusAdd.Add_VAT_Reg_No__c;
                        //VAT 号修改标识
                        companyView.ZZSH_X = isUpdate;
                        //VAT  类型
                        companyView.ZKHFL = cusAdd.VAT_Tax_type__c == null ? '': cusAdd.VAT_Tax_type__c;
                        //VAT  类型修改标识
                        companyView.ZKHFL_X = isUpdate;

                        companyViewList.add(companyView);
                    }
                    
                    if (cusAdd.Hisense_Entity_Sales__c != null) {
                        
                        //销售组织
                        salesView.VKORG = cusAdd.Hisense_Entity_Sales__c == null ? '': cusAdd.Hisense_Entity_Sales__c;
                        //产品组（产品中类）
                        salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
                        //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
                        salesView.VTWEG = cusAdd.Distribution_Channel__c == null ? '' : cusAdd.Distribution_Channel__c;
                        //客户定价过程
                        //salesView.KALKS = cusAdd.Customer_Extend_Sales__r.Customer_pricing_process__c == null ? '': cusAdd.Customer_Extend_Sales__r.Customer_pricing_process__c;
                        //客户定价过程修改标识
                        //salesView.KALKS_X = isUpdate;
                        //付款条件
                        salesView.ZTERM = cusAdd.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(cusAdd.Payment_Term_Sales__c);
                        //付款条件修改标识
                        salesView.ZTERM_X = isUpdate;
                        //销售地区 不再传给MDG 2024.11.27 第一轮测试更新
                        // salesView.BZIRK = cusAdd.Customer_Extend_Sales__r.Sales_Region__c == null ? '': cusAdd.Customer_Extend_Sales__r.Sales_Region__c;
                        //销售地区修改标识
                        // salesView.BZIRK_X = isUpdate;
                        //销售区域删除标志
                        salesView.LOEVM = cusAdd.Sales_area_deletion_flag__c;
                        //销售区域删除标志修改标识
                        salesView.LOEVM_X = isUpdate;
                        //税分类
                        //salesView.TAXKD = cusAdd.Customer_Extend_Sales__r.Tax_Classification__c == null ? '': cusAdd.Customer_Extend_Sales__r.Tax_Classification__c;
                        //税分类修改标识
                        //salesView.TAXKD_X = isUpdate;
                        //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                        salesView.AUFSD = cusAdd.Sales_View_Freeze_markers__c ? 'X' : '';
                        // if(cusAdd.Customer_Extend_Sales__r.Customer_Status_MDG__c == '50'){
                            
                        //     salesView.AUFSD = 'X';
                        // }
                        //冻结标记修改标识
                        salesView.AUFSD_X = isUpdate;
                        //价格组
                        //salesView.KONDA = cusAdd.Customer_Extend_Sales__r.Price_Group__c == null ? '': cusAdd.Customer_Extend_Sales__r.Price_Group__c;
                        //价格组修改标识
                        //salesView.KONDA_X = isUpdate;
                        //销售部门
                        salesView.VKBUR = cusAdd.Sales_Office__c == null ? '': picklistId2CodeMap.get(cusAdd.Sales_Office__c);
                        //销售部门修改标识
                        salesView.VKBUR_X = isUpdate;
                        //销售组
                        salesView.VKGRP = cusAdd.Sales_Group__c == null ? '': picklistId2CodeMap.get(cusAdd.Sales_Group__c);
                        //销售组修改标识
                        salesView.VKGRP_X = isUpdate;
                        //与POD相关
                        salesView.PODKZ = cusAdd.Related_to_POD__c;
                        //与POD相关修改标识
                        salesView.PODKZ_X = isUpdate;
                        //国际贸易条款
                        salesView.INCO1 = cusAdd.International_Trade_Terms__c == null ? '': cusAdd.International_Trade_Terms__c;
                        //国际贸易条款修改标识
                        salesView.INCO1_X = isUpdate;
                        //国际贸易条款2
                        salesView.INCO2_L = cusAdd.International_Trade_Terms_2__c == null ? '': cusAdd.International_Trade_Terms_2__c;
                        //国际贸易条款2修改标识
                        salesView.INCO2_L_X = isUpdate;
                        //货币
                        salesView.WAERS = cusAdd.CurrencyIsoCode == null ? '': cusAdd.CurrencyIsoCode;
                        //货币修改标识
                        salesView.WAERS_X = isUpdate;
                        //账户分配组
                        //salesView.KTGRD = cusAdd.Customer_Extend_Sales__r.Account_Assignment_Group__c == null ? '': cusAdd.Customer_Extend_Sales__r.Account_Assignment_Group__c;
                        //账户分配组修改标识
                        //salesView.KTGRD_X = isUpdate;
                        //客户组
                        //salesView.KDGRP = cusAdd.Customer_Extend_Sales__r.KDGRP__c == null ? '': cusAdd.Customer_Extend_Sales__r.KDGRP__c;
                        //客户组修改标识
                        //salesView.KDGRP_X = isUpdate;
                        //运输条件
                        salesView.VSBED = cusAdd.Shipping_Conditions__c == null ? '': cusAdd.Shipping_Conditions__c;
                        //运输条件修改标识
                        salesView.VSBED_X = isUpdate;
                        //发货工厂
                        //salesView.VWERK = cusAdd.Customer_Extend_Sales__r.Deliverying_Plant__c == null ? '': cusAdd.Customer_Extend_Sales__r.Deliverying_Plant__c;
                        //发货工厂修改标识
                        //salesView.VWERK_X = isUpdate;
                        //税类别
                        //salesView.TATYP = cusAdd.Customer_Extend_Sales__r.VAT_Tax_type__c == null ? '': cusAdd.Customer_Extend_Sales__r.VAT_Tax_type__c;
                        //税类别修改标识
                        //salesView.TATYP_X = isUpdate;
                        //客户组2
                        //salesView.KVGR2 = cusAdd.Customer_Extend_Sales__r.Customer_Group2__c == null ? '': cusAdd.Customer_Extend_Sales__r.Customer_Group2__c;
                        //客户组2修改标识
                        //salesView.KVGR2_X = isUpdate;
                        //1202 追加
                        if(addressTaxList != null){
                            for (Customer_Address_Tax_category__c cetc : addressTaxList) {
                                taxCodn tcd = new taxCodn();
                                // 国家地区代码 例：国内CN
                                tcd.ALAND = cetc.CountryCodeAndCustomerIdF__c == null ? '': cetc.CountryCodeAndCustomerIdF__c;
                                // 税收条件类型 例：NWST
                                tcd.TATYP = cetc.Tax_category_code__c == null ? '': cetc.Tax_category_code__c;
                                //税分类 1或者0
                                tcd.TAXKD = cetc.Tax_category__r.Name == null ? '': cetc.Tax_category__r.Name;
                                //税分类修改标识符
                                tcd.TAXKD_X = isUpdate;
                                taxCodnList.add(tcd);  
                            }

                        }
                        
                        salesView.TAXCODN = taxCodnList;
                    }
                } else {
                    
                    if ('Sub_Account'.equals(account.recordtype.DeveloperName)) {
                        // if (account.Customer_Extend_Sub_Account__c != null) {
                        if (account.Hisense_Entity__c != null) {
                            companyView = getSubAccountCompanyView(account, paymentTermId2CodeMap, picklistId2CodeMap, isUpdate);
                            if (String.isNotEmpty(companyView.BUKRS)) {
                                companyViewList.add(companyView);
                            }
                        }
                        // if (account.Customer_Extend_Sales__c != null) {
                        if (account.Hisense_Entity_Sales__c != null) {
                            accountTaxList = [Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Tax_category__c where Customer__c = :account.Id];
                            salesView = getSubAccountSalesView(account, accountTaxList, paymentTermId2CodeMap, picklistId2CodeMap, isUpdate);
                        }
                    } else {

                        //TODO
                        if (cusAdd.Customer__r.Hisense_Entity__c != null) {

                            // 分户同步公司信息，主户的默认公司视图 2024.12.26
                            companyView = new CompanyView();
                            //公司代码
                            companyView.BUKRS = cusAdd.Customer__r.Hisense_Entity__c == null ? '': cusAdd.Customer__r.Hisense_Entity__c;
                            //付款条件
                            companyView.ZTERM = cusAdd.Customer__r.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(cusAdd.Customer__r.Payment_Term__c);
                            //付款条件修改标识
                            companyView.ZTERM_X = isUpdate;
                            //统驭科目
                            companyView.AKONT = cusAdd.Customer__r.Reconciliation_Customer__c == null ? '': cusAdd.Customer__r.Reconciliation_Customer__c;
                            //统驭科目修改标识
                            companyView.AKONT_X = isUpdate;
                            //选择规则
                            companyView.SREGL = cusAdd.Customer__r.Selection_Rules__c == null ? '': cusAdd.Customer__r.Selection_Rules__c;
                            //选择规则修改标识
                            companyView.SREGL_X = isUpdate;
                            //账户备注
                            companyView.KVERM = cusAdd.Customer__r.Account_Remarks__c == null ? '': cusAdd.Customer__r.Account_Remarks__c;
                            //账户备注修改标识
                            companyView.KVERM_X = isUpdate;
                            //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                            companyView.NODEL = cusAdd.Customer__r.Company_View_Freeze_markers__c ? 'X' : '';
                            //冻结标记修改标识
                            companyView.NODEL_X = isUpdate;
                            //支付方式
                            companyView.ZWELS = cusAdd.Customer__r.Payment_Method_MDG__c == null ? '': cusAdd.Customer__r.Payment_Method_MDG__c.substring(0,1);
                            //支付方式修改标识
                            companyView.ZWELS_X = isUpdate;
                            //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
                            // companyView.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
                            //线上/线下修改标识
                            // companyView.ZZLINE_X = isUpdate;
                            //公司区域删除标识
                            companyView.LOEVM = cusAdd.Customer__r.Delete_identification_for_company_region__c;
                            //公司区域删除标识修改标识
                            companyView.LOEVM_X = isUpdate;
                            //客户EDI 默认库位 默认库位使用旧字段Stor_Location__c 2024/12/30 优化
                            companyView.ZZLGORT = cusAdd.Customer__r.Stor_Location__c == null ? '': picklistId2CodeMap.get(cusAdd.Customer__r.Stor_Location__c);
                            //客户EDI 默认库位修改标识
                            companyView.ZZLGORT_X = isUpdate;
                            //客户EDI ID
                            companyView.ZZSORT1 = cusAdd.EDI_ID__c == null ? '': cusAdd.EDI_ID__c;
                            //客户EDI ID修改标识
                            companyView.ZZSORT1_X = isUpdate;
                            //客户EDI ID2
                            companyView.ZZSORT2 = cusAdd.EDI_ID2__c == null ? '': cusAdd.EDI_ID2__c;
                            //客户EDI ID2修改标识
                            companyView.ZZSORT2_X = isUpdate;
                            //客户EDI 类型
                            companyView.EDI_TYPE = cusAdd.Customer_EDI_ID_Type__c == null ? '': cusAdd.Customer_EDI_ID_Type__c;
                            //客户EDI 类型修改标识
                            companyView.EDI_TYPE_X = isUpdate;
                            //TV lisense
                            companyView.ZTV = cusAdd.TV_lisense__c == null ? '': cusAdd.TV_lisense__c;
                            //TV lisense修改标识
                            companyView.ZTV_X = isUpdate;
                            if(cusAdd.Valid_to__c != null){
                
                                //Valid to
                                companyView.ZVALID_TO = dateToString(cusAdd.Valid_to__c);
                                //Valid to修改标识
                                companyView.ZVALID_TO_X = isUpdate;
                    
                            }
                            //包装类型
                            companyView.PACKAGING_TYPE = cusAdd.Packing_Type__c == null ? '': cusAdd.Packing_Type__c;
                            //包装类型修改标识
                            companyView.PACKAGING_TYPE_X = isUpdate;
                            //VAT 号
                            companyView.ZZSH = cusAdd.Add_VAT_Reg_No__c == null ? '': cusAdd.Add_VAT_Reg_No__c;
                            //VAT 号修改标识
                            companyView.ZZSH_X = isUpdate;
                            //VAT  类型
                            companyView.ZKHFL = cusAdd.VAT_Tax_type__c == null ? '': cusAdd.VAT_Tax_type__c;
                            //VAT  类型修改标识
                            companyView.ZKHFL_X = isUpdate;

                            companyViewList.add(companyView);
                        }

                        if (cusAdd.Customer__r.Hisense_Entity_Sales__c != null) {
                            
                            //销售组织
                            salesView.VKORG = cusAdd.Customer__r.Hisense_Entity_Sales__c == null ? '': cusAdd.Customer__r.Hisense_Entity_Sales__c;
                            //产品组（产品中类）
                            salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
                            //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
                            salesView.VTWEG = cusAdd.Customer__r.Distribution_Channel__c == null ? '': cusAdd.Customer__r.Distribution_Channel__c;
                            //客户定价过程
                            salesView.KALKS = cusAdd.Customer__r.Customer_pricing_process__c == null ? '': cusAdd.Customer__r.Customer_pricing_process__c;
                            //客户定价过程修改标识
                            salesView.KALKS_X = isUpdate;
                            //付款条件
                            salesView.ZTERM = cusAdd.Customer__r.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(cusAdd.Customer__r.Payment_Term_Sales__c);
                            //付款条件修改标识
                            salesView.ZTERM_X = isUpdate;
                            //销售地区 不再传给MDG 2024.11.27 第一轮测试更新
                            // salesView.BZIRK = cusAdd.Customer__r.Sales_Region__c == null ? '': cusAdd.Customer__r.Sales_Region__c;
                            //销售地区修改标识
                            // salesView.BZIRK_X = isUpdate;
                            //销售区域删除标志
                            salesView.LOEVM = cusAdd.Customer__r.Sales_area_deletion_flag__c;
                            //销售区域删除标志修改标识
                            salesView.LOEVM_X = isUpdate;
                            //税分类
                            //salesView.TAXKD = cusAdd.Customer__r.Tax_Classification__c == null ? '': cusAdd.Customer__r.Tax_Classification__c;
                            //税分类修改标识
                            //salesView.TAXKD_X = isUpdate;
                            //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                            salesView.AUFSD = cusAdd.Customer__r.Sales_View_Freeze_markers__c ? 'X' : '';
                            /*if(cusAdd.Customer__r.Customer_Status_MDG__c == '50'){
                                
                                salesView.AUFSD = 'X';
                            }*/
                            //冻结标记修改标识
                            salesView.AUFSD_X = isUpdate;
                            //价格组
                            salesView.KONDA = cusAdd.Customer__r.Price_Group__c == null ? '': cusAdd.Customer__r.Price_Group__c;
                            //价格组修改标识
                            salesView.KONDA_X = isUpdate;
                            //销售部门
                            salesView.VKBUR = cusAdd.Customer__r.Sales_Office__c == null ? '': picklistId2CodeMap.get(cusAdd.Customer__r.Sales_Office__c);
                            //销售部门修改标识
                            salesView.VKBUR_X = isUpdate;
                            //销售组
                            salesView.VKGRP = cusAdd.Customer__r.Sales_Group__c == null ? '': picklistId2CodeMap.get(cusAdd.Customer__r.Sales_Group__c);
                            //销售组修改标识
                            salesView.VKGRP_X = isUpdate;
                            //与POD相关
                            salesView.PODKZ = cusAdd.Customer__r.Related_to_POD__c;
                            //与POD相关修改标识
                            salesView.PODKZ_X = isUpdate;
                            //国际贸易条款
                            salesView.INCO1 = cusAdd.Customer__r.International_Trade_Terms__c == null ? '': cusAdd.Customer__r.International_Trade_Terms__c;
                            //国际贸易条款修改标识
                            salesView.INCO1_X = isUpdate;
                            //国际贸易条款2
                            salesView.INCO2_L = cusAdd.Customer__r.International_Trade_Terms_2__c == null ? '': cusAdd.Customer__r.International_Trade_Terms_2__c;
                            //国际贸易条款2修改标识
                            salesView.INCO2_L_X = isUpdate;
                            //货币
                            salesView.WAERS = cusAdd.Customer__r.CurrencyIsoCode == null ? '': cusAdd.Customer__r.CurrencyIsoCode;
                            //货币修改标识
                            salesView.WAERS_X = isUpdate;
                            //账户分配组
                            salesView.KTGRD = cusAdd.Customer__r.Account_Assignment_Group__c == null ? '': cusAdd.Customer__r.Account_Assignment_Group__c;
                            //账户分配组修改标识
                            salesView.KTGRD_X = isUpdate;
                            //客户组
                            salesView.KDGRP = cusAdd.Customer__r.KDGRP__c == null ? '': cusAdd.Customer__r.KDGRP__c;
                            //客户组修改标识
                            salesView.KDGRP_X = isUpdate;
                            //运输条件
                            salesView.VSBED = cusAdd.Customer__r.Shipping_Conditions__c == null ? '': cusAdd.Customer__r.Shipping_Conditions__c;
                            //运输条件修改标识
                            salesView.VSBED_X = isUpdate;
                            //发货工厂
                            salesView.VWERK = cusAdd.Customer__r.Deliverying_Plant__c == null ? '': cusAdd.Customer__r.Deliverying_Plant__c;
                            //发货工厂修改标识
                            salesView.VWERK_X = isUpdate;
                            //税类别
                            //salesView.TATYP = cusAdd.Customer__r.VAT_Tax_type__c == null ? '': cusAdd.Customer__r.VAT_Tax_type__c;
                            //税类别修改标识
                            //salesView.TATYP_X = isUpdate;
                            //客户组2
                            salesView.KVGR2 = cusAdd.Customer__r.Customer_Group2__c == null ? '': cusAdd.Customer__r.Customer_Group2__c;
                            //客户组2修改标识
                            salesView.KVGR2_X = isUpdate;
                            if (!account.Customer_Tax_category__r.isEmpty() & account.Customer_Tax_category__r != null) {
                                for (Customer_Tax_category__c ctc : account.Customer_Tax_category__r) {
                                    taxCodn tc = new taxCodn();
                                    // 国家地区代码 例：国内CN
                                    tc.ALAND = ctc.CountryCodeAndCustomerIdF__c == null ? '': ctc.CountryCodeAndCustomerIdF__c;
                                    // 税收条件类型 例：NWST
                                    tc.TATYP = ctc.Tax_category_code__c == null ? '': ctc.Tax_category_code__c;
                                    //税分类 1或者0
                                    tc.TAXKD = ctc.Tax_category__r.Name == null ? '': ctc.Tax_category__r.Name;
                                    
                                    tc.TAXKD_X = isUpdate;
                                    taxCodnList.add(tc);
                                }
                            }
                            salesView.TAXCODN = taxCodnList;   
                        } 
                    }  
                }
                // 扩展客户传递参数    
            }else if(objectName == 'Customer_Extend__c'){
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
                if(account.License_Expiration_Date__c != null){

                    //营业执照到日期
                    customerInfo.ZZBLED = dateToString(account.License_Expiration_Date__c);
                    //营业执照到日期修改标识
                    customerInfo.ZZBLED_X = isUpdate;

                }
            
                if(account.Registration_Date__c != null){
                    //注册日期
                    customerInfo.FOUND_DAT = dateToString(account.Registration_Date__c);
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
                //customerInfo.SMTP_ADDR = account.Email__c == null ? '': account.Email__c;
                //官方邮箱修改标识
                //customerInfo.SMTP_ADDR_X = isUpdate;
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
                //所属客商编码
                customerInfo.ZZCVCO = account.Belonged_Customer_Code__c == null ? '': account.Belonged_Customer_Code__c;
                //所属客商编码修改标识
                customerInfo.ZZCVCO_X = isUpdate;
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

                // lzx - 2025-02-08新增字段
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
                //税码1
                customerInfo.ZTAX_CODE1 = account.Tax_Number1__c == null ? '': account.Tax_Number1__c;
                //税码1修改标识
                customerInfo.ZTAX_CODE1_X = isUpdate;
                //税码2
                customerInfo.ZTAX_CODE2 = account.Tax_Number2__c == null ? '': account.Tax_Number2__c;
                //税码2修改标识
                customerInfo.ZTAX_CODE2_X = isUpdate;
                //税管辖区域
                customerInfo.ZTAX_JUR  = '';
                //税管辖区域修改标识
                customerInfo.ZTAX_JUR_X = isUpdate;
                //地址类型 员工类客户不传值 2024.12.3
                // 员工类客户，就是地址视图还是要，地址类型固定01，只带国家和语言，其他地址视图的字段不需要 2024.12.27 MDG规则更新
                addr.ZZADTY = '01';
                //国家
                addr.LAND1 = account.Guarantor_Country_Code__c == null ? '': account.Guarantor_Country_Code__c;
                //国家修改标识
                addr.LAND1_X = isUpdate;
                //2025-06-04 刘平华说省份必填
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
                //2025-06-24 王传斌要求传递员工地址
                //if (account.recordtype.Name != 'Staff') {
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

                if (customerExtend.Hisense_Entity__c != null) {
                    
                    //companyView = new CompanyView();
                    //公司代码
                    companyView.BUKRS = customerExtend.Hisense_Entity__c == null ? '': customerExtend.Hisense_Entity__c;
                    //付款条件
                    companyView.ZTERM = customerExtend.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(customerExtend.Payment_Term__c);
                    //付款条件修改标识
                    companyView.ZTERM_X = isUpdate;
                    //统驭科目
                    companyView.AKONT = customerExtend.Reconciliation_Customer__c == null ? '': customerExtend.Reconciliation_Customer__c;
                    //统驭科目修改标识
                    companyView.AKONT_X = isUpdate;
                    //选择规则
                    companyView.SREGL = customerExtend.Selection_Rule__c == null ? '': customerExtend.Selection_Rule__c;
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
                    // companyView.ZZLINE = customerExtend.E_commerce_Customer_Label__c == null ? '': customerExtend.E_commerce_Customer_Label__c;
                    //线上/线下修改标识
                    // companyView.ZZLINE_X = isUpdate;
                    //公司区域删除标识
                    companyView.LOEVM = customerExtend.Delete_identification_for_company_region__c;
                    //公司区域删除标识修改标识
                    companyView.LOEVM_X = isUpdate;
                    //客户EDI 默认库位
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
                        companyView.ZVALID_TO = dateToString(customerExtend.Valid_to__c);
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

                if (customerExtend.Hisense_Entity_Sales__c != null) {

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
                    salesView.ZTERM = customerExtend.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(customerExtend.Payment_Term_Sales__c);
                    //付款条件修改标识
                    salesView.ZTERM_X = isUpdate;
                    //销售地区 不再传给MDG 2024.11.27 第一轮测试更新
                    // salesView.BZIRK = customerExtend.Sales_Region__c == null ? '': customerExtend.Sales_Region__c;
                    //销售地区修改标识
                    // salesView.BZIRK_X = isUpdate;
                    //销售区域删除标志
                    salesView.LOEVM = customerExtend.Sales_area_deletion_flag__c;
                    //销售区域删除标志修改标识
                    salesView.LOEVM_X = isUpdate;
                    //税分类
                    //salesView.TAXKD = customerExtend.Tax_Classification__c == null ? '': customerExtend.Tax_Classification__c;
                    //税分类修改标识
                    //salesView.TAXKD_X = isUpdate;
                    //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                    salesView.AUFSD = customerExtend.Sales_View_Freeze_markers__c ? 'X' : '';
                    // if(account.Customer_Status_MDG__c == '50'){

                    // salesView.AUFSD = 'X';
                    // }
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

                    //国际贸易条款2
                    salesView.INCO2_L = customerExtend.International_Trade_Terms_2__c == null ? '': customerExtend.International_Trade_Terms_2__c;
                    //国际贸易条款2修改标识
                    salesView.INCO2_L_X = isUpdate;
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
                    //税类别
                    //salesView.TATYP = customerExtend.VAT_Tax_type__c == null ? '': customerExtend.VAT_Tax_type__c;
                    //税类别修改标识
                    //salesView.TATYP_X = isUpdate;
                    //客户组2
                    salesView.KVGR2 = customerExtend.Customer_Group2__c == null ? '': customerExtend.Customer_Group2__c;
                    //客户组2修改标识
                    salesView.KVGR2_X = isUpdate;

                    //客户处我方账户
                    salesView.EIKTO = customerExtend.Our_account_at_the_customer_s_place__c == null ? '': customerExtend.Our_account_at_the_customer_s_place__c;
                    //客户处我方账户修改标识
                    salesView.EIKTO_X = isUpdate;

                    System.debug('taxCodnList='+taxCodnList);
                    
                    //1202 追加
                    if (!customerExtend.Customer_Extend_Tax_category__r.isEmpty() & customerExtend.Customer_Extend_Tax_category__r != null) {
                        for (Customer_Extend_Tax_category__c cetc : customerExtend.Customer_Extend_Tax_category__r) {
                            system.debug('cetc='+cetc);
                            taxCodn tcd = new taxCodn();
                            // 国家地区代码 例：国内CN
                            tcd.ALAND = cetc.CountryCodeAndCustomerIdF__c == null ? '': cetc.CountryCodeAndCustomerIdF__c;
                            // 税收条件类型 例：NWST
                            tcd.TATYP = cetc.Tax_category_code__c == null ? '': cetc.Tax_category_code__c;
                            //税分类 1或者0
                            tcd.TAXKD = cetc.Tax_category__r.Name == null ? '': cetc.Tax_category__r.Name;
                            //税分类修改标识符
                            tcd.TAXKD_X = isUpdate;
                            taxCodnList.add(tcd);  
                        }
                    }
                    
                    salesView.TAXCODN = taxCodnList;

                    // 21.同步接口中追加Payer和Bill to两个字段的同步逻辑，Payer对应付款方，Bill to对应开票方 2024.12.31 优化
                    // CustomerExtend增加4个字段，bill to，payer，price list, payment overdue times 2025.1.6 优化
                    // 1.主户和主户拓展，payer就是默认他自己，bill放开自己选择，不选择的话传MDG空。 2025.1.13 优化
                    // BPKUR 开票方
                    salesView.BPKUR = customerExtend.Receiver__r == null || customerExtend.Receiver__r.SAP_Customer_Code__c == null ? '': String.valueOf(customerExtend.Receiver__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                    // 开票方修改标识
                    salesView.BPKUR_X = isUpdate;
                    // PYKUR 付款方
                    salesView.PYKUR = customerExtend.Payer__r == null || customerExtend.Payer__r.SAP_Customer_Code__c == null ? '' : String.valueOf(customerExtend.Payer__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                    // 付款放修改标识
                    salesView.PYKUR_X = isUpdate;
                    // 分户：payer 默认主户，bill 放开自己选择，如果不选，传mdg  X (wfc:2025-01-26)
                    if(account.recordtype.DeveloperName == 'Sub_Account'){
                        // PYKUR 付款方
                        salesView.PYKUR = account.ParentCustomerOfSubAcc__r.MDG_Customer_Code__c;
                        // 付款放修改标识
                        salesView.PYKUR_X = isUpdate;
                        // BPKUR 开票方
                        salesView.BPKUR = customerExtend.Receiver__c == null || customerExtend.Receiver__r.SAP_Customer_Code__c == null ? 'X': String.valueOf(customerExtend.Receiver__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                        // 开票方修改标识
                        salesView.BPKUR_X = isUpdate;
                    }
                }
            }else{
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
                if(account.License_Expiration_Date__c != null){

                //营业执照到日期
                customerInfo.ZZBLED = dateToString(account.License_Expiration_Date__c);
                //营业执照到日期修改标识
                customerInfo.ZZBLED_X = isUpdate;

                }
                
                if(account.Registration_Date__c != null){
                //注册日期
                customerInfo.FOUND_DAT = dateToString(account.Registration_Date__c);
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
                //customerInfo.SMTP_ADDR = account.Email__c == null ? '': account.Email__c;
                customerInfo.SMTP_ADDR = emailAccount;
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
                //所属客商编码
                customerInfo.ZZCVCO = account.Belonged_Customer_Code__c == null ? '': account.Belonged_Customer_Code__c;
                //所属客商编码修改标识
                customerInfo.ZZCVCO_X = isUpdate;
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

                // lzx - 2025-02-08新增字段
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

                //运输区域修改标识
                customerInfo.LZONE_X = isUpdate;
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
                //税管辖区域
                customerInfo.ZTAX_JUR  = '';
                //税管辖区域修改标识
                customerInfo.ZTAX_JUR_X = isUpdate;
                //地址类型 员工类客户不传值 2024.12.3
                // 员工类客户，就是地址视图还是要，地址类型固定01，只带国家和语言，其他地址视图的字段不需要 2024.12.27 MDG规则更新
                addr.ZZADTY = '01';
                // addr.ZZADTY = account.recordtype.Name == 'Staff' ? '' : '01';
                //国家
                addr.LAND1 = account.Guarantor_Country_Code__c == null ? '': account.Guarantor_Country_Code__c;
                //国家修改标识
                addr.LAND1_X = isUpdate;
                
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
                //if (account.recordtype.Name != 'Staff') {
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

                if (account.Hisense_Entity__c != null) {
                    
                    companyView = new CompanyView();
                    //公司代码
                    companyView.BUKRS = account.Hisense_Entity__c == null ? '': account.Hisense_Entity__c;
                    //付款条件
                    companyView.ZTERM = account.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
                    //付款条件修改标识
                    companyView.ZTERM_X = isUpdate;
                    //统驭科目
                    companyView.AKONT = account.Reconciliation_Customer__c == null ? '': account.Reconciliation_Customer__c;
                    //统驭科目修改标识
                    companyView.AKONT_X = isUpdate;
                    //选择规则
                    companyView.SREGL = account.Selection_Rules__c == null ? '': account.Selection_Rules__c;
                    //选择规则修改标识
                    companyView.SREGL_X = isUpdate;
                    //账户备注
                    companyView.KVERM = account.Account_Remarks__c == null ? '': account.Account_Remarks__c;
                    //账户备注修改标识
                    companyView.KVERM_X = isUpdate;
                    //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                    companyView.NODEL = account.Company_View_Freeze_markers__c ? 'X' : '';
                    //冻结标记修改标识
                    companyView.NODEL_X = isUpdate;
                    //支付方式
                    companyView.ZWELS = account.Payment_Method_MDG__c == null ? '': account.Payment_Method_MDG__c.substring(0,1);
                    //支付方式修改标识
                    companyView.ZWELS_X = isUpdate;
                    //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
                    // companyView.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
                    //线上/线下修改标识
                    // companyView.ZZLINE_X = isUpdate;
                    //公司区域删除标识
                    companyView.LOEVM = account.Delete_identification_for_company_region__c;
                    //公司区域删除标识修改标识
                    companyView.LOEVM_X = isUpdate;
                    //客户EDI 默认库位 默认库位使用旧字段Stor_Location__c 2024/12/30 优化
                    companyView.ZZLGORT = account.Stor_Location__c == null ? '': picklistId2CodeMap.get(account.Stor_Location__c);
                    //客户EDI 默认库位修改标识
                    companyView.ZZLGORT_X = isUpdate;
                    //客户EDI ID
                    companyView.ZZSORT1 = account.EDI_ID__c == null ? '': account.EDI_ID__c;
                    //客户EDI ID修改标识
                    companyView.ZZSORT1_X = isUpdate;
                    //客户EDI ID2
                    companyView.ZZSORT2 = account.EDI_ID2__c == null ? '': account.EDI_ID2__c;
                    //客户EDI ID2修改标识
                    companyView.ZZSORT2_X = isUpdate;
                    //客户EDI 类型
                    companyView.EDI_TYPE = account.Customer_EDI_ID_Type__c == null ? '': account.Customer_EDI_ID_Type__c;
                    //客户EDI 类型修改标识
                    companyView.EDI_TYPE_X = isUpdate;
                    //TV lisense
                    companyView.ZTV = account.TV_lisense__c == null ? '': account.TV_lisense__c;
                    //TV lisense修改标识
                    companyView.ZTV_X = isUpdate;
                    if(account.Valid_to__c != null){
        
                        //Valid to
                        companyView.ZVALID_TO = dateToString(account.Valid_to__c);
                        //Valid to修改标识
                        companyView.ZVALID_TO_X = isUpdate;
            
                    }
                    //包装类型
                    companyView.PACKAGING_TYPE = account.Packing_Type__c == null ? '': account.Packing_Type__c;
                    //包装类型修改标识
                    companyView.PACKAGING_TYPE_X = isUpdate;
                    //VAT 号
                    companyView.ZZSH = account.Add_VAT_Reg_No__c == null ? '': account.Add_VAT_Reg_No__c;
                    //VAT 号修改标识
                    companyView.ZZSH_X = isUpdate;
                    //VAT  类型
                    companyView.ZKHFL = account.VAT_Tax_type__c == null ? '': account.VAT_Tax_type__c;
                    //VAT  类型修改标识
                    companyView.ZKHFL_X = isUpdate;

                    companyViewList.add(companyView);
                }

                // 员工类客户不创建销售视图 MDG最新规则同步 2024.12.26
                //if (account.recordtype.Name != 'Staff' && account.Hisense_Entity_Sales__c != null) {
                //桑工 25-06-10 员工类客户创建销售视图
                if (account.Hisense_Entity_Sales__c != null) {
                    //销售组织
                    salesView.VKORG = account.Hisense_Entity_Sales__c == null ? '': account.Hisense_Entity_Sales__c;
                    //产品组（产品中类）
                    salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
                    //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
                    salesView.VTWEG = account.Distribution_Channel__c == null ? '': account.Distribution_Channel__c;
                    //客户定价过程
                    salesView.KALKS = account.Customer_pricing_process__c == null ? '': account.Customer_pricing_process__c;
                    //客户定价过程修改标识
                    salesView.KALKS_X = isUpdate;
                    //付款条件
                    salesView.ZTERM = account.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term_Sales__c);
                    //付款条件修改标识
                    salesView.ZTERM_X = isUpdate;
                    //销售地区 字段不在传给MDG 2024.11.27 第一轮测试更新
                    // salesView.BZIRK = account.Sales_Region__c == null ? '': account.Sales_Region__c;
                    //销售地区修改标识
                    // salesView.BZIRK_X = isUpdate;
                    //销售区域删除标志
                    salesView.LOEVM = account.Sales_area_deletion_flag__c;
                    //销售区域删除标志修改标识
                    salesView.LOEVM_X = isUpdate;
                    //税分类
                    //salesView.TAXKD = account.Tax_Classification__c == null ? '': account.Tax_Classification__c;
                    //税分类修改标识
                    //salesView.TAXKD_X = isUpdate;
                    //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                    salesView.AUFSD = account.Sales_View_Freeze_markers__c ? 'X' : '';
                    // if(account.Customer_Status_MDG__c == '50'){
                    //     salesView.AUFSD = 'X';
                    // }
                    //冻结标记修改标识
                    salesView.AUFSD_X = isUpdate;
                    //价格组
                    salesView.KONDA = account.Price_Group__c == null ? '': account.Price_Group__c;
                    //价格组修改标识
                    salesView.KONDA_X = isUpdate;
                    //销售部门
                    salesView.VKBUR = account.Sales_Office__c == null ? '': picklistId2CodeMap.get(account.Sales_Office__c);
                    //销售部门修改标识
                    salesView.VKBUR_X = isUpdate;
                    //销售组
                    salesView.VKGRP = account.Sales_Group__c == null ? '': picklistId2CodeMap.get(account.Sales_Group__c);
                    //销售组修改标识
                    salesView.VKGRP_X = isUpdate;
                    //与POD相关
                    salesView.PODKZ = account.Related_to_POD__c;
                    //与POD相关修改标识
                    salesView.PODKZ_X = isUpdate;
                    //国际贸易条款
                    salesView.INCO1 = account.International_Trade_Terms__c == null ? '': account.International_Trade_Terms__c;

                    //客户组1
                    salesView.ZKVGR1 = account.Customer_Group_1__c == null ? '': account.Customer_Group_1__c;
                    //客户组1修改标识
                    salesView.ZKVGR1_X = isUpdate;
                    //客户组3
                    salesView.ZKVGR3 = account.Customer_Group_3__c == null ? '': account.Customer_Group_3__c;
                    //客户组3修改标识
                    salesView.ZKVGR3_X = isUpdate;
                    //客户组4
                    salesView.ZKVGR4 = account.Customer_Group_4__c == null ? '': account.Customer_Group_4__c;
                    //客户组4修改标识
                    salesView.ZKVGR4_X = isUpdate;
                    //客户组5
                    salesView.ZKVGR5 = account.Customer_Group_5__c == null ? '': account.Customer_Group_5__c;
                    //客户组5修改标识
                    salesView.ZKVGR5_X = isUpdate;

                    //国际贸易条款修改标识
                    salesView.INCO1_X = isUpdate;
                    //国际贸易条款2
                    salesView.INCO2_L = account.International_Trade_Terms_2__c == null ? '': account.International_Trade_Terms_2__c;
                    //国际贸易条款2修改标识
                    salesView.INCO2_L_X = isUpdate;
                    //货币
                    salesView.WAERS = account.CurrencyIsoCode == null ? '': account.CurrencyIsoCode;
                    //货币修改标识
                    salesView.WAERS_X = isUpdate;
                    //账户分配组
                    salesView.KTGRD = account.Account_Assignment_Group__c == null ? '': account.Account_Assignment_Group__c;
                    //账户分配组修改标识
                    salesView.KTGRD_X = isUpdate;
                    //客户组
                    salesView.KDGRP = account.KDGRP__c == null ? '': account.KDGRP__c;
                    //客户组修改标识
                    salesView.KDGRP_X = isUpdate;
                    //运输条件
                    salesView.VSBED = account.Shipping_Conditions__c == null ? '': account.Shipping_Conditions__c;
                    //运输条件修改标识
                    salesView.VSBED_X = isUpdate;
                    //发货工厂
                    salesView.VWERK = account.Deliverying_Plant__c == null ? '': account.Deliverying_Plant__c;
                    //发货工厂修改标识
                    salesView.VWERK_X = isUpdate;
                    //税类别
                    //salesView.TATYP = account.VAT_Tax_type__c == null ? '': account.VAT_Tax_type__c;
                    //税类别修改标识
                    //salesView.TATYP_X = isUpdate;
                    //客户组2
                    salesView.KVGR2 = account.Customer_Group2__c == null ? '': account.Customer_Group2__c;
                    //客户组2修改标识
                    salesView.KVGR2_X = isUpdate;
                    //1202 追加
                    if (!account.Customer_Tax_category__r.isEmpty() & account.Customer_Tax_category__r != null) {
                        for (Customer_Tax_category__c ctc : account.Customer_Tax_category__r) {
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
                    salesView.BPKUR = account.Receiver__r == null || account.Receiver__r.SAP_Customer_Code__c == null ? '': String.valueOf(account.Receiver__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                    // 开票方修改标识
                    salesView.BPKUR_X = isUpdate;
                    // PYKUR 付款方
                    salesView.PYKUR = account.Payer__r == null || account.Payer__r.SAP_Customer_Code__c == null ? '' : String.valueOf(account.Payer__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                    // 付款放修改标识
                    salesView.PYKUR_X = isUpdate;
                    //客户处我方账户
                    salesView.EIKTO = account.Our_account_at_the_customer_s_place__c == null ? '': account.Our_account_at_the_customer_s_place__c;
                    //客户处我方账户修改标识
                    salesView.EIKTO_X = isUpdate;
                    // 分户：payer 默认主户，bill 放开自己选择，如果不选，传mdg  X (wfc:2025-01-26)
                    if(account.recordtype.DeveloperName == 'Sub_Account'){
                        // PYKUR 付款方
                        salesView.PYKUR = account.ParentCustomerOfSubAcc__r.MDG_Customer_Code__c;
                        // 付款放修改标识
                        salesView.PYKUR_X = isUpdate;
                        // BPKUR 开票方
                        salesView.BPKUR = account.Receiver__c == null || account.Receiver__r.SAP_Customer_Code__c == null ? 'X': String.valueOf(account.Receiver__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                        // 开票方修改标识
                        salesView.BPKUR_X = isUpdate;
                    }
                }
            }
            
            // MDG侧员工类客户不接收地址视图的信息，连定义也不要，在报文中不定义 2024/12/26 变更
            // 员工类客户，就是地址视图还是要，地址类型固定01，只带国家和语言，其他地址视图的字段不需要 2024.12.27 MDG规则更新
            // MDG侧员工类客户不接收销售视图的信息，连定义也不要，在报文中不定义 2024/12/26 变更
            addrList.add(addr);
            if (addrList != null && addrList.size() > 0) {
                customerInfo.ADDR = addrList;
            }
            //if (account != null && account.recordtype.Name != 'Staff' && String.isNotEmpty(salesView.VKORG)) {
            if (account != null && String.isNotEmpty(salesView.VKORG)) {
                saleViewList.add(salesView);
            }
            // 如果是更新已同步到MDG的客户，则不传客户上的公司视图和销售视图信息，因为创建之后会拆分到Customer Extend上
            // 桑老师提供逻辑更新 2025.1.18
            // if (!'Account'.equals(objectName) || 'Sub Account'.equals(account.recordtype.Name) || String.isEmpty(account.MDG_Customer_Code__c)) {
            if (!'Account'.equals(objectName) || String.isEmpty(account.MDG_Customer_Code__c)) {
                if (companyViewList != null && companyViewList.size() > 0) {
                    customerInfo.COMPANY = companyViewList;
                }
                if (saleViewList != null && saleViewList.size() > 0) {
                    customerInfo.SALES = saleViewList;
                }
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
                if(String.isNotBlank(cbc.Bank_Account_Name__c)){
                    bank.ACCNAME=cbc.Bank_Account_Name__c;
                }else{
                    bank.ACCNAME= account.Customer_Name_Local_Language__c == null ? '': account.Customer_Name_Local_Language__c;
                    if(String.isNotBlank(account.Customer_Name_Local_Language_2__c)){
                        bank.ACCNAME += account.Customer_Name_Local_Language_2__c == null ? '': account.Customer_Name_Local_Language_2__c;
                    }
                    //bank.ACCNAME = cbc.Bank_name_local_language__c;
                }
                
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

            ResDeta input = new ResDeta();
            String bodyRes;

            InterfaceLog__c ic = new InterfaceLog__c();
            try {
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http_login = new Http();
                request.setEndpoint(url.replace(' ','%20'));
                request.setMethod('POST');
                request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
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
                    System.debug('input_login.INSTID2='+input_login.INSTID.substring(0,18));
                    //同步成功，更改记录类型，解锁部分字段
                    List<RecordType> recordTypeIdList = [Select id from recordtype where name = 'customer synced sap'];
                    Id objId = Id.valueOf(input_login.INSTID.substring(0,18));
                    System.debug('objId='+objId);
                    System.debug('recordTypeIdList[0].Id ..  '+recordTypeIdList[0].Id);
                    if(objectName == 'Customer_Extend__c'){
                        //update Customer_Extend__c SAPCode information
                        Customer_Extend__c ceTmp = new Customer_Extend__c();
                        ceTmp.Id = cid;
                        ceTmp.Extend_or_Not__c = True;
                        System.debug('ceTmp='+ceTmp);
                        //忽略触发器更新
                        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerExtendTriggerHandler');
                        Database.update(ceTmp);

                        //恢复触发器
                        Utility.IgnoreAction(false,false,false,'');
                    } else if(objectName == 'Account'){
                        
                        //update account SAPCode information
                        // Account accountTmp = new Account();
                        Account accountTmp = [Select Id, Name, MDG_Customer_Code__c, SAP_Customer_Code__c from Account where Id =: cid LIMIT 1];
                        // 历史数据的SAP编码保持不变
                        // 非A和E开头的客商编码,MDG客商编码前2位0补位 2024/12/2 18:00 start
                        // MDG可以同时接收补位和不补位的客商编码
                        if (!input_login.PARTNER.startsWith('A') && !input_login.PARTNER.startsWith('E')) {
                            accountTmp.MDG_Customer_Code__c = '00' + input_login.PARTNER;
                            // 历史数据的SAP编码保持不变
                            if (String.isEmpty(accountTmp.SAP_Customer_Code__c)) {
                                accountTmp.SAP_Customer_Code__c = '00' + input_login.PARTNER;
                            }
                        } else {
                            accountTmp.MDG_Customer_Code__c = input_login.PARTNER;
                            if (String.isEmpty(accountTmp.SAP_Customer_Code__c)) {
                                accountTmp.SAP_Customer_Code__c = input_login.PARTNER;
                            }
                        }
                        // 非A和E开头的客商编码，MDG客商编码前2位0补位 2024/12/2 18:00 end
                        accountTmp.Id = cid;
                        // accountTmp.RecordTypeId = recordTypeIdList[0].Id;
                        System.debug('*****='+accountTmp);
                        //忽略触发器更新
                        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
                        Database.update(accountTmp);

                        //恢复触发器
                        Utility.IgnoreAction(false,false,false,'');
                    } else if (objectName == 'Customer_Address__c'){

                        //2025-02-06  lzx 崔杰要求SAP编码如果为空就放入MDG编码
                        Customer_Address__c caTmp = [Select Id, Name, MDG_Code__c, SAP_Customer_Code__c from Customer_Address__c where Id =: cid LIMIT 1];

                        //update Customer_Address__c SAPCode information
                        //Customer_Address__c caTmp = new Customer_Address__c();
                        //caTmp.Id = cid;
                        caTmp.MDG_Code__c = input_login.PARTNER;
                        // 非A和E开头的客商编码,MDG客商编码前2位0补位 2024/12/2 18:00 start
                        // MDG可以同时接收补位和不补位的客商编码
                        if (!input_login.PARTNER.startsWith('A') && !input_login.PARTNER.startsWith('E')) {
                            caTmp.MDG_Code__c = '00' + input_login.PARTNER;
                        }

                        if (String.isBlank(caTmp.SAP_Customer_Code__c)) {
                            caTmp.SAP_Customer_Code__c = caTmp.MDG_Code__c;
                        }
                        
                        // 非A和E开头的客商编码，MDG客商编码前2位0补位 2024/12/2 18:00 end
                        Database.update(caTmp);
                    }
                    insCustomerHistory(account, customerExtend, cusAdd);
                    Utility.insertLog('SyncCustomerInfoToMDG', '1', body, bodyRes);
                }else {
                    //log
                    Utility.insertLog('SyncCustomerInfoToMDG', '0', body, input_login.SYNRESULT);

                    if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
                        List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
                        Utility.sendMail('SyncCustomerInfoToMDG接口失败：' + customerId, input_login.SYNRESULT, toAddress, 'Salesforce System', '');
                    }

                    return input_login.SYNRESULT;
                }      
            }catch(Exception e) {
                Utility.IgnoreAction(false,false,false,'');
                //Integration Log
                Utility.insertLog('SyncCustomerInfoToMDG', '0', body, 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() + '-------' + bodyRes);

                if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
                    List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
                    Utility.sendMail('SyncCustomerInfoToMDG接口失败：' + customerId, 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() + '-------' + bodyRes, toAddress, 'Salesforce System', '');
                }
                

                return 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage();
            }
        }

    return 'SUCCESS'; 

   }


   public static String generateHmacSha256(String message, String secretKey){
    System.debug('message' + message);
    Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
    String sigture = EncodingUtil.base64Encode(mac);
    System.debug('sigture' + sigture);
    return sigture;
   }

   public static String dateToString(Date originalDate){
    System.debug('originalDate' + originalDate);
    String year = String.valueOf(originalDate.year());
    String month = (originalDate.month() < 10 ? '0' + String.valueOf(originalDate.month()) : String.valueOf(originalDate.month()));
    String day = (originalDate.day() < 10 ? '0' + String.valueOf(originalDate.day()) : String.valueOf(originalDate.day()));

    String formattedDate = year + month + day;
    System.debug(formattedDate); 

    return formattedDate;
   }

   public static void insCustomerHistory(Account account, Customer_Extend__c customerExtend, Customer_Address__c cusAdd) {
        Customer_Sync_History__c csHistory = new Customer_Sync_History__c();
        if (account != null) {
            csHistory.Customer__c = account.Id;
            csHistory.CustomerContents__c = JSON.serialize(account);
            if (customerExtend != null){
                csHistory.Customer_Extend__c = customerExtend.Id;
                csHistory.CustomerExtendContents__c = JSON.serialize(customerExtend);
            }

            if (cusAdd != null){
                csHistory.Customer_Address__c = cusAdd.Id;
                csHistory.CustomerAddressContents__c = JSON.serialize(cusAdd);
            }
        }
        if (csHistory != null) {
            insert csHistory;
        }
   }
   //获取城市，区县，乡镇信息
   public static void getAddressValue(String addressId) {
    
  }

    private static SalesView getSubAccountSalesView(Account account, List<Customer_Tax_category__c> extendTaxList, Map<String,String> paymentTermId2CodeMap, Map<String,String> picklistId2CodeMap, Boolean isUpdate) {
        
        SalesView salesView = new SalesView();
        List<taxCodn> taxCodnList = new List<taxCodn>();
        // if (account.Customer_Extend_Sales__c != null) {
            // if (account.Customer_Extend_Sales__r.Hisense_Entity_Sales__c != null) {
            if (account.Hisense_Entity_Sales__c != null) {
                
                // //公司代码 
                // salesView.BUKRS = account.Customer_Extend_Sub_Account__r.Hisense_Entity__c == null ? '': account.Customer_Extend_Sub_Account__r.Hisense_Entity__c;
                //销售组织
                // salesView.VKORG = account.Customer_Extend_Sales__r.Hisense_Entity_Sales__c == null ? '': account.Customer_Extend_Sales__r.Hisense_Entity_Sales__c;
                salesView.VKORG = account.Hisense_Entity_Sales__c == null ? '': account.Hisense_Entity_Sales__c;
                //产品组（产品中类）
                salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
                //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
                // salesView.VTWEG = account.Customer_Extend_Sales__r.Distribution_Channel__c == null ? '': account.Customer_Extend_Sales__r.Distribution_Channel__c;
                salesView.VTWEG = account.Distribution_Channel__c == null ? '': account.Distribution_Channel__c;
                //客户定价过程
                // salesView.KALKS = account.Customer_Extend_Sales__r.Customer_pricing_process__c == null ? '': account.Customer_Extend_Sales__r.Customer_pricing_process__c;
                salesView.KALKS = account.Customer_pricing_process__c == null ? '': account.Customer_pricing_process__c;
                //客户定价过程修改标识
                salesView.KALKS_X = isUpdate;
                
                // 付款条件分户，使用分户上的付款条件
                if ('13'.equals(account.Sub_account_type__c)) {
                    //付款条件
                    salesView.ZTERM = account.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term_Sales__c);
                } else {
                    //付款条件
                    // salesView.ZTERM = account.Customer_Extend_Sales__r.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.Customer_Extend_Sales__r.Payment_Term_Sales__c);
                    salesView.ZTERM = account.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term_Sales__c);
                }
                //付款条件修改标识
                salesView.ZTERM_X = isUpdate;
                //销售地区 不再传给MDG 2024.11.27 第一轮测试更新
                // salesView.BZIRK = account.Customer_Extend_Sales__r.Sales_Region__c == null ? '': account.Customer_Extend_Sales__r.Sales_Region__c;
                //销售地区修改标识
                // salesView.BZIRK_X = isUpdate;
                //销售区域删除标志
                // salesView.LOEVM = account.Customer_Extend_Sales__r.Sales_area_deletion_flag__c;
                salesView.LOEVM = account.Sales_area_deletion_flag__c;
                //销售区域删除标志修改标识
                salesView.LOEVM_X = isUpdate;
                //税分类
                //salesView.TAXKD = account.Customer_Extend_Sales__r.Tax_Classification__c == null ? '': account.Customer_Extend_Sales__r.Tax_Classification__c;
                //税分类修改标识
                //salesView.TAXKD_X = isUpdate;
                //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                // salesView.AUFSD = account.Customer_Extend_Sales__r.Sales_View_Freeze_markers__c ? 'X' : '';
                salesView.AUFSD = account.Sales_View_Freeze_markers__c ? 'X' : '';
                // if(account.Customer_Extend_Sales__r.Customer_Status_MDG__c == '50'){
                // salesView.AUFSD = 'X';

                // }
                
                //冻结标记修改标识
                salesView.AUFSD_X = isUpdate;
                //价格组
                // salesView.KONDA = account.Customer_Extend_Sales__r.Price_Group__c == null ? '': account.Customer_Extend_Sales__r.Price_Group__c;
                salesView.KONDA = account.Price_Group__c == null ? '': account.Price_Group__c;
                //价格组修改标识
                salesView.KONDA_X = isUpdate;
                //销售部门
                // salesView.VKBUR = account.Customer_Extend_Sales__r.Sales_Office__c == null ? '': picklistId2CodeMap.get(account.Customer_Extend_Sales__r.Sales_Office__c);
                salesView.VKBUR = account.Sales_Office__c == null ? '': picklistId2CodeMap.get(account.Sales_Office__c);
                //销售部门修改标识
                salesView.VKBUR_X = isUpdate;
                //销售组
                // salesView.VKGRP = account.Customer_Extend_Sales__r.Sales_Group__c == null ? '': picklistId2CodeMap.get(account.Customer_Extend_Sales__r.Sales_Group__c);
                salesView.VKGRP = account.Sales_Group__c == null ? '': picklistId2CodeMap.get(account.Sales_Group__c);
                //销售组修改标识
                salesView.VKGRP_X = isUpdate;
                //与POD相关
                salesView.PODKZ = account.Related_to_POD__c;
                //与POD相关修改标识
                salesView.PODKZ_X = isUpdate;
                //国际贸易条款
                // salesView.INCO1 = account.Customer_Extend_Sales__r.International_Trade_Terms__c == null ? '': account.Customer_Extend_Sales__r.International_Trade_Terms__c;
                salesView.INCO1 = account.International_Trade_Terms__c == null ? '': account.International_Trade_Terms__c;
                //国际贸易条款修改标识
                salesView.INCO1_X = isUpdate;

                //客户组1
                salesView.ZKVGR1 = account.Customer_Group_1__c == null ? '': account.Customer_Group_1__c;
                //客户组1修改标识
                salesView.ZKVGR1_X = isUpdate;
                //客户组3
                salesView.ZKVGR3 = account.Customer_Group_3__c == null ? '': account.Customer_Group_3__c;
                //客户组3修改标识
                salesView.ZKVGR3_X = isUpdate;
                //客户组4
                salesView.ZKVGR4 = account.Customer_Group_4__c == null ? '': account.Customer_Group_4__c;
                //客户组4修改标识
                salesView.ZKVGR4_X = isUpdate;
                //客户组5
                salesView.ZKVGR5 = account.Customer_Group_5__c == null ? '': account.Customer_Group_5__c;
                //客户组5修改标识
                salesView.ZKVGR5_X = isUpdate;

                //国际贸易条款2
                // salesView.INCO2_L = account.Customer_Extend_Sales__r.International_Trade_Terms_2__c == null ? '': account.Customer_Extend_Sales__r.International_Trade_Terms_2__c;
                salesView.INCO2_L = account.International_Trade_Terms_2__c == null ? '': account.International_Trade_Terms_2__c;
                //国际贸易条款2修改标识
                salesView.INCO2_L_X = isUpdate;
                //货币
                // salesView.WAERS = account.Customer_Extend_Sales__r.CurrencyIsoCode == null ? '': account.Customer_Extend_Sales__r.CurrencyIsoCode;
                salesView.WAERS = account.CurrencyIsoCode == null ? '': account.CurrencyIsoCode;
                //货币修改标识
                salesView.WAERS_X = isUpdate;
                //账户分配组
                // salesView.KTGRD = account.Customer_Extend_Sales__r.Account_Assignment_Group__c == null ? '': account.Customer_Extend_Sales__r.Account_Assignment_Group__c;
                salesView.KTGRD = account.Account_Assignment_Group__c == null ? '': account.Account_Assignment_Group__c;
                //账户分配组修改标识
                salesView.KTGRD_X = isUpdate;
                //客户组
                // salesView.KDGRP = account.Customer_Extend_Sales__r.KDGRP__c == null ? '': account.Customer_Extend_Sales__r.KDGRP__c;
                salesView.KDGRP = account.KDGRP__c == null ? '': account.KDGRP__c;
                //客户组修改标识
                salesView.KDGRP_X = isUpdate;
                //运输条件
                // salesView.VSBED = account.Customer_Extend_Sales__r.Shipping_Conditions__c == null ? '': account.Customer_Extend_Sales__r.Shipping_Conditions__c;
                salesView.VSBED = account.Shipping_Conditions__c == null ? '': account.Shipping_Conditions__c;
                //运输条件修改标识
                salesView.VSBED_X = isUpdate;
                //发货工厂
                // salesView.VWERK = account.Customer_Extend_Sales__r.Deliverying_Plant__c == null ? '': account.Customer_Extend_Sales__r.Deliverying_Plant__c;
                salesView.VWERK = account.Deliverying_Plant__c == null ? '': account.Deliverying_Plant__c;
                //发货工厂修改标识
                salesView.VWERK_X = isUpdate;
                //税类别
                //salesView.TATYP = account.Customer_Extend_Sales__r.VAT_Tax_type__c == null ? '': account.Customer_Extend_Sales__r.VAT_Tax_type__c;
                //税类别修改标识
                //salesView.TATYP_X = isUpdate;
                //客户组2
                // salesView.KVGR2 = account.Customer_Extend_Sales__r.Customer_Group2__c == null ? '': account.Customer_Extend_Sales__r.Customer_Group2__c;
                salesView.KVGR2 = account.Customer_Group2__c == null ? '': account.Customer_Group2__c;
                //客户组2修改标识
                salesView.KVGR2_X = isUpdate;
                //客户处我方账户
                salesView.EIKTO = account.Our_account_at_the_customer_s_place__c == null ? '': account.Our_account_at_the_customer_s_place__c;
                //客户处我方账户修改标识
                salesView.EIKTO_X = isUpdate;

                // 分户选择的客户拓展上的税分类 2024.12.29 优化
                if(extendTaxList != null){
                    for (Customer_Tax_category__c cetc : extendTaxList) {
                        taxCodn tcd = new taxCodn();
                        // 国家地区代码 例：国内CN
                        tcd.ALAND = cetc.CountryCodeAndCustomerIdF__c == null ? '': cetc.CountryCodeAndCustomerIdF__c;
                        // 税收条件类型 例：NWST
                        tcd.TATYP = cetc.Tax_category_code__c == null ? '': cetc.Tax_category_code__c;
                        //税分类 1或者0
                        tcd.TAXKD = cetc.Tax_category__r.Name == null ? '': cetc.Tax_category__r.Name;
                        //税分类修改标识符
                        tcd.TAXKD_X = isUpdate;
                        taxCodnList.add(tcd);  
                    }
                }
                
                salesView.TAXCODN = taxCodnList;
                // CustomerExtend增加4个字段，bill to，payer，price list, payment overdue times 2025.1.6 优化
                // 分户客户的开票方，付款方默认主户
                // 分户：payer默认主户(分户传空，MDG会默认成主户)，bill放开自己选择，如果不选，传X 2025.1.13 优化
                // BPKUR 开票方
                salesView.BPKUR = account.Receiver__c == null || account.Receiver__r.SAP_Customer_Code__c == null ? 'X': String.valueOf(account.Receiver__r.SAP_Customer_Code__c.replaceAll('^0+', ''));
                // 开票方修改标识
                salesView.BPKUR_X = isUpdate;
                // PYKUR 付款方
                // salesView.PYKUR = account.ParentCustomerOfSubAcc__r.MDG_Customer_Code__c;
                // 付款放修改标识
                // salesView.PYKUR_X = isUpdate;
            }
        // } else {
            // if (account.ParentCustomerOfSubAcc__r.Hisense_Entity_Sales__c != null) {
            //     System.debug('account.ParentCustomerOfSubAcc__r');
            //     System.debug(account.ParentCustomerOfSubAcc__r);
            //     // 1.2 分户上的客户拓展为空，默认同步主户上的公司视图和销售视图信息
            //     //销售组织
            //     salesView.VKORG = account.ParentCustomerOfSubAcc__r.Hisense_Entity_Sales__c == null ? '': account.ParentCustomerOfSubAcc__r.Hisense_Entity_Sales__c;
            //     //产品组（产品中类）
            //     salesView.SPART = MDG_Interface__c.getValues('CustomerMaintain').Product_Group__c;
            //     //分销渠道 分销渠道直接从数据中取值，代替之前MDG要求的固定值 2025.1.10
            //     salesView.VTWEG = account.ParentCustomerOfSubAcc__r.Distribution_Channel__c == null ? '': account.ParentCustomerOfSubAcc__r.Distribution_Channel__c;
            //     //客户定价过程
            //     salesView.KALKS = account.ParentCustomerOfSubAcc__r.Customer_pricing_process__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_pricing_process__c;
            //     //客户定价过程修改标识
            //     salesView.KALKS_X = isUpdate;
            //     // 付款条件分户，使用分户上的付款条件
            //     if ('13'.equals(account.Sub_account_type__c)) {
            //         //付款条件
            //         salesView.ZTERM = account.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term_Sales__c);
            //     } else {
            //         //付款条件
            //         salesView.ZTERM = account.ParentCustomerOfSubAcc__r.Payment_Term_Sales__c == null ? '': paymentTermId2CodeMap.get(account.ParentCustomerOfSubAcc__r.Payment_Term_Sales__c);
            //     }
            //     //付款条件修改标识
            //     salesView.ZTERM_X = isUpdate;
            //     //销售地区 不再传给MDG 2024.11.27 第一轮测试更新
            //     // salesView.BZIRK = account.ParentCustomerOfSubAcc__r.Sales_Region__c == null ? '': account.ParentCustomerOfSubAcc__r.Sales_Region__c;
            //     //销售地区修改标识
            //     // salesView.BZIRK_X = isUpdate;
            //     //销售区域删除标志
            //     salesView.LOEVM = account.ParentCustomerOfSubAcc__r.Sales_area_deletion_flag__c;
            //     //销售区域删除标志修改标识
            //     salesView.LOEVM_X = isUpdate;
            //     //税分类
            //     //salesView.TAXKD = account.ParentCustomerOfSubAcc__r.Tax_Classification__c == null ? '': account.ParentCustomerOfSubAcc__r.Tax_Classification__c;
            //     //税分类修改标识
            //     //salesView.TAXKD_X = isUpdate;
            //     //冻结标记 新增冻结标记手动选择，桑老师内部沟通 优化 2024.12.26 
            //     salesView.AUFSD = account.ParentCustomerOfSubAcc__r.Sales_View_Freeze_markers__c ? 'X' : '';
            //     // if(account.ParentCustomerOfSubAcc__r.Customer_Status_MDG__c == '50'){
            //     // salesView.AUFSD = 'X';

            //     // }
                
            //     //冻结标记修改标识
            //     salesView.AUFSD_X = isUpdate;
            //     //价格组
            //     salesView.KONDA = account.ParentCustomerOfSubAcc__r.Price_Group__c == null ? '': account.ParentCustomerOfSubAcc__r.Price_Group__c;
            //     //价格组修改标识
            //     salesView.KONDA_X = isUpdate;
            //     //销售部门
            //     salesView.VKBUR = account.ParentCustomerOfSubAcc__r.Sales_Office__c == null ? '': picklistId2CodeMap.get(account.ParentCustomerOfSubAcc__r.Sales_Office__c);
            //     //销售部门修改标识
            //     salesView.VKBUR_X = isUpdate;
            //     //销售组
            //     salesView.VKGRP = account.ParentCustomerOfSubAcc__r.Sales_Group__c == null ? '': picklistId2CodeMap.get(account.ParentCustomerOfSubAcc__r.Sales_Group__c);
            //     //销售组修改标识
            //     salesView.VKGRP_X = isUpdate;
            //     //与POD相关
            //     salesView.PODKZ = account.Related_to_POD__c;
            //     //与POD相关修改标识
            //     salesView.PODKZ_X = isUpdate;
            //     //国际贸易条款
            //     salesView.INCO1 = account.ParentCustomerOfSubAcc__r.International_Trade_Terms__c == null ? '': account.ParentCustomerOfSubAcc__r.International_Trade_Terms__c;
            //     //国际贸易条款修改标识
            //     salesView.INCO1_X = isUpdate;
            //     //国际贸易条款2
            //     salesView.INCO2_L = account.ParentCustomerOfSubAcc__r.International_Trade_Terms_2__c == null ? '': account.ParentCustomerOfSubAcc__r.International_Trade_Terms_2__c;
            //     //国际贸易条款2修改标识
            //     salesView.INCO2_L_X = isUpdate;
            //     //货币
            //     salesView.WAERS = account.CurrencyIsoCode == null ? '': account.CurrencyIsoCode;
            //     //货币修改标识
            //     salesView.WAERS_X = isUpdate;
            //     //账户分配组
            //     salesView.KTGRD = account.ParentCustomerOfSubAcc__r.Account_Assignment_Group__c == null ? '': account.ParentCustomerOfSubAcc__r.Account_Assignment_Group__c;
            //     //账户分配组修改标识
            //     salesView.KTGRD_X = isUpdate;
            //     //客户组
            //     salesView.KDGRP = account.ParentCustomerOfSubAcc__r.KDGRP__c == null ? '': account.ParentCustomerOfSubAcc__r.KDGRP__c;
            //     //客户组修改标识
            //     salesView.KDGRP_X = isUpdate;
            //     //运输条件
            //     salesView.VSBED = account.ParentCustomerOfSubAcc__r.Shipping_Conditions__c == null ? '': account.ParentCustomerOfSubAcc__r.Shipping_Conditions__c;
            //     //运输条件修改标识
            //     salesView.VSBED_X = isUpdate;
            //     //发货工厂
            //     salesView.VWERK = account.ParentCustomerOfSubAcc__r.Deliverying_Plant__c == null ? '': account.ParentCustomerOfSubAcc__r.Deliverying_Plant__c;
            //     //发货工厂修改标识
            //     salesView.VWERK_X = isUpdate;
            //     //税类别
            //     //salesView.TATYP = account.ParentCustomerOfSubAcc__r.VAT_Tax_type__c == null ? '': account.ParentCustomerOfSubAcc__r.VAT_Tax_type__c;
            //     //税类别修改标识
            //     //salesView.TATYP_X = isUpdate;
            //     //客户组2
            //     salesView.KVGR2 = account.ParentCustomerOfSubAcc__r.Customer_Group2__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_Group2__c;
            //     //客户组2修改标识
            //     salesView.KVGR2_X = isUpdate;
            //     //1202 追加
            //     // if (!account.Customer_Tax_category__r.isEmpty() & account.Customer_Tax_category__r != null) {
            //     //     for (Customer_Tax_category__c ctc : account.Customer_Tax_category__r) {
            //     //         taxCodn tc = new taxCodn();
            //     //         // 国家地区代码 例：国内CN
            //     //         tc.ALAND = ctc.CountryCodeAndCustomerIdF__c == null ? '': ctc.CountryCodeAndCustomerIdF__c;
            //     //         // 税收条件类型 例：NWST
            //     //         tc.TATYP = ctc.Tax_category_code__c == null ? '': ctc.Tax_category_code__c;
            //     //         //税分类 1或者0
            //     //         tc.TAXKD = ctc.Tax_category__r.Name == null ? '': ctc.Tax_category__r.Name;
            //     //         //税分类修改标识符
            //     //         tc.TAXKD_X = isUpdate;
            //     //         taxCodnList.add(tc);
            //     //     }
            //     // } else {
            //         // 分户客户如果没有税分类，从主户上获取税分类
            //         List<Customer_Tax_category__c> parentTaxCategory = [Select Id,Name,Tax_category_code__c,Tax_category__r.Name,CountryCodeAndCustomerIdF__c,sortF__c from Customer_Tax_category__c WHERE Customer__c =: account.ParentCustomerOfSubAcc__c];
            //         if (parentTaxCategory != null && parentTaxCategory.size() > 0) {
            //             for (Customer_Tax_category__c ctc : parentTaxCategory) {
            //                 taxCodn tc = new taxCodn();
            //                 // 国家地区代码 例：国内CN
            //                 tc.ALAND = ctc.CountryCodeAndCustomerIdF__c == null ? '': ctc.CountryCodeAndCustomerIdF__c;
            //                 // 税收条件类型 例：NWST
            //                 tc.TATYP = ctc.Tax_category_code__c == null ? '': ctc.Tax_category_code__c;
            //                 //税分类 1或者0
            //                 tc.TAXKD = ctc.Tax_category__r.Name == null ? '': ctc.Tax_category__r.Name;
            //                 //税分类修改标识符
            //                 tc.TAXKD_X = isUpdate;
            //                 taxCodnList.add(tc);
            //             }
            //         }
            //     // }
            //     salesView.TAXCODN = taxCodnList;
            // }
            
        //     // 21.同步接口中追加Payer和Bill to两个字段的同步逻辑，Payer对应付款方，Bill to对应开票方 2024.12.31 优化
        //     // 分户客户的开票方，付款方，固定成主户 2025.1.7
        //         // 分户：payer默认主户(分户传空，MDG会默认成主户)，bill放开自己选择，如果不选，传X 2025.1.13 优化
        //     // BPKUR 开票方
        //     salesView.BPKUR = account.Receiver__c == null ? 'X' : account.Receiver__c;
        //     // 开票方修改标识
        //     salesView.BPKUR_X = isUpdate;
        //     // PYKUR 付款方
        //     // salesView.PYKUR = account.ParentCustomerOfSubAcc__r.MDG_Customer_Code__c;
        //     // 付款放修改标识
        //     // salesView.PYKUR_X = isUpdate;
        // }
        return salesView;
    }
    private static CompanyView getSubAccountCompanyView(Account account, Map<String,String> paymentTermId2CodeMap, Map<String,String> picklistId2CodeMap, Boolean isUpdate) {

        // 分户同步公司信息，主户的默认公司视图 2024.12.26
        CompanyView companyView = new CompanyView();

        // if (account.Customer_Extend_Sub_Account__c != null) {

            // if (account.Customer_Extend_Sub_Account__r.Hisense_Entity__c != null) {
            if (account.Hisense_Entity__c != null) {
                
                //公司代码
                // companyView.BUKRS = account.Customer_Extend_Sub_Account__r.Hisense_Entity__c == null ? '': account.Customer_Extend_Sub_Account__r.Hisense_Entity__c;
                companyView.BUKRS = account.Hisense_Entity__c == null ? '': account.Hisense_Entity__c;
                //付款条件
                // companyView.ZTERM = account.Customer_Extend_Sub_Account__r.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Customer_Extend_Sub_Account__r.Payment_Term__c);
                companyView.ZTERM = account.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
                //付款条件修改标识
                companyView.ZTERM_X = isUpdate;
                //统驭科目
                // companyView.AKONT = account.Customer_Extend_Sub_Account__r.Reconciliation_Customer__c == null ? '': account.Customer_Extend_Sub_Account__r.Reconciliation_Customer__c;
                companyView.AKONT = account.Reconciliation_Customer__c == null ? '': account.Reconciliation_Customer__c;
                //统驭科目修改标识
                companyView.AKONT_X = isUpdate;
                //选择规则
                // companyView.SREGL = account.Customer_Extend_Sub_Account__r.Selection_Rule__c == null ? '': account.Customer_Extend_Sub_Account__r.Selection_Rule__c;
                // companyView.SREGL = account.Selection_Rule__c == null ? '': account.Selection_Rule__c;
                //选择规则修改标识
                companyView.SREGL_X = isUpdate;
                //账户备注
                // companyView.KVERM = account.Customer_Extend_Sub_Account__r.Account_Remarks__c == null ? '': account.Customer_Extend_Sub_Account__r.Account_Remarks__c;
                companyView.KVERM = account.Account_Remarks__c == null ? '': account.Account_Remarks__c;
                //账户备注修改标识
                companyView.KVERM_X = isUpdate;
                //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
                // companyView.NODEL = account.Customer_Extend_Sub_Account__r.Company_View_Freeze_markers__c ? 'X' : '';
                companyView.NODEL = account.Company_View_Freeze_markers__c ? 'X' : '';
                //冻结标记修改标识
                companyView.NODEL_X = isUpdate;
                //支付方式
                // companyView.ZWELS = account.Customer_Extend_Sub_Account__r.Payment_Method_MDG__c == null ? '': account.Customer_Extend_Sub_Account__r.Payment_Method_MDG__c.substring(0,1);
                companyView.ZWELS = account.Payment_Method_MDG__c == null ? '': account.Payment_Method_MDG__c.substring(0,1);
                //支付方式修改标识
                companyView.ZWELS_X = isUpdate;
                //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
                // companyView.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
                //线上/线下修改标识
                // companyView.ZZLINE_X = isUpdate;
                //公司区域删除标识
                // companyView.LOEVM = account.Customer_Extend_Sub_Account__r.Delete_identification_for_company_region__c;
                companyView.LOEVM = account.Delete_identification_for_company_region__c;
                //公司区域删除标识修改标识
                companyView.LOEVM_X = isUpdate;
                //客户EDI 默认库位
                // companyView.ZZLGORT = account.Customer_Extend_Sub_Account__r.Stor_Location__c == null ? '': picklistId2CodeMap.get(account.Customer_Extend_Sub_Account__r.Stor_Location__c);
                companyView.ZZLGORT = account.Stor_Location__c == null ? '': picklistId2CodeMap.get(account.Stor_Location__c);
                //客户EDI 默认库位修改标识
                companyView.ZZLGORT_X = isUpdate;
                //客户EDI ID
                // companyView.ZZSORT1 = account.Customer_Extend_Sub_Account__r.EDI_ID__c == null ? '': account.Customer_Extend_Sub_Account__r.EDI_ID__c;
                companyView.ZZSORT1 = account.EDI_ID__c == null ? '': account.EDI_ID__c;
                //客户EDI ID修改标识
                companyView.ZZSORT1_X = isUpdate;
                //客户EDI ID2
                // companyView.ZZSORT2 = account.Customer_Extend_Sub_Account__r.EDI_ID2__c == null ? '': account.Customer_Extend_Sub_Account__r.EDI_ID2__c;
                companyView.ZZSORT2 = account.EDI_ID2__c == null ? '': account.EDI_ID2__c;
                //客户EDI ID2修改标识
                companyView.ZZSORT2_X = isUpdate;
                //客户EDI 类型
                // companyView.EDI_TYPE = account.Customer_Extend_Sub_Account__r.Customer_EDI_ID_Type__c == null ? '': account.Customer_Extend_Sub_Account__r.Customer_EDI_ID_Type__c;
                companyView.EDI_TYPE = account.Customer_EDI_ID_Type__c == null ? '': account.Customer_EDI_ID_Type__c;
                //客户EDI 类型修改标识
                companyView.EDI_TYPE_X = isUpdate;
                //TV lisense
                // companyView.ZTV = account.Customer_Extend_Sub_Account__r.TV_lisense__c == null ? '': account.Customer_Extend_Sub_Account__r.TV_lisense__c;
                companyView.ZTV = account.TV_lisense__c == null ? '': account.TV_lisense__c;
                //TV lisense修改标识
                companyView.ZTV_X = isUpdate;
                // if(account.Customer_Extend_Sub_Account__r.Valid_to__c != null){
                if(account.Valid_to__c != null){

                    //Valid to
                    // companyView.ZVALID_TO = dateToString(account.Customer_Extend_Sub_Account__r.Valid_to__c);
                    companyView.ZVALID_TO = dateToString(account.Valid_to__c);
                    //Valid to修改标识
                    companyView.ZVALID_TO_X = isUpdate;

                }
                //包装类型
                // companyView.PACKAGING_TYPE = account.Customer_Extend_Sub_Account__r.Packing_Type__c == null ? '': account.Customer_Extend_Sub_Account__r.Packing_Type__c;
                companyView.PACKAGING_TYPE = account.Packing_Type__c == null ? '': account.Packing_Type__c;
                //包装类型修改标识
                companyView.PACKAGING_TYPE_X = isUpdate;
                //VAT 号
                // companyView.ZZSH = account.Customer_Extend_Sub_Account__r.Add_VAT_Reg_No__c == null ? '': account.Customer_Extend_Sub_Account__r.Add_VAT_Reg_No__c;
                companyView.ZZSH = account.Add_VAT_Reg_No__c == null ? '': account.Add_VAT_Reg_No__c;
                //VAT 号修改标识
                companyView.ZZSH_X = isUpdate;
                //VAT  类型
                // companyView.ZKHFL = account.Customer_Extend_Sub_Account__r.VAT_Tax_type__c == null ? '': account.Customer_Extend_Sub_Account__r.VAT_Tax_type__c;
                companyView.ZKHFL = account.VAT_Tax_type__c == null ? '': account.VAT_Tax_type__c;
                //VAT  类型修改标识
                companyView.ZKHFL_X = isUpdate;
            }
        // } else {

            // if (account.ParentCustomerOfSubAcc__r.Hisense_Entity__c != null) {
                
            //     // 分户同步公司信息，主户的默认公司视图 2024.12.26
            //     //公司代码
            //     companyView.BUKRS = account.ParentCustomerOfSubAcc__r.Hisense_Entity__c == null ? '': account.ParentCustomerOfSubAcc__r.Hisense_Entity__c;
            //     //付款条件
            //     companyView.ZTERM = account.ParentCustomerOfSubAcc__r.Payment_Term__c == null ? '': paymentTermId2CodeMap.get(account.Payment_Term__c);
            //     //付款条件修改标识
            //     companyView.ZTERM_X = isUpdate;
            //     //统驭科目
            //     companyView.AKONT = account.ParentCustomerOfSubAcc__r.Reconciliation_Customer__c == null ? '': account.ParentCustomerOfSubAcc__r.Reconciliation_Customer__c;
            //     //统驭科目修改标识
            //     companyView.AKONT_X = isUpdate;
            //     //选择规则
            //     companyView.SREGL = account.ParentCustomerOfSubAcc__r.Selection_Rules__c == null ? '': account.ParentCustomerOfSubAcc__r.Selection_Rules__c;
            //     //选择规则修改标识
            //     companyView.SREGL_X = isUpdate;
            //     //账户备注
            //     companyView.KVERM = account.ParentCustomerOfSubAcc__r.Account_Remarks__c == null ? '': account.ParentCustomerOfSubAcc__r.Account_Remarks__c;
            //     //账户备注修改标识
            //     companyView.KVERM_X = isUpdate;
            //     //冻结标记 新增冻结标记手动选择，桑老师内部沟通 2024.12.26 
            //     companyView.NODEL = account.ParentCustomerOfSubAcc__r.Company_View_Freeze_markers__c ? 'X' : '';
            //     //冻结标记修改标识
            //     companyView.NODEL_X = isUpdate;
            //     //支付方式
            //     companyView.ZWELS = account.ParentCustomerOfSubAcc__r.Payment_Method_MDG__c == null ? '': account.ParentCustomerOfSubAcc__r.Payment_Method_MDG__c.substring(0,1);
            //     //支付方式修改标识
            //     companyView.ZWELS_X = isUpdate;
            //     //线上/线下 字段从公司视图中移除，归属客户主信息 2024.11.27 第一轮测试更新
            //     // companyView.ZZLINE = account.E_commerce_Customer_Label__c == null ? '': account.E_commerce_Customer_Label__c;
            //     //线上/线下修改标识
            //     // companyView.ZZLINE_X = isUpdate;
            //     //公司区域删除标识
            //     companyView.LOEVM = account.ParentCustomerOfSubAcc__r.Delete_identification_for_company_region__c;
            //     //公司区域删除标识修改标识
            //     companyView.LOEVM_X = isUpdate;
            //     //客户EDI 默认库位 默认库位使用旧字段Stor_Location__c 2024/12/30 优化
            //     companyView.ZZLGORT = account.ParentCustomerOfSubAcc__r.Stor_Location__c == null ? '': picklistId2CodeMap.get(account.ParentCustomerOfSubAcc__r.Stor_Location__c);
            //     //客户EDI 默认库位修改标识
            //     companyView.ZZLGORT_X = isUpdate;
            //     //客户EDI ID
            //     companyView.ZZSORT1 = account.ParentCustomerOfSubAcc__r.EDI_ID__c == null ? '': account.ParentCustomerOfSubAcc__r.EDI_ID__c;
            //     //客户EDI ID修改标识
            //     companyView.ZZSORT1_X = isUpdate;
            //     //客户EDI ID2
            //     companyView.ZZSORT2 = account.ParentCustomerOfSubAcc__r.EDI_ID2__c == null ? '': account.ParentCustomerOfSubAcc__r.EDI_ID2__c;
            //     //客户EDI ID2修改标识
            //     companyView.ZZSORT2_X = isUpdate;
            //     //客户EDI 类型
            //     companyView.EDI_TYPE = account.ParentCustomerOfSubAcc__r.Customer_EDI_ID_Type__c == null ? '': account.ParentCustomerOfSubAcc__r.Customer_EDI_ID_Type__c;
            //     //客户EDI 类型修改标识
            //     companyView.EDI_TYPE_X = isUpdate;
            //     //TV lisense
            //     companyView.ZTV = account.ParentCustomerOfSubAcc__r.TV_lisense__c == null ? '': account.ParentCustomerOfSubAcc__r.TV_lisense__c;
            //     //TV lisense修改标识
            //     companyView.ZTV_X = isUpdate;
            //     if(account.ParentCustomerOfSubAcc__r.Valid_to__c != null){

            //         //Valid to
            //         companyView.ZVALID_TO = dateToString(account.ParentCustomerOfSubAcc__r.Valid_to__c);
            //         //Valid to修改标识
            //         companyView.ZVALID_TO_X = isUpdate;

            //     }
            //     //包装类型
            //     companyView.PACKAGING_TYPE = account.ParentCustomerOfSubAcc__r.Packing_Type__c == null ? '': account.ParentCustomerOfSubAcc__r.Packing_Type__c;
            //     //包装类型修改标识
            //     companyView.PACKAGING_TYPE_X = isUpdate;
            //     //VAT 号
            //     companyView.ZZSH = account.ParentCustomerOfSubAcc__r.Add_VAT_Reg_No__c == null ? '': account.ParentCustomerOfSubAcc__r.Add_VAT_Reg_No__c;
            //     //VAT 号修改标识
            //     companyView.ZZSH_X = isUpdate;
            //     //VAT  类型
            //     companyView.ZKHFL = account.ParentCustomerOfSubAcc__r.VAT_Tax_type__c == null ? '': account.ParentCustomerOfSubAcc__r.VAT_Tax_type__c;
            //     //VAT  类型修改标识
            //     companyView.ZKHFL_X = isUpdate;
            // }
        // }
        return companyView;
    }
}