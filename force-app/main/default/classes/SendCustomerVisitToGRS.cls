/**********************************************************************
 * function:传客户拜访信息到GRS
 * @author:Yanhao
 * @url: /services/apexrest/rest
 * @data: Customer_Visit__c
 * date:2020-05
 *************************************************************************/
//sendCustomerVisitToGRS
@RestResource(urlMapping='/sendCustomerVisitToGRS')
global with sharing class SendCustomerVisitToGRS {

global class AppInput {
//inventoryReportData
//传入开始和结束日期
/*
String startDate;
String endDate;
String cvCode;
*/
String START_DATE;
String END_DATE;
String CV_CODE;

}

global class AppOutPut {
//返回Customer Visti List
List<CustomerVistiList> CustomerVistiList;
}

global class CustomerVistiList {
public String VisitCode;
public String CustomerName;
public String VisitName;
public String VisitLink;
}

global class StartEndDate {
public String startDate;
public String endDate;
}

@HttpPost
//global static GetACProductFromGSS.AppOutPut adoPost() {
global static SendCustomerVisitToGRS.AppOutPut adoPost() {
    //SendCustomerVisitToGRS
    RestRequest req = RestContext.request;
    String reqBody = req.requestBody.tostring();

    //Test
    //reqBody = '{"startDate": "2019-01-01","endDate": "2019-01-01"}';
    system.debug('doPost now, req : ' + req);
    system.debug('doPost now, body : ' + reqBody);

    AppInput input = new AppInput();
    SendCustomerVisitToGRS.AppOutPut result = new SendCustomerVisitToGRS.AppOutPut();
    //DateJsonSerializer
    // String outPutString = (SendCustomerVisitToGRS.AppInput) JSON.deserialize(reqBody, SendCustomerVisitToGRS.AppInput.class);
    try{
        input = (SendCustomerVisitToGRS.AppInput) JSON.deserialize(reqBody, SendCustomerVisitToGRS.AppInput.class);

        System.debug('input===>:' + input);
        //空数据
        //input.startDate = '20190101';
        //input.endDate = '20190101';
 
        //当只传cvCode, 
        if ((input.START_DATE == null || input.START_DATE == '') && (input.END_DATE == null || input.END_DATE == '') && (input.CV_CODE != null || input.CV_CODE != '')) {


            String startDateString = input.START_DATE;
            String endDateString = input.END_DATE;
            String cvCode = input.CV_CODE;

            string URLString = 'https://hisenseint.my.salesforce.com/';
            String querySql = 'SELECT id,name,Customer_Visit_Code__c, Customer__r.name  from Customer_Visit__c where Customer_Visit_Code__c  = \''  + cvCode +  '\'';

            List<Customer_Visit__c> cusVisitList = Database.query(querySql);

            List<CustomerVistiList> CVList = new List<CustomerVistiList>();//创建一个空List

            for (Customer_Visit__c cusVisitData : cusVisitList) {
                CustomerVistiList outputData = new CustomerVistiList();//实例化outputData
                outputData.VisitCode = cusVisitData.Customer_Visit_Code__c   == null ? '' : cusVisitData.Customer_Visit_Code__c;
                outputData.VisitName = cusVisitData.name   == null ? '' : cusVisitData.name;
                outputData.CustomerName = cusVisitData.Customer__r.name   == null ? '' : cusVisitData.Customer__r.name;
                outputData.VisitLink = URLString + cusVisitData.id;
                CVList.add(outputData);
            }

            result.CustomerVistiList = CVList;

            //如果 CVList 是空，则返回个空结构
            if(CVList.size() == 0) {
                CustomerVistiList outputData = new CustomerVistiList();
                outputData.VisitCode = '';
                outputData.CustomerName = '';
                outputData.VisitName = '';
                outputData.VisitLink = '';
                CVList.add(outputData);
                result.CustomerVistiList = CVList;
            }


            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerVisitToGRS';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            ic.Res_Json__c = JSON.serialize(result);
            ic.ErrorMsg__c = '';
            insert ic;
            System.debug(result);
            return result;
        }


        //当只传日期，cvCode为空时
        else if ((input.START_DATE != null && input.START_DATE != '') && (input.END_DATE != null && input.END_DATE != '') && (input.CV_CODE == null || input.CV_CODE == '')){
            //日期转换

            String startDateString = input.START_DATE;
            String endDateString = input.END_DATE;
            //Date completeDateStart = Date.valueOf(startDateString);
            //Date completeDateEnd = Date.valueOf(endDateString);

            string URLString = 'https://hisenseint.my.salesforce.com/';
            String querySql = 'SELECT id,name,Customer_Visit_Code__c, Customer__r.name  from Customer_Visit__c where Status__c  = \'Completed\'  and (VisitCompletedDate__c <= ' + endDateString +') and (VisitCompletedDate__c >=' + startDateString +' )';

            List<Customer_Visit__c> cusVisitList = Database.query(querySql);

            List<CustomerVistiList> CVList = new List<CustomerVistiList>();//创建一个空List

            for (Customer_Visit__c cusVisitData : cusVisitList) {
                CustomerVistiList outputData = new CustomerVistiList();//实例化outputData
                outputData.VisitCode = cusVisitData.Customer_Visit_Code__c   == null ? '' : cusVisitData.Customer_Visit_Code__c;
                outputData.VisitName = cusVisitData.name   == null ? '' : cusVisitData.name;
                outputData.CustomerName = cusVisitData.Customer__r.name   == null ? '' : cusVisitData.Customer__r.name;
                outputData.VisitLink = URLString + cusVisitData.id;
                CVList.add(outputData);
            }

            result.CustomerVistiList = CVList;

            //如果 CVList 是空，则返回个空结构
            if(CVList.size() == 0) {
                CustomerVistiList outputData = new CustomerVistiList();
                outputData.VisitCode = '';
                outputData.CustomerName = '';
                outputData.VisitName = '';
                outputData.VisitLink = '';
                CVList.add(outputData);
                result.CustomerVistiList = CVList;
            }


            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendCustomerVisitToGRS';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            ic.Res_Json__c = JSON.serialize(result);
            ic.ErrorMsg__c = '';
            insert ic;
            System.debug(result);
            return result;

        }


        //全是空时
        //else if ((input.startDate == null || input.startDate == '') && (input.endDate == null || input.endDate == '') && (input.cvCode == null || input.cvCode == '')) {
        else{ 

            //result.IsSuccess = 'False';
            //result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
            List<CustomerVistiList> CVList = new List<CustomerVistiList>();
            CustomerVistiList outputData = new CustomerVistiList();
            outputData.VisitCode = 'Input Date Error';
            outputData.CustomerName = 'Input Date Error';
            outputData.VisitName = 'Input Date Error';
            outputData.VisitLink = 'Input Date Error';
            CVList.add(outputData);//传入为空的时候
            result.CustomerVistiList = CVList;

            return result;
        }




        //错误数据
    }catch(Exception e) {
        System.debug(e.getMessage()+e.getLineNumber());
        //日志内容
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SendCustomerVisitToGRS';
        ic.Time__c = System.Now();
        ic.ReturnCode__c = '0';
        ic.Req_Json__c = reqBody;
        ic.Res_Json__c = JSON.serialize(result);
        ic.ErrorMsg__c = e.getMessage()+ ';The Line Number is:' +e.getLineNumber();
        insert ic;
        //
        List<CustomerVistiList> CVList = new List<CustomerVistiList>();
        CustomerVistiList outputData = new CustomerVistiList();
        outputData.VisitCode = 'Erro:' + e.getMessage()+ ';The Line Number is:' +e.getLineNumber();
        outputData.CustomerName = 'Error:' + e.getMessage()+ ';The Line Number is:' +e.getLineNumber();
        outputData.VisitName = 'Error:' + e.getMessage()+ ';The Line Number is:' +e.getLineNumber();
        outputData.VisitLink = 'Error:' + e.getMessage()+ ';The Line Number is:' +e.getLineNumber();
        CVList.add(outputData);        //传入报错时候
        result.CustomerVistiList = CVList;

        return result;
    }

}

}