/**********************************************************************
 * function:将Daily Sales推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendDailySalesToBigData')
global with sharing class SendDailySalesToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<DailySalesInfo> dailySalesInfoList;
    }

    public class DailySalesInfo {
        public String id;
        public String Name;
        public String CreatedDate;
        public String LastModifiedDate;  
        public String CurrencyIsoCode;
        public String Brand;
        public String ChangeDailySalesHistory;
        public String Comments;
        public String CreatedEmail;
        public String CustomerName;
        public String Customer;
        public String Description;
        public String District;
        public String GiftQuantity;
        public String Gift;
        public String HasGift;
        public String IsSampling;
        public String IsUpload;
        public String IsExport;
        public String Kiosk;
        public String ListPrice;
        public String Number1;
        public String OwnerId;
        public String Owner;
        public String Price;
        public String ProductBrand;
        public String ProductCategory;
        public String ProductLine;
        public String ProductSeries;
        public String Product_Category;
        public String Product_Line;
        public String Product;
        public String PromoterDailyReport;
        public String ReportDate;
        public String Reportmonth;
        public String Reportyear;
        public String SPIV;
        public String SalesGoal;
        public String SalesRegion;
        public String SameMonth;
        public String Shop;
        public String Status;
        public String StoreDelivery;
        public String StoreSalesRegion;
        public String TotalPrice;
    }

    @HttpPost
    global static SendDailySalesToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendDailySalesToBigData.AppInput appInput = new SendDailySalesToBigData.AppInput();
        
        SendDailySalesToBigData.AppOutPut result = new SendDailySalesToBigData.AppOutPut();
        
        try{
            appInput = (SendDailySalesToBigData.AppInput)JSON.deserialize(reqBody, SendDailySalesToBigData.AppInput.class);

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
            'LastModifiedDate, '+
            'CurrencyIsoCode,'+
            'Brand__c,'+
            'Change_Daily_Sales_History__c,'+
            'Comments__c,'+
            'Created_Email__c,'+
            'Customer_Name__c,'+
            'Customer__c,'+
            'Description__c,'+
            'District__c,'+
            'GiftQuantity__c,'+
            'Gift__c,'+
            'HasGift__c,'+
            'IsSampling__c,'+
            'IsUpload__c,'+
            'Is_Export__c,'+
            'Kiosk__c,'+
            'List_Price__c,'+
            'Number__c,'+
            'OwnerId__c,'+
            'Owner__c,'+
            'Price__c,'+
            'ProductBrand__c,'+
            'ProductCategory__c,'+
            'ProductLine__c,'+
            'ProductSeries__c,'+
            'Product_Category__c,'+
            'Product_Line__c,'+
            'Product__c,'+
            'PromoterDailyReport__c,'+
            'ReportDate__c,'+
            'Reportmonth__c,'+
            'Reportyear__c,'+
            'SPIV__c,'+
            'SalesGoal__c,'+
            'Sales_Region__c,'+
            'SameMonth__c,'+
            'Shop__c,'+
            'Status__c,'+
            'StoreDelivery__c,'+
            'Store_Sales_Region__c,'+
            'TotalPrice__c'+

            ' from Retail_Number__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Retail_Number__c> DailySalesList = (List<Retail_Number__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<DailySalesInfo> DailySalesInfoList = new List<DailySalesInfo>();

            for(Retail_Number__c a : DailySalesList){
                DailySalesInfo c = new DailySalesInfo();
                c.id = a.id;
                c.Name = a.Name;
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode + '');
                c.Brand = checkNull(a.Brand__c + '');
                c.ChangeDailySalesHistory = checkNull(a.Change_Daily_Sales_History__c + '');
                c.Comments = checkNull(a.Comments__c + '');
                c.CreatedEmail = checkNull(a.Created_Email__c + '');
                c.CustomerName = checkNull(a.Customer_Name__c + '');
                c.Customer = checkNull(a.Customer__c + '');
                c.Description = checkNull(a.Description__c + '');
                c.District = checkNull(a.District__c + '');
                c.GiftQuantity = checkNull(a.GiftQuantity__c + '');
                c.Gift = checkNull(a.Gift__c + '');
                c.HasGift = checkNull(a.HasGift__c + '');
                c.IsSampling = checkNull(a.IsSampling__c + '');
                c.IsUpload = checkNull(a.IsUpload__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                c.Kiosk = checkNull(a.Kiosk__c + '');
                c.ListPrice = checkNull(a.List_Price__c + '');
                c.Number1 = checkNull(a.Number__c + '');
                c.OwnerId = checkNull(a.OwnerId__c + '');
                c.Owner = checkNull(a.Owner__c + '');
                c.Price = checkNull(a.Price__c + '');
                c.ProductBrand = checkNull(a.ProductBrand__c + '');
                c.ProductCategory = checkNull(a.ProductCategory__c + '');
                c.ProductLine = checkNull(a.ProductLine__c + '');
                c.ProductSeries = checkNull(a.ProductSeries__c + '');
                c.Product_Category = checkNull(a.Product_Category__c + '');
                c.Product_Line = checkNull(a.Product_Line__c + '');
                c.Product = checkNull(a.Product__c + '');
                c.PromoterDailyReport = checkNull(a.PromoterDailyReport__c + '');
                c.ReportDate = checkNull(a.ReportDate__c + '');
                c.Reportmonth = checkNull(a.Reportmonth__c + '');
                c.Reportyear = checkNull(a.Reportyear__c + '');
                c.SPIV = checkNull(a.SPIV__c + '');
                c.SalesGoal = checkNull(a.SalesGoal__c + '');
                c.SalesRegion = checkNull(a.Sales_Region__c + '');
                c.SameMonth = checkNull(a.SameMonth__c + '');
                c.Shop = checkNull(a.Shop__c + '');
                c.Status = checkNull(a.Status__c + '');
                c.StoreDelivery = checkNull(a.StoreDelivery__c + '');
                c.StoreSalesRegion = checkNull(a.Store_Sales_Region__c + '');
                c.TotalPrice = checkNull(a.TotalPrice__c + '');
                DailySalesInfoList.add(c);
            }
            result.DailySalesInfoList = DailySalesInfoList;
            
            String sql1 = 'select count(id) totalNumber from Retail_Number__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendDailySalesToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody + '---返回条数' + c.get(0).get('totalNumber');
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendDailySalesToBigData';
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