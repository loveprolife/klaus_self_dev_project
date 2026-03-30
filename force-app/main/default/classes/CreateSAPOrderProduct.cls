/**********************************************************************
* Name: CreateSAPOrderProduct
* Object: Order 
* Purpose: 
* SAP中传过来的客户型号 产品型号不存在的就新建
* Author: Gerry
* Create Date: 2019-05-28
*************************************************************************/
global class CreateSAPOrderProduct implements Database.Batchable<sObject> {
    public String query;

    global CreateSAPOrderProduct() {
        //a0q0p000000dJYgAAM a0q0p000000dJTGAA2(产品型号和客户型号都不存在) a0q0p000000dJToAAM（产品型号和客户型号都不存在） a0q0p000000dK34AAE
        //a0q0p000000dabbAAA a0q0p000000dabcAAA 
        this.query = 'SELECT SAP_Product_Customer_Model__c,Product_Factory_Model__c,SAP_Product_Export_Model__c,Product_Export_Model__c,Customer_Model_Product__c,'+
                     'Product_Line__c,Order__r.Customer__r.Sales_Region__c FROM Order_Product__c WHERE Product_Export_Model__c=null OR Customer_Model_Product__c=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Product__c> orderProductList) {
        Savepoint sp = Database.setSavepoint();
        try{
            //冰冷洗找不到产品型号  对应的出口型号
            Set<String> productModel = new Set<String>();
            //客户型号找不到
            Set<String> customerModel = new Set<String>();
            for (Order_Product__c orderProduct : orderProductList) {
                String productLine = orderProduct.Product_Line__c;
                if (('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine))
                    &&orderProduct.Product_Export_Model__c==null&&orderProduct.SAP_Product_Export_Model__c!=null) {
                    productModel.add(orderProduct.SAP_Product_Export_Model__c);
                }
                if (orderProduct.Customer_Model_Product__c==null && orderProduct.SAP_Product_Customer_Model__c!=null) {
                    customerModel.add(orderProduct.SAP_Product_Customer_Model__c);
                }    
                if (('AC'.equals(productLine)||'LCAC'.equals(productLine)||'Small Domestic Home Appliances'.equals(productLine)||'Cooking'.equals(productLine)||'Dishwasher'.equals(productLine))
                    && orderProduct.SAP_Product_Export_Model__c!=null && orderProduct.Product_Export_Model__c==null) {
                    productModel.add(orderProduct.SAP_Product_Export_Model__c);
                }
                if (('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine))
                    &&orderProduct.Product_Factory_Model__c!=null&&orderProduct.Product_Export_Model__c==null) {
                    productModel.add(orderProduct.Product_Factory_Model__c);   
                }     
            }

            //已经存在的客户型号
            Map<String,Customer_Model_Product__c> customerMap = new Map<String,Customer_Model_Product__c>();
            for (Customer_Model_Product__c cm : [SELECT ID,Name FROM Customer_Model_Product__c WHERE Name IN :customerModel]) {
                customerMap.put(cm.Name, cm);
            }

            //已经存在的产品
            Map<String,Product__c> factoryMap = new Map<String,Product__c>();
            for (Product__c pro : [SELECT ID,Name FROM Product__c WHERE Name IN :productModel]) {
                factoryMap.put(pro.Name,pro);
            }
            //用来判断客户型号是否已经新建
            Set<String> customerModelFlag = new Set<String>();
            //用来判断工厂型号是否已经新建
            Set<String> factoryModelFlag = new Set<String>();
            //用来判断出口型号是否已经创建
            Set<String> exportModelFlag = new Set<String>();
            List<Customer_Model_Product__c> customerModelProductList = new List<Customer_Model_Product__c>();
            List<Product__c> productList = new List<Product__c>();
            for (Order_Product__c orderProduct : orderProductList) {
                //如果没有关联到Customer Model Product并且sap传过来的客户型号不为空  就直接新建一个Customer Model Product
                if (orderProduct.Customer_Model_Product__c==null && orderProduct.SAP_Product_Customer_Model__c!=null 
                    && !customerModelFlag.contains(orderProduct.SAP_Product_Customer_Model__c)
                    &&customerMap.get(orderProduct.SAP_Product_Customer_Model__c)==null) {
                    Customer_Model_Product__c customerModelProduct = new Customer_Model_Product__c();
                    customerModelProduct.Name = orderProduct.SAP_Product_Customer_Model__c;
                    customerModelProduct.Product_Line__c = orderProduct.Product_Line__c;
                    customerModelProduct.Country_Code__c = orderProduct.Order__r.Customer__r.Sales_Region__c;
                    customerModelProductList.add(customerModelProduct);
                    customerModelFlag.add(orderProduct.SAP_Product_Customer_Model__c);
                }
                String productLine = orderProduct.Product_Line__c;
                //如果为冰冷洗产品线的时候，看出口型号是否有对应的product 如果有就不创建  没有就创建
                if (('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine))
                    &&orderProduct.Product_Export_Model__c==null&&orderProduct.SAP_Product_Export_Model__c!=null
                    &&factoryMap.get(orderProduct.SAP_Product_Export_Model__c)==null&&!exportModelFlag.contains(orderProduct.SAP_Product_Export_Model__c)) {
                    Product__c product = new Product__c();
                    product.Name = orderProduct.SAP_Product_Export_Model__c;
                    if ('Refrigerator'.equals(productLine)) {
                        product.Product_Line__c = 'Refrigerator';
                        product.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Refrigerator Product RecordType').getRecordTypeId();
                    }else if ('Freezer'.equals(productLine)) {
                        product.Product_Line__c = 'Freezer';
                        product.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Freezer Product RecordType').getRecordTypeId();
                    }else{
                        product.Product_Line__c = 'WM';
                        product.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('WM Product RecordType').getRecordTypeId();
                    }
                    productList.add(product);
                    exportModelFlag.add(orderProduct.SAP_Product_Export_Model__c);
                }
                //如果为电视和手机产品线的时候 用直接创建product
                if (('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine))
                    &&orderProduct.Product_Factory_Model__c!=null&&orderProduct.Product_Export_Model__c==null
                    &&!factoryModelFlag.contains(orderProduct.Product_Factory_Model__c)
                    &&factoryMap.get(orderProduct.Product_Factory_Model__c)==null) {
                    Product__c product1 = new Product__c();
                    product1.Name = orderProduct.Product_Factory_Model__c;
                    if ('TV'.equals(productLine)) {
                        product1.Product_Line__c = 'TV';
                        product1.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV Product RecordType').getRecordTypeId();
                    }else if ('Laser TV'.equals(productLine)) {
                        product1.Product_Line__c = 'Laser TV';
                        product1.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('TV Product RecordType').getRecordTypeId();
                    }else{
                        product1.Product_Line__c = 'Mobile';
                        product1.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Mobile Product RecordType').getRecordTypeId();
                    }
                    productList.add(product1);
                    factoryModelFlag.add(orderProduct.Product_Factory_Model__c);
                }
                //如果为AC产品线或者其他产品线的时候
                if (('AC'.equals(productLine)||'LCAC'.equals(productLine)||'Small Domestic Home Appliances'.equals(productLine)||'Cooking'.equals(productLine)||'Dishwasher'.equals(productLine))
                    && orderProduct.SAP_Product_Export_Model__c!=null && orderProduct.Product_Export_Model__c==null && !exportModelFlag.contains(orderProduct.SAP_Product_Export_Model__c)
                    &&factoryMap.get(orderProduct.SAP_Product_Export_Model__c)==null) {
                    Product__c product2 = new Product__c();
                    product2.Name = orderProduct.SAP_Product_Export_Model__c;
                    if ('AC'.equals(productLine)) {
                        product2.Product_Line__c = 'AC';
                        product2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('AC Product RecordType').getRecordTypeId();
                    }
                    if ('LCAC'.equals(productLine)) {
                        product2.Product_Line__c = 'LCAC';
                        product2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('AC Product RecordType').getRecordTypeId();
                    }
                    if ('Small Domestic Home Appliances'.equals(productLine)) {
                        product2.Product_Line__c = 'Small Domestic Home Appliances';
                        product2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('SDHA Product RecordType').getRecordTypeId();
                    }
                    if ('Cooking'.equals(productLine)) {
                        product2.Product_Line__c = 'Cooking';
                        product2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Cooking Product RecordType').getRecordTypeId();
                    }
                    if ('Dishwasher'.equals(productLine)) {
                        product2.Product_Line__c = 'Dishwasher';
                        product2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Dishwasher Product RecordType').getRecordTypeId();
                    }
                    productList.add(product2);
                    exportModelFlag.add(orderProduct.SAP_Product_Export_Model__c);
                }
            }
            Database.insert(customerModelProductList);
            Database.insert(productList);
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('CreateSAPOrderProduct', errorMsg);
        }    
    }

    global void finish(Database.BatchableContext BC) {

    }
}