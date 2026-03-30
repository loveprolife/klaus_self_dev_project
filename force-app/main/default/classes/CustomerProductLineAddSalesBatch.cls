/**********************************************************************
* Name: CustomerProductLineAddSalesBatch 
* Object: Customer Product Line Add Sales
* Purpose: 客户产品线批量添加销售
* Author: WFC
* Create Date: 2021-03-10
* 执行方法 Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
*************************************************************************/
public class CustomerProductLineAddSalesBatch implements Database.Batchable<sObject> {

    public CustomerProductLineAddSalesBatch () {
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, UserId__c, Customer_SAP_Account__c, CustomerId__c, Product_Line__c, Flag__c from Customer_Product_Line_Add_Sales__c');
    }
    public void execute(Database.BatchableContext BC, List<Customer_Product_Line_Add_Sales__c> proLineList) {
        Map<String, Customer_Product_Line__c> customerProductLineMap = new Map<String, Customer_Product_Line__c>();
        List<Customer_Product_Line__c> addList = new List<Customer_Product_Line__c>();
        List<Customer_Product_Line__c> updateList = new List<Customer_Product_Line__c>();

        // 遍历查询Customer_Product_Line_Add_Sales__c
        for(Customer_Product_Line_Add_Sales__c addSales : proLineList){
            Id uid = addSales.UserId__c;
            Id aid = addSales.CustomerId__c;
            String key = addSales.CustomerId__c + addSales.Product_Line__c;
            Customer_Product_Line__c currentObject = customerProductLineMap.get(key);
            if(currentObject != null){
                if(String.isNotBlank(addSales.Flag__c) && addSales.Flag__c.equals('1')){
                    if(currentObject.Sales_member01__c != null && currentObject.Sales_member01__c.equals(uid)){
                        currentObject.Sales_member01__c = null;
                    }
                    if(currentObject.Sales_member02__c != null && currentObject.Sales_member02__c.equals(uid)){
                        currentObject.Sales_member02__c = null;
                    }
                    if(currentObject.Sales_member03__c != null && currentObject.Sales_member03__c.equals(uid)){
                        currentObject.Sales_member03__c = null;
                    }
                    if(currentObject.Sales_member04__c != null && currentObject.Sales_member04__c.equals(uid)){
                        currentObject.Sales_member04__c = null;
                    }
                    if(currentObject.Sales_member05__c != null && currentObject.Sales_member05__c.equals(uid)){
                        currentObject.Sales_member05__c = null;
                    }
                    if(currentObject.Sales_member06__c != null && currentObject.Sales_member06__c.equals(uid)){
                        currentObject.Sales_member06__c = null;
                    }
                    if(currentObject.Sales_member07__c != null && currentObject.Sales_member07__c.equals(uid)){
                        currentObject.Sales_member07__c = null;
                    }
                    if(currentObject.Sales_member08__c != null && currentObject.Sales_member08__c.equals(uid)){
                        currentObject.Sales_member08__c = null;
                    }
                    if(currentObject.Sales_member09__c != null && currentObject.Sales_member09__c.equals(uid)){
                        currentObject.Sales_member09__c = null;
                    }
                    if(currentObject.Key_Sales__c != null && currentObject.Key_Sales__c.equals(uid)){
                        currentObject.Key_Sales__c = null;
                    }
                    customerProductLineMap.put(key, currentObject);
                }else {
                    if( currentObject.Sales_member01__c == uid ||
                        currentObject.Sales_member02__c == uid ||
                        currentObject.Sales_member03__c == uid ||
                        currentObject.Sales_member04__c == uid ||
                        currentObject.Sales_member05__c == uid ||
                        currentObject.Sales_member06__c == uid ||
                        currentObject.Sales_member07__c == uid ||
                        currentObject.Sales_member08__c == uid ||
                        currentObject.Sales_member09__c == uid ||
                        currentObject.Key_Sales__c == uid){
                    }else {
                        if(currentObject.Sales_member01__c == null){
                            currentObject.Sales_member01__c = uid;
                        }else if(currentObject.Sales_member02__c == null){
                            currentObject.Sales_member02__c = uid;
                        }else if(currentObject.Sales_member03__c == null){
                            currentObject.Sales_member03__c = uid;
                        }else if(currentObject.Sales_member04__c == null){
                            currentObject.Sales_member04__c = uid;
                        }else if(currentObject.Sales_member05__c == null){
                            currentObject.Sales_member05__c = uid;
                        }else if(currentObject.Sales_member06__c == null){
                            currentObject.Sales_member06__c = uid;
                        }else if(currentObject.Sales_member07__c == null){
                            currentObject.Sales_member07__c = uid;
                        }else if(currentObject.Sales_member08__c== null){
                            currentObject.Sales_member08__c = uid;
                        }else if(currentObject.Sales_member09__c == null){
                            currentObject.Sales_member09__c = uid;
                        }
                        customerProductLineMap.put(key, currentObject);
                    }
                    
                }
            }else {
                // Flag__c '1'为删除标记
                if(String.isNotBlank(addSales.Flag__c) && addSales.Flag__c.equals('1')){
                    List<Customer_Product_Line__c> cplLists =  [SELECT Id,Customer__c,Product_Line_Name__c,
                        Sales_member01__c,Sales_member02__c,Sales_member03__c,
                        Sales_member04__c,Sales_member05__c,Sales_member06__c,
                        Sales_member07__c,Sales_member08__c,Sales_member09__c,Key_Sales__c
                        from Customer_Product_Line__c 
                        where Customer__c =:aid and Product_Line_Name__c =:addSales.Product_Line__c
                        and (
                        Sales_member01__c =:uid or
                        Sales_member02__c =:uid or
                        Sales_member03__c =:uid or 
                        Sales_member04__c =:uid or
                        Sales_member05__c =:uid or
                        Sales_member06__c =:uid or
                        Sales_member07__c =:uid or
                        Sales_member08__c =:uid or
                        Sales_member09__c =:uid or
                        Key_Sales__c = :uid
                        )
                    ];
                    if(cplLists != null && cplLists.size() > 0){
                        for(Customer_Product_Line__c cplList: cplLists){
                            if(cplList.Sales_member01__c != null && cplList.Sales_member01__c.equals(uid)){
                                cplList.Sales_member01__c = null;
                            }
                            if(cplList.Sales_member02__c != null && cplList.Sales_member02__c.equals(uid)){
                                cplList.Sales_member02__c = null;
                            }
                            if(cplList.Sales_member03__c != null && cplList.Sales_member03__c.equals(uid)){
                                cplList.Sales_member03__c = null;
                            }
                            if(cplList.Sales_member04__c != null && cplList.Sales_member04__c.equals(uid)){
                                cplList.Sales_member04__c = null;
                            }
                            if(cplList.Sales_member05__c != null && cplList.Sales_member05__c.equals(uid)){
                                cplList.Sales_member05__c = null;
                            }
                            if(cplList.Sales_member06__c != null && cplList.Sales_member06__c.equals(uid)){
                                cplList.Sales_member06__c = null;
                            }
                            if(cplList.Sales_member07__c != null && cplList.Sales_member07__c.equals(uid)){
                                cplList.Sales_member07__c = null;
                            }
                            if(cplList.Sales_member08__c != null && cplList.Sales_member08__c.equals(uid)){
                                cplList.Sales_member08__c = null;
                            }
                            if(cplList.Sales_member09__c != null && cplList.Sales_member09__c.equals(uid)){
                                cplList.Sales_member09__c = null;
                            }
                            if(cplList.Key_Sales__c != null && cplList.Key_Sales__c.equals(uid)){
                                cplList.Key_Sales__c = null;
                            }
                            updateList.add(cplList);
                            customerProductLineMap.put(key, cplList);
                        }
                    }
                }else {
                    List<Customer_Product_Line__c> cplLists =  [SELECT Id,Customer__c,Product_Line_Name__c,
                        Sales_member01__c,Sales_member02__c,Sales_member03__c,
                        Sales_member04__c,Sales_member05__c,Sales_member06__c,
                        Sales_member07__c,Sales_member08__c,Sales_member09__c,Key_Sales__c
                        from Customer_Product_Line__c 
                        where Customer__c =:aid and Product_Line_Name__c =:addSales.Product_Line__c
                    ];
                    if(cplLists != null && cplLists.size() > 0){
                        for(Customer_Product_Line__c cplList: cplLists){
                            if( cplList.Sales_member01__c == uid ||
                                cplList.Sales_member02__c == uid ||
                                cplList.Sales_member03__c == uid ||
                                cplList.Sales_member04__c == uid ||
                                cplList.Sales_member05__c == uid ||
                                cplList.Sales_member06__c == uid ||
                                cplList.Sales_member07__c == uid ||
                                cplList.Sales_member08__c == uid ||
                                cplList.Sales_member09__c == uid ||
                                cplList.Key_Sales__c == uid){
                                    break;
                            }
                            if(cplList.Sales_member01__c == null){
                                cplList.Sales_member01__c = uid;
                            }else if(cplList.Sales_member02__c == null){
                                cplList.Sales_member02__c = uid;
                            }else if(cplList.Sales_member03__c == null){
                                cplList.Sales_member03__c = uid;
                            }else if(cplList.Sales_member04__c == null){
                                cplList.Sales_member04__c = uid;
                            }else if(cplList.Sales_member05__c == null){
                                cplList.Sales_member05__c = uid;
                            }else if(cplList.Sales_member06__c == null){
                                cplList.Sales_member06__c = uid;
                            }else if(cplList.Sales_member07__c == null){
                                cplList.Sales_member07__c = uid;
                            }else if(cplList.Sales_member08__c== null){
                                cplList.Sales_member08__c = uid;
                            }else if(cplList.Sales_member09__c == null){
                                cplList.Sales_member09__c = uid;
                            }
                            updateList.add(cplList);
                            customerProductLineMap.put(key, cplList);
                        }
                    
                    }else {
                        Customer_Product_Line__c cp = new Customer_Product_Line__c();
                        cp.Customer__c = aid;
                        cp.Product_Line_Name__c = addSales.Product_Line__c;
                        cp.Sales_member01__c = uid;
                        addList.add(cp);
                        customerProductLineMap.put(key, cp);
                    }
                }
            }
            
        }
        // Database.update(updateList);
        // Database.insert(addList); 
        Database.upsert(customerProductLineMap.values());


    }
    public void finish(Database.BatchableContext BC) {

    }

}