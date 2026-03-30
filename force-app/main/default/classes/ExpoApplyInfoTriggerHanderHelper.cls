public without sharing class ExpoApplyInfoTriggerHanderHelper {
    private final static String EXHIBITION_SITE_API_USERNAME = System.Label.EXHIBITION_SITE_API_USERNAME;
    //用户区组负责人多选下拉列表为空的情况下赋值方便进行业务判断
    private final static String ALL_COND = 'ALL全部';

    /**
     * @description 重复创建检测
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void duplicateCheck(List<ExpoApplyInfo__c> newList, List<ExpoApplyInfo__c> oldList){
    	Set<String> expoIdSet = new Set<String>();
    	Set<String> firstNameENSet = new Set<String>();
    	Set<String> firstNameCNSet = new Set<String>();
    	Set<String> lastNameENSet = new Set<String>();
    	Set<String> lastNameCNSet = new Set<String>();
    	Set<String> emailSet = new Set<String>();
        Set<String> telphoneSet = new Set<String>();
        Set<String> workTelSet = new Set<String>();

        Map<Id, ExpoApplyInfo__c> oldDataMap = new Map<Id, ExpoApplyInfo__c>(oldList);

        //国家英文-中文 Map
        Map<String,String> countryEntoCNMap = new Map<String, String>();
        Map<String,String> countryRegionMap = new Map<String, String>();
        Set<String> countryEnSet = new Set<String>(new LisqContainer(newList).SelectSField('CountryRegionEN__c'));
        Set<String> countryCnSet = new Set<String>(new LisqContainer(newList).SelectSField('CountryRegionCN__c'));
        if (countryEnSet.size() >0 || countryCnSet.size() > 0) {
            String soqlQuery  = 'SELECT Id, Name, NameEN__c,Region__c FROM ExpoCountrysBazaar__c WHERE ';
            String conditSoqlStr = '';
            if (! countryEnSet.isEmpty()) {
                conditSoqlStr += ' NameEN__c IN:countryEnSet ';
            }if (! countryCnSet.isEmpty()) {
                conditSoqlStr += (String.isNotBlank(conditSoqlStr) ? ' OR Name IN: countryCnSet' : ' Name IN: countryCnSet ');
            }
            soqlQuery+= conditSoqlStr;
            for (ExpoCountrysBazaar__c countryItem: Database.query(soqlQuery)) {
                countryEntoCNMap.put(countryItem.NameEN__c, countryItem.Name);
                countryRegionMap.put(countryItem.Name , countryItem.Region__c);
                        System.debug(' countryRegionList==>'+countryItem);

            }
        }
        System.debug(' countryRegionList==>'+countryRegionMap);
        System.debug(' countryRegionMap==>'+countryRegionMap);
    	for (ExpoApplyInfo__c expoItem: newList) {
            // Add By Ethan 20231015 增加国家匹配区域
            String countryRes = String.isNotBlank(expoItem.CountryRegionCN__c) ? expoItem.CountryRegionCN__c : 'Nothing!';
            countryRes =  String.isNotBlank(expoItem.CountryRegionEN__c) ? countryEntoCNMap.get(expoItem.CountryRegionEN__c) : countryRes;
            System.debug('conntryRes==>'+countryRes);
            if(countryRegionMap.containsKey(countryRes)) {
                if (oldDataMap.isEmpty()) {//操作为新增
                    expoItem.Region__c = countryRegionMap.get(countryRes);
                }else{//操作为更新 且 国家字段有变更
                    if ((expoItem.CountryRegionCN__c != oldDataMap.get(expoItem.Id).CountryRegionCN__c) 
                        || (expoItem.CountryRegionEN__c != oldDataMap.get(expoItem.Id).CountryRegionEN__c) ) {
                        expoItem.Region__c = countryRegionMap.get(countryRes);
                    }
                }
            }
            // 20231016 不为空才加入 
    		if(String.isNotBlank(expoItem.ExpoId__c)) expoIdSet.add(expoItem.ExpoId__c);
    		if(String.isNotBlank(expoItem.FirstNameEN__c)) firstNameENSet.add(expoItem.FirstNameEN__c);
    		if(String.isNotBlank(expoItem.FirstNameCN__c)) firstNameCNSet.add(expoItem.FirstNameCN__c);
    		if(String.isNotBlank(expoItem.LastNameCN__c)) lastNameCNSet.add(expoItem.LastNameCN__c);
    		if(String.isNotBlank(expoItem.LastNameEN__c)) lastNameENSet.add(expoItem.LastNameEN__c);
    		if(String.isNotBlank(expoItem.Email__c)) emailSet.add(expoItem.Email__c);
            if(String.isNotBlank(expoItem.Telephone__c)) telphoneSet.add(expoItem.Telephone__c);
            if(String.isNotBlank(expoItem.WorkTel__c)) workTelSet.add(expoItem.WorkTel__c);
    	}

        //拼接soql
        String soqlStr = 'SELECT Id, ExpoId__c, FirstNameEN__c,FirstNameCN__c, LastNameCN__c, LastNameEN__c, Email__c,Telephone__c, WorkTel__c FROM ExpoApplyInfo__c WHERE ';
        soqlStr += ' ExpoId__c IN: expoIdSet AND ( ';
        String infoTri = '';
        String qHead = 'Createddate!=null';
        if (! emailSet.isEmpty() ) {
            qHead = 'Createddate = null';
            infoTri += ' OR Email__c IN: emailSet ';
        }if (! telphoneSet.isEmpty() ) {
            qHead = 'Createddate = null';
            infoTri += ' OR Telephone__c IN: telphoneSet ';
        }if (! workTelSet.isEmpty() ) {
            qHead = 'Createddate = null';
            infoTri += ' OR WorkTel__c IN: workTelSet ';
        }
        infoTri = qHead + infoTri;
        soqlStr = soqlStr+infoTri+') AND (';
        String nameInfoStr = '';
        qHead = 'Createddate!=null';
        if (! firstNameCNSet.isEmpty()) {
            qHead = 'Createddate=null';
            nameInfoStr += ' OR (FirstNameCN__c IN: firstNameCNSet AND LastNameCN__c IN: lastNameCNSet)';
        }if (! firstNameENSet.isEmpty()) {
            qHead = 'Createddate=null';
            nameInfoStr += ' OR (FirstNameEN__c IN:firstNameENSet AND LastNameEN__c IN: lastNameENSet)';
        }

        nameInfoStr = qHead + nameInfoStr;
        soqlStr = soqlStr+nameInfoStr+')';



        System.debug('Soql==>'+soqlStr);
        List<ExpoApplyInfo__c> existDataList = Database.query(soqlStr);
    	// List<ExpoApplyInfo__c> existDataList = [SELECT  
    	// 	Id, ExpoId__c, FirstNameEN__c,FirstNameCN__c, LastNameCN__c, LastNameEN__c, Email__c,Telephone__c, WorkTel__c
    	// 	FROM ExpoApplyInfo__c 
    	// 	WHERE ExpoId__c IN: expoIdSet AND (Email__c IN: emailSet  OR Telephone__c IN: telphoneSet OR WorkTel__c IN: workTelSet)
    	// 	AND (
    	// 		(FirstNameCN__c IN: firstNameCNSet AND LastNameCN__c IN: lastNameENSet) 
    	// 		OR (FirstNameEN__c IN:firstNameENSet AND LastNameEN__c IN: lastNameENSet) )];
    	if (existDataList.size() > 0) {
    	    for (ExpoApplyInfo__c expoItem: newList) {
    	    	for (ExpoApplyInfo__c expoCheckItem: existDataList) {
    	    		if (expoItem.Id != expoCheckItem.Id && expoItem.ExpoId__c == expoCheckItem.ExpoId__c
                        && ( (expoItem.Email__c != NULL && expoItem.Email__c == expoCheckItem.Email__c )
                            || (expoItem.Telephone__c !=NULL && expoItem.Telephone__c == expoCheckItem.Telephone__c)
                            || (expoItem.WorkTel__c != NULL && expoItem.WorkTel__c == expoCheckItem.WorkTel__c) )
    	    			&& ( (expoItem.FirstNameCN__c != NULL && expoItem.FirstNameCN__c == expoCheckItem.FirstNameCN__c && expoItem.LastNameCN__c == expoCheckItem.LastNameCN__c) 
    	    			    || (expoItem.FirstNameEN__c != NULL && expoItem.FirstNameEN__c == expoCheckItem.FirstNameEN__c && expoItem.LastNameEN__c == expoCheckItem.LastNameEN__c)	
    	    			)) {
    	    		    expoItem.addError('此展会下已存在该客户信息！');
    	    		}
    	    	}
    	    }

    	}
    }


    /**
     * @description 负责人分配
     * @param       newList     更改后数据
    */
    public static void initOwner(List<ExpoApplyInfo__c> newList) {
        //重开发： 通过 二级部门 国家+品牌偏好+产品找出满足 条件的区组负责人写入 Owner_User1__c中。
        // 二级部门未匹配则通过一级部门大区进行分配。

        //查询所有区组负责人 如果没有关联到用户则不查询出来
        List<Exhibition_Region_Owner__c> exhiRegOwnList = [SELECT Id, User__c,Email__c, Primary_Department__c, Secondary_Department__c,Counry__c, Brand__c, Product_Line__c 
            FROM Exhibition_Region_Owner__c WHERE User__c <> NULL];

        //产品偏好配置表全量查询做英文-中文 Map
        Map<String, String> proEntoCNMap = new Map<String, String>();
        for (ExpoProductPreference__c proItem: [SELECT Id, Name, ProductEN__c FROM ExpoProductPreference__c WHERE ProductEN__c<>NULL AND Name <> NULL]) {
            proEntoCNMap.put(proItem.ProductEN__c, proItem.Name);
        }

        //国家英文-中文 Map
        Map<String,String> countryEntoCNMap = new Map<String, String>();
        Set<String> countryEnSet = new Set<String>(new LisqContainer(newList).SelectSField('CountryRegionEN__c'));
        if (countryEnSet.size() >0) {
            for (ExpoCountrysBazaar__c countryItem: [SELECT Id, Name, NameEN__c FROM ExpoCountrysBazaar__c WHERE NameEN__c IN:countryEnSet]) {
                countryEntoCNMap.put(countryItem.NameEN__c, countryItem.Name);
            }
        }

        //双层循环 负责人分配
        //中文提报时，根据品牌偏好、产品偏好、国家进行过滤匹配
        for (ExpoApplyInfo__c exAppItem: newList) {

            resSetOwner(exAppItem);//重置负责人
            for (Exhibition_Region_Owner__c ownerItem: exhiRegOwnList) {
                //230920 增加逻辑判断 如果有品牌偏好则为前端提报，为其分配负责人
                if (exAppItem.BrandPreferenceCN__c != NULL || exAppItem.BrandPreferenceEN__c != NULL) {
                    //初始化为空的判断字段方便逻辑判断
                    String ownerPro = ownerItem.Product_Line__c == NULL ? ALL_COND : ownerItem.Product_Line__c;
                    String ownerCountry = ownerItem.Counry__c == NULL ? ALL_COND : ownerItem.Counry__c;
                    String ownerBrand = ownerItem.Brand__c == NULL ? ALL_COND : ownerItem.Brand__c;

                    Set<String> ownerProSet = new Set<String>(ownerPro.split(';'));
                    Set<String> ownerBrandSet = new Set<String>(ownerBrand.split(';'));

                    //有中文输入的情况按照中文统计,英文转换成中文
                    String appPro = '';
                    String appCountry = '';
                    // 初始化 品牌偏好 
                    String brandStrCn = exAppItem.BrandPreferenceCN__c == NULL ? '' : exAppItem.BrandPreferenceCN__c;
                    String brandStrEn = exAppItem.BrandPreferenceEN__c == NULL ? 'Not Found Brand' : exAppItem.BrandPreferenceEN__c;
                    String appBrand = brandStrCn == '' ? brandStrEn : brandStrCn;

                    if (String.isNotBlank(exAppItem.ProductInterestEN__c)) {//表示选择了英文提报，则国家也是英文提报的
                       for (String proStr: exAppItem.ProductInterestEN__c.split(';')) appPro += proEntoCNMap.get(proStr)+';';
                       appPro = appPro.removeEnd(';');
                       appCountry = String.isNotBlank(exAppItem.CountryRegionEN__c) ? countryEntoCNMap.get(exAppItem.CountryRegionEN__c) : 'Not Found Country';
                    }else{
                        appPro = exAppItem.ProductInterestCN__c == NULL ? 'Not Found Pro' : exAppItem.ProductInterestCN__c;
                        appCountry = exAppItem.CountryRegionCN__c == NULL ? 'Not Found Country' : exAppItem.CountryRegionCN__c;
                    }

                    if (
                        (ownerProSet.containsAll(appPro.split(';')) || ownerPro.equals(ALL_COND))  
                        && (ownerBrandSet.containsAll(appBrand.split(';'))|| ownerBrand.equals(ALL_COND))
                        && (ownerCountry.contains(appCountry)
                            ||(ownerCountry.equals(ALL_COND) && ownerItem.Primary_Department__c == exAppItem.Region__c) )
                        ) {
                        resSetOwner(exAppItem, ownerItem);
                        
                    }

                }
            }
        }
            
    }

    /**
     * @description 负责人分配 - 更新
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void isAllocated(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList){
        Map<Id, ExpoApplyInfo__c> oldDataMap = new Map<Id, ExpoApplyInfo__c>(oldList);
        List<ExpoApplyInfo__c> updateItemList = new List<ExpoApplyInfo__c>();
        for (ExpoApplyInfo__c item: newList) {
            if (item.ProductInterestEN__c != oldDataMap.get(item.Id).ProductInterestEN__c 
                || item.ProductInterestCN__c != oldDataMap.get(item.Id).ProductInterestCN__c 
                || item.BrandPreferenceCN__c != oldDataMap.get(item.Id).BrandPreferenceCN__c
                || item.BrandPreferenceEN__c != oldDataMap.get(item.Id).BrandPreferenceEN__c 
                || item.CountryRegionCN__c != oldDataMap.get(item.Id).CountryRegionCN__c
                || item.CountryRegionEN__c != oldDataMap.get(item.Id).CountryRegionEN__c 
                || item.Region__c != oldDataMap.get(item.Id).Region__c ) {
                item.Is_Allocated__c = FALSE;
            updateItemList.add(item);
            }
        }

        if (updateItemList.size() > 0) initOwner(updateItemList);

    }


    /**
     * @description 给负责人发送通知
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void sendNotifyToOwners(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList) {
        Map<Id, ExpoApplyInfo__c> oldDataMap = NULL;
        if (oldList != NULL ) oldDataMap  = new Map<Id, ExpoApplyInfo__c>(oldList);
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Custom_Notification'];

        for (ExpoApplyInfo__c item: newList) {
            Set<String>userIdSet = new Set<String>();
            if (oldList == NULL) {
                if (item.Owner_User1__c != NULL) userIdSet.add(item.Owner_User1__c);
                if (item.Owner_User2__c != NULL) userIdSet.add(item.Owner_User2__c);
                if (item.Owner_User3__c != NULL) userIdSet.add(item.Owner_User3__c);
                if (item.Owner_User4__c != NULL) userIdSet.add(item.Owner_User4__c);
                if (item.Owner_User5__c != NULL) userIdSet.add(item.Owner_User5__c);
            }else {
                if (item.Owner_User1__c != NULL && item.Owner_User1__c != oldDataMap.get(item.Id).Owner_User1__c) userIdSet.add(item.Owner_User1__c);
                if (item.Owner_User2__c != NULL && item.Owner_User2__c != oldDataMap.get(item.Id).Owner_User2__c) userIdSet.add(item.Owner_User2__c);
                if (item.Owner_User3__c != NULL && item.Owner_User3__c != oldDataMap.get(item.Id).Owner_User3__c) userIdSet.add(item.Owner_User3__c);
                if (item.Owner_User4__c != NULL && item.Owner_User4__c != oldDataMap.get(item.Id).Owner_User4__c) userIdSet.add(item.Owner_User4__c);
                if (item.Owner_User5__c != NULL && item.Owner_User5__c != oldDataMap.get(item.Id).Owner_User5__c) userIdSet.add(item.Owner_User5__c);
            }
            

            notifyUsers(notificationType, userIdSet, item.Id);


        }

    }

    /**
     * @description 自定义通知
     * @param       notificationType     通知类型
     * @param       recipientsIds       接收人
     * @param       targetId            数据id
    */
    public static void notifyUsers(CustomNotificationType notificationType, Set<String> recipientsIds, String targetId) {

        
        System.debug('userid--->'+recipientsIds);
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('参展客户共享记录提醒！');
        notification.setBody('新增一条参展客户记录！');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getLineNumber()+e.getMessage());
        }
    }

    /**
     * @description 重置负责人分配并重新设置 Is_Allocated__c 为false
     * @param       exApp     展会
    */
    public static void resSetOwner(ExpoApplyInfo__c exApp) {
        exApp.Owner_User1__c = NULL;
        exApp.Owner_User2__c = NULL;
        exApp.Owner_User3__c = NULL;
        exApp.Owner_User4__c = NULL;
        exApp.Owner_User5__c = NULL;
    }

    /**
     * @description 负责人分配
     * @param       exApp     展会
     * @param       regOwner     展会区组负责人
    */
    public static void resSetOwner(ExpoApplyInfo__c exApp, Exhibition_Region_Owner__c regOwner) {
        //Add By Ethan 记录历史所加区组
        exApp.Expect_to_meet_people__c = '记录Id:'+regOwner.Id+ ',邮箱：'+regOwner.Email__c+';';
        if (exApp.Owner_User1__c == NULL) exApp.Owner_User1__c = regOwner.User__c;
        else if (exApp.Owner_User2__c == NULL) exApp.Owner_User2__c = regOwner.User__c;
        else if (exApp.Owner_User3__c == NULL) exApp.Owner_User3__c = regOwner.User__c;
        else if (exApp.Owner_User4__c == NULL) exApp.Owner_User4__c = regOwner.User__c;
        else  exApp.Owner_User5__c = regOwner.User__c;



    }

    //获取国家是哪个区域
    // public static String getCountryRegion(String country){
    //     Map<String, String> countryLabelMap = new Map<String, String>{System.Label.Exhibtion_Country_Mid =>'Mid-East & Africa Region',
    //                                                                     System.Label.Exhibtion_Country_Japan =>'Japan Region',
    //                                                                     System.Label.Exhibtion_Country_Europe =>'Europe Region',
    //                                                                     System.Label.Exhibtion_Country_Asia_Pacific =>'Asia-Pacific Region',
    //                                                                     System.Label.Exhibtion_Country_American =>'America Region'};

    //     for(String item : countryLabelMap.keyset()){
    //         if(item.contains(country))
    //             return countryLabelMap.get(item);
    //     }

    //     return null;
    // }

    // 匹配现场接待人员
    public static void matchingOnSiteReceptionists(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList) {
        matchingOnSiteReceptionists(oldList, newList, Date.today());
    }

    // 匹配现场接待人员
    // public static List<ExpoApplyInfo__c> matchingOnSiteReceptionists(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList, Date exhibitDate) {
    //     List<ExpoApplyInfo__c> updateCustomerList = new List<ExpoApplyInfo__c>();

    //     Map<Id, ExpoApplyInfo__c> oldMap = new Map<Id, ExpoApplyInfo__c>();
    //     if(oldList != NULL) {
    //         oldMap = new Map<Id, ExpoApplyInfo__c>(oldList);
    //     }

    //     Map<String, String> regisFields = SObjectHelper.getFieldLabelMap('Internal_Registration__c');
    //     List<String> exhibitionIdList = new LisqContainer(newList).SelectSField('ExpoId__c');
    //     List<Exhibition_Arrangement__c> peopleOnSiteList = [SELECT Id, Name, Internal_Registration__c, Internal_Registration__r.Name, Internal_Registration__r.Name_CN__c, Internal_Registration__r.Phone__c, Internal_Registration__r.Email__c, 
    //                                                                 Internal_Registration__r.Region__c, Internal_Registration__r.Counry__c, Internal_Registration__r.Brand__c, Internal_Registration__r.Product_Line__c, PresenceDate__c,
    //                                                                 Exhibition_Management__c, Exhibition_Management__r.LastRegistrationDate__c
    //                                                         FROM Exhibition_Arrangement__c 
    //                                                         WHERE Exhibition_Management__c IN :exhibitionIdList AND Internal_Registration__r.Approval_Status__c = '审批通过' 
    //                                                             AND (Internal_Registration__r.Region__c != null OR Internal_Registration__r.Counry__c != null)
    //                                                         ORDER BY Internal_Registration__r.AssociateWeight__c DESC];
    //     // 邮箱与行程信息
    //     Map<String, Exhibition_Arrangement__c> emailAndArrangementMap = new Map<String, Exhibition_Arrangement__c>();
    //     // 展会Id与展会内部报名截止时间Map
    //     Map<String, Date> exhibitionIdAndLastDateMap = new Map<String, Date>();
    //     for (Exhibition_Arrangement__c item : peopleOnSiteList) {
    //         emailAndArrangementMap.put(item.Internal_Registration__r.Email__c, item);
    //         exhibitionIdAndLastDateMap.put(item.Exhibition_Management__c, item.Exhibition_Management__r.LastRegistrationDate__c);
    //     }

    //     // 接待人员信息
    //     Map<Id, List<ExhibitionCustomerAssignment__c>> customerAndAssignmentMap = new Map<Id, List<ExhibitionCustomerAssignment__c>>();
    //     if (oldList != NULL) {
    //         Map<Id, ExpoApplyInfo__c> ExhibitionCustomerMap = new Map<Id, ExpoApplyInfo__c>(oldList);
    //         List<ExhibitionCustomerAssignment__c> assignmentList = [SELECT Id, Name, ExhibitionArrangement__c, ExhibitionCustomer__c, ReceptionUser__c, logical_delete__c FROM ExhibitionCustomerAssignment__c WHERE ExhibitionCustomer__c IN :ExhibitionCustomerMap.keyset()];
    //         for (ExhibitionCustomerAssignment__c item : assignmentList) {
    //             if (customerAndAssignmentMap.containsKey(item.ExhibitionCustomer__c)) {
    //                 customerAndAssignmentMap.get(item.ExhibitionCustomer__c).add(item);
    //             } else {
    //                 customerAndAssignmentMap.put(item.ExhibitionCustomer__c, new List<ExhibitionCustomerAssignment__c> { item });
    //             }
    //         }
    //     }

    //     //产品偏好配置表全量查询做英文-中文 Map
    //     Map<String, String> proEntoCNMap = new Map<String, String>();
    //     for (ExpoProductPreference__c proItem: [SELECT Id, Name, ProductEN__c FROM ExpoProductPreference__c WHERE ProductEN__c<>NULL AND Name <> NULL]) {
    //         proEntoCNMap.put(proItem.ProductEN__c, proItem.Name);
    //     }

    //     // 国家对应大区关系
    //     Map<String, String> countryAndRegionMap = new Map<String, String>();
    //     Map<String, String> countryEnToCNMap = new Map<String, String>();
    //     for (ExpoCountrysBazaar__c countryItem: [SELECT Id, Name, NameEN__c, Region__c FROM ExpoCountrysBazaar__c]) {
    //         countryAndRegionMap.put(countryItem.Name, countryItem.Region__c);
    //         countryEnToCNMap.put(countryItem.NameEN__c, countryItem.Name);
    //     }

    //     for(ExpoApplyInfo__c customer : newList) {
    //         // 展会内部报名时间未截止，不进行匹配
    //         if (exhibitionIdAndLastDateMap.containskey(customer.ExpoId__c) && exhibitionIdAndLastDateMap.get(customer.ExpoId__c) >= Date.today()) {

    //             // continue;
    //         }
    //         if(oldMap.keyset().size() > 0) {
    //             if(
    //                 (customer.Region__c != oldMap.get(customer.Id).Region__c) || 
    //                 (customer.CountryRegionCN__c != oldMap.get(customer.Id).CountryRegionCN__c) || 
    //                 (customer.CountryRegionEN__c != oldMap.get(customer.Id).CountryRegionEN__c) || 
    //                 (customer.BrandPreferenceCN__c != oldMap.get(customer.Id).BrandPreferenceCN__c) ||
    //                 (customer.BrandPreferenceEN__c != oldMap.get(customer.Id).BrandPreferenceEN__c) ||
    //                 (customer.ProductInterestCN__c != oldMap.get(customer.Id).ProductInterestCN__c) ||
    //                 (customer.ProductInterestEN__c != oldMap.get(customer.Id).ProductInterestEN__c) ||
    //                 (customer.Reception_Email__c != oldMap.get(customer.Id).Reception_Email__c)
    //             ) {
    //                 customer.ReceptionUserInfo__c = '';
    //                 customer.ExhibitionArrangement1__c = null;
    //                 customer.ExhibitionArrangement2__c = null;
    //                 customer.ExhibitionArrangement3__c = null;
    //             } else {
    //                 continue;
    //             }
    //         }

    //         // 精确匹配的接待人员
    //         List<Exhibition_Arrangement__c> matchPersonList = new List<Exhibition_Arrangement__c>();
    //         // 匹配同区域国家的接待人员
    //         List<Exhibition_Arrangement__c> matchPersonOfCountryList = new List<Exhibition_Arrangement__c>();

    //         // 客户信息上有指定接待人员邮箱
    //         if (emailAndArrangementMap.containskey(customer.Reception_Email__c)) {
    //             matchPersonList.add(emailAndArrangementMap.get(customer.Reception_Email__c));
    //             System.debug('matchingOnSiteReceptionists -> customer has Reception Email');
    //         } else {
    //             // 客户偏好信息
    //             String cutomerRegion = String.isBlank(customer.Region__c) ? '' : customer.Region__c;
    //             String customerCountry = '';
    //             if(String.isNotBlank(customer.CountryRegionEN__c)) {
    //                 customerCountry = countryEnToCNMap.containsKey(customer.CountryRegionEN__c) ? countryEnToCNMap.get(customer.CountryRegionEN__c) : customer.CountryRegionEN__c;
    //             } else if(String.isNotBlank(customer.CountryRegionCN__c)) {
    //                 customerCountry = customer.CountryRegionCN__c;
    //             }
    //             if(String.isBlank(cutomerRegion) && String.isNotBlank(customerCountry) && countryAndRegionMap.containsKey(customerCountry)) {
    //                 cutomerRegion = countryAndRegionMap.get(customerCountry);
    //             }

    //             Set<String> brandPrefer = new Set<String>();
    //             if(String.isNotBlank(customer.BrandPreferenceCN__c)) {
    //                 brandPrefer.addAll(customer.BrandPreferenceCN__c.split(';'));
    //             } else if(String.isNotBlank(customer.BrandPreferenceEN__c)) {
    //                 brandPrefer.addAll(customer.BrandPreferenceEN__c.split(';'));
    //             }

    //             Set<String> proLinePrefer = new Set<String>();
    //             if(String.isNotBlank(customer.ProductInterestEN__c)) {
    //                 for(String proLine : customer.ProductInterestEN__c.split(';')) {
    //                     if(proEntoCNMap.containskey(proLine)) {
    //                         proLinePrefer.add(proEntoCNMap.get(proLine));
    //                     }
    //                 }
    //             } else if(String.isNotBlank(customer.ProductInterestCN__c)) {
    //                 proLinePrefer.addAll(customer.ProductInterestCN__c.split(';'));
    //             }
    //             for(Exhibition_Arrangement__c person : peopleOnSiteList) {

    //                 if(customer.ExpoId__c != person.Exhibition_Management__c) {
                        
    //                     continue;
    //                 }

    //                 // if(String.isNotBlank(person.PresenceDate__c) && person.PresenceDate__c.contains(DateTime.newInstance(exhibitDate.year(), exhibitDate.month(), exhibitDate.day()).format('MM-dd'))) {
    //                 Set<String> personCountry = String.isBlank(person.Internal_Registration__r.Counry__c) ? new Set<String>() : new Set<String>(person.Internal_Registration__r.Counry__c.split(';'));
    //                 // 员工的负责国家是多选
    //                 Set<String> personRegion = new Set<String>();
    //                 for(String country : personCountry) {
    //                     if(countryAndRegionMap.containsKey(country)) {
    //                         personRegion.add(countryAndRegionMap.get(country));
    //                     }
    //                 }
    //                 Set<String> personBrand = String.isBlank(person.Internal_Registration__r.Brand__c) ? new Set<String>() : new Set<String>(person.Internal_Registration__r.Brand__c.split(';'));
    //                 Set<String> personProLine = String.isBlank(person.Internal_Registration__r.Product_Line__c) ? new Set<String>() : new Set<String>(person.Internal_Registration__r.Product_Line__c.split(';'));
    //                 Boolean regionMatch = (String.isBlank(cutomerRegion)) || (personRegion.size() == 0) || (personRegion.contains(cutomerRegion));
    //                 Boolean countryMatch = (String.isBlank(customerCountry)) || (personCountry.size() == 0) || (personCountry.contains(customerCountry));
    //                 Boolean brandMatch = (brandPrefer.size() == 0) || (personBrand.size() == 0) || (personBrand.containsAll(brandPrefer));
    //                 Boolean proLineMatch = (proLinePrefer.size() == 0) || (personProLine.size() == 0) || (personProLine.containsAll(proLinePrefer));
                    
    //                 if(regionMatch && countryMatch && brandMatch && proLineMatch) {
    //                     matchPersonList.add(person);
    //                     System.debug('matchPersonList -> matchPerson : ' + person);
    //                     continue;
    //                 }
                    
    //                 // 如果对应的国家负责人不在，则匹配同区域平级国家的负责人
    //                 if(regionMatch && brandMatch && proLineMatch) {
    //                     matchPersonOfCountryList.add(person);
    //                     System.debug('matchPersonOfCountryList -> matchPerson : ' + person);
    //                 }
    //                 // }
    //             }
    //         }

    //         // 合并精确匹配到的接待人员与同区域平级国家接待人员
    //         matchPersonList.addAll(matchPersonOfCountryList);
    //         if(matchPersonList.size() > 0) {
    //             List<Map<String, String>> infoMapList = new List<Map<String, String>>();
    //             for(Integer index=1; index <= matchPersonList.size() && index <= 3; index++) {
    //                 String fieldStr = 'ExhibitionArrangement' + index + '__c';
    //                 customer.put(fieldStr, matchPersonList[index-1].Id);

    //                 infoMapList.add(new Map<String, String> {
    //                     regisFields.get('Email__c') => matchPersonList[index-1].Internal_Registration__r.Email__c,
    //                     regisFields.get('Phone__c') => matchPersonList[index-1].Internal_Registration__r.Phone__c,
    //                     regisFields.get('Name_CN__c') => matchPersonList[index-1].Internal_Registration__r.Name_CN__c,
    //                     regisFields.get('Name') => matchPersonList[index-1].Internal_Registration__r.Name
    //                 });
    //             }
    //             customer.ReceptionUserInfo__c = Json.serialize(infoMapList);
    //         }
    //         System.debug('matchingOnSiteReceptionists -> customer.ReceptionUserInfo__c : ' + customer.ReceptionUserInfo__c);
    //         if (String.isNotBlank(customer.ReceptionUserInfo__c)) {
    //             updateCustomerList.add(customer);
    //         }
    //     }

    //     return updateCustomerList;
    // }

    //TJP 移除行程表
    public static List<ExpoApplyInfo__c> matchingOnSiteReceptionists(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList, Date exhibitDate) {
        List<ExpoApplyInfo__c> updateCustomerList = new List<ExpoApplyInfo__c>();

        Map<Id, ExpoApplyInfo__c> oldMap = new Map<Id, ExpoApplyInfo__c>();
        if(oldList != NULL) {
            oldMap = new Map<Id, ExpoApplyInfo__c>(oldList);
        }

        Map<String, String> regisFields = SObjectHelper.getFieldLabelMap('Internal_Registration__c');
        List<String> exhibitionIdList = new LisqContainer(newList).SelectSField('ExpoId__c');
        List<Internal_Registration__c> peopleOnSiteList = [SELECT Id, Name,  Name_CN__c, Phone__c,Email__c, 
                                                                    Region__c, Counry__c, Brand__c, Product_Line__c,
                                                                    Exhibition_Id__c, Exhibition_Id__r.LastRegistrationDate__c
                                                            FROM Internal_Registration__c 
                                                            WHERE Exhibition_Id__c IN :exhibitionIdList AND Approval_Status__c = '审批通过' 
                                                                AND (Region__c != null OR Counry__c != null)
                                                            ORDER BY AssociateWeight__c DESC];
        System.debug('查询满足条件得所有现场参展人' + peopleOnSiteList.size());
        // 邮箱与行程信息
        Map<String, Internal_Registration__c> emailAndArrangementMap = new Map<String, Internal_Registration__c>();
        // 展会Id与展会内部报名截止时间Map
        Map<String, Date> exhibitionIdAndLastDateMap = new Map<String, Date>();
        for (Internal_Registration__c item : peopleOnSiteList) {
            emailAndArrangementMap.put(item.Email__c, item);
            exhibitionIdAndLastDateMap.put(item.Exhibition_Id__c, item.Exhibition_Id__r.LastRegistrationDate__c);
        }

        // 接待人员信息
        Map<Id, List<ExhibitionCustomerAssignment__c>> customerAndAssignmentMap = new Map<Id, List<ExhibitionCustomerAssignment__c>>();
        if (oldList != NULL) {
            Map<Id, ExpoApplyInfo__c> ExhibitionCustomerMap = new Map<Id, ExpoApplyInfo__c>(oldList);
            List<ExhibitionCustomerAssignment__c> assignmentList = [SELECT Id, Name, ExhibitionArrangement__c, ExhibitionCustomer__c, ReceptionUser__c, logical_delete__c FROM ExhibitionCustomerAssignment__c WHERE ExhibitionCustomer__c IN :ExhibitionCustomerMap.keyset()];
            for (ExhibitionCustomerAssignment__c item : assignmentList) {
                if (customerAndAssignmentMap.containsKey(item.ExhibitionCustomer__c)) {
                    customerAndAssignmentMap.get(item.ExhibitionCustomer__c).add(item);
                } else {
                    customerAndAssignmentMap.put(item.ExhibitionCustomer__c, new List<ExhibitionCustomerAssignment__c> { item });
                }
            }
        }

        //产品偏好配置表全量查询做英文-中文 Map
        Map<String, String> proEntoCNMap = new Map<String, String>();
        for (ExpoProductPreference__c proItem: [SELECT Id, Name, ProductEN__c FROM ExpoProductPreference__c WHERE ProductEN__c<>NULL AND Name <> NULL]) {
            proEntoCNMap.put(proItem.ProductEN__c, proItem.Name);
        }

        // 国家对应大区关系
        Map<String, String> countryAndRegionMap = new Map<String, String>();
        Map<String, String> countryEnToCNMap = new Map<String, String>();
        for (ExpoCountrysBazaar__c countryItem: [SELECT Id, Name, NameEN__c, Region__c,Contrast_Region__c FROM ExpoCountrysBazaar__c]) {
            countryAndRegionMap.put(countryItem.Name, countryItem.Contrast_Region__c);
            countryEnToCNMap.put(countryItem.NameEN__c, countryItem.Name);
        }

        for(ExpoApplyInfo__c customer : newList) {
            // 展会内部报名时间未截止，不进行匹配
            // if (exhibitionIdAndLastDateMap.containskey(customer.ExpoId__c) && exhibitionIdAndLastDateMap.get(customer.ExpoId__c) >= Date.today()) {

            //     // continue;
            // }
            if(oldMap.keyset().size() > 0) {
                if(
                    (customer.Region__c != oldMap.get(customer.Id).Region__c) || 
                    (customer.CountryRegionCN__c != oldMap.get(customer.Id).CountryRegionCN__c) || 
                    (customer.CountryRegionEN__c != oldMap.get(customer.Id).CountryRegionEN__c) || 
                    (customer.BrandPreferenceCN__c != oldMap.get(customer.Id).BrandPreferenceCN__c) ||
                    (customer.BrandPreferenceEN__c != oldMap.get(customer.Id).BrandPreferenceEN__c) ||
                    (customer.ProductInterestCN__c != oldMap.get(customer.Id).ProductInterestCN__c) ||
                    (customer.ProductInterestEN__c != oldMap.get(customer.Id).ProductInterestEN__c) ||
                    (customer.Reception_Email__c != oldMap.get(customer.Id).Reception_Email__c)
                ) {
                    customer.ReceptionUserInfo__c = '';
                    customer.ExhibitionArrangement1__c = null;
                    customer.ExhibitionArrangement2__c = null;
                    customer.ExhibitionArrangement3__c = null;
                } else {
                    continue;
                }
            }

            // 精确匹配的接待人员
            List<Internal_Registration__c> matchPersonList = new List<Internal_Registration__c>();
            // 匹配同区域国家的接待人员
            List<Internal_Registration__c> matchPersonOfCountryList = new List<Internal_Registration__c>();

            // 客户信息上有指定接待人员邮箱
            if (emailAndArrangementMap.containskey(customer.Reception_Email__c)) {
                matchPersonList.add(emailAndArrangementMap.get(customer.Reception_Email__c));
                System.debug('matchingOnSiteReceptionists -> customer has Reception Email');
            } else {
                // 客户偏好信息
                String cutomerRegion = String.isBlank(customer.Region__c) ? '' : customer.Region__c;
                String customerCountry = '';
                if(String.isNotBlank(customer.CountryRegionEN__c)) {
                    customerCountry = countryEnToCNMap.containsKey(customer.CountryRegionEN__c) ? countryEnToCNMap.get(customer.CountryRegionEN__c) : customer.CountryRegionEN__c;
                } else if(String.isNotBlank(customer.CountryRegionCN__c)) {
                    customerCountry = customer.CountryRegionCN__c;
                }
                if(String.isBlank(cutomerRegion) && String.isNotBlank(customerCountry) && countryAndRegionMap.containsKey(customerCountry)) {
                    cutomerRegion = countryAndRegionMap.get(customerCountry);
                }

                Set<String> brandPrefer = new Set<String>();
                if(String.isNotBlank(customer.BrandPreferenceCN__c)) {
                    brandPrefer.addAll(customer.BrandPreferenceCN__c.split(';'));
                } else if(String.isNotBlank(customer.BrandPreferenceEN__c)) {
                    brandPrefer.addAll(customer.BrandPreferenceEN__c.split(';'));
                }

                Set<String> proLinePrefer = new Set<String>();
                if(String.isNotBlank(customer.ProductInterestEN__c)) {
                    for(String proLine : customer.ProductInterestEN__c.split(';')) {
                        if(proEntoCNMap.containskey(proLine)) {
                            proLinePrefer.add(proEntoCNMap.get(proLine));
                        }
                    }
                } else if(String.isNotBlank(customer.ProductInterestCN__c)) {
                    proLinePrefer.addAll(customer.ProductInterestCN__c.split(';'));
                }
                for(Internal_Registration__c person : peopleOnSiteList) {

                    if(customer.ExpoId__c != person.Exhibition_Id__c) {
                        
                        continue;
                    }

                    // if(String.isNotBlank(person.PresenceDate__c) && person.PresenceDate__c.contains(DateTime.newInstance(exhibitDate.year(), exhibitDate.month(), exhibitDate.day()).format('MM-dd'))) {
                    Set<String> personCountry = String.isBlank(person.Counry__c) ? new Set<String>() : new Set<String>(person.Counry__c.split(';'));
                    // 员工的负责国家是多选
                    Set<String> personRegion = new Set<String>();
                    for(String country : personCountry) {
                        if(countryAndRegionMap.containsKey(country)) {
                            personRegion.add(countryAndRegionMap.get(country));
                        }
                    }
                    Set<String> personBrand = String.isBlank(person.Brand__c) ? new Set<String>() : new Set<String>(person.Brand__c.split(';'));
                    Set<String> personProLine = String.isBlank(person.Product_Line__c) ? new Set<String>() : new Set<String>(person.Product_Line__c.split(';'));
                    Boolean regionMatch = (String.isBlank(cutomerRegion)) || (personRegion.size() == 0) || (personRegion.contains(cutomerRegion));
                    Boolean countryMatch = (String.isBlank(customerCountry)) || (personCountry.size() == 0) || (personCountry.contains(customerCountry));
                    Boolean brandMatch = (brandPrefer.size() == 0) || (personBrand.size() == 0) || (personBrand.containsAll(brandPrefer));
                    Boolean proLineMatch = (proLinePrefer.size() == 0) || (personProLine.size() == 0) || (personProLine.containsAll(proLinePrefer));
                    
                    if(regionMatch && countryMatch && brandMatch && proLineMatch) {
                        matchPersonList.add(person);
                        System.debug('matchPersonList -> matchPerson : ' + person);
                        continue;
                    }
                    
                    // 如果对应的国家负责人不在，则匹配同区域平级国家的负责人
                    if(regionMatch && brandMatch && proLineMatch) {
                        matchPersonOfCountryList.add(person);
                        System.debug('matchPersonOfCountryList -> matchPerson : ' + person);
                    }
                    // }
                }
            }

            // 合并精确匹配到的接待人员与同区域平级国家接待人员
            matchPersonList.addAll(matchPersonOfCountryList);
            if(matchPersonList.size() > 0) {
                List<Map<String, String>> infoMapList = new List<Map<String, String>>();
                for(Integer index=1; index <= matchPersonList.size() && index <= 3; index++) {
                    String fieldStr = 'ReceptionId' + index + '__c';
                    customer.put(fieldStr, matchPersonList[index-1].Id);

                    infoMapList.add(new Map<String, String> {
                        regisFields.get('Email__c') => matchPersonList[index-1].Email__c,
                        regisFields.get('Phone__c') => matchPersonList[index-1].Phone__c,
                        regisFields.get('Name_CN__c') => matchPersonList[index-1].Name_CN__c,
                        regisFields.get('Name') => matchPersonList[index-1].Name
                    });
                }
                customer.ReceptionUserInfo__c = Json.serialize(infoMapList);
            }
            System.debug('matchingOnSiteReceptionists -> customer.ReceptionUserInfo__c : ' + customer.ReceptionUserInfo__c);
            if (String.isNotBlank(customer.ReceptionUserInfo__c)) {
                updateCustomerList.add(customer);
            }
        }

        return updateCustomerList;
    }


    // 通知现场接待人员
    // public static void messageToSiteReceptionists(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList) { 
    //     Map<Id, ExpoApplyInfo__c> oldMap = new Map<Id, ExpoApplyInfo__c>();
    //     List<ExhibitionCustomerAssignment__c> existedAssignmentList = new List<ExhibitionCustomerAssignment__c>();
    //     if(oldList != NULL) {
    //         oldMap = new Map<Id, ExpoApplyInfo__c>(oldList);
    //         existedAssignmentList = [SELECT Id, Name, ExhibitionArrangement__c, ExhibitionCustomer__c, ReceptionUser__c, logical_delete__c FROM ExhibitionCustomerAssignment__c WHERE ExhibitionCustomer__c IN :oldMap.keyset()];
    //     }

    //     List<String> arrStrList = new List<String>{'ExhibitionArrangement1__c', 'ExhibitionArrangement2__c', 'ExhibitionArrangement3__c'};
    //     List<String> arrIdList = new List<String>();
    //     for(Integer index=1; index <= arrStrList.size(); index++) {
    //         arrIdList.addAll(new LisqContainer(newList).Where1(arrStrList[index-1], '!=', null).selectsField(arrStrList[index-1]));
    //     }
    //     System.debug('messageToSiteReceptionists ---> arrIdList: ' + arrIdList);

    //     List<Exhibition_Arrangement__c> peopleOnSiteList = [SELECT Id, Name, Internal_Registration__c, Internal_Registration__r.Name, Internal_Registration__r.Name_CN__c, 
    //                                                                 Internal_Registration__r.Phone__c, Internal_Registration__r.Email__c
    //                                                             FROM Exhibition_Arrangement__c 
    //                                                             WHERE Id IN :arrIdList];
    //     Map<Id, Exhibition_Arrangement__c> peopleOnSiteMap = new Map<Id, Exhibition_Arrangement__c>(peopleOnSiteList);

    //     EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
    //                                         FROM EmailTemplate
    //                                         WHERE DeveloperName = 'Exhibition_Customer_Reception_SMS' LIMIT 1];
    //     // String message = '您有一位新的参展客户待接待，请及时处理。';
    //     Map<String, List<String>> personInfoMap = new Map<String, List<String>>();

    //     // 需要更新的客户接待人员信息
    //     List<ExhibitionCustomerAssignment__c> needInsertAssignmentList = new List<ExhibitionCustomerAssignment__c>();
    //     Map<String, ExhibitionCustomerAssignment__c> existedAssignmentInfoMap = new Map<String, ExhibitionCustomerAssignment__c>();
    //     for (ExhibitionCustomerAssignment__c item : existedAssignmentList) {
    //         existedAssignmentInfoMap.put(item.ExhibitionCustomer__c + '-' + item.ExhibitionArrangement__c, item);
    //     }

    //     for(ExpoApplyInfo__c customer : newList) { 
    //         List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, customer.Id, new List<String>{tempOfSMS.Body});
    //         String contentOfSMS = renderEmailTemplateBodyRes[0].getMergedBody();
    //         for(Integer index=1; index <= arrStrList.size(); index++) {
    //             String fieldStr = arrStrList[index-1];
    //             String arrId = String.valueOf(customer.get(fieldStr));
    //             if(oldList == NULL || (String.isNotBlank(arrId) && arrId != String.valueOf(oldMap.get(customer.Id).get(fieldStr)))) {
    //                 if(peopleOnSiteMap.containsKey(arrId)) {

    //                     String assignmentKey = customer.Id + '-' + peopleOnSiteMap.get(arrId).Id;
    //                     if (existedAssignmentInfoMap.containsKey(assignmentKey)) {
    //                         existedAssignmentInfoMap.remove(assignmentKey);
    //                         // 已存在接待记录, 无需再次发送短信
    //                         System.debug('messageToSiteReceptionists ---> already exists: ' + existedAssignmentInfoMap.get(assignmentKey));

    //                         continue;
    //                     } else {
    //                         // 新的接待人员信息数据
    //                         needInsertAssignmentList.add(
    //                             new ExhibitionCustomerAssignment__c(
    //                                 ExhibitionCustomer__c = customer.Id, 
    //                                 ExhibitionArrangement__c = peopleOnSiteMap.get(arrId).Id, 
    //                                 ReceptionUser__c = peopleOnSiteMap.get(arrId).Internal_Registration__c
    //                             )
    //                         );
    //                     }

    //                     String personPhoneNumber = peopleOnSiteMap.get(arrId).Internal_Registration__r.Phone__c;
    //                     if(personInfoMap.containskey(personPhoneNumber)) {
    //                         personInfoMap.get(personPhoneNumber).add(contentOfSMS);
    //                     } else {
    //                         personInfoMap.put(personPhoneNumber, new List<String>{contentOfSMS});
    //                     } 
    //                 }
    //             }

    //             // 接待人员没有变更，需要remove
    //             if(oldList != NULL && (String.isNotBlank(arrId) && arrId == String.valueOf(oldMap.get(customer.Id).get(fieldStr)))) {
    //                 if (peopleOnSiteMap.containsKey(arrId) && existedAssignmentInfoMap.containsKey(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id)) {
    //                     existedAssignmentInfoMap.remove(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id);
    //                     System.debug('messageToSiteReceptionists ---> no change: ' + existedAssignmentInfoMap.get(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id));
    //                 }
    //             }
    //         }
    //     }
    //     System.debug('messageToSiteReceptionists ---> needInsertAssignmentList: ' + needInsertAssignmentList.size());
    //     System.debug('messageToSiteReceptionists ---> needDeleteAssignmentList: ' + existedAssignmentInfoMap.values());
    //     Database.insert(needInsertAssignmentList);
    //     Database.delete(existedAssignmentInfoMap.values());

    //     // 发送短信通知
    //     sendMessage(Json.serialize(personInfoMap));
    // }

    //TJP 移除行程表关联关系
    public static void messageToSiteReceptionists(List<ExpoApplyInfo__c> oldList, List<ExpoApplyInfo__c> newList) { 
        Map<Id, ExpoApplyInfo__c> oldMap = new Map<Id, ExpoApplyInfo__c>();
        List<ExhibitionCustomerAssignment__c> existedAssignmentList = new List<ExhibitionCustomerAssignment__c>();
        if(oldList != NULL) {
            oldMap = new Map<Id, ExpoApplyInfo__c>(oldList);
            existedAssignmentList = [SELECT Id, Name, ExhibitionArrangement__c, ExhibitionCustomer__c, ReceptionUser__c, logical_delete__c FROM ExhibitionCustomerAssignment__c WHERE ExhibitionCustomer__c IN :oldMap.keyset()];
        }

        List<String> arrStrList = new List<String>{'ReceptionId1__c', 'ReceptionId2__c', 'ReceptionId3__c'};
        List<String> arrIdList = new List<String>();
        for(Integer index=1; index <= arrStrList.size(); index++) {
            arrIdList.addAll(new LisqContainer(newList).Where1(arrStrList[index-1], '!=', null).selectsField(arrStrList[index-1]));
        }
        System.debug('messageToSiteReceptionists ---> arrIdList: ' + arrIdList);

        List<Internal_Registration__c> peopleOnSiteList = [SELECT Id, Name, Name_CN__c, 
                                                                   Phone__c, Email__c
                                                                FROM Internal_Registration__c 
                                                                WHERE Id IN :arrIdList];
        Map<Id, Internal_Registration__c> peopleOnSiteMap = new Map<Id, Internal_Registration__c>(peopleOnSiteList);

        EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
                                            FROM EmailTemplate
                                            WHERE DeveloperName = 'Exhibition_Customer_Reception_SMS' LIMIT 1];
        // String message = '您有一位新的参展客户待接待，请及时处理。';
        Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        // 需要更新的客户接待人员信息
        List<ExhibitionCustomerAssignment__c> needInsertAssignmentList = new List<ExhibitionCustomerAssignment__c>();
        Map<String, ExhibitionCustomerAssignment__c> existedAssignmentInfoMap = new Map<String, ExhibitionCustomerAssignment__c>();
        for (ExhibitionCustomerAssignment__c item : existedAssignmentList) {
            existedAssignmentInfoMap.put(item.ExhibitionCustomer__c + '-' + item.ReceptionUser__c, item);
        }

        for(ExpoApplyInfo__c customer : newList) { 
            List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, customer.Id, new List<String>{tempOfSMS.Body});
            String contentOfSMS = renderEmailTemplateBodyRes[0].getMergedBody();
            for(Integer index=1; index <= arrStrList.size(); index++) {
                String fieldStr = arrStrList[index-1];
                String arrId = String.valueOf(customer.get(fieldStr));
                if(oldList == NULL || (String.isNotBlank(arrId) && arrId != String.valueOf(oldMap.get(customer.Id).get(fieldStr)))) {
                    if(peopleOnSiteMap.containsKey(arrId)) {

                        String assignmentKey = customer.Id + '-' + peopleOnSiteMap.get(arrId).Id;
                        if (existedAssignmentInfoMap.containsKey(assignmentKey)) {
                            existedAssignmentInfoMap.remove(assignmentKey);
                            // 已存在接待记录, 无需再次发送短信
                            System.debug('messageToSiteReceptionists ---> already exists: ' + existedAssignmentInfoMap.get(assignmentKey));

                            continue;
                        } else {
                            // 新的接待人员信息数据
                            needInsertAssignmentList.add(
                                new ExhibitionCustomerAssignment__c(
                                    ExhibitionCustomer__c = customer.Id, 
                                    ExhibitionArrangement__c = null, 
                                    ReceptionUser__c = peopleOnSiteMap.get(arrId).Id
                                )
                            );
                        }

                        String personPhoneNumber = peopleOnSiteMap.get(arrId).Phone__c;

                        if(personInfoMap.containskey(personPhoneNumber)) {
                            personInfoMap.get(personPhoneNumber).add(contentOfSMS);
                        } else {
                            personInfoMap.put(personPhoneNumber, new List<String>{contentOfSMS});
                        }
                        
                        String toEmail = peopleOnSiteMap.get(arrId).Email__c;
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				        renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(customer.OwnerId, customer.Id, new List<String>{tempOfSMS.HtmlValue});
				        String body = renderEmailTemplateBodyRes[0].getMergedBody();
				        System.debug('body=' + body);
				        singleEmail.setHTMLBody(body);
				        singleEmail.setSaveAsActivity(false);
				        // singleEmail.setTemplateId(emtemp.Id);
				        // singleEmail.setWhatId(item.Id);
				        singleEmail.setSubject(tempOfSMS.Subject + '');
				        //设置发送人邮箱
				        singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				        singleEmail.setToAddresses(new List<String>{toEmail});
				        sendEmailList.add(singleEmail);
                    }
                }

                // 接待人员没有变更，需要remove
                if(oldList != NULL && (String.isNotBlank(arrId) && arrId == String.valueOf(oldMap.get(customer.Id).get(fieldStr)))) {
                    if (peopleOnSiteMap.containsKey(arrId) && existedAssignmentInfoMap.containsKey(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id)) {
                        existedAssignmentInfoMap.remove(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id);
                        System.debug('messageToSiteReceptionists ---> no change: ' + existedAssignmentInfoMap.get(customer.Id + '-' + peopleOnSiteMap.get(arrId).Id));
                    }
                }
            }
        }
        System.debug('messageToSiteReceptionists ---> Info: ' + needInsertAssignmentList);
        System.debug('messageToSiteReceptionists ---> needInsertAssignmentList: ' + needInsertAssignmentList.size());
        System.debug('messageToSiteReceptionists ---> needDeleteAssignmentList: ' + existedAssignmentInfoMap.values());
        Database.insert(needInsertAssignmentList);
        Database.delete(existedAssignmentInfoMap.values());

        if (sendEmailList.size() > 0) {
			System.debug('------------>ready send ! ');
			try {
				Messaging.sendEmail(sendEmailList);
			}
			catch (Exception e) {
				System.debug('ExhibitionVehicalTriggerHandlerHelper.sendEmail->'+e.getLineNumber()+e.getMessage());
			}
		}

        // 发送短信通知 Tips：TJP-2025-04-09 取消短信推送
        sendMessage(Json.serialize(personInfoMap));
    }


    @future (callout=true)
    public static void sendMessage(String personInfoMapJson) {
        Map<String, List<String>> personInfoMap = (Map<String, List<String>>)JSON.deserialize(personInfoMapJson, Map<String, List<String>>.class);
        for(String key : personInfoMap.keyset()) {
            for(String message : personInfoMap.get(key)) {
               HisenseSMSUtility.sendSMS(key, message); 
            }
        }
        HisenseSMSUtility.saveLog();
    }




}