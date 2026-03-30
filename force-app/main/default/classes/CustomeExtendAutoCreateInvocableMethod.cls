/*
 * @Author: WFC
 * @Date: 2025-01-10 17:25:59
 * @LastEditors: WFC
 * @LastEditTime: 2025-06-04 14:18:48
 * @Description: 自动生成客户拓展数据
 * @FilePath: \HiTest20250422\force-app\main\default\classes\CustomeExtendAutoCreateInvocableMethod.cls
 */
public without sharing class CustomeExtendAutoCreateInvocableMethod{
    @InvocableMethod
    public static void addCustomerExtend(List<String> customerIdList){
        if (customerIdList != null && customerIdList.size() > 0){
            Account account = [SELECT Id,
                                    Hisense_Entity__c, 
                                    E_commerce_Customer_Label__c, 
                                    Reconciliation_Customer__c, 
                                    Customer_EDI_ID_Type__c,
                                    Payment_Method_MDG__c, 
                                    EDI_ID__c, 
                                    EDI_ID2__c, 
                                    VAT_Tax_type__c, 
                                    Add_VAT_Reg_No__c, 
                                    Packing_Type__c, 
                                    Account_Remarks__c,
                                    TV_lisense__c, 
                                    Company_View_Freeze_markers__c, 
                                    Valid_to__c, 
                                    Payment_Term__c, 
                                    Hisense_Entity_Sales__c, 
                                    Distribution_Channel__c,
                                    Deliverying_Plant__c, 
                                    Account_Assignment_Group__c, 
                                    Sales_Region__c, 
                                    Customer_pricing_process__c, 
                                    Sales_Office__c, 
                                    Payment_Term_Sales__c,
                                    Sales_Group__c, 
                                    Price_Group__c, Stor_Location__c, 
                                    CurrencyIsoCode, 
                                    Shipping_Conditions__c,
                                    KDGRP__c, 
                                    International_Trade_Terms__c,
                                    International_Trade_Terms_2__c, 
                                    Customer_Group2__c, 
                                    Price_List__c, 
                                    Payer__c, 
                                    Receiver__c, 
                                    Payback_Overdue_Number__c, 
                                    Related_to_POD__c, 
                                    Sales_View_Freeze_markers__c,
                                    // 客户新增字段 （wfc 2025-02-08）
                                    Customer_Group_1__c,
                                    Customer_Group_3__c,
                                    Customer_Group_4__c,
                                    Customer_Group_5__c
                                FROM Account
                                WHERE Id = :customerIdList[0]
                                LIMIT 1];
            if(account.Hisense_Entity__c != null && account.Hisense_Entity_Sales__c != null){
                Customer_Extend__c customerExtendCompany = new Customer_Extend__c();
                customerExtendCompany.Customer__c = account.Id;
                customerExtendCompany.Extend_or_Not__c = true;
                customerExtendCompany.Show_Company__c = true;
                customerExtendCompany.Show_Sales__c = false;
                customerExtendCompany.Approval_Status__c = 'Approved';
                customerExtendCompany.Create_View__c = '1';
                customerExtendCompany.ExternalID__c = account.Id + '-' + account.Hisense_Entity__c + '-' + '' + '-' + '';
                // 公司视图
                customerExtendCompany.Hisense_Entity__c = account.Hisense_Entity__c;
                customerExtendCompany.E_commerce_Customer_Label__c = account.E_commerce_Customer_Label__c;
                customerExtendCompany.Reconciliation_Customer__c = account.Reconciliation_Customer__c;
                customerExtendCompany.Customer_EDI_ID_Type__c = account.Customer_EDI_ID_Type__c;
                customerExtendCompany.Payment_Method_MDG__c = account.Payment_Method_MDG__c;
                customerExtendCompany.EDI_ID__c = account.EDI_ID__c;
                customerExtendCompany.EDI_ID2__c = account.EDI_ID2__c;
                customerExtendCompany.VAT_Tax_type__c = account.VAT_Tax_type__c;
                customerExtendCompany.Add_VAT_Reg_No__c = account.Add_VAT_Reg_No__c;
                customerExtendCompany.Packing_Type__c = account.Packing_Type__c;
                customerExtendCompany.Account_Remarks__c = account.Account_Remarks__c;
                customerExtendCompany.TV_lisense__c = account.TV_lisense__c;
                customerExtendCompany.Company_View_Freeze_markers__c = account.Company_View_Freeze_markers__c;
                customerExtendCompany.Valid_to__c = account.Valid_to__c;
                customerExtendCompany.Payment_Term__c = account.Payment_Term__c;
                customerExtendCompany.Stor_Location__c = account.Stor_Location__c;


                Customer_Extend__c customerExtendSales = new Customer_Extend__c();
                customerExtendSales.Customer__c = account.Id;
                customerExtendSales.Extend_or_Not__c = true;
                customerExtendSales.Show_Company__c = false;
                customerExtendSales.Show_Sales__c = true;
                customerExtendSales.Approval_Status__c = 'Approved';
                customerExtendSales.Create_View__c = '2';
                customerExtendSales.ExternalID__c = account.Id + '-' + '' + '-' + account.Hisense_Entity_Sales__c + '-' + account.Distribution_Channel__c;
                // 销售视图
                customerExtendSales.Hisense_Entity_Sales__c = account.Hisense_Entity_Sales__c;
                customerExtendSales.Distribution_Channel__c = account.Distribution_Channel__c;
                customerExtendSales.Deliverying_Plant__c = account.Deliverying_Plant__c;
                customerExtendSales.Account_Assignment_Group__c = account.Account_Assignment_Group__c;
                customerExtendSales.Sales_Region__c = account.Sales_Region__c;
                customerExtendSales.Customer_pricing_process__c = account.Customer_pricing_process__c;
                customerExtendSales.Sales_Office__c = account.Sales_Office__c;
                customerExtendSales.Payment_Term_Sales__c = account.Payment_Term_Sales__c;
                customerExtendSales.Sales_Group__c = account.Sales_Group__c;
                customerExtendSales.Price_Group__c = account.Price_Group__c;
                customerExtendSales.CurrencyIsoCode = account.CurrencyIsoCode;
                customerExtendSales.Shipping_Conditions__c = account.Shipping_Conditions__c;
                customerExtendSales.KDGRP__c = account.KDGRP__c;
                customerExtendSales.International_Trade_Terms__c = account.International_Trade_Terms__c;
                customerExtendSales.International_Trade_Terms_2__c = account.International_Trade_Terms_2__c;
                customerExtendSales.Customer_Group2__c = account.Customer_Group2__c;
                customerExtendSales.Price_List__c = account.Price_List__c;
                customerExtendSales.Payer__c = account.Payer__c;
                customerExtendSales.Receiver__c = account.Receiver__c;
                customerExtendSales.Payback_Overdue_Number__c = account.Payback_Overdue_Number__c;
                customerExtendSales.Related_to_POD__c = account.Related_to_POD__c;
                customerExtendSales.Sales_View_Freeze_markers__c = account.Sales_View_Freeze_markers__c;
                // 客户新增字段 （wfc 2025-02-08）
                customerExtendSales.Customer_Group_1__c = account.Customer_Group_1__c;
                customerExtendSales.Customer_Group_3__c = account.Customer_Group_3__c;
                customerExtendSales.Customer_Group_4__c = account.Customer_Group_4__c;
                customerExtendSales.Customer_Group_5__c = account.Customer_Group_5__c;

                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
                Database.upsert(customerExtendCompany, Customer_Extend__c.Fields.ExternalID__c, true);
                Database.upsert(customerExtendSales, Customer_Extend__c.Fields.ExternalID__c, true);
                // 查询客户税信息
                List<Customer_Tax_category__c> customerTaxCategoryList = [SELECT Id, Tax_category__c, National_tax_category__c, Tax_category_code__c  FROM Customer_Tax_category__c
                                                            WHERE Customer__c = :account.Id];
                // 根据税类别分组
                Map<String,SObject> taxMap = new LisqContainer(customerTaxCategoryList).ToMapS('Tax_category_code__c');
                // 查询税信息
                List<Customer_Extend_Tax_category__c> customerExtendTaxCategoryList = [SELECT Id, Tax_category__c, National_tax_category__c, Tax_category_code__c  FROM Customer_Extend_Tax_category__c
                                                            WHERE Customer_Extend__c = :customerExtendSales.Id];
                for(Customer_Extend_Tax_category__c customerExtendTaxCategory : customerExtendTaxCategoryList){
                    Customer_Tax_category__c tax = (Customer_Tax_category__c)taxMap.get(customerExtendTaxCategory.Tax_category_code__c);
                    customerExtendTaxCategory.Tax_category__c = tax.Tax_category__c;
                }
                update customerExtendTaxCategoryList;
                // 锁定新建的表
                // Approval.lock(customerExtendCompany, true);
                // Approval.lock(customerExtendSales, true);
            }
            
        }
    }

}