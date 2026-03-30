public with sharing class CommonLookUpController {

    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 

    public class RetrieveWrapper {
        //keyword:used to retrieve this
        @AuraEnabled
        public String retrieveKeyword{get;set;}
        //search group： values :(ALL FIELDS/EMAIL FIELDS/NAME FIELDS/PHONE FIELDS/SIDEBAR FIELDS)
        @AuraEnabled
        public String searchGroup{get;set;}
        //obj api name -> field    eg: account->Name
        @AuraEnabled
        public Map<String,String> objName2FieldMap{
        	get{
        		if(objName2FieldMap != null) {
        			Map<String,String> objLowerCaseName2FieldMap = new Map<String,String>();
        			for(String objName : objName2FieldMap.keySet()) {
        				objLowerCaseName2FieldMap.put(objName.toLowerCase(), objName2FieldMap.get(objName));
        			}
        			objName2FieldMap.clear();
        			objName2FieldMap = objLowerCaseName2FieldMap;
        		}
        		return objName2FieldMap;
        	}
        	set;
        }
        //obj api name -> condition eg : account -> where name like 'test%' order by name asc limit 10 offset 1
        @AuraEnabled
        public Map<String,String> objName2QueryConditionMap{get;set;}
    }

    public class SearchResultWrapperList {
        @AuraEnabled
        public Boolean isCanSend { get; set; }

        @AuraEnabled
        public List<SearchResultWrapper> addressSearchResultWrapper { get; set; }

        @AuraEnabled
        public List<SearchResultWrapper> ccSearchResultWrapper { get; set; }
    }

    public class SearchResultWrapper {
    	//sObject ID
        @AuraEnabled
    	public String objId { get; set; }
        //sobject api name  eg:Account
        @AuraEnabled
        public String objName{ get; set; }
        //sobject label name eg: Account
        @AuraEnabled
        public String objLabel { get; set; }
        //sObject Value
        @AuraEnabled
        public String objValue { get; set; }
        //sObject URL
        @AuraEnabled
        public String objUrl { get; set; }
        // Email
        @AuraEnabled
        public String objEmail { get; set; }
    }

    public class SendEmailField {
        @AuraEnabled
    	public String recordId { get; set; }

        @AuraEnabled
        public String ids{ get; set; }

        @AuraEnabled
        public String emailAddress { get; set; }
 
        @AuraEnabled
        public String usernameAddress { get; set; }
 
        @AuraEnabled
        public String ccIds { get; set; }
 
        @AuraEnabled
        public String ccEmailAddress { get; set; }

        @AuraEnabled
        public String ccUsernameAddress { get; set; }
    }

    public class ReturnResult{
        @AuraEnabled
        public String code; //code "0" means success, and other codes means failure

        @AuraEnabled
        public String msg;  //result message
    }

    @AuraEnabled
    public static List<SearchResultWrapper> search(RetrieveWrapper wrapper) {
        System.debug(LoggingLevel.INFO, '*** wrapper: ' + JSON.serialize(wrapper));
        String retrieveSQL = buildRetrieveSQL(wrapper);
        System.debug(LoggingLevel.INFO, '*** retrieveSQL: ' + retrieveSQL);
        List<SearchResultWrapper> searchResultWrappers = new List<SearchResultWrapper>();
        if(retrieveSQL == null || (!retrieveSQL.contains('FIND'))) {
            return null;
        }
        List<List<sObject>> searchResults = search.query(retrieveSQL);
        System.debug(LoggingLevel.INFO, '*** searchResults: ' + JSON.serialize(searchResults));
        if(searchResults.size() > 0) {
            for(List<sObject> objs : searchResults) {
                for(sObject obj : objs) {
                	SearchResultWrapper searchResultItem = new SearchResultWrapper();
                	searchResultItem.objId = obj.Id;
                	searchResultItem.objName = getAPINameByObjId(obj.Id);
                    searchResultItem.objLabel = getLabelNameByObjId(obj.Id);
                	String field2Fetch = wrapper.objName2FieldMap.get(searchResultItem.objName);// 多个值
                    List<String> field2FetchList = field2Fetch.split(',');
                    searchResultItem.objValue = '<';
                    for(String field3 : field2FetchList){
                        searchResultItem.objValue += (String)obj.get(field3) + '> <';
                        if(field3 == 'Address__c'){
                            searchResultItem.objEmail = (String)obj.get(field3);
                        }
                    }
                    searchResultItem.objValue = searchResultItem.objValue.substring(0, searchResultItem.objValue.length() - 2);
                    searchResultItem.objUrl = '/lightning/r/' + obj.Id + '/view';
                	searchResultWrappers.add(searchResultItem);
                }
            }
        }
        return searchResultWrappers;
    }

    @AuraEnabled
    public static SearchResultWrapperList searchById(String recordId) {
        SearchResultWrapperList searchResultWrapperList = new SearchResultWrapperList();
        List<SearchResultWrapper> searchResultWrappers = new List<SearchResultWrapper>();
        List<SearchResultWrapper> searchResultWrappersCC = new List<SearchResultWrapper>();
        System.debug('recordId：' + recordId);
        Send_Email__c se = [SELECT Id,Address_Ids__c,Address__c,Address_Usernames__c,Cc__c,Cc_Ids__c,Cc_Usernames__c FROM Send_Email__c WHERE Id = :recordId Limit 1];
        System.debug('se.Address_Ids__c: ' + se.Address_Ids__c);
        System.debug('se.Address__c: ' + se.Address__c);
        System.debug('se.Address_Usernames__c: ' + se.Address_Usernames__c);
        System.debug('se.Cc_Ids__c: ' + se.Cc_Ids__c);
        System.debug('se.Cc__c: ' + se.Cc__c);
        System.debug('se.Cc_Usernames__c: ' + se.Cc_Usernames__c);
        if(String.isNotBlank(se.Address_Ids__c)){
            List<String> idList = se.Address_Ids__c.split(',');
            List<String> addressList = se.Address__c.split(',');
            List<String> addressUsernameList = se.Address_Usernames__c.split(',');

            for (Integer i = 0; i < idList.size(); i++) {
                SearchResultWrapper searchResultItem = new SearchResultWrapper();
                searchResultItem.objId = idList[i];
                searchResultItem.objName = getAPINameByObjId(idList[i]);
                searchResultItem.objLabel = getLabelNameByObjId(idList[i]);
                searchResultItem.objValue = addressUsernameList[i];
                searchResultItem.objEmail = addressList[i];
                searchResultItem.objUrl = '/lightning/r/' + idList[i] + '/view';
                searchResultWrappers.add(searchResultItem);
            }

            searchResultWrapperList.addressSearchResultWrapper = searchResultWrappers;
        }
        if(String.isNotBlank(se.Cc_Ids__c)){
            List<String> ccIdList = se.Cc_Ids__c.split(',');
            List<String> ccList = se.Cc__c.split(',');
            List<String> ccUsernameList = se.Cc_Usernames__c.split(',');

            for (Integer i = 0; i < ccIdList.size(); i++) {
                SearchResultWrapper searchResultItem = new SearchResultWrapper();
                searchResultItem.objId = ccIdList[i];
                searchResultItem.objName = getAPINameByObjId(ccIdList[i]);
                searchResultItem.objLabel = getLabelNameByObjId(ccIdList[i]);
                searchResultItem.objValue = ccUsernameList[i];
                searchResultItem.objEmail = ccList[i];
                searchResultItem.objUrl = '/lightning/r/' + ccIdList[i] + '/view';
                searchResultWrappersCC.add(searchResultItem);
            }

            searchResultWrapperList.ccSearchResultWrapper = searchResultWrappersCC;
        }

        // 查询是否有发送邮件功能
        searchResultWrapperList.isCanSend = false;
        if(Label.Send_Email_Profiles.split(',').contains(currentUser.Profile.name)){
            searchResultWrapperList.isCanSend = true;
        }
        return searchResultWrapperList;
    }

    @AuraEnabled
    public static String saveAddress(SendEmailField sendEmailField) {
        ReturnResult result = new ReturnResult();
        result.code = '1';
        result.msg = 'Save failure!';
        Boolean saveStatus = saveSendEmail(sendEmailField);
        if(saveStatus){
            result.code = '0';
            result.msg = 'Save successfully!';
        }
        return JSON.serialize(result);
    }

    @AuraEnabled
    public static String sendEmail(SendEmailField sendEmailField) {
        SavePoint sp = Database.setSavepoint();
        ReturnResult result = new ReturnResult();
        result.code = '1';
        result.msg = 'Send failure!';
        try {
            Boolean saveStatus = saveSendEmail(sendEmailField);
            if(saveStatus){
                Send_Email__c se = [SELECT Id,Subject__c FROM Send_Email__c WHERE Id = :sendEmailField.recordId Limit 1];
                // 收件人和抄送人
                String userEmail = sendEmailField.emailAddress + ',' + sendEmailField.ccEmailAddress;
                List<String> userEmailList = userEmail.split(',');
                // 新增用户
                UserController.insertUser(userEmailList);
                //发送邮件
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String sendEmailurl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + sendEmailField.recordId;
                email.setSenderDisplayName(System.UserInfo.getName());
                email.setHtmlBody('<span>连接：</span><a href="' + sendEmailurl + '">' + sendEmailurl + '</a>');
                email.setSubject(se.Subject__c);
                email.setToAddresses(sendEmailField.emailAddress.split(','));
                if(String.isNotBlank(sendEmailField.ccEmailAddress) ){
                    email.setCcAddresses(sendEmailField.ccEmailAddress.split(','));
                }
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                // 邮件保存日志
                Utility.insertLog('sendEmail', '1', sendEmailField.emailAddress + ',' + sendEmailField.ccEmailAddress, sendEmailField.recordId);

                result.code = '0';
                result.msg = 'Send successfully!';
            }else {
                Database.rollback(sp);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }
        return JSON.serialize(result);
    }

    @AuraEnabled
    public static String saveUser(String username, String address) {
        System.debug('username: ' + username);
        System.debug('address: ' + address);
        ReturnResult result = new ReturnResult();
        result.code = '1';
        result.msg = 'Save failure!';
        Send_Email_User__c seu = new Send_Email_User__c();
        seu.Username__c = username;
        seu.Address__c = address;
        try{
            Database.insert(seu);
            result.code = '0';
            result.msg = 'Save successfully!';
            Utility.insertLog('saveUser', '1', null, username + '-' + address);
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
            Utility.insertLog('saveUser', '0', null, username + '-' + address);
        }
        return JSON.serialize(result);
    }

    @AuraEnabled
    public static SearchResultWrapper searchUserById(String userRecordId) {
        System.debug('userRecordId: ' + userRecordId);
        Send_Email_User__c seu = [SELECT Id ,Username__c, Address__c FROM Send_Email_User__c WHERE Id =:userRecordId LIMIT 1];
        SearchResultWrapper searchResultItem = new SearchResultWrapper();
        if(seu != null){
            searchResultItem.objId = seu.id;
            searchResultItem.objName = getAPINameByObjId(seu.id);
            searchResultItem.objLabel = getLabelNameByObjId(seu.id);
            searchResultItem.objValue = '<'+ seu.Username__c + '> <' + seu.Address__c + '>';
            searchResultItem.objEmail = seu.Address__c;
            searchResultItem.objUrl = '/lightning/r/' + seu.id + '/view';
        }
        return searchResultItem;
    }


    private static String buildRetrieveSQL(RetrieveWrapper wrapper) {
        String fetchSQL;
        if(wrapper.retrieveKeyword != null && wrapper.retrieveKeyword.trim() != '') {
            String keyword = '\'' + wrapper.retrieveKeyword + '\'';
            fetchSQL = 'FIND ' + keyword;

            if(wrapper.searchGroup != null) {
                fetchSQL += ' IN ' + wrapper.searchGroup;
            } else {
                fetchSQL += ' IN ALL FIELDS';
            }

            if(wrapper.objName2FieldMap != null) {
                List<String> objToFieldsList = new List<String>();
                for(String key : wrapper.objName2FieldMap.keySet()) {
                    String objName = key;
                    String fieldStr;
                    if(wrapper.objName2FieldMap != null && wrapper.objName2FieldMap.get(objName) != null) {
                        fieldStr = wrapper.objName2FieldMap.get(objName);
                    } else {
                        fieldStr = String.join(getAvailableFields(objName), '');
                    }
                    String filterStr;
                    if(wrapper.objName2QueryConditionMap != null) {
                        filterStr = wrapper.objName2QueryConditionMap.get(objName);
                    }

                    if(String.isNotEmpty(filterStr)){
                        fieldStr = '(' + fieldStr + ' WHERE ' + filterStr +')';
                    }
                    else{
                        if(fieldStr != null) {
                            fieldStr = '(' + fieldStr +')';
                        }
                    }
                    if(fieldStr != null) {
                        objName = key + fieldStr;
                    } else {
                        objName = key;
                    }
                    
                    objToFieldsList.add(objName);
                }

                if(objToFieldsList.size() > 0) {
                    fetchSQL += ' RETURNING ' + String.join(objToFieldsList, ',');
                }
            }
        }
        return fetchSQL;
    }

    // 返回true为保存成功
    private static Boolean saveSendEmail(SendEmailField sendEmailField) {
        System.debug('recordId: ' + sendEmailField.recordId);
        System.debug('ids: ' + sendEmailField.ids);
        System.debug('emailAddress: ' + sendEmailField.emailAddress);
        System.debug('usernameAddress: ' + sendEmailField.usernameAddress);
        System.debug('ccIds: ' + sendEmailField.ccIds);
        System.debug('ccEmailAddress: ' + sendEmailField.ccEmailAddress);
        System.debug('ccUsernameAddress: ' + sendEmailField.ccUsernameAddress);
        Boolean status = false;
        Send_Email__c se = new Send_Email__c(id = sendEmailField.recordId);
        se.Address_Ids__c = sendEmailField.ids;
        se.Address__c = sendEmailField.emailAddress;
        se.Address_Usernames__c = sendEmailField.usernameAddress;
        se.Cc_Ids__c = sendEmailField.ccIds;
        se.Cc__c = sendEmailField.ccEmailAddress;
        se.Cc_Usernames__c = sendEmailField.ccUsernameAddress;
        try{
            Database.update(se);
            Utility.insertLog('saveSendEmail', '1', JSON.serialize(sendEmailField), '');
            status = true;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
            Utility.insertLog('saveSendEmail', '0', JSON.serialize(sendEmailField), e.getLineNumber() + '-' + e.getMessage());
        }
        return status;
    }

    private static String getAPINameByObjId(String objId) {
        String objPrefix = objId.left(3);
        return objId2APIName.get(objPrefix).toLowerCase();
    }

    private static String getLabelNameByObjId(String objId) {
        String objPrefix = objId.left(3);
        return objId2ObjName.get(objPrefix).toLowerCase();
    }


    private static Map<String,String> objId2APIName {
        get {
            if(objId2APIName == null) {
                objId2APIName = new Map<String,String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                for(String objectName : gd.keySet()) {
                    Schema.SObjectType objectType = gd.get(objectName);
                    String prefix = objectType.getDescribe().getKeyPrefix();
                    if(prefix != null) {
                        objId2APIName.put(prefix, objectName);
                    }
                }
            }
            return objId2APIName;
        }
        set;
    }

    private static Map<String,String> objId2ObjName {
        get {
            if(objId2ObjName == null) {
                objId2ObjName = new Map<String,String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                for(String objectName : gd.keySet()) {
                    Schema.SObjectType objectType = gd.get(objectName);
                    String prefix = objectType.getDescribe().getKeyPrefix();
                    if(prefix != null) {
                        objId2ObjName.put(prefix, objectType.getDescribe().getLabel());
                    }
                }
            }
            return objId2ObjName;
        }set;
    }

    private static List<String> getAvailableFields(String objName) {
        List<String> availableFields = new List<String>();
        List<Schema.DescribeSObjectResult> objDescribes = Schema.describeSObjects(new List<String>{objName});
        Schema.DescribeSObjectResult objDescribe;
        if(objDescribes != null && objDescribes.size() > 0) {
            objDescribe = objDescribes.get(0);
        } else {
            return null;
        }
        Map<String,SObjectField> sObjectFieldMaps = objDescribe.fields.getMap();
        for(String objField : sObjectFieldMaps.keySet()) {
            SObjectField field = sObjectFieldMaps.get(objField);
            DescribeFieldResult fieldResult = field.getDescribe();
            if(fieldResult.isAccessible()) {
                availableFields.add(fieldResult.getName());
            }
        }
        return availableFields;
    }
}