/**************************************************************************************************
 * ProductLineTriggerHandler
 * Purpose:Score Sheet Trigger处理逻辑
 * Author: Deloitte xiaowei
 * Create Date: 2019-02-13  Last modified by johnson2019-09-12
***************************************************************************************************/
public class ProductLineTriggerHandler extends TriggerHandler{
    //获取客户产品线的Sales字段的field set 
    public static List<Schema.FieldSetMember> plSalesFieldSet = SObjectType.Customer_Product_Line__c.FieldSets.All_Sales_Fields.getFields();
	public override void afterInsert(){
        List<Account> accUp = new List<Account>();

        List<Sales__c> sales = new List<Sales__c>();
        for(Customer_Product_Line__c cpl : ((list<Customer_Product_Line__c>)Trigger.new)){
            //录入产品线计划开发完成时间录入时更新客户状态
            if(cpl.Expected_Development_Date__c != null){
                Account acc = new Account();
                acc.Customer_Status__c = 'Developping';
                acc.id = cpl.Customer__c;
                accUp.add(acc);
            }

            //根据填写的每个sales字段自动创建sales数据
            for(Schema.FieldSetMember plSales : plSalesFieldSet) {
                //System.debug('plSales: '+plSales);
                if(cpl.get(plSales.getFieldPath()) != null){
                    Sales__c sc1 = new Sales__c();
                    sc1.Sales__c = cpl.get(plSales.getFieldPath()) + '';
                    sc1.Customer__c= cpl.Customer__c;
                    sc1.Product_Line__c = cpl.Product_Line_Name__c;
                    sc1.IsKeyUser__c = plSales.getFieldPath().contains('Key_Sales__c') ? true : false;
                    sales.add(sc1);
                }
            }
            
        }
        update accUp;
        Database.insert(sales,false);
    }

    public override void beforeUpdate(){
        List<Account> accUp = new List<Account>();
        //需要新增的Sales
        List<Sales__c> insertSales = new List<Sales__c>();
        //需要删除的Sales的Key指向Account ID的Map
        Map<String,String> deleteSalesKeyMap = new Map<String,String>();

        for(Customer_Product_Line__c cpl : ((list<Customer_Product_Line__c>)Trigger.new)){
            Customer_Product_Line__c oCpl = (Customer_Product_Line__c)Trigger.oldMap.get(cpl.Id);
            //Rank字段更新，则将old值存到Last Rank中
            if(cpl.Rank__c != oCpl.Rank__c){
                cpl.Recent_Evaluated_Rank__c = oCpl.Rank__c;
            }
            //录入产品线计划开发完成时间录入时更新客户状态
            if(cpl.Expected_Development_Date__c != oCpl.Expected_Development_Date__c 
            && cpl.Expected_Development_Date__c != null){
                Account acc = new Account();
                acc.Customer_Status__c = 'Developping';
                acc.id = cpl.Customer__c;
                accUp.add(acc);
            }

            //根据填写的每个sales字段自动创建sales数据
            for(Schema.FieldSetMember plSales : plSalesFieldSet) {
                if(cpl.get(plSales.getFieldPath()) != oCpl.get(plSales.getFieldPath())){
                    //如果Sales字段值修改后不为空则将自动创建Sales数据
                    if(cpl.get(plSales.getFieldPath()) != null){
                        Sales__c sc1 = new Sales__c();
                        sc1.Sales__c = cpl.get(plSales.getFieldPath())+'';
                        sc1.Customer__c= cpl.Customer__c;
                        sc1.Product_Line__c = cpl.Product_Line_Name__c;
                        sc1.IsKeyUser__c = plSales.getFieldPath().contains('Key_Sales__c') ? true : false;
                        insertSales.add(sc1);
                    }
                    //如果Sales字段修改前值不为空则许将相关Sales数据删除
                    if(oCpl.get(plSales.getFieldPath()) != null){
                        deleteSalesKeyMap.put(cpl.Customer__c + cpl.Product_Line_Name__c + oCpl.get(plSales.getFieldPath()),cpl.Customer__c);
                    }
                }
            }
        }
        deleteSalesBySalesKeyMap(deleteSalesKeyMap);
        Database.insert(insertSales,false);
        update accUp;
    }

