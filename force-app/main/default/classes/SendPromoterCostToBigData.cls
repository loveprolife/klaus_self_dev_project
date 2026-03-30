/**********************************************************************
 * function:促销员费用表Promoter_Cost
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendPromoterCostToBigData')
global with sharing class SendPromoterCostToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<PromoterCostInfo> promoterCostInfoList;
    }

    public class PromoterCostInfo {
        
        public String YearMonth;
        public String ChannelCode;
        public String ChannelName;
        public String StoreName;
        public String Promoter;
        public String PromoterEmail;
        public String EmploymentDate;
        public String DepartureDate;
        public String Salary;
        public String Commission;
        public String AdditionalAmount;
        public String StoreId;

        public String id;
        public String Name;
        public String OwnerId;
        public String IsDeleted;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String CreatedDate;
        public String LastModifiedById;
        public String LastModifiedDate;
        public String SystemModstamp;
    }

    @HttpPost
    global static SendPromoterCostToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendPromoterCostToBigData.AppInput appInput = new SendPromoterCostToBigData.AppInput();
        
        SendPromoterCostToBigData.AppOutPut result = new SendPromoterCostToBigData.AppOutPut();
        
        try{
            appInput = (SendPromoterCostToBigData.AppInput)JSON.deserialize(reqBody, SendPromoterCostToBigData.AppInput.class);

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
            'SystemModstamp,'+
            
            'Store_Id__c,'+
            'Year_Month__c,'+
            'Channel_Code__c,'+
            'Channel_Name__c,'+
            'Store_Name__c,'+
            'Promoter__c,'+
            'Promoter_Email__c,'+
            'Employment_Date__c,'+
            'Departure_Date__c,'+
            'Salary__c,'+
            'Commission__c,'+
            'Additional_Amount__c'+
            
            ' from Promoter_Cost__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Promoter_Cost__c> PromoterCostList = (List<Promoter_Cost__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<PromoterCostInfo> PromoterCostInfoList = new List<PromoterCostInfo>();

            for(Promoter_Cost__c a : PromoterCostList){
                PromoterCostInfo c = new PromoterCostInfo();
                c.id = a.id;
                c.Name = checkNull(a.Name);
                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
              
                c.YearMonth = checkNull(a.Year_Month__c + '');
                c.ChannelCode = checkNull(a.Channel_Code__c + '');
                c.ChannelName = checkNull(a.Channel_Name__c + '');
                c.StoreName = checkNull(a.Store_Name__c + '');
                c.Promoter = checkNull(a.Promoter__c + '');
                c.PromoterEmail = checkNull(a.Promoter_Email__c + '');
                c.EmploymentDate = checkNull(a.Employment_Date__c + '');
                c.DepartureDate = checkNull(a.Departure_Date__c + '');
                c.Salary = checkNull(a.Salary__c + '');
                c.Commission = checkNull(a.Commission__c + '');
                c.AdditionalAmount = checkNull(a.Additional_Amount__c + '');
                c.StoreId = checkNull(a.Store_Id__c + '');

                PromoterCostInfoList.add(c);

            }
            result.PromoterCostInfoList = PromoterCostInfoList;
            String sql1 = 'select count(id) totalNumber from Promoter_Cost__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterCostToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterCostToBigData';
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