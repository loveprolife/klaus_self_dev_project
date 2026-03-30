/**********************************************************************
 * function:Login_History__c
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-07-16
*************************************************************************/
@RestResource(urlMapping='/SendLoginHistoryToBigData')
global with sharing class SendLoginHistoryToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
    }
    global class AppOutPut{
        //public Integer totalPage;
        List<LoginHistoryInfo> loginHistoryInfoList;
    }

    public class LoginHistoryInfo {

        public String Id;
        public String UserId;
        public String LoginTime;
        public String LoginType;
        public String SourceIp;
        public String LoginUrl;
        public String NetworkId;
        public String AuthenticationServiceId;
        public String LoginGeoId;
        public String TlsProtocol;
        public String CipherSuite;
        public String OptionsIsGet;
        public String OptionsIsPost;
        public String Browser;
        public String Platform;
        public String Status;
        public String Application;
        public String ClientVersion;
        public String ApiType;
        public String ApiVersion;
        public String CountryIso;
        public String AuthMethodReference;

    }

    @HttpPost
    global static SendLoginHistoryToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendLoginHistoryToBigData.AppInput appInput = new SendLoginHistoryToBigData.AppInput();
        
        SendLoginHistoryToBigData.AppOutPut result = new SendLoginHistoryToBigData.AppOutPut();
        
        try{
            appInput = (SendLoginHistoryToBigData.AppInput)JSON.deserialize(reqBody, SendLoginHistoryToBigData.AppInput.class);

            if(String.isBlank(appInput.startTime) || String.isBlank(appInput.endTime)){
                return result;
            }


            appInput.startTime = Utility.increaseHoursInStringDate(appInput.startTime,8).replace(' ','T') + '.000+0000';
            appInput.endTime = Utility.increaseHoursInStringDate(appInput.endTime,8).replace(' ','T') + '.000+0000';

            String sql = 'select '+
            'Id,'+
            'UserId__c,'+
            'LoginTime__c,'+
            'LoginType__c,'+
            'SourceIp__c,'+
            'LoginUrl__c,'+
            'CipherSuite__c,'+
            'Browser__c,'+
            'Platform__c,'+
            'Status__c,'+
            'Application__c,'+
            'CountryIso__c'+
            ' from Login_History__c where LoginTime__c >= '+appInput.startTime+' and LoginTime__c <= '+appInput.endTime;
            //List<LoginHistory> LoginHistoryList = (List<LoginHistory>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Login_History__c> LoginHistoryList = Database.query(sql);

            List<LoginHistoryInfo> LoginHistoryInfoList = new List<LoginHistoryInfo>();

            for(Login_History__c a : LoginHistoryList){
                LoginHistoryInfo c = new LoginHistoryInfo();
                c.Id = checkNull(a.Id + '');
                c.UserId = checkNull(a.UserId__c + '');
                c.LoginTime = checkNull(a.LoginTime__c + '');
                c.LoginType = checkNull(a.LoginType__c + '');
                c.SourceIp = checkNull(a.SourceIp__c + '');
                c.LoginUrl = checkNull(a.LoginUrl__c + '');
                c.NetworkId = '';
                c.AuthenticationServiceId = '';
                c.LoginGeoId = '';
                c.TlsProtocol = '';
                c.CipherSuite = checkNull(a.CipherSuite__c + '');
                c.OptionsIsGet = '';
                c.OptionsIsPost = '';
                c.Browser = checkNull(a.Browser__c + '');
                c.Platform = checkNull(a.Platform__c + '');
                c.Status = checkNull(a.Status__c + '');
                c.Application = checkNull(a.Application__c + '');
                c.ClientVersion = '';
                c.ApiType = '';
                c.ApiVersion = '';
                c.CountryIso = checkNull(a.CountryIso__c + '');
                c.AuthMethodReference = '';

              
                LoginHistoryInfoList.add(c);

            }
            result.LoginHistoryInfoList = LoginHistoryInfoList;
            //String sql1 = 'select count(id) totalNumber from LoginHistory where LoginTime >= '+appInput.startTime+' and LoginTime <= '+appInput.endTime;
            //List<AggregateResult> c = Database.query(sql1);
            //result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendLoginHistoryToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendLoginHistoryToBigData';
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