    public override void afterUpdate(){
        List<String> accEIDs = new List<String>();

        for(Customer_Product_Line__c cpl : ((list<Customer_Product_Line__c>)Trigger.new)){
            //变更为淘汰时需要查询的客户
            if(cpl.Rank__c == 'Eliminated Customer'){
                accEIDs.add(cpl.Customer__c);
            }
        }

        //查询客户产品线
        List<Customer_Product_Line__c> cples = [select Customer__c,Rank__c from Customer_Product_Line__c where Customer__c in:accEIDs];

        //组装客户与产品线的关系
        Map<String, List<Customer_Product_Line__c>> eAccMap = new Map<String, List<Customer_Product_Line__c>>();
        for (Customer_Product_Line__c  cple: cples) {
            if(eAccMap.containsKey(cple.Customer__c)){
                List<Customer_Product_Line__c> cplesTmp = eAccMap.get(cple.Customer__c);
                cplesTmp.add(cple);
                eAccMap.put(cple.Customer__c,cplesTmp);
            }else{
                List<Customer_Product_Line__c> cplesTmp = new List<Customer_Product_Line__c>();
                cplesTmp.add(cple);
                eAccMap.put(cple.Customer__c,cplesTmp);
            }
        }

        List<Account> upAccs = new List<Account>();
        Boolean isUpdate = true;
        for(String accId : eAccMap.keySet()){
            Account tempAcc = new Account();
            tempAcc.id = accId;
            for (Customer_Product_Line__c cpl : eAccMap.get(accId)) {
               //如果有不为淘汰的pl则不更新客户
               if(cpl.Rank__c != 'Eliminated Customer'){
                   isUpdate = false;
               }
            }
            if(isUpdate){
                tempAcc.Customer_Status__c = 'Eliminated';
                upAccs.add(tempAcc);
            }
        }
        update upAccs;
    }
    public override void afterDelete(){
        //需要删除的Sales的Key指向Account ID的Map
        Map<String,String> deleteSalesKeyMap = new Map<String,String>();
        for(Customer_Product_Line__c oCpl : ((list<Customer_Product_Line__c>)Trigger.old)){
             //根据填写的每个sales字段自动删除sales数据
            for(Schema.FieldSetMember plSales : plSalesFieldSet) {
                //如果Sales字段修改前值不为空则许将相关Sales数据删除
                if(oCpl.get(plSales.getFieldPath()) != null){
                    deleteSalesKeyMap.put(oCpl.Customer__c + oCpl.Product_Line_Name__c + oCpl.get(plSales.getFieldPath()),oCpl.Customer__c);
                }
            }
        }
        deleteSalesBySalesKeyMap(deleteSalesKeyMap);
    }
    /**
     方法名: deleteSalesBySalesKeyMap
     功能说明: 根据删除的deleteSalesKeyMap删除相关Sales数据 
     参数说明: Map<String,String> deleteSalesKeyMap Customer ID + Product Line + Sales Person ID => Customer ID
     返回值: 
     作者: Johnson
     日期: 2019-09-12
    */
    public void deleteSalesBySalesKeyMap(Map<String,String> deleteSalesKeyMap){
        if(deleteSalesKeyMap.keySet().size() > 0){
            //需要删除的Sales
            List<Sales__c> deleteSales = new List<Sales__c>();
            Map<String,Sales__c> deleteSalesMap = new Map<String,Sales__c>();
            for(Sales__c sales : [SELECT Id,Customer__c,Sales__c,Product_Line__c FROM Sales__c 
                                  WHERE Customer__c IN:deleteSalesKeyMap.values()]){
                String salesKey = sales.Customer__c + sales.Product_Line__c + sales.Sales__c;
                if(deleteSalesKeyMap.containsKey(salesKey)){
                    deleteSales.add(sales);
                }
            }
            delete deleteSales;
        }
    }
}