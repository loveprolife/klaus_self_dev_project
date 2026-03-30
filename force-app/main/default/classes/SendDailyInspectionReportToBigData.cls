/**********************************************************************
 * function:将看板指标数据推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-06
*************************************************************************/
@RestResource(urlMapping='/SendDailyInspectionReportToBigData')
global with sharing class SendDailyInspectionReportToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<DailyInspectionReportInfo> dailyInspectionReportInfoList;
    }
    
    @HttpPost
    global static SendDailyInspectionReportToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendDailyInspectionReportToBigData.AppInput appInput = new SendDailyInspectionReportToBigData.AppInput();
        
        SendDailyInspectionReportToBigData.AppOutPut result = new SendDailyInspectionReportToBigData.AppOutPut();
        
        try{
            appInput = (SendDailyInspectionReportToBigData.AppInput)JSON.deserialize(reqBody, SendDailyInspectionReportToBigData.AppInput.class);

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
            'Name,'+
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Average_Score_Count__c,'+
            'Average_Score_Max__c,'+
            'Average_Score__c,'+
            'Created_By_Role__c,'+
            'Customer_Attribute__c,'+
            'Customer_Name__c,'+
            'Customer__c,'+
            'ExternalId__c,'+
            'Gridding__c,'+
            'Inspection_Shop_Plan__c,'+
            'Mileage_Of_Today__c,'+
            'NeedCheckIn__c,'+
            'Note__c,'+
            'Owner_Email__c,'+
            'Owner_Profile__c,'+
            'Owner_text__c,'+
            'Report_Date__c,'+
            'Report_Detail__c,'+
            'Report_Type__c,'+
            'Sales_Region__c,'+
            'Status__c,'+
            'Store__c,'+
            'Summary__c,'+
            'Total_Score_Max__c,'+
            'Total_Score__c'+
            ' from Daily_Inspection_Report__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Daily_Inspection_Report__c> dirList = (List<Daily_Inspection_Report__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<DailyInspectionReportInfo> dirInfoList = new List<DailyInspectionReportInfo>();
            for(Daily_Inspection_Report__c d : dirList){
                DailyInspectionReportInfo di = new DailyInspectionReportInfo();
                di.id = checkNull(d.id + '');
                di.CreatedDate = checkNull(d.CreatedDate + '');
                di.LastModifiedDate = checkNull(d.LastModifiedDate + '');
                di.Name = checkNull(d.Name + '');
                di.Average_Score_Count = checkNull(d.Average_Score_Count__c + '');
                di.Average_Score_Max = checkNull(d.Average_Score_Max__c + '');
                di.Average_Score = checkNull(d.Average_Score__c + '');
                di.Created_By_Role = checkNull(d.Created_By_Role__c + '');
                di.Customer_Attribute = checkNull(d.Customer_Attribute__c + '');
                di.Customer_Name = checkNull(d.Customer_Name__c + '');
                di.Customer = checkNull(d.Customer__c + '');
                di.ExternalId = checkNull(d.ExternalId__c + '');
                di.Gridding = checkNull(d.Gridding__c + '');
                di.Inspection_Shop_Plan = checkNull(d.Inspection_Shop_Plan__c + '');
                di.Mileage_Of_Today = checkNull(d.Mileage_Of_Today__c + '');
                di.NeedCheckIn = checkNull(d.NeedCheckIn__c + '');
                di.Note = checkNull(d.Note__c + '');
                di.Owner_Email = checkNull(d.Owner_Email__c + '');
                di.Owner_Profile = checkNull(d.Owner_Profile__c + '');
                di.Owner_text = checkNull(d.Owner_text__c + '');
                di.Report_Date = checkNull(d.Report_Date__c + '');
                di.Report_Detail = checkNull(d.Report_Detail__c + '');
                di.Report_Type = checkNull(d.Report_Type__c + '');
                di.Sales_Region = checkNull(d.Sales_Region__c + '');
                di.Status = checkNull(d.Status__c + '');
                di.Store = checkNull(d.Store__c + '');
                di.Summary = checkNull(d.Summary__c + '');
                di.Total_Score_Max = checkNull(d.Total_Score_Max__c + '');
                di.Total_Score = checkNull(d.Total_Score__c + '');
                dirInfoList.add(di);
            }
            result.dailyInspectionReportInfoList = dirInfoList;
           
            String sql1 = 'select count(id) totalNumber from Daily_Inspection_Report__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendDailyInspectionReportToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            //String str = JSON.serialize(result).replace('null','null');
            //result = (SendDailyInspectionReportToBigData.AppOutPut)JSON.deserialize(str, SendDailyInspectionReportToBigData.AppOutPut.class);
            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendDailyInspectionReportToBigData';
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

    public class DailyInspectionReportInfo{
        public String id; 
        public String CreatedDate;
        public String LastModifiedDate;
        public String Name; 
        public String Average_Score_Count;
        public String Average_Score_Max;
        public String Average_Score;
        public String Created_By_Role;
        public String Customer_Attribute;
        public String Customer_Name;
        public String Customer;
        public String ExternalId;
        public String Gridding;
        public String Inspection_Shop_Plan;
        public String Mileage_Of_Today;
        public String NeedCheckIn;
        public String Note;
        public String Owner_Email;
        public String Owner_Profile;
        public String Owner_text;
        public String Report_Date;
        public String Report_Detail;
        public String Report_Type;
        public String Sales_Region;
        public String Status;
        public String Store;
        public String Summary;
        public String Total_Score_Max;
        public String Total_Score;
    }

}