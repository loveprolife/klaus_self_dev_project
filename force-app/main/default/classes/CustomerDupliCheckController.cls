public without sharing class CustomerDupliCheckController {

    // 查重校验
    @AuraEnabled(cacheable=true)
    public static Account findAccount(String country, String registrationNumber, String recordTypeId) {
        // 本地查重
        List<Account> accounts = [
            SELECT Id,Name FROM Account 
            WHERE Guarantor_Country_Code__c = :country AND Company_Registration_Number__c = :registrationNumber
            LIMIT 1
        ];

        if (accounts != null && accounts.size() > 0) {
            return accounts.get(0);
        } else if (country != null && registrationNumber != null && recordTypeId != null) {
            
            // 获取对应RecordType的DeveloperName
            String recordTypeName = Schema.SobjectType.Account.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            String traderType = '';
            // 根据DeveloperName获取MDG客商类型代码
            if (!Test.isRunningTest()) {
                traderType = [SELECT DeveloperName,MDG_SFDC_Name__c, MDG_Code__c, MDG_Sub_Code__c FROM MDG_Client_Mapping__mdt WHERE MDG_SFDC_Name__c =: recordTypeName].MDG_Code__c;
            } else {
                traderType = 'H002';
            }

            system.debug('country:'+country);
            system.debug('traderType:'+traderType);
            system.debug('registrationNumber:'+registrationNumber);
            GetCustomerInfoFromMDG.CustomerInfo customer = GetCustomerInfoFromMDG.getCustomerInformationFromMDG(country, traderType, registrationNumber);
            // GetCustomerInfoFromMDG.DATA customer;

            // MDG接口查重 TODO
            if (customer != null && String.isNotEmpty(customer.PARTNER)) {
                Account mdgAcc = new Account();
                // MDG把原来的NameEN和NameLocal对换 2025.1.16
                mdgAcc.Name = String.isNotEmpty(customer.NAME_LO) ? customer.NAME_LO : '';//客商名称（当地语言）
                // 非A和E开头的客商编码,MDG客商编码前2位0补位 2024/12/2 18:00 start
                // MDG可以同时接收补位和不补位的客商编码
                if (!customer.PARTNER.startsWith('A') && !customer.PARTNER.startsWith('E')) {
                    mdgAcc.SAP_Customer_Code__c = '00' + customer.PARTNER;
                    mdgAcc.MDG_Customer_Code__c = '00' + customer.PARTNER;
                } else {
                    mdgAcc.SAP_Customer_Code__c = customer.PARTNER;
                    mdgAcc.MDG_Customer_Code__c = customer.PARTNER;
                }
                mdgAcc.Customer_Name_Local_Language__c = String.isNotEmpty(customer.NAME_EN) ? customer.NAME_EN : '';
                mdgAcc.Customer_Short_Name__c = customer.BU_SORT1;//简称
                mdgAcc.FormerName__c = String.isNotEmpty(customer.ZZFONM) ? customer.ZZFONM : '';//曾用名
                mdgAcc.ID_Type__c = String.isNotEmpty(customer.ZZZJLX) ? customer.ZZZJLX : '';//证件类型
                mdgAcc.Company_Registration_Number__c = customer.ZZRENO;//注册码
                mdgAcc.VAT_Registration_Number__c = String.isNotEmpty(customer.ZZZJLX) ? customer.ZZZJLX : '';//VAT编号
                mdgAcc.DUNS_Number__c = String.isNotEmpty(customer.ZZDUNS) ? customer.ZZDUNS : '';//DUNS编号
                mdgAcc.License_Expiration_Date__c = customer.ZZBLED != null ? stringToDate(customer.ZZBLED) : null;//营业执照到日期
                mdgAcc.Registration_Date__c = customer.FOUND_DAT != null ? stringToDate(customer.FOUND_DAT) : null;//注册日期
                mdgAcc.Registered_Capital__c = customer.ZZREFD != null ? Decimal.valueOf(customer.ZZREFD?.replaceAll('[^\\d.-]', '')) : null;//注册资金
                mdgAcc.Paid_In_Funds__c = customer.ZZPDFD != null ? Decimal.valueOf(customer.ZZPDFD?.replaceAll('[^\\d.-]', '')) : null;//实缴资金
                mdgAcc.Corporate_Representative__c = String.isNotEmpty(customer.ZZLERE) ? customer.ZZLERE : '';//法定代表人
                mdgAcc.Unit_Nature__c = String.isNotEmpty(customer.ZZCMAT) ? customer.ZZCMAT : ''; //单位性质
                mdgAcc.Annual_Revenue_Scale__c = customer.ZZANRE != null ? String.valueOf(customer.ZZANRE) : null;//年营业额
                // mdgAcc.Is_Listed_Company__c = customer.ZZIFCM;//是否上市公司
                mdgAcc.Listed_Company_Code__c = String.isNotEmpty(customer.ZZCMCO) ? customer.ZZCMCO : '';//上市公司代码

                mdgAcc.Language__c = String.isNotEmpty(customer.BU_LANGU) ? customer.BU_LANGU : '';//语言
                mdgAcc.NumberOfEmployees = customer.ZZEMCN != null ? customer.ZZEMCN : null;//员工人数
                mdgAcc.Website = String.isNotEmpty(customer.URI_ADDR) ? customer.URI_ADDR : '';//网址
                mdgAcc.Main_Business_Scope__c = String.isNotEmpty(customer.ZZBNAR) ? customer.ZZBNAR : '';//经营范围
                mdgAcc.Email__c = String.isNotEmpty(customer.SMTP_ADDR) ? customer.SMTP_ADDR : '';//邮箱
                mdgAcc.Fax = String.isNotEmpty(customer.FAX_NUMBER) ? customer.FAX_NUMBER : '';//传真
                mdgAcc.Phone = String.isNotEmpty(customer.TEL_NUMBER) ? customer.TEL_NUMBER : '';//电话

                mdgAcc.Industry_Sector__c = customer.IND_SECTOR;//行业(国标二级)
                //ZZJTKHMC//集团客户名称
                if (String.isNotEmpty(customer.ZZCVCO)) {
                    List<Account> belongAcc = [SELECT Id, Name FROM Account WHERE SAP_Customer_Code__c = :customer.ZZCVCO];
                    if (belongAcc != null && belongAcc.size() > 0) {
                        mdgAcc.ParentId = belongAcc[0].Id;//所属客商编码
                    }
                }
                mdgAcc.Customer_Status_MDG__c = String.isNotEmpty(customer.ZZCUSTA) ? customer.ZZCUSTA : '';//客户状态
                mdgAcc.Customer_Risk_Level__c = String.isNotEmpty(customer.ZZCUSRISL) ? customer.ZZCUSRISL : '';//客户风险等级
                mdgAcc.Customer_Risk_Type__c = String.isNotEmpty(customer.ZZCUSRITY) ? customer.ZZCUSRITY : '';// 客户风险类型
                mdgAcc.Unified_customer_group_code__c = String.isNotEmpty(customer.ZZCUSGR) ? customer.ZZCUSGR : '';//统一客户组编码
                mdgAcc.Channel_Customer_Categories__c = String.isNotEmpty(customer.ZZCHCUSCA) ? customer.ZZCHCUSCA : '';//渠道客户大类
                mdgAcc.Channel_Customer_Subcategories__c = String.isNotEmpty(customer.ZZCHCUSSU) ? customer.ZZCHCUSSU : '';//渠道客户小类
                mdgAcc.credit_rating__c = String.isNotEmpty(customer.ZZCRERAT) ? customer.ZZCRERAT : '';//信用等级
                mdgAcc.Transportation_area__c = String.isNotEmpty(customer.LZONE) ? customer.LZONE : ''; // 运输区域
                mdgAcc.Overseas_customer_level__c =String.isNotEmpty(customer.ZZHWKHFJ) ? customer.ZZHWKHFJ : ''; //海外客户分级
                mdgAcc.Sub_account_type__c = String.isNotEmpty(customer.ZZFHLX) ? customer.ZZFHLX : '';//分户类型
                mdgAcc.Reasons_for_customer_segmentation__c = String.isNotEmpty(customer.ZZFHYY) ? customer.ZZFHYY : '';//分户原因
                mdgAcc.Global_Location_Number__c = String.isNotEmpty(customer.BBSNR) && String.isNotEmpty(customer.BBBNR) && String.isNotEmpty(customer.BUBKZ) ? customer.BBBNR + customer.BBSNR + customer.BUBKZ : '';//GLN码
                mdgAcc.E_commerce_Customer_Label__c = String.isNotEmpty(customer.ZZLINE) ? customer.ZZLINE : '';//线上/线下
                mdgAcc.Tax_Number1__c = String.isNotEmpty(customer.ZTAX_CODE1) ? customer.ZTAX_CODE1 : '';//税码1
                mdgAcc.Tax_Number1__c = String.isNotEmpty(customer.ZTAX_CODE2) ? customer.ZTAX_CODE2 : '';//税码2

                // 客户新增字段 （wfc 2025-02-08）
                mdgAcc.Search_Term2__c = String.isNotEmpty(customer.ZSORT2) ? customer.ZSORT2 : '';//搜索项2
                mdgAcc.Tax_Number3__c = String.isNotEmpty(customer.ZTAX_CODE3) ? customer.ZTAX_CODE3 : '';//税码3
                mdgAcc.Tax_Number4__c = String.isNotEmpty(customer.ZTAX_CODE4) ? customer.ZTAX_CODE4 : '';//税码4
                mdgAcc.Supplier__c = String.isNotEmpty(customer.ZLIFNR) ? customer.ZLIFNR : '';//供应商

                return mdgAcc;
            } else {
                return null;
            }
        } else {
            return null;
        }

    }
    
    @AuraEnabled
    public static List<Map<String, String>> getCountryList() {
        List<Map<String, String>> countryList = MDGCustomerUtils.getPicklistValues('Account', 'Guarantor_Country_Code__c');
        System.debug('countryList:');
        System.debug(countryList);
        return countryList;
    }

    @AuraEnabled
    public static List<Map<String, String>> getIdTypeList() {
        List<Map<String, String>> idTypeList = MDGCustomerUtils.getPicklistValues('Account', 'ID_Type__c');
        System.debug('idTypeList:');
        System.debug(idTypeList);
        return idTypeList;
    }

    @AuraEnabled
    public static String getRecordTypeDeveloperName(String recordTypeId){
        try {
            return MDGCustomerUtils.getRecordTypeDeveloperName(recordTypeId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Date stringToDate(String dateString){
        System.debug('dateString: ' + dateString);
        
        // 确保传入的字符串是有效的
        if (dateString == null || dateString.length() != 8) {
            System.debug('Invalid date string format');
            return null;
        }
    
        // 从字符串中提取年、月、日
        Integer year = Integer.valueOf(dateString.substring(0, 4));
        Integer month = Integer.valueOf(dateString.substring(4, 6));
        Integer day = Integer.valueOf(dateString.substring(6, 8));
    
        // 创建并返回 Date 对象
        Date parsedDate = Date.newInstance(year, month, day);
        System.debug('parsedDate: ' + parsedDate);
    
        return parsedDate;
    }

    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-01-24 10:39:57
     * @Description: 
     */    
    @AuraEnabled
    public static ConResponse getParentCustomerInfo(String parentCustomerOfSubAcc) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();

        // 查询客户的字段
        String accountSqlField = Label.MDGCustomerSqlField;
        // 查询客户拓展的公司视图字段
        String accountExtendCompanyViewField = Label.MDGCustomerExtendCompanyViewSqlField;
        // 查询客户拓展的销售视图字段
        String accountExtendSalesViewField = Label.MDGCustomerExtendSalesViewSqlField;

        // 查询客户信息的sql
        String accountSql = 'SELECT Id, ' + accountSqlField + ' FROM Account WHERE Id = :parentCustomerOfSubAcc LIMIT 1';
        // 查询客户拓展的公司视图的sql
        String accountExtendCompanyViewSql = 'SELECT ' + accountExtendCompanyViewField + ' FROM Customer_Extend__c WHERE Customer__c  = :parentCustomerOfSubAcc AND Show_Company__c = true'; 
        // 查询客户拓展的销售视图的sql
        String accountExtendSalesViewSql = 'SELECT ' + accountExtendSalesViewField + ' FROM Customer_Extend__c WHERE Customer__c  = :parentCustomerOfSubAcc AND Show_Sales__c = true';

        // 查询客户信息
        Account account = Database.query(accountSql);
        // 查询客户拓展的公司视图
        List<Customer_Extend__c> customerExtendCompanyViewList = Database.query(accountExtendCompanyViewSql);
        // 查询客户拓展的销售视图
        List<Customer_Extend__c> customerExtendSalesViewList = Database.query(accountExtendSalesViewSql);
        
        if(customerExtendCompanyViewList != null && customerExtendCompanyViewList.size() == 1){
            mso.put('CompanyView', customerExtendCompanyViewList[0]);
        }else {
            mso.put('CompanyView', null);
        }

        if(customerExtendSalesViewList != null && customerExtendSalesViewList.size() == 1){
            // 分户时，payer默认是主户
            Customer_Extend__c  customerExtend = customerExtendSalesViewList[0];
            customerExtend.Payer__c = parentCustomerOfSubAcc;
            mso.put('SalesView', customerExtendSalesViewList[0]);
        }else {
            mso.put('SalesView', null);
        }

        mso.put('Account', account );
        
        resp.data = mso;
        return resp;
    }
}