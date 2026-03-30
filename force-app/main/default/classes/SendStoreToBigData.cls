/**********************************************************************
 * function:将Store推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-02-02
*************************************************************************/
@RestResource(urlMapping='/SendStoreToBigData')
global with sharing class SendStoreToBigData {  

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

    public class StoreInfo {
        public String Id;
        public String OwnerId;
        public String IsDeleted;
        public String Name;
        public String CurrencyIsoCode;
        public String CreatedDate;
        public String CreatedById;
        public String LastModifiedDate;
        public String LastModifiedById;
        public String SystemModstamp;
        public String LastViewedDate;
        public String LastReferencedDate;
        public String Account;
        public String Address1;
        public String City;
        public String ENName;
        public String ExternalKeyID;
        public String Fax;
        public String GridAll;
        public String Grid;
        public String IsChange;
        public String IsNew;
        public String Phone;
        public String Postal;
        public String ResponsiblePerson;
        public String ShopCenterLocationLatitudes;
        public String ShopCenterLocationLongitudes;
        public String ShopCenterLocation;
        public String ShopExternalKey;
        public String ShopLevel;
        public String StoreNofromAccount;
        public String isLocationEmpty;
        public String IsExport;
        public String AccountName;
        public String GiftGrid;
        public String SalesRegion;
        public String IsInMyRegion;
        public String Entity;
        public String AutoNumber;
        public String ShopCode;
        //public String FloorwalkerPosition;
        //public String Position;
        //public String FloorwalkerGroup;
        //public String Group1;
        public String District;
        public String AnnualStoreSales;
        public String StoreArea;
        public String BoothExpense;
        public String ExhibitionFormat;
        public String NumberOfStoreStaff;
        public String StoreDevelopmentTime;
        public String StoreProperties;
        public String BoothSize;
        //public String InspectType;
        //public String Comments;
        public String CoverImgContentBodyId;
        public String CoverImgVersionId1;
        public String CoverImgVersionId2;
        public String CoverImgVersionId;
        public String CoverImg1;
        public String CoverImg2;
        public String CoverImg;
        public String ShopCodeText;
        //public String Whetherenter;
        //public String shopfrom;
        //public String BackupFloorwalkerJP;
        public String HisenseTVNum;
        public String ToshibaTvNum;
        public String HANum;
        public String MIXNum;
        public String EnteringStatus;
        public String Country;
        public String ChannelName;
        // public String ChannelCode;
        // public String ProductLine;
        // public String TimeOfEntry;
        // public String CloseDate;
        public String ChannelItem;

        public String State_Province;
        public String Type;
        public String Flagship_store;
        public String Have_Promoter;
        public String Booth_or_not;
        public String Booth_Style;

        // wfc 2025-12-25 新增
        public String ShortName;
        public String AccountCode;
        public String IsQualityShop;
        public String ShopBusinessStatus;
        public String StoreLevelHQ;
        public String MerchantShopName;
        public String ResponsiblePersonId;
        
    }

    @HttpPost
    global static SendStoreToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendStoreToBigData.AppInput appInput = new SendStoreToBigData.AppInput();
        
        SendStoreToBigData.AppOutPut result = new SendStoreToBigData.AppOutPut();
        
        try{
            appInput = (SendStoreToBigData.AppInput)JSON.deserialize(reqBody, SendStoreToBigData.AppInput.class);

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
            'Type__c,'+
            'Flagship_store__c,'+
            'Have_Promoter__c,'+
            'Booth_or_not__c,'+
            '(select Booth_Style__c from Booth_Styles__r)'+
            'Id,'+
            'OwnerId,'+
            'IsDeleted,'+
            'Name,'+
            'CurrencyIsoCode,'+
            'CreatedDate,'+
            'CreatedById,'+
            'LastModifiedDate,'+
            'LastModifiedById,'+
            'SystemModstamp,'+
            'LastViewedDate,'+
            'LastReferencedDate,'+
            'Account__c,'+
            'Address1__c,'+
            'City__c,'+
            'EN_Name__c,'+
            'External_Key_ID__c,'+
            'Fax__c,'+
            'Grid_All__c,'+
            'Grid__c,'+
            'IsChange__c,'+
            'IsNew__c,'+
            'Phone__c,'+
            'Postal__c,'+
            'Responsible_Person__c,'+
            'Shop_Center_Location__Latitude__s,'+
            'Shop_Center_Location__Longitude__s,'+
            'Shop_Center_Location__c,'+
            'Shop_External_Key__c,'+
            'Shop_Level__c,'+
            'Store_No_from_Account__c,'+
            'isLocationEmpty__c,'+
            'Is_Export__c,'+
            'Account_Name__c,'+
            'GiftGrid__c,'+
            'Sales_Region__c,'+
            'IsInMyRegion__c,'+
            'Entity__c,'+
            'Auto_Number__c,'+
            'Shop_Code__c,'+
//'Floorwalker_Position__c,'+
            //'Position__c,'+
            //'Floorwalker_Group__c,'+
            //'Group__c,'+
            'District__c,'+
            'Annual_Store_Sales__c,'+
            'Store_Area__c,'+
            'Booth_Expense__c,'+
            'Exhibition_Format__c,'+
            'Number_Of_Store_Staff__c,'+
            'Store_Development_Time__c,'+
            'Store_Properties__c,'+
            'Booth_Size__c,'+
//'Inspect_Type__c,'+
            //'Comments__c,'+
            'CoverImgContentBodyId__c,'+
            'CoverImgVersionId1__c,'+
            'CoverImgVersionId2__c,'+
            'CoverImgVersionId__c,'+
            'CoverImg1__c,'+
            'CoverImg2__c,'+
            'CoverImg__c,'+
            'Shop_Code_Text__c,'+
            //'Whether_enter__c,'+
            //'shop_from__c,'+
            //'Backup_FloorwalkerJP__c,'+
            'Hisense_TV_Num__c,'+
            'Toshiba_Tv_Num__c,'+
            'HA_Num__c,'+
            'MIX_Num__c,'+
            'Entering_Status__c,'+
            'Country__c,'+
            'State_Province__c,'+
            'Channel_Name__c,'+
            //'Channel_Code__c,'+
            //'Product_Line__c,'+
            //'Close_Date__c,'+
            'Channel_Item__c,'+
            //'Time_Of_Entry__c'+
            'Short_Name__c,'+
            'Account__r.Name,'+
            'Account__r.SAP_Customer_Code__c,'+
            'Merchant_Shop_Name__c,'+
            'Customer_Store_Type__c,'+
            'Shop_Business_Status__c,'+
            'Store_Level_HQ__c,'+
            'Responsible_Person__r.Name'+

            ' from Shop__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            //List<Shop__c> storeList = (List<Shop__c>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);

            List<Shop__c> storeList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));

            List<StoreInfo> storeInfoList = new List<StoreInfo>();

            for(Shop__c a : storeList){
                StoreInfo c = new StoreInfo();
                c.Id = checkNull(a.Id + '');
                c.OwnerId = checkNull(a.OwnerId + '');
                c.IsDeleted = checkNull(a.IsDeleted + '');
                c.Name = checkNull(a.Name + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.CreatedById = checkNull(a.CreatedById + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');
                c.LastModifiedById = checkNull(a.LastModifiedById + '');
                c.SystemModstamp = checkNull(a.SystemModstamp + '');
                c.LastViewedDate = checkNull(a.LastViewedDate + '');
                c.LastReferencedDate = checkNull(a.LastReferencedDate + '');
                c.Account = checkNull(a.Account__c + '');
                c.Address1 = checkNull(a.Address1__c + '');
                c.City = checkNull(a.City__c + '');
                c.ENName = checkNull(a.EN_Name__c + '');
                c.ExternalKeyID = checkNull(a.External_Key_ID__c + '');
                c.Fax = checkNull(a.Fax__c + '');
                c.GridAll = checkNull(a.Grid_All__c + '');
                c.Grid = checkNull(a.Grid__c + '');
                c.IsChange = checkNull(a.IsChange__c + '');
                c.IsNew = checkNull(a.IsNew__c + '');
                c.Phone = checkNull(a.Phone__c + '');
                c.Postal = checkNull(a.Postal__c + '');
                // c.ResponsiblePerson = checkNull(a.Responsible_Person__c + '');
                c.ShopCenterLocationLatitudes = checkNull(a.Shop_Center_Location__Latitude__s + '');
                c.ShopCenterLocationLongitudes = checkNull(a.Shop_Center_Location__Longitude__s + '');
                c.ShopCenterLocation = checkNull(a.Shop_Center_Location__c + '');
                c.ShopExternalKey = checkNull(a.Shop_External_Key__c + '');
                c.ShopLevel = checkNull(a.Shop_Level__c + '');
                c.StoreNofromAccount = checkNull(a.Store_No_from_Account__c + '');
                c.isLocationEmpty = checkNull(a.isLocationEmpty__c + '');
                c.IsExport = checkNull(a.Is_Export__c + '');
                // c.AccountName = checkNull(a.Account_Name__c + '');
                c.GiftGrid = checkNull(a.GiftGrid__c + '');
                c.SalesRegion = checkNull(a.Sales_Region__c + '');
                c.IsInMyRegion = checkNull(a.IsInMyRegion__c + '');
                c.Entity = checkNull(a.Entity__c + '');
                c.AutoNumber = checkNull(a.Auto_Number__c + '');
                c.ShopCode = checkNull(a.Shop_Code__c + '');
                //.FloorwalkerPosition = checkNull(a.Floorwalker_Position__c + '');
                //c.Position = checkNull(a.Position__c + '');
                //c.FloorwalkerGroup = checkNull(a.Floorwalker_Group__c + '');
                //c.Group1 = checkNull(a.Group__c + '');
                c.District = checkNull(a.District__c + '');
                c.AnnualStoreSales = checkNull(a.Annual_Store_Sales__c + '');
                c.StoreArea = checkNull(a.Store_Area__c + '');
                c.BoothExpense = checkNull(a.Booth_Expense__c + '');
                c.ExhibitionFormat = checkNull(a.Exhibition_Format__c + '');
                c.NumberOfStoreStaff = checkNull(a.Number_Of_Store_Staff__c + '');
                c.StoreDevelopmentTime = checkNull(a.Store_Development_Time__c + '');
                c.StoreProperties = checkNull(a.Store_Properties__c + '');
                c.BoothSize = checkNull(a.Booth_Size__c + '');
                //c.InspectType = checkNull(a.Inspect_Type__c + '');
                //c.Comments = checkNull(a.Comments__c + '');
                c.CoverImgContentBodyId = checkNull(a.CoverImgContentBodyId__c + '');
                c.CoverImgVersionId1 = checkNull(a.CoverImgVersionId1__c + '');
                c.CoverImgVersionId2 = checkNull(a.CoverImgVersionId2__c + '');
                c.CoverImgVersionId = checkNull(a.CoverImgVersionId__c + '');
                c.CoverImg1 = checkNull(a.CoverImg1__c + '');
                c.CoverImg2 = checkNull(a.CoverImg2__c + '');
                c.CoverImg = checkNull(a.CoverImg__c + '');
                c.ShopCodeText = checkNull(a.Shop_Code_Text__c + '');
                //c.Whetherenter = checkNull(a.Whether_enter__c + '');
                //c.shopfrom = checkNull(a.shop_from__c + '');
                //c.BackupFloorwalkerJP = checkNull(a.Backup_FloorwalkerJP__c + '');
                c.HisenseTVNum = checkNull(a.Hisense_TV_Num__c + '');
                c.ToshibaTvNum = checkNull(a.Toshiba_Tv_Num__c + '');
                c.HANum = checkNull(a.HA_Num__c + '');
                c.MIXNum = checkNull(a.MIX_Num__c + '');
                c.EnteringStatus = checkNull(a.Entering_Status__c + '');
                c.Country = checkNull(a.Country__c + '');
                c.ChannelName = checkNull(a.Channel_Name__c + '');
                //c.ChannelCode = checkNull(a.Channel_Code__c + '');
                //c.ProductLine = checkNull(a.Product_Line__c + '');
                //c.TimeOfEntry = checkNull(a.Time_Of_Entry__c + '');
                //c.CloseDate = checkNull(a.Close_Date__c + '');
                c.ChannelItem = checkNull(a.Channel_Item__c + '');

                c.State_Province = checkNull(a.State_Province__c + '');
                c.Type = checkNull(a.Type__c + '');
                c.Flagship_store = checkNull(a.Flagship_store__c + '');
                c.Have_Promoter = checkNull(a.Have_Promoter__c + '');
                c.Booth_or_not = checkNull(a.Booth_or_not__c + '');

                if(a.Booth_Styles__r != null && a.Booth_Styles__r.size() > 0 ){
                    c.Booth_Style = '';
                    for(Booth_Style__c bs : a.Booth_Styles__r){
                        c.Booth_Style += bs.Booth_Style__c + ';';
                    }
                    c.Booth_Style = c.Booth_Style.removeEnd(';');
                }else{
                    c.Booth_Style = '';
                }

                c.ShortName = checkNull(a.Short_Name__c + '');
                c.MerchantShopName = checkNull(a.Merchant_Shop_Name__c + '');
                c.AccountName = checkNull(a.Account__r.Name + '');
                c.AccountCode = checkNull(a.Account__r.SAP_Customer_Code__c + '');
                c.IsQualityShop = checkNull(a.Customer_Store_Type__c + '');
                c.ShopBusinessStatus = checkNull(a.Shop_Business_Status__c + '');
                c.StoreLevelHQ = checkNull(a.Store_Level_HQ__c + '');
                c.ResponsiblePerson = checkNull(a.Responsible_Person__r.Name + '');
                c.ResponsiblePersonId = checkNull(a.Responsible_Person__c + '');

                storeInfoList.add(c);
            }
            result.storeInfoList = storeInfoList;
            String sql1 = 'select count(id) totalNumber from Shop__c where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendStoreToBigData';
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