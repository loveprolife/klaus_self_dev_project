/**********************************************************************
 * function:客户产品线表Store_Product_Line__c
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendStoreProductlineToBigData')
global with sharing class SendStoreProductlineToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<StoreProductlineInfo> storeProductlineInfoList;
    }

    public class StoreProductlineInfo {
        
        public String productLine;
        public String storeId;
        public String timeOfEntry;
        public String closeDate;
        public String EnteringStatus;

        public String id;
        public String Name;
        public String IsDeleted;
        public String CurrencyIsoCode;
        public String CreatedById;
        public String CreatedDate;
        public String LastModifiedById;
        public String LastModifiedDate;
        public String SystemModstamp;

        public String StandAmount;
        public String Type;
    }

    @HttpPost
    global static SendStoreProductlineToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendStoreProductlineToBigData.AppInput appInput = new SendStoreProductlineToBigData.AppInput();
        
        SendStoreProductlineToBigData.AppOutPut result = new SendStoreProductlineToBigData.AppOutPut();
        
        try{
            appInput = (SendStoreProductlineToBigData.AppInput)JSON.deserialize(reqBody, SendStoreProductlineToBigData.AppInput.class);

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
            'IsDeleted,'+
            'CurrencyIsoCode,'+
            'CreatedById,'+
            'CreatedDate,'+
            'LastModifiedById,'+
            'LastModifiedDate,'+
            'SystemModstamp,'+
            
            'Stand_Amount__c,'+
            'Close_Date__c,'+
            'Product_Line__c,'+
            'Store__c,'+
            'Entering_Status__c,'+
            'Type__c,'+
            'Time_Of_Entry__c'+

            ' from Store_Product_Line__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Store_Product_Line__c> StoreProductlineList = (List<Store_Product_Line__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Store_Product_Line__c> StoreProductlineList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));

            List<StoreProductlineInfo> StoreProductlineInfoList = new List<StoreProductlineInfo>();

            for(Store_Product_Line__c a : StoreProductlineList){
                StoreProductlineInfo c = new StoreProductlineInfo();
                c.id = a.id;
                c.Name = checkNull(a.Name);
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode);
                c.CreatedById = checkNull(a.CreatedById);
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedById = checkNull(a.LastModifiedById);
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
              
                c.StandAmount = checkNull(a.Stand_Amount__c + '');
                c.closeDate = checkNull(a.Close_Date__c + '');
                c.productLine = checkNull(a.Product_Line__c + '');
                c.storeId = checkNull(a.Store__c + '');
                c.timeOfEntry = checkNull(a.Time_Of_Entry__c + '');
                c.EnteringStatus = checkNull(a.Entering_Status__c + '');

                c.Type = checkNull(a.Type__c + '');

                StoreProductlineInfoList.add(c);

            }
            result.StoreProductlineInfoList = StoreProductlineInfoList;
            String sql1 = 'select count(id) totalNumber from Store_Product_Line__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreProductlineToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreProductlineToBigData';
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