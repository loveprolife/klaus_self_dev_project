/**********************************************************************
 * function:将Channel item推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-07-19
*************************************************************************/
@RestResource(urlMapping='/SendChannelItemToBigData')
global with sharing class SendChannelItemToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<ChannelItemInfo> channelItemInfoList;
    }

    public class ChannelItemInfo {
        public String id;
        public String Name;
        public String CreatedDate;
        public String LastModifiedDate;  
        public String OwnerId;
        public String IsDeleted;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String LastModifiedById;

        public String ChannelName;
        public String ChannelCode;

        public String SBU;
        //public String Sales_Region;

    }

    @HttpPost
    global static SendChannelItemToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendChannelItemToBigData.AppInput appInput = new SendChannelItemToBigData.AppInput();
        
        SendChannelItemToBigData.AppOutPut result = new SendChannelItemToBigData.AppOutPut();
        
        try{
            appInput = (SendChannelItemToBigData.AppInput)JSON.deserialize(reqBody, SendChannelItemToBigData.AppInput.class);

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
            'id,'+
            'Name,'+
            'CreatedDate,'+
            'LastModifiedDate, '+
            'Channel_Code__c, '+
            'SBU__c, '+
            //'Sales_Region__c, '+
            'Channel_Name__c'+
            ' from Channel_item__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Channel_item__c> channelList = (List<Channel_item__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Channel_item__c> channelList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<ChannelItemInfo> ChannelItemInfoList = new List<ChannelItemInfo>();

            for(Channel_item__c a : channelList){
                ChannelItemInfo c = new ChannelItemInfo();
                c.id = a.id;
                c.Name = a.Name;
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.OwnerId = checkNull(a.OwnerId);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.channelName = checkNull(a.Channel_Name__c + '');
                c.channelCode = checkNull(a.Channel_Code__c + '');

                c.SBU = checkNull(a.SBU__c + '');
                //c.Sales_Region = checkNull(a.Sales_Region__c + '');

                ChannelItemInfoList.add(c);
            }
            result.ChannelItemInfoList = ChannelItemInfoList;
            String sql1 = 'select count(id) totalNumber from Channel_item__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendChannelItemToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendChannelItemToBigData';
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