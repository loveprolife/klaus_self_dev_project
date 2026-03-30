global  without sharing class CustomerProLineSalesChangeController{
    // @AuraEnabled 
    // //查询用户
    // public static User searchUser(String keyword){
    // 	System.debug('current keyword is  ' +keyword);
    // 	User userList = new User();
    // 	if(String.isNotBlank(keyword)){
    //         userList = [SELECT Id,Name FROM User WHERE Name =:keyword];
    // 	}
    // 	return userList;
    // }
    @AuraEnabled 
    //根据两个销售用户id执行替换
    public static String changeTwoSales(String oldUserId, String targetUserId){
        List<Schema.FieldSetMember> plSalesFieldSet = SObjectType.Customer_Product_Line__c.FieldSets.All_Sales_Fields.getFields();
        System.debug(oldUserId+'---'+targetUserId);
        String qs = '%'+oldUserId+'%';
        List<Customer_Product_Line__c> cplList = new List<Customer_Product_Line__c>();

        if(String.isNotBlank(oldUserId)&&String.isNotBlank(targetUserId)){
            
            cplList =  [SELECT Id,Key_Sales__c,Sales_member01__c,Sales_member02__c,
                Sales_member03__c,Sales_member04__c,Sales_member05__c,Sales_member06__c,Sales_member07__c,
                Sales_member08__c,Sales_member09__c FROM Customer_Product_Line__c WHERE IsExistSales__c LIKE :qs];
            
            System.debug(cplList.size());
            List<Customer_Product_Line__c> newcplList = new List<Customer_Product_Line__c>();
            for(Customer_Product_Line__c cpl : cplList){
                for(Schema.FieldSetMember plSales : plSalesFieldSet) {
                    if(cpl.get(plSales.getFieldPath()) == oldUserId){
                        System.debug(cpl.get(plSales.getFieldPath()));
                        cpl.put(plSales.getFieldPath(),targetUserId);
                        newcplList.add(cpl);
                    }
                }
                
            }
            update newcplList;
            if(newcplList.size()!=0)
                return 'success!';
            else
                return 'this user have no product line!';
        }
        return 'user is empty!';
    }

}