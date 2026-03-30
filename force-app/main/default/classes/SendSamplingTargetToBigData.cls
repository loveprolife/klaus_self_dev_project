/**********************************************************************
 * function:将SamplingTarget推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendSamplingTargetToBigData')
global with sharing class SendSamplingTargetToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<SamplingTargetInfo> samplingTargetInfoList;
    }

    public class SamplingTargetInfo {
        public String id;
        public String region; //Region__c 大区
        public String SBU; // SBU__c 海外公司 SBU
        public String customerModel; // Customer_Model__c 客户型号
        public String priceUSD; // USD__c 价格段Price（USD）(匹配信数)
        public String sampleStatus; // Sample_Status__c 出样状态
        public String channel; // Channel__c 渠道名称 Channel (与渠道信息一致)   
        public String totalSampleQtyIn2023; // Total_Sample_Qty_in_2023__c 2023累计出样数量
        public String totalSampleTargetedQtyIn2024; // Total_Sample_Targeted_Qty_in_2024__c 2024累计出样目标
        public String annualTargetAchievementProgress; // Annual_Target_Achievement_Progress__c 年度目标达成进度Annual Target Achievement Progress(最新实际出样/年度累计出样目标)
        public String targetedSampleNumbersJan; // Targeted_Sample_Numbers_Jan__c 目标出样数量   
        public String targetedSampleNumbersFeb; // Targeted_Sample_Numbers_Feb__c 目标出样数量
        public String targetedSampleNumbersMar; // Targeted_Sample_Numbers_Mar__c 目标出样数量  
        public String targetedSampleNumbersApr; // Targeted_Sample_Numbers_Apr__c 目标出样数量
        public String targetedSampleNumbersMay; // Targeted_Sample_Numbers_May__c 目标出样数量 
        public String targetedSampleNumbersJun; // Targeted_Sample_Numbers_Jun__c 目标出样数量
        public String targetedSampleNumbersJuly; // Targeted_Sample_Numbers_July__c 目标出样数量
        public String targetedSampleNumbersAug; // Targeted_Sample_Numbers_Aug__c 目标出样数量
        public String targetedSampleNumbersSep; // Targeted_Sample_Numbers_Sep__c 目标出样数量
        public String targetedSampleNumbersOct; // Targeted_Sample_Numbers_Oct__c 目标出样数量 
        public String targetedSampleNumbersNov; // Targeted_Sample_Numbers_Nov__c 目标出样数量
        public String targetedSampleNumbersDec; // Targeted_Sample_Numbers_Dec__c 目标出样数量  
        public String exportDate;  
        public String CreatedDate;
        public String LastModifiedDate; 
        public String channelCode;
        public String SamplingTargetYear; //Sampling_Target_Year__c	

        public String OwnerId;
        public String IsDeleted;
        public String Name;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String LastModifiedById;
        public String SystemModstamp;
        public String LastViewedDate;
        public String LastReferencedDate;
        public String Index;
        public String Key;
        public String ActualSampleQty;
        public String Brand;
        public String PlatformModel;
        public String ProductLine;

    }

    @HttpPost
    global static SendSamplingTargetToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendSamplingTargetToBigData.AppInput appInput = new SendSamplingTargetToBigData.AppInput();
        
        SendSamplingTargetToBigData.AppOutPut result = new SendSamplingTargetToBigData.AppOutPut();
        
        try{
            appInput = (SendSamplingTargetToBigData.AppInput)JSON.deserialize(reqBody, SendSamplingTargetToBigData.AppInput.class);

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
            'Index__c,'+
            'Key__c,'+
            'Brand__c,'+
            'Platform_Model__c,'+
            'Product_Line__c,'+
            'Actual_Sample_Qty__c,'+
            'Sampling_Target_Year__c,'+
            

            'id,'+
            'Region__c,'+
            'SBU__c,'+
            'Customer_Model__c,'+
            'USD__c,'+
            'Sample_Status__c,'+
            'Channel__c,'+
            'Total_Sample_Qty_in_2023__c,'+
            'Total_Sample_Targeted_Qty_in_2024__c,'+
            'Annual_Target_Achievement_Progress__c,'+
            'Targeted_Sample_Numbers_Jan__c,'+
            'Targeted_Sample_Numbers_Feb__c,'+
            'Targeted_Sample_Numbers_Mar__c,'+
            'Targeted_Sample_Numbers_Apr__c,'+
            'Targeted_Sample_Numbers_May__c,'+
            'Targeted_Sample_Numbers_Jun__c,'+
            'Targeted_Sample_Numbers_July__c,'+
            'Targeted_Sample_Numbers_Aug__c,'+
            'Targeted_Sample_Numbers_Sep__c,'+
            'Targeted_Sample_Numbers_Oct__c,'+
            'Targeted_Sample_Numbers_Nov__c,'+
            'Targeted_Sample_Numbers_Dec__c,'+
            'Date__c,'+
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Channel_Code__c'+
            ' from Sampling_Target__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Sampling_Target__c> samplingTargetList = (List<Sampling_Target__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Sampling_Target__c> samplingTargetList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));

            List<SamplingTargetInfo> samplingTargetInfoList = new List<SamplingTargetInfo>();

            for(Sampling_Target__c a : samplingTargetList){
                SamplingTargetInfo c = new SamplingTargetInfo();
                c.id = a.id;
                c.region = checkNull(a.Region__c);
                c.SBU = checkNull(a.SBU__c);
                c.customerModel = checkNull(a.Customer_Model__c);
                c.priceUSD = checkNull(a.USD__c);
                c.sampleStatus = checkNull(a.Sample_Status__c);
                c.channel = checkNull(a.Channel__c);
                c.totalSampleQtyIn2023 = checkNull(a.Total_Sample_Qty_in_2023__c + '');
                c.totalSampleTargetedQtyIn2024 = checkNull(a.Total_Sample_Targeted_Qty_in_2024__c + '');
                c.annualTargetAchievementProgress = checkNull(a.Annual_Target_Achievement_Progress__c);
                c.targetedSampleNumbersJan = checkNull(a.Targeted_Sample_Numbers_Jan__c + '');
                c.targetedSampleNumbersFeb = checkNull(a.Targeted_Sample_Numbers_Feb__c + '');
                c.targetedSampleNumbersMar = checkNull(a.Targeted_Sample_Numbers_Mar__c + '');
                c.targetedSampleNumbersApr = checkNull(a.Targeted_Sample_Numbers_Apr__c + '');
                c.targetedSampleNumbersMay = checkNull(a.Targeted_Sample_Numbers_May__c + '');
                c.targetedSampleNumbersJun = checkNull(a.Targeted_Sample_Numbers_Jun__c + '');
                c.targetedSampleNumbersJuly = checkNull(a.Targeted_Sample_Numbers_July__c + '');
                c.targetedSampleNumbersAug = checkNull(a.Targeted_Sample_Numbers_Aug__c + '');
                c.targetedSampleNumbersSep = checkNull(a.Targeted_Sample_Numbers_Sep__c + '');
                c.targetedSampleNumbersOct = checkNull(a.Targeted_Sample_Numbers_Oct__c + '');
                c.targetedSampleNumbersNov = checkNull(a.Targeted_Sample_Numbers_Nov__c + '');
                c.targetedSampleNumbersDec = checkNull(a.Targeted_Sample_Numbers_Dec__c + '');
                c.exportDate = checkNull(a.Date__c + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.channelCode = checkNull(a.Channel_Code__c + '');
                c.SamplingTargetYear = checkNull(a.Sampling_Target_Year__c + '');

                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.Name = checkNull(a.Name);
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
                c.LastViewedDate = '';
                c.LastReferencedDate = '';
                c.Index = checkNull(a.Index__c);
                c.Key = checkNull(a.Key__c);
                c.Brand = checkNull(a.Brand__c);
                c.PlatformModel = checkNull(a.Platform_Model__c);
                c.ProductLine = checkNull(a.Product_Line__c);
                c.ActualSampleQty = checkNull(a.Actual_Sample_Qty__c);


                samplingTargetInfoList.add(c);

            }
            result.samplingTargetInfoList = samplingTargetInfoList;
            String sql1 = 'select count(id) totalNumber from Sampling_Target__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingTargetToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendSamplingTargetToBigData';
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