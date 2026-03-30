/**********************************************************************
* Name: SyncCustomerCreditInfoToRR
* Object: Credit_Limit_Application__c 
* Purpose: When credit limit application get approved,credit limit information
* send to RR system automatically
* Author: Roy
* Create Date: 2019-03-10
*************************************************************************/
global with sharing class SyncCustomerCreditInfoToRR{

  private static String url = Interface_Url__c.getValues('RR').Basic_Url__c + 'CC_REST_CUSTOMER_CREDIT_APPROVAL_SEND';
  private static String user = Interface_Url__c.getValues('RR').User_Name__c;
  private static String password = Interface_Url__c.getValues('RR').Password__c;

  /* Credit Limit Information */
  public class CreditLimitInfo {
    public  String  SFCode;
    public  String  SAPCustomerCode;
    public  String  Organization;
    public  String  ChinaCreditInsuranceBuyerCode;
    //public  String  EnterpriseInternalcode;
    public  String  BuyerEnglishName;
    public  String  BuyerEnglishaddress;
    public  String  BuyerCountryCode;
    public  String  BuyerPhone;
    public  String  BuyerRegistrationNumber;
    public  String  BuyerVATNumber;
    public  String  IndependentlyControlTheCreditLimit;
    public  String  BuyerFax;
    public  String  CreditApplicatioPeriod;
    public  String  CompetitiveProductAccountInformation;
    public  String  CompetitiveProductAccountPeriod;
    public  String  CreditLimiteforApplication;
    public  String  ExportGoodsName;
    public  String  HistoricalTransaction;
    public  String  EarliestTransactioYear;
    public  String  EarliestYearofRelease;
    public  String  LastThreeTransactioYears1;
    public  String  TransactionSettlementMethod1;
    public  String  Last3YearsTransactionAmount1;
    public  String  LastThreeTransactioYears2;
    public  String  TransactionSettlementMethod2;
    public  String  Last3YearsTransactionAmount2;
    public  String  LastThreeTransactioYears3;
    public  String  TransactionSettlementMethod3;
    public  String  Last3YearsTransactionAmount3;
    public  String  PossessGuarantor;
    public  String  ChinaCreditInsuranceGuarantorCode;
    //public  String  CorporateGuarantorCode;
    public  String  GuarantorEnglishName;
    public  String  GuarantorCountryCode;
    public  String  GuarantorEnglishAddress;
    public  String  GuarantorPhone;
    public  String  GuarantorFax;
    public  String  GuarantorRegistrationNumber;
    public  String  SalespersonName;
    public  String  PaymentMethod;
    public  String  CurrentOrderAmount;
    public  String  CurrentCustomerReceivableBalanceUSD;
    public  String  Circular;
    public  String  LetterofCreditNumber;
    public  String  LetterofCreditAmount;
    public  String  LatestShippingDate;
    public  String  CreditGuaranteeIssuingBankSWIFT;
    public  String  IssuingBankEnterpriseInternalCode;
    public  String  IssuingBankEnglishName;
    public  String  IssuingBankCountryCode;
    public  String  IssuingBankEnglishAddress;
    public  String  CreditInsuranceConfirmation;
    public  String  CreditInsuranceConfirmationBankSWIFT;
    public  String  ConfirmationBankEnglishName;
    public  String  ConfirmedBankCountryCode;
    public  String  ConfirmingBankEnglishAddress;
    public  String  DirectSalesDepartmentLocation;
    public  String  RecordSubmittedDate;
    public  String  EstimatedTransactionAmount;
    public  String  ShippingPlan;
    public  String  InsuranceCompany;
    public  String  BuyerRegionCode;
    public  List<ApprovalInformation> ApprovalInformationList;
    public  List<AttachmentInformation>  AttachmentListToRR;

    public  String  paymodeapply;
    public  String  ifgov;
    public  String  ifquotedcompany;
    public  String  hisbuyerpayment;
    public  String  advancecharge;
    public  String  netadvance;
  }

  /* Credit Limit Information Approval Information */
  public class ApprovalInformation {
    public String Approver;
    public String ApprovedResult;
    public String ApprovedTime;
    public String ApproverEmail;
    public String ApproverRemark;
  }

  public class ResDeta {
    public String FailReason;
    public String IsSuccess;
  }

  public class AttachmentInformation{
    public String AttachmentLink;
    public String AttachmentName;
  }

  @future(callout=true)
  global static Void postInfomation(String customerCreditInforId){
    System.debug('url... '+url);
    System.debug('user... '+user);
    System.debug('password... '+password);
  //public static Void postInfomation(){
    System.debug('aaaaaaaaaa'+customerCreditInforId);
    //查找当前客户的信息
    CreditLimitInfo creditLimitInfo = new CreditLimitInfo();
      // Query quote data from salesforce.
    Credit_Limit_Application__c creditLimit = [SELECT Id,
    Name,
    Customer__c,
    Salesperson_Email__c,
    Customer__r.Customer_SF_Code__c,
    Customer__r.SAP_Customer_Code__c,
    Customer__r.Company_Registration_Number__c,
    Customer__r.VAT_Registration_Number__c,
    Orgnization__c,
    China_Credit_Insurance_Buyer_Code__c,
    //Enterprise_internal_code__c,
    Buyer_English_Name__c,
    Buyer_English_Address__c,
    Buyer_Country_Code__c,
    Buyer_Phone__c,
    Buyer_Registration_Number__c,
    Buyer_VAT_Number__c,
    Independently_control_the_credit_limit__c,
    Buyer_Fax__c,
    Credit_Application_Period_days__c,
    Competitive_Product_Information__c,
    Competitive_Product_Period__c,
    Credit_Limit_for_Application_USD__c,
    Export_Goods_Name__c,
    Historical_Transaction_Y_N__c,
    Earliest_Transaction_Year__c,
    Earliest_Year_of_Release_year__c,
    Last_Three_Transaction_Years_1_year__c,
    Transaction_Settlement_Method_1_3year__c,
    Last_3_Years_Transaction_Amount_1_USD__c,
    Last_Three_Transaction_Years_2_year__c,
    Transaction_Settlement_Method_2_3year__c,
    Last_3_Years_Transaction_Amount_2_USD__c,
    Last_Three_Transaction_Years_3_year__c,
    Transaction_Settlement_Method_3_3year__c,
    Last_3_Years_Transaction_Amount_3_USD__c,
    Possess_Guarantor_Y_N__c,
    China_Credit_Insurance_Guarantor_Code__c,
    //Corporate_Guarantor_Code__c,
    Guarantor_English_Name__c,
    Guarantor_Country_Code__c,
    Guarantor_English_Address__c,
    Guarantor_Phone__c,
    Guarantor_Fax__c,
    Guarantor_Registration_Number__c,
    Salesperson_Name__c,
    Payment_Method__c,
    Current_Order_Amount_USD__c,
    Current_Customer_Receivable_Balance_USD__c,
    Circular_Y_N__c,
    Letter_of_Credit_Number__c,
    Letter_of_Credit_Amount_USD__c,
    Latest_Shipping_Date__c,
    Credit_Guarantee_Issuing_Bank_SWIFT__c,
    Issuing_Bank_Enterprise_Internal_Code__c,
    Issuing_Bank_English_Name__c,
    Issuing_Bank_Country_Code__c,
    Issuing_Bank_Address_English__c,
    Credit_Insurance_Confirmation_Y_N__c,
    Credit_Insurance_Confirmation_Bank_SWIFT__c,
    Confirmation_Bank_English_Name__c,
    Confirmed_Bank_Country_Code__c,
    Confirming_Bank_Address_English__c,
    Direct_Sales_Department_Location__c,
    Estimated_Transaction_Amount_CY__c,
    Shipping__c,
    Insurance_Company__c,
    CreatedById,
    Paymode_Apply__c,
    If_Gov__c,
    If_Quoted_Company__c,
    His_Buyer_Payment__c,
    Advance_Charge__c,
    Net_Advance__c,
    USA_State__c,
    (SELECT Id,
      ActorId,
      StepStatus,
      CreatedDate,
      Comments
      From ProcessSteps order by CreatedDate
      ),
    (SELECT ContentDocumentId,Title FROM AttachedContentDocuments),
    (SELECT id,Shipping_Month__c, Shipping_Amount__c FROM Credit_Shipping_Plan__r )
    FROM Credit_Limit_Application__c Where Id =: customerCreditInforId];
  
    //Map SalesOffice
    Map<String,String> salesOfficeId2CodeMap = new Map<String,String>();
    for(PickList__c plc : [Select id,Value__c  from Picklist__c where id =: creditLimit.Orgnization__c]){
      salesOfficeId2CodeMap.put(plc.Id,plc.Value__c);
    }

    System.debug('salesOfficeId2CodeMap: '+salesOfficeId2CodeMap);

    //Map UserId with UserName
    Map<String,String> userId2UserNameMap = new Map<String,String>();
    for(User user : [Select id, User_Full_Name__c from User]){
      userId2UserNameMap.put(user.Id,user.User_Full_Name__c);
    }

    //Map UserId with UserEmail
    Map<String,String> userId2EmailMap = new Map<String,String>();
    for(User user : [Select id, Email from User]){
      userId2EmailMap.put(user.Id,user.Email);
    }


    if (creditLimit != null) {
      creditLimitInfo.SFCode = creditLimit.Name == null ? '' : creditLimit.Name;
      //String SAPCode = '';
      /*if(creditLimit.Customer__r.SAP_Customer_Code__c != null){
          if(creditLimit.Customer__r.SAP_Customer_Code__c.length() == 6){
            SAPCode = '0000' + creditLimit.Customer__r.SAP_Customer_Code__c;
          }if(creditLimit.Customer__r.SAP_Customer_Code__c.length() == 7){
            SAPCode = '000' + creditLimit.Customer__r.SAP_Customer_Code__c;
          }
        }*/
        //国家ID和Code的Map
        Map<String,String> countryId2CodeMap = new Map<String,String>();
        for(PickList__c plc : [select id,name,Value__c from PickList__c where recordtype.DeveloperName = 'Master_Data_RR_Country']){
            countryId2CodeMap.put(plc.Id, plc.Value__c);
        }

        creditLimitInfo.SAPCustomerCode = creditLimit.Customer__r.SAP_Customer_Code__c == null ? '' : creditLimit.Customer__r.SAP_Customer_Code__c;
        creditLimitInfo.Organization = creditLimit.Orgnization__c == null ? '' : salesOfficeId2CodeMap.get(creditLimit.Orgnization__c);
        creditLimitInfo.ChinaCreditInsuranceBuyerCode = creditLimit.China_Credit_Insurance_Buyer_Code__c == null ? '' : creditLimit.China_Credit_Insurance_Buyer_Code__c;
        //creditLimitInfo.EnterpriseInternalcode = creditLimit.Enterprise_internal_code__c == null ? '' : creditLimit.Enterprise_internal_code__c;
        creditLimitInfo.BuyerEnglishName = creditLimit.Buyer_English_Name__c == null ? '' : creditLimit.Buyer_English_Name__c.replace(' ', ' ');
        creditLimitInfo.BuyerEnglishaddress = creditLimit.Buyer_English_Address__c == null ? '' : creditLimit.Buyer_English_Address__c.replace(' ', ' ');
        creditLimitInfo.BuyerCountryCode = creditLimit.Buyer_Country_Code__c == null ? '' : countryId2CodeMap.get(creditLimit.Buyer_Country_Code__c);
        if('USA'.equals(creditLimitInfo.BuyerCountryCode)){
          creditLimitInfo.BuyerRegionCode = creditLimit.USA_State__c == null ? '' : creditLimit.USA_State__c;
        }
        creditLimitInfo.BuyerPhone = creditLimit.Buyer_Phone__c == null ? '' : creditLimit.Buyer_Phone__c;

        creditLimitInfo.BuyerRegistrationNumber = creditLimit.Buyer_Registration_Number__c == null ? '' : creditLimit.Buyer_Registration_Number__c;
        if(String.isBlank(creditLimitInfo.BuyerRegistrationNumber) && String.isNotBlank(creditLimit.Customer__r.Company_Registration_Number__c)){
          creditLimitInfo.BuyerRegistrationNumber = creditLimit.Customer__r.Company_Registration_Number__c;
        }
        creditLimitInfo.BuyerVATNumber = creditLimit.Buyer_VAT_Number__c == null ? '' : creditLimit.Buyer_VAT_Number__c;
        if(String.isBlank(creditLimitInfo.BuyerVATNumber) && String.isNotBlank(creditLimit.Customer__r.VAT_Registration_Number__c)){
          creditLimitInfo.BuyerVATNumber = creditLimit.Customer__r.VAT_Registration_Number__c;
        }
        
        creditLimitInfo.IndependentlyControlTheCreditLimit = creditLimit.Independently_control_the_credit_limit__c == null ? '' : creditLimit.Independently_control_the_credit_limit__c;
        creditLimitInfo.BuyerFax = creditLimit.Buyer_Fax__c == null ? '' : creditLimit.Buyer_Fax__c;
        creditLimitInfo.CreditApplicatioPeriod = creditLimit.Credit_Application_Period_days__c == null ? '' : creditLimit.Credit_Application_Period_days__c + '';
        creditLimitInfo.CompetitiveProductAccountInformation = creditLimit.Competitive_Product_Information__c == null ? '' : creditLimit.Competitive_Product_Information__c;
        creditLimitInfo.CompetitiveProductAccountPeriod = creditLimit.Competitive_Product_Period__c == null ? '' : creditLimit.Competitive_Product_Period__c;
        creditLimitInfo.CreditLimiteforApplication = creditLimit.Credit_Limit_for_Application_USD__c == null ? '' : creditLimit.Credit_Limit_for_Application_USD__c + '';
        creditLimitInfo.ExportGoodsName = creditLimit.Export_Goods_Name__c == null ? '' : creditLimit.Export_Goods_Name__c;

        if(creditLimit.Historical_Transaction_Y_N__c == True){
          creditLimitInfo.HistoricalTransaction = '1';
          creditLimitInfo.EarliestTransactioYear = creditLimit.Earliest_Transaction_Year__c == null ? '' : creditLimit.Earliest_Transaction_Year__c;
        }else if(creditLimit.Historical_Transaction_Y_N__c == False){
          creditLimitInfo.HistoricalTransaction = '0';
          //如果是新客户，自动默认传递当前年份
          creditLimitInfo.EarliestTransactioYear = (System.now() + '').substring(0,4);
        }

        //creditLimitInfo.EarliestTransactioYear = creditLimit.Earliest_Transaction_Year__c == null ? '' : countryId2CodeMap.get(creditLimit.Earliest_Transaction_Year__c);
        creditLimitInfo.EarliestYearofRelease = creditLimit.Earliest_Year_of_Release_year__c == null ? '' : creditLimit.Earliest_Year_of_Release_year__c;
        creditLimitInfo.LastThreeTransactioYears1 = creditLimit.Last_Three_Transaction_Years_1_year__c == null ? '' : creditLimit.Last_Three_Transaction_Years_1_year__c;
        creditLimitInfo.TransactionSettlementMethod1 = creditLimit.Transaction_Settlement_Method_1_3year__c == null ? '' : creditLimit.Transaction_Settlement_Method_1_3year__c.replace(';', ',');
        creditLimitInfo.Last3YearsTransactionAmount1 = creditLimit.Last_3_Years_Transaction_Amount_1_USD__c == null ? '' : creditLimit.Last_3_Years_Transaction_Amount_1_USD__c + '';
        creditLimitInfo.LastThreeTransactioYears2 = creditLimit.Last_Three_Transaction_Years_2_year__c == null ? '' : creditLimit.Last_Three_Transaction_Years_2_year__c;
        creditLimitInfo.TransactionSettlementMethod2 = creditLimit.Transaction_Settlement_Method_2_3year__c == null ? '' : creditLimit.Transaction_Settlement_Method_2_3year__c.replace(';', ',');
        creditLimitInfo.Last3YearsTransactionAmount2 = creditLimit.Last_3_Years_Transaction_Amount_2_USD__c == null ? '' : creditLimit.Last_3_Years_Transaction_Amount_2_USD__c + '';
        creditLimitInfo.LastThreeTransactioYears3 = creditLimit.Last_Three_Transaction_Years_3_year__c == null ? '' : creditLimit.Last_Three_Transaction_Years_3_year__c;
        creditLimitInfo.TransactionSettlementMethod3 = creditLimit.Transaction_Settlement_Method_3_3year__c == null ? '' : creditLimit.Transaction_Settlement_Method_3_3year__c.replace(';', ',');
        creditLimitInfo.Last3YearsTransactionAmount3 = creditLimit.Last_3_Years_Transaction_Amount_3_USD__c == null ? '' : creditLimit.Last_3_Years_Transaction_Amount_3_USD__c + '';

        if(creditLimit.Possess_Guarantor_Y_N__c == True){
          creditLimitInfo.PossessGuarantor = '1';
        }else if(creditLimit.Possess_Guarantor_Y_N__c == False){
          creditLimitInfo.PossessGuarantor = '0';
        }

        creditLimitInfo.ChinaCreditInsuranceGuarantorCode = creditLimit.China_Credit_Insurance_Guarantor_Code__c == null ? '' : creditLimit.China_Credit_Insurance_Guarantor_Code__c;
        //creditLimitInfo.CorporateGuarantorCode = creditLimit.Corporate_Guarantor_Code__c == null ? '' : creditLimit.Corporate_Guarantor_Code__c;
        creditLimitInfo.GuarantorEnglishName = creditLimit.Guarantor_English_Name__c == null ? '' : creditLimit.Guarantor_English_Name__c;
        creditLimitInfo.GuarantorCountryCode = creditLimit.Guarantor_Country_Code__c == null ? '' : countryId2CodeMap.get(creditLimit.Guarantor_Country_Code__c);
        creditLimitInfo.GuarantorEnglishAddress = creditLimit.Guarantor_English_Address__c == null ? '' : creditLimit.Guarantor_English_Address__c;
        creditLimitInfo.GuarantorPhone = creditLimit.Guarantor_Phone__c == null ? '' : creditLimit.Guarantor_Phone__c;
        creditLimitInfo.GuarantorFax = creditLimit.Guarantor_Fax__c == null ? '' : creditLimit.Guarantor_Fax__c;
        creditLimitInfo.GuarantorRegistrationNumber = creditLimit.Guarantor_Registration_Number__c == null ? '' : creditLimit.Guarantor_Registration_Number__c;
        creditLimitInfo.SalespersonName = creditLimit.Salesperson_Email__c == null ? '' : creditLimit.Salesperson_Email__c;
        creditLimitInfo.PaymentMethod = creditLimit.Payment_Method__c == null ? '' : creditLimit.Payment_Method__c;
        creditLimitInfo.CurrentOrderAmount = creditLimit.Current_Order_Amount_USD__c == null ? '' : creditLimit.Current_Order_Amount_USD__c + '';
        creditLimitInfo.CurrentCustomerReceivableBalanceUSD = creditLimit.Current_Customer_Receivable_Balance_USD__c == null ? '' : creditLimit.Current_Customer_Receivable_Balance_USD__c + '';
        //if(creditLimit.Circular_Y_N__c == True){
        creditLimitInfo.Circular = '1';
        //}else if(creditLimit.Circular_Y_N__c == False){
          //creditLimitInfo.Circular = '0';
        //}
        creditLimitInfo.LetterofCreditNumber = creditLimit.Letter_of_Credit_Number__c == null ? '' : creditLimit.Letter_of_Credit_Number__c;
        creditLimitInfo.LetterofCreditAmount = creditLimit.Letter_of_Credit_Amount_USD__c == null ? '' : creditLimit.Letter_of_Credit_Amount_USD__c + '';
        creditLimitInfo.LatestShippingDate = creditLimit.Latest_Shipping_Date__c == null ? '' : creditLimit.Latest_Shipping_Date__c + '';
        String CreditGuaranteeIssuingBankSWIFTVar ;
        String CreditGuaranteeIssuingBankSWIFTTmp =  creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c;
        if(creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c == null){
          CreditGuaranteeIssuingBankSWIFTVar = '';
        }else{
          //拼接 CreditGuaranteeIssuingBankSWIFT 如果是8位： AAA BBB CC XXX  如果是11位： AAA BBB CC DDD
          if(CreditGuaranteeIssuingBankSWIFTTmp.length() == 8){
            CreditGuaranteeIssuingBankSWIFTVar = CreditGuaranteeIssuingBankSWIFTTmp.substring(0,4) + ' ' + CreditGuaranteeIssuingBankSWIFTTmp.substring(4,6) + ' ' +CreditGuaranteeIssuingBankSWIFTTmp.substring(6,8) + ' ' + 'XXX';
          }else if(CreditGuaranteeIssuingBankSWIFTTmp.length() == 11){
            CreditGuaranteeIssuingBankSWIFTVar = CreditGuaranteeIssuingBankSWIFTTmp.substring(0,4) + ' ' + CreditGuaranteeIssuingBankSWIFTTmp.substring(4,6) + ' ' +CreditGuaranteeIssuingBankSWIFTTmp.substring(6,8) + ' ' + CreditGuaranteeIssuingBankSWIFTTmp.substring(8,11);
          }
        }

        creditLimitInfo.CreditGuaranteeIssuingBankSWIFT = CreditGuaranteeIssuingBankSWIFTVar;

        creditLimitInfo.IssuingBankEnterpriseInternalCode = creditLimit.Issuing_Bank_Enterprise_Internal_Code__c == null ? '' : creditLimit.Issuing_Bank_Enterprise_Internal_Code__c;
        creditLimitInfo.IssuingBankEnglishName = creditLimit.Issuing_Bank_English_Name__c == null ? '' : creditLimit.Issuing_Bank_English_Name__c;
        creditLimitInfo.IssuingBankCountryCode = creditLimit.Issuing_Bank_Country_Code__c == null ? '' : countryId2CodeMap.get(creditLimit.Issuing_Bank_Country_Code__c);
        creditLimitInfo.IssuingBankEnglishAddress = creditLimit.Issuing_Bank_Address_English__c == null ? '' : creditLimit.Issuing_Bank_Address_English__c;
        creditLimitInfo.EstimatedTransactionAmount = creditLimit.Estimated_Transaction_Amount_CY__c == null ? '' :  String.valueOf(creditLimit.Estimated_Transaction_Amount_CY__c);
        if(creditLimit.Credit_Shipping_Plan__r != null && creditLimit.Credit_Shipping_Plan__r.size() > 0 ){
          List<Map<String, String>> lm = new List<Map<String, String>>();
          for(Credit_Shipping_Plan__c csp : creditLimit.Credit_Shipping_Plan__r){
              Map<String, String> shippingPlanMap = new Map<String, String>();
              shippingPlanMap.put('shipmentmonth', String.valueOf(csp.Shipping_Month__c));
              shippingPlanMap.put('shipmentmoney', String.valueOf(csp.Shipping_Amount__c));
              lm.add(shippingPlanMap);
          }
          System.debug(JSON.serialize(lm));
          creditLimitInfo.ShippingPlan = JSON.serialize(lm);
        }else{
          creditLimitInfo.ShippingPlan = '';
        }

        creditLimitInfo.paymodeapply = creditLimit.Paymode_Apply__c == null ? '' : creditLimit.Paymode_Apply__c;
        creditLimitInfo.ifgov = creditLimit.If_Gov__c == null ? '' : creditLimit.If_Gov__c;
        creditLimitInfo.ifquotedcompany = creditLimit.If_Quoted_Company__c == null ? '' : creditLimit.If_Quoted_Company__c;
        creditLimitInfo.hisbuyerpayment = creditLimit.His_Buyer_Payment__c == null ? '' : creditLimit.His_Buyer_Payment__c;
        creditLimitInfo.advancecharge = creditLimit.Advance_Charge__c == null || creditLimit.Advance_Charge__c == 0 ? '' : String.valueOf(creditLimit.Advance_Charge__c);
        creditLimitInfo.netadvance = creditLimit.Net_Advance__c == null || creditLimit.Net_Advance__c == 0 ? '' : String.valueOf(creditLimit.Net_Advance__c);
        
        //creditLimitInfo.ShippingPlan = creditLimit.Shipping__c == null ? '' : creditLimit.Shipping__c;
        creditLimitInfo.InsuranceCompany = creditLimit.Insurance_Company__c == null ? '' : creditLimit.Insurance_Company__c;
        
        
        //if(creditLimit.Credit_Insurance_Confirmation_Y_N__c == True){
          //creditLimitInfo.CreditInsuranceConfirmation = '1';
        //}else if(creditLimit.Credit_Insurance_Confirmation_Y_N__c == False){
        creditLimitInfo.CreditInsuranceConfirmation = '0';
        //}

        String CreditGuaranteeConfirmationBankSWIFTVar ;
        String CreditGuaranteeConfirmationBankSWIFTTmp =  creditLimit.Credit_Insurance_Confirmation_Bank_SWIFT__c;
        if(creditLimit.Credit_Insurance_Confirmation_Bank_SWIFT__c == null){
          CreditGuaranteeConfirmationBankSWIFTVar = '';
        }else{
          //拼接 CreditGuaranteeIssuingBankSWIFT 如果是8位： AAA BBB CC XXX  如果是11位： AAA BBB CC DDD
          if(CreditGuaranteeConfirmationBankSWIFTTmp.length() == 8){
            CreditGuaranteeConfirmationBankSWIFTVar = CreditGuaranteeConfirmationBankSWIFTTmp.substring(0,4) + ' ' + CreditGuaranteeConfirmationBankSWIFTTmp.substring(4,6) + ' ' +CreditGuaranteeConfirmationBankSWIFTTmp.substring(6,8) + ' ' + 'XXX';
          }else if(CreditGuaranteeConfirmationBankSWIFTTmp.length() == 11){
            CreditGuaranteeConfirmationBankSWIFTVar = CreditGuaranteeConfirmationBankSWIFTTmp.substring(0,4) + ' ' + CreditGuaranteeConfirmationBankSWIFTTmp.substring(4,6) + ' ' +CreditGuaranteeConfirmationBankSWIFTTmp.substring(6,8) + ' ' + CreditGuaranteeConfirmationBankSWIFTTmp.substring(8,11);
          }
        }

        creditLimitInfo.CreditInsuranceConfirmationBankSWIFT = CreditGuaranteeConfirmationBankSWIFTVar;
        creditLimitInfo.ConfirmationBankEnglishName = creditLimit.Confirmation_Bank_English_Name__c == null ? '' : creditLimit.Confirmation_Bank_English_Name__c;
        creditLimitInfo.ConfirmedBankCountryCode = creditLimit.Confirmed_Bank_Country_Code__c == null ? '' : countryId2CodeMap.get(creditLimit.Confirmed_Bank_Country_Code__c);
        creditLimitInfo.ConfirmingBankEnglishAddress = creditLimit.Confirming_Bank_Address_English__c == null ? '' : creditLimit.Confirming_Bank_Address_English__c;
        creditLimitInfo.DirectSalesDepartmentLocation = creditLimit.Direct_Sales_Department_Location__c == null ? '' : creditLimit.Direct_Sales_Department_Location__c;
        creditLimitInfo.RecordSubmittedDate = System.now() + '';
        //get Approval Line Information
        creditLimitInfo.ApprovalInformationList = new List<ApprovalInformation>();
        if (!creditLimit.ProcessSteps.isEmpty() & creditLimit.ProcessSteps != null) {
          for (ProcessInstanceHistory processStepItem1 : creditLimit.ProcessSteps) {
            ApprovalInformation approvalInfo = new  ApprovalInformation();
            approvalInfo.Approver = userId2UserNameMap.get(processStepItem1.ActorId) == null ? '' : userId2UserNameMap.get(processStepItem1.ActorId);
            approvalInfo.ApprovedResult = processStepItem1.StepStatus == null ? '' : processStepItem1.StepStatus;
            // approvalInfo.ApprovedTime = processStepItem1.CreatedDate == null ? '' : processStepItem1.CreatedDate + '';
            if(processStepItem1.CreatedDate != null){
              Timezone tz = Timezone.getTimeZone('Asia/Shanghai');
              approvalInfo.ApprovedTime = Datetime.valueOf(processStepItem1.CreatedDate).addSeconds(tz.getOffset(processStepItem1.CreatedDate)/1000) + '';
            }
            approvalInfo.ApproverEmail = userId2EmailMap.get(processStepItem1.ActorId) == null ? '' : userId2EmailMap.get(processStepItem1.ActorId);
            approvalInfo.ApproverRemark = processStepItem1.Comments == null ? '' : processStepItem1.Comments+'';
            creditLimitInfo.ApprovalInformationList.add(approvalInfo);  
          }
        }

        //get AttachURL Information
        //拼接附件URL
        creditLimitInfo.AttachmentListToRR = new List<AttachmentInformation>();
        if (!creditLimit.AttachedContentDocuments.isEmpty() & creditLimit.AttachedContentDocuments != null) {
          for (AttachedContentDocument attachment : creditLimit.AttachedContentDocuments) {
            AttachmentInformation attachmentInfoVar = new AttachmentInformation();
            attachmentInfoVar.AttachmentLink = Label.AttachFileDomain + '/lightning/r/' + attachment.ContentDocumentId + '/view';
            attachmentInfoVar.AttachmentName = attachment.Title;
            creditLimitInfo.AttachmentListToRR.add(attachmentInfoVar);  
          }
        }
      }


      String body = JSON.serialize(creditLimitInfo);
      System.debug('body:: '+body);

      ResDeta input = new ResDeta();
      String bodyRes;
      try {
        Blob headerValue = Blob.valueOf(user + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
      //登陆获取token
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http_login = new Http();    
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(body);
      request.setTimeout(120000); // timeout in milliseconds
      System.debug('request::: '+request);
      response = http_login.send(request);

      bodyRes = response.getBody();
      System.debug('bodyRes:' + bodyRes);
      //bodyRes = 'aaaaaaa';
      SyncCustomerCreditInfoToRR.ResDeta input_login = new SyncCustomerCreditInfoToRR.ResDeta();
      input_login =(SyncCustomerCreditInfoToRR.ResDeta)JSON.deserialize(bodyRes,SyncCustomerCreditInfoToRR.ResDeta.class );
      sYSTEM.debug('input_login... '+input_login);
      //handle log
      if(input_login.IsSuccess == 'True'){
        //log
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SyncCustomerCreditInfoToRR';
        ic.Time__c = System.Now();
        ic.ReturnCode__c = '1';
        ic.Req_Json__c = body;
        ic.Res_Json__c = bodyRes;
        ic.ErrorMsg__c = '';
        insert ic;
        return; 
      } else {
        //log
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SyncCustomerCreditInfoToRR';
        ic.Time__c = System.Now();
        ic.ReturnCode__c = '0';
        ic.Req_Json__c = body;
        ic.Res_Json__c = bodyRes;
        ic.ErrorMsg__c = input_login.FailReason;
        insert ic;
        List<Credit_Limit_Application__c> creditLimitApplicationListVar = new List<Credit_Limit_Application__c>();
        creditLimitApplicationListVar.add(creditLimit);
        System.debug('creditLimit... '+creditLimit);
        //如果程序报错，给对应的提交者发邮件
        sendingEmail2Submitter(creditLimitApplicationListVar);
        return;  
      }
    }
    catch (Exception e) {
      //Integration Log
      InterfaceLog__c ic = new InterfaceLog__c();
      ic.Class__c = 'SyncCustomerCreditInfoToRR';
      ic.Time__c = System.Now();
      ic.ReturnCode__c = '0';
      ic.Req_Json__c = body;
      ic.Res_Json__c = '';
      ic.ErrorMsg__c = 'failure: SF Sync Credit Information to RR Failed! '+e.getMessage() + '--' + e.getLineNumber();
      insert ic;
      List<Credit_Limit_Application__c> creditLimitApplicationListVar = new List<Credit_Limit_Application__c>();
      creditLimitApplicationListVar.add(creditLimit);
      System.debug('creditLimit... '+creditLimit);
      //如果程序报错，给对应的提交者发邮件
      //sendingEmail2Submitter(creditLimitApplicationListVar);
      return; 
    }
  }
  private static void sendingEmail2Submitter(List<Credit_Limit_Application__c> creditLimitApplicationList){
        //System.debug('customerInfoListcustomerInfoList:: '+customerInfoList);
    String submitterId = creditLimitApplicationList[0].CreatedById;
    User submitter = [select Id,Name,Email from User where Id =: submitterId limit 1];
    System.debug('submitter...'+submitter);
    List<String> pIdList = new List<String>();
    for(Profile p : [select id,name from Profile where name in ('System Admin','System Administrator')]){
        pIdList.add(p.Id);
    }

    List<string> emailList = new List<string>();
    emailList.add(submitter.Email);
    for(User u : [select Id,Name,Email from User where ProfileId in: pIdList]){
      if(u.Email.equals('sanghong@hisense.com') || u.Email.equals('syssfcrm@hisense.com')){
        emailList.add(u.Email);
      }  
    } 

    String creditLimitApplicationId = creditLimitApplicationList[0].Id;
    Credit_Limit_Application__c clac = [select Id,Name from Credit_Limit_Application__c where Id =: creditLimitApplicationId limit 1];

        //Email list
    Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
        //for(Credit_Limit_Application__c gcici : creditLimitApplicationList){
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //String emailBody = '<span style="display: inline-block; width:28px;"></span>Dear [' + operationUser.Name + ']，<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Below Customer has already been created in SAP, [' + visitParticipant.Visit_Record_Name__c + ']&nbsp;&nbsp;(On &nbsp;&nbsp;&nbsp;[' + visitParticipant.Visit_Date__c + '] ) has already been reached, Please take action in time!';
    String emailBody = '<span style="display: inline-block; width:28px;"></span> ' + Label.Email_Title + submitter.Name + '，<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Credit Limit : [' + clac.Name + ']&nbsp;&nbsp;&nbsp; '+ Label.CreditLimit_Sync_Fail;
    mail.setToAddresses(emailList);
    mail.setSenderDisplayName('CRM System Reminder');
    mail.setSubject('Credit Limit Application Synced to RR System Failed!');
    mail.setHtmlBody(emailBody);
    theEmails.add(mail);
        //}
    Messaging.Email[] allMails = new Messaging.Email[]{};
    for(Integer j = 0; j < theEmails.size(); j++) {
      allMails.add(theEmails.get(j));
    }

    System.debug('allMails:: '+allMails);
        // Print error information
    Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
    System.debug('results... '+results);
    Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
    String emailErrorReport = '';
    for(Messaging.SendEmailResult currentResult : results) {
      errors = currentResult.getErrors();
      if(null != errors) {
        for(Messaging.SendEmailError currentError : errors) {
          emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
          System.debug('emailErrorReport... '+emailErrorReport);
        }
      }
    }
  }
}