public without sharing class ApplicationButtonController {
    @AuraEnabled
    public static ConResponse saveData(String recordListJson, String fileMapJson){

        System.debug('recordListJson：' + recordListJson);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        try {
           
            List<Application__c> applicationList = (List<Application__c>)JSON.deserialize(recordListJson, List<Application__c>.class);
            // application.RecordTypeId = Schema.SobjectType.Application__c.getRecordTypeInfosByDeveloperName().get('TransferStore').getRecordTypeId();
            upsert applicationList;

            if(!String.isBlank(fileMapJson)) {
               UploadFilesController.saveFiles(recordListJson, fileMapJson, applicationList, applicationList[0].Id); 
            }
            

            mso.put('applicationId', applicationList[0].Id);
            resp.data = mso;
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }  

        return resp;

    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId){

        System.debug('recordId：' + recordId);

        MapResponse resp = new MapResponse();

        Application__c application= new  Application__c();
        Boolean isLocked = false;
        Boolean canUploadFile = false;

        String userId = UserInfo.getUserId();
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        Boolean isSouthAfrica = (currentUser[0].Sales_Region__c == 'Hisense South Africa');

        if(recordId != null) {
            application= [SELECT Id, OwnerId, Name, RecordTypeId, RecordType.DeveloperName, CheckDate__c, CheckInStoreName__c, CheckOutStoreName__c, FirstApprover__c, 
                                FourthApprover__c, From__c, LeaveType__c, Reason__c, RefillCheckInTime__c, RefillCheckOutTime__c, SecondApprover__c, 
                                Status__c, Successor__c, ThirdApprover__c, To__c, TransferStore__c, Comments__c, LastDay__c
                                FROM Application__c WHERE Id = :recordId];
            if(application.Status__c == 'Submitted' || application.Status__c == 'Approved' || application.Status__c == 'In Approval') {
                isLocked = true;
            }

            if((application.RecordType.DeveloperName == 'Leave') && (application.LeaveType__c == 'Sick Leave')) {
                if((currentUser[0].Sales_Region__c == 'Hisense Indonesia') || (currentUser[0].Sales_Region__c == 'Hisense South Africa')) {
                    canUploadFile = true;
                }
            }

        }
        resp.put('application', application);
        resp.put('isLocked', isLocked);
        resp.put('canUploadFile', canUploadFile);
        resp.put('isSouthAfrica', isSouthAfrica);

        String defaultRecordTypeId = '';
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SobjectType.Application__c.getRecordTypeInfosByDeveloperName();
        List<Map<String, String>> temp = new List<Map<String, String>>();
        for(String key : recordTypesMap.keyset()) {
            if (recordTypesMap.get(key).isMaster() ) {
                continue;
            }

            if(recordTypesMap.get(key).isActive() && recordTypesMap.get(key).isAvailable()) {
                temp.add(new Map<String, String>{
                    'label' => recordTypesMap.get(key).getName(),
                    'value' => recordTypesMap.get(key).getRecordTypeId()
                });
                if(recordTypesMap.get(key).isDefaultRecordTypeMapping()) {
                    defaultRecordTypeId = recordTypesMap.get(key).getRecordTypeId();
                }
            } else {
                System.debug('getInitData：'+recordTypesMap.get(key).getName());
            }
            
        }
        resp.put('defaultRecordTypeId', defaultRecordTypeId);
        resp.put('typesOptions', temp);
        System.debug('typesOptions：' + temp);
        
        List<RecordType> recordTypeList = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'Application__c'];
        Map<String, String> recordTypeMap = new Map<String, String>();
        for(RecordType item : recordTypeList) {
            recordTypeMap.put(item.DeveloperName, item.Id);
        }
        resp.put('recordTypeMap', recordTypeMap);

        // resp.put('recordTypesMap', recordTypesMap);
        resp.put('transferStoreId', Schema.SobjectType.Application__c.getRecordTypeInfosByDeveloperName().get('TransferStore').getRecordTypeId());
        resp.put('fields', SObjectHelper.getFieldLabelMap('Application__c'));

        return resp;    

    }


    @AuraEnabled
    public static ConResponse submitSaveData(String recordId){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Boolean needFile = false;
        String messages = '';

        try {
           List<Application__c> applicationList = [SELECT Id, RecordType.DeveloperName, LeaveType__c FROM Application__c WHERE Id = :recordId];
           List<ContentDocumentLink> fileList = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

           String userId = UserInfo.getUserId();
           List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

           if(applicationList.size() > 0) {
            if((currentUser[0].Sales_Region__c == 'Hisense Indonesia') && (applicationList[0].RecordType.DeveloperName == 'Leave') && (applicationList[0].LeaveType__c == 'Sick Leave') && (fileList.size() == 0)) {
                needFile = true;
                messages = Label.upload_file;
            } else {
                List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                //req.setComments(approvalMap.get(appId));
                req.setObjectId(recordId);
                req.setSkipEntryCriteria(true);
                processList.add(req);
                List<Approval.ProcessResult> resultlist = Approval.process(processList);
            }
           }
           mso.put('messages', messages);
           mso.put('needFile', needFile);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }  
        resp.data = mso;
        return resp;

    }

    @AuraEnabled
    public static ConResponse submitGetInitData(String recordId){

        System.debug('recordId：' + recordId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Boolean needFile = false;
        String messages = '';

        try {
           List<Application__c> applicationList = [SELECT Id, RecordType.DeveloperName, Status__c, LeaveType__c FROM Application__c WHERE Id = :recordId];
           List<ContentDocumentLink> fileList = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

           String userId = UserInfo.getUserId();
           List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

           if(applicationList.size() > 0) {

            if(applicationList[0].Status__c == 'Submitted' || applicationList[0].Status__c == 'Approved' || applicationList[0].Status__c == 'In Approval') {
                messages += Label.submitted_repeatedly + '\n';
            }

            if(currentUser[0].Sales_Region__c == 'Hisense Indonesia') {
                if((applicationList[0].RecordType.DeveloperName == 'Leave') && (applicationList[0].LeaveType__c == 'Sick Leave') && (fileList.size() == 0)) {
                    needFile = true;
                    messages += Label.upload_file + '\n';
                }
            }
           }
           mso.put('messages', messages);
           mso.put('needFile', needFile);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }  
        resp.data = mso;
        return resp;  

    }
}