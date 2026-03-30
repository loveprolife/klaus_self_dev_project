public without sharing class InternalRegistrationTriggerHanderHelper {
    // https://hisenseint--hitest.sandbox.my.salesforce-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=a3M0T0000006rG5UAI
    private final static String SITE_URL_MID = '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';
    private static Map<String, Decimal> exhibitorMap;
    private static Map<String,String> errorMap;
    private static Map<String, Decimal> tempMap;
    private final static String Temporary_Certificate = '临时证';
    private final static String Exhibitor_Card = '参展商证';

   /**
     * @description 创建时校验是否已过期
     * @param       newList     更改后数据
    */
    public static void createCheck(List<Internal_Registration__c> newList) {
   		List<Id> expoInfoIdList = new LisqContainer(newList).SelectSField('Exhibition_Id__c');

   		// Map<Id, ExpoInfo__c> expoInfoMap = new Map<Id, ExpoInfo__c>([SELECT 
   		// 	Id, LastRegistrationDate__c, TitleCN__c, TitleEN__c FROM ExpoInfo__c WHERE Id IN: expoInfoIdList]);

           List<Expo_Date_Controller__c> expoDateControllers = [
            SELECT Id, 
                   SignUp_End_Date__c, 
                   Exhibition_Management__c, 
                   Exhibition_Management__r.TitleCN__c, 
                   Exhibition_Management__r.TitleEN__c 
            FROM Expo_Date_Controller__c 
            WHERE Exhibition_Management__c IN :expoInfoIdList
        ];
        
        Map<Id, Expo_Date_Controller__c> expoInfoMap = new Map<Id, Expo_Date_Controller__c>();
        
        for (Expo_Date_Controller__c record : expoDateControllers) {
            if (record.Exhibition_Management__c != null) {
                expoInfoMap.put(record.Exhibition_Management__c, record);
            }
        }
   		for (Internal_Registration__c item: newList) {
   			if (item.Exhibition_Id__c != NULL) {
   			    Date lastRegistrationDate = expoInfoMap.get(item.Exhibition_Id__c).SignUp_End_Date__c;
   			    String nameCN = expoInfoMap.get(item.Exhibition_Id__c).Exhibition_Management__r.TitleCN__c == NULL ? '此展会' : expoInfoMap.get(item.Exhibition_Id__c).Exhibition_Management__r.TitleCN__c;
   			    String nameEN = expoInfoMap.get(item.Exhibition_Id__c).Exhibition_Management__r.TitleEN__c == NULL ? 'this Exhibition' : expoInfoMap.get(item.Exhibition_Id__c).Exhibition_Management__r.TitleEN__c; 
   			    if (lastRegistrationDate < Date.today()) item.addError(nameCN+'的截止报名时间为：'+ lastRegistrationDate + ', 展会内部报名时间已结束！ '
   			    	+ 'The registration deadline for '+ nameEN+ ' is ' + lastRegistrationDate + ' you have missed the registration time!');
   			}
   		}
    }

    public static void GenerateXHN(List<Internal_Registration__c> newList) {
        for (Internal_Registration__c item : newList) {
            //由邮箱转为对应信鸿号
            if(!String.isEmpty(item.Email__c)) {
                Integer atPosition = item.Email__c.indexOf('@');
                if (atPosition != -1) {
                    item.XHNumber__c = item.Email__c.substring(0, atPosition);
                }
            }
            if(String.isEmpty(item.Organization_Abbr__c) && !String.isEmpty(item.Company_Abbr__c)) {
                item.Organization_Abbr__c = ProcessStringLock(item.Company_Abbr__c);
            }
        }
    }

    public static String ProcessStringLock(String input) {
        if (!input.contains('\\')) { // 注意：需要转义反斜杠
            System.debug('字段中不包含 \\');
            return input;
        }
        // System.debug('部门' + inter.Company_Abbr__c);
        List<String> parts = input.split('\\\\', -1);
        Integer backslashCount = parts.size() - 1; 
        
        if (backslashCount < 2) {
            System.debug('\\ 的数量不超过两个，当前数量为：' + backslashCount);
            return input;
        } else {
            String result = '';
            for (Integer i = parts.size() - 3; i < parts.size(); i++) {
                result += '\\' + parts[i]; // 注意：重新添加转义的 \ 作为分隔符
            }
		    result = result.substring(1, result.length());
            System.debug('截取结果：' + result);
            return result;
        }   
    }

    public static void GenerateName(List<Internal_Registration__c> newList, List<Internal_Registration__c> oldList) {
        Map<Id, Internal_Registration__c> oldMap = new Map<Id, Internal_Registration__c>(oldList);    
        for (Internal_Registration__c item : newList) {
            Internal_Registration__c oldItem = oldMap.get(item.Id);
            boolean firstNameChanged = item.First_Name__c == null ? oldItem.First_Name__c != null : !item.First_Name__c.equals(oldItem.First_Name__c);
            boolean lastNameChanged = item.Last_Name__c == null ? oldItem.Last_Name__c != null : !item.Last_Name__c.equals(oldItem.Last_Name__c);
            boolean nameChanged = item.Name == null ? oldItem.Name != null : !item.Name.equals(oldItem.Name);
            
            if (firstNameChanged || lastNameChanged || nameChanged) {
                // 如果 First_Name__c 或 Last_Name__c 发生变化，重新设置 Name
                item.Name = (item.First_Name__c != null ? item.First_Name__c : '') + ' ' + (item.Last_Name__c != null ? item.Last_Name__c : '');
            }
        }
    }

    public static void  createNumCheck(List<Internal_Registration__c> newList, List<Internal_Registration__c> oldList){
        List<Id> newListId = new LisqContainer(newList).SelectSField('Id');
        Map<Id, Internal_Registration__c> oldMap = new Map<Id, Internal_Registration__c>(oldList);    

        Map<String, Decimal> tempTotalMap = new Map<String, Decimal>(); // 临时证的总数值
        Map<String, Decimal> exhibitorTotalMap = new Map<String, Decimal>(); // 参展商证的总数量
        // if((oldMap.get(item.Id).Certificate_Type__c != item.Certificate_Type__c || oldMap.get(item.Id).Validity_Date__c != item.Validity_Date__c )) {
        List<Expo_Certificate_Assignment__c> records = [SELECT Id,Approver__c,Region__c, Certificate_Quantity__c, Validity__c,Validity_Date__c,Expend_Quantity__c FROM Expo_Certificate_Assignment__c];
        Map<String, Expo_Certificate_Assignment__c> assMap = new Map<String, Expo_Certificate_Assignment__c>();
        List<Expo_Certificate_Assignment__c> assList = new List<Expo_Certificate_Assignment__c>();
        for (Expo_Certificate_Assignment__c record : records) {
            String approval = String.isNotEmpty(record.Approver__c) ? record.Approver__c : '';
            String region = String.isNotEmpty(record.Region__c) ? record.Region__c : '';
            tempTotalMap.put(approval + region, record.Validity__c);
            exhibitorTotalMap.put(approval + region,record.Certificate_Quantity__c);
        }

        List<Internal_Registration__c> intCount = [Select Id,Approver__c,Company__c,Certificate_Type__c,Validity_Date__c from Internal_Registration__c Where Id NOT IN: newListId And Exhibition_Id__c =: newList[0].Exhibition_Id__c  And (Certificate_Type__c INCLUDES ('参展商证|Exhibition Badge') or Certificate_Type__c INCLUDES ('临时证|Day Voucher'))];

        Map<String, Decimal> tempCertMap = new Map<String, Decimal>(); // 临时证的累计数值
        Map<String, Decimal> exhibitorCertMap = new Map<String, Decimal>(); // 参展商证的累计数量
        tempMap = new Map<String, Decimal>(); // 临时证的可用数值
        // Map<String, Decimal> exhibitorMap = new Map<String, Decimal>(); // 参展商证的可用数量
        exhibitorMap = new Map<String, Decimal>(); // 参展商证的可用数量
        // 遍历查询结果
        If(intCount.size() > 0) {
            for (Internal_Registration__c record: intCount) {
                String approval = String.isNotEmpty(record.Approver__c) ? record.Approver__c : '';
                String company = String.isNotEmpty(record.Company__c) ? record.Company__c : '';
                String key = approval + company; // 组合键
                if (record.Certificate_Type__c.contains(Temporary_Certificate)) {
                    // 处理临时证
                    if (String.isNotEmpty(record.Validity_Date__c) && !record.Validity_Date__c.equals('None')) {
                        // 分割并累加数值
                        List<String> values = record.Validity_Date__c.split(';');
                        Decimal total = 0;
                        for (String value : values) {
                            try {
                                total += 1;
                            } catch (Exception e) {
                                // 忽略非法数值
                            }
                        }
                        // 累加到 Map 中
                        tempCertMap.put(key, tempCertMap.containsKey(key) ? tempCertMap.get(key) + total : total);
                    }
                } else if (record.Certificate_Type__c.contains(Exhibitor_Card)) {
                    // 处理参展商证
                    exhibitorCertMap.put(key, exhibitorCertMap.containsKey(key) ? exhibitorCertMap.get(key) + 1 : 1);
                }
            }
            for (String key : tempTotalMap.keySet()) {
                Decimal value = 0;
                if(tempCertMap.containsKey(key)) {value = tempCertMap.get(key);}
                tempMap.put(key, tempTotalMap.get(key) - value);
            }
            for (String key : exhibitorTotalMap.keySet()) {
                Decimal value = 0;
                if(exhibitorCertMap.containsKey(key)) {value = exhibitorCertMap.get(key);}
                exhibitorMap.put(key, exhibitorTotalMap.get(key) - value);
            }
            // 输出结果
            // System.debug('临时证可使用数值：' + tempMap);
            // System.debug('参展商证可使用数量：' + exhibitorMap);
        } else {
            tempMap = tempTotalMap;
            exhibitorMap = exhibitorTotalMap;
            // System.debug('临时证可使用数值：' + tempMap);
            // System.debug('参展商证可使用数量：' + exhibitorMap);
        }
        List<Internal_Registration__c> intList = new List<Internal_Registration__c>();
        errorMap = new Map<String,String>(); //记录错误文案
        Map<String,Boolean> booleanMap = new Map<String,Boolean>();//记录组操作是否有超限情况
        for (Internal_Registration__c item : newList) {
            String approval = String.isNotEmpty(item.Approver__c) ? item.Approver__c : '';
            String company = String.isNotEmpty(item.Company__c) ? item.Company__c : '';
            String key = approval + company; // 组合键
            String compositeKey = key + item.Name_CN__c;
        
            if (String.isNotEmpty(item.Certificate_Type__c)) {
                handleCertificateType(item, key, compositeKey, approval, company);
            }
        }
        // System.debug('错误集锦' + errorMap);
        for (Internal_Registration__c item: newList) {
            String approval = String.isNotEmpty(item.Approver__c) ? item.Approver__c : '';
            String company = String.isNotEmpty(item.Company__c) ? item.Company__c : '';
            String key = approval + company; // 组合键
            String compositeKey = key + item.Name_CN__c;
            if (errorMap.containsKey(compositeKey)) {
                String errorMessage = errorMap.get(compositeKey);
                addError(item, key, errorMessage);
            } else {
                Boolean hasError = false;
                for (String keyString : errorMap.keySet()) {
                    if (keyString.contains(key)) {
                        hasError = true;
                        break;
                    }
                }
                if (hasError) {
                    item.addError(System.label.Batch_Operation_Prompt);
                }
           }
        }
    }
    
    public static void handleCertificateType(Internal_Registration__c item, String key, String compositeKey, String approval, String company) {
        if (item.Certificate_Type__c.contains(Temporary_Certificate + '|') && item.Certificate_Type__c.contains(Exhibitor_Card)) {
            errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '既存在临时证又存在参展商证。请对证件进行合理配置！');
        } else if (item.Certificate_Type__c.contains(Temporary_Certificate +'|') || item.Certificate_Type__c.contains(Exhibitor_Card)) {
            handleSingleCertificateType(item, key, compositeKey, approval, company);
        } else if (String.isNotEmpty(item.Validity_Date__c) && !item.Validity_Date__c.equals('None')) {
            errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '的证件无需设置用证日期，请清空。');
        }
    }
    
    public static void handleSingleCertificateType(Internal_Registration__c item, String key, String compositeKey, String approval, String company) {
        if (item.Approver__c == null && item.Company__c == null) {
            errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '没有挂靠有效分配单位!');
        } else if (item.Approver__c != null && item.Company__c != null) {
            handleValidApproverAndCompany(item, key, compositeKey, approval, company);
        } else if (item.Approver__c == null && item.Company__c != null) {
            handleValidCompanyOnly(item, key, compositeKey, company);
        }
    }
    
    public static void handleValidApproverAndCompany(Internal_Registration__c item, String key, String compositeKey, String approval, String company) {
        if (item.Certificate_Type__c.contains(Temporary_Certificate + '|')) {
            handleTemporaryCertificate(item, key, compositeKey, approval, company);
        } else if (item.Certificate_Type__c.contains(Exhibitor_Card)) {
            handleExhibitorCertificate(item, key, compositeKey, approval, company);
        }
    }
    
    public static void handleValidCompanyOnly(Internal_Registration__c item, String key, String compositeKey, String company) {
        if (item.Certificate_Type__c.contains(Temporary_Certificate + '|')) {
            handleTemporaryCertificate(item, key, compositeKey, null, company);
        } else if (item.Certificate_Type__c.contains(Exhibitor_Card)) {
            handleExhibitorCertificate(item, key, compositeKey, null, company);
        }
    }
    
    public static void handleTemporaryCertificate(Internal_Registration__c item, String key, String compositeKey, String approval, String company) {
        if (String.isEmpty(item.Validity_Date__c) || item.Validity_Date__c.equals('None')) {
            errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '需要选择用证日期!');
        } else {
            String expendDate = item.Validity_Date__c;
            Decimal count = expendDate.split(';').size();
            if (tempMap.containsKey(key)) {
                if ((tempMap.get(key) - count) < 0) {
                    errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '的审批人' + approval + '负责区域' + company + '名下 临时证 证件超限无法分配！');
                } else {
                    tempMap.put(key, tempMap.get(key) - count);
                }
            } else {
                errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '没有挂靠有效分配单位!');
            }
        }
    }
    
    public static void handleExhibitorCertificate(Internal_Registration__c item, String key, String compositeKey, String approval, String company) {
        if (String.isNotEmpty(item.Validity_Date__c) && !item.Validity_Date__c.equals('None')) {
            errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '的证件无需设置用证日期，请清空。');
        } else {
            if (exhibitorMap.containsKey(key)) {
                if ((exhibitorMap.get(key) - 1) < 0) {
                    errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '的审批人' + approval + '负责区域' + company + '名下 参展商证 证件超限无法分配！');
                } else {
                    exhibitorMap.put(key, exhibitorMap.get(key) - 1);
                }
            } else {
                errorMap.put(compositeKey, '参展人：' + item.Name_CN__c + '没有挂靠有效分配单位!');
            }
        }
    }

    public static void addError(Internal_Registration__c item, String key, String errorMessage) {
        if (errorMessage.contains('参展商证 证件超限')) {
            item.addError('审核单位' + key + '名下参展商证 证件超限！');
        } else if (errorMessage.contains('临时证 证件超限')) {
            item.addError('审核单位' + key + '名下临时证 证件超限！');
        } else if (errorMessage.contains(item.Name_CN__c)) {
            item.addError(errorMessage);
        } else {
            item.addError(System.label.Batch_Operation_Prompt);
        }
    }

   /**
     * @description 自动创建行程信息
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void autoCreatedExhibitionArrangement(List<Internal_Registration__c> newList) {

        List<Exhibition_Arrangement__c> exhibitionArrList = new List<Exhibition_Arrangement__c>();

        List<Exhibition_Vehical_Booking__c> vehicalList = new List<Exhibition_Vehical_Booking__c>();
        List<Hotel_Booked_Info__c> hotelList = new List<Hotel_Booked_Info__c>();

        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();   

        List<String> exhibitionIdList = new LisqContainer(newList).SelectSField('Exhibition_Id__c');
        List<ExpoInfo__c> exhibitionList = [SELECT Id, Name, StartDate__c, EndDate__c, LastRegistrationDate__c FROM ExpoInfo__c WHERE Id IN:exhibitionIdList];
        Map<Id, ExpoInfo__c> exhibitionMap = new Map<Id, ExpoInfo__c>(exhibitionList);

        EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
                                            FROM EmailTemplate
                                            WHERE DeveloperName = 'Exhibition_Registration_Success_SMS' LIMIT 1];
        // <- 20240913 释放SMS推送 ->
        Map<String, List<String>> personInfoMap = new Map<String, List<String>>();

        for (Internal_Registration__c item: newList) {

            // String exhibitionDateStr = '';
            // if(exhibitionMap.containskey(item.Exhibition_Id__c)) {
            //     for(Date indexDate = exhibitionMap.get(item.Exhibition_Id__c).StartDate__c; indexDate <= exhibitionMap.get(item.Exhibition_Id__c).EndDate__c;) {
            //         exhibitionDateStr += indexDate.format() + ',';
            //         indexDate=indexDate.addDays(1);
            //     }
            // }


            //TJP 20250225 注释增加行程 start  
            // Exhibition_Arrangement__c ea = new Exhibition_Arrangement__c(
            //     Name = '行程信息-'+item.Name_CN__c+'_'+Date.today().year()+Date.today().month()+Date.today().day(),
            //     Internal_Registration__c = item.Id
            //     // PresenceInformation__c = exhibitionDateStr
            // );
            // exhibitionArrList.add(ea);
            // System.debug('New Exhibition_Arrangement__c: ' + ea);
            //TJP 20250225 注释增加行程 end

            Exhibition_Vehical_Booking__c ev = new Exhibition_Vehical_Booking__c(
                // Name = '行程信息-'+item.Name_CN__c+'_'+Date.today().year()+Date.today().month()+Date.today().day(),
                Internal_Registration__c = item.Id,
                ExpoInfo_Id__c = item.Exhibition_Id__c
                // PresenceInformation__c = exhibitionDateStr
            );
            vehicalList.add(ev);
            Hotel_Booked_Info__c hb = new Hotel_Booked_Info__c(
                // Name = '行程信息-'+item.Name_CN__c+'_'+Date.today().year()+Date.today().month()+Date.today().day(),
                Residents__c = item.Id,
                Exhibition_Management__c = item.Exhibition_Id__c
                // PresenceInformation__c = exhibitionDateStr
            );
            hotelList.add(hb);


            List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, item.Id, new List<String>{tempOfSMS.Body});
            String contentOfSMS = renderEmailTemplateBodyRes[0].getMergedBody();
            // 提交成功，并发送邮件提示

            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setSaveAsActivity(false);
            singleEmail.setTemplateId(tempOfSMS.Id);
            singleEmail.setSubject(tempOfSMS.Subject + '');
            singleEmail.setPlainTextBody(contentOfSMS);
            singleEmail.setWhatId(item.Id);
            //设置发送人邮箱
            singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
            singleEmail.setToAddresses(new List<String>{item.Email__c});
            sendEmailList.add(singleEmail);

            // 提交完成发送短信通知 
            //短信取消20240901 <- 20240913 释放SMS推送 ->
            if(personInfoMap.containskey(item.Phone__c)) {
                personInfoMap.get(item.Phone__c).add(contentOfSMS);
            } else {
                personInfoMap.put(item.Phone__c, new List<String>{contentOfSMS});
            }
        }
        // INSERT exhibitionArrList;
        INSERT vehicalList;
        INSERT hotelList;


        Organization orgs = [SELECT Id, IsSandbox FROM Organization Limit 1];
        if (sendEmailList.size() > 0) {
            if (!(Test.isRunningTest() || orgs.IsSandbox)) {
                Messaging.sendEmail(sendEmailList);
            }
        }
        //短信取消20240901 <- 20240913 释放SMS推送 ->

        if(!orgs.IsSandbox) {
            // ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        }

   }

   /**
     * @description 发送邮件通知用户，可以填写行程信息了
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void sendEmail(List<Internal_Registration__c> newList, List<Internal_Registration__c> oldList){

        String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0];
        Map<Id, Internal_Registration__c> oldMap = new Map<Id, Internal_Registration__c>(oldList);

        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE DeveloperName = 'Exhibition_Internal_Registration_Approved' LIMIT 1];
        EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
                                        FROM EmailTemplate
                                        WHERE DeveloperName = 'Exhibition_Internal_Registration_Approved_SMS' LIMIT 1];
        // EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
        //     FROM EmailTemplate
        //     WHERE DeveloperName = 'IFA_Internal_Registration_Approved' LIMIT 1];
        //     EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
        //                                 FROM EmailTemplate
        //                                 WHERE DeveloperName = 'IFA_Internal_Registration_Approved_SMS' LIMIT 1];
        EmailTemplate notice = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Book_Meeting_Room' LIMIT 1];   
        //拼凑行程信息
        List<Id> irList = new LisqContainer(newList).SelectSField('Id');
        // List<Exhibition_Arrangement__c> eaList = [SELECT Id, Internal_Registration__c FROM Exhibition_Arrangement__c WHERE Internal_Registration__c IN: irList];
        // Map<Id, Id> iREaMap  = new Map<Id, Id>();//员工-行程信息映射Map
        // for (Exhibition_Arrangement__c eaItem: eaList) {
        //     iREaMap.put(eaItem.Internal_Registration__c, eaItem.Id);
        // }

        List<Id> expoInfoIdList = new LisqContainer(newList).SelectSField('Exhibition_Id__c'); 
        // Map<Id, ExpoInfo__c> exhiMap = new Map<Id, ExpoInfo__c>([SELECT Id, TitleCN__c, TitleEN__c, StartDate__c, EndDate__c FROM ExpoInfo__c WHERE Id IN:expoInfoIdList  ]);
            
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       
        //短信取消20240901 <- 20240913 释放SMS推送 ->
        Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
        for (Internal_Registration__c item : newList) {//是否和旧的做对比 TODO 旧的用Map
            if (item.Approval_Status__c == '审批通过' && oldMap.get(item.Id).Approval_Status__c != item.Approval_Status__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setSaveAsActivity(false);
                singleEmail.setTemplateId(emtemp.Id);
                singleEmail.setSubject(emtemp.Subject + '');
                String toName = item.Name_CN__c != NULL ? item.Name_CN__c : item.Name_EN__c;
                // String strDate = exhiMap.get(item.Exhibition_Id__c).StartDate__c == NULL ? ' ' : String.valueOf(exhiMap.get(item.Exhibition_Id__c).StartDate__c);
                // String exhiName = exhiMap.get(item.Exhibition_Id__c).TitleCN__c;
                //add by lihao2024-03-29 start
                String certificateType_CN = '';
                String certificateType_EN = '';
                String certificate = item.Certificate_Type__c;
                if(String.isNotBlank(certificate)){
                    certificate = certificate.replaceALL(';','|');
                    Integer i =1;
                    for(String str:certificate.split('\\|')){
                        Boolean flag = Math.mod(i,2)==0?true:false;
                        if(String.isNotBlank(str)&&!flag){
                            certificateType_EN += str+';';
                        }else if(String.isNotBlank(str)&&flag){
                            certificateType_CN += str+';';
                        }
                        i++;
                    }
                }
                //add by lihao2024-03-29 end
                // String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, strDate, exhiName, SITE_URL_FRO+SITE_URL_MID+iREaMap.get(item.Id),certificateType_CN,certificateType_EN});
                String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, null, null, SITE_URL_FRO+SITE_URL_MID,certificateType_CN,certificateType_EN});
                singleEmail.setHtmlBody(bodyFormat);
                //设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
                singleEmail.setToAddresses(new List<String>{item.Email__c});
                // singleEmail.setCcAddresses(item.Email__c);
                System.debug('bodyFormat--->'+bodyFormat);
                //sendEmailList.add(singleEmail);
                Utility.sendMail(emtemp.Subject + '', bodyFormat, new List<String>{item.Email__c}, '海信展会', '');

                // 短信
                List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, item.Id, new List<String>{tempOfSMS.Body});
                if(personInfoMap.containskey(item.Phone__c)) {
                    personInfoMap.get(item.Phone__c).add(renderEmailTemplateBodyRes[0].getMergedBody());
                } else {
                    personInfoMap.put(item.Phone__c, new List<String>{renderEmailTemplateBodyRes[0].getMergedBody()});
                }
            }
            if (item.If_Inform__c && !oldMap.get(item.Id).If_Inform__c) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
				String toEmail = item.Email__c;
				List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(item.OwnerId, item.Id, new List<String>{notice.HtmlValue});
				String body = renderEmailTemplateBodyRes[0].getMergedBody();
				System.debug('body=' + body);
				singleEmail.setHTMLBody(body);
				singleEmail.setSaveAsActivity(false);
				// singleEmail.setTemplateId(emtemp.Id);
				// singleEmail.setWhatId(item.Id);
				singleEmail.setSubject(notice.Subject + '');
				//设置发送人邮箱
				singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				singleEmail.setToAddresses(new List<String>{toEmail});
				sendEmailList.add(singleEmail); 
            }
        }

        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            try {
                Messaging.sendEmail(sendEmailList);
            }
            catch (Exception e) {
                
            }
            
           
        }
        
        if(personInfoMap.keyset().size() > 0) {
            // ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        }
        

        
   }

   
}