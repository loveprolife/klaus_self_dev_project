/**********************************************************************
 * function:将看板指标数据推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-06
*************************************************************************/
@RestResource(urlMapping='/SendKanbanIndicatorToBigData')
global with sharing class SendKanbanIndicatorToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
    }
    global class AppOutPut{
        public Integer customerTotalNumber;
        public Integer storeTotalNumber;
        public Integer promotersTotalNumber;
        public Integer dailyInspectionReportTotalNumber;
        public Integer ticketTotalNumber;
        List<CustomerInfo> customerInfoList;
        List<StoreInfo> storeInfoList;
        List<ResponsiblePersonInfo> promotersInfoList;
        List<DailyInspectionReportInfo> dailyInspectionReportInfoList;
        List<TicketInfo> ticketInfoList;
    }
    
    @HttpPost
    global static SendKanbanIndicatorToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendKanbanIndicatorToBigData.AppInput appInput = new SendKanbanIndicatorToBigData.AppInput();
        
        SendKanbanIndicatorToBigData.AppOutPut result = new SendKanbanIndicatorToBigData.AppOutPut();
        
        try{
            appInput = (SendKanbanIndicatorToBigData.AppInput)JSON.deserialize(reqBody, SendKanbanIndicatorToBigData.AppInput.class);

            if(String.isBlank(appInput.startTime) || String.isBlank(appInput.endTime)){
                return result;
            }

            Datetime startTime = Datetime.valueOf(appInput.startTime);
            Datetime endTime = Datetime.valueOf(appInput.endTime);
            
            //渠道合计(市场所有渠道总和)
            List<Account> customerList = [select id,
                                            CreatedDate,
                                            LastModifiedDate, 
                                            SAP_Code_Generation_Time__c,  
                                            AccountSource,
                                            Active_Flag__c,
                                            Actual_Sales_Income_Ratio_N_1_Year__c,
                                            Address_Text__c,
                                            Address__c,
                                            AnnualRevenue,
                                            Approval_Status__c,
                                            Attribute2__c,
                                            Automatic_updates__c,
                                            Avaliable_Credit_Limit_Currency__c,
                                            Avaliable_Credit_Limit_ZAR__c,
                                            Avaliable_Credit_Limit__c,
                                            Basic_Approval_Status__c,
                                            BillingAddress,
                                            Brands_Work_with_Hisense__c,
                                            Buyer_English_Name__c,
                                            ChannelProgramLevelName,
                                            ChannelProgramName,
                                            Channel_Level__c,
                                            Check_Digit__c,
                                            City__c,
                                            Contract_Rebate_Types__c,
                                            Cooperated_Store_Quantity__c,
                                            Corporate_Representative__c,
                                            Coverage__c,
                                            Credit_Account_Code__c,
                                            Credit_Account_Name__c,
                                            Credit_Approval_Status__c,
                                            Credit_Currency__c,
                                            CurrencyIsoCode,
                                            Customer_Category__c,
                                            Customer_Classification__c,
                                            Customer_Group2__c,
                                            Customer_Group__c,
                                            Customer_Management_Name__c,
                                            Customer_Management_Name__r.Customer_Management_Name_Code__c, 
                                            Customer_Management_Name__r.name,
                                            Customer_Name_Local_Language__c,
                                            Customer_No__c,
                                            Customer_Record_Type_Name__c,
                                            Customer_SF_Code__c,
                                            Customer_Sales_For_3_Consecutive_Years_1__c,
                                            Customer_Sales_For_3_Consecutive_Years_2__c,
                                            Customer_Sales_For_3_Consecutive_Years_3__c,
                                            Customer_Sales_Scale__c,
                                            Customer_Short_Name__c,
                                            Customer_Status__c,
                                            Customer_dba__c,
                                            Customer_type__c,
                                            Delivery_Matters_Needing_Attention__c,
                                            Delivery_Priority__c,
                                            Delivery_Way__c,
                                            Deliverying_Plant__c,
                                            Description,
                                            Differential_Request_Method__c,
                                            Distribution_Channel__c,
                                            E_commerce_Customer_Label__c,
                                            Eliminate_Approval_Status__c,
                                            Email__c,
                                            ExcodeLen__c,
                                            ExternalIDFormula__c,
                                            External_Key__c,
                                            Fax,
                                            Goods_Form__c,
                                            Gross_Profit__c,
                                            Guarantor_Country_Code__c,
                                            Have_Parent_Customer__c,
                                            Headquarters_Approval_Status__c,
                                            Hisense_ASM__c,
                                            Hisense_Actual_Sales_Income_Ratio_N_Year__c,
                                            Hisense_Entity__c,
                                            Hisense_RSM__c,
                                            //Industry,
                                            Industry__c,
                                            IsChange__c,
                                            //IsCustomerPortal,
                                            IsInMyRegion__c,
                                            IsNew__c,
                                            IsPartner,
                                            IsUsedForBackground__c,
                                            Japan_Unlock_Tag__c,
                                            Jigsaw,
                                            KDGRP__c,
                                            Location_No_1__c,
                                            Location_No_2__c,
                                            Main_Business_Scope__c,
                                            Management_Area__c,
                                            Name,
                                            Natural_Person_or_Not__c,
                                            NumberOfEmployees,
                                            //OperatingHoursId,
                                            Order_Way__c,
                                            Other_Delivery_Way__c,
                                            Other_Order_Way__c,
                                            Other_Pay_Day__c,
                                            Other_Pay_Way__c,
                                            Other_Payment_Details__c,
                                            Other_Single_Mode__c,
                                            Other_Trade_Payment_Days__c,
                                            Overdue_Amount__c,
                                            Overdue_Currency__c,
                                            Overdue_Y_N__c,
                                            OwnerId,
                                            Ownership,
                                            ParentId,
                                            Parent_Customer__c,
                                            Pay_Day__c,
                                            Pay_Object__c,
                                            Pay_Way__c,
                                            Payback_Overdue_Number__c,
                                            Payback_Y_N__c,
                                            Payer__c,
                                            Payment_Condition__c,
                                            Payment_Details__c,
                                            Payment_Term__c,
                                            Payment_methods__c,
                                            Phone,
                                            Postal_Code__c,
                                            Price_Book_Region__c,
                                            Price_List__c,
                                            Product_Line__c,
                                            Province_State__c,
                                            RR_China_Credit__c,
                                            Rank__c,
                                            Rating,
                                            Receiver__c,
                                            Reconciliation_Customer__c,
                                            Region__c,
                                            Related_staff_associates_with_Buyer_Y_N__c,
                                            Related_to_POD__c,
                                            Restore_Approval_Status__c,
                                            SAP_Account__c,
                                            SAP_Credit_Limit_Currency__c,
                                            SAP_Credit_Limit_ZAR__c,
                                            SAP_Credit_Limit__c,
                                            SAP_Customer_Code__c,
                                            SA_Credit_Send_Email_Flag__c,
                                            SA_Financial_Email_Date__c,
                                            Sales_Group__c,
                                            Sales_Office__c,
                                            Sales_Region__c,
                                            ShippingAddress,
                                            Shipping_Conditions__c,
                                            Sic,
                                            SicDesc,
                                            Single_Mode__c,
                                            Site,
                                            South_Africa_Flag__c,
                                            Status_Changing_Time_From_SAP__c,
                                            Stor_Location__c,
                                            SumOfPL__c,
                                            SumOfSales__c,
                                            Tax_Classification__c,
                                            Tax_Number1__c,
                                            Tax_Number2__c,
                                            TickerSymbol,
                                            Total_Store_Quantity__c,
                                            Trade_Payment_Days__c,
                                            Type,
                                            Uploding_Usage_Key__c,
                                            Used_Credit_Limit_Currency__c,
                                            Used_Credit_Limit_ZAR__c,
                                            Used_Credit_Limit__c,
                                            VAT_Registration_Number__c,
                                            VAT_Tax_type__c,
                                            Website,
                                            channel__c,
                                            isGoFinApprove__c
                                            from Account where LastModifiedDate >= :startTime and LastModifiedDate <= :endTime];

            List<CustomerInfo> customerInfoList = new List<CustomerInfo>();
            for(Account a : customerList){
                CustomerInfo c = new CustomerInfo();
                c.id = checkNull(a.id + '');
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');  
                c.SAPCodeGenerationTime = checkNull(a.SAP_Code_Generation_Time__c + '');
                c.AccountNumber = '';
                c.AccountSource = checkNull(a.AccountSource + '');
                c.Active_Flag = checkNull(a.Active_Flag__c + '');
                c.Actual_Sales_Income_Ratio_N_1_Year = checkNull(a.Actual_Sales_Income_Ratio_N_1_Year__c + '');
                c.Address_Text = checkNull(a.Address_Text__c + '');
                c.Address = checkNull(a.Address__c + '');
                c.AnnualRevenue = checkNull(a.AnnualRevenue + '');
                c.Approval_Status = checkNull(a.Approval_Status__c + '');
                c.Attribute2 = checkNull(a.Attribute2__c + '');
                c.Automatic_updates = checkNull(a.Automatic_updates__c + '');
                c.Avaliable_Credit_Limit_Currency = checkNull(a.Avaliable_Credit_Limit_Currency__c + '');
                c.Avaliable_Credit_Limit_ZAR = checkNull(a.Avaliable_Credit_Limit_ZAR__c + '');
                c.Avaliable_Credit_Limit = checkNull(a.Avaliable_Credit_Limit__c + '');
                c.Basic_Approval_Status = checkNull(a.Basic_Approval_Status__c + '');
                c.BillingAddress = checkNull(a.BillingAddress + '');
                c.Brands_Work_with_Hisense = checkNull(a.Brands_Work_with_Hisense__c + '');
                c.Buyer_English_Name = checkNull(a.Buyer_English_Name__c + '');
                c.ChannelProgramLevelName = checkNull(a.ChannelProgramLevelName + '');
                c.ChannelProgramName = checkNull(a.ChannelProgramName + '');
                c.Channel_Level = checkNull(a.Channel_Level__c + '');
                c.Check_Digit = checkNull(a.Check_Digit__c + '');
                c.City = checkNull(a.City__c + '');
                c.Contract_Rebate_Types = checkNull(a.Contract_Rebate_Types__c + '');
                c.Cooperated_Store_Quantity = checkNull(a.Cooperated_Store_Quantity__c + '');
                c.Corporate_Representative = checkNull(a.Corporate_Representative__c + '');
                c.Coverage = checkNull(a.Coverage__c + '');
                c.Credit_Account_Code = checkNull(a.Credit_Account_Code__c + '');
                c.Credit_Account_Name = checkNull(a.Credit_Account_Name__c + '');
                c.Credit_Approval_Status = checkNull(a.Credit_Approval_Status__c + '');
                c.Credit_Currency = checkNull(a.Credit_Currency__c + '');
                c.CurrencyIsoCode = checkNull(a.CurrencyIsoCode + '');
                c.Customer_Category = checkNull(a.Customer_Category__c + '');
                c.Customer_Classification = checkNull(a.Customer_Classification__c + '');
                c.Customer_Group2 = checkNull(a.Customer_Group2__c + '');
                c.Customer_Group = checkNull(a.Customer_Group__c + '');
                c.Customer_Management_Id = checkNull(a.Customer_Management_Name__c + '');
                c.Customer_Management_Code = checkNull(a.Customer_Management_Name__r.Customer_Management_Name_Code__c + '');
                c.Customer_Management_Name = checkNull(a.Customer_Management_Name__r.name + '');
                c.Customer_Name_Local_Language = checkNull(a.Customer_Name_Local_Language__c + '');
                c.Customer_No = checkNull(a.Customer_No__c + '');
                c.Customer_Record_Type_Name = checkNull(a.Customer_Record_Type_Name__c + '');
                c.Customer_SF_Code = checkNull(a.Customer_SF_Code__c + '');
                c.Customer_Sales_For_3_Consecutive_Years_1 = checkNull(a.Customer_Sales_For_3_Consecutive_Years_1__c + '');
                c.Customer_Sales_For_3_Consecutive_Years_2 = checkNull(a.Customer_Sales_For_3_Consecutive_Years_2__c + '');
                c.Customer_Sales_For_3_Consecutive_Years_3 = checkNull(a.Customer_Sales_For_3_Consecutive_Years_3__c + '');
                c.Customer_Sales_Scale = checkNull(a.Customer_Sales_Scale__c + '');
                c.Customer_Short_Name = checkNull(a.Customer_Short_Name__c + '');
                c.Customer_Status = checkNull(a.Customer_Status__c + '');
                c.Customer_dba = checkNull(a.Customer_dba__c + '');
                c.Customer_type = checkNull(a.Customer_type__c + '');
                c.Delivery_Matters_Needing_Attention = checkNull(a.Delivery_Matters_Needing_Attention__c + '');
                c.Delivery_Priority = checkNull(a.Delivery_Priority__c + '');
                c.Delivery_Way = checkNull(a.Delivery_Way__c + '');
                c.Deliverying_Plant = checkNull(a.Deliverying_Plant__c + '');
                c.Description = checkNull(a.Description + '');
                c.Differential_Request_Method = checkNull(a.Differential_Request_Method__c + '');
                c.Distribution_Channel = checkNull(a.Distribution_Channel__c + '');
                c.E_commerce_Customer_Label = checkNull(a.E_commerce_Customer_Label__c + '');
                c.Eliminate_Approval_Status = checkNull(a.Eliminate_Approval_Status__c + '');
                c.Email = checkNull(a.Email__c + '');
                c.ExcodeLen = checkNull(a.ExcodeLen__c + '');
                c.ExternalIDFormula = checkNull(a.ExternalIDFormula__c + '');
                c.External_Key = checkNull(a.External_Key__c + '');
                c.Fax = checkNull(a.Fax + '');
                c.Goods_Form = checkNull(a.Goods_Form__c + '');
                c.Gross_Profit = checkNull(a.Gross_Profit__c + '');
                c.Guarantor_Country_Code = checkNull(a.Guarantor_Country_Code__c + '');
                c.Have_Parent_Customer = checkNull(a.Have_Parent_Customer__c + '');
                c.Headquarters_Approval_Status = checkNull(a.Headquarters_Approval_Status__c + '');
                c.Hisense_ASM = checkNull(a.Hisense_ASM__c + '');
                c.Hisense_Actual_Sales_Income_Ratio_N_Year = checkNull(a.Hisense_Actual_Sales_Income_Ratio_N_Year__c + '');
                c.Hisense_Entity = checkNull(a.Hisense_Entity__c + '');
                c.Hisense_RSM = checkNull(a.Hisense_RSM__c + '');
                //c.Industry = checkNull(a.Industry + '');
                c.Industry = checkNull(a.Industry__c + '');
                c.IsChange = checkNull(a.IsChange__c + '');
                //c.IsCustomerPortal = checkNull(a.IsCustomerPortal + '');
                c.IsInMyRegion = checkNull(a.IsInMyRegion__c + '');
                c.IsNew = checkNull(a.IsNew__c + '');
                c.IsPartner = checkNull(a.IsPartner + '');
                c.IsUsedForBackground = checkNull(a.IsUsedForBackground__c + '');
                c.Japan_Unlock_Tag = checkNull(a.Japan_Unlock_Tag__c + '');
                c.Jigsaw = checkNull(a.Jigsaw + '');
                c.KDGRP = checkNull(a.KDGRP__c + '');
                c.Location_No_1 = checkNull(a.Location_No_1__c + '');
                c.Location_No_2 = checkNull(a.Location_No_2__c + '');
                c.Main_Business_Scope = checkNull(a.Main_Business_Scope__c + '');
                c.Management_Area = checkNull(a.Management_Area__c + '');
                c.Name = checkNull(a.Name + '');
                c.Natural_Person_or_Not = checkNull(a.Natural_Person_or_Not__c + '');
                c.NumberOfEmployees = checkNull(a.NumberOfEmployees + '');
                //c.OperatingHoursId = checkNull(a.OperatingHoursId + '');
                c.Order_Way = checkNull(a.Order_Way__c + '');
                c.Other_Delivery_Way = checkNull(a.Other_Delivery_Way__c + '');
                c.Other_Order_Way = checkNull(a.Other_Order_Way__c + '');
                c.Other_Pay_Day = checkNull(a.Other_Pay_Day__c + '');
                c.Other_Pay_Way = checkNull(a.Other_Pay_Way__c + '');
                c.Other_Payment_Details = checkNull(a.Other_Payment_Details__c + '');
                c.Other_Single_Mode = checkNull(a.Other_Single_Mode__c + '');
                c.Other_Trade_Payment_Days = checkNull(a.Other_Trade_Payment_Days__c + '');
                c.Overdue_Amount = checkNull(a.Overdue_Amount__c + '');
                c.Overdue_Currency = checkNull(a.Overdue_Currency__c + '');
                c.Overdue_Y_N = checkNull(a.Overdue_Y_N__c + '');
                c.OwnerId = checkNull(a.OwnerId + '');
                c.Ownership = checkNull(a.Ownership + '');
                c.ParentId = checkNull(a.ParentId + '');
                c.Parent_Customer = checkNull(a.Parent_Customer__c + '');
                c.Pay_Day = checkNull(a.Pay_Day__c + '');
                c.Pay_Object = checkNull(a.Pay_Object__c + '');
                c.Pay_Way = checkNull(a.Pay_Way__c + '');
                c.Payback_Overdue_Number = checkNull(a.Payback_Overdue_Number__c + '');
                c.Payback_Y_N = checkNull(a.Payback_Y_N__c + '');
                c.Payer = checkNull(a.Payer__c + '');
                c.Payment_Condition = checkNull(a.Payment_Condition__c + '');
                c.Payment_Details = checkNull(a.Payment_Details__c + '');
                c.Payment_Term = checkNull(a.Payment_Term__c + '');
                c.Payment_methods = checkNull(a.Payment_methods__c + '');
                c.Phone = checkNull(a.Phone + '');
                c.Postal_Code = checkNull(a.Postal_Code__c + '');
                c.Price_Book_Region = checkNull(a.Price_Book_Region__c + '');
                c.Price_List = checkNull(a.Price_List__c + '');
                c.Product_Line = checkNull(a.Product_Line__c + '');
                c.Province_State = checkNull(a.Province_State__c + '');
                c.RR_China_Credit = checkNull(a.RR_China_Credit__c + '');
                c.Rank = checkNull(a.Rank__c + '');
                c.Rating = checkNull(a.Rating + '');
                c.Receiver = checkNull(a.Receiver__c + '');
                c.Reconciliation_Customer = checkNull(a.Reconciliation_Customer__c + '');
                c.Region = checkNull(a.Region__c + '');
                c.Related_staff_associates_with_Buyer_Y_N = checkNull(a.Related_staff_associates_with_Buyer_Y_N__c + '');
                c.Related_to_POD = checkNull(a.Related_to_POD__c + '');
                c.Restore_Approval_Status = checkNull(a.Restore_Approval_Status__c + '');
                c.SAP_Account = checkNull(a.SAP_Account__c + '');
                c.SAP_Credit_Limit_Currency = checkNull(a.SAP_Credit_Limit_Currency__c + '');
                c.SAP_Credit_Limit_ZAR = checkNull(a.SAP_Credit_Limit_ZAR__c + '');
                c.SAP_Credit_Limit = checkNull(a.SAP_Credit_Limit__c + '');
                c.SAP_Customer_Code = checkNull(a.SAP_Customer_Code__c + '');
                c.SA_Credit_Send_Email_Flag = checkNull(a.SA_Credit_Send_Email_Flag__c + '');
                c.SA_Financial_Email_Date = checkNull(a.SA_Financial_Email_Date__c + '');
                c.Sales_Group = checkNull(a.Sales_Group__c + '');
                c.Sales_Office = checkNull(a.Sales_Office__c + '');
                c.Sales_Region = checkNull(a.Sales_Region__c + '');
                c.ShippingAddress = checkNull(a.ShippingAddress + '');
                c.Shipping_Conditions = checkNull(a.Shipping_Conditions__c + '');
                c.Sic = checkNull(a.Sic + '');
                c.SicDesc = checkNull(a.SicDesc + '');
                c.Single_Mode = checkNull(a.Single_Mode__c + '');
                c.Site = checkNull(a.Site + '');
                c.South_Africa_Flag = checkNull(a.South_Africa_Flag__c + '');
                c.Status_Changing_Time_From_SAP = checkNull(a.Status_Changing_Time_From_SAP__c + '');
                c.Stor_Location = checkNull(a.Stor_Location__c + '');
                c.SumOfPL = checkNull(a.SumOfPL__c + '');
                c.SumOfSales = checkNull(a.SumOfSales__c + '');
                c.Tax_Classification = checkNull(a.Tax_Classification__c + '');
                c.Tax_Number1 = checkNull(a.Tax_Number1__c + '');
                c.Tax_Number2 = checkNull(a.Tax_Number2__c + '');
                c.TickerSymbol = checkNull(a.TickerSymbol + '');
                c.Tier = '';
                c.Total_Store_Quantity = checkNull(a.Total_Store_Quantity__c + '');
                c.Trade_Payment_Days = checkNull(a.Trade_Payment_Days__c + '');
                c.Type = checkNull(a.Type + '');
                c.Uploding_Usage_Key = checkNull(a.Uploding_Usage_Key__c + '');
                c.Used_Credit_Limit_Currency = checkNull(a.Used_Credit_Limit_Currency__c + '');
                c.Used_Credit_Limit_ZAR = checkNull(a.Used_Credit_Limit_ZAR__c + '');
                c.Used_Credit_Limit = checkNull(a.Used_Credit_Limit__c + '');
                c.VAT_Registration_Number = checkNull(a.VAT_Registration_Number__c + '');
                c.VAT_Tax_type = checkNull(a.VAT_Tax_type__c + '');
                c.Website = checkNull(a.Website + '');
                c.channel = checkNull(a.channel__c + '');
                c.isGoFinApprove = checkNull(a.isGoFinApprove__c + '');

                customerInfoList.add(c);
            }
            result.customerInfoList = customerInfoList;
            result.customerTotalNumber = customerInfoList.size();

            //门店合计(市场所有渠道总和  (包含未进驻渠道门店))   Whether_enter__c：是否入驻
            List<shop__c> storeList = [select id,
                                        CreatedDate,
                                        LastModifiedDate, 
                                        Name,
                                        Account_Name__c,
                                        Account__c,
                                        Address1__c,
                                        Annual_Store_Sales__c,
                                        Auto_Number__c,
                                        Booth_Expense__c,
                                        Booth_Size__c,
                                        City__c,
                                        District__c,
                                        EN_Name__c,
                                        Entity__c,
                                        Exhibition_Format__c,
                                        External_Key_ID__c,
                                        Fax__c,
                                        GiftGrid__c,
                                        Grid_All__c,
                                        Grid__c,
                                        IsChange__c,
                                        IsInMyRegion__c,
                                        IsNew__c,
                                        Is_Export__c,
                                        Number_Of_Store_Staff__c,
                                        Phone__c,
                                        Postal__c,
                                        Responsible_Person__c,
                                        Sales_Region__c,
                                        Shop_Center_Location__c,
                                        Shop_Code_Text__c,
                                        Shop_Code__c,
                                        Shop_External_Key__c,
                                        Shop_Level__c,
                                        Store_Area__c,
                                        Store_Development_Time__c,
                                        Store_No_from_Account__c,
                                        Store_Properties__c,
                                        Entering_Status__c,
                                        isLocationEmpty__c
                                        from Shop__c where LastModifiedDate >= :startTime and LastModifiedDate <= :endTime];
         
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
            result.storeTotalNumber = storeInfoList.size();

            //促销员数量
            List<Responsible_Person__c> responsiblePersonList = [select id, 
                                                                    Account_Name__c,
                                                                    External_Key_ID__c,
                                                                    Is_Export__c,
                                                                    Principal_Text__c,
                                                                    Principal__c,
                                                                    Promoter_Attendance_Rule__c,
                                                                    RecordType__c,
                                                                    SAPCreateTime__c,
                                                                    SAPCreate__c,
                                                                    SAPExternal__c,
                                                                    SAPUserName__c,
                                                                    Shop_Id__c,
                                                                    Shop_Name_Text__c,
                                                                    Shop_Name__c,
                                                                    Store_Grid__c,
                                                                    UserEmail__c
                                                                    FROM Responsible_Person__c where LastModifiedDate >= :startTime and LastModifiedDate <= :endTime and Principal__r.IsActive = true];
            List<UserLogin> UserLoginList = [select UserId, IsFrozen from UserLogin];
            Map<String, Boolean> UserLoginMap = new Map<String, Boolean>();
            for(UserLogin u : UserLoginList){
                UserLoginMap.put(u.UserId, u.IsFrozen);
            }

            List<ResponsiblePersonInfo> responsiblePersonInfoList = new List<ResponsiblePersonInfo>();
            for(Responsible_Person__c r : responsiblePersonList){
                ResponsiblePersonInfo ri = new ResponsiblePersonInfo();

                if(UserLoginMap.get(r.Principal__c)){
                    continue;
                }
                ri.id = checkNull(r.id + '');
                ri.Account_Name = checkNull(r.Account_Name__c + '');
                ri.External_Key_ID = checkNull(r.External_Key_ID__c + '');
                ri.Is_Export = checkNull(r.Is_Export__c + '');
                ri.Principal_Text = checkNull(r.Principal_Text__c + '');
                ri.Principal = checkNull(r.Principal__c + '');
                ri.Promoter_Attendance_Rule = checkNull(r.Promoter_Attendance_Rule__c + '');
                ri.RecordType = checkNull(r.RecordType__c + '');
                ri.SAPCreateTime = checkNull(r.SAPCreateTime__c + '');
                ri.SAPCreate = checkNull(r.SAPCreate__c + '');
                ri.SAPExternal = checkNull(r.SAPExternal__c + '');
                ri.SAPUserName = checkNull(r.SAPUserName__c + '');
                ri.Shop_Id = checkNull(r.Shop_Id__c + '');
                ri.Shop_Name_Text = checkNull(r.Shop_Name_Text__c + '');
                ri.Shop_Name = checkNull(r.Shop_Name__c + '');
                ri.Store_Grid = checkNull(r.Store_Grid__c + '');
                ri.UserEmail = checkNull(r.UserEmail__c + '');

                responsiblePersonInfoList.add(ri);
            }
            result.promotersInfoList = responsiblePersonInfoList;
            result.promotersTotalNumber = responsiblePersonInfoList.size();

            //巡店报告门店总数
            List<Daily_Inspection_Report__c> dirList = [select id, 
                                                            Name,
                                                            CreatedDate,
                                                            LastModifiedDate,
                                                            Average_Score_Count__c,
                                                            Average_Score_Max__c,
                                                            Average_Score__c,
                                                            Created_By_Role__c,
                                                            Customer_Attribute__c,
                                                            Customer_Name__c,
                                                            Customer__c,
                                                            ExternalId__c,
                                                            Gridding__c,
                                                            Inspection_Shop_Plan__c,
                                                            Mileage_Of_Today__c,
                                                            NeedCheckIn__c,
                                                            Note__c,
                                                            Owner_Email__c,
                                                            Owner_Profile__c,
                                                            Owner_text__c,
                                                            Report_Date__c,
                                                            Report_Detail__c,
                                                            Report_Type__c,
                                                            Sales_Region__c,
                                                            Status__c,
                                                            Store__c,
                                                            Summary__c,
                                                            Total_Score_Max__c,
                                                            Total_Score__c
                                                            from Daily_Inspection_Report__c where LastModifiedDate >= :startTime and LastModifiedDate <= :endTime];
            
            List<DailyInspectionReportInfo> dirInfoList = new List<DailyInspectionReportInfo>();
            for(Daily_Inspection_Report__c d : dirList){
                DailyInspectionReportInfo di = new DailyInspectionReportInfo();
                di.id = checkNull(d.id + '');
                di.CreatedDate = checkNull(d.CreatedDate + '');
                di.LastModifiedDate = checkNull(d.LastModifiedDate + '');
                di.Name = checkNull(d.Name + '');
                di.Average_Score_Count = checkNull(d.Average_Score_Count__c + '');
                di.Average_Score_Max = checkNull(d.Average_Score_Max__c + '');
                di.Average_Score = checkNull(d.Average_Score__c + '');
                di.Created_By_Role = checkNull(d.Created_By_Role__c + '');
                di.Customer_Attribute = checkNull(d.Customer_Attribute__c + '');
                di.Customer_Name = checkNull(d.Customer_Name__c + '');
                di.Customer = checkNull(d.Customer__c + '');
                di.ExternalId = checkNull(d.ExternalId__c + '');
                di.Gridding = checkNull(d.Gridding__c + '');
                di.Inspection_Shop_Plan = checkNull(d.Inspection_Shop_Plan__c + '');
                di.Mileage_Of_Today = checkNull(d.Mileage_Of_Today__c + '');
                di.NeedCheckIn = checkNull(d.NeedCheckIn__c + '');
                di.Note = checkNull(d.Note__c + '');
                di.Owner_Email = checkNull(d.Owner_Email__c + '');
                di.Owner_Profile = checkNull(d.Owner_Profile__c + '');
                di.Owner_text = checkNull(d.Owner_text__c + '');
                di.Report_Date = checkNull(d.Report_Date__c + '');
                di.Report_Detail = checkNull(d.Report_Detail__c + '');
                di.Report_Type = checkNull(d.Report_Type__c + '');
                di.Sales_Region = checkNull(d.Sales_Region__c + '');
                di.Status = checkNull(d.Status__c + '');
                di.Store = checkNull(d.Store__c + '');
                di.Summary = checkNull(d.Summary__c + '');
                di.Total_Score_Max = checkNull(d.Total_Score_Max__c + '');
                di.Total_Score = checkNull(d.Total_Score__c + '');
                dirInfoList.add(di);
            }
            result.dailyInspectionReportInfoList = dirInfoList;
            result.dailyInspectionReportTotalNumber = dirInfoList.size();

            //年累或月累所有出现问题
            List<Ticket__c> ticketList = [select id, 
                                            Name,
                                            CreatedDate,
                                            LastModifiedDate, 
                                            AssignedTo__c,
                                            CheckItem__c,
                                            CheckResult__c,
                                            ClosedDailyInspectionReport__c,
                                            Department__c,
                                            Description__c,
                                            DueDate__c,
                                            Histories_Feedback__c,
                                            InspectionReport__c,
                                            Newest_Feedback__c,
                                            Priority__c,
                                            PromoterDailyReport__c,
                                            ResponsibleDepartmentUserIds__c,
                                            ResponsibleDepartment__c,
                                            SalesRegion__c,
                                            Sales_Region__c,
                                            Status__c,
                                            Subject__c,
                                            isMine__c
                                            from Ticket__c where LastModifiedDate >= :startTime and LastModifiedDate <= :endTime];
            
            List<TicketInfo> ticketInfoList = new List<TicketInfo>();
            for(Ticket__c t : ticketList){
                TicketInfo ti = new TicketInfo();
                ti.id  = checkNull(t.id  + '');
                ti.Name  = checkNull(t.Name  + '');
                ti.CreatedDate  = checkNull(t.CreatedDate  + '');
                ti.LastModifiedDate  = checkNull(t.LastModifiedDate  + '');
                ti.AssignedTo = checkNull(t.AssignedTo__c + '');
                ti.CheckItem = checkNull(t.CheckItem__c + '');
                ti.CheckResult = checkNull(t.CheckResult__c + '');
                ti.ClosedDailyInspectionReport = checkNull(t.ClosedDailyInspectionReport__c + '');
                ti.Department = checkNull(t.Department__c + '');
                ti.Description = checkNull(t.Description__c + '');
                ti.DueDate = checkNull(t.DueDate__c + '');
                ti.Histories_Feedback = checkNull(t.Histories_Feedback__c + '');
                ti.InspectionReport = checkNull(t.InspectionReport__c + '');
                ti.Newest_Feedback = checkNull(t.Newest_Feedback__c + '');
                ti.Priority = checkNull(t.Priority__c + '');
                ti.PromoterDailyReport = checkNull(t.PromoterDailyReport__c + '');
                ti.ResponsibleDepartmentUserIds = checkNull(t.ResponsibleDepartmentUserIds__c + '');
                ti.ResponsibleDepartment = checkNull(t.ResponsibleDepartment__c + '');
                ti.SalesRegion = checkNull(t.SalesRegion__c + '');
                ti.Sales_Region = checkNull(t.Sales_Region__c + '');
                ti.Status = checkNull(t.Status__c + '');
                ti.Subject = checkNull(t.Subject__c + '');
                ti.isMine = checkNull(t.isMine__c + '');

                ticketInfoList.add(ti);
            }
            result.ticketInfoList = ticketInfoList;
            result.ticketTotalNumber = ticketInfoList.size();

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendKanbanIndicatorToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            //String str = JSON.serialize(result).replace('null','null');
            //result = (SendKanbanIndicatorToBigData.AppOutPut)JSON.deserialize(str, SendKanbanIndicatorToBigData.AppOutPut.class);
            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendKanbanIndicatorToBigData';
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

    public class CustomerInfo {
        public String id;
        public String CreatedDate;
        public String LastModifiedDate;  
        public String SAPCodeGenerationTime;
        public String AccountNumber;
        public String AccountSource;
        public String Active_Flag;
        public String Actual_Sales_Income_Ratio_N_1_Year;
        public String Address_Text;
        public String Address;
        public String AnnualRevenue;
        public String Approval_Status;
        public String Attribute2;
        public String Automatic_updates;
        public String Avaliable_Credit_Limit_Currency;
        public String Avaliable_Credit_Limit_ZAR;
        public String Avaliable_Credit_Limit;
        public String Basic_Approval_Status;
        public String BillingAddress;
        public String Brands_Work_with_Hisense;
        public String Buyer_English_Name;
        public String ChannelProgramLevelName;
        public String ChannelProgramName;
        public String Channel_Level;
        public String Check_Digit;
        public String City;
        public String Contract_Rebate_Types;
        public String Cooperated_Store_Quantity;
        public String Corporate_Representative;
        public String Coverage;
        public String Credit_Account_Code;
        public String Credit_Account_Name;
        public String Credit_Approval_Status;
        public String Credit_Currency;
        public String CurrencyIsoCode;
        public String Customer_Category;
        public String Customer_Classification;
        public String Customer_Group2;
        public String Customer_Group;
        public String Customer_Management_Id;
        public String Customer_Management_Code;
        public String Customer_Management_Name;
        public String Customer_Name_Local_Language;
        public String Customer_No;
        public String Customer_Record_Type_Name;
        public String Customer_SF_Code;
        public String Customer_Sales_For_3_Consecutive_Years_1;
        public String Customer_Sales_For_3_Consecutive_Years_2;
        public String Customer_Sales_For_3_Consecutive_Years_3;
        public String Customer_Sales_Scale;
        public String Customer_Short_Name;
        public String Customer_Status;
        public String Customer_dba;
        public String Customer_type;
        public String Delivery_Matters_Needing_Attention;
        public String Delivery_Priority;
        public String Delivery_Way;
        public String Deliverying_Plant;
        public String Description;
        public String Differential_Request_Method;
        public String Distribution_Channel;
        public String E_commerce_Customer_Label;
        public String Eliminate_Approval_Status;
        public String Email;
        public String ExcodeLen;
        public String ExternalIDFormula;
        public String External_Key;
        public String Fax;
        public String Goods_Form;
        public String Gross_Profit;
        public String Guarantor_Country_Code;
        public String Have_Parent_Customer;
        public String Headquarters_Approval_Status;
        public String Hisense_ASM;
        public String Hisense_Actual_Sales_Income_Ratio_N_Year;
        public String Hisense_Entity;
        public String Hisense_RSM;
        //public String Industry;
        public String Industry;
        public String IsChange;
        //public String IsCustomerPortal;
        public String IsInMyRegion;
        public String IsNew;
        public String IsPartner;
        public String IsUsedForBackground;
        public String Japan_Unlock_Tag;
        public String Jigsaw;
        public String KDGRP;
        public String Location_No_1;
        public String Location_No_2;
        public String Main_Business_Scope;
        public String Management_Area;
        public String Name;
        public String Natural_Person_or_Not;
        public String NumberOfEmployees;
        //public String OperatingHoursId;
        public String Order_Way;
        public String Other_Delivery_Way;
        public String Other_Order_Way;
        public String Other_Pay_Day;
        public String Other_Pay_Way;
        public String Other_Payment_Details;
        public String Other_Single_Mode;
        public String Other_Trade_Payment_Days;
        public String Overdue_Amount;
        public String Overdue_Currency;
        public String Overdue_Y_N;
        public String OwnerId;
        public String Ownership;
        public String ParentId;
        public String Parent_Customer;
        public String Pay_Day;
        public String Pay_Object;
        public String Pay_Way;
        public String Payback_Overdue_Number;
        public String Payback_Y_N;
        public String Payer;
        public String Payment_Condition;
        public String Payment_Details;
        public String Payment_Term;
        public String Payment_methods;
        public String Phone;
        public String Postal_Code;
        public String Price_Book_Region;
        public String Price_List;
        public String Product_Line;
        public String Province_State;
        public String RR_China_Credit;
        public String Rank;
        public String Rating;
        public String Receiver;
        public String Reconciliation_Customer;
        public String Region;
        public String Related_staff_associates_with_Buyer_Y_N;
        public String Related_to_POD;
        public String Restore_Approval_Status;
        public String SAP_Account;
        public String SAP_Credit_Limit_Currency;
        public String SAP_Credit_Limit_ZAR;
        public String SAP_Credit_Limit;
        public String SAP_Customer_Code;
        public String SA_Credit_Send_Email_Flag;
        public String SA_Financial_Email_Date;
        public String Sales_Group;
        public String Sales_Office;
        public String Sales_Region;
        public String ShippingAddress;
        public String Shipping_Conditions;
        public String Sic;
        public String SicDesc;
        public String Single_Mode;
        public String Site;
        public String South_Africa_Flag;
        public String Status_Changing_Time_From_SAP;
        public String Stor_Location;
        public String SumOfPL;
        public String SumOfSales;
        public String Tax_Classification;
        public String Tax_Number1;
        public String Tax_Number2;
        public String TickerSymbol;
        public String Tier;
        public String Total_Store_Quantity;
        public String Trade_Payment_Days;
        public String Type;
        public String Uploding_Usage_Key;
        public String Used_Credit_Limit_Currency;
        public String Used_Credit_Limit_ZAR;
        public String Used_Credit_Limit;
        public String VAT_Registration_Number;
        public String VAT_Tax_type;
        public String Website;
        public String channel;
        public String isGoFinApprove;

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

    public class ResponsiblePersonInfo{
        public String id; 
        public String Account_Name;
        public String External_Key_ID;
        public String Is_Export;
        public String Principal_Text;
        public String Principal;
        public String Promoter_Attendance_Rule;
        public String RecordType;
        public String SAPCreateTime;
        public String SAPCreate;
        public String SAPExternal;
        public String SAPUserName;
        public String Shop_Id;
        public String Shop_Name_Text;
        public String Shop_Name;
        public String Store_Grid;
        public String UserEmail;

    }

    public class DailyInspectionReportInfo{
        public String id; 
        public String CreatedDate;
        public String LastModifiedDate;
        public String Name; 
        public String Average_Score_Count;
        public String Average_Score_Max;
        public String Average_Score;
        public String Created_By_Role;
        public String Customer_Attribute;
        public String Customer_Name;
        public String Customer;
        public String ExternalId;
        public String Gridding;
        public String Inspection_Shop_Plan;
        public String Mileage_Of_Today;
        public String NeedCheckIn;
        public String Note;
        public String Owner_Email;
        public String Owner_Profile;
        public String Owner_text;
        public String Report_Date;
        public String Report_Detail;
        public String Report_Type;
        public String Sales_Region;
        public String Status;
        public String Store;
        public String Summary;
        public String Total_Score_Max;
        public String Total_Score;
    }

    public class TicketInfo{
        public String id; 
        public String Name; 
        public String CreatedDate;
        public String LastModifiedDate;  
        public String AssignedTo;
        public String CheckItem;
        public String CheckResult;
        public String ClosedDailyInspectionReport;
        public String Department;
        public String Description;
        public String DueDate;
        public String Histories_Feedback;
        public String InspectionReport;
        public String Newest_Feedback;
        public String Priority;
        public String PromoterDailyReport;
        public String ResponsibleDepartmentUserIds;
        public String ResponsibleDepartment;
        public String SalesRegion;
        public String Sales_Region;
        public String Status;
        public String Subject;
        public String isMine;
    }

}