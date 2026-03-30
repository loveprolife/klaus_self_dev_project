/**********************************************************************
 * function:将SamplingCondition推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendSamplingConditionToBigData')
global with sharing class SendSamplingConditionToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<SamplingConditionInfo> samplingConditionInfoList;
    }

    public class SamplingConditionInfo {
        public String id;
        public String region; //Region__c 大区
        public String SBU; // SBU__c 海外公司 SBU
        public String channelCode; // Channel_Code__c 客户管理名称编码
        public String customerModel; // Customer_Model__c 客户型号
        public String priceUSD; // USD__c 价格段Price（USD）(匹配信数)
        public String samplingStatus; // Sampling_Status__c 出样状态
        public String actualSampleQty; // Actual_Sample_Qty__c 累计实际出样数量
        public String channel; // Channel__c 渠道名称 Channel (与渠道信息一致)   
        public String exportDate;  
        public String CreatedDate;
        public String LastModifiedDate; 

        public String OwnerId;
        public String IsDeleted;
        public String Name;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String LastModifiedById;
        public String SystemModstamp;
        public String LastViewedDate;
        public String LastReferencedDate;
        public String Key;
        public String Index;
        public String Brand;
        public String PlatformModel;
        public String ProductLine;
        public String TotalSampleTargetedQtyin2024;

    }

    @HttpPost
    global static SendSamplingConditionToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendSamplingConditionToBigData.AppInput appInput = new SendSamplingConditionToBigData.AppInput();
        
        SendSamplingConditionToBigData.AppOutPut result = new SendSamplingConditionToBigData.AppOutPut();
        
        try{
            appInput = (SendSamplingConditionToBigData.AppInput)JSON.deserialize(reqBody, SendSamplingConditionToBigData.AppInput.class);

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

            'OwnerId,'+
            'IsDeleted,'+
            'Name,'+
            'CurrencyIsoCode,'+
            'CreatedById,'+
            'LastModifiedById,'+
            'SystemModstamp,'+
            'Key__c,'+
            'Index__c,'+
            'Brand__c,'+
            'Platform_Model__c,'+
            'Product_Line__c,'+
            'Total_Sample_Targeted_Qty_in_2024__c,'+


            'id,'+
            'Region__c,'+
            'SBU__c,'+
            'Channel_Code__c,'+
            'Customer_Model__c,'+
            'USD__c,'+
            'Sampling_Status__c,'+
            'Actual_Sample_Qty__c,'+
            'Channel__c,'+
            'Date__c,'+
            'CreatedDate,'+
            'LastModifiedDate'+
            ' from Sampling_Condition__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Sampling_Condition__c> samplingConditionList = (List<Sampling_Condition__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Sampling_Condition__c> samplingConditionList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<SamplingConditionInfo> samplingConditionInfoList = new List<SamplingConditionInfo>();

            for(Sampling_Condition__c a : samplingConditionList){
                SamplingConditionInfo c = new SamplingConditionInfo();
                c.id = a.id;
                c.region = checkNull(a.Region__c);
                c.SBU = checkNull(a.SBU__c);
                c.channelCode = checkNull(a.Channel_Code__c);
                c.customerModel = checkNull(a.Customer_Model__c);
                c.priceUSD = checkNull(a.USD__c);
                c.samplingStatus = checkNull(a.Sampling_Status__c);
                c.actualSampleQty = checkNull(a.Actual_Sample_Qty__c);
                c.channel = checkNull(a.Channel__c);
                c.exportDate = checkNull(a.Date__c + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');

                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.Name = checkNull(a.Name);
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
                c.LastViewedDate = '';
                c.LastReferencedDate = '';
                c.Key = checkNull(a.Key__c);
                c.Index = checkNull(a.Index__c);
                c.Brand = checkNull(a.Brand__c);
                c.PlatformModel = checkNull(a.Platform_Model__c);
                c.ProductLine = checkNull(a.Product_Line__c);
                c.TotalSampleTargetedQtyin2024 = checkNull(a.Total_Sample_Targeted_Qty_in_2024__c + '');

                samplingConditionInfoList.add(c);
            }
            result.samplingConditionInfoList = samplingConditionInfoList;
            String sql1 = 'select count(id) totalNumber from Sampling_Condition__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingConditionToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingConditionToBigData';
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