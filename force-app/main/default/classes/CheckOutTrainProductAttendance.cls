public with sharing class CheckOutTrainProductAttendance {

    @AuraEnabled
    public static ReturnDate getTrainAttendance(String id){
        ReturnDate result = new ReturnDate();
        result.isSuccess = false;
        try {
            List<Promoter_Attendance__c> data = getAttendanceInfo(id);

            if(data != null && data.size() > 0){
                result.isSuccess = true;
                result.data = data.get(0);

                // 查询客户信息
                String customerId = data.get(0).Customer__c;
                List<Account> customerList = [select name from Account where id =: customerId];
                if(customerList != null && customerList.size() > 0){
                    result.customerName = customerList.get(0).name;
                }
            }

            // System.debug('wwww Attendance' + data.get(0));
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Promoter_Attendance__c> getAttendanceInfo(String id){
        return [select 
                        id,
                        name,
                        Customer__c,
                        Trainer__c,
                        Name_of_Store_Manager__c,
                        Name_of_BA__c,
                        Name_of_FSPs__c,
                        Product_Features_Sales_Skill__c,
                        Promotion_Focus__c,
                        Marketing_display_condition__c, 
                        Display_Pictures__c, Second_Show__c from Promoter_Attendance__c 
                        where id =: id];
    }

    public class ReturnDate{
        @AuraEnabled
        public Boolean isSuccess{get;set;}

        @AuraEnabled
        public Promoter_Attendance__c data{get;set;}

        @AuraEnabled
        public String customerName{get;set;}
    }
}