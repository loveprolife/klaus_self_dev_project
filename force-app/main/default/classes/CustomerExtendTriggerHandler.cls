/*
 * @Author: WFC
 * @Date: 2023-03-23 16:38:33
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-22 10:03:03
 * @Description:
 * @FilePath: \testuat\force-app\main\default\classes\CustomerExtendTriggerHandler.cls
 */
public class CustomerExtendTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public void handle(){

        if (Trigger.isBefore && Trigger.isUpdate){
            for (Customer_Extend__c acc : ((list<Customer_Extend__c>)Trigger.new )){
                Customer_Extend__c accOld = (Customer_Extend__c)Trigger.oldMap.get(acc.Id);

                //lzx 20250122
                if('Approved'.equals(accOld.Approval_Status__c) && !Label.Undo_Changes_Profile_Exclude.contains(currentUser.Profile.name)){

                    String oldBodyJson = JSON.serialize(accOld);
                    String newBodyJson = JSON.serialize(acc);

                    if(!oldBodyJson.equals(newBodyJson)){
                        Utility.insertCusHistoyr(acc.Id, 'Customer_Extend__c', '变更', oldBodyJson, newBodyJson);
                        acc.Approval_Status__c = 'Draft';
                    }
                }
            }
            
        }

        if (Trigger.isAfter && Trigger.isInsert){
            //获取税分类组织mapping
            Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();

            Map<String, String> taxCounMap = new Map<String, String>();
            //根据客户的Hisense entity获取税分类国家
            for (Customer_Extend__c acc : ((list<Customer_Extend__c>)Trigger.new )){
                if (String.isNotBlank(acc.Hisense_Entity_Sales__c)){
                    String cs = countries.get(acc.Hisense_Entity_Sales__c).Country__c;
                    taxCounMap.put(acc.id, cs);
                }
            }

            if (taxCounMap.size() > 0){
                creatTax(taxCounMap);
            }
        }


        if (Trigger.isAfter && Trigger.isUpdate){

            //获取税分类组织mapping
            Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();

            Map<String, String> taxCounMap = new Map<String, String>();

            //同步到SAP的客户ID集合
            List<String> accIdList = new List<String>();

            for (Customer_Extend__c acc : ((list<Customer_Extend__c>)Trigger.new )){
                Customer_Extend__c accOld = (Customer_Extend__c) Trigger.oldMap.get(acc.Id);
                if (String.isNotBlank(acc.Hisense_Entity_Sales__c) && accOld.Hisense_Entity_Sales__c <> acc.Hisense_Entity_Sales__c){
                    String cs = countries.get(acc.Hisense_Entity_Sales__c).Country__c;
                    taxCounMap.put(acc.id, cs);
                }
                // 审批通过发送sap
                if (acc.Approval_Status__c.equals('Approved') && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)){
                    accIdList.add(acc.Id);
                }
            }

            if (taxCounMap.size() > 0){
                //删除原有的税分类
                List<Customer_Extend_Tax_category__c> ctcsdels = [select id
                                                                  from Customer_Extend_Tax_category__c
                                                                  where Customer_Extend__c in:taxCounMap.keySet()];
                if (ctcsdels.size() > 0)
                    delete ctcsdels;
                creatTax(taxCounMap);
            }

