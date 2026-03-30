/**********************************************************************
 * function:将看板指标数据推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-06
*************************************************************************/
@RestResource(urlMapping='/SendTicketToBigData')
global with sharing class SendTicketToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<TicketInfo> ticketInfoList;
    }
    
    @HttpPost
    global static SendTicketToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendTicketToBigData.AppInput appInput = new SendTicketToBigData.AppInput();
        
        SendTicketToBigData.AppOutPut result = new SendTicketToBigData.AppOutPut();
        
        try{
            appInput = (SendTicketToBigData.AppInput)JSON.deserialize(reqBody, SendTicketToBigData.AppInput.class);

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
            'LastModifiedDate, '+
            'AssignedTo__c,'+
            'CheckItem__c,'+
            'CheckResult__c,'+
            'ClosedDailyInspectionReport__c,'+
            'Department__c,'+
            'Description__c,'+
            'DueDate__c,'+
            'Histories_Feedback__c,'+
            'InspectionReport__c,'+
            'Newest_Feedback__c,'+
            'Priority__c,'+
            'PromoterDailyReport__c,'+
            'ResponsibleDepartmentUserIds__c,'+
            'ResponsibleDepartment__c,'+
            'SalesRegion__c,'+
            'Sales_Region__c,'+
            'Status__c,'+
            'Subject__c,'+
            'isMine__c'+

            ' from Ticket__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Ticket__c> ticketList = (List<Ticket__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Ticket__c> ticketList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<TicketInfo> ticketInfoList = new List<TicketInfo>();
            for(Ticket__c t : ticketList){
                TicketInfo ti = new TicketInfo();
                ti.id  = checkNull(t.id  + '');
                ti.Name  = checkNull(t.Name  + '');
                ti.CreatedDate  = checkNull(t.CreatedDate  + '');
                ti.LastModifiedDate  = checkNull(t.LastModifiedDate  + '');
                ti.AssignedTo = checkNull(t.AssignedTo__c + '');
                ti.CheckItem = checkNull(t.CheckItem__c + '');
                ti.CheckResult = checkNull(t.CheckResult__c + '');
                ti.ClosedDailyInspectionReport = checkNull(t.ClosedDailyInspectionReport__c + '');
                ti.Department = checkNull(t.Department__c + '');
                ti.Description = checkNull(t.Description__c + '');
                ti.DueDate = checkNull(t.DueDate__c + '');
                ti.Histories_Feedback = checkNull(t.Histories_Feedback__c + '');
                ti.InspectionReport = checkNull(t.InspectionReport__c + '');
                ti.Newest_Feedback = checkNull(t.Newest_Feedback__c + '');
                ti.Priority = checkNull(t.Priority__c + '');
                ti.PromoterDailyReport = checkNull(t.PromoterDailyReport__c + '');
                ti.ResponsibleDepartmentUserIds = checkNull(t.ResponsibleDepartmentUserIds__c + '');
                ti.ResponsibleDepartment = checkNull(t.ResponsibleDepartment__c + '');
                ti.SalesRegion = checkNull(t.SalesRegion__c + '');
                ti.Sales_Region = checkNull(t.Sales_Region__c + '');
                ti.Status = checkNull(t.Status__c + '');
                ti.Subject = checkNull(t.Subject__c + '');
                ti.isMine = checkNull(t.isMine__c + '');

                ticketInfoList.add(ti);
            }
            result.ticketInfoList = ticketInfoList;
            String sql1 = 'select count(id) totalNumber from Ticket__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);
            System.debug('result.totalPage :' + c.get(0).get('totalNumber'));
            System.debug('result.totalPage :' + appInput.pageSize);
            System.debug('result.totalPage :' + result.totalPage);
            System.debug('result.totalPage :' + ticketInfoList.size());
            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendTicketToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            //String str = JSON.serialize(result).replace('null','null');
            //result = (SendTicketToBigData.AppOutPut)JSON.deserialize(str, SendTicketToBigData.AppOutPut.class);
            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendTicketToBigData';
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

    public class TicketInfo{
        public String id; 
        public String Name; 
        public String CreatedDate;
        public String LastModifiedDate;  
        public String AssignedTo;
        public String CheckItem;
        public String CheckResult;
        public String ClosedDailyInspectionReport;
        public String Department;
        public String Description;
        public String DueDate;
        public String Histories_Feedback;
        public String InspectionReport;
        public String Newest_Feedback;
        public String Priority;
        public String PromoterDailyReport;
        public String ResponsibleDepartmentUserIds;
        public String ResponsibleDepartment;
        public String SalesRegion;
        public String Sales_Region;
        public String Status;
        public String Subject;
        public String isMine;
    }

}