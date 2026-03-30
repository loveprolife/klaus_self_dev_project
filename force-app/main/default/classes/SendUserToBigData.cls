/**********************************************************************
 * function:将User推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendUserToBigData')
global with sharing class SendUserToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<UserInfo> userInfoList;
    }

    public class UserInfo {
        public String id;
        public String CreatedDate;
        public String LastModifiedDate;
        public String Name;
        public String AboutMe;
        public String AccountCode;
        public String Address;
        public String Alias;
        public String CallCenterId;
        public String CommunityNickname;
        public String CompanyName;
        public String ContactId;
        public String Country;
        public String DefaultGroupNotificationFrequency;
        public String DelegatedApproverId;
        public String Department;
        public String Department1;
        public String DigestFrequency;
        public String DirectSalesDepartmentLocation;
        public String Division;
        public String Email;
        public String EmailEncodingKey;
        public String EmailKey;
        public String EmployeeNumber;
        public String Extension;
        public String Fax;
        public String FederationIdentifier;
        public String ForecastEnabled;
        public String HisenseSSOName;
        public String IndividualId;
        public String IsActive;
        public String LanguageLocaleKey;
        public String LocaleSidKey;
        public String ManagementLevel;
        public String ManagerId;
        public String MobilePhone;
        public String Office;
        public String Phone;
        public String PlanCustomerVisitNum;
        public String PlanLoginNum;
        public String PortalRole;
        public String Position;
        public String ProfileId;
        public String ReceivesAdminInfoEmails;
        public String ReceivesInfoEmails;
        public String SalesRegion;
        public String SenderEmail;
        public String SenderName;
        public String Signature;
        public String StayInTouchNote;
        public String StayInTouchSignature;
        public String StayInTouchSubject;
        public String TIMBASURVEYSSurveyReminder;
        public String TIMBASURVEYSreminderStringSize;
        public String TimeZoneSidKey;
        public String Title;
        public String UserRoleId;
        public String UserSubtype;
        public String UserFullName;
        public String Username;
        public String WorkspaceId;
        public String SYSTEM_CODE;

    }

    @HttpPost
    global static SendUserToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendUserToBigData.AppInput appInput = new SendUserToBigData.AppInput();
        
        SendUserToBigData.AppOutPut result = new SendUserToBigData.AppOutPut();
        
        try{
            appInput = (SendUserToBigData.AppInput)JSON.deserialize(reqBody, SendUserToBigData.AppInput.class);

            if(String.isBlank(appInput.startTime) || String.isBlank(appInput.endTime)){
                return result;
            }

            if(String.isBlank(appInput.pageIndex)){
                appInput.pageIndex = '1';
            }

            if(String.isBlank(appInput.pageSize) || Integer.valueOf(appInput.pageSize) < 200){
                appInput.pageSize = '200';
            }

            appInput.startTime = Utility.increaseHoursInStringDate(appInput.startTime,8).replace(' ','T') + '.000+0000';
            appInput.endTime = Utility.increaseHoursInStringDate(appInput.endTime,8).replace(' ','T') + '.000+0000';

            String sql = 'select '+
            'id,'+
            'CreatedDate,'+
            'LastModifiedDate,'+
            'AboutMe,'+
            'AccountCode__c,'+
            'Address,'+
            'Alias,'+
            'CallCenterId,'+
            'CommunityNickname,'+
            'CompanyName,'+
            'ContactId,'+
            'Country__c,'+
            'DefaultGroupNotificationFrequency,'+
            'DelegatedApproverId,'+
            'Department,'+
            'Department__c,'+
            'DigestFrequency,'+
            'Direct_Sales_Department_Location__c,'+
            'Division,'+
            'Email,'+
            'EmailEncodingKey,'+
            'Email_Key__c,'+
            'EmployeeNumber,'+
            'Extension,'+
            'Fax,'+
            'FederationIdentifier,'+
            'ForecastEnabled,'+
            'HisenseSSOName__c,'+
            //'IndividualId,'+
            'IsActive,'+
            'LanguageLocaleKey,'+
            'LocaleSidKey,'+
            'Management_Level__c,'+
            'ManagerId,'+
            'MobilePhone,'+
            'Name,'+
            'Office__c,'+
            'Phone,'+
            'Plan_Customer_Visit_Num__c,'+
            'Plan_Login_Num__c,'+
            'PortalRole,'+
            'Position__c,'+
            'ProfileId,'+
            'ReceivesAdminInfoEmails,'+
            'ReceivesInfoEmails,'+
            'Sales_Region__c,'+
            'SenderEmail,'+
            'SenderName,'+
            'Signature,'+
            'StayInTouchNote,'+
            'StayInTouchSignature,'+
            'StayInTouchSubject,'+
            'TIMBASURVEYS__SurveyReminder__c,'+
            'TIMBASURVEYS__reminderStringSize__c,'+
            'TimeZoneSidKey,'+
            'Title,'+
            'UserRoleId,'+
            'User_Full_Name__c,'+
            'Username'+

            ' from User where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<User> UserList = (List<User>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<User> UserList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<UserInfo> UserInfoList = new List<UserInfo>();

            for(User a : UserList){
                UserInfo c = new UserInfo();
                c.id = checkNull(a.id + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.Name = checkNull(a.Name + '');
                c.AboutMe = checkNull(a.AboutMe + '');
                c.AccountCode = checkNull(a.AccountCode__c + '');
                c.Address = checkNull(a.Address + '');
                c.Alias = checkNull(a.Alias + '');
                c.CallCenterId = checkNull(a.CallCenterId + '');
                c.CommunityNickname = checkNull(a.CommunityNickname + '');
                c.CompanyName = checkNull(a.CompanyName + '');
                c.ContactId = checkNull(a.ContactId + '');
                c.Country = checkNull(a.Country__c + '');
                c.DefaultGroupNotificationFrequency = checkNull(a.DefaultGroupNotificationFrequency + '');
                c.DelegatedApproverId = checkNull(a.DelegatedApproverId + '');
                c.Department = checkNull(a.Department + '');
                c.Department1 = checkNull(a.Department__c + '');
                c.DigestFrequency = checkNull(a.DigestFrequency + '');
                c.DirectSalesDepartmentLocation = checkNull(a.Direct_Sales_Department_Location__c + '');
                c.Division = checkNull(a.Division + '');
                c.Email = checkNull(a.Email + '');
                c.EmailEncodingKey = checkNull(a.EmailEncodingKey + '');
                c.EmailKey = checkNull(a.Email_Key__c + '');
                c.EmployeeNumber = checkNull(a.EmployeeNumber + '');
                c.Extension = checkNull(a.Extension + '');
                c.Fax = checkNull(a.Fax + '');
                c.FederationIdentifier = checkNull(a.FederationIdentifier + '');
                c.ForecastEnabled = checkNull(a.ForecastEnabled + '');
                c.HisenseSSOName = checkNull(a.HisenseSSOName__c + '');
                c.IndividualId = '';
                c.IsActive = checkNull(a.IsActive + '');
                c.LanguageLocaleKey = checkNull(a.LanguageLocaleKey + '');
                c.LocaleSidKey = checkNull(a.LocaleSidKey + '');
                c.ManagementLevel = checkNull(a.Management_Level__c + '');
                c.ManagerId = checkNull(a.ManagerId + '');
                c.MobilePhone = checkNull(a.MobilePhone + '');
                c.Office = checkNull(a.Office__c + '');
                c.Phone = checkNull(a.Phone + '');
                c.PlanCustomerVisitNum = checkNull(a.Plan_Customer_Visit_Num__c + '');
                c.PlanLoginNum = checkNull(a.Plan_Login_Num__c + '');
                c.PortalRole = checkNull(a.PortalRole + '');
                c.Position = checkNull(a.Position__c + '');
                c.ProfileId = checkNull(a.ProfileId + '');
                c.ReceivesAdminInfoEmails = checkNull(a.ReceivesAdminInfoEmails + '');
                c.ReceivesInfoEmails = checkNull(a.ReceivesInfoEmails + '');
                c.SalesRegion = checkNull(a.Sales_Region__c + '');
                c.SenderEmail = checkNull(a.SenderEmail + '');
                c.SenderName = checkNull(a.SenderName + '');
                c.Signature = checkNull(a.Signature + '');
                c.StayInTouchNote = checkNull(a.StayInTouchNote + '');
                c.StayInTouchSignature = checkNull(a.StayInTouchSignature + '');
                c.StayInTouchSubject = checkNull(a.StayInTouchSubject + '');
                c.TIMBASURVEYSSurveyReminder = checkNull(a.TIMBASURVEYS__SurveyReminder__c + '');
                c.TIMBASURVEYSreminderStringSize = checkNull(a.TIMBASURVEYS__reminderStringSize__c + '');
                c.TimeZoneSidKey = checkNull(a.TimeZoneSidKey + '');
                c.Title = checkNull(a.Title + '');
                c.UserRoleId = checkNull(a.UserRoleId + '');
                c.UserFullName = checkNull(a.User_Full_Name__c + '');
                c.Username = checkNull(a.Username + '');
                c.SYSTEM_CODE = 'S0218';

                UserInfoList.add(c);
            }
            result.UserInfoList = UserInfoList;
            String sql1 = 'select count(id) totalNumber from User where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendUserToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendUserToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            return result; 
        }
    }

    public static String checkNull(String str){
        if(String.isBlank(str)){
            return '';
        }else if('null'.equals(str)){
            return '';
        }else{
            return str;
        }
    }
}