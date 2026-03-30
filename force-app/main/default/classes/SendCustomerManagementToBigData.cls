/**********************************************************************
 * function:Customer Management
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendCustomerManagementToBigData')
global with sharing class SendCustomerManagementToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<CustomerManagementInfo> customerManagementInfoList;
    }

    public class CustomerManagementInfo {

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
        public String CustomerManagementNameCode;
        public String ManagementName;


    }

    @HttpPost
    global static SendCustomerManagementToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendCustomerManagementToBigData.AppInput appInput = new SendCustomerManagementToBigData.AppInput();
        
        SendCustomerManagementToBigData.AppOutPut result = new SendCustomerManagementToBigData.AppOutPut();
        
        try{
            appInput = (SendCustomerManagementToBigData.AppInput)JSON.deserialize(reqBody, SendCustomerManagementToBigData.AppInput.class);

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

            'Customer_Management_Name_Code__c,'+
            'Management_Name__c'+
            
            ' from Customer_Management__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Customer_Management__c> CustomerManagementList = (List<Customer_Management__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Customer_Management__c> CustomerManagementList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<CustomerManagementInfo> CustomerManagementInfoList = new List<CustomerManagementInfo>();

            for(Customer_Management__c a : CustomerManagementList){
                CustomerManagementInfo c = new CustomerManagementInfo();
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
                c.CustomerManagementNameCode = checkNull(a.Customer_Management_Name_Code__c + '');
                c.ManagementName = checkNull(a.Management_Name__c + '');
              
                CustomerManagementInfoList.add(c);

            }
            result.CustomerManagementInfoList = CustomerManagementInfoList;
            String sql1 = 'select count(id) totalNumber from Customer_Management__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerManagementToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerManagementToBigData';
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