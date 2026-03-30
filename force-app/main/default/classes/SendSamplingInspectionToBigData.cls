/**********************************************************************
 * function:将Sampling Inspection推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendSamplingInspectionToBigData')
global with sharing class SendSamplingInspectionToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<SamplingInspectionInfo> samplingInspectionInfoList;
    }

    public class SamplingInspectionInfo {
        public String id;	
        public String CreatedDate;	
        public String LastModifiedDate;	
        public String Name;	
        public String ExternalID;	
        public String Flag;	
        public String InspectionDate;	
        public String InspectionShopTask;	
        public String IsChange;	
        public String IsNew;	
        public String IsExport;	
        public String PlacementStatus;	
        public String Product;	
        public String ReRe;	
        public String SampleImagesUrl;	
        public String SampleItem;	
        public String ShareGriddingCode;	
        public String ShareShop;	
        public String Shop;	
        public String Sort1;	
        public String UnplannedSample;	
    }

    @HttpPost
    global static SendSamplingInspectionToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendSamplingInspectionToBigData.AppInput appInput = new SendSamplingInspectionToBigData.AppInput();
        
        SendSamplingInspectionToBigData.AppOutPut result = new SendSamplingInspectionToBigData.AppOutPut();
        
        try{
            appInput = (SendSamplingInspectionToBigData.AppInput)JSON.deserialize(reqBody, SendSamplingInspectionToBigData.AppInput.class);

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
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Name,'+
            'ExternalID__c,'+
            'Flag__c,'+
            'Inspection_Date__c,'+
            'Inspection_Shop_Task__c,'+
            'IsChange__c,'+
            'IsNew__c,'+
            'Is_Export__c,'+
            'Placement_Status__c,'+
            'Product__c,'+
            'ReRe__c,'+
            'Sample_Images_Url__c,'+
            'Sample_Item__c,'+
            'Share_Gridding_Code__c,'+
            'Share_Shop__c,'+
            'Shop__c,'+
            'Sort__c,'+
            'Unplanned_Sample__c'+

            ' from Sampling_Inspection__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<Sampling_Inspection__c> SamplingInspectionList = (List<Sampling_Inspection__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<SamplingInspectionInfo> SamplingInspectionInfoList = new List<SamplingInspectionInfo>();

            for(Sampling_Inspection__c a : SamplingInspectionList){
                SamplingInspectionInfo c = new SamplingInspectionInfo();
                c.id = checkNull(a.id + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.Name = checkNull(a.Name + '');
                c.ExternalID = checkNull(a.ExternalID__c + '');
                c.Flag = checkNull(a.Flag__c + '');
                c.InspectionDate = checkNull(a.Inspection_Date__c + '');
                c.InspectionShopTask = checkNull(a.Inspection_Shop_Task__c + '');
                c.IsChange = checkNull(a.IsChange__c + '');
                c.IsNew = checkNull(a.IsNew__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                c.PlacementStatus = checkNull(a.Placement_Status__c + '');
                c.Product = checkNull(a.Product__c + '');
                c.ReRe = checkNull(a.ReRe__c + '');
                c.SampleImagesUrl = checkNull(a.Sample_Images_Url__c + '');
                c.SampleItem = checkNull(a.Sample_Item__c + '');
                c.ShareGriddingCode = checkNull(a.Share_Gridding_Code__c + '');
                c.ShareShop = checkNull(a.Share_Shop__c + '');
                c.Shop = checkNull(a.Shop__c + '');
                c.Sort1 = checkNull(a.Sort__c + '');
                c.UnplannedSample = checkNull(a.Unplanned_Sample__c + '');

                SamplingInspectionInfoList.add(c);
            }
            result.SamplingInspectionInfoList = SamplingInspectionInfoList;
            String sql1 = 'select count(id) totalNumber from Sampling_Inspection__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);
            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingInspectionToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingInspectionToBigData';
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