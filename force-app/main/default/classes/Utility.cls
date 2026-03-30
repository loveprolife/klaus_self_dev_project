/**************************************************************************************************
* Name:Utility
* Purpose:公共方法类
* Author: Deloitte Johnson
* Create Date: 2019-02-20
***************************************************************************************************/
public class Utility { 
    public class PicklistItem{
        public String value;
        public String label;
    }
    /**
方法名: getPicklistValueMap
功能说明: 根据对象名，字段名获取picklist字段选项value=>label的Map映射
参数说明: String objectName,String fieldName
返回值: map<String,string >
作者: Johnson
日期: 2019-02-20
*/
    public static map<String,string > getPicklistValueMap(String objectName,String fieldName){ 
        Map<String,String> picklistMap = new Map<String,String>();
        
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry a : picklistEntries){
            picklistMap.put(a.getValue(),a.getLabel());
        }
        return picklistMap;
    }

    public static List<map<String,string >> getPicklistValueMapOption(String objectName,String fieldName,Boolean hasNone){ 
        List<map<String,string >> picklistMap = new List<map<String,string >>();
        if(hasNone){
            Map<String,String> m = new Map<String,String>();
            m.put('value','');
            m.put('label',Label.None);
            picklistMap.add(m);
        }
        
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry a : picklistEntries){
            Map<String,String> m = new Map<String,String>();
            m.put('value',a.getValue());
            m.put('label',a.getLabel());
            picklistMap.add(m);
        }
        return picklistMap;
    }
    /**
方法名: getPicklistValueList
功能说明: 根据对象名，字段名获取picklist字段选项list
参数说明: String objectName,String fieldName
返回值: List<PicklistItem>
作者: Johnson
日期: 2019-02-20
*/
    public static List<PicklistItem> getPicklistValueList(String objectName,String fieldName){ 
        List<PicklistItem> picklistValueList = new List<PicklistItem>();
        
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        
        for(Schema.PicklistEntry entry : picklistEntries){
            PicklistItem item = new PicklistItem();
            item.value = entry.getValue();
            item.label = entry.getLabel();
            picklistValueList.add(item);
        }
        return picklistValueList;
    }
    /**
方法名: getRecordTypeMapBySobj
功能说明: 根据记录类型名称获取记录Id, 或者根据记录Id得到记录名称
参数说明: 
返回值: Map<String,String>
作者: Johnson
日期: 2019-02-20
*/
    public static Map<String, String> getRecordTypeMapBySobj(String sobj) {
        Map<String, String> sobjMap = new Map<String, String>();
        for(RecordType rt :[SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :sobj AND IsActive = TRUE]){
            sobjMap.put(rt.DeveloperName, rt.Id);
            sobjMap.put(rt.Id, rt.DeveloperName);   //id => developer name
        }
        return sobjMap;        
    }
    /**
方法名: getCurrencyRateMap
功能说明: 获得货币汇率Map
参数说明: 
返回值: Map<String,Decimal> Currency type => Rate, Rate表示本位币(美元)转换成其他币种的汇率
作者: Johnson
日期: 2019-02-20
*/
    public static Map<String, Decimal> getCurrencyRateMap() {
        Map<String, Decimal> currencyRateMap = new Map<String, Decimal>();
        for(CurrencyType cType :[SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE]){
            currencyRateMap.put(cType.IsoCode, cType.ConversionRate);   //Currency type => Rate
        }
        return currencyRateMap;        
    }
    /**
方法名: getCurrencyRateMap
功能说明: 获得货币历史汇率Map
参数说明: 
返回值: Map<String,Decimal> Currency type + Year + Month => Rate, Rate表示本位币(美元)转换成其他币种的汇率
作者: Johnson
日期: 2019-07-11
*/
    public static Map<String, Decimal> getCurrencyRateHistoryMap() {
        Map<String, Decimal> currencyRateHistoryMap = new Map<String, Decimal>();
        //只查询最近三年的历史汇率
        Set<String> yearSet = new Set<String>();
        for(Integer i=0; i<=2; i++){
            yearSet.add(System.now().addYears(-i).format('yyyy'));
        }
        for(Currency_Rate_History__c cType :[SELECT CurrencyIsoCode, Conversion_Rate__c,Year__c,Month__c 
                                             FROM Currency_Rate_History__c WHERE IsActive__c = TRUE AND Year__c IN:yearSet]){
                                                 currencyRateHistoryMap.put(cType.CurrencyIsoCode + cType.Year__c + cType.Month__c, cType.Conversion_Rate__c);   //Currency type + Year + Month => Rate
                                             }
        //取当前系统的实时汇率
        for(CurrencyType cType : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE]){
            currencyRateHistoryMap.put(cType.IsoCode + System.now().format('yyyyMM'), cType.ConversionRate);
        }
        return currencyRateHistoryMap;        
    }
    /**
方法名: getHisenseEntityCurrencyMap
功能说明: 根据销售组织代码获取组织币种
参数说明:  
返回值: Map<String,String> Hisense Entity => Currency Type
作者: Johnson
日期: 2019-07-31
*/
    public static Map<String,String> getHisenseEntityCurrencyMap(){
        Map<String,String> hEntityMap = new Map<String,String>();
        for (Mapping__c mp : [SELECT Id,CurrencyIsoCode,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c 
                              WHERE RecordType.DeveloperName =:Label.Business_Orgnization_and_Name_Mapping]){
                                  hEntityMap.put(mp.Name, mp.CurrencyIsoCode);
                              }
        return hEntityMap;
    }
    /**
方法名: getPriceBookIdByRegionOrCustomer
功能说明: 根据区域或者客户获得价格手册Id
参数说明: Quote__c 
返回值: Price book ID
作者: Johnson
日期: 2019-03-12
*/
    public static String getPriceBookIdByRegionOrCustomer(Quote__c quote) {
        String pbId = '';
        if(quote.RecordType != null && quote.RecordType.DeveloperName.contains('Sales_Department')
           && String.isBlank(quote.Pricebook__c)){
               pbId = Label.Price_Book_ID_For_SD;
           }else if(quote.RecordType != null && quote.RecordType.DeveloperName.contains('USA')){
               List<Pricebook__c> pbList = [SELECT Id,Name FROM Pricebook__c 
                                            WHERE Customer__c =:quote.Customer_Name__c AND IsActive__c = TRUE LIMIT 1];
               if(pbList.size() > 0){
                   pbId = pbList[0].Id;
               }
           }else if(quote.RecordType != null && quote.RecordType.DeveloperName.contains('Malaysia')&& String.isNotBlank(quote.Price_Book_Region__c)){
               List<Pricebook__c> pbList = [SELECT Id,Name FROM Pricebook__c 
                                            WHERE Price_Book_Region__c =:quote.Price_Book_Region__c AND IsActive__c = TRUE LIMIT 1];
               if(pbList.size() > 0){
                   pbId = pbList[0].Id;
               }
           } 
        return pbId;      
    }
    /**
方法名: getQueryStringByFieldMap
功能说明: 根据对象字段Map返回SQL查询语句
参数说明: Map<String,Schema.SObjectField> objLoopMap 
返回值: String queryString
作者: Johnson
日期: 2019-03-27
*/
    public static String getQueryStringByFieldMap(Map<String,Schema.SObjectField> objLoopMap){
        String queryString = '';
        for (String fieldApi : objLoopMap.keySet()) {
            if (queryString <> '') {
                queryString += ',';
            }
            queryString += fieldApi;
        }
        return queryString;
    }
    /**
description：handle error message
parameters：original error message
return value：proper error message
**/        
    public static String getProperErrorMessage(String exceptionMsg){
        //validation error message
        if(exceptionMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('ENTITY_IS_LOCKED')){
            exceptionMsg = 'The record has been locked!';    
        }else if(exceptionMsg.contains('FIELD_INTEGRITY_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_INTEGRITY_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION,', ': [');
        }    
        return exceptionMsg;
    }
    /**
方法名: addErrorToRecord，避免测试类执行导致报错
功能说明: Trigger报错
参数说明: SObject sObj,String errorMessage 
返回值: 
作者: Johnson
日期: 2019-05-10
*/
    public static void addErrorToRecord(SObject sObj,String errorMessage){
        if(Test.isRunningTest()){
            System.debug('test');
        }else{
            sObj.addError(errorMessage);
        }
        
    }
    
    /**
方法名: insertLog，避免测试类执行导致报错
功能说明: 接口报错
参数说明: String errorClass,String returnCode,String reqJson,String errorMsg 
返回值: 
作者: Gerry
日期: 2019-05-13
**/
    public static void insertLog(String errorClass,String returnCode,String reqJson,String errorMsg){
        InterfaceLog__c interfaceLog = new InterfaceLog__c();
        interfaceLog.Class__c = errorClass;
        interfaceLog.Time__c = System.now();
        interfaceLog.ReturnCode__c = returnCode;
        interfaceLog.Req_Json__c = reqJson;
        interfaceLog.ErrorMsg__c = errorMsg;
        Database.insert(interfaceLog);
    }
    
    /**
方法名: insertBatchLog，避免测试类执行导致报错
功能说明: Batch报错
参数说明: String errorClass,String errorMsg
返回值: 
作者: Gerry
日期: 2019-05-14
**/
    public static void insertBatchLog(String errorClass,String errorMsg){
        BatchLog__c log = new BatchLog__c();
        log.Class__c = errorClass;
        log.Time__c = System.Now();
        log.ErrorMsg__c = errorMsg;
        Database.insert(log);
    }
    /**
方法名: isExistProductLine
功能说明: 判断销售关系中是否包含数某数据产品线
参数说明: String errorClass,String errorMsg
返回值: Boolean isExist true/false
作者: Johsnon 
日期: 2019-09-05
**/
    public static Boolean isExistProductLine(String salesProductLine,String dataProductLine){
        Boolean isExist = false;
        List<String> productLineList = salesProductLine.split(';');
        for(String productLine : productLineList){
            if(productLine.equals(dataProductLine)){
                isExist = true; 
                break ;
            }
        }
        return isExist;
    }
    
    //这是一个trigger的控制开关
    public static Boolean isTriggerDisabled() {
        if (!Test.isRunningTest()) {
            GlobalSetting__c gs = GlobalSetting__c.getInstance();
            if (gs != null && gs.IgnoreTrigger__c) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    
    /**
* @description 忽略触发器,验证规则操作
* @author chengpeng@deloitte.com.cn | 06-29-2021 
* @param isIgnoreTrigger 
* @param isIgnoreValidation 
* @param isIgnoreWorkflow 
* @param isIgnore  忽略/恢复
* @param LastAddress 
* @param gs 
* @return GlobalSetting__c 
* @use ignore : GlobalSetting__c ignoreGs = Utility.IgnoreAction(true,true,true,false,'ConfirmProductSolutionController',new GlobalSetting__c());
* @user return :   Utility.IgnoreAction(false,false,false,true,'',ignoreGs); 
**/
    public static GlobalSetting__c IgnoreAction(
        Boolean isIgnoreTrigger, 
        Boolean isIgnoreValidation, 
        Boolean isIgnoreWorkflow, 
        String LastAddress){
            
            List<GlobalSetting__c> gsList = [SELECT Id, 
                                             SetupOwnerId, 
                                             IgnoreTrigger__c,
                                             IgnoreValidation__c,
                                             IgnoreWorkflow__c
                                             FROM GlobalSetting__c  
                                             WHERE SetupOwnerId = :UserInfo.getUserId()];
            GlobalSetting__c gs;
            if (gsList.size() > 0) {
                gs = gsList[0];
            } else {
                gs = new GlobalSetting__c();
            }
            gs.SetupOwnerId = UserInfo.getUserId();
            gs.IgnoreTrigger__c = isIgnoreTrigger;
            gs.IgnoreValidation__c = isIgnoreValidation;
            gs.IgnoreWorkflow__c = isIgnoreWorkflow;
            gs.Last_Address__c = LastAddress;
            UPSERT gs;
            return gs;
        }
    
    // 保存门店产品图片集参数到全局变量
    public static Img_Parameter_Setting__c SaveImgParameter(
        String accId, 
        String shopId, 
        String productId,
        Boolean flag){
            
            List<Img_Parameter_Setting__c> gsList = [SELECT Id, 
                                                     SetupOwnerId, 
                                                     accId__c,
                                                     shopId__c,
                                                     productId__c
                                                     FROM Img_Parameter_Setting__c  
                                                     WHERE SetupOwnerId = :UserInfo.getUserId()];
            Img_Parameter_Setting__c gs;
            if (gsList.size() > 0) {
                gs = gsList[0];
            } else {
                gs = new Img_Parameter_Setting__c();
            }
            if(flag){
                gs.SetupOwnerId = UserInfo.getUserId();
                gs.accId__c = accId;
                gs.shopId__c = shopId;
                gs.productId__c = productId;
                UPSERT gs;
            }
            return gs;
        }
    
    /**
* @description Dynamic Code Split by number
* @author chenpeng@deloitte.com.cn | 01-05-2022 
* @param sObjectList 
* @param groupSize 
* @return List<List<SObject>> 
**/
    public static List<List<SObject>> splitList(List<SObject> sObjectList, Integer groupSize){
        Integer sObjectListLength = sObjectList.size();
        Integer num = (sObjectListLength + groupSize - 1) / groupSize;
        List<List<SObject>> newSObjectList = new List<List<SObject>>();
        for (Integer i = 0; i < num; i++) {
            List<SObject> inforSobjectList = new List<SObject>();
            
            // 开始位置
            Integer fromIndex = i * groupSize;
            
            //结束
            Integer toIndex = (i+1) * groupSize < sObjectListLength ? ( i+1 ) * groupSize : sObjectListLength ;
            for (Integer j = fromIndex; j < toIndex; j++) {
                inforSobjectList.add(sObjectList[j]);
            }
            newSObjectList.add(inforSobjectList);
        }
        return  newSObjectList;
    }
    
    public static Map<Integer, String> splitString(String str, Decimal size) {
        Map<Integer, String> splitStrMap = new Map<Integer, String>();
        Integer index = 0;
        
        //可分成份数
        Integer num = Integer.valueOf(Math.ceil(str.length() / size));
        for (Integer i = 0; i < num; i++) {
            // 开始位置
            Integer fromIndex = i * Integer.valueOf(size);
            
            Integer toIndex = (i+1) * Integer.valueOf(size) < str.length() ? ( i+1 ) * Integer.valueOf(size) : str.length() ;
            String splitStr = str.substring(fromIndex, toIndex);
            splitStrMap.put(i+1, splitStr);
        }
        return splitStrMap;
    }
    
    /**
* @description 长文本换行
* @author chenpeng@deloitte.com.cn | 09-27-2021 
* @param str 
* @param num 
* @param issegmentation 
* @return String 
**/
    public static String ConvertString(String str, Integer num) {
        List<String> proDecList = new List<String>();
        if (String.isBlank(str)) {
            return '';
        }
        proDecList.add(str);
        
        String converStr = '';
        for (String proDec : proDecList) {
            String strword = proDec;
            Decimal leng = 0;
            String tmp = '';
            Integer j = 1;
            Integer k = 0;
            Decimal z = num;
            
            for (Integer i=0; i < strword.length(); i++) {
                if ((strword.charAt(i) >= 19968 && 
                     strword.charAt(i) <= 171941) || 
                    (strword.charAt(i) == 64) || 
                    (strword.charAt(i) == 12289)) {
                        leng = leng + 2;
                    } else if (strword.charAt(i) == 109) {
                        leng = leng + 1.5;
                    } else if ((strword.charAt(i) >= 60 && strword.charAt(i) <= 122 ) ){
                        leng = leng + 1.6;
                    } else if ((strword.charAt(i) == 49) || 
                               (strword.charAt(i) == 105) || 
                               (strword.charAt(i) == 106) || 
                               (strword.charAt(i) == 108)  || 
                               (strword.charAt(i) == 116)){
                                   leng = leng + 0.6;
                               }
                else if ((strword.charAt(i) == 46) || (strword.charAt(i) == 58)){
                    leng = leng + 0.4;
                } else if (strword.charAt(i) >= 48 && strword.charAt(i) <= 57){
                    leng = leng + 1.1;
                } else if (strword.charAt(i) == 95){
                    leng = leng + 1;
                } else {
                    leng = leng + 1.1;
                }
                
                //如果数据大与给定的Number增加<br/>
                if (leng >= z){     
                    tmp = tmp + strword.mid(k,j) + '\n';
                    leng = 0;
                    j = 0;
                    k = i+1;
                }
                
                
                if (i == (strword.length() - 1)) {
                    tmp = tmp + strword.mid(k,j+1);
                }
                
                // if (issegmentation) {
                //     String w = strword.substring(i, i+1);
                //     String reg =';';
                //     if(w==reg){
                //         tmp = tmp + strword.mid(k,j) + '\n';
                //         leng = 0;
                //         j = 0;
                //         k = i+1;
                //     }
                // }
                
                j++;
            }
            converStr += tmp;
        }
        
        return converStr;
    }
    
    public static String nextSchedulableTime(Integer callTime){
        Datetime dt = Datetime.now().addMinutes(callTime);
        String fmt = '{0} {1} {2} {3} {4} ? {5}';
        List<String> argList = new List<String>();
        argList.add(String.valueOf(dt.second()));
        argList.add(String.valueOf(dt.minute()));
        argList.add(String.valueOf(dt.hour()));
        argList.add(String.valueOf(dt.day()));
        argList.add(String.valueOf(dt.month()));
        argList.add(String.valueOf(dt.year()));
        fmt = String.format(fmt, argList);
        return fmt;
    }
    
    public static List<String> getLockRecord(List<Id> recordIdList) {
        List<String> lockRecordList = new List<String>();
        Map<Id,Boolean> isLockedMap = Approval.isLocked(recordIdList);
        for(Id checkId : recordIdList){
            Boolean isLocked = isLockedMap.get(checkId) == null ? false : isLockedMap.get(checkId);
            if(isLocked){
                Approval.UnLockResult unLockResult = Approval.unlock(checkId);
                lockRecordList.add(checkId);
            }
        }
        
        return lockRecordList;
    }
    
    /*
功能： 根据id获取对应对象的名称
参数： String类型的Id
返回： String
*/
    public static String getSobjectName(String record) {
        if (String.isBlank(record)) {
            return null;
        }
        Id recordId = (Id)record;
        return recordId.getSobjectType().getDescribe().getName();
    }
    
    public static List<String> setConverList(Set<String> strSet){
        List<String> strList = new List<String>();
        for (String str : strSet) {
            strList.add(str);
        }
        
        return strList;
    }
    
    public class UtilsException extends Exception{}
    
    /**
* @description 发送电子邮件
* @author chenpeng@deloitte.com.cn | 01-25-2022 
* @param subject 邮件主题
* @param htmlBody 邮件内容
* @param toAddress 邮件接收人Email列表
* @param senderDisplayName 
* @param replyTo 
**/
    public static void sendMail(String subject, String htmlBody, List<String> toAddress, String senderDisplayName, String replyTo) {
        
        System.debug(LoggingLevel.INFO, '*** toAddress: ' + toAddress);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setBccSender(false);
        
        // 设置邮件主题
        if (String.isBlank(subject)) {
            throw new UtilsException(Label.EMAIL_SUBJECT_CANNOT_EMPTY);
        } else {
            mail.setSubject(subject);
        }
        
        // 设置邮件接收人
        if (toAddress.isEmpty()) {
            throw new UtilsException(Label.EMAIL_ACCEPTOR_CANNOT_EMPTY);
        } else {
            mail.setToAddresses (toAddress);
        }
        
        // 设置邮件内容
        if (String.isBlank(htmlBody)) {
            throw new UtilsException(Label.EMAIL_BODY_CANNOT_EMPTY);
        } else {
            mail.setHtmlBody(htmlBody);
        }
        
        // 设置邮件编码
        mail.setCharset('UTF-8');
        
        // 设置回复地址
        if (String.isNotBlank(replyTo)) {
            mail.setReplyTo(replyTo);
        }
        
        // 设置显示的发送人名字
        if (String.isNotBlank(senderDisplayName)) {
            mail.setSenderDisplayName(senderDisplayName);
        }
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
            
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('*** 邮件发送成功.');
                } else {
                    System.debug('*** 邮件发送失败，失败原因： ' + results[0].errors[0].message);
                }
            }
    }
    
    /*
方法名: sendChatterFuture
功能说明: 调用future方法进行chatter的发送
参数：List<Chatter>
*/
    @future
    public static void sendChatterFuture(String sendChatterJson){
        if(!Test.isRunningTest()){
            List<Chatter> chatterList = (List<Chatter>)JSON.deserialize(sendChatterJson, List<Chatter>.class);
            createChatterNotice(chatterList);
        }
    }
    
    /*
方法名: createChatterNotice
功能说明:创建chatter提醒
参数：chatterSet
返回值：Chatter结果
*/
    public static List<ConnectApi.BatchResult> createChatterNotice(List<Chatter> chatterSet) {
        List<ConnectApi.FeedItemInput> feedItemInputList = new List<ConnectApi.FeedItemInput>();
        List<ConnectApi.BatchResult> results = new List<ConnectApi.BatchResult>();
        
        for(Chatter obj : chatterSet) {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mentionSegmentInput.id = obj.ownerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            textSegmentInput.text = obj.message;
            messageBodyInput.messageSegments.add(textSegmentInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = obj.subjectId;
            feedItemInputList.add(feedItemInput);
        }
        
        // 准备发送Chatter提醒
        System.debug(LoggingLevel.INFO, '*** feedItemInputList: ' + feedItemInputList);
        
        if(feedItemInputList.size()>0)
        {
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for(ConnectApi.FeedItemInput feedItemInputData : feedItemInputList){
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInputData);
                batchInputs.add(batchInput);
            }
            if (!Test.isRunningTest()) {
                results = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        }
        
        System.debug(LoggingLevel.INFO, '*** results: ' + results);
        return results;
    }
    
    public static Set<String> conversionStringList(List<String> conversionList) {
        Set<String> conversionSet = new Set<String>();
        for (String str : conversionList) {
            conversionSet.add(str);
        }
        
        return conversionSet;
    }
    
    public static List<String> conversionStringSet(Set<String> conversionSet) {
        List<String> conversionList = new List<String>();
        for (String str : conversionSet) {
            conversionList.add(str);
        }
        
        return conversionList;
    }
    
    /*
内部类名: Chatter
功能说明: 组装发送chatter需要的信息
*/
    public class Chatter{
        public Id ownerId;
        public Id subjectId;
        public String message;
        public Chatter(Id ownerId, Id subjectId, String message) {
            this.ownerId = ownerId;
            this.subjectId = subjectId;
            this.message = message;
        }
    }
    
    /**
* Method : geolocationGetLatLng 
* Function : Get geolocation lat&lng by address  through geolocation api
* Params : String address
* Return : Map<String,Object>
* Author : wfc
* Date : 2022/02/21
*/
    public static Map<String,Object> geolocationGetLatLng (String address){
        Map<String,Object> locationMap = new  Map<String,Object>();
        try {
            //发送请求
            // String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAucQYfZ2tw2RBO7jieFwG27-BeldZVgFY&sensor=false';
            String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAevReUCBK5ntbBf525M-O31NcDc_Q-130&sensor=false';
            String currentUserLanguageKey = UserInfo.getLanguage();
            requestUrl = requestUrl + '&language=' + currentUserLanguageKey + '&address=' + EncodingUtil.urlEncode(address, 'UTF-8');
            System.debug(requestUrl);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
            
            String doc = '';
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            doc = res.getBody();
            system.debug('doc:' + doc);
            //提取地址信息
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(doc);
            
            if(String.valueOf(resultMap.get('status')) == 'OK'){
                List<Object> addressList = (List<Object>) resultMap.get('results');
                Map<String, Object> addressMap = (Map<String, Object>)addressList[0];
                Map<String, Object> geometryMap = (Map<String, Object>) addressMap.get('geometry');
                locationMap = (Map<String, Object>)geometryMap.get('location');
                //Add By Ethan 20230922 增加省份字段 Start
                locationMap.put('administrative_area_level_1', NULL);
                for(Object item: (List<Object>)addressMap.get('address_components')){
                    if(JSON.serialize(item).contains('administrative_area_level_1'))
                        locationMap.put('administrative_area_level_1', ((Map<String, Object>)item).get('long_name'));
                }    
                //Add By Ethan 20230922 增加省份字段 End
                
            }
            system.debug( 'resultMap:' + resultMap);
            system.debug(locationMap);
            
        } catch (Exception e) {
            
        }
        
        return locationMap;
    }
    
    public static void setNextSchedulable(String schedulableName, Integer nextSchedulableTime){
        //运行定时任务
        String fmt = nextSchedulableTime(nextSchedulableTime);
        String scheduledJob = schedulableName + '_' + fmt;
        Type t = Type.forName(schedulableName);
        Schedulable classInstance = (Schedulable)t.newInstance();
        System.schedule(scheduledJob, fmt, classInstance);
    }
    
    /**
* @description 使用邮件模板发送电子邮件
* @author wfc | 02-25-2022 
* @param whatId 
* @param toAddresses 
**/
    public static void sendEmailWithTextTemplate(Id whatId, List<String> toAddresses, String emailTemplateName) {
        EmailTemplate temp =  [
            SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId
            FROM EmailTemplate
            WHERE DeveloperName = :emailTemplateName
            LIMIT 1
        ];
        
        Contact contact = [SELECT ID FROM Contact LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // 设置邮件的发件人的显示名称；
        email.setSenderDisplayName(Label.Visit_Participant_Email_Display_Name);
        
        // 当使用email template时，此方法是必须使用的
        email.setTargetObjectId(contact.id);
        
        // 设置targetObjectId是否作为接收人接收此邮件，默认是true，如果不想将targetObjectId作为接收人，则设置为false；
        email.setTreatTargetObjectAsRecipient(false);
        
        // 如果设置了targetObjectId,则需要对它赋值为false，默认为true；
        email.setSaveAsActivity(false);
        
        // 如果template中使用了merge field,可以指定需要引用的object的ID，比如模板中使用了{!Account.Name},则需要设置whatId项为account的ID；
        email.setWhatId(whatId);
        
        // 设置email的template
        email.setTemplateId(temp.Id);
        // 设置接收人的email地址
        email.setToAddresses(toAddresses);
        
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            Utility.insertLog('sendEmailWithTextTemplate', '1', toAddresses.toString(), whatId);
        }
    }
    
    public static List<Object> getRecordListPage(String sql, String pageIndex, String pageSize){ 
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(sql));
        // 每页多少条
        con.setPageSize(Integer.valueOf(pageSize));
        // 当前返回第xx页
        con.setPageNumber(Integer.valueOf(pageIndex));
        // 给前端返回最大条数 
        con.getResultSize();
        // 获得当前页面数据
        List<Object> result =  con.getRecords();
        
        return result;
    }
    
    public static String increaseHoursInStringDate(String dateStr, Integer hoursToAdd) {
        // 将字符串转换为日期时间类型
        Datetime date1 = Datetime.valueOf(dateStr);
        // 给日期增加小时数
        //Datetime newDate = date1.addHours(-hoursToAdd);
        // 将日期时间类型转换回字符串格式
        return date1 + '';
    }
    
    public static void refreshReportCustom(String batchClass){ 
        // 修改自定义报表状态
        List<Report_Custom__c> reportCustomList = [SELECT Id, Last_Update_Time__c, Report_Status__c
                                                   FROM Report_Custom__c
                                                   WHERE Batch_Class__c = :batchClass];
        if (reportCustomList != null && reportCustomList.size() > 0){
            Report_Custom__c rc = reportCustomList[0];
            rc.Last_Update_Time__c = System.now();
            rc.Report_Status__c = 'Update complete';
            update rc;
        }
    }

    public static void refreshPhotoDownload(String batchClass,String salesRegion){ 
        System.debug('refreshPhotoDownload' + batchClass + ':' + salesRegion);
        // 修改自定义报表状态
        List<Update_Data_Event__c> updateList = [SELECT Id, Last_Update_Time__c, Update_Status__c
                                                   FROM Update_Data_Event__c
                                                   WHERE Batch_Class__c = :batchClass AND SBU__c =: salesRegion];
        if (updateList != null && updateList.size() > 0){
            Update_Data_Event__c rc = updateList[0];
            rc.Last_Update_Time__c = System.now();
            rc.Update_Status__c = 'Update complete';
            update rc;
        }
    }
    
    public static List<SObject> apexPagination(List<SObject> acclist, Integer page, Integer pageSize){
        //List<Account> acclist = [Select Id,Name FRom Account Order by Name desc];
        
        List<SObject> returnList=new List<SObject>();
        // 当前第N页
        if(page==1){
            if(acclist.size()>=pageSize){
                for(Integer i=0;i<pageSize;i++){
                    returnList.add(acclist[i]);
                }
            }
            else{
                for(SObject cs:acclist){
                    returnList.add(cs);
                }
            }
        }else{
            Integer size=page*pageSize;
            Integer lastsize=(page-1)*pageSize;
            if(acclist.size()>=size){
                for(Integer i=lastsize;i<size;i++){
                    returnList.add(acclist[i]);
                }
            }else if(acclist.size()>=lastsize&&acclist.size()<=size){
                for(Integer i=lastsize;i<acclist.size();i++){
                    returnList.add(acclist[i]);
                }
            }else if(acclist.size()<=lastsize){
                //return new Map<String, String> { 'status' => 'success', 'message' => '当前数据已全部显示.' };
            }
        }
        
        return returnList;
    }
    /**
    方法名: insertLogAsyn，避免测试类执行导致报错
    功能说明: 接口报错
    参数说明: String errorClass,String returnCode,String reqJson,String errorMsg 
    返回值: 
    作者: Chen Fen
    日期: 2024-11-08
    **/
    @future
    public static void insertLogAsyn(String errorClass,String returnCode,String reqJson,String errorMsg){
        InterfaceLog__c interfaceLog = new InterfaceLog__c();
        interfaceLog.Class__c = errorClass;
        interfaceLog.Time__c = System.now();
        interfaceLog.ReturnCode__c = returnCode;
        interfaceLog.Req_Json__c = reqJson;
        interfaceLog.ErrorMsg__c = errorMsg;
        try{
            
            Database.insert(interfaceLog);
            
        }catch(Exception e){
            
        }
        
    }
    
    /**
    * 获取当前用户最近的一条门店
    * @param currentLat - 当前经度
    * @param currentLong - 当前维度
    * @return 门店ID
    * @throws AuraHandledException 如果获取案件信息时出现问题
    * @作者: Collin 
    * @日期: 2024-12-12
    * @描述: 该方法获取当前用户最近的一条门店
    */
    @AuraEnabled
    public static String getNearestStore(String currentLat, String currentLong) {
        System.debug(currentLat);
        System.debug(currentLong);
        // 最近门店ID
        String nearestStoreId = null;
        Decimal shortestDistance = 999999.999; // 初始化为一个极大的值
        
        // 查询与用户相关的门店数据
        List<Responsible_Person__c> responsiblePersonList = 
            [SELECT 
             Id,
             Shop_Name__c,
             Shop_Name__r.Name,
             Shop_Name__r.Shop_Center_Location__c,
             Shop_Name__r.Shop_Center_Location__Latitude__s,
             Shop_Name__r.Shop_Center_Location__Longitude__s,
             Promoter_Attendance_Rule__r.Distance__c,
             RecordType__c
             FROM Responsible_Person__c 
             WHERE 
             Principal__c = :UserInfo.getUserId()];
        
        // 遍历计算最短距离
        for (Responsible_Person__c person : responsiblePersonList) {
            Location location = Location.newInstance(Decimal.valueOf(currentLat), Decimal.valueOf(currentLong));
            Decimal distance = 999999.999; // 初始化距离
            
            // 如果门店位置存在，计算与当前用户位置的距离
            if (person.Shop_Name__r.Shop_Center_Location__c != null) {
                distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c, 'km');
                
                // 如果当前门店距离比已知最短距离更近，则更新
                if (distance < shortestDistance) {
                    shortestDistance = distance;
                    nearestStoreId = person.Shop_Name__c; // 更新最近门店ID
                }
            }
        }
        
        return nearestStoreId; // 返回最近门店ID
    }

    //插入Customer&Extend&Bank History
    public static void insertCusHistoyr(String recordId, String recordType, String processCause, String recordBody, String newRecordType){
        Customer_Extend_Bank_History__c cebh = new Customer_Extend_Bank_History__c();
        cebh.Record_id__c = recordId;
        cebh.Record_type__c = recordType;
        cebh.Record_body__c = recordBody;
        cebh.New_record_body__c = newRecordType;
        cebh.Process_cause__c = processCause;
        
        insert cebh;
    }

    //获取表中全部字段
    public static String getAllFields(Schema.SObjectType objectType){
        List<String> accountFields = new List<string>(objectType.getDescribe().fields.getMap().keySet());
        return  String.join(accountFields, ',');
    }

    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-07-21 11:17:38
     * @Description: 获取字典表数据
     */    
    public static List<Dictionary__c> getDictionaryByType(String type){
        List<Dictionary__c> dictionaryList = [SELECT Id, Sales_Region__c, Store_Level__c, Overdue__c
                                                FROM Dictionary__c 
                                                WHERE Type__c = :type];
        return dictionaryList;
    }

    //批量设置Profile
    // public static void grantAccess( String sObjectName ) {
    //     // Strange but when I try to delete old records it raises internal salesforce error, but it works anyway even if we don't delete the previous records
    //     //Database.delete( [ select id from ObjectPermissions where Parent.IsOwnedByProfile = true and SobjectType = :sObjectName  ], false );
    //     List<ObjectPermissions > os = new List<ObjectPermissions >();
    //     List<PermissionSet> ps = [ select id from PermissionSet where IsOwnedByProfile = true];
    //     for (PermissionSet p:ps) {
    //         os.add( new ObjectPermissions(
    //             ParentId = p.Id, 
    //             SobjectType = sObjectName,
    //             //PermissionsCreate = true,
    //             //PermissionsDelete = true,
    //             //PermissionsEdit = true,
    //             //PermissionsModifyAllRecords = true,
    //             PermissionsRead = true
    //             //PermissionsViewAllRecords = true
    //         ));
    //     }
    //     Database.insert(os, false);
    // }

    //批量设置字段权限
    // String fieldStrs = 'MDG_Customer_Code__c,SAP_Customer_Code__c,Customer_Name_Local_Language__c,Guarantor_Country_Code__c,city__c,Postal_Code__c,Phone,Customer_Short_Name__c,Search_Term2__c,Address__c,	Global_Location_Number__c,Tax_Number4__c,VAT_Registration_Number__c,Approval_Status__c,';
    // List<String> fieldList = fieldStrs.split(',');
    // grantAccess('Customer_Address__c');
    // public static void grantAccess( String sObjectName ) {
    //     // Strange but when I try to delete old records it raises internal salesforce error, but it works anyway even if we don't delete the previous records
    //     //Database.delete( [ select id from ObjectPermissions where Parent.IsOwnedByProfile = true and SobjectType = :sObjectName  ], false );
    //     List<FieldPermissions > os = new List<FieldPermissions >();
    //     List<PermissionSet> ps = [ select id from PermissionSet where IsOwnedByProfile = true];
    //     for (PermissionSet p:ps) {
    //         for(String fieldStr : fieldList){
    //             os.add( new FieldPermissions(
    //                 ParentId = p.Id, 
    //                 SobjectType = sObjectName,
    //                 Field = sObjectName + '.' + fieldStr,
    //                 PermissionsEdit = true,
    //                 PermissionsRead = true
    //             ));
    //         }
            
    //     }
    //     Database.insert(os, false);
    // }
}