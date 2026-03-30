/**********************************************************************
 * function:将促销员收入表Promoter_Revenue推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendPromoterRevenueToBigData')
global with sharing class SendPromoterRevenueToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<PromoterRevenueInfo> promoterRevenueInfoList;
    }

    public class PromoterRevenueInfo {
        
        
        public String ChannelCode;
        public String ChannelName;
        public String ExportDate;  
        public String ProductLine;
        public String SalesRevenue;
        public String StoreName;
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
    global static SendPromoterRevenueToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendPromoterRevenueToBigData.AppInput appInput = new SendPromoterRevenueToBigData.AppInput();
        
        SendPromoterRevenueToBigData.AppOutPut result = new SendPromoterRevenueToBigData.AppOutPut();
        
        try{
            appInput = (SendPromoterRevenueToBigData.AppInput)JSON.deserialize(reqBody, SendPromoterRevenueToBigData.AppInput.class);

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

            'Channel_Code__c,'+
            'Channel_Name__c,'+
            'Date__c,'+
            'Product_Line__c,'+
            'Sales_Revenue__c,'+
            'Store_Name__c'+
            ' from Promoter_Revenue__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Promoter_Revenue__c> PromoterRevenueList = (List<Promoter_Revenue__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<PromoterRevenueInfo> PromoterRevenueInfoList = new List<PromoterRevenueInfo>();

            for(Promoter_Revenue__c a : PromoterRevenueList){
                PromoterRevenueInfo c = new PromoterRevenueInfo();
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
              
                c.ChannelCode = checkNull(a.Channel_Code__c + '');
                c.ChannelName = checkNull(a.Channel_Name__c + '');
                c.ExportDate = checkNull(a.Date__c + '');
                c.ProductLine = checkNull(a.Product_Line__c + '');
                c.SalesRevenue = checkNull(a.Sales_Revenue__c + '');
                c.StoreName = checkNull(a.Store_Name__c + '');
                c.StoreId = checkNull(a.Store_Id__c + '');

                PromoterRevenueInfoList.add(c);

            }
            result.PromoterRevenueInfoList = PromoterRevenueInfoList;
            String sql1 = 'select count(id) totalNumber from Promoter_Revenue__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterRevenueToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendPromoterRevenueToBigData';
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