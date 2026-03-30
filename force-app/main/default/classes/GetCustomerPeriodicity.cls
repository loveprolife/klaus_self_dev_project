/**********************************************************************
 * 
 * 获取一定时间范围内的客户数据
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/GetCustomers')
global with sharing class GetCustomerPeriodicity {

    global class SFInput{
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
    }

    //返回值
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
        public List<Customer> data{set;get;}
    }

    global class Customer{
        public Customer(Account acc){
            this.sapCode = acc.SAP_Customer_Code__c;
            this.sfCode = acc.Customer_SF_Code__c;
            this.name = acc.Name;
            this.status = acc.Customer_Status__c;
            this.category = acc.Customer_Category__c;
            this.createdDate = acc.LastModifiedDate.format('yyyy-MM-dd hh:mm:ss');
            this.bmCustomers = new List<BranchManagementCustomer>();
            if(acc.Account_Product_Lines__r != null 
                && acc.Account_Product_Lines__r.size()>0){
                for(Customer_Product_Line__c cpl: acc.Account_Product_Lines__r){
                    this.bmCustomers.add(new BranchManagementCustomer(cpl));
                }
            }
            this.bmCustomers.sort();
        }
        public String sapCode{set;get;}
        public String sfCode{set;get;}
        public String name{set;get;}
        public String status{set;get;}
        public String category{set;get;}
        public String createdDate{set;get;}
        public String branchManagementCustomer{
            get{
                if(this.bmCustomers!=null && this.bmCustomers.size()>0){
                    return this.bmCustomers.get(0).name;
                }
                return null;
            }
        }
        List<BranchManagementCustomer> bmCustomers;
    }

    /**
     * 对管理用客户进行封装
     */
    global class BranchManagementCustomer implements Comparable{

        public BranchManagementCustomer(){}
        public BranchManagementCustomer(Customer_Product_Line__c cpl){
            this.productLine = cpl.Product_Line_Name__c;
            this.name = cpl.Management_Customer_Branch_Company__r.Name;
            this.id = cpl.Management_Customer_Branch_Company__c;
        }

        public String productLine{set;get;}
        public String name{set;get;}
        public String id{set;get;}

        Map<String,Integer> productLineMap{
            get{
                return new Map<String,Integer>{
                    'TV'=>1, 'Refrigerator'=>2, 'Freezer'=>3, 'AC'=>4, 'WM'=>5
                };
            }
        }

        global Integer compareTo(Object compareTo){
            if(compareTo == null){
                return 1;
            }
            BranchManagementCustomer obj = (BranchManagementCustomer) compareTo;
            if(obj.productLine == this.productLine){
                return 0;
            }
            if(obj.productLine == null){
                return -1;
            }
            if(obj.productLine.equals(this.productLine)){
                return 0;
            } else {
                //按照TV, Refrigerator, Freezer, AC, WM的顺序排列
                Integer v1 = this.productLineMap.get(this.productLine);
                Integer v2 = this.productLineMap.get(obj.productLine);
                if(v1 == null){
                    return 1;
                }
                if(v2 == null){
                    return -1;
                }
                if(v1 == v2){
                    return 0;
                } else {
                    return v1 > v2 ? 1: -1;
                }
            }
        }
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
                result.failReason = null;
                List<Account> accs = [
                    SELECT Id,Name,SAP_Customer_Code__c,Customer_SF_Code__c,
                        Customer_Status__c,Customer_Category__c,CreatedDate,LastModifiedDate,
                        (SELECT 
                            id,Name,Product_Line_Name__c,
                            Management_Customer_Branch_Company__c,
                            Management_Customer_Branch_Company__r.Name,
                            Management_Customer__c
                        from Account_Product_Lines__r)
                    FROM Account
                    WHERE LastModifiedDate < :input.endDay
                    AND LastModifiedDate >= :input.startDay
                    AND Sales_Region__c = :input.salesRegion
                    ORDER BY LastModifiedDate
                ];
                if(!accs.isEmpty()){
                    result.data = new List<Customer>();
                    for(Account acc: accs){
                        Customer cus = new Customer(acc);
                        result.data.add(cus);
                    }
                    System.debug('result data size:'+result.data.size());
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