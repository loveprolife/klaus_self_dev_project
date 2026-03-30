/**********************************************************************
 * function:将Inspection Plan推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendInspectionPlanToBigData')
global with sharing class SendInspectionPlanToBigData{  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<InspectionPlanInfo> inspectionPlanInfoList;
    }

    public class InspectionPlanInfo {
        public String id;
        public String Name;
        public String CreatedDate;
        public String LastModifiedDate;
        public String Approver1;
        public String Approver2;
        public String InspectionMonth;
        public String InspectionYear;
        public String IsExport;
        public String OwnerId;
        public String SalesRegion;
        public String Status;
        public String Submiter;
    }

    @HttpPost
    global static SendInspectionPlanToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendInspectionPlanToBigData.AppInput appInput = new SendInspectionPlanToBigData.AppInput();
        
        SendInspectionPlanToBigData.AppOutPut result = new SendInspectionPlanToBigData.AppOutPut();
        
        try{
            appInput = (SendInspectionPlanToBigData.AppInput)JSON.deserialize(reqBody, SendInspectionPlanToBigData.AppInput.class);

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
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Approver1__c,'+
            'Approver2__c,'+
            'Inspection_Month__c,'+
            'Inspection_Year__c,'+
            'Is_Export__c,'+
            'OwnerId__c,'+
            'Sales_Region__c,'+
            'Status__c,'+
            'Submiter__c'+

            ' from Inspection_Shop_Plan__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Inspection_Shop_Plan__c> InspectionPlanList = (List<Inspection_Shop_Plan__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Inspection_Shop_Plan__c> InspectionPlanList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<InspectionPlanInfo> InspectionPlanInfoList = new List<InspectionPlanInfo>();

            for(Inspection_Shop_Plan__c a : InspectionPlanList){
                InspectionPlanInfo c = new InspectionPlanInfo();
                c.id = checkNull(a.id + '');
                c.Name = a.Name;
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.Approver1 = checkNull(a.Approver1__c + '');
                c.Approver2 = checkNull(a.Approver2__c + '');
                c.InspectionMonth = checkNull(a.Inspection_Month__c + '');
                c.InspectionYear = checkNull(a.Inspection_Year__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                c.OwnerId = checkNull(a.OwnerId__c + '');
                c.SalesRegion = checkNull(a.Sales_Region__c + '');
                c.Status = checkNull(a.Status__c + '');
                c.Submiter = checkNull(a.Submiter__c + '');

                InspectionPlanInfoList.add(c);
            }
            result.InspectionPlanInfoList = InspectionPlanInfoList;
            String sql1 = 'select count(id) totalNumber from Inspection_Shop_Plan__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);
           

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendInspectionPlanToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendInspectionPlanToBigData';
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