            if (accIdList.size() > 0){
                for (String accId : accIdList){
                    String jobID = System.enqueueJob(new AccountTriggerHandler.AsyncSyncCustomer(accId));
                    system.Debug('======== jobID===' + jobID);
                }
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){

            //获取财务必填字段的field set
            List<Schema.FieldSetMember> sfsFin = SObjectType.Customer_Extend__c.FieldSets.Fin_Required_Fields.getFields();
            //获取财务必填字段的field set 公司视图
            List<Schema.FieldSetMember> sfsFinCompany = SObjectType.Customer_Extend__c.FieldSets.Fin_Required_Fields_Company.getFields();
            

            List<String> accIDs = new List<String>();
            // 主户ID
            List<String> parentAccIds = new List<String>();
            Map<String, String> payerMap = new Map<String, String>();
            Map<String, String> billerMap = new Map<String, String>();
            List<String> payBillList = new List<String>();
            for (Customer_Extend__c acc : ((list<Customer_Extend__c>)Trigger.new )){
                if(String.isNotBlank(acc.Create_View__c)){
                    if('1'.equals(acc.Create_View__c)){
                        acc.Show_Sales__c = false;
                        acc.Show_Company__c = true;
                    }else if('2'.equals(acc.Create_View__c)){
                        acc.Show_Sales__c = true;
                        acc.Show_Company__c = false;

                        //新加坡POD默认为true
                        if(Trigger.isInsert && 
                            (acc.Hisense_Entity_Sales__c == '8470'
                            || acc.Hisense_Entity_Sales__c == '8400')){
                            acc.Related_to_POD__c = true;
                        }
                    }
                }
                accIDs.add(acc.id);
                parentAccIds.add(acc.Customer__c);
                // 清空数据
                if (!acc.Show_Company__c){
                    acc.Hisense_Entity__c = '';
                    acc.E_commerce_Customer_Label__c = '';
                    acc.Reconciliation_Customer__c = '';
                    acc.Customer_EDI_ID_Type__c = '';
                    acc.Payment_Method_MDG__c = '';
                    acc.EDI_ID__c = '';
                    acc.EDI_ID2__c = '';
                    acc.VAT_Tax_type__c = '';
                    acc.Add_VAT_Reg_No__c = '';
                    acc.Packing_Type__c = '';
                    acc.Account_Remarks__c = '';
                    acc.TV_lisense__c = '';
                    acc.Company_View_Freeze_markers__c = false;
                    acc.Valid_to__c = null;
                    acc.Payment_Term__c = null;
                    acc.Stor_Location__c = null;
                }
                if (!acc.Show_Sales__c){
                    acc.Hisense_Entity_Sales__c = '';
                    acc.Distribution_Channel__c = '';
                    acc.Deliverying_Plant__c = '';
                    acc.Account_Assignment_Group__c = '';
                    acc.Sales_Region__c = '';
                    acc.Customer_pricing_process__c = '';
                    acc.Sales_Office__c = null;
                    acc.Payment_Term_Sales__c = null;
                    acc.Sales_Group__c = null;
                    acc.Price_Group__c = '';
                    acc.Shipping_Conditions__c = '';
                    acc.KDGRP__c = '';
                    acc.International_Trade_Terms__c = '';
                    acc.International_Trade_Terms_2__c = '';
                    acc.Customer_Group2__c = '';
                    acc.Price_List__c = '';
                    acc.Payer__c = null;
                    acc.Receiver__c = null;
                    acc.Payback_Overdue_Number__c = null;
                    acc.Related_to_POD__c = false;
                    acc.Sales_View_Freeze_markers__c = false;
                }
                List<String> currentAccList = new List<String>();
                if (String.isNotEmpty(acc.Payer__c)){
                    payBillList.add(acc.Payer__c);
                    payerMap.put(acc.Id, acc.Payer__c);
                }
                if (String.isNotEmpty(acc.Receiver__c)){
                    payBillList.add(acc.Receiver__c);
                    billerMap.put(acc.Id, acc.Receiver__c);
                }
            }

            Map<String, String> payBillterEntityMap = new Map<String, String>();
            List<Account> payBillers = [SELECT Id, Name, Hisense_Entity_Sales__c FROM Account WHERE Id IN: payBillList];
            for (Account payer : payBillers){
                payBillterEntityMap.put(payer.Id, payer.Hisense_Entity_Sales__c);
            }
            system.debug(payBillterEntityMap);

            // Customer Extend的付款方，开票方，只能选择已经拓展过的公司所属的付款方和开票方
            // 即Customer Extend.Reciever 和 Payer 的Hisense Entity IN：ALL Customer Extend.Hisense Entity 2025.1.13
            List<Customer_Extend__c> cexts = [SELECT Id, Hisense_Entity_Sales__c, Customer__c
                                              FROM Customer_Extend__c 
                                              WHERE Customer__c IN: parentAccIds
                                              AND Extend_or_Not__c = true];
            Map<String, Map<String, Customer_Extend__c>> cextMap = new Map<String, Map<String, Customer_Extend__c>>();
            for (Customer_Extend__c cext : cexts){
                Map<String, Customer_Extend__c> cextInfo = cextMap.get(cext.Customer__c) != null ? cextMap.get(cext.Customer__c) : new Map<String, Customer_Extend__c>();
                cextInfo.put(cext.Hisense_Entity_Sales__c, cext);
                cextMap.put(cext.Customer__c, cextInfo);
            }
            system.debug(cextMap);

            //查询税分类
            List<Customer_Extend_Tax_category__c> ctaxs = [SELECT Customer_Extend__c, Tax_category__c
                                                           FROM Customer_Extend_Tax_category__c
                                                           WHERE Customer_Extend__c in:accIDs];
            Map<String, List<String>> ctaxMap = new Map<String, List<String>>();
            if (ctaxs.size() > 0){
                for (Customer_Extend_Tax_category__c ctax : ctaxs){
                    if (ctaxMap.containsKey(ctax.Customer_Extend__c)){
                        List<String> taxs = ctaxMap.get(ctax.Customer_Extend__c);
                        taxs.add(ctax.Tax_category__c);
                        ctaxMap.put(ctax.Customer_Extend__c, taxs);
                    } else{
                        List<String> taxs = new List<String>();
                        taxs.add(ctax.Tax_category__c);
                        ctaxMap.put(ctax.Customer_Extend__c, taxs);
                    }
                }
            }

            for (Customer_Extend__c acc : ((list<Customer_Extend__c>)Trigger.new )){

                // Customer Extend的付款方，开票方，只能选择已经拓展过的公司所属的付款方和开票方
                // 即Customer Extend.Reciever 和 Payer 的Hisense Entity IN：ALL Customer Extend.Hisense Entity 2025.1.13
                Map<String, Customer_Extend__c> cextInfo = cextMap.get(acc.Customer__c);
                if (String.isNotEmpty(acc.Receiver__c)) {
                    String receiverEntity = payBillterEntityMap.get(billerMap.get(acc.Id));
                    if (cextInfo != null && !cextInfo.containsKey(receiverEntity)){
                        if (!Test.isRunningTest()){
                            // acc.addError(Label.MDGPayerReceiverNotMatch);
                            // return;
                        }
                    }
                }
                if (String.isNotEmpty(acc.Payer__c)) {
                    String payerEntity = payBillterEntityMap.get(payerMap.get(acc.Id));
                    if (cextInfo != null && !cextInfo.containsKey(payerEntity)){
                        if (!Test.isRunningTest()){
                            // acc.addError(Label.MDGPayerReceiverNotMatch);
                            // return;
                        }
                    }
                }

                acc.ExternalID__c = acc.Customer__c + '-' + acc.Hisense_Entity__c + '-' + acc.Hisense_Entity_Sales__c + '-' + acc.Distribution_Channel__c;

                //当进行到财务审核时触发财务信息录入的校验
                if (acc.Financial_Approval__c && acc.Show_Sales__c){
                    for (Schema.FieldSetMember f : sfsFin){
                        if (acc.get(f.getFieldPath()) == null){
                            if (!Test.isRunningTest()){
                                acc.addError(Label.need_fin_info);
                                return;
                            }
                        }
                    }
                    //校验税分类是否填写
                    if (ctaxMap.size() > 0){
                        List<String> ctaxchks = ctaxMap.get(acc.Id);
                        for (String ctaxchk : ctaxchks){
                            if (String.isBlank(ctaxchk)){
                                if (!Test.isRunningTest()){
                                    acc.addError(Label.need_Tax_classification);
                                    return;
                                }
                            }
                        }
                    }
                    acc.Financial_Approval__c = false;
                //当进行到财务审核时触发财务信息录入的校验 ---公司视图
                }else if (acc.Financial_Approval__c && acc.Show_Company__c){
                    for (Schema.FieldSetMember f : sfsFinCompany){
                        if (acc.get(f.getFieldPath()) == null){
                            if (!Test.isRunningTest()){
                                acc.addError(Label.need_fin_info);
                                return;
                            }
                        }
                    }
                    acc.Financial_Approval__c = false;
                }
            }
        }
    }

    private void creatTax(Map<String, String> taxCounMap){
        List<String> couns = new List<String>();
        //根据国家自动生成税分类列表
        for (String ss : taxCounMap.values()){
            couns.addAll(ss.split(';'));
        }
        system.debug(taxCounMap);
        Map<String, List<National_tax_category__c>> ntcsMap = new Map<String, List<National_tax_category__c>>();
        //根据国家代码查询国家税分类
        List<National_tax_category__c> ntcs = [select id, National_code__c, sort__c, Tax_category__c
                                               from National_tax_category__c
                                               where National_code__c in:couns
                                               order by sort__c];

        for (National_tax_category__c ntc : ntcs){
            if (ntcsMap.containsKey(ntc.National_code__c)){
                List<National_tax_category__c> srts = ntcsMap.get(ntc.National_code__c);
                srts.add(ntc);
                ntcsMap.put(ntc.National_code__c, srts);
            } else{
                List<National_tax_category__c> srts = new List<National_tax_category__c>();
                srts.add(ntc);
                ntcsMap.put(ntc.National_code__c, srts);
            }
        }
        system.debug(ntcsMap);
        List<Customer_Extend_Tax_category__c> ctcsIn = new List<Customer_Extend_Tax_category__c>();
        for (String accId : taxCounMap.keySet()){
            List<String> counss = taxCounMap.get(accId).split(';');
            List<National_tax_category__c> srts = new List<National_tax_category__c>();
            //system.debug(counss);
            for (String con : counss){
                if (!ntcsMap.isEmpty()){
                    srts.addAll(ntcsMap.get(con));
                }
            }

            if (srts == null){
                break;
            }
            //system.debug(srts);
            for (National_tax_category__c ntc : srts){
                Customer_Extend_Tax_category__c ctc = new Customer_Extend_Tax_category__c();
                ctc.Customer_Extend__c = accId;
                ctc.National_tax_category__c = ntc.id;
                //ctc.Name = ntc.National_code__c;
                ctc.Tax_category_code__c = ntc.Tax_category__c;
                ctc.Customer_Tax_Category_External_Id__c = accId + ntc.Tax_category__c;
                ctcsIn.add(ctc);
            }
        }

        if (ctcsIn.size() > 0)
            Database.upsert (ctcsIn, Customer_Extend_Tax_category__c.Fields.Customer_Tax_Category_External_Id__c, false);
    }

}