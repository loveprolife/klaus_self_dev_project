/**********************************************************************
 * function:将看板指标数据推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-06
*************************************************************************/
@RestResource(urlMapping='/SendPromotersToBigData')
global with sharing class SendPromotersToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<ResponsiblePersonInfo> promotersInfoList;
    }
    
    @HttpPost
    global static SendPromotersToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendPromotersToBigData.AppInput appInput = new SendPromotersToBigData.AppInput();
        
        SendPromotersToBigData.AppOutPut result = new SendPromotersToBigData.AppOutPut();
        
        try{
            appInput = (SendPromotersToBigData.AppInput)JSON.deserialize(reqBody, SendPromotersToBigData.AppInput.class);

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
            'id, '+
            'Account_Name__c,'+
            'External_Key_ID__c,'+
            'Is_Export__c,'+
            'Principal_Text__c,'+
            'Principal__c,'+
            'Promoter_Attendance_Rule__c,'+
            'RecordType__c,'+
            'SAPCreateTime__c,'+
            'SAPCreate__c,'+
            'SAPExternal__c,'+
            'SAPUserName__c,'+
            'Shop_Id__c,'+
            'Shop_Name_Text__c,'+
            'Shop_Name__c,'+
            'Store_Grid__c,'+
            'UserEmail__c'+
            ' from Responsible_Person__c where Principal__r.IsActive = true and LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Responsible_Person__c> responsiblePersonList = (List<Responsible_Person__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<UserLogin> UserLoginList = [select UserId, IsFrozen from UserLogin];
            Map<String, Boolean> UserLoginMap = new Map<String, Boolean>();
            for(UserLogin u : UserLoginList){
                UserLoginMap.put(u.UserId, u.IsFrozen);
            }

            List<ResponsiblePersonInfo> responsiblePersonInfoList = new List<ResponsiblePersonInfo>();
            for(Responsible_Person__c r : responsiblePersonList){
                ResponsiblePersonInfo ri = new ResponsiblePersonInfo();

                if(UserLoginMap.get(r.Principal__c)){
                    continue;
                }
                ri.id = checkNull(r.id + '');
                ri.Account_Name = checkNull(r.Account_Name__c + '');
                ri.External_Key_ID = checkNull(r.External_Key_ID__c + '');
                ri.Is_Export = checkNull(r.Is_Export__c + '');
                ri.Principal_Text = checkNull(r.Principal_Text__c + '');
                ri.Principal = checkNull(r.Principal__c + '');
                ri.Promoter_Attendance_Rule = checkNull(r.Promoter_Attendance_Rule__c + '');
                ri.RecordType = checkNull(r.RecordType__c + '');
                ri.SAPCreateTime = checkNull(r.SAPCreateTime__c + '');
                ri.SAPCreate = checkNull(r.SAPCreate__c + '');
                ri.SAPExternal = checkNull(r.SAPExternal__c + '');
                ri.SAPUserName = checkNull(r.SAPUserName__c + '');
                ri.Shop_Id = checkNull(r.Shop_Id__c + '');
                ri.Shop_Name_Text = checkNull(r.Shop_Name_Text__c + '');
                ri.Shop_Name = checkNull(r.Shop_Name__c + '');
                ri.Store_Grid = checkNull(r.Store_Grid__c + '');
                ri.UserEmail = checkNull(r.UserEmail__c + '');

                responsiblePersonInfoList.add(ri);
            }
            result.promotersInfoList = responsiblePersonInfoList;
            String sql1 = 'select count(id) totalNumber from Responsible_Person__c where Principal__r.IsActive = true and  LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromotersToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            //String str = JSON.serialize(result).replace('null','null');
            //result = (SendPromotersToBigData.AppOutPut)JSON.deserialize(str, SendPromotersToBigData.AppOutPut.class);
            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromotersToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            return null; 
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

    public class ResponsiblePersonInfo{
        public String id; 
        public String Account_Name;
        public String External_Key_ID;
        public String Is_Export;
        public String Principal_Text;
        public String Principal;
        public String Promoter_Attendance_Rule;
        public String RecordType;
        public String SAPCreateTime;
        public String SAPCreate;
        public String SAPExternal;
        public String SAPUserName;
        public String Shop_Id;
        public String Shop_Name_Text;
        public String Shop_Name;
        public String Store_Grid;
        public String UserEmail;

    }

}