/**********************************************************************
 * function:Promoter_Daily_Report__c
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-07-03
*************************************************************************/
@RestResource(urlMapping='/SendPromoterDailyReportToBigData')
global with sharing class SendPromoterDailyReportToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<PromoterDailyReportInfo> promoterDailyReportInfoList;
    }

    public class PromoterDailyReportInfo {

        public String id;
        public String Name;
        public String OwnerId;
        public String IsDeleted;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String CreatedDate;
        public String LastModifiedById;
        public String LastModifiedDate;

        public String Attendance;
        public String CLKeyAccountManager;
        public String CreatedByRole;
        public String Customer;
        public String FinishRemark;
        public String IDTrainingManager;
        public String IsChange;
        public String IsNew;
        public String IsPerformance;
        public String IsExport;
        public String IsToday;
        public String OwnerEmail;
        public String Ownertext;
        public String PromoterDailyReport;
        public String RecordLink;
        public String ReportDateFormula;
        public String ReportSubmittedDate;
        public String ReportSubmittedDelayJudgment;
        public String ReportContent;
        public String ReportDate;
        public String SAOpsRegionalManager;
        public String SARegionalManager;
        public String SalesRegion;
        public String ShareGriddingCode;
        public String ShareShop;
        public String Shop;
        public String Status;

   


    }

    @HttpPost
    global static SendPromoterDailyReportToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendPromoterDailyReportToBigData.AppInput appInput = new SendPromoterDailyReportToBigData.AppInput();
        
        SendPromoterDailyReportToBigData.AppOutPut result = new SendPromoterDailyReportToBigData.AppOutPut();
        
        try{
            appInput = (SendPromoterDailyReportToBigData.AppInput)JSON.deserialize(reqBody, SendPromoterDailyReportToBigData.AppInput.class);

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
            'Name,'+
            'OwnerId,'+
            'IsDeleted,'+
            'CurrencyIsoCode,'+
            'CreatedById,'+
            'CreatedDate,'+
            'LastModifiedById,'+
            'LastModifiedDate,'+
      

            'Attendance__c,'+
            'CLKeyAccountManager__c,'+
            'Created_By_Role__c,'+
            'Customer__c,'+
            'FinishRemark__c,'+
            'IDTrainingManager__c,'+
            'IsChange__c,'+
            'IsNew__c,'+
            'IsPerformance__c,'+
            'Is_Export__c,'+
            'Is_Today__c,'+
            'Owner_Email__c,'+
            'Owner_text__c,'+
            'PromoterDailyReport__c,'+
            'RecordLink__c,'+
            'ReportDateFormula__c,'+
            'ReportSubmittedDate__c,'+
            'ReportSubmittedDelayJudgment__c,'+
            'Report_Content__c,'+
            'Report_Date__c,'+
            'SAOpsRegionalManager__c,'+
            'SARegionalManager__c,'+
            'Sales_Region__c,'+
            'Share_Gridding_Code__c,'+
            'Share_Shop__c,'+
            'Shop__c,'+
            'Status__c'+
            
            ' from Promoter_Daily_Report__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Promoter_Daily_Report__c> PromoterDailyReportList = (List<Promoter_Daily_Report__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<PromoterDailyReportInfo> PromoterDailyReportInfoList = new List<PromoterDailyReportInfo>();

            for(Promoter_Daily_Report__c a : PromoterDailyReportList){
                PromoterDailyReportInfo c = new PromoterDailyReportInfo();
                c.id = a.id;
                c.Name = checkNull(a.Name);
                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');

                c.Attendance = checkNull(a.Attendance__c + '');
                c.CLKeyAccountManager = checkNull(a.CLKeyAccountManager__c + '');
                c.CreatedByRole = checkNull(a.Created_By_Role__c + '');
                c.Customer = checkNull(a.Customer__c + '');
                c.FinishRemark = checkNull(a.FinishRemark__c + '');
                c.IDTrainingManager = checkNull(a.IDTrainingManager__c + '');
                c.IsChange = checkNull(a.IsChange__c + '');
                c.IsNew = checkNull(a.IsNew__c + '');
                c.IsPerformance = checkNull(a.IsPerformance__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                c.IsToday = checkNull(a.Is_Today__c + '');
                c.OwnerEmail = checkNull(a.Owner_Email__c + '');
                c.Ownertext = checkNull(a.Owner_text__c + '');
                c.PromoterDailyReport = checkNull(a.PromoterDailyReport__c + '');
                c.RecordLink = checkNull(a.RecordLink__c + '');
                c.ReportDateFormula = checkNull(a.ReportDateFormula__c + '');
                c.ReportSubmittedDate = checkNull(a.ReportSubmittedDate__c + '');
                c.ReportSubmittedDelayJudgment = checkNull(a.ReportSubmittedDelayJudgment__c + '');
                c.ReportContent = checkNull(a.Report_Content__c + '');
                c.ReportDate = checkNull(a.Report_Date__c + '');
                c.SAOpsRegionalManager = checkNull(a.SAOpsRegionalManager__c + '');
                c.SARegionalManager = checkNull(a.SARegionalManager__c + '');
                c.SalesRegion = checkNull(a.Sales_Region__c + '');
                c.ShareGriddingCode = checkNull(a.Share_Gridding_Code__c + '');
                c.ShareShop = checkNull(a.Share_Shop__c + '');
                c.Shop = checkNull(a.Shop__c + '');
                c.Status = checkNull(a.Status__c + '');
              
                PromoterDailyReportInfoList.add(c);

            }
            result.PromoterDailyReportInfoList = PromoterDailyReportInfoList;
            String sql1 = 'select count(id) totalNumber from Promoter_Daily_Report__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterDailyReportToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody + '返回条数：' + Integer.valueOf(c.get(0).get('totalNumber'));
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterDailyReportToBigData';
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