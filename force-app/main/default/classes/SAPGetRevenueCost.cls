/**********************************************************************
* Name: SAPGetRevenueCost
* Object: SAP Cost Revenue Data 
* Purpose: 
* SAP中的收入相关信息定时的传递给salesforce
* Author: Gerry
* Create Date: 2019-03-04
*************************************************************************/
public with sharing class SAPGetRevenueCost {

  private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_COSTINFO_SEND';
  private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
  private static String password = Interface_Url__c.getValues('SAP').Password__c;

  public class RevenueCostInfoOutput{
    public List<String> CompanyCodeList;                  //公司代码代码列表
    public String Year;                            //年份
    public String Month;                          //月份
  }

  public class RevenueCostInfoInput{
    public String IsSuccess;  
    public String FailReason;                      //是否成功
    public List<FinanceInfo> FinanceInfoList;                  
  }

  public class FinanceInfo{
    public String CompanyCode;                        //公司代码
    public String Year;                            //年份
    public String Month;                          //月份
    public String BusinessScope;                      //业务范围
    public String SapCustomerCode;                      //SAP客户编码
    //json串中的key为‘currency’，但是与系统中标识符重复
    public String SFCurrency;                          //币种
    public String SalesVolume;                        //销量
    public String SalesRevenue;                        //销售收入
    public String Cost;                            //成本
    public String Brand;                            //品牌  Roy Added on 20190711
    public String SalesGrossRevenue;
  }


  //测试数据
  //2018 12 8040
  //2018 10 8040
  //2018 08 8040
  //2018 02 8510 8040

  @Future(callout =true)
  public static void GetRevenueCostInfoFromSAP(List<String> companyCodeList,String year,String month){
  //public static void GetRevenueCostInfoFromSAP(){  
    RevenueCostInfoOutput out = new RevenueCostInfoOutput();
    out.CompanyCodeList = companyCodeList;
    out.Year = year;
    out.Month = month;
    String body = JSON.serialize(out);
    //String body = '{"CompanyCodeList": ["8500"],"Year": "2018","Month": "02"}';
    //String body = '{"CompanyCodeList": ["8040"],"Year": "2018","Month": "12"}';
    //String body = '{"CompanyCodeList": ["8510"],"Year": "2018","Month": "02"}';
    String bodyRes;
    RevenueCostInfoInput input;
    try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
          String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
      //信息同步
      HttpRequest req = new HttpRequest();
          HttpResponse res = new HttpResponse();
          Http http = new Http();              
          req.setEndpoint(url);
          req.setMethod('POST');
          req.setHeader('Content-Type', 'application/json');
          req.setHeader('Authorization', authorizationHeader);
          req.setBody(body);
          req.setTimeout(120000); // timeout in milliseconds
          res = http.send(req);
          bodyRes = res.getBody();
          System.debug('bodyRes:' + bodyRes);
          input= (SAPGetRevenueCost.RevenueCostInfoInput)JSON.deserialize(bodyRes, SAPGetRevenueCost.RevenueCostInfoInput.class);
    }
    catch (Exception e) {
        //日志内容
        String errorMsg = 'sfdc调用获取收入信息接口失败'+e.getMessage();
        Utility.insertLog('SAPGetRevenueCost', '0', body, errorMsg);
          return;
    }

    if (input.IsSuccess == 'False') {
      //日志内容
      Utility.insertLog('SAPGetRevenueCost', '0', body, input.FailReason);
      return;
    }
    
    //System.debug('input.FinanceInfoList:: '+input.FinanceInfoList);
    //添加数据
    if (!(input.FinanceInfoList == null || input.FinanceInfoList.isEmpty())) {
      System.debug('aaaaaaaaaaaa');
      List<SAP_Cost_Revenue_Data__c> costRevenueDataList = new List<SAP_Cost_Revenue_Data__c>();
      List<String> crDataListWithoutProductLine = new List<String>();//没找到客户产品线的收入成本数据
      try{
        //businessscope集合
        Set<String> mpCode = new Set<String>();
        //公司编码的集合
        Set<String> customerCodeSet = new Set<String>();
        //获取所有的code值
        for (FinanceInfo info : input.FinanceInfoList) {
          mpCode.add(info.BusinessScope);
          mpCode.add(info.CompanyCode);
          mpCode.add(info.Brand);
          customerCodeSet.add(info.SapCustomerCode);
        }

        Map<String,List<Mapping__c>> mpMap = new Map<String,List<Mapping__c>>();
        Map<String,String> brandCode2NameMap = new Map<String,String>();
        for (Mapping__c mp : [SELECT Id,Name,Original_Code_Ext_Code__c,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c WHERE Name IN :mpCode]) {
          brandCode2NameMap.put(mp.Original_Code_Ext_Code__c,mp.Mapping_Code__c);
          if (mpMap.containsKey(mp.Name)) {
            mpMap.get(mp.Name).add(mp);
          }else{
            mpMap.put(mp.Name, new List<Mapping__c>{mp});
          }
        }

        Map<String,ID> customerMap = new Map<String,ID>();
        Set<String> accIdSet = new Set<String>();
        for (Account acc : [SELECT ID,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c IN :customerCodeSet]) {
          customerMap.put(acc.SAP_Customer_Code__c, acc.Id);
          accIdSet.add(acc.Id);
        }

        //Adding management user SAP code --- Roy 20190411 
        Set<String> managementUserSAPCodeSet = new Set<String>();
        Map<String,String> customerSAPCode2IdMap = new Map<String,String>();
        managementUserSAPCodeSet.add(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Austrilia_Company);
        managementUserSAPCodeSet.add(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Malaysia_Company);
        managementUserSAPCodeSet.add(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Mexico_Company);
        managementUserSAPCodeSet.add(Label.CUSTOMER_SAP_CODEManagement_Customer_Revenue_Cost_Usage_South_Africa_Company);
        managementUserSAPCodeSet.add(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_USA_Company);
        //map management user SAP code 2 Id --- Roy 20190411
        for (Account acc : [SELECT ID,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c IN :managementUserSAPCodeSet]) {
          customerSAPCode2IdMap.put(acc.SAP_Customer_Code__c, acc.Id);
        }

        Map<String,ID> cplIdMap = new Map<String,ID>();
        for (Customer_Product_Line__c cpl : [SELECT Id,Customer__c,Product_Line_Name__c FROM Customer_Product_Line__c WHERE Customer__c IN :accIdSet]) {
          cplIdMap.put(cpl.Customer__c+cpl.Product_Line_Name__c, cpl.Id);
        }
        Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();//Last modified by johnson20190711
        Decimal rate;
        for (FinanceInfo info : input.FinanceInfoList) {
          SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
          costRevenueData.Hisense_Entity__c = info.CompanyCode;
          costRevenueData.Interface_Business_Scope__c = info.BusinessScope;
          if (!String.isBlank(info.CompanyCode)&&mpMap.get(info.CompanyCode)!=null) {
            for (Mapping__c mp : mpMap.get(info.CompanyCode)) {

              if (mp.RecordType.DeveloperName.equals(Label.Business_Orgnization_and_Name_Mapping)) {
                costRevenueData.Company_Code__c = mp.Id;
                break;
              }
            }
          }
          
          String productLine;
          if (!String.isBlank(info.BusinessScope)&&mpMap.get(info.BusinessScope)!=null) {
            for (Mapping__c mp : mpMap.get(info.BusinessScope)) {
              if (mp.RecordType.DeveloperName.equals(Label.Business_Scope_and_Product_Line_Mapping)) {
                costRevenueData.Business_Scope__c = mp.Id;
                productLine = mp.Mapping_Code__c;
                break;
              }
            }
          }
          
          
          if(!info.SFCurrency.equals('USD')){
            rate = currencyRateMap.get(info.SFCurrency+ info.Year + info.Month);//Last modified by johnson20190711
            if(Test.isRunningTest()){
                            rate = 1;
            }
            costRevenueData.Sales_Gross_Revenue_USD__c = Decimal.valueOf(String.isBlank(info.SalesGrossRevenue)? '0':info.SalesGrossRevenue) / rate;
            costRevenueData.Sales_Revenue_USD__c = Decimal.valueOf(String.isBlank(info.SalesRevenue)? '0':info.SalesRevenue) / rate;
            costRevenueData.Cost_USD__c = Decimal.valueOf(String.isBlank(info.Cost)? '0':info.Cost) / rate;
          }else{
            costRevenueData.Sales_Gross_Revenue_USD__c = Decimal.valueOf(String.isBlank(info.SalesGrossRevenue)? '0':info.SalesGrossRevenue);
            costRevenueData.Sales_Revenue_USD__c = Decimal.valueOf(String.isBlank(info.SalesRevenue)? '0':info.SalesRevenue);
            costRevenueData.Cost_USD__c = Decimal.valueOf(String.isBlank(info.Cost)? '0':info.Cost);
          }
          costRevenueData.Sales_Gross_Revenue__c = Decimal.valueOf(String.isBlank(info.SalesGrossRevenue)? '0':info.SalesGrossRevenue);
          costRevenueData.Sales_Revenue__c = Decimal.valueOf(String.isBlank(info.SalesRevenue)? '0':info.SalesRevenue);
          costRevenueData.Cost__c = Decimal.valueOf(String.isBlank(info.Cost)? '0':info.Cost);
          costRevenueData.Sales_Volume__c = Decimal.valueOf(String.isBlank(info.SalesVolume)? '0':info.SalesVolume);
          if (String.isNotBlank(info.SapCustomerCode)) {
            costRevenueData.Customer__c = customerMap.get(info.SapCustomerCode);
            costRevenueData.SAPCode_SF_Usage__c = info.SapCustomerCode;
          }else{
            if('8140'.equals(info.CompanyCode)){//Mexico
              costRevenueData.Customer__c = customerSAPCode2IdMap.get(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Mexico_Company);
            }else if('8110'.equals(info.CompanyCode)){//USA
              costRevenueData.Customer__c = customerSAPCode2IdMap.get(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_USA_Company);
            }else if('8400'.equals(info.CompanyCode)){//Malaysia
              costRevenueData.Customer__c = customerSAPCode2IdMap.get(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Malaysia_Company);
            }else if('8200'.equals(info.CompanyCode)){//Austrilia
              costRevenueData.Customer__c = customerSAPCode2IdMap.get(Label.CUSTOMER_SAP_CODE_Management_Customer_Revenue_Cost_Usage_Austrilia_Company);
            }else if('8500'.equals(info.CompanyCode) || '8510'.equals(info.CompanyCode)){//South Africa
              costRevenueData.Customer__c = customerSAPCode2IdMap.get(Label.CUSTOMER_SAP_CODEManagement_Customer_Revenue_Cost_Usage_South_Africa_Company);
            }
          }
          costRevenueData.Customer_Product_Line__c = cplIdMap.get(costRevenueData.Customer__c+productLine);
          costRevenueData.CurrencyIsoCode = info.SFCurrency;
          costRevenueData.Year__c = info.Year;
          costRevenueData.Month__c = info.Month;
          costRevenueData.Brand__c = brandCode2NameMap.get(info.Brand);
          //System.debug('aaaaaaaaaaa:   '+brandCode2NameMap.get(info.Brand));
          if(cplIdMap.get(costRevenueData.Customer__c+productLine) == null 
          && String.isNotBlank(productLine) 
          && String.isNotBlank(info.SapCustomerCode)){
            costRevenueData.Product_Line_Text__c = info.SapCustomerCode + '_' + productLine;
                        crDataListWithoutProductLine.add('客户代码：' + info.SapCustomerCode + '; 产品线：' +productLine);
          }
          //System.debug('ANY ocostRevenueData  '+costRevenueData);
          costRevenueDataList.add(costRevenueData);
        }
        //System.debug('costRevenueDataList.......... '+costRevenueDataList);
        if(crDataListWithoutProductLine.size() > 0){
          //生成Log，通过相关工作流提醒管理员有收入成本数据没找到产品线
          Utility.insertLog('SAPGetRevenueCost', '0', JSON.serialize(crDataListWithoutProductLine), Label.SAP_Cost_Revenue_Cannot_Find_Customer_Or_Product_Line);
        }
        Database.insert(costRevenueDataList);
      }catch(Exception e){
        //日志内容
        String errorMsg = '新建数据出错'+e.getMessage()+e.getLineNumber();
        Utility.insertLog('SAPGetRevenueCost', '0', body, errorMsg);
            return;
      }
      //日志内容
      Utility.insertLog('SAPGetRevenueCost', '1', body, null);
    }
  }  
}