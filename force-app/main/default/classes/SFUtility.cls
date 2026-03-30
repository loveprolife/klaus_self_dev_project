/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global with sharing class SFUtility {
    public static final Integer CON_MAX_LENGTH = 50000;

    global class SFRestCallResult {
        public String FailReason {GET; SET;}
        public String IsSuccess {GET; SET;}
    }

    public static void writeCallLogs(String isSucceed,
                                     String interfaceName, 
                                     String callParameter, 
                                     String callResult,
                                     String calltype,
                                     String errorMsg) {

        try {
            InterfaceLog__c log = new InterfaceLog__c();
            log.IsSuccess__c = isSucceed == 'true' ? true : false;
            log.Class__c = interfaceName;
            log.Time__c = System.now();
            log.Call_Type__c = calltype;
            log.Res_Json__c = callResult;

            String callAttachmentName = '';
            String resultAttachmentName = '';

            // 如果调用参数太长，生成附件保存
            if (callParameter.length() > CON_MAX_LENGTH) {
                callAttachmentName = interfaceName + '_Send_' + System.now().format('yyMMdd');
                log.Req_Json__c =  + '请查看附件: ' + callAttachmentName + '.txt';
            } else {
                log.Req_Json__c = callParameter;
            }

            // 如果返回参数太长，生成附件保存
            if (callResult.length() > CON_MAX_LENGTH) {
                resultAttachmentName = interfaceName + '_Return_' + System.now().format('yyMMdd');
                log.Res_Json__c = '请查看附件: ' + resultAttachmentName + '.txt';
            } else {
                log.Res_Json__c = callResult;
            }

            if (errorMsg.length() > CON_MAX_LENGTH) {
                resultAttachmentName = interfaceName + '_Error_Message_' + System.now().format('yyMMdd');
                log.ErrorMsg__c = '请查看附件: ' + resultAttachmentName + '.txt';
            } else {
                log.ErrorMsg__c = errorMsg;
            }

            INSERT log;

            if (String.isNotBlank(callAttachmentName)) {
                createAttachment(log.Id, callAttachmentName, callParameter);
            }

            if (String.isNotBlank(resultAttachmentName)) {
                createAttachment(log.Id, resultAttachmentName, callResult);
            }

        } catch(Exception ex) {
            System.debug(LoggingLevel.INFO, '*** Insert Log Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    public static void createAttachment(Id sourceID, String fileName, String body) {
        Attachment att = new Attachment();
        att.Name = fileName;
        att.Body = Blob.valueOf(body);
        att.ParentId = sourceID;
        att.Description = '系统自动生成';
        INSERT att;
    }
}