@RestResource(urlMapping='/SendStoreAllToBigData')
global with sharing class SendStoreAllToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<StoreInfo> storeInfoList;
    }
    
    @HttpPost
    global static SendStoreAllToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendStoreAllToBigData.AppInput appInput = new SendStoreAllToBigData.AppInput();
        
        SendStoreAllToBigData.AppOutPut result = new SendStoreAllToBigData.AppOutPut();
        
        try{
            appInput = (SendStoreAllToBigData.AppInput)JSON.deserialize(reqBody, SendStoreAllToBigData.AppInput.class);

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

            
            String sql = 'select id,'+
            'CreatedDate,'+
            'LastModifiedDate,'+
            'Name,'+
            'Account_Name__c,'+
            'Account__c,'+
            'Address1__c,'+
            'Annual_Store_Sales__c,'+
            'Auto_Number__c,'+
            'Booth_Expense__c,'+
            'Booth_Size__c,'+
            'City__c,'+
            'District__c,'+
            'EN_Name__c,'+
            'Entity__c,'+
            'Exhibition_Format__c,'+
            'External_Key_ID__c,'+
            'Fax__c,'+
            'GiftGrid__c,'+
            'Grid_All__c,'+
            'Grid__c,'+
            'IsChange__c,'+
            'IsInMyRegion__c,'+
            'IsNew__c,'+
            'Is_Export__c,'+
            'Number_Of_Store_Staff__c,'+
            'Phone__c,'+
            'Postal__c,'+
            'Responsible_Person__c,'+
            'Sales_Region__c,'+
            'Shop_Center_Location__c,'+
            'Shop_Code_Text__c,'+
            'Shop_Code__c,'+
            'Shop_External_Key__c,'+
            'Shop_Level__c,'+
            'Store_Area__c,'+
            'Store_Development_Time__c,'+
            'Store_No_from_Account__c,'+
            'Store_Properties__c,'+
            'Entering_Status__c,'+
            'isLocationEmpty__c'+
            ' from Shop__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
   
            List<Shop__c> storeList = (List<Shop__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<StoreInfo> storeInfoList = new List<StoreInfo>();
            for(shop__c s : storeList){
                StoreInfo si = new StoreInfo();
                si.id = checkNull(s.id + '');
                si.CreatedDate = checkNull(s.CreatedDate + '');
                si.LastModifiedDate = checkNull(s.LastModifiedDate + '');
                si.Name = checkNull(s.Name + '');
                si.Account_Name = checkNull(s.Account_Name__c + '');
                si.Account = checkNull(s.Account__c + '');
                si.Address1 = checkNull(s.Address1__c + '');
                si.Annual_Store_Sales = checkNull(s.Annual_Store_Sales__c + '');
                si.Auto_Number = checkNull(s.Auto_Number__c + '');
                si.Booth_Expense = checkNull(s.Booth_Expense__c + '');
                si.Booth_Size = checkNull(s.Booth_Size__c + '');
                si.City = checkNull(s.City__c + '');
                si.District = checkNull(s.District__c + '');
                si.EN_Name = checkNull(s.EN_Name__c + '');
                si.Entity = checkNull(s.Entity__c + '');
                si.Exhibition_Format = checkNull(s.Exhibition_Format__c + '');
                si.External_Key_ID = checkNull(s.External_Key_ID__c + '');
                si.Fax = checkNull(s.Fax__c + '');
                si.GiftGrid = checkNull(s.GiftGrid__c + '');
                si.Grid_All = checkNull(s.Grid_All__c + '');
                si.Grid = checkNull(s.Grid__c + '');
                si.IsChange = checkNull(s.IsChange__c + '');
                si.IsInMyRegion = checkNull(s.IsInMyRegion__c + '');
                si.IsNew = checkNull(s.IsNew__c + '');
                si.Is_Export = checkNull(s.Is_Export__c + '');
                si.Number_Of_Store_Staff = checkNull(s.Number_Of_Store_Staff__c + '');
                si.Phone = checkNull(s.Phone__c + '');
                si.Postal = checkNull(s.Postal__c + '');
                si.Responsible_Person = checkNull(s.Responsible_Person__c + '');
                si.Sales_Region = checkNull(s.Sales_Region__c + '');
                si.Shop_Center_Location = checkNull(s.Shop_Center_Location__c + '');
                si.Shop_Code_Text = checkNull(s.Shop_Code_Text__c + '');
                si.Shop_Code = checkNull(s.Shop_Code__c + '');
                si.Shop_External_Key = checkNull(s.Shop_External_Key__c + '');
                si.Shop_Level = checkNull(s.Shop_Level__c + '');
                si.Store_Area = checkNull(s.Store_Area__c + '');
                si.Store_Development_Time = checkNull(s.Store_Development_Time__c + '');
                si.Store_No_from_Account = checkNull(s.Store_No_from_Account__c + '');
                si.Store_Properties = checkNull(s.Store_Properties__c + '');
                si.Whether_enter = checkNull(s.Entering_Status__c + '');
                si.isLocationEmpty = checkNull(s.isLocationEmpty__c + '');
                storeInfoList.add(si);
            }

            result.storeInfoList = storeInfoList;
            String sql1 = 'select count(id) totalNumber from Shop__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreAllToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreAllToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            return null; 
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

    public class StoreInfo {
        public String id;
        public String CreatedDate;
        public String LastModifiedDate;  
        public String Name; 
        public String Account_Name;
        public String Account;
        public String Address1;
        public String Annual_Store_Sales;
        public String Auto_Number;
        public String Booth_Expense;
        public String Booth_Size;
        public String City;
        public String District;
        public String EN_Name;
        public String Entity;
        public String Exhibition_Format;
        public String External_Key_ID;
        public String Fax;
        public String GiftGrid;
        public String Grid_All;
        public String Grid;
        public String IsChange;
        public String IsInMyRegion;
        public String IsNew;
        public String Is_Export;
        public String Number_Of_Store_Staff;
        public String Phone;
        public String Postal;
        public String Responsible_Person;
        public String Sales_Region;
        public String Shop_Center_Location;
        public String Shop_Code_Text;
        public String Shop_Code;
        public String Shop_External_Key;
        public String Shop_Level;
        public String Store_Area;
        public String Store_Development_Time;
        public String Store_No_from_Account;
        public String Store_Properties;
        public String Whether_enter;
        public String isLocationEmpty;

    }
}