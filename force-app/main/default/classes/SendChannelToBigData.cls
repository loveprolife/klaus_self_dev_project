/**********************************************************************
 * function:将Channel推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendChannelToBigData')
global with sharing class SendChannelToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<ChannelInfo> channelInfoList;
    }

    public class ChannelInfo {
        public String id;
        public String CreatedDate;
        public String LastModifiedDate;  
        public String productLine;
        public String SBU;
        public String country;
        public String channelName;
        public String marketShare;
        public String annualBusinessRevenueUnit10kUSD;
        public String cooperatingMethod;
        public String cooperatingCustomerEntityName;
        public String cooperatingCustomerSAPCode;
        public String cooperatingStatus;
        public String hisenseValueShare;
        public String numberOfStores;
        public String numberOfEnteredStores;
        public String numberOfNewStoreEnteringPlan2024;
        public String plannedCooperatingTime;

        public String OwnerId;
        public String IsDeleted;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String LastModifiedById;
        public String SystemModstamp;
        public String LastViewedDate;
        public String LastReferencedDate;
        public String Index;
        public String Key;
        public String SBUCode;
        public String StatisticalYear;
        public String CooperatingTime;
        public String Region;
        public String ChannelCodeFormula;

    }

    @HttpPost
    global static SendChannelToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendChannelToBigData.AppInput appInput = new SendChannelToBigData.AppInput();
        
        SendChannelToBigData.AppOutPut result = new SendChannelToBigData.AppOutPut();
        
        try{
            appInput = (SendChannelToBigData.AppInput)JSON.deserialize(reqBody, SendChannelToBigData.AppInput.class);

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
            'CurrencyIsoCode,'+
            'CreatedById,'+
            'LastModifiedById,'+
            'SystemModstamp,'+
            'Index__c,'+
            'Key__c,'+
            'SBU_Code__c,'+
            'Statistical_Year__c,'+
            'Cooperating_Time__c,'+


            'id,'+
            'Name,'+
            'CreatedDate,'+
            'LastModifiedDate, '+
            'Annual_Business_Revenue_Unit_10k_USD__c,'+
            'Cooperating_Customer_Entity_Name__c,'+
            'Cooperating_Customer_SAP_Code__c,'+
            'Cooperating_Method__c,'+
            'Country__c,'+
            'Hisense_Value_Share__c,'+
            'Market_Share__c,'+
            'Number_of_Entered_Stores__c,'+
            'Number_of_New_Store_Entering_Plan_2024__c,'+
            'Number_of_Stores__c,'+
            'Product_Line__c,'+
            'SBU__c,'+
            'Cooperating_Status__c,'+
            'Region__c,'+
            'Channel_Code_Formula__c,'+
            'Planned_Cooperating_Time__c'+
            ' from Channel__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Channel__c> channelList = (List<Channel__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Channel__c> channelList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<ChannelInfo> channelInfoList = new List<ChannelInfo>();

            for(Channel__c a : channelList){
                ChannelInfo c = new ChannelInfo();
                c.id = a.id;
                c.channelName = a.Name;
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.productLine = checkNull(a.Product_Line__c);
                c.SBU = checkNull(a.SBU__c);
                c.country = checkNull(a.Country__c);
                c.marketShare = checkNull(a.Market_Share__c);
                c.annualBusinessRevenueUnit10kUSD = checkNull(a.Annual_Business_Revenue_Unit_10k_USD__c);
                c.cooperatingStatus = checkNull(a.Cooperating_Status__c);
                c.cooperatingMethod = checkNull(a.Cooperating_Method__c);
                c.cooperatingCustomerEntityName = checkNull(a.Cooperating_Customer_Entity_Name__c);
                c.cooperatingCustomerSAPCode = checkNull(a.Cooperating_Customer_SAP_Code__c);
                c.numberOfStores = checkNull(a.Number_of_Stores__c);
                c.numberOfEnteredStores = checkNull(a.Number_of_Entered_Stores__c);
                c.numberOfNewStoreEnteringPlan2024 = checkNull(a.Number_of_New_Store_Entering_Plan_2024__c);
                c.hisenseValueShare = checkNull(a.Hisense_Value_Share__c);
                c.plannedCooperatingTime = checkNull(a.Planned_Cooperating_Time__c);

                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
                c.LastViewedDate = '';
                c.LastReferencedDate = '';
                c.Index = checkNull(a.Index__c);
                c.Key = checkNull(a.Key__c);
                c.SBUCode = checkNull(a.SBU_Code__c);
                c.StatisticalYear = checkNull(a.Statistical_Year__c);
                c.CooperatingTime = checkNull(a.Cooperating_Time__c);

                c.Region = checkNull(a.Region__c + '');
                c.ChannelCodeFormula = checkNull(a.Channel_Code_Formula__c + '');



                ChannelInfoList.add(c);
            }
            result.channelInfoList = channelInfoList;
            String sql1 = 'select count(id) totalNumber from Channel__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendChannelToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendChannelToBigData';
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