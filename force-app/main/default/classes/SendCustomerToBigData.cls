@RestResource(urlMapping='/SendCustomerToBigData')
global with sharing class SendCustomerToBigData {  

    global class AppInput{
        public String startTime; 
        public String endTime; 
        public String pageIndex;
        public String pageSize;
    }
    global class AppOutPut{
        public Integer totalPage;
        List<CustomerInfo> customerInfoList;
    }
    
    @HttpPost
    global static SendCustomerToBigData.AppOutPut adoPost() {

        List<Customer_Product_Line__c> cplList = [select id,Product_Line_Name__c, Customer__c, Cooperation_Level__c from Customer_Product_Line__c];
        Map<String, String> clMap = new Map<String, String>();
        for(Customer_Product_Line__c cpl : cplList){
            if(String.isNotBlank(cpl.Cooperation_Level__c)){
                if(String.isBlank(clMap.get(cpl.Customer__c))){
                    clMap.put(cpl.Customer__c, cpl.Product_Line_Name__c + ':' + cpl.Cooperation_Level__c + ';');
                }else{
                    clMap.put(cpl.Customer__c, clMap.get(cpl.Customer__c) + cpl.Product_Line_Name__c + ':' + cpl.Cooperation_Level__c + ';');
                }
            }
        }

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendCustomerToBigData.AppInput appInput = new SendCustomerToBigData.AppInput();
        
        SendCustomerToBigData.AppOutPut result = new SendCustomerToBigData.AppOutPut();
        
        try{
            appInput = (SendCustomerToBigData.AppInput)JSON.deserialize(reqBody, SendCustomerToBigData.AppInput.class);

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

            
            String sql = 'select id,' +

            'MDG_Customer_Code__c,'+
            'Trader_Type__c,'+
            'CustomerDetailType__c,'+
            'FormerName__c,'+
            'ID_Type__c,'+
            'Company_Registration_Number__c,'+
            'DUNS_Number__c,'+
            'License_Expiration_Date__c,'+
            'Registration_Date__c,'+
            'Registered_Capital__c,'+
            'Paid_In_Funds__c,'+
            'Unit_Nature__c,'+
            'Annual_Revenue_Scale__c,'+
            'Is_Listed_Company__c,'+
            'Listed_Company_Code__c,'+
            'Language__c,'+
            'Belonged_Customer_Code__c,'+
            'Credit_Management__c,'+

            'CreatedDate,' +
            'LastModifiedDate, ' +
            'SAP_Code_Generation_Time__c,  ' +
            'Actual_Sales_Income_Ratio_N_1_Year__c,' +
            'Address_Text__c,' +
            'Address__c,' +
            'Approval_Status__c,' +
            'Avaliable_Credit_Limit_Currency__c,' +
            'Avaliable_Credit_Limit_ZAR__c,' +
            'Avaliable_Credit_Limit__c,' +
            'Channel_Level__c,' +
            'Check_Digit__c,' +
            'City__c,' +
            'Cooperated_Store_Quantity__c,' +
            'Corporate_Representative__c,' +
            'Coverage__c,' +
            'Credit_Account_Code__c,' +
            'Credit_Account_Name__c,' +
            'Credit_Approval_Status__c,' +
            'Credit_Currency__c,' +
            'CurrencyIsoCode,' +
            'Customer_Category__c,' +
            'Customer_Classification__c,' +
            'Customer_Group2__c,' +
            'Customer_Group__c,' +
            'Customer_Management_Name__c,' +
            'Customer_Management_Name__r.Customer_Management_Name_Code__c, ' +
            'Customer_Management_Name__r.name,' +
            'Customer_Name_Local_Language__c,' +
            'Customer_No__c,' +
            'Customer_Record_Type_Name__c,' +
            'Customer_SF_Code__c,' +
            'Customer_Sales_For_3_Consecutive_Years_1__c,' +
            'Customer_Sales_For_3_Consecutive_Years_2__c,' +
            'Customer_Sales_For_3_Consecutive_Years_3__c,' +
            'Customer_Sales_Scale__c,' +
            'Customer_Short_Name__c,' +
            'Customer_Status__c,' +
            'Customer_type__c,' +
            'Delivery_Matters_Needing_Attention__c,' +
            'Delivery_Priority__c,' +
            'Delivery_Way__c,' +
            'Deliverying_Plant__c,' +
            'Description,' +
            'Differential_Request_Method__c,' +
            'Distribution_Channel__c,' +
            'E_commerce_Customer_Label__c,' +
            'Email__c,' +
            'ExcodeLen__c,' +
            'External_Key__c,' +
            'Fax,' +
            'Goods_Form__c,' +
            'Gross_Profit__c,' +
            'Guarantor_Country_Code__c,' +
            'Have_Parent_Customer__c,' +
            'Hisense_Actual_Sales_Income_Ratio_N_Year__c,' +
            'Hisense_Entity__c,' +
            'Hisense_RSM__c,' +
            'IsPartner,' +
            'KDGRP__c,' +
            'Location_No_1__c,' +
            'Location_No_2__c,' +
            'Main_Business_Scope__c,' +
            'Management_Area__c,' +
            'Name,' +
            'Natural_Person_or_Not__c,' +
            'NumberOfEmployees,' +
            'Order_Way__c,' +
            'Other_Delivery_Way__c,' +
            'Other_Order_Way__c,' +
            'Other_Pay_Day__c,' +
            'Other_Pay_Way__c,' +
            'Other_Payment_Details__c,' +
            'Other_Single_Mode__c,' +
            'Other_Trade_Payment_Days__c,' +
            'Overdue_Amount__c,' +
            'Overdue_Currency__c,' +
            'Overdue_Y_N__c,' +
            'OwnerId,' +
            'ParentId,' +
            'Pay_Day__c,' +
            'Pay_Object__c,' +
            'Pay_Way__c,' +
            'Payback_Overdue_Number__c,' +
            'Payback_Y_N__c,' +
            'Payer__c,' +
            'Payment_Condition__c,' +
            'Payment_Details__c,' +
            'Payment_Term__c,' +
            'Payment_methods__c,' +
            'Phone,' +
            'Postal_Code__c,' +
            'Price_Book_Region__c,' +
            'Price_List__c,' +
            'Product_Line__c,' +
            'Province_State__c,' +
            'RR_China_Credit__c,' +
            'Rank__c,' +
            'Receiver__c,' +
            'Reconciliation_Customer__c,' +
            'Region__c,' +
            'Related_staff_associates_with_Buyer_Y_N__c,' +
            'Related_to_POD__c,' +
            'Restore_Approval_Status__c,' +
            'SAP_Account__c,' +
            'SAP_Credit_Limit_Currency__c,' +
            'SAP_Credit_Limit_ZAR__c,' +
            'SAP_Credit_Limit__c,' +
            'SAP_Customer_Code__c,' +
            'SA_Credit_Send_Email_Flag__c,' +
            'SA_Financial_Email_Date__c,' +
            'Sales_Group__c,' +
            'Sales_Office__c,' +
            'Sales_Region__c,' +
            'ShippingAddress,' +
            'Shipping_Conditions__c,' +
            'Single_Mode__c,' +
            'South_Africa_Flag__c,' +
            'Status_Changing_Time_From_SAP__c,' +
            'Stor_Location__c,' +
            'SumOfPL__c,' +
            'SumOfSales__c,' +
            'Tax_Classification__c,' +
            'Tax_Number1__c,' +
            'Tax_Number2__c,' +
            'TickerSymbol,' +
            'Total_Store_Quantity__c,' +
            'Trade_Payment_Days__c,' +
            'Type,' +
            'Uploding_Usage_Key__c,' +
            'Used_Credit_Limit_Currency__c,' +
            'Used_Credit_Limit_ZAR__c,' +
            'Used_Credit_Limit__c,' +
            'VAT_Registration_Number__c,' +
            'VAT_Tax_type__c,' +
            'channel__c,' +
            'channel_type__c ' +
            'from Account where RecordType.DeveloperName  != \'Customer_Address\' and MDG_Customer_Code__c != null and LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
   
            //List<Account> customerList = (List<Account>)Utility.getRecordListPage(sql, appInput.pageIndex, appInput.pageSize);
            List<Account> customerList = Utility.apexPagination(Database.query(sql), Integer.valueOf(appInput.pageIndex), Integer.valueOf(appInput.pageSize));
            List<CustomerInfo> customerInfoList = new List<CustomerInfo>();
            for(Account a : customerList){
                CustomerInfo c = new CustomerInfo();
                c.id = a.id;
                c.CreatedDate = checkNull(a.CreatedDate + '');
                c.LastModifiedDate = checkNull(a.LastModifiedDate + '');  
                c.SAPCodeGenerationTime = checkNull(a.SAP_Code_Generation_Time__c + '');
                c.Actual_Sales_Income_Ratio_N_1_Year = checkNull(a.Actual_Sales_Income_Ratio_N_1_Year__c + '');
                c.Address_Text = checkNull(a.Address_Text__c + '');
                c.Address = checkNull(a.Address__c + '');
                c.Approval_Status = checkNull(a.Approval_Status__c + '');
                c.Avaliable_Credit_Limit_Currency = checkNull(a.Avaliable_Credit_Limit_Currency__c + '');
                c.Avaliable_Credit_Limit_ZAR = checkNull(a.Avaliable_Credit_Limit_ZAR__c + '');
                c.Avaliable_Credit_Limit = checkNull(a.Avaliable_Credit_Limit__c + '');
                c.Channel_Level = checkNull(a.Channel_Level__c + '');
                c.Check_Digit = checkNull(a.Check_Digit__c + '');
                c.City = checkNull(a.City__c + '');
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
                c.Customer_type = checkNull(a.Customer_type__c + '');
                c.Delivery_Matters_Needing_Attention = checkNull(a.Delivery_Matters_Needing_Attention__c + '');
                c.Delivery_Priority = checkNull(a.Delivery_Priority__c + '');
                c.Delivery_Way = checkNull(a.Delivery_Way__c + '');
                c.Deliverying_Plant = checkNull(a.Deliverying_Plant__c + '');
                c.Description = checkNull(a.Description + '');
                c.Differential_Request_Method = checkNull(a.Differential_Request_Method__c + '');
                c.Distribution_Channel = checkNull(a.Distribution_Channel__c + '');
                c.E_commerce_Customer_Label = checkNull(a.E_commerce_Customer_Label__c + '');
                c.Email = checkNull(a.Email__c + '');
                c.ExcodeLen = checkNull(a.ExcodeLen__c + '');
                c.External_Key = checkNull(a.External_Key__c + '');
                c.Fax = checkNull(a.Fax + '');
                c.Goods_Form = checkNull(a.Goods_Form__c + '');
                c.Gross_Profit = checkNull(a.Gross_Profit__c + '');
                c.Guarantor_Country_Code = checkNull(a.Guarantor_Country_Code__c + '');
                c.Have_Parent_Customer = checkNull(a.Have_Parent_Customer__c + '');
                c.Hisense_Actual_Sales_Income_Ratio_N_Year = checkNull(a.Hisense_Actual_Sales_Income_Ratio_N_Year__c + '');
                c.Hisense_Entity = checkNull(a.Hisense_Entity__c + '');
                c.Hisense_RSM = checkNull(a.Hisense_RSM__c + '');
                c.IsPartner = checkNull(a.IsPartner + '');
                c.KDGRP = checkNull(a.KDGRP__c + '');
                c.Location_No_1 = checkNull(a.Location_No_1__c + '');
                c.Location_No_2 = checkNull(a.Location_No_2__c + '');
                c.Main_Business_Scope = checkNull(a.Main_Business_Scope__c + '');
                c.Management_Area = checkNull(a.Management_Area__c + '');
                c.Name = checkNull(a.Name + '');
                c.Natural_Person_or_Not = checkNull(a.Natural_Person_or_Not__c + '');
                c.NumberOfEmployees = checkNull(a.NumberOfEmployees + '');
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
                c.ParentId = checkNull(a.ParentId + '');
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
                c.Single_Mode = checkNull(a.Single_Mode__c + '');
                c.South_Africa_Flag = checkNull(a.South_Africa_Flag__c + '');
                c.Status_Changing_Time_From_SAP = checkNull(a.Status_Changing_Time_From_SAP__c + '');
                c.Stor_Location = checkNull(a.Stor_Location__c + '');
                c.SumOfPL = checkNull(a.SumOfPL__c + '');
                c.SumOfSales = checkNull(a.SumOfSales__c + '');
                c.Tax_Classification = checkNull(a.Tax_Classification__c + '');
                c.Tax_Number1 = checkNull(a.Tax_Number1__c + '');
                c.Tax_Number2 = checkNull(a.Tax_Number2__c + '');
                c.TickerSymbol = checkNull(a.TickerSymbol + '');
                c.Total_Store_Quantity = checkNull(a.Total_Store_Quantity__c + '');
                c.Trade_Payment_Days = checkNull(a.Trade_Payment_Days__c + '');
                c.Type = checkNull(a.Type + '');
                c.Uploding_Usage_Key = checkNull(a.Uploding_Usage_Key__c + '');
                c.Used_Credit_Limit_Currency = checkNull(a.Used_Credit_Limit_Currency__c + '');
                c.Used_Credit_Limit_ZAR = checkNull(a.Used_Credit_Limit_ZAR__c + '');
                c.Used_Credit_Limit = checkNull(a.Used_Credit_Limit__c + '');
                c.VAT_Registration_Number = checkNull(a.VAT_Registration_Number__c + '');
                c.VAT_Tax_type = checkNull(a.VAT_Tax_type__c + '');
                c.channel = checkNull(a.channel__c + '');
                c.CooperationLevel = checkNull(clMap.get(a.id));
                c.channelType = checkNull(a.channel_type__c + '');
                
                c.MDG_Customer_Code = checkNull(a.MDG_Customer_Code__c + '');
                c.Trader_Type = checkNull(a.Trader_Type__c + '');
                c.CustomerDetailType = checkNull(a.CustomerDetailType__c + '');
                c.FormerName = checkNull(a.FormerName__c + '');
                c.ID_Type = checkNull(a.ID_Type__c + '');
                c.Company_Registration_Number = checkNull(a.Company_Registration_Number__c + '');
                c.DUNS_Number = checkNull(a.DUNS_Number__c + '');
                c.License_Expiration_Date = checkNull(a.License_Expiration_Date__c + '');
                c.Registration_Date = checkNull(a.Registration_Date__c + '');
                c.Registered_Capital = checkNull(a.Registered_Capital__c + '');
                c.Paid_In_Funds = checkNull(a.Paid_In_Funds__c + '');
                c.Unit_Nature = checkNull(a.Unit_Nature__c + '');
                c.Annual_Revenue_Scale = checkNull(a.Annual_Revenue_Scale__c + '');
                c.Is_Listed_Company = checkNull(a.Is_Listed_Company__c + '');
                c.Listed_Company_Code = checkNull(a.Listed_Company_Code__c + '');
                c.Language = checkNull(a.Language__c + '');
                c.Belonged_Customer_Code = checkNull(a.Belonged_Customer_Code__c + '');
                c.Credit_Management = checkNull(a.Credit_Management__c + '');


                customerInfoList.add(c);
            }
            result.customerInfoList = customerInfoList;

            String sql1 = 'select count(id) totalNumber from Account where LastModifiedDate >= '+appInput.startTime+' and LastModifiedDate <= '+appInput.endTime;
            List<AggregateResult> c = Database.query(sql1);
            result.totalPage = (Integer.valueOf(c.get(0).get('totalNumber')) + Integer.valueOf(appInput.pageSize) - 1) / Integer.valueOf(appInput.pageSize);

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerToBigData';
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
        public String Actual_Sales_Income_Ratio_N_1_Year;
        public String Address_Text;
        public String Address;
        public String Approval_Status;
        public String Avaliable_Credit_Limit_Currency;
        public String Avaliable_Credit_Limit_ZAR;
        public String Avaliable_Credit_Limit;
        public String Channel_Level;
        public String Check_Digit;
        public String City;
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
        public String External_Key;
        public String Fax;
        public String Goods_Form;
        public String Gross_Profit;
        public String Guarantor_Country_Code;
        public String Have_Parent_Customer;
        public String Hisense_Actual_Sales_Income_Ratio_N_Year;
        public String Hisense_Entity;
        public String Hisense_RSM;
        public String IsPartner;
        public String KDGRP;
        public String Location_No_1;
        public String Location_No_2;
        public String Main_Business_Scope;
        public String Management_Area;
        public String Name;
        public String Natural_Person_or_Not;
        public String NumberOfEmployees;
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
        public String ParentId;
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
        public String Single_Mode;
        public String South_Africa_Flag;
        public String Status_Changing_Time_From_SAP;
        public String Stor_Location;
        public String SumOfPL;
        public String SumOfSales;
        public String Tax_Classification;
        public String Tax_Number1;
        public String Tax_Number2;
        public String TickerSymbol;
        public String Total_Store_Quantity;
        public String Trade_Payment_Days;
        public String Type;
        public String Uploding_Usage_Key;
        public String Used_Credit_Limit_Currency;
        public String Used_Credit_Limit_ZAR;
        public String Used_Credit_Limit;
        public String VAT_Registration_Number;
        public String VAT_Tax_type;
        public String channel;
        public String CooperationLevel;
        public String channelType;
        public String MDG_Customer_Code;
        public String Trader_Type;
        public String CustomerDetailType;
        public String FormerName;
        public String ID_Type;
        public String Company_Registration_Number;
        public String DUNS_Number;
        public String License_Expiration_Date;
        public String Registration_Date;
        public String Registered_Capital;
        public String Paid_In_Funds;
        public String Unit_Nature;
        public String Annual_Revenue_Scale;
        public String Is_Listed_Company;
        public String Listed_Company_Code;
        public String Language;
        public String Belonged_Customer_Code;
        public String Credit_Management;

    }
}