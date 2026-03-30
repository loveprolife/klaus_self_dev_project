global class SyncReminderToPortal {
    private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_TODOLIST_SEND';
    private static String urlDone = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_DONELIST_SEND';
    private static String user = 'xiaxiaoyang';
    private static String password = 'hs123456';

    public class TaskList{
        public List<TaskFieldList> FieldList;//参数
    }

    public class TaskFieldList{
        public List<TaskField> Field;
    }

    public class TaskField{
        public String name;
        public String value;
    }

    public class Result {
        public String State;
        public ErrorInfo[] ErrorInfo;
    }

    public class resObj {
        public Result Result;
    }

    public class ErrorInfo {
        public String Error;
        public String Message;
    }

	public static void sendReminder (String jsonPost) {
        SyncReminderToPortal.resObj Result = new SyncReminderToPortal.resObj();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        try{
            System.debug(jsonPost);
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(jsonPost);
            request.setTimeout(12000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('RES BODY:' +'|'+response.getBody());
            
            Result = (SyncReminderToPortal.resObj)JSON.deserialize(response.getBody(),SyncReminderToPortal.resObj.class);
            System.debug(Result);

            //handle log
            if (Result.Result.State == 'Failure') {
                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'SyncReminderToPortal';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = response.getBody();
                ic.ErrorMsg__c = '';
                insert ic;
            }
        }catch(Exception e){
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncReminderToPortal';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = jsonPost;
            ic.Res_Json__c = response.getBody();
            ic.ErrorMsg__c = 'failure: SF Sync Task To Portal Failed!' + e.getMessage();
            insert ic;
            system.debug('Task Sync Faild! ' + e.getMessage()+e.getLineNumber()+datetime.now().format('yyyy-MM-dd HH:mm:ss'));  
        }
	}

    public static void sendReminderDone (String jsonPost) {
        SyncReminderToPortal.resObj Result = new SyncReminderToPortal.resObj();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        try{
            System.debug(jsonPost);
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            Http http_login = new Http();
            request.setEndpoint(urlDone);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(jsonPost);
            request.setTimeout(12000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('RES BODY:' +'|'+response.getBody());
            
            Result = (SyncReminderToPortal.resObj)JSON.deserialize(response.getBody(),SyncReminderToPortal.resObj.class);
            System.debug(Result);

            //handle log
            if (Result.Result.State == 'Failure') {
                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'SyncReminderToPortal';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = jsonPost;
                ic.Res_Json__c = response.getBody();
                ic.ErrorMsg__c = '';
                insert ic;
            }
        }catch(Exception e){
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncReminderToPortal';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = jsonPost;
            ic.Res_Json__c = response.getBody();
            ic.ErrorMsg__c = 'failure: SF Sync Task To Portal Failed!' + e.getMessage();
            insert ic;
            system.debug('Task Sync Faild! ' + e.getMessage()+e.getLineNumber()+datetime.now().format('yyyy-MM-dd HH:mm:ss'));  
        }
	}

    public static SyncReminderToPortal.TaskList createReminderList(List<ProcessInstanceHistory> pihs,String remainderType){
        SyncReminderToPortal.TaskList taskList = new SyncReminderToPortal.TaskList();
        taskList.FieldList = new List<SyncReminderToPortal.TaskFieldList>();
        for (ProcessInstanceHistory pinh : pihs) {
                SyncReminderToPortal.TaskFieldList TaskFieldList = new SyncReminderToPortal.TaskFieldList();
                TaskFieldList.Field = new List<SyncReminderToPortal.TaskField>();
                SyncReminderToPortal.TaskField  APP_CODE = new SyncReminderToPortal.TaskField();
                APP_CODE.name = 'APP_CODE';
                APP_CODE.value = 'sfcrm';
                TaskFieldList.Field.add(APP_CODE);

                SyncReminderToPortal.TaskField  APP_NAME = new SyncReminderToPortal.TaskField();
                APP_NAME.name = 'APP_NAME';
                APP_NAME.value = '国际营销CRM';
                TaskFieldList.Field.add(APP_NAME);

                SyncReminderToPortal.TaskField  tkField = new SyncReminderToPortal.TaskField();
                tkField.name = 'TASK_ID';
                if(remainderType.equals('ADD')){
                    tkField.value = pinh.TargetObjectId + '' +pinh.Actor.Id;
                }else{
                    tkField.value = pinh.TargetObjectId + '' +pinh.CreatedById;
                }
                TaskFieldList.Field.add(tkField);

                SyncReminderToPortal.TaskField  TASK_NAME = new SyncReminderToPortal.TaskField();
                TASK_NAME.name = 'TASK_NAME';
                TASK_NAME.value = pinh.ProcessNode.name;
                TaskFieldList.Field.add(TASK_NAME);

                SyncReminderToPortal.TaskField  CURR_USERID = new SyncReminderToPortal.TaskField();
                CURR_USERID.name = 'CURR_USERID';
                CURR_USERID.value = 'caorong';
                TaskFieldList.Field.add(CURR_USERID);

                SyncReminderToPortal.TaskField  CURR_USERNAME = new SyncReminderToPortal.TaskField();
                CURR_USERNAME.name = 'CURR_USERNAME';
                // CURR_USERNAME.value = task.owner.lastname;
                CURR_USERNAME.value = 'caorong';
                TaskFieldList.Field.add(CURR_USERNAME);

                SyncReminderToPortal.TaskField  DEPT_NAME = new SyncReminderToPortal.TaskField();
                DEPT_NAME.name = 'DEPT_NAME';
                DEPT_NAME.value = '0';
                TaskFieldList.Field.add(DEPT_NAME);

                SyncReminderToPortal.TaskField  COMP_NAME = new SyncReminderToPortal.TaskField();
                COMP_NAME.name = 'COMP_NAME';
                COMP_NAME.value = '0';
                TaskFieldList.Field.add(COMP_NAME);
                
                SyncReminderToPortal.TaskField  ACTIVITY_NAME = new SyncReminderToPortal.TaskField();
                ACTIVITY_NAME.name = 'ACTIVITY_NAME';
                ACTIVITY_NAME.value = '0';
                TaskFieldList.Field.add(ACTIVITY_NAME);
                
                SyncReminderToPortal.TaskField  TASK_TIME = new SyncReminderToPortal.TaskField();
                TASK_TIME.name = 'TASK_TIME';
                TASK_TIME.value = Datetime.now().format('YYYY-MM-dd hh:mm:ss');
                TaskFieldList.Field.add(TASK_TIME);
                
                SyncReminderToPortal.TaskField  PRIORITY = new SyncReminderToPortal.TaskField();
                PRIORITY.name = 'PRIORITY';
                PRIORITY.value = '1';
                TaskFieldList.Field.add(PRIORITY);
                
                SyncReminderToPortal.TaskField  PROCESS_URL = new SyncReminderToPortal.TaskField();
                PROCESS_URL.name = 'PROCESS_URL';
                PROCESS_URL.value = 'https://hisenseint--hisenseuat.lightning.force.com/lightning/r/ProcessInstanceWorkitem/'+pinh.id+'/view';
                TaskFieldList.Field.add(PROCESS_URL);
                
                SyncReminderToPortal.TaskField  PRE_USERID = new SyncReminderToPortal.TaskField();
                PRE_USERID.name = 'PRE_USERID';
                PRE_USERID.value = '0';
                TaskFieldList.Field.add(PRE_USERID);
                
                SyncReminderToPortal.TaskField  PRE_USERNAME = new SyncReminderToPortal.TaskField();
                PRE_USERNAME.name = 'PRE_USERNAME';
                PRE_USERNAME.value = '0';
                TaskFieldList.Field.add(PRE_USERNAME);
                
                SyncReminderToPortal.TaskField  PRE_DEPT = new SyncReminderToPortal.TaskField();
                PRE_DEPT.name = 'PRE_DEPT';
                PRE_DEPT.value = '0';
                TaskFieldList.Field.add(PRE_DEPT);
                
                SyncReminderToPortal.TaskField  PRE_COMP = new SyncReminderToPortal.TaskField();
                PRE_COMP.name = 'PRE_COMP';
                PRE_COMP.value = '0';
                TaskFieldList.Field.add(PRE_COMP);
                
                SyncReminderToPortal.TaskField  TASK_TYPE = new SyncReminderToPortal.TaskField();
                TASK_TYPE.name = 'TASK_TYPE';
                TASK_TYPE.value = '1';
                TaskFieldList.Field.add(TASK_TYPE);
                
                SyncReminderToPortal.TaskField  TASK_STATE = new SyncReminderToPortal.TaskField();
                TASK_STATE.name = 'TASK_STATE';
                TASK_STATE.value = '0';
                TaskFieldList.Field.add(TASK_STATE);
                
                SyncReminderToPortal.TaskField  DRAFTSMAN = new SyncReminderToPortal.TaskField();
                DRAFTSMAN.name = 'DRAFTSMAN';
                DRAFTSMAN.value = pinh.createdBy.name;
                TaskFieldList.Field.add(DRAFTSMAN);
                
                SyncReminderToPortal.TaskField  DRAFT_DEPT = new SyncReminderToPortal.TaskField();
                DRAFT_DEPT.name = 'DRAFT_DEPT';
                DRAFT_DEPT.value = '0';
                TaskFieldList.Field.add(DRAFT_DEPT);
                
                SyncReminderToPortal.TaskField  DRAFT_COMP = new SyncReminderToPortal.TaskField();
                DRAFT_COMP.name = 'DRAFT_COMP';
                DRAFT_COMP.value = '0';
                TaskFieldList.Field.add(DRAFT_COMP);
                
                SyncReminderToPortal.TaskField  DOC_NUMBER = new SyncReminderToPortal.TaskField();
                DOC_NUMBER.name = 'DOC_NUMBER';
                DOC_NUMBER.value = '0';
                TaskFieldList.Field.add(DOC_NUMBER);
                
                SyncReminderToPortal.TaskField  DRAFT_TIME = new SyncReminderToPortal.TaskField();
                DRAFT_TIME.name = 'DRAFT_TIME';
                DRAFT_TIME.value = '0';
                TaskFieldList.Field.add(DRAFT_TIME);
                
                SyncReminderToPortal.TaskField  INSTANCE_ID = new SyncReminderToPortal.TaskField();
                INSTANCE_ID.name = 'INSTANCE_ID';
                INSTANCE_ID.value = '0';
                TaskFieldList.Field.add(INSTANCE_ID);
                
                SyncReminderToPortal.TaskField  OPTYPE = new SyncReminderToPortal.TaskField();
                OPTYPE.name = 'OPTYPE';
                if(remainderType.equals('ADD')){
                    OPTYPE.value = '1';
                }else{
                    OPTYPE.value = '3';
                }
                TaskFieldList.Field.add(OPTYPE);

                taskList.FieldList.add(TaskFieldList);
        }
        return taskList;
    }
}