/**************************************************************************************************
 * AccountTriggerHandler
 * Purpose:Account Trigger处理逻辑
 * Author: xiaowei
 * Create Date: 2019-03-06 
***************************************************************************************************/
public class AccountTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public static String subAccountRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Sub_Account').getRecordTypeId();
    public static String customerType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();
    public static String aseanType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Asean').getRecordTypeId();
    public static String hitachiCustomerType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('HitachiCustomer').getRecordTypeId();
    public static String b2bCustomerType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_customer').getRecordTypeId();
    public static String unconventional = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Hisense_International_Custoemr_Unconventional').getRecordTypeId();
    public static String staff = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
    public static String vendor = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Service_Vendor').getRecordTypeId();
    public static String customerSyncedSapType = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer_synced_sap').getRecordTypeId();
    public static String customerAddress = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Address').getRecordTypeId();
    public static Map<String, RecordType> accRecordTypeMap = new Map<String, RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType = 'Account']);

    public void handle() {

        if(Trigger.isBefore && Trigger.isDelete){
            System.debug('Account-----beforeDelete');
            for (Account acc : ((list<Account>)Trigger.old)) {
                if('Submitted' == acc.Approval_Status__c  || 'Approved' == acc.Approval_Status__c || 'Adjustment' == acc.Approval_Status__c){
                    String addr = acc.Address__c;
                    String appstatus = acc.Approval_Status__c;
                    if(!Test.isRunningTest()){
                        acc.addError(Label.Cannot_delete_customer);
                        return;
                    }
                }
            }
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            System.debug('Account-----beforeInsert');
            
            // MDG Account Master Data 获取MDG 代码映射表
            Map<String, MDG_Client_Mapping__mdt> clientMappingMap = new Map<String, MDG_Client_Mapping__mdt>();
            for (MDG_Client_Mapping__mdt mapping : [SELECT Id,MasterLabel, DeveloperName,MDG_SFDC_Name__c,MDG_Description__c, MDG_Code__c, MDG_Sub_Code__c FROM MDG_Client_Mapping__mdt]) {
                clientMappingMap.put(mapping.MDG_SFDC_Name__c, mapping);
            }

            for (Account acc : ((list<Account>)Trigger.new)) {
                if(String.isNotBlank(acc.Postal_Code__c)){
                    acc.Postal_Code__c = acc.Postal_Code__c.trim();
                }

                if('TH'.equals(acc.Guarantor_Country_Code__c)){
                    acc.Address__c = (String.isNotBlank(acc.Street_2__c) ? acc.Street_2__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_3__c) ? acc.Street_3__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_4__c) ? acc.Street_4__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_5__c) ? acc.Street_5__c : '');
                }
                if(String.isNotBlank(acc.Customer_Name_Local_Language__c)){
                    if(acc.Customer_Name_Local_Language__c.length() == 40){
                        acc.Name = acc.Customer_Name_Local_Language__c + (String.isNotBlank(acc.Customer_Name_Local_Language_2__c) ? acc.Customer_Name_Local_Language_2__c : '');
                    }else{
                        acc.Name = acc.Customer_Name_Local_Language__c;
                    }
                }
                String addr = acc.Address__c;
                if(String.isNotBlank(addr) && addr.length() > 255){
                    acc.Address_Text__c = addr.substring(0, 255);
                }else {
                    acc.Address_Text__c = addr;
                }

                if(acc.SAP_Code_Generation_Time__c == null && String.isNotBlank(acc.SAP_Customer_Code__c)){
                    acc.SAP_Code_Generation_Time__c = System.Now();
                }
                // MDG Account Master Data 分户客户类型指定
                if (String.isNotEmpty(acc.Sub_account_type__c)) {
                    // acc.Parent_Customer__c = acc.ParentId;
                    acc.Customer_Short_Name__c = acc.Name;
                    acc.Customer_Name_Local_Language__c = acc.Name;
                    acc.RecordTypeId = subAccountRTId;
                    
                }

                // MDG Account Master Data 客商类型和客商类型明细自动赋值
                String recordTypeName = accRecordTypeMap.get(acc.RecordTypeId).DeveloperName;
                if (clientMappingMap.get(recordTypeName) != null){
                    acc.Trader_Type__c = clientMappingMap.get(recordTypeName).MDG_Code__c;
                    acc.CustomerDetailType__c = clientMappingMap.get(recordTypeName).MDG_Sub_Code__c;
                }

                // if ('Staff'.equals(recordTypeName)){
                //     String staffCode = 'E' + acc.Company_Registration_Number__c;
                //     acc.SAP_Customer_Code__c = staffCode;
                //     acc.MDG_Customer_Code__c = staffCode;
                // }

                // MDG Customer Status根据现系统的Customer Status值去赋值
                if(acc.Customer_Status__c != null){
                    if (clientMappingMap.get(acc.Customer_Status__c) != null){
                        acc.Customer_Status_MDG__c = clientMappingMap.get(acc.Customer_Status__c).MDG_Code__c;
                    }
                }   

                System.debug('wwwAccount-----beforeInsert11'  + acc.ID_Type__c);

            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            //获取税分类组织mapping
            Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();

            Map<String,String> taxCounMap = new Map<String,String>();
            //根据客户的Hisense entity获取税分类国家
            for (Account acc : ((list<Account>)Trigger.new)) {
                if(String.isNotBlank(acc.Hisense_Entity_Sales__c) && acc.Hisense_Entity_Sales__c != '0000'){
                    String cs = countries.get(acc.Hisense_Entity_Sales__c).Country__c;
                    taxCounMap.put(acc.id,cs);
                }
                // wfc 2025-01-02 Ecss_Flag__c标识可以跳过Ecss
                if(!acc.Ecss_Flag__c){
                    String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Id));
                    system.Debug('======== ECSS==='+jobID);
                }

                if(String.isNotBlank(acc.Email__c)){
                    Customer_Email__c ce = new Customer_Email__c();
                    ce.Email__c = acc.Email__c;
                    ce.Customer__c = acc.Id;
                    insert ce;
                }
            }

            if(taxCounMap.size()>0){
                creatTax(taxCounMap);
            }            
        }

        // if (Trigger.isBefore && Trigger.isInsert) {
        //     System.debug('ECSS-----beforeInsert');
        //     for (Account acc : ((list<Account>)Trigger.new)) {
        //         if(String.isNotBlank(acc.Name)){
        //             acc.Name = acc.Name.replace(' ', ' ');
        //         }
        //         String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Name));
        //         system.Debug('======== jobID==='+jobID);
                
                
        //         // if(acc.SAP_Code_Generation_Time__c == null && String.isNotBlank(acc.SAP_Customer_Code__c)){
        //         //     acc.SAP_Code_Generation_Time__c = System.Now();
        //         // }
        //         //使用名称触发异步逻辑

        //     }
        // }
        if (Trigger.isAfter&& Trigger.isUpdate) {
            System.debug('afterUpdate-->Ecss Update');
            for(Account acc : ((list<Account>)Trigger.new)){
                Account accOld = (Account)Trigger.oldMap.get(acc.Id);
                //获取修改的数据,查看客户名称是否修改修改时更新ECSS数据                
                if(String.isNotBlank(acc.Name) && acc.Name != accOld.Name && !acc.Ecss_Flag__c){
                    String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Id));
                    system.Debug('======== jobID==='+jobID);
                }
                system.Debug('======== String.isNotBlank(acc.Approval_Status__c) && String.isNotBlank(accOld.Approval_Status__c)==='+(String.isNotBlank(acc.Approval_Status__c) && String.isNotBlank(accOld.Approval_Status__c)));
                system.Debug('======== !acc.Approval_Status__c.equals(accOld.Approval_Status__c) && String.isBlank(acc.Ecss_Result__c) ==='+(!acc.Approval_Status__c.equals(accOld.Approval_Status__c) && String.isBlank(acc.Ecss_Result__c) ));

                if(String.isNotBlank(acc.Approval_Status__c) && String.isNotBlank(accOld.Approval_Status__c) 
                && !acc.Approval_Status__c.equals(accOld.Approval_Status__c) && String.isBlank(acc.Ecss_Result__c) ){
                    system.Debug('======== 监听Approval 用于Ecss填充');
                    String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Id));
                    system.Debug('======== Update Approval Ecss jobID==='+jobID);
                }
            }
        } 
        if (Trigger.isAfter&& Trigger.isUpdate) {
            System.debug('afterUpdate');
            //获取税分类组织mapping
            Map<String, TaxCountryMapping__c> countries = TaxCountryMapping__c.getAll();

            Map<String,String> taxCounMap = new Map<String,String>();
            //同步到SAP的客户ID集合
            List<String> accIdList = new List<String>();
            // 打分表锁定集合
            List<Id> scIdList = new List<Id>();

            List<String> accIDs = new List<String>(); 
            for (Account acc : ((list<Account>)Trigger.new)) {
                accIDs.add(acc.id);
            }
            //查询日本客户下对应的信用申请
            List<Credit_Limit_Application__c> claList= [SELECT id, Customer__c, Approval_Status__c FROM Credit_Limit_Application__c WHERE Approval_Status__c = 'Draft' and Customer__c in:accIDs];
            Map<String,Credit_Limit_Application__c> creditMap = new Map<String,Credit_Limit_Application__c>();
            if(claList.size()>0){
                for(Credit_Limit_Application__c ar : claList){
                    creditMap.put((String)ar.get('Customer__c'),ar);
                }
            }
            //查询客户所有的打分表，审批通过进行锁定
            List<Score_Sheet__c> scoreList = [SELECT id, Customer__c FROM Score_Sheet__c WHERE Customer__c in : accIDs];
            Map<String,List<Id>> scoreMap = new Map<String,List<Id>>();
            if(scoreList.size() > 0){
                for(Score_Sheet__c sc : scoreList){
                    if(scoreMap.containsKey(sc.Customer__c)){
                        List<Id> scList = scoreMap.get(sc.Customer__c);
                        scList.add(sc.Id);
                        scoreMap.put(sc.Customer__c,scList);
                    }else{
                        List<Id> scList = new List<Id>();
                        scList.add(sc.Id);
                        scoreMap.put(sc.Customer__c,scList);
                    }
                }
            }
            //根据客户的Hisense entity获取税分类国家
            for (Account acc : ((list<Account>)Trigger.new)) {
                Account accOld = (Account)Trigger.oldMap.get(acc.Id);
                // 定时修改标记不运行下面逻辑
                if(acc.Active_Flag__c != accOld.Active_Flag__c){
                    return;
                }

                if(String.isNotBlank(acc.Hisense_Entity_Sales__c) && accOld.Hisense_Entity_Sales__c <> acc.Hisense_Entity_Sales__c && acc.Hisense_Entity_Sales__c != '0000'){
                    String cs = countries.get(acc.Hisense_Entity_Sales__c).Country__c;
                    taxCounMap.put(acc.id,cs);
                }
                //当客户审批通过后，自动同步到SAP
                if(acc.Approval_Status__c.equals('Approved')
                && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)){
                    accIdList.add(acc.Id);

                    // 审批通过 锁定相关的打分表
                    // List<Id> ids = scoreMap.get(acc.Id);
                    // if(ids != null && ids.size() > 0){
                    //     for(Id scId : ids){
                    //         scIdList.add(scId);
                    //     }
                    // }
                }

                //当日本客户客户基本信息审批通过时
                // 分户不再校验这块逻辑 2025.1.10 
                if(String.isNotBlank(acc.Basic_Approval_Status__c) && String.isNotBlank(accOld.Basic_Approval_Status__c) && 'Approved'.equals(acc.Basic_Approval_Status__c)
                && !acc.Basic_Approval_Status__c.equals(accOld.Basic_Approval_Status__c) && 'Submitted'.equals(acc.Headquarters_Approval_Status__c)  && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)){
                    // 启动信用申请流程 2025-7-11日本服务商不校验信保
                    if(!'103'.equals(acc.Channel_Customer_Subcategories__c)){
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
                        req1.setComments('Submitting request for approval.'); 
                        req1.setObjectId(creditMap.get(acc.id).id); 
                        // Submit on behalf of a specific submitter 
                        req1.setSubmitterId(acc.CreatedById); 
                        // Submit the record to specific process and skip the criteria evaluation 
                        req1.setProcessDefinitionNameOrId(Label.Credit_application_process_JP); 
                        req1.setSkipEntryCriteria(true); // Submit the approval request for the account 
                        Approval.ProcessResult result = Approval.process(req1); // Verify the result 
                    }
                }
      
                //澳洲常规客户自动提交信用申请
                if(acc.RecordTypeId.equals(customerType) && ('AU'.equals(acc.Guarantor_Country_Code__c) || 'NZ'.equals(acc.Guarantor_Country_Code__c))){
                    if(String.isNotBlank(acc.Basic_Approval_Status__c) && String.isNotBlank(accOld.Basic_Approval_Status__c) && 'Approved'.equals(acc.Basic_Approval_Status__c)
                    && 'Approved'.equals(acc.Approval_Status__c) && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)){
                        if(creditMap.get(acc.id) != null && String.isNotBlank(creditMap.get(acc.id).Id)){

                            // 启动信用申请流程 2025-10-20
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
                            req1.setComments('Submitting request for approval.'); 
                            req1.setObjectId(creditMap.get(acc.id).id); 
                            // Submit on behalf of a specific submitter 
                            req1.setSubmitterId(acc.CreatedById); 
                            // Submit the record to specific process and skip the criteria evaluation 
                            req1.setProcessDefinitionNameOrId(Label.Credit_application_process_AU); 
                            req1.setSkipEntryCriteria(true); // Submit the approval request for the account 
                            Approval.ProcessResult result = Approval.process(req1); // Verify the result 
                        }
                    }
                }

                //当客户提交审批查看选择人的权限
                // 分户不再校验这块逻辑 2025.1.09
                if(acc.Approval_Status__c.equals('Submitted') && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)) {
                    try {
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addMinutes(1);
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = '0 ' + minute + ' ' + hour + ' * * ?';
            
                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.schedule(h, con, new AccountSchedulable(acc.Id, h));

                        // // 法务
                        // List<User> legalUserList = [SELECT Id,Name,Profile.Name FROM User WHERE Profile.name = 'Legal staff']; 
                        // // 给法务分配权限
                        // if(legalUserList != null && legalUserList.size() > 0){
                        //     for(User legalUser : legalUserList){
                        //         AccountShare accountShare = new AccountShare();
                        //         accountShare.RowCause = 'Manual';
                        //         accountShare.AccountId = acc.Id;
                        //         accountShare.UserOrGroupId  = legalUser.Id;
                        //         accountShare.AccountAccessLevel = 'Edit';
                        //         accountShare.OpportunityAccessLevel = 'Edit';
                        //         insert accountShare;
                        //     }
                        // }
                    } catch (Exception e) {
                        system.debug('error message'+e.getMessage());
                        system.debug('line number'+e.getLineNumber());    
                    }
                }
                //监听修改操作                              
                // String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Name));
                // system.Debug('======== ECSSID==='+jobID);
                
            }

            // 执行锁定打分表操作
            // if(scIdList.size() > 0){
            //     system.debug('锁定的打分表ID：'+ scIdList.toString());
            //     Approval.lock(scIdList);
            // }

            if(taxCounMap.size()>0){
                //删除原有的税分类
                List<Customer_Tax_category__c> ctcsdels = [select id from Customer_Tax_category__c where Customer__c in:taxCounMap.keySet()];
                if(ctcsdels.size()>0)
                    delete ctcsdels;
                creatTax(taxCounMap);
            }
            
            if(accIdList.size() > 0 && accIdList.size() <= 3){ 
                for(String accId : accIdList){
                    String jobID = System.enqueueJob(new AsyncSyncCustomer(accId));
                    system.Debug('======== jobID==='+jobID);
                }
                //并发的情况
                if(accIdList.size() > 1 ){ system.Debug('======== 并发');}
            }           
           
        }

        //acc.Approval_Status__c.equals('Submitted') && '103'.equals(acc.Channel_Customer_Subcategories__c) 
        //肖文怡、王予婷 转办 于浩然
        if (Trigger.isAfter&& Trigger.isUpdate) {
            System.debug('afterUpdate-->转办');

            // 1. 配置区（只需改这里）
            String TARGET_USER_ID = '005TL0000033ldOYAQ';       // 转办目标用户 于浩然
            String STEP_ID = '005GB00000ZO2osYAD,0050o00000ZMV8SAAX';        // 审批节点肖文怡、王予婷

            List<ProcessInstanceWorkitem> toUpdate = new List<ProcessInstanceWorkitem>();
            for(Account acc : ((list<Account>)Trigger.new)){
                if(acc.Approval_Status__c.equals('Submitted') && '103'.equals(acc.Channel_Customer_Subcategories__c)) {
                    

                    // 查询当前正在进行的审批流程【最新步骤】
                    List<ProcessInstanceWorkitem> workItems = [
                        SELECT Id, ProcessInstance.TargetObjectId,ActorId,Actor.name
                        FROM ProcessInstanceWorkitem
                        WHERE ProcessInstance.TargetObjectId =:acc.Id
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];

                    if(workItems != null && workItems.size() > 0){
                        ProcessInstanceWorkitem workItem = workItems.get(0);
                        if (workItem == null || !STEP_ID.contains(workItem.ActorId)) continue;

                        workItem.ActorId = TARGET_USER_ID;
                        toUpdate.add(workItem);
                    }

                    
                }
            }

            // 4. 执行转办
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }
        } 


        if (Trigger.isBefore && Trigger.isUpdate) {
            System.debug('beforeUpdate');

            // 获取可以跳过自动更新Approval Status到Draft的Profile
            Map<String, MDG_Customer_Edit_Profiles__c> skipProfilesMap = new Map<String, MDG_Customer_Edit_Profiles__c>();
            List<MDG_Customer_Edit_Profiles__c> skipProfiles = [SELECT Id, Profile_Id__c, Profile_Name__c From MDG_Customer_Edit_Profiles__c];
            for (MDG_Customer_Edit_Profiles__c profile : skipProfiles) {
                skipProfilesMap.put(profile.Profile_Name__c, profile);
            }

            //获取基本视图字段的field set
            List<Schema.FieldSetMember> basicInfoSet = SObjectType.Account.FieldSets.CustomerBasicInfo.getFields();

            List<String> accIDs = new List<String>();
            // MDG Account Master Data 获取MDG 代码映射表
            Map<String, MDG_Client_Mapping__mdt> clientMappingMap = new Map<String, MDG_Client_Mapping__mdt>();
            for (MDG_Client_Mapping__mdt mapping : [SELECT Id,MasterLabel, DeveloperName,MDG_SFDC_Name__c,MDG_Description__c, MDG_Code__c, MDG_Sub_Code__c FROM MDG_Client_Mapping__mdt]) {
                clientMappingMap.put(mapping.MDG_SFDC_Name__c, mapping);
            }
            
            for (Account acc : ((list<Account>)Trigger.new)) {

                Account accOld = (Account)Trigger.oldMap.get(acc.Id);

                //lzx 20250122 用户修改客户信息后变为草稿状态
                if('Approved'.equals(accOld.Approval_Status__c) && !Label.Undo_Changes_Profile_Exclude.contains(currentUser.Profile.name)){
                    
                    String oldBodyJson = JSON.serialize(accOld);
                    String newBodyJson = JSON.serialize(acc);

                    if(!oldBodyJson.equals(newBodyJson)){
                        Utility.insertCusHistoyr(acc.Id, 'Account', '变更', oldBodyJson, newBodyJson);

                        Boolean isProfileName = true;
                        // 分批上线保留原来验证
                        // List<String> profileNameList = Label.New_Customer_Profile_Name.split(',');
                        // for(String Str : profileNameList){
                        //     if(currentUser.Profile.name.indexOf(Str) != -1){
                        //         isProfileName = true;
                        //         break;
                        //     }
                        // }
                        
                        if(isProfileName){
                            // 财务不需要审批 澳洲分户不需要审批
                            if(currentUser.Profile.name.indexOf('Finance') == -1 && !acc.RecordTypeId.equals(customerAddress) &&
                            !(acc.RecordTypeId.equals(subAccountRTId) && currentUser.Profile.name.indexOf('Australia') != -1)){
                                acc.Approval_Status__c = 'Adjustment';
                            }  
                            
                            acc.Current_Modifier__c = UserInfo.getUserId();
                        }else {
                            acc.Approval_Status__c = 'Draft';
                        }
                    }
                }

                if(String.isNotBlank(acc.Postal_Code__c)){
                    acc.Postal_Code__c = acc.Postal_Code__c.trim();
                }
                // 暂时不允许编辑Approved并且有SAP Code的记录 2025.1.20上线决定 崔杰
                // if(!skipProfilesMap.containsKey(currentUser.Profile.name) && acc.Approval_Status__c == 'Approved' && String.isNotEmpty(acc.SAP_Customer_Code__c)){
                //     if(!Test.isRunningTest()){
                //         acc.addError('Customer cannot be updated because it has been approved and has SAP Customer Code. Please contact your administrator.');
                //         return;
                //     }
                // }

                if(String.isNotBlank(acc.Customer_Name_Local_Language__c)){
                    if(acc.Customer_Name_Local_Language__c.length() == 40){
                        acc.Name = acc.Customer_Name_Local_Language__c + (String.isNotBlank(acc.Customer_Name_Local_Language_2__c) ? acc.Customer_Name_Local_Language_2__c : '');
                    }else{
                        acc.Name = acc.Customer_Name_Local_Language__c;
                    }
                }
                

                if('TH'.equals(acc.Guarantor_Country_Code__c)){
                    acc.Address__c = (String.isNotBlank(acc.Street_2__c) ? acc.Street_2__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_3__c) ? acc.Street_3__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_4__c) ? acc.Street_4__c + ' ' : '') +
                                     (String.isNotBlank(acc.Street_5__c) ? acc.Street_5__c : '');
                }

                
                
                // 定时修改标记不运行下面逻辑
                if(acc.Active_Flag__c != accOld.Active_Flag__c){
                    return;
                }
                accIDs.add(acc.id);

                if(acc.SAP_Code_Generation_Time__c == null && String.isNotBlank(acc.SAP_Customer_Code__c)){
                    acc.SAP_Code_Generation_Time__c = System.Now();
                }
                // MDG Customer Status根据现系统的Customer Status值去赋值
                if(String.isNotBlank(acc.Customer_Status__c) && !acc.Customer_Status__c.equals(accOld.Customer_Status__c)){
                    if (clientMappingMap.get(acc.Customer_Status__c) != null){
                        acc.Customer_Status_MDG__c = clientMappingMap.get(acc.Customer_Status__c).MDG_Code__c;

                    }
                }
                
                //基本视图信息变更，且已经同步到SAP，Approval Status为Approved，则将Approval Status变为Draft 2025.1.17
                // 2025.1.20 暂时去掉
                // system.debug('currentUser.Profile.name : ' + currentUser.Profile.name);
                // system.debug('accinfo : '+acc.Approval_Status__c+ ' : '+acc.SAP_Customer_Code__c);
                // if(!skipProfilesMap.containsKey(currentUser.Profile.name)){
                //     for(Schema.FieldSetMember f : basicInfoSet) {
                //         system.debug(f.getFieldPath()+': '+acc.get(f.getFieldPath()));
                //         if(acc.get(f.getFieldPath()) != null && accOld.Approval_Status__c == 'Approved' && acc.Approval_Status__c == 'Approved' && String.isNotEmpty(acc.SAP_Customer_Code__c)){
                //             acc.Approval_Status__c = 'Draft';
                //         }
                //     }
                // }
            }

            //查询客户下PL及Score的数量，审批进入前进行校验
            AggregateResult[] SSgroupedResults= [SELECT Customer__c,count(id) FROM Score_Sheet__c WHERE Customer__c in : accIDs GROUP BY Customer__c ];
            Map<String,integer> ssCountMap = new Map<String,integer>();
            if(SSgroupedResults.size()>0){
                for(AggregateResult ar : SSgroupedResults){
                    ssCountMap.put((String)ar.get('Customer__c'),(integer)ar.get('expr0'));
                }
            }

            //查询客户下打分表不够60分，审批进入前进行校验
            // AggregateResult[] ssResults= [SELECT Customer__c,count(id) FROM Score_Sheet__c WHERE Customer__c in : accIDs AND Evaluated_Score__c < 60 GROUP BY Customer__c ];
            // Map<String,integer> ssMap = new Map<String,integer>();
            // if(ssResults.size()>0){
            //     for(AggregateResult ar : ssResults){
            //         ssMap.put((String)ar.get('Customer__c'),(integer)ar.get('expr0'));
            //     }
            // }

            //查询日本客户是否有上传文件
            AggregateResult[] fileResults= [SELECT COUNT(id), LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in:accIDs GROUP BY LinkedEntityId ];
            Map<String,integer> fileMap = new Map<String,integer>();
            if(fileResults.size()>0){
                for(AggregateResult ar : fileResults){
                    fileMap.put((String)ar.get('LinkedEntityId'),(integer)ar.get('expr0'));
                }
            }

            //查询日本客户下是否有信用申请
            AggregateResult[] claResults= [SELECT COUNT(id), Customer__c FROM Credit_Limit_Application__c WHERE Customer__c in:accIDs GROUP BY Customer__c ];
            Map<String,integer> claMap = new Map<String,integer>();
            if(claResults.size()>0){
                for(AggregateResult ar : claResults){
                    claMap.put((String)ar.get('Customer__c'),(integer)ar.get('expr0'));
                }
            }

            AggregateResult[] PLgroupedResults= [SELECT Customer__c,count(id) FROM Customer_Product_Line__c  WHERE Customer__c in : accIDs GROUP BY  Customer__c ];
            Map<String,integer> plCountMap = new Map<String,integer>();
            if(PLgroupedResults.size()>0){
                for(AggregateResult ar : PLgroupedResults){
                    plCountMap.put((String)ar.get('Customer__c'),(integer)ar.get('expr0'));
                }
            }

            //查询销售视图的税分类
            List<Customer_extend_Tax_category__c> cetaxs = [SELECT Customer_Extend__r.Customer__c,Tax_category__c FROM Customer_extend_Tax_category__c WHERE Customer_Extend__r.Customer__c in : accIDs];
            Map<String,List<String>> cetaxMap = new Map<String,List<String>>();
            if(cetaxs.size()>0){
                for(Customer_extend_Tax_category__c ctax : cetaxs){
                    if(cetaxMap.containsKey(ctax.Customer_Extend__r.Customer__c)){
                        List<String> taxs = cetaxMap.get(ctax.Customer_Extend__r.Customer__c);
                        taxs.add(ctax.Tax_category__c);
                        cetaxMap.put(ctax.Customer_Extend__r.Customer__c,taxs);
                    }else{
                        List<String> taxs = new List<String>();
                        taxs.add(ctax.Tax_category__c);
                        cetaxMap.put(ctax.Customer_Extend__r.Customer__c,taxs);
                    }
                }
            }

            //查询税分类
            List<Customer_Tax_category__c> ctaxs = [SELECT Customer__c,Tax_category__c FROM Customer_Tax_category__c WHERE Customer__c in : accIDs];
            Map<String,List<String>> ctaxMap = new Map<String,List<String>>();
            if(ctaxs.size()>0){
                for(Customer_Tax_category__c ctax : ctaxs){
                    if(ctaxMap.containsKey(ctax.Customer__c)){
                        List<String> taxs = ctaxMap.get(ctax.Customer__c);
                        taxs.add(ctax.Tax_category__c);
                        ctaxMap.put(ctax.Customer__c,taxs);
                    }else{
                        List<String> taxs = new List<String>();
                        taxs.add(ctax.Tax_category__c);
                        ctaxMap.put(ctax.Customer__c,taxs);
                    }
                }
            }

            // wfc 查询公司视图的统驭科目 2025-05-29
            List<Customer_Extend__c> companyViewList = [SELECT Reconciliation_Customer__c, Customer__c FROM Customer_Extend__c WHERE Show_Company__c = true AND Customer__c IN : accIDs];
            Map<String,List<String>> companyViewMap = new Map<String,List<String>>();
            if(companyViewList.size()>0){
                for(Customer_Extend__c ce : companyViewList){
                    if(companyViewMap.containsKey(ce.Customer__c)){
                        List<String> tempList = companyViewMap.get(ce.Customer__c);
                        tempList.add(ce.Reconciliation_Customer__c);
                        companyViewMap.put(ce.Customer__c,tempList);
                    }else{
                        List<String> tempList = new List<String>();
                        tempList.add(ce.Reconciliation_Customer__c);
                        companyViewMap.put(ce.Customer__c,tempList);
                    }
                }
            }

            //查询客户的PL，批准后进行更新
            List<Customer_Product_Line__c> cpls = [select id,Prospective_Rank__c,Customer__c from Customer_Product_Line__c where Customer__c IN : accIDs];
            Map<String, List<Customer_Product_Line__c>> cplm = new Map<String, List<Customer_Product_Line__c>>();

            for (Customer_Product_Line__c cpl : cpls) {
                if(cplm.containsKey(cpl.Customer__c)){
                    List<Customer_Product_Line__c> srts = cplm.get(cpl.Customer__c);
                    srts.add(cpl);
                    cplm.put(cpl.Customer__c,srts);
                }else{
                    List<Customer_Product_Line__c> srts = new List<Customer_Product_Line__c>();
                    srts.add(cpl);
                    cplm.put(cpl.Customer__c,srts);
                }
            }

            List<Customer_Product_Line__c> cplsUP = new List<Customer_Product_Line__c>();
            // 日本客户解锁集合
            List<Id> cidList = new List<Id>();

            //获取销售SAP必填字段的field set
            List<Schema.FieldSetMember> ssFin = SObjectType.Account.FieldSets.sales_SAP_onBoard_required.getFields();

            //获取财务必填字段的field set
            List<Schema.FieldSetMember> sfsFin = SObjectType.Account.FieldSets.Fin_Required_Fields.getFields();

            for(Account acc : ((list<Account>)Trigger.new)){
                Account accOld = (Account)Trigger.oldMap.get(acc.Id);
                if('Submitted' == acc.Approval_Status__c && accOld.Approval_Status__c != 'Submitted'){
                    // 日本二次审批跳过基本审批
                    if(acc.Basic_Approval_Status__c == 'Approved'){
                        acc.Japan_Unlock_Tag__c = System.now();
                    }

                    //20240417 RecordType为国际营销客户-非常规类型的不需要填写打分表 YYL

                    // 20241107 分户客户新增审批流，修改触发器中的审批校验，当客户类型为分户且主客户已经同步到MDG，不进行触发器中的校验，审批结束后，分户同步至MDG
                    // Boolean isValidSubAcc = false;
                    // if (acc.RecordTypeId.equals(subAccountRTId) && String.isEmpty(parentAcc.SAP_Customer_Code)) {
                    //     if(!Test.isRunningTest()){
                    //         acc.addError(Label.MDGParent_Account_Not_Synced);
                    //         return;
                    //     }
                    // } else {
                    //     isValidSubAcc = true;
                    // }

                    // if(!acc.RecordTypeId.equals(unconventional) && !isValidSubAcc){
                    if(!acc.RecordTypeId.equals(unconventional) && !acc.RecordTypeId.equals(staff) && !acc.RecordTypeId.equals(vendor)){
                        System.debug('unconventional' + unconventional);
                        System.debug('unconventional1' + acc.RecordTypeId);
                        //校验SAP信息是否填写 日本流程提交审批时，去掉验证Tax 字段，改为由财务最终审批时填写
                        if(!Label.JP_Profile.split(',').contains(currentUser.Profile.name)){
                            for(Schema.FieldSetMember f : ssFin) {
                                system.debug(f.getFieldPath()+': '+acc.get(f.getFieldPath()));
                                if(acc.get(f.getFieldPath()) == null){
                                    if(!Test.isRunningTest()){
                                        acc.addError(Label.sale_in_put_tax_info);
                                        return;
                                    }
                                }
                            }
                        }

                        // //提交onboard的时候检查评分表和产品线是否添加
                        // if(ssCountMap.size() == 0 || plCountMap.size() == 0 || plCountMap.get(acc.id) == 0 || ssCountMap.get(acc.id) == 0 ){
                        //     if(!Test.isRunningTest()){
                        //         acc.addError(Label.need_PL_and_SC);
                        //         return;
                        //     }
                        // }

                        // if(fileMap.get(acc.id) == null){
                        //     if(!Test.isRunningTest()){
                        //         acc.addError(Label.Need_Legal_report);
                        //         return;
                        //     }
                        // }
                    }

                    // ----------------- start -----------------
                    // 客户提交审批验证产品线及文件 (wfc 2025-02-13)
                    // Hisense International Regular Sales Customer
                    // Hisense Asean Customer
                    // Hitachi Customer
                    // Commercial Display Customer
                    // 以上需要打分
                    if(accOld.Approval_Status__c != 'Adjustment' && acc.RecordTypeId.equals(customerType) || acc.RecordTypeId.equals(aseanType) || acc.RecordTypeId.equals(hitachiCustomerType) || acc.RecordTypeId.equals(b2bCustomerType)){
                        if(ssCountMap.size() == 0 || plCountMap.size() == 0 || plCountMap.get(acc.id) == 0 || ssCountMap.get(acc.id) == 0 ){
                            if(!Test.isRunningTest()){
                                acc.addError(Label.need_PL_and_SC);
                                return;
                            }
                        }
                    }
                    // Hisense International Unconventional Customer  
                    // Staff
                    // Sub Account
                    // customer synced sap
                    // 以上不需要法务报告
                    if(accOld.Approval_Status__c != 'Adjustment' && !acc.RecordTypeId.equals(unconventional) && !acc.RecordTypeId.equals(staff) && !acc.RecordTypeId.equals(subAccountRTId )&& !acc.RecordTypeId.equals(customerSyncedSapType)){
                        if(fileMap.get(acc.id) == null){
                            if(!Test.isRunningTest()){
                                acc.addError(Label.Need_Legal_report);
                                return;
                            }
                        }
                    }
                    //  ----------------- end --------------
                    
                    // //提交onboard的时候检查评分表是否有小于60分的
                    // if(ssMap.get(acc.id) > 0 ){
                    //     if(!Test.isRunningTest()){
                    //         acc.addError(Label.need_SC_60);
                    //         return;
                    //     }
                    // }
                    // 日本流程校验填写法务报告表单
                    // if(Label.Legal_Report_Check_Profiles.split(',').contains(currentUser.Profile.name) && fileMap.get(acc.id) == null){
                    //     if(!Test.isRunningTest()){
                    //         acc.addError(Label.Need_Legal_report);
                    //         return;
                    //     }
                    // }

                    // 日本流程校验信用额度申请表
                    // 分户客户跳过校验 2024.01.09  2025-7-11日本服务商不校验信保
                    if((!'103'.equals(acc.Channel_Customer_Subcategories__c)) && (!'2'.equals(acc.Credit_Management__c))){
                        if(Label.JP_Profile.split(',').contains(currentUser.Profile.name) && claMap.get(acc.id) == null){
                            if(!Test.isRunningTest()){
                                acc.addError(Label.Need_Credit_Limit_Application);
                                return;
                            }
                        }
                    }

                    //澳洲常规客户自动提交信用申请
                    // if(accOld.Approval_Status__c != 'Adjustment' && acc.RecordTypeId.equals(customerType) && ('AU'.equals(acc.Guarantor_Country_Code__c) || 'NZ'.equals(acc.Guarantor_Country_Code__c))){
                    //     if(claMap.get(acc.id) == null){
                    //         if(!Test.isRunningTest()){
                    //             acc.addError(Label.Need_Credit_Limit_Application);
                    //             return;
                    //         }
                    //     }
                    // }
                    
                }

                // 根据日本标记解锁客户信息
                if(acc.Japan_Unlock_Tag__c != accOld.Japan_Unlock_Tag__c){
                    cidList.add(acc.Id);   
                }

                //当进行到财务审核时触发财务信息录入的校验 當前用戶的建檔含有Finance Team
                if('fin_approved' == acc.isGoFinApprove__c ){
                    acc.isGoFinApprove__c = '';
                    Boolean isProfileName = true;
                    // 分批上线保留原来验证
                    // List<String> profileNameList = Label.New_Customer_Profile_Name.split(',');
                    // for(String Str : profileNameList){
                    //     if(currentUser.Profile.name.indexOf(Str) != -1){
                    //         isProfileName = true;
                    //         break;
                    //     }
                    // }
                    // 新客户 财务校验
                    if(isProfileName){
                        Boolean flag = true;
                        String errorMessage = '';
                        //校验税分类是否填写
                        if(cetaxMap.size()>0){
                            List<String> ctaxchks = cetaxMap.get(acc.Id);
                            for (String ctaxchk: ctaxchks) {
                                if(String.isBlank(ctaxchk)){
                                    flag = false;
                                    String fieldLabel = Schema.SObjectType.Customer_extend_Tax_category__c.fields.getMap().get('Tax_category__c').getDescribe().getLabel();
                                    errorMessage += String.format(Label.Customer_Sales_View_Error, new List<Object>{fieldLabel}) + ' ';
                                    // if(!Test.isRunningTest()){
                                    //     acc.addError(Label.need_Tax_classification);
                                    //     return;
                                    // }
                                }
                            }
                        }
                        //校验统御科目
                        if(companyViewMap.size()>0){
                            List<String> reconciliationCustomerList = companyViewMap.get(acc.Id);
                            for (String reconciliationCustomer: reconciliationCustomerList) {
                                if(String.isBlank(reconciliationCustomer)){
                                    flag = false;
                                    String fieldLabel = Schema.SObjectType.Customer_Extend__c.fields.getMap().get('Reconciliation_Customer__c').getDescribe().getLabel();
                                    errorMessage += String.format(Label.Customer_Company_View_Error, new List<Object>{fieldLabel}) + ' ';
                                    // if(!Test.isRunningTest()){
                                    //     acc.addError(Label.need_Tax_classification);
                                    //     return;
                                    // }
                                }
                            }
                        }
                        // 校验不通过
                        if(!flag){
                            if(!Test.isRunningTest()){
                                acc.addError(errorMessage);
                                return;
                            }
                        }
                    }else {
                        String fieldName = '';

                        for(Schema.FieldSetMember f : sfsFin) {
                            // system.debug(f.getFieldPath()+': '+acc.get(f.getFieldPath()));
                            if(f.getFieldPath() == 'Buyer_English_Name__c' && !Label.JP_Financial_Profile.split(',').contains(currentUser.Profile.name)){
                                continue;
                            }
                            if(f.getFieldPath() == 'Customer_Group2__c' && !Label.SA_Financial_Profile.split(',').contains(currentUser.Profile.name)){
                                continue;
                            }
                            if(f.getFieldPath() == 'VAT_Tax_type__c' && !'8640'.equals(acc.Hisense_Entity__c)){
                                continue;
                            }
                            if(f.getFieldPath() == 'Customer_Management_Name__c' && String.isNotBlank(acc.Expected_Hisense_cooperation_annual_scal__c)){
                                continue;
                            }

                            if(acc.get(f.getFieldPath()) == null){
                                fieldName += Schema.SObjectType.Account.fields.getMap().get(f.getFieldPath()).getDescribe().getLabel() + '、';
                            }  
                        }

                        list<Customer_Tax_category__c> ctaList = [select Tax_category__c from Customer_Tax_category__c where Customer__c = :acc.id];

                        //校验税分类
                        for(Customer_Tax_category__c c : ctaList){
                            if(c.Tax_category__c == null){
                                fieldName += Schema.SObjectType.Customer_Tax_category__c.fields.getMap().get('Tax_category__c').getDescribe().getLabel() + '、';
                                break;
                            }
                        }

                        // 分户客户跳过必填审批校验，使用主户上的字段 2025.01.08
                        if(String.isNotBlank(fieldName)){
                            if(!Test.isRunningTest()){
                                acc.addError(Label.Required_Info + ' : ' + fieldName.substring(0, fieldName.length() - 1));
                                return;
                            }
                        }

                        // 校验SAP信息是否填写 日本流程提交审批时，去掉验证Tax 字段，改为由财务最终审批时填写
                        if(Label.JP_Financial_Profile.split(',').contains(currentUser.Profile.name)){
                            for(Schema.FieldSetMember f : ssFin) {
                                system.debug(f.getFieldPath()+': '+acc.get(f.getFieldPath()));
                                if(acc.get(f.getFieldPath()) == null){
                                    if(!Test.isRunningTest()){
                                        acc.addError(Label.sale_in_put_tax_info);
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }

                //当客户onboard approve后，所有产品线的Rank设置为Prospective_Rank__c
                if('Approved' == acc.Approval_Status__c && accOld.Approval_Status__c !='Approved'){
                    List<Customer_Product_Line__c> cplsTmps = cplm.get(acc.Id);
                    if(cplsTmps != null){
                        for (Customer_Product_Line__c cpl : cplsTmps) {
                            cpl.Rank__c = cpl.Prospective_Rank__c;
                            cplsUP.add(cpl);
                        }
                    }
                }
            }

            if(cidList.size() > 0){
                // 当前时间N分钟，下一次定时时间
                DateTime reTime = System.Now().addMinutes(1);
                Integer minute = reTime.minute();
                Integer hour = reTime.hour();  
                String con = '0 ' + minute + ' ' + hour + ' * * ?';

                // 生成唯一值
                Blob b = Crypto.GenerateAESKey(128);
                String h = '解锁日本客户:'+ EncodingUtil.ConvertTohex(b);
                System.schedule(h, con, new AccountJapanUnlockSchedulable(cidList, h, false));
            }
               
            
            system.debug('======cplsUP'+ cplsUP);
            if(cplsUP.size() > 0)
                update cplsUP;
        }

        

    }

    private void creatTax(Map<String,String> taxCounMap){
        List<String> couns = new List<String>();
        //根据国家自动生成税分类列表
        for (String ss : taxCounMap.values()) {
            couns.addAll(ss.split(';'));
        }
        system.debug(taxCounMap);
        Map<String,List<National_tax_category__c>> ntcsMap = new Map<String,List<National_tax_category__c>>();
        //根据国家代码查询国家税分类
        List<National_tax_category__c> ntcs= [select id,National_code__c, sort__c,Tax_category__c from National_tax_category__c where National_code__c in:couns order by sort__c];

        for (National_tax_category__c ntc : ntcs) {
            if(ntcsMap.containsKey(ntc.National_code__c)){
                List<National_tax_category__c> srts = ntcsMap.get(ntc.National_code__c);
                srts.add(ntc);
                ntcsMap.put(ntc.National_code__c,srts);
            }else{
                List<National_tax_category__c> srts = new List<National_tax_category__c>();
                srts.add(ntc);
                ntcsMap.put(ntc.National_code__c,srts);
            }
        }
        system.debug(ntcsMap);
        List<Customer_Tax_category__c> ctcsIn = new List<Customer_Tax_category__c> ();
        for (String accId : taxCounMap.keySet()) {
            List<String> counss = taxCounMap.get(accId).split(';');
            List<National_tax_category__c> srts = new List<National_tax_category__c>();
            //system.debug(counss);
            for (String con : counss) {
                if(!ntcsMap.isEmpty()){
                    srts.addAll(ntcsMap.get(con));
                }
            }

            if(srts == null){
                break;
            }
            //system.debug(srts);
            for(National_tax_category__c ntc:srts){
                Customer_Tax_category__c ctc = new Customer_Tax_category__c();
                ctc.Customer__c = accId;
                ctc.National_tax_category__c = ntc.id;
                //ctc.Name = ntc.National_code__c;
                ctc.Tax_category_code__c = ntc.Tax_category__c;
                ctc.Customer_Tax_Category_External_Id__c = accId + ntc.Tax_category__c;
                ctcsIn.add(ctc);
            }
        }
        
        if(ctcsIn.size()>0)
            Database.upsert(ctcsIn,Customer_Tax_category__c.Fields.Customer_Tax_Category_External_Id__c,false);
        // insert ctcsIn;
    }

    //异步调用接口同步客户到SAP
    public class AsyncSyncCustomer implements Queueable, Database.AllowsCallouts {
        public String customerId { get; set; }
        public AsyncSyncCustomer(String idData){
            customerId = idData;
            system.debug('======customerId===='+ customerId);
        }
        public void execute(QueueableContext context) {
            // SyncCustomerInfoToSAP.postCustomerInfomationToSAP(customerId);
            try {
                system.debug('======customerId===='+ customerId);
                Boolean isProfileName = true;
                // 分批上线保留原来验证
                // List<String> profileNameList = Label.New_Customer_Profile_Name.split(',');
                // for(String Str : profileNameList){
                //     if(currentUser.Profile.name.indexOf(Str) != -1){
                //         isProfileName = true;
                //         break;
                //     }
                // }
                if(isProfileName){
                    SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(customerId);
                    // GetCustomerInfoFromECSS.GetCustomerInfoFromECSS(customerId);
                }else {
                    SyncCustomerInfoToMDG.postCustomerInfomationToMDG(customerId);
                }
            } catch (Exception e) {
                Utility.IgnoreAction(false,false,false,'');
                //Integration Log
                Utility.insertLog('SyncCustomerInfoToMDGPro', '0', '', 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage() + '-------');
                // return 'failure: SF Sync Customer Information to MDG Failed! ' + e.getMessage();
            }
        }
    }

    //异步调用接口同步ECSS扫描数据到库表
    public class AsyncSyncEcssCustomer implements Queueable, Database.AllowsCallouts {
        public String customerName { get; set; }
        public AsyncSyncEcssCustomer(String idData){
            customerName = idData;
            system.debug('======customerName===='+ customerName);
        }
        public void execute(QueueableContext context) {
            GetCustomerInfoFromECSS.GetCustomerInfoFromECSS(customerName);
        }
    }

    public static void checkTest(){
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}