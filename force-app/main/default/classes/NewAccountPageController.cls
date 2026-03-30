/*
 * @Author: WFC
 * @Date: 2025-04-24 17:49:29
 * @LastEditors: WFC
 * @LastEditTime: 2025-10-20 16:27:23
 * @Description: 客户新页面
 * @FilePath: \testuat\force-app\main\default\classes\NewAccountPageController.cls
 */
public without sharing class NewAccountPageController{
    public static List<SObject> updateSObjectList = new List<SObject>();
    public static List<String> deleteIdList = new List<String>();
    /**
     * @Param: recordId：客户id
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-25 11:01:29
     * @Description: 公司视图
     */
    @AuraEnabled
    public static Map<String, Object> getCustomerExtendForCompany(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        Map<String, String> hisenseEntityMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c');
        Map<String, String> reconciliationCustomerMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Reconciliation_Customer__c');
        Map<String, String> paymentMethodMDGMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Payment_Method_MDG__c');
        List<CustomerExtendData> companyViewData = new List<CustomerExtendData>();

        List<Customer_Extend__c> companyViewList = [SELECT Id, Name, Extend_or_Not__c, Hisense_Entity__c, Reconciliation_Customer__c, EDI_ID__c, Payment_Method_MDG__c, Stor_Location__c, Payment_Term__c, Payment_Term__r.Name
                                                    FROM Customer_Extend__c
                                                    WHERE Customer__c = :recordId AND Show_Company__c = true
                                                    ORDER BY CreatedDate];
        if (!companyViewList.isEmpty()){
            for (Customer_Extend__c ce : companyViewList){
                CustomerExtendData resultData = new CustomerExtendData();
                resultData.Id = ce.Id;
                resultData.Name = ce.Name;
                resultData.Extend_or_Not = ce.Extend_or_Not__c;
                resultData.Hisense_Entity_Api = ce.Hisense_Entity__c;
                resultData.Hisense_Entity = hisenseEntityMap.get(ce.Hisense_Entity__c);
                resultData.Reconciliation_Customer = reconciliationCustomerMap.get(ce.Reconciliation_Customer__c);
                resultData.EDI_ID = ce.EDI_ID__c;
                resultData.Payment_Method_MDG = paymentMethodMDGMap.get(ce.Payment_Method_MDG__c);
                resultData.Payment_Term = ce.Payment_Term__r.Name;
                resultData.Payment_Term_Url = ce.Payment_Term__c != null ? '/lightning/r/' + ce.Payment_Term__c + '/view' : '';
                resultData.Stor_Location = ce.Stor_Location__c;

                companyViewData.add(resultData);
            }
            result.put('companyViewData', JSON.serialize(companyViewData));
            result.put('isHaveCompanyView', true);
        } else{
            result.put('companyViewData', null);
            result.put('isHaveCompanyView', false);
        }
        return result;
    }

    /**
     * @Param: recordId：客户id
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-25 11:01:46
     * @Description: 销售视图
     */
    @AuraEnabled
    public static Map<String, Object> getCustomerExtendForSales(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        Map<String, String> hisenseEntitySalesMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity_Sales__c');
        Map<String, String> distributionChannelMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Distribution_Channel__c');
        List<CustomerExtendData> salesViewData = new List<CustomerExtendData>();

        List<Customer_Extend__c> salesViewList = [SELECT Id, Name, Extend_or_Not__c, Hisense_Entity_Sales__c, Distribution_Channel__c, Sales_Office__c, Sales_Office__r.Name, Sales_Office__r.Value__c, Sales_Group__c, Sales_Group__r.Name, (SELECT id, Tax_category__c
                                                                                                                                                                                                                                              FROM Customer_Extend_Tax_category__r)
                                                  FROM Customer_Extend__c 
                                                  WHERE Customer__c = :recordId AND Show_Sales__c = true
                                                  ORDER BY CreatedDate];
        if (!salesViewList.isEmpty()){
            for (Customer_Extend__c ce : salesViewList){
                CustomerExtendData resultData = new CustomerExtendData();
                resultData.Id = ce.Id;
                resultData.Name = ce.Name;
                resultData.Extend_or_Not = ce.Extend_or_Not__c;
                resultData.Hisense_Entity_Sales_Api = ce.Hisense_Entity_Sales__c;
                resultData.Hisense_Entity_Sales = hisenseEntitySalesMap.get(ce.Hisense_Entity_Sales__c);
                resultData.Distribution_Channel = distributionChannelMap.get(ce.Distribution_Channel__c);
                resultData.Sales_Office = ce.Sales_Office__r.Name;
                resultData.Sales_Office_Id = ce.Sales_Office__c;
                resultData.Sales_Office_Url = ce.Sales_Office__c != null ? '/lightning/r/' + ce.Sales_Office__c + '/view' : '';
                resultData.Sales_Office_Value = ce.Sales_Office__r.Value__c;
                resultData.Sales_Group = ce.Sales_Group__r.Name;
                resultData.Sales_Group_Id = ce.Sales_Group__c;
                resultData.Sales_Group_Url = ce.Sales_Group__c != null ? '/lightning/r/' + ce.Sales_Group__c + '/view' : '';
                resultData.iconName = 'utility:success';
                resultData.buttonVariante = 'success';
                // 税信息
                if (!ce.Customer_Extend_Tax_category__r.isEmpty() && ce.Customer_Extend_Tax_category__r != null){
                    for (Customer_Extend_Tax_category__c tax : ce.Customer_Extend_Tax_category__r){
                        if (tax.Tax_category__c == null){
                            resultData.iconName = 'utility:error';
                            resultData.buttonVariante = 'destructive';
                            break;
                        }
                    }
                } else{
                    resultData.iconName = 'utility:error';
                    resultData.buttonVariante = 'destructive';
                }

                salesViewData.add(resultData);
            }
            result.put('salesViewData', JSON.serialize(salesViewData));
            result.put('isHaveSalesView', true);
        } else{
            result.put('salesViewData', null);
            result.put('isHaveSalesView', false);
        }
        return result;
    }

    /**
     * @Param: recordId：客户id
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-25 11:01:49
     * @Description: 银行信息
     */
    @AuraEnabled
    public static Map<String, Object> getCustomerBanks(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        Map<String, String> bankCountryMap = Utility.getPicklistValueMap('Customer_Banks__c', 'Bank_Country__c');
        List<CustomerBanksData> customerBanksData = new List<CustomerBanksData>();

        List<Customer_Banks__c> customerBanksList = [SELECT Id, Name, Extend_or_Not__c, Bank_Code__c, Bank_Account__c, Bank_name_local_language__c, Bank_Country__c, Bank_Control_Code__c, Reference_Detail__c, Swift_Code__c, MDG_BANK__c
                                                     FROM Customer_Banks__c
                                                     WHERE Customer__c = :recordId
                                                     ORDER BY CreatedDate];
        if (!customerBanksList.isEmpty()){
            for (Customer_Banks__c cb : customerBanksList){
                CustomerBanksData resultData = new CustomerBanksData();
                resultData.Id = cb.Id;
                resultData.Name = cb.Name;
                resultData.Extend_or_Not = cb.Extend_or_Not__c;
                resultData.Bank_Code = cb.Bank_Code__c;
                resultData.Bank_Account = cb.Bank_Account__c;
                resultData.Bank_name_local_language = cb.Bank_name_local_language__c;
                resultData.Bank_Country_Api = cb.Bank_Country__c;
                resultData.Bank_Country = bankCountryMap.get(cb.Bank_Country__c);
                resultData.Bank_Control_Code = cb.Bank_Control_Code__c;
                resultData.Reference_Detail = cb.Reference_Detail__c;
                resultData.Swift_Code = cb.Swift_Code__c;
                resultData.MDG_BANK = cb.MDG_BANK__c;

                customerBanksData.add(resultData);
            }
            result.put('customerBanksData', JSON.serialize(customerBanksData));
        } else{
            result.put('customerBanksData', null);
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-14 09:34:41
     * @Description: 查询客户下的客户产品线信息
     */
    @AuraEnabled
    public static Map<String, Object> getCustomerProductLine(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        // Score_Sheet__c 表的record type
        Map<String, String> scoreSheetRdTypeMap = Utility.getRecordTypeMapBySobj('Score_Sheet__c');
        List<CustomerProductLineData> CustomerProductLineData = new List<CustomerProductLineData>();
        // 查询客户产品线表
        List<Customer_Product_Line__c> customerProductList = [SELECT Id, Name, Classification__c, Product_Line_Name__c, Development_Stage__c
                                                              FROM Customer_Product_Line__c
                                                              WHERE Customer__c = :recordId
                                                              ORDER BY CreatedDate];
        // 查询打分表
        List<Score_Sheet__c> scoreSheetList = [SELECT Id, Product_Line__c, Evaluated_Score__c
                                               FROM Score_Sheet__c
                                               WHERE Customer__c = :recordId];
        LisqContainer lcScoreSheet = new LisqContainer(scoreSheetList);
        // 根据产品线分组
        Map<String, SObject> scoreSheetMap = lcScoreSheet.ToMapS('Product_Line__c');

        if (!customerProductList.isEmpty()){
            for (Customer_Product_Line__c cpl : customerProductList){
                CustomerProductLineData resultData = new CustomerProductLineData();
                resultData.Id = cpl.Id;
                resultData.Name = cpl.Name;
                resultData.Classification = cpl.Classification__c;
                resultData.Product_Line_Name = cpl.Product_Line_Name__c;
                resultData.Development_Stage = cpl.Development_Stage__c;
                // 产品线 Classification__c 对应的打分表 Record Type
                if ('Agency Customer' == cpl.Classification__c){
                    resultData.recordTypeId = scoreSheetRdTypeMap.get('New_Brand_Customer_selection_and_evaluation_criteria');
                } else if ('OEM Customer' == cpl.Classification__c){
                    resultData.recordTypeId = scoreSheetRdTypeMap.get('New_OEM_Customer_selection_and_evaluation_criteria');
                } else if ('Customer of Oversea Company' == cpl.Classification__c){
                    resultData.recordTypeId = scoreSheetRdTypeMap.get('Customer_selection_and_evaluation_criteria');
                } else{
                    resultData.recordTypeId = scoreSheetRdTypeMap.get('New_Brand_Customer_selection_and_evaluation_criteria');
                }
                // 查询是否存在打分表
                if (scoreSheetMap.get(cpl.Product_Line_Name__c) != null){
                    resultData.buttonVariante = 'success';
                    Score_Sheet__c sheet = (Score_Sheet__c) scoreSheetMap.get(cpl.Product_Line_Name__c);
                    resultData.scoreSheet = sheet;
                    resultData.evaluatedScore = sheet.Evaluated_Score__c;

                } else{
                    resultData.buttonVariante = 'destructive';
                }

                CustomerProductLineData.add(resultData);
            }
            result.put('customerProductLineData', JSON.serialize(customerProductLineData));
        } else{
            result.put('customerProductLineData', null);
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-28 17:32:43
     * @Description: 删除数据
     */
    @AuraEnabled
    public static Boolean deleteRecord(String recordId){
        Database.delete (recordId);
        return true;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-27 16:43:03
     * @Description: 保存公司视图
     */
    @AuraEnabled
    public static ConResponse saveCompanySalesView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Customer_Extend__c customerExtend = (Customer_Extend__c) JSON.deserialize(viewRecord, Customer_Extend__c.class);
            Database.UpsertResult result = Database.upsert (customerExtend, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }

            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-29 16:25:54
     * @Description: 保存银行信息
     */
    @AuraEnabled
    public static ConResponse saveBankView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Customer_Banks__c customerBanks = (Customer_Banks__c) JSON.deserialize(viewRecord, Customer_Banks__c.class);
            Database.UpsertResult result = Database.upsert (customerBanks, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }
            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }
        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: LZX
     * @Date: 2025-07-30 16:43:03
     * @Description: 保存客户管理名称
     */
    @AuraEnabled
    public static ConResponse saveCustomerManagementNameView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Customer_Management__c cm = (Customer_Management__c) JSON.deserialize(viewRecord, Customer_Management__c.class);
            Database.UpsertResult result = Database.upsert (cm, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }
            mso.put('CustomerManagementNameId', cm.Id);
            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-14 09:58:41
     * @Description: 保存客户产品线
     */
    @AuraEnabled
    public static ConResponse saveProductLineView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Customer_Product_Line__c customerProductLine = (Customer_Product_Line__c) JSON.deserialize(viewRecord, Customer_Product_Line__c.class);
            Database.UpsertResult result = Database.upsert (customerProductLine, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }
            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-14 17:27:41
     * @Description: 保存打分表
     */
    @AuraEnabled
    public static ConResponse saveScoreSheetView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Score_Sheet__c scoreSheet = (Score_Sheet__c) JSON.deserialize(viewRecord, Score_Sheet__c.class);
            Database.UpsertResult result = Database.upsert (scoreSheet, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }
            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-04-29 16:26:14
     * @Description: 保存客户主信息
     */
    @AuraEnabled
    public static ConResponse saveAccountView(String viewRecord){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Account account = (Account)JSON.deserialize(viewRecord, Account.class);
            Database.UpsertResult result = Database.upsert (account, true);
            String errorMessage = '';
            if (!result.isSuccess()){
                // Operation failed, so get all errors
                for (Database.Error err : result.getErrors()){
                    errorMessage = errorMessage + err.getMessage();
                }
            }

            resp.message = errorMessage;
            mso.put('account', account);
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-06 14:04:45
     * @Description: 查询客户主信息
     */
    @AuraEnabled
    public static Account getAccountData(String recordId){
        return [SELECT Id, Name, Sold_to__c, Guarantor_Country_Code__c, Province_State__c, City_CN__c, District_CN__c, Township_CN__c, Email_Multiple__c, Approval_Status__c, Current_Modifier__c, Current_Modifier__r.Name, Current_Modifier__r.Email, RecordTypeId, RecordType.DeveloperName, ParentCustomerOfSubAcc__c, Latest_Version__c, Marketing_Model__c, Company_Registration_Number__c,Unified_Customer_Group__c
                FROM Account
                WHERE Id = :recordId
                LIMIT 1];
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT Id, Name, Profile.Name, Sales_Region__c, UserRole.DeveloperName
                FROM User
                WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Customer_Extend__c getCurrency(String customerId, String hisenseEntitySales){
        return [SELECT CurrencyIsoCode
                FROM Customer_Extend__c
                WHERE Customer__c = :customerId and Hisense_Entity_Sales__c = :hisenseEntitySales];
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-23 17:20:54
     * @Description: 查询客户类型名称
     */
    @AuraEnabled
    public static RecordType getAccountRecordType(String recordTypeId){
        return [SELECT Id, DeveloperName
                FROM RecordType
                WHERE Id = :recordTypeId
                LIMIT 1];
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-06 14:04:57
     * @Description: 查询销售视图对应的tax税信息
     */
    @AuraEnabled
    public static List<Customer_Extend_Tax_category__c> getTaxInfoBySalesId(String customerExtendId){
        return [SELECT Id, Name, CountryCodeAndCustomerIdF__c, Tax_category_code__c, Tax_category__c, National_tax_category__c, National_tax_category__r.Name
                FROM Customer_Extend_Tax_category__c
                WHERE Customer_Extend__c = :customerExtendId
                ORDER BY sortF__c];
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-06 16:25:01
     * @Description: 保存税信息
     */
    @AuraEnabled
    public static ConResponse saveTaxCategoryView(String taxCategoryList){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            List<Customer_Extend_Tax_category__c> taxList = (List<Customer_Extend_Tax_category__c>)JSON.deserialize(taxCategoryList, List<Customer_Extend_Tax_category__c>.class);
            List<Database.UpsertResult> result = Database.upsert (taxList, true);
            String errorMessage = '';
            for (Database.UpsertResult res : result){
                if (!res.isSuccess()){
                    // Operation failed, so get all errors
                    for (Database.Error err : res.getErrors()){
                        errorMessage = errorMessage + err.getMessage();
                    }
                }
            }
            resp.message = errorMessage;
        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage();
        }

        resp.data = mso;
        return resp;
    }

     /**
     * @Param:
     * @Return:
     * @Author: LZX
     * @Date: 2025-011-11
     * @Description: 查询是否已经进行信用申请
     */
    @AuraEnabled
    public static ConResponse checkCreditApplicationLimit(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        // 查询信用申请
        List<Credit_Limit_Application__c> claList = [SELECT id FROM Credit_Limit_Application__c WHERE Customer__c =:recordId];
        if(claList != null && claList.size() > 0){
            resp.code = 0;
        }else{
            resp.code = -1;
        }
        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-19 17:11:37
     * @Description: 撤销更改
     */
    @AuraEnabled
    public static ConResponse undoChangesView(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        updateSObjectList = new List<SObject>();
        deleteIdList = new List<String>();

        // 查询当前客户最新version值
        // 查询客户主信息
        List<Account> accountList = CustomerHistoryQueueable.getAccountById(recordId);
        Account account = accountList[0];
        // 查询历史表获取客户所有相关数据
        List<Customer_History__c> customerHistoryList = [SELECT Id, Object_Name__c, Record_Id__c, Record_Body__c
                                                         FROM Customer_History__c
                                                         WHERE Latest_Version__c = :account.Latest_Version__c];
        Map<String, SObject> customerHistoryMap = new LisqContainer(customerHistoryList).ToMapS('Record_Id__c');
        // 查询当前客户下所有相关数据
        // 查询公司视图信息
        List<Customer_Extend__c> companyList = CustomerHistoryQueueable.getCompanyByAccountId(recordId);
        // 查询销售视图信息
        List<Customer_Extend__c> salesList = CustomerHistoryQueueable.getSalesByAccountId(recordId);
        // 查询销售视图的税信息
        List<Customer_Extend_Tax_category__c> taxList = CustomerHistoryQueueable.getTaxByAccountId(recordId);
        // 查询银行信息
        List<Customer_Banks__c> banksList = CustomerHistoryQueueable.getBanksByAccountId(recordId);
        // 比较内容
        compareData(accountList, customerHistoryMap);
        compareData(companyList, customerHistoryMap);
        compareData(taxList, customerHistoryMap);
        compareData(salesList, customerHistoryMap);
        compareData(banksList, customerHistoryMap);
        // // 重构客户信息
        // if (customerHistoryMap.get(account.Id) != null){
        //     SObject accountHistory = (SObject) Type.forName('Account').newInstance();
        //     Customer_History__c customerHistory = (Customer_History__c)customerHistoryMap.get(account.Id);
        //     Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(account, false));
        //     accountHistory.put('Id', account.Id);
        //     for (String key : updateMap.keySet()){
        //         System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
        //         Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
        //         accountHistory.put(key, tempMap.get('json1'));
        //     }
        //     updateSObjectList.add(accountHistory);
        // }
        // // 公司视图
        // for (Customer_Extend__c ce : companyList){
        //     // 判断公司视图是否存在历史记录
        //     if (customerHistoryMap.get(ce.Id) != null){
        //         SObject companyHistory = (SObject) Type.forName('Customer_Extend__c').newInstance();
        //         Customer_History__c customerHistory = (Customer_History__c)customerHistoryMap.get(ce.Id);
        //         Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(ce, false));
        //         companyHistory.put('Id', ce.Id);
        //         for (String key : updateMap.keySet()){
        //             System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
        //             Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
        //             companyHistory.put(key, tempMap.get('json1'));
        //         }
        //         updateSObjectList.add(companyHistory);
        //     } else{
        //         // 删除当前公司视图
        //         deleteIdList.add(ce.Id);
        //     }
        // }
        // // 销售视图
        // for (Customer_Extend__c ce : salesList){
        //     // 判断公司视图是否存在历史记录
        //     if (customerHistoryMap.get(ce.Id) != null){
        //         SObject salesHistory = (SObject) Type.forName('Customer_Extend__c').newInstance();
        //         Customer_History__c customerHistory = (Customer_History__c)customerHistoryMap.get(ce.Id);
        //         Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(ce, false));
        //         salesHistory.put('Id', ce.Id);
        //         for (String key : updateMap.keySet()){
        //             System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
        //             Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
        //             salesHistory.put(key, tempMap.get('json1'));
        //         }
        //         updateSObjectList.add(salesHistory);
        //     } else{
        //         // 删除当前数据
        //         deleteIdList.add(ce.Id);
        //     }
        // }
        // // 银行信息
        // for (Customer_Banks__c cb : banksList){
        //     // 判断公司视图是否存在历史记录
        //     if (customerHistoryMap.get(cb.Id) != null){
        //         SObject banksHistory = (SObject) Type.forName('Customer_Banks__c').newInstance();
        //         Customer_History__c customerHistory = (Customer_History__c)customerHistoryMap.get(cb.Id);
        //         Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(cb, false));
        //         banksHistory.put('Id', cb.Id);
        //         for (String key : updateMap.keySet()){
        //             System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
        //             Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
        //             banksHistory.put(key, tempMap.get('json1'));
        //         }
        //         updateSObjectList.add(banksHistory);
        //     } else{
        //         // 删除当前数据
        //         deleteIdList.add(cb.Id);
        //     }
        // }
        // // 税信息
        // for (Customer_Extend_Tax_category__c tax : taxList){
        //     // 判断公司视图是否存在历史记录
        //     if (customerHistoryMap.get(tax.Id) != null){
        //         SObject taxHistory = (SObject) Type.forName('Customer_Extend_Tax_category__c').newInstance();
        //         Customer_History__c customerHistory = (Customer_History__c)customerHistoryMap.get(tax.Id);
        //         Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(tax, false));
        //         taxHistory.put('Id', tax.Id);
        //         for (String key : updateMap.keySet()){
        //             System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
        //             Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
        //             taxHistory.put(key, tempMap.get('json1'));
        //         }
        //         updateSObjectList.add(taxHistory);
        //     } else{
        //         // 删除当前数据
        //         deleteIdList.add(tax.Id);
        //     }
        // }

        try{
            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'undoChangesView');
            Database.update (updateSObjectList);
            Database.delete (deleteIdList);
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');

        } catch (Exception e){
            resp.code = -1;
            resp.message = e.getMessage();
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');
        }
        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-19 17:11:32
     * @Description: 比较数据不同
     */
    public static void compareData(List<Object> dataList, Map<String, SObject> customerHistoryMap){
        for (Object ob : dataList){
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ob));
            Id cid = (Id) objMap.get('Id');
            String objectName = cid.getSObjectType().getDescribe().getName();
            // 判断公司视图是否存在历史记录
            if (customerHistoryMap.get(String.valueOf(objMap.get('Id'))) != null){
                SObject companyHistory = (SObject) Type.forName(objectName).newInstance();
                Customer_History__c customerHistory = (Customer_History__c) customerHistoryMap.get(String.valueOf(objMap.get('Id')));
                Map<String, Object> updateMap = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(ob, false));
                companyHistory.put('Id', cid);
                for (String key : updateMap.keySet()){
                    System.debug('wwwwww-----' + key + '------------' + updateMap.get(key));
                    Map<String, Object> tempMap = (Map<String, Object>)updateMap.get(key);
                    companyHistory.put(key, tempMap.get('json1'));
                }
                updateSObjectList.add(companyHistory);
            } else{
                // 删除当前公司视图
                deleteIdList.add(cid);
            }
        }
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-26 10:21:52
     * @Description: 分户根据主户信息查询信贷管理
     */
    @AuraEnabled
    public static ConResponse checkSubAccountCreditManagement(String parentCustomerId, String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('isHaveCreditManagement', false);
        mso.put('creditManagement', '');

        if (String.isNotBlank(recordId)){
            // 查询当前数据
            Account acc = [SELECT Credit_Management__c
                           FROM Account
                           WHERE Id = :recordId];
            if (acc.Credit_Management__c != null){
                mso.put('isHaveCreditManagement', true);
                mso.put('creditManagement', acc.Credit_Management__c);
                resp.data = mso;
                return resp;
            }
        }
        List<Account> subAccountList = [SELECT Id, Credit_Management__c
                                        FROM Account
                                        WHERE ParentCustomerOfSubAcc__c = :parentCustomerId AND Id != :recordId AND RecordType.DeveloperName = 'Sub_Account' AND Credit_Management__c != NULL];
        if (subAccountList != null && subAccountList.size() > 0){
            mso.put('isHaveCreditManagement', true);
            for (Account account : subAccountList){
                mso.put('creditManagement', account.Credit_Management__c);
            }
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-26 10:50:30
     * @Description: 地址类客户同步SAP
     */
    @AuraEnabled
    public static String handleSyncToSAP(String recordId){
        String result = SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(recordId);
        // String jobID = System.enqueueJob(new AccountTriggerHandler.AsyncSyncEcssCustomer(recordId));
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-28 10:34:44
     * @Description:
     */
    @AuraEnabled
    public static ConResponse handleVerification(String countryCode, String registrationNumber, String recordTypeId, String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        system.debug('wwww---country:' + countryCode);
        system.debug('wwww---registrationNumber:' + registrationNumber);
        // 本地查重
        List<Account> accounts = [SELECT Id, Name, MDG_Customer_Code__c
                                  FROM Account
                                  WHERE Guarantor_Country_Code__c = :countryCode AND Company_Registration_Number__c = :registrationNumber AND Id != :recordId
                                  LIMIT 1];
        if (accounts != null && accounts.size() > 0){
            // 本地已存在客户
            mso.put('isHaveLocalAccount', true);
            mso.put('account', accounts[0]);
        } else{
            // 查询接口客户信息是否存在
            // 获取对应RecordType的DeveloperName
            String recordTypeName = Schema.SobjectType.Account.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            String traderType = '';
            // 根据DeveloperName获取MDG客商类型代码
            if (!Test.isRunningTest()){
                traderType = [SELECT DeveloperName, MDG_SFDC_Name__c, MDG_Code__c, MDG_Sub_Code__c
                              FROM MDG_Client_Mapping__mdt
                              WHERE MDG_SFDC_Name__c = :recordTypeName].MDG_Code__c;
            } else{
                traderType = 'H002';
            }
            system.debug('wwww---traderType:' + traderType);
            GetCustomerInfoFromMDG.CustomerInfo customer = GetCustomerInfoFromMDG.getCustomerInformationFromMDG(countryCode, traderType, registrationNumber);
            if (customer != null && String.isNotEmpty(customer.PARTNER)){
                Account mdgAcc = new Account();
                mdgAcc.Customer_Name_Local_Language__c = String.isNotEmpty(customer.NAME_ORG1) ? customer.NAME_ORG1 : '';//Customer Name
                if (!customer.PARTNER.startsWith('A') && !customer.PARTNER.startsWith('E')){
                    mdgAcc.SAP_Customer_Code__c = '00' + customer.PARTNER;
                    mdgAcc.MDG_Customer_Code__c = '00' + customer.PARTNER;
                } else{
                    mdgAcc.SAP_Customer_Code__c = customer.PARTNER;
                    mdgAcc.MDG_Customer_Code__c = customer.PARTNER;
                }
                mso.put('isHaveMDGAccount', true);
                mso.put('account', mdgAcc);
                mso.put('accountJson', JSON.serialize(customer));
            } else{
                mso.put('isHaveAccount', false);
            }
        }
        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-29 14:03:24
     * @Description: 同步MDG客户数据
     */
    @AuraEnabled
    public static ConResponse syncMDGAccount(String accountFromMdgJson, String recordTypeId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();

        System.debug('wwwww------' + accountFromMdgJson);
        System.debug('wwwww------' + recordTypeId);
        // json转换
        GetCustomerInfoFromMDG.CustomerInfo customer = (GetCustomerInfoFromMDG.CustomerInfo)JSON.deserialize(accountFromMdgJson, GetCustomerInfoFromMDG.CustomerInfo.class);
        // 客户主数据
        Account mdgAcc = new Account();
        // 根据客商类型，不同的客户类型
        Map<String, String> accountRdTypeMap = Utility.getRecordTypeMapBySobj('Account');
        if ('H002' == customer.BU_GROUP){
            mdgAcc.recordTypeId = accountRdTypeMap.get('customer');
        } else if ('H006' == customer.BU_GROUP && '18' == customer.ZZMXLX){
            mdgAcc.recordTypeId = accountRdTypeMap.get('Sub_Account');
        } else if ('H006' == customer.BU_GROUP && '15' == customer.ZZMXLX){
            mdgAcc.recordTypeId = accountRdTypeMap.get('Hisense_International_Custoemr_Unconventional');
        } else{
            mdgAcc.recordTypeId = recordTypeId;
        }
        mdgAcc.Approval_Status__c = 'Approved';
        mdgAcc.CustomerDetailType__c = String.isNotEmpty(customer.ZZMXLX) ? customer.ZZMXLX : '';

        mdgAcc.Name = String.isNotEmpty(customer.NAME_ORG1) ? customer.NAME_ORG1 : '';
        mdgAcc.Customer_Name_Local_Language__c = String.isNotEmpty(customer.NAME_ORG1) ? customer.NAME_ORG1 : '';//Customer Name
        mdgAcc.Customer_Name_Local_Language_2__c = String.isNotEmpty(customer.NAME_ORG2) ? customer.NAME_ORG2 : '';//Customer Name 2
        mdgAcc.Customer_Name_1__c = String.isNotEmpty(customer.NAME_ORG3) ? customer.NAME_ORG3 : '';//Customer Name 3
        mdgAcc.Customer_Name_2__c = String.isNotEmpty(customer.NAME_ORG4) ? customer.NAME_ORG4 : '';//Customer Name 4
        // 非A和E开头的客商编码,MDG客商编码前2位0补位 2024/12/2 18:00 start
        // MDG可以同时接收补位和不补位的客商编码
        if (!customer.PARTNER.startsWith('A') && !customer.PARTNER.startsWith('E')){
            mdgAcc.SAP_Customer_Code__c = '00' + customer.PARTNER;
            mdgAcc.MDG_Customer_Code__c = '00' + customer.PARTNER;
        } else{
            mdgAcc.SAP_Customer_Code__c = customer.PARTNER;
            mdgAcc.MDG_Customer_Code__c = customer.PARTNER;
        }
        // mdgAcc.Customer_Name_Local_Language__c = String.isNotEmpty(customer.NAME_EN) ? customer.NAME_EN : '';
        mdgAcc.Customer_Short_Name__c = customer.BU_SORT1;//简称
        mdgAcc.FormerName__c = String.isNotEmpty(customer.ZZFONM) ? customer.ZZFONM : '';//曾用名
        mdgAcc.ID_Type__c = String.isNotEmpty(customer.ZZZJLX) ? customer.ZZZJLX : '';//证件类型
        mdgAcc.Company_Registration_Number__c = customer.ZZRENO;//注册码
        mdgAcc.VAT_Registration_Number__c = String.isNotEmpty(customer.ZZVAT) ? customer.ZZVAT : '';//VAT编号
        mdgAcc.DUNS_Number__c = String.isNotEmpty(customer.ZZDUNS) ? customer.ZZDUNS : '';//DUNS编号
        // mdgAcc.License_Expiration_Date__c = customer.ZZBLED != null ? CustomerDupliCheckController.stringToDate(customer.ZZBLED) : null;//营业执照到日期
        // mdgAcc.Registration_Date__c = customer.FOUND_DAT != null ? CustomerDupliCheckController.stringToDate(customer.FOUND_DAT) : null;//注册日期
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
        mdgAcc.Email_Multiple__c = String.isNotEmpty(customer.SMTP_ADDR) ? customer.SMTP_ADDR : '';//邮箱
        mdgAcc.Fax = String.isNotEmpty(customer.FAX_NUMBER) ? customer.FAX_NUMBER : '';//传真
        mdgAcc.Phone = String.isNotEmpty(customer.TEL_NUMBER) ? customer.TEL_NUMBER : '';//电话
        mdgAcc.Industry_Sector__c = customer.IND_SECTOR;//行业(国标二级)
        //ZZJTKHMC//集团客户名称
        if (String.isNotEmpty(customer.ZZCVCO)){
            List<Account> belongAcc = [SELECT Id, Name
                                       FROM Account
                                       WHERE SAP_Customer_Code__c = :customer.ZZCVCO];
            if (belongAcc != null && belongAcc.size() > 0){
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
        mdgAcc.Overseas_customer_level__c = String.isNotEmpty(customer.ZZHWKHFJ) ? customer.ZZHWKHFJ : ''; //海外客户分级
        mdgAcc.Sub_account_type__c = String.isNotEmpty(customer.ZZFHLX) ? customer.ZZFHLX : '';//分户类型
        mdgAcc.Reasons_for_customer_segmentation__c = String.isNotEmpty(customer.ZZFHYY) ? customer.ZZFHYY : '';//分户原因
        mdgAcc.Global_Location_Number__c = String.isNotEmpty(customer.BBSNR) && String.isNotEmpty(customer.BBBNR) && String.isNotEmpty(customer.BUBKZ) ? customer.BBBNR + customer.BBSNR + customer.BUBKZ : '';//GLN码
        mdgAcc.E_commerce_Customer_Label__c = String.isNotEmpty(customer.ZZLINE) ? customer.ZZLINE : '';//线上/线下
        mdgAcc.Tax_Number1__c = String.isNotEmpty(customer.ZTAX_CODE1) ? customer.ZTAX_CODE1 : '';//税码1
        mdgAcc.Tax_Number2__c = String.isNotEmpty(customer.ZTAX_CODE2) ? customer.ZTAX_CODE2 : '';//税码2
        // 客户新增字段 （wfc 2025-02-08）
        mdgAcc.Search_Term2__c = String.isNotEmpty(customer.ZSORT2) ? customer.ZSORT2 : '';//搜索项2
        mdgAcc.Tax_Number3__c = String.isNotEmpty(customer.ZTAX_CODE3) ? customer.ZTAX_CODE3 : '';//税码3
        mdgAcc.Tax_Number4__c = String.isNotEmpty(customer.ZTAX_CODE4) ? customer.ZTAX_CODE4 : '';//税码4
        mdgAcc.Supplier__c = String.isNotEmpty(customer.ZLIFNR) ? customer.ZLIFNR : '';//供应商
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
                                                     WHERE Name__c IN:countryStateNameSet]){
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
        // 保存客户主数据
        // 事务开始
        System.Savepoint sp = Database.setSavepoint();
        try{
            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'syncMDGAccount');
            // 保存客户数据
            Database.insert (mdgAcc);
            mso.put('Account', mdgAcc);
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');

            List<Customer_Extend__c> addCustomerExtendList = new List<Customer_Extend__c>();
            List<Customer_Banks__c> addCustomerBanksList = new List<Customer_Banks__c>();
            // 公司视图
            List<GetCustomerInfoFromMDG.CompanyView> companyList = customer.COMPANY;
            if (companyList != null && companyList.size() > 0){
                for (GetCustomerInfoFromMDG.CompanyView companyView : companyList){
                    if (!'810'.equals(companyView.CLIENT)){
                        continue;
                    }
                    Customer_Extend__c company = new Customer_Extend__c();
                    company.Customer__c = mdgAcc.Id;
                    company.Extend_or_Not__c = true;
                    company.Show_Company__c = true;
                    company.Show_Sales__c = false;
                    company.Approval_Status__c = 'Approved';
                    company.Create_View__c = '1';


                    if (companyView.BUKRS != null && String.isNotBlank(Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c').get(companyView.BUKRS))){
                        company.Hisense_Entity__c = companyView.BUKRS != null ? companyView.BUKRS : '';
                        company.Reconciliation_Customer__c = companyView.AKONT != null ? companyView.AKONT : '';
                        company.Account_Remarks__c = companyView.KVERM != null ? companyView.KVERM : '';
                        company.Company_View_Freeze_markers__c = companyView.NODEL != null ? true : false;
                        // company.Payment_Method_MDG__c = companyView.ZWELS != null ? companyView.ZWELS : ''; // 只有首个字母对应不上
                        company.Delete_identification_for_company_region__c = companyView.LOEVM != null ? Boolean.valueOf(companyView.LOEVM) : false;
                        company.EDI_ID__c = companyView.ZZSORT1 != null ? companyView.ZZSORT1 : '';
                        company.EDI_ID2__c = companyView.ZZSORT2 != null ? companyView.ZZSORT2 : '';
                        company.Customer_EDI_ID_Type__c = companyView.EDI_TYPE != null ? companyView.EDI_TYPE : '';
                        company.TV_lisense__c = companyView.ZTV != null ? companyView.ZTV : '';
                        company.Packing_Type__c = companyView.PACKAGING_TYPE != null ? companyView.PACKAGING_TYPE : '';
                        company.Add_VAT_Reg_No__c = companyView.ZZSH != null ? companyView.ZZSH : '';
                        company.VAT_Tax_type__c = companyView.ZKHFL != null ? companyView.ZKHFL : '';
                        company.ExternalID__c = mdgAcc.Id + '-' + mdgAcc.Hisense_Entity__c + '-' + '' + '-' + '';
                        if (companyView.ZVALID_TO != null){
                            String dataString = companyView.ZVALID_TO;
                            company.Valid_to__c = Date.newInstance(Integer.valueOf(dataString.substring(0, 4)), Integer.valueOf(dataString.substring(4, 6)), Integer.valueOf(dataString.substring(6, 8)));
                        }
                        if (companyView.ZTERM != null){
                            List<Payment_Term__c> paymentList = [SELECT Id
                                                                 FROM Payment_Term__c
                                                                 WHERE Name = :companyView.ZTERM];
                            if (paymentList != null && paymentList.size() > 0){
                                company.Payment_Term__c = paymentList[0].Id;
                            }
                        }
                        if (companyView.ZZLGORT != null){
                            List<PickList__c> locationList = [SELECT Id
                                                              FROM PickList__c
                                                              WHERE belong_to_Loc__c = :company.Hisense_Entity__c AND RecordType.DeveloperName = 'Master_Location'];
                            if (locationList != null && locationList.size() > 0){
                                company.Stor_Location__c = locationList[0].Id;
                            }
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
                    if (!'810'.equals(salesView.CLIENT)){
                        continue;
                    }
                    Customer_Extend__c sales = new Customer_Extend__c();
                    sales.Customer__c = mdgAcc.Id;
                    sales.Extend_or_Not__c = true;
                    sales.Show_Company__c = false;
                    sales.Show_Sales__c = true;
                    sales.Approval_Status__c = 'Approved';
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
                        sales.Related_to_POD__c = salesView.PODKZ != null ? Boolean.valueOf(salesView.PODKZ) : false;
                        sales.Delete_identification_for_company_region__c = salesView.LOEVM != null ? Boolean.valueOf(salesView.LOEVM) : false;
                        sales.Customer_Group2__c = salesView.KVGR2 != null ? salesView.KVGR2 : '';
                        sales.Account_Assignment_Group__c = salesView.KTGRD != null ? salesView.KTGRD : '';
                        sales.Price_Group__c = salesView.KONDA != null ? salesView.KONDA : '';
                        sales.KDGRP__c = salesView.KDGRP != null ? salesView.KDGRP : '';
                        sales.Customer_pricing_process__c = salesView.KALKS != null ? salesView.KALKS : '';
                        sales.International_Trade_Terms_2__c = salesView.INCO2_L != null ? salesView.INCO2_L : '';
                        sales.International_Trade_Terms__c = salesView.INCO1 != null ? salesView.INCO1 : '';
                        sales.Sales_View_Freeze_markers__c = salesView.AUFSD != null ? true : false;
                        sales.ExternalID__c = mdgAcc.Id + '-' + '' + '-' + sales.Hisense_Entity_Sales__c + '-' + sales.Distribution_Channel__c;

                        if (salesView.ZTERM != null){
                            List<Payment_Term__c> paymentList = [SELECT Id
                                                                 FROM Payment_Term__c
                                                                 WHERE Name = :salesView.ZTERM];
                            if (paymentList != null && paymentList.size() > 0){
                                sales.Payment_Term_Sales__c = paymentList[0].Id;
                            }
                        }
                        // 销售部门 Sales Office
                        if (salesView.VKBUR != null){
                            List<PickList__c> officePickList = [SELECT Id
                                                                FROM PickList__c
                                                                WHERE Value__c = :salesView.VKBUR AND RecordType.DeveloperName = 'Master_Data_Office' AND belong_to_he__c = :sales.Hisense_Entity_Sales__c];
                            if (officePickList != null && officePickList.size() > 0){
                                sales.Sales_Office__c = officePickList[0].Id;
                            }
                            // 销售组 Sales Group
                            if (salesView.VKGRP != null){
                                List<PickList__c> groupPickList = [SELECT Id
                                                                   FROM PickList__c
                                                                   WHERE Value__c = :salesView.VKGRP AND RecordType.DeveloperName = 'Master_Data_Team' AND belong_to_office__c = :salesView.VKBUR];
                                if (groupPickList != null && groupPickList.size() > 0){
                                    sales.Sales_Office__c = groupPickList[0].Id;
                                }
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

            // 银行信息
            List<GetCustomerInfoFromMDG.BankDetail> bankList = customer.BANKDETAIL;
            if (bankList != null && bankList.size() > 0){
                for (GetCustomerInfoFromMDG.BankDetail bankDetail : bankList){
                    Customer_Banks__c bank = new Customer_Banks__c();
                    bank.Customer__c = mdgAcc.Id;
                    bank.Bank_name_local_language__c = bankDetail.ACCNAME != null ? bankDetail.ACCNAME : '';
                    bank.Bank_Account__c = bankDetail.BANKN != null ? bankDetail.BANKN : '';
                    bank.Bank_Code__c = bankDetail.BANKL != null ? bankDetail.BANKL : '';
                    bank.Bank_Country__c = bankDetail.BANKS != null ? bankDetail.BANKS : '';
                    bank.Bank_name_in_English__c = bankDetail.ZZACCNAME != null ? bankDetail.ZZACCNAME : '';
                    bank.CurrencyIsoCode = bankDetail.ZZWAERS != null ? bankDetail.ZZWAERS : '';
                    bank.Bank_Control_Code__c = bankDetail.BKONT != null ? bankDetail.BKONT : '';

                    addCustomerBanksList.add(bank);
                }
            }
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');
            // 保存客户相关数据
            if (addCustomerExtendList != null && addCustomerExtendList.size() > 0){
                Database.insert (addCustomerExtendList);
            }
            if (addCustomerBanksList != null && addCustomerBanksList.size() > 0){
                Database.insert (addCustomerBanksList);
            }

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
                    Database.insert (customerExtendTaxCategoryList);
                }
            }

        } catch (Exception e){
            // 回滚事务
            Database.rollback(sp);
            //恢复触发器
            Utility.IgnoreAction(false, false, false, '');
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }

        resp.data = mso;
        return resp;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-05-21 14:20:44
     * @Description: 客户信息变更显示
     */
    @AuraEnabled
    public static ConResponse initAccountChangesInfo(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        Map<String, String> channelCustomerCategoriesMap = Utility.getPicklistValueMap('Account', 'Channel_Customer_Categories__c');
        Map<String, String> channelCustomerSubcategoriesMap = Utility.getPicklistValueMap('Account', 'Channel_Customer_Subcategories__c');
        Map<String, String> transportationAreaMap = Utility.getPicklistValueMap('Account', 'Transportation_area__c');
        Map<String, String> hisenseEntityMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Hisense_Entity__c');
        Map<String, String> reconciliationCustomerMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Reconciliation_Customer__c');
        Map<String, String> deliveryingPlantMap = Utility.getPicklistValueMap('Customer_Extend__c', 'Deliverying_Plant__c');
        // 参数recordId是否是客户id
        Id cid = Id.valueOf(recordId);
        // Approval Request 页面中
        if (cid.getSObjectType().getDescribe().getName() == 'ProcessInstanceWorkitem'){
            ProcessInstanceWorkitem piw = [SELECT ProcessInstance.TargetObjectId
                                           FROM ProcessInstanceWorkitem
                                           WHERE Id = :cid
                                           LIMIT 1];

            // 判断审批流是否是客户的审批
            if (piw.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName() == 'Account'){
                recordId = piw.ProcessInstance.TargetObjectId;
            } else{
                mso.put('haveHistory', false);
                resp.data = mso;
                return resp;
            }
        }

        List<String> excludeField = new List<String>{ 'Id', 'Name', 'Approval_Status__c', 'Current_Modifier__c' };
        // 主信息数据对比
        List<Map<String, Object>> customerDifferencesList = new List<Map<String, Object>>();
        // 公司视图数据对比
        List<Map<String, Object>> companyUpdateDifferencesList = new List<Map<String, Object>>();
        List<Map<String, Object>> companyNewDifferencesList = new List<Map<String, Object>>();
        // 销售视图数据对比
        List<Map<String, Object>> salesUpdateDifferencesList = new List<Map<String, Object>>();
        List<Map<String, Object>> salesNewDifferencesList = new List<Map<String, Object>>();
        // 银行视图数据对比
        List<Map<String, Object>> banksUpdateDifferencesList = new List<Map<String, Object>>();
        List<Map<String, Object>> banksNewDifferencesList = new List<Map<String, Object>>();
        // 查询客户主信息
        List<Account> accountList = CustomerHistoryQueueable.getAccountById(recordId);
        Account account = accountList[0];
        // 查询公司视图信息
        List<Customer_Extend__c> companyList = CustomerHistoryQueueable.getCompanyByAccountId(recordId);
        // 查询销售视图信息
        List<Customer_Extend__c> salesList = CustomerHistoryQueueable.getSalesByAccountId(recordId);
        // 查询销售视图的税信息
        List<Customer_Extend_Tax_category__c> taxList = CustomerHistoryQueueable.getTaxByAccountId(recordId);
        // 查询银行信息
        List<Customer_Banks__c> banksList = CustomerHistoryQueueable.getBanksByAccountId(recordId);
        // 查询历史表最新version获取客户所有相关数据
        List<Customer_History__c> customerHistoryList = [SELECT Id, Object_Name__c, Record_Id__c, Record_Body__c
                                                         FROM Customer_History__c
                                                         WHERE Latest_Version__c = :account.Latest_Version__c];
        // 没有历史数据则不执行一下逻辑
        if (customerHistoryList == null || customerHistoryList.size() == 0){
            mso.put('haveHistory', false);
            resp.data = mso;
            return resp;
        } else{
            mso.put('haveHistory', true);
        }
        Map<String, SObject> customerHistoryMap = new LisqContainer(customerHistoryList).ToMapS('Record_Id__c');
        // 客户的历史数据
        Customer_History__c customerHistory = (Customer_History__c) customerHistoryMap.get(account.Id);
        // 比较数据获取不同的map
        Map<String, Object> customerDifferences = JsonComparator.compareJson(customerHistory.Record_Body__c, JSON.serialize(account));
        for (String key : customerDifferences.keySet()){
            if (excludeField.contains(key)){
                continue;
            }
            System.debug('wwwwww-----' + key + '------------' + customerDifferences.get(key));
            Map<String, Object> tempMap = (Map<String, Object>)customerDifferences.get(key);
            // picklist 依赖关系的字段，不取Api Name，直接取Value
            Object initialValue;
            Object changeValue;
            if (key == 'Channel_Customer_Categories__c'){
                initialValue = channelCustomerCategoriesMap.get(String.valueOf(tempMap.get('json1')));
                changeValue = channelCustomerCategoriesMap.get(String.valueOf(tempMap.get('json2')));
            } else if (key == 'Channel_Customer_Subcategories__c'){
                initialValue = channelCustomerSubcategoriesMap.get(String.valueOf(tempMap.get('json1')));
                changeValue = channelCustomerSubcategoriesMap.get(String.valueOf(tempMap.get('json2')));
            } else if (key == 'Transportation_area__c'){
                initialValue = transportationAreaMap.get(String.valueOf(tempMap.get('json1')));
                changeValue = transportationAreaMap.get(String.valueOf(tempMap.get('json2')));
            } else{
                initialValue = tempMap.get('json1');
                changeValue = tempMap.get('json2');
            }
            customerDifferencesList.add(new Map<String, Object>{ 'fieldNameLabel' => getFieldLabel('Account', key), 'fieldName' => key, 'initialValue' => initialValue, 'changeValue' => changeValue });
        }

        // 比较公司视图
        for (Customer_Extend__c ce : companyList){
            List<Map<String, Object>> differencesListTemp = new List<Map<String, Object>>();
            Map<String, Object> entityMap = new Map<String, Object>();
            // 存在历史表中，表示不是新建的数据
            if (customerHistoryMap.get(ce.Id) != null){
                Customer_History__c companyHistory = (Customer_History__c) customerHistoryMap.get(ce.Id);
                Map<String, Object> companyDifferences = JsonComparator.compareJson(companyHistory.Record_Body__c, JSON.serialize(ce));
                // 对比数据为空时，则跳过
                if (companyDifferences.isEmpty()){
                    continue;
                }
                for (String key : companyDifferences.keySet()){
                    if (excludeField.contains(key)){
                        continue;
                    }
                    System.debug('wwwwww-----' + key + '------------' + companyDifferences.get(key));
                    Map<String, Object> tempMap = (Map<String, Object>)companyDifferences.get(key);
                    // picklist 依赖关系的字段，不取Api Name，直接取Value
                    Object initialValue;
                    Object changeValue;
                    if (key == 'Reconciliation_Customer__c'){
                        initialValue = reconciliationCustomerMap.get(String.valueOf(tempMap.get('json1')));
                        changeValue = reconciliationCustomerMap.get(String.valueOf(tempMap.get('json2')));
                    } else if (key == 'Deliverying_Plant__c'){
                        initialValue = deliveryingPlantMap.get(String.valueOf(tempMap.get('json1')));
                        changeValue = deliveryingPlantMap.get(String.valueOf(tempMap.get('json2')));
                    } else{
                        initialValue = tempMap.get('json1');
                        changeValue = tempMap.get('json2');
                    }
                    differencesListTemp.add(new Map<String, Object>{ 'fieldNameLabel' => getFieldLabel('Customer_Extend__c', key), 'fieldName' => key, 'initialValue' => initialValue, 'changeValue' => changeValue });
                }
                entityMap.put('entityUpdate', hisenseEntityMap.get(ce.Hisense_Entity__c));
                entityMap.put('differences', differencesListTemp);
                companyUpdateDifferencesList.add(entityMap);
            } else{
                entityMap.put('entityNew', hisenseEntityMap.get(ce.Hisense_Entity__c));
                companyNewDifferencesList.add(entityMap);
            }
        }

        // 比较销售视图
        for (Customer_Extend__c ce : salesList){
            List<Map<String, Object>> differencesListTemp = new List<Map<String, Object>>();
            Map<String, Object> entityMap = new Map<String, Object>();
            // 存在历史表中，表示不是新建的数据
            if (customerHistoryMap.get(ce.Id) != null){
                Customer_History__c salesHistory = (Customer_History__c) customerHistoryMap.get(ce.Id);
                Map<String, Object> salesDifferences = JsonComparator.compareJson(salesHistory.Record_Body__c, JSON.serialize(ce));
                // 对比数据为空时，则跳过
                if (salesDifferences.isEmpty()){
                    continue;
                }
                for (String key : salesDifferences.keySet()){
                    if (excludeField.contains(key)){
                        continue;
                    }
                    System.debug('wwwwww-----' + key + '------------' + salesDifferences.get(key));
                    Map<String, Object> tempMap = (Map<String, Object>)salesDifferences.get(key);
                    // picklist 依赖关系的字段，不取Api Name，直接取Value
                    Object initialValue;
                    Object changeValue;
                    if (key == 'Reconciliation_Customer__c'){
                        initialValue = reconciliationCustomerMap.get(String.valueOf(tempMap.get('json1')));
                        changeValue = reconciliationCustomerMap.get(String.valueOf(tempMap.get('json2')));
                    } else if (key == 'Deliverying_Plant__c'){
                        initialValue = deliveryingPlantMap.get(String.valueOf(tempMap.get('json1')));
                        changeValue = deliveryingPlantMap.get(String.valueOf(tempMap.get('json2')));
                    } else{
                        initialValue = tempMap.get('json1');
                        changeValue = tempMap.get('json2');
                    }
                    differencesListTemp.add(new Map<String, Object>{ 'fieldNameLabel' => getFieldLabel('Customer_Extend__c', key), 'fieldName' => key, 'initialValue' => initialValue, 'changeValue' => changeValue });
                }
                entityMap.put('entityUpdate', hisenseEntityMap.get(ce.Hisense_Entity_Sales__c));
                entityMap.put('differences', differencesListTemp);
                salesUpdateDifferencesList.add(entityMap);
            } else{
                entityMap.put('entityNew', hisenseEntityMap.get(ce.Hisense_Entity_Sales__c));
                salesNewDifferencesList.add(entityMap);
            }
        }

        // 比较银行视图
        for (Customer_Banks__c ce : banksList){
            List<Map<String, Object>> differencesListTemp = new List<Map<String, Object>>();
            Map<String, Object> entityMap = new Map<String, Object>();
            // 存在历史表中，表示不是新建的数据
            if (customerHistoryMap.get(ce.Id) != null){
                Customer_History__c banksHistory = (Customer_History__c) customerHistoryMap.get(ce.Id);
                Map<String, Object> banksDifferences = JsonComparator.compareJson(banksHistory.Record_Body__c, JSON.serialize(ce));
                // 对比数据为空时，则跳过
                if (banksDifferences.isEmpty()){
                    continue;
                }
                for (String key : banksDifferences.keySet()){
                    if (excludeField.contains(key)){
                        continue;
                    }
                    System.debug('wwwwww-----' + key + '------------' + banksDifferences.get(key));
                    Map<String, Object> tempMap = (Map<String, Object>)banksDifferences.get(key);
                    differencesListTemp.add(new Map<String, Object>{ 'fieldNameLabel' => getFieldLabel('Customer_Banks__c', key), 'fieldName' => key, 'initialValue' => tempMap.get('json1'), 'changeValue' => tempMap.get('json2') });
                }
                entityMap.put('nameUpdate', ce.Name);
                entityMap.put('differences', differencesListTemp);
                banksUpdateDifferencesList.add(entityMap);
            } else{
                entityMap.put('nameNew', ce.Name);
                banksNewDifferencesList.add(entityMap);
            }
        }

        mso.put('customerDifferencesList', customerDifferencesList);
        mso.put('companyUpdateDifferencesList', companyUpdateDifferencesList);
        mso.put('companyNewDifferencesList', companyNewDifferencesList);
        mso.put('salesUpdateDifferencesList', salesUpdateDifferencesList);
        mso.put('salesNewDifferencesList', salesNewDifferencesList);
        mso.put('banksUpdateDifferencesList', banksUpdateDifferencesList);
        mso.put('banksNewDifferencesList', banksNewDifferencesList);

        mso.put('isHaveCustomerDifferencesList', customerDifferencesList != null ? true : false);
        mso.put('isHaveCompanyUpdateDifferencesList', companyUpdateDifferencesList != null ? true : false);
        mso.put('isHaveCompanyNewDifferencesList', companyNewDifferencesList != null ? true : false);
        mso.put('isHaveSalesUpdateDifferencesList', salesUpdateDifferencesList != null ? true : false);
        mso.put('isHaveSalesNewDifferencesList', salesNewDifferencesList != null ? true : false);
        mso.put('isHaveBanksUpdateDifferencesList', banksUpdateDifferencesList != null ? true : false);
        mso.put('isHaveBanksNewDifferencesList', banksNewDifferencesList != null ? true : false);

        resp.data = mso;
        return resp;
    }

    public static String getFieldLabel(String objectApiName, String fieldApiName){
        SObjectType objType = ((SObject) Type.forName(objectApiName).newInstance()).getSObjectType();
        return objType.getDescribe().fields.getMap().get(fieldApiName).getDescribe().getLabel();
    }

    public class CustomerExtendData{
        public String Id;
        public String Name;
        public Boolean Extend_or_Not;
        public String Hisense_Entity_Api;
        public String Hisense_Entity;
        public String Reconciliation_Customer;
        public String EDI_ID;
        public String Stor_Location;
        public String Payment_Method_MDG;
        public String Payment_Term;
        public String Payment_Term_Url;
        public String Hisense_Entity_Sales_Api;
        public String Hisense_Entity_Sales;
        public String Distribution_Channel;
        public String Sales_Office;
        public String Sales_Office_Id;
        public String Sales_Office_Url;
        public String Sales_Office_Value;
        public String Sales_Group;
        public String Sales_Group_Id;
        public String Sales_Group_Url;
        public String iconName;
        public String buttonVariante;
    }

    public class CustomerBanksData{
        public String Id;
        public String Name;
        public Boolean Extend_or_Not;
        public String Bank_Code;
        public String Bank_Account;
        public String Bank_name_local_language;
        public String Bank_Country_Api;
        public String Bank_Country;
        public String Bank_Control_Code;
        public String Reference_Detail;
        public String Swift_Code;
        public String MDG_BANK;
    }

    public class CustomerProductLineData{
        public String Id;
        public String Name;
        public String Classification;
        public String Product_Line_Name;
        public String Development_Stage;
        public String buttonVariante;
        public String recordTypeId;
        public String recordTypeName;
        public Decimal evaluatedScore;
        public Score_Sheet__c scoreSheet;

    }

}