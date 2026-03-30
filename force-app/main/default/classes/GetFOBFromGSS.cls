/**********************************************************************
 * function:获取来自GSS系统的FOB信息
 * @author:wfc
 * @url: /services/apexrest/rest
 * @data: FOB
 * date:2021-09-28
*************************************************************************/
@RestResource(urlMapping='/getFOBFromGSS')
global with sharing class GetFOBFromGSS {

    global class AppInput{
        List<FOBList> FOBDataList;
    }
    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }
    global class FOBList{
        public String BatchNumber;
        public String RequestFactoryFinishDate;
        public String ActualFactoryFinishDate;
        public String ContainerNumber;
        public String ProductLine;
    }   
      
    @HttpPost
    global static GetFOBFromGSS.AppOutPut doPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 

        AppInput input = new AppInput();
        GetFOBFromGSS.AppOutPut result = new GetFOBFromGSS.AppOutPut();
        try{
            input = (GetFOBFromGSS.AppInput) JSON.deserialize(reqBody, GetFOBFromGSS.AppInput.class);
            Integer i = 0;
            Integer j = 0;
            //空数据
            if (input.FOBDataList == null || input.FOBDataList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{
                List<FOB_GSS__c> fobGSSList = new List<FOB_GSS__c>();
                for(FOBList fobList : input.FOBDataList){
                    i++;
                    j++;
                    FOB_GSS__c fobGSS = new FOB_GSS__c();
                    fobGSS.Batch_Number__c = fobList.BatchNumber;
                    fobGSS.Actual_Factory_Finish_Date__c = toDate(fobList.ActualFactoryFinishDate);
                    fobGSS.Container_Number__c = fobList.ContainerNumber;
                    fobGSS.Request_Factory_Finish_Date__c = toDate(fobList.RequestFactoryFinishDate);
                    fobGSS.Product_Line_Code__c = fobList.ProductLine;
                    fobGSSList.add(fobGSS);
                    if((i == 8000 || j == input.FOBDataList.size() ) && !Test.isRunningTest()){
                        // List<Database.upsertResult> resultsOrder = Database.upsert(fobGSSList,FOB_GSS__c.Fields.Batch_Number__c,false);
                        //进行另一个异步处理
                        GetFOBFromGSSSecond getFOBFromGSSProduct = new GetFOBFromGSSSecond(fobGSSList);
                        ID jobID = System.enqueueJob(getFOBFromGSSProduct);
                        i = 1;
                        fobGSSList.clear();
                    }
                }

                result.IsSuccess = 'true';
                result.FailReason = '';
                return result;
            }
        //错误数据   
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            //日志内容
            Utility.insertLog('GetFOBFromGSS', '0', null, e.getMessage());
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;
        }
        
    }

    //修复日期问题
    private static Date toDate(String text){
        if(String.isNotBlank(text)){
            if(Integer.valueOf(text.replace('-', '')) == 0){
                return null;
            }
            return Date.valueOf(text);
            // String regExp = '\\d{8}';
            // if(Pattern.matches(regExp, text)){
            //     if(Integer.valueOf(text) == 0){
            //         return null;
            //     }
            //     Integer year = Integer.valueOf(text.left(4));
            //     Integer month = Integer.valueOf(text.substring(4, 6));
            //     Integer day = Integer.valueOf(text.right(2));
            //     return Date.newInstance(year, month, day);
            // } else {
            //     return null;
            // }
        }
        return null;
    }
}