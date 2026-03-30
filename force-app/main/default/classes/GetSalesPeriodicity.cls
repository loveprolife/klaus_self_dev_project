/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/GetSales')
global with sharing class GetSalesPeriodicity {

    global class SFInput{
        public String productLine;//分解后需要用逗号隔开
        public String salesRegion;
        public String startDate;
        public String endDate;
        public Date startDay{
            get{
                if(String.isNotBlank(this.startDate)) {
                    return Date.valueOf(startDate);
                }
                return null;
            }
        }

        public Date endDay{
            get{
                if(String.isNotBlank(this.endDate)) {
                    return Date.valueOf(endDate);
                }
                return null;
            }
        }

        public List<String> productLines{
            get{
                if(String.isNotBlank(this.productLine)){
                    return this.productLine.split(',|;');
                }
                return null;
            }
        }
    }

    global class SFOutputResult{

        SFOutputResult(){
            this.isSuccess = true;
        }

        SFOutputResult(Boolean isSuccess, String failReason){
            this.isSuccess = isSuccess;
            this.failReason = failReason;
        }

        public Boolean isSuccess;
        public String failReason;
        public List<Sales> data{set;get;}
    }

    global class Sales{
        public Sales(Sales__c acc){
            this.sapCode = acc.Customer__r.SAP_Customer_Code__c;
            this.productLine = acc.Product_Line__c;
            this.ssoName = acc.Sales__r.HisenseSSOName__c;
            this.createdDate = acc.LastModifiedDate.format('yyyy-MM-dd hh:mm:ss');
            //Roy updated
            //this.shortName = acc.Customer__r.Customer_Short_Name__c;
            
            
        }
        public String sapCode{set;get;}
        public String productLine{set;get;}
        public String ssoName{set;get;}
        public String createdDate{set;get;}
        //public String shortName{set;get;}
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type','application/json;charset=UTF-8');

        String reqBody = req.requestBody.tostring(); 
        System.debug('Received input:'+reqBody);
        if(String.isNotBlank(reqBody)){
            SFInput input = (SFInput) Json.deserialize(reqBody, SFInput.class);
            System.debug(Json.serialize(input));
            SFOutputResult result = validateInput(input);

            if(result.isSuccess) {
                String inputProductLine = '';
                String []inputProductLines = input.productLine.split(',');
                Set<String> inputProductLineSet = new Set<String>(inputProductLines);
                for(String s: inputProductLineSet){
                    inputProductLine += '\''+s+'\',';
                }
                result.failReason = null;

                Date endDay = input.endDay;
                Date startDay = input.startDay;
                String salesRegion = input.salesRegion;
                String sosql = 'SELECT Id,Name,Customer__r.SAP_Customer_Code__c,Customer__r.Sales_Region__c,'+
                        'Customer__r.Customer_SF_Code__c,CreatedDate,LastModifiedDate,Product_Line__c,'+
                        //'Sales__c,Sales__r.HisenseSSOName__c,IsKeyUser__c,Customer__r.Customer_Short_Name__c '+
                        'Sales__c,Sales__r.HisenseSSOName__c,IsKeyUser__c '+
                        'FROM Sales__c '+
                        'WHERE LastModifiedDate < :endDay '+
                        'AND LastModifiedDate >= :startDay '+
                        'AND Customer__r.Sales_Region__c = :salesRegion '+
                        'AND Product_Line__c includes ('+inputProductLine.removeEnd(',')+') '+
                        'ORDER BY LastModifiedDate';

                List<Sales__c> accs = Database.query(sosql);
                /*List<Sales__c> accs = [
                    SELECT Id,Name,Customer__r.SAP_Customer_Code__c,Customer__r.Sales_Region__c,
                        Customer__r.Customer_SF_Code__c,CreatedDate,Product_Line__c,
                        Sales__c,Sales__r.HisenseSSOName__c,IsKeyUser__c
                    FROM Sales__c
                    WHERE CreatedDate < :input.endDay
                    AND CreatedDate >= :input.startDay
                    AND Customer__r.Sales_Region__c = :input.salesRegion
                    AND Product_Line__c includes (:inputProductLine.removeEnd(','))
                    ORDER BY CreatedDate
                ];*/
                if(!accs.isEmpty()){
                    Map<String, Sales__c> salesMap = new Map<String, Sales__c>();

                    result.data = new List<Sales>();
                    for(Sales__c acc: accs){
                        if(String.isBlank(acc.Customer__r.SAP_Customer_Code__c)){
                            continue;
                        }
                        String [] productLines = acc.Product_Line__c.split(';|,');
                        for(String productLine:productLines){
                            if(!inputProductLineSet.contains(productLine)){
                                continue;
                            }
                            //SAP Code + ProductLine为 key
                            String key = acc.Customer__r.SAP_Customer_Code__c+'_'+productLine;
                            Sales__c s = salesMap.get(key);
                            if(s!=null){
                                if(acc.IsKeyUser__c == true){
                                    salesMap.put(key, acc);
                                }
                            } else{
                                salesMap.put(key, acc);
                            }
                        }
                        
                    }

                    for(String key: salesMap.keySet()){
                        Sales__c s = salesMap.get(key);
                        Sales cus = new Sales(s);
                        cus.productLine = key.substring(key.indexOf('_')+1,key.length());
                        result.data.add(cus);
                    }
                }
            } 
            res.responseBody = Blob.valueOf(JSON.serialize(result));
        } else {
            SFOutputResult result = new SFOutputResult(false, '传入入参不正确！');
            res.responseBody = Blob.valueOf(JSON.serialize(result));
        }
    }

    public static SFOutputResult validateInput(SFInput input){
        SFOutputResult result = new SFOutputResult();
        result.failReason = '';
        if(input == null){
            result.isSuccess = false;
            result.failReason = '传入入参不正确！';
        } else {
            if(String.isBlank(input.productLine)){
                result.isSuccess = false;
                result.failReason += 'productLine 字段缺失！';
            }
            if(String.isBlank(input.salesRegion)){
                result.isSuccess = false;
                result.failReason += 'salesRegion 字段缺失！';
            }
            if(String.isBlank(input.startDate)){
                result.isSuccess = false;
                result.failReason += 'startDate 字段缺失！';
            }
            if(String.isBlank(input.endDate)){
                result.isSuccess = false;
                result.failReason += 'endDate 字段缺失！';
            }
            if(input.endDay <= input.startDay){
                result.isSuccess = false;
                result.failReason += '结束日期 endDate 在开始日期之前！';
            }

        }
        return result;
    }
}