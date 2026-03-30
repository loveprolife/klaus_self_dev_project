global class UtilitySchedulableController implements Schedulable{
    global void execute(SchedulableContext SC){
        // 删除初始化定时
        deleteSchedulable('UtilitySchedulableController');
        List<Temporary_Table__c> templist = [SELECT Id, Name, Is_Delete__c
                                             FROM Temporary_Table__c
                                             WHERE Is_Delete__c = false
                                             LIMIT 45];
        // Set<String> idSet = new Set<String>();
        // for (Temporary_Table__c temp : templist){
        //     temp.Is_Delete__c = true;
        //     idSet.add(temp.Name);
        // }
        // // 查询客户信息，维护电商属性
        // List<Account> accList = [SELECT Id, E_commerce_Customer_Label__c, Ecss_Flag__c
        //                          FROM Account
        //                          WHERE Id IN:idSet AND E_commerce_Customer_Label__c = NULL];
        // for (Account acc : accList){
        //     acc.E_commerce_Customer_Label__c = '10';
        // }

        // List<Tax_category__c> taxList = [SELECT Id, Name, Tax_category__c
        //                                  FROM Tax_category__c];
        // Map<String, SObject> taxMap = new LisqContainer(taxList).ToMapS('Tax_category__c');

        // List<National_tax_category__c> ntcList = [SELECT Id, name, National_code__c, Nationnal_Tax_Catagoery_External_Id__c, Tax_category__c
        //                                           FROM National_tax_category__c];
        // Map<String, SObject> ntcMap = new LisqContainer(ntcList).ToMapS('Nationnal_Tax_Catagoery_External_Id__c');

        // // 查询税信息
        // List<Customer_Tax_category__c> ctcList = [SELECT Id, Tax_category__c, National_tax_category__c, Tax_category_code__c, Customer__r.Guarantor_Country_Code__c
        //                                           FROM Customer_Tax_category__c
        //                                           WHERE Customer__c IN:idSet];
        // for (Customer_Tax_category__c ctc : ctcList){
        //     if (taxMap.get(ctc.Tax_category_code__c) != null){
        //         Tax_category__c tc = (Tax_category__c) taxMap.get(ctc.Tax_category_code__c);
        //         ctc.Tax_category__c = tc.Id;
        //     }

        //     if (ntcMap.get(ctc.Customer__r.Guarantor_Country_Code__c + ctc.Tax_category_code__c) != null){
        //         National_tax_category__c ntc = (National_tax_category__c) ntcMap.get(ctc.Customer__r.Guarantor_Country_Code__c + ctc.Tax_category_code__c);
        //         ctc.National_tax_category__c = ntc.Id;
        //     }
        // }
        // //忽略触发器更新
        // GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'UtilitySchedulableController');
        // try{
        //     update accList;
        //     update ctcList;
        //     update templist;
        // } catch (Exception e){
        //     Utility.IgnoreAction(false, false, false, '');
        // }
        // //恢复触发器
        // Utility.IgnoreAction(false, false, false, '');

        String syncStartDate = Datetime.now().format('yyyy-MM-dd');
        for (Temporary_Table__c temp : templist){
            try{
                temp.Is_Delete__c = true;
                GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo(temp.Name, syncStartDate, syncStartDate, null);
                // SyncCustomerInfoToSAP.postCustomerInfomationToSAP(temp.Name);
            } catch (Exception e){

            }
        }
        update templist;

        // 当前时间N分钟，下一次定时时间
        DateTime reTime = System.Now().addMinutes(1);
        Integer minute = reTime.minute();
        Integer hour = reTime.hour();
        String con = '0 ' + minute + ' ' + hour + ' * * ?';
        if (templist != null && templist.size() > 0){
            System.schedule('UtilitySchedulableController', con, new UtilitySchedulableController());
        }
    }

    global void deleteSchedulable(String name){
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id
                                          from CronTrigger
                                          where CronJobDetail.Name like:name and CronJobDetail.JobType = '7'];
        if (cronTriggers.size() > 0){
            for (cronTrigger cronTrigger : cronTriggers){
                System.abortJob(cronTrigger.id);
            }
        }
    }

}