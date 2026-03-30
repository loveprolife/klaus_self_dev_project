/**********************************************************************
 * function:将Sampling Detail推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendSamplingDetailToBigData')
global with sharing class SendSamplingDetailToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<SamplingDetailInfo> samplingDetailInfoList;
    }

    public class SamplingDetailInfo {
        public String id;
        public String Name;
        public String CreatedDate;
        public String LastModifiedDate;
        public String AutomaticallyGenerateSampleStandard;
        public String CustomerName;
        public String DisplayStatus;
        public String ExhibitedForReporting;
        public String ExternalID;
        public String Flag;
        public String IsAdd;
        public String IsExport;
        public String NotShowTime;
        public String ProductLine;
        public String ProductId;
        public String Product;
        public String RName;
        public String SamplingStandard;
        public String ShopLevelText;
        public String ShopLevel;
        public String Shop;
        public String ShowTime;
        public String Sort1;
        public String UnplannedSample;
        public String salesregionf;
    }

    @HttpPost
    global static SendSamplingDetailToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendSamplingDetailToBigData.AppInput appInput = new SendSamplingDetailToBigData.AppInput();
        
        SendSamplingDetailToBigData.AppOutPut result = new SendSamplingDetailToBigData.AppOutPut();
        
        try{
            appInput = (SendSamplingDetailToBigData.AppInput)JSON.deserialize(reqBody, SendSamplingDetailToBigData.AppInput.class);

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
            'AutomaticallyGenerateSampleStandard__c,'+
            'Customer_Name__c,'+
            'Display_Status__c,'+
            'ExhibitedForReporting__c,'+
            'ExternalID__c,'+
            'Flag__c,'+
            'Is_Add__c,'+
            'Is_Export__c,'+
            'Not_Show_Time__c,'+
            'ProductLine__c,'+
            'Product_Id__c,'+
            'Product__c,'+
            'R_Name__c,'+
            'Sampling_Standard__c,'+
            'ShopLevelText__c,'+
            'Shop_Level__c,'+
            'Shop__c,'+
            'Show_Time__c,'+
            'Sort__c,'+
            'Unplanned_Sample__c,'+
            'sales_region_f__c'+

            ' from Sampling_Detail__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Sampling_Detail__c> SamplingDetailList = (List<Sampling_Detail__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            
            List<SamplingDetailInfo> SamplingDetailInfoList = new List<SamplingDetailInfo>();

            for(Sampling_Detail__c a : SamplingDetailList){
                SamplingDetailInfo c = new SamplingDetailInfo();
                c.id = checkNull(a.id + '');
                c.Name = checkNull(a.Name + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.AutomaticallyGenerateSampleStandard = checkNull(a.AutomaticallyGenerateSampleStandard__c + '');
                c.CustomerName = checkNull(a.Customer_Name__c + '');
                c.DisplayStatus = checkNull(a.Display_Status__c + '');
                c.ExhibitedForReporting = checkNull(a.ExhibitedForReporting__c + '');
                c.ExternalID = checkNull(a.ExternalID__c + '');
                c.Flag = checkNull(a.Flag__c + '');
                c.IsAdd = checkNull(a.Is_Add__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                c.NotShowTime = checkNull(a.Not_Show_Time__c + '');
                c.ProductLine = checkNull(a.ProductLine__c + '');
                c.ProductId = checkNull(a.Product_Id__c + '');
                c.Product = checkNull(a.Product__c + '');
                c.RName = checkNull(a.R_Name__c + '');
                c.SamplingStandard = checkNull(a.Sampling_Standard__c + '');
                c.ShopLevelText = checkNull(a.ShopLevelText__c + '');
                c.ShopLevel = checkNull(a.Shop_Level__c + '');
                c.Shop = checkNull(a.Shop__c + '');
                c.ShowTime = checkNull(a.Show_Time__c + '');
                c.Sort1 = checkNull(a.Sort__c + '');
                c.UnplannedSample = checkNull(a.Unplanned_Sample__c + '');
                c.salesregionf = checkNull(a.sales_region_f__c + '');

                SamplingDetailInfoList.add(c);
            }
            result.SamplingDetailInfoList = SamplingDetailInfoList;
            String sql1 = 'select count(id) totalNumber from Sampling_Detail__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingDetailToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingDetailToBigData';
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