/**********************************************************************
* Name: CreateSAPInvoiceProduct
* Object: Invoice_Item__c 
* Purpose: 
* SAP中传过来的客户型号 产品型号不存在的就新建
* Author: Gerry
* Create Date: 2019-05-28
*************************************************************************/
global class CreateSAPInvoiceProduct implements Database.Batchable<sObject> {
    public String query;

    global CreateSAPInvoiceProduct() {
        //a0J0p000001iYAZEA2 a0J0p000001iUChEAM a0J0p000001ibTGEAY
        this.query = 'SELECT SAP_Customer_Model_Product__c,Product_Factory_Model__c,SAP_Product_Export_Model__c,Product_Export_Model__c,Customer_Model_Product__c,'+
                     'Product_Line__c,Invoice__r.Customer__r.Sales_Region__c FROM Invoice_Item__c WHERE Product_Export_Model__c=null OR Customer_Model_Product__c=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Invoice_Item__c> invoiceItemList) {
        Savepoint sp = Database.setSavepoint();
        try{
            //冰冷洗找不到产品型号  对应的出口型号
            Set<String> productModel = new Set<String>();
            //客户型号找不到
            Set<String> customerModel = new Set<String>();
            for (Invoice_Item__c invoice : invoiceItemList) {
                String productLine = invoice.Product_Line__c;
                if (('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine))
                    &&invoice.Product_Export_Model__c==null&&invoice.SAP_Product_Export_Model__c!=null) {
                    productModel.add(invoice.SAP_Product_Export_Model__c);
                }
                if (invoice.Customer_Model_Product__c==null && invoice.SAP_Customer_Model_Product__c!=null) {
                    customerModel.add(invoice.SAP_Customer_Model_Product__c);
                }    
                if (('AC'.equals(productLine)||'LCAC'.equals(productLine)||'Small Domestic Home Appliances'.equals(productLine)||'Cooking'.equals(productLine)||'Dishwasher'.equals(productLine))
                    && invoice.SAP_Product_Export_Model__c!=null && invoice.Product_Export_Model__c==null) {
                    productModel.add(invoice.SAP_Product_Export_Model__c);
                }
                if (('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine))
                    &&invoice.Product_Factory_Model__c!=null&&invoice.Product_Export_Model__c==null) {
                    productModel.add(invoice.Product_Factory_Model__c);   
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
            for (Invoice_Item__c invoice : invoiceItemList) {
                //如果没有关联到Customer Model Product并且sap传过来的客户型号不为空  就直接新建一个Customer Model Product
                if (invoice.Customer_Model_Product__c==null && invoice.SAP_Customer_Model_Product__c!=null 
                    && !customerModelFlag.contains(invoice.SAP_Customer_Model_Product__c)
                    &&customerMap.get(invoice.SAP_Customer_Model_Product__c)==null) {
                    Customer_Model_Product__c customerModelProduct = new Customer_Model_Product__c();
                    customerModelProduct.Name = invoice.SAP_Customer_Model_Product__c;
                    customerModelProduct.Product_Line__c = invoice.Product_Line__c;
                    customerModelProduct.Country_Code__c = invoice.Invoice__r.Customer__r.Sales_Region__c;
                    customerModelProductList.add(customerModelProduct);
                    customerModelFlag.add(invoice.SAP_Customer_Model_Product__c);
                }
                String productLine = invoice.Product_Line__c;
                //如果为冰冷洗产品线的时候，看出口型号是否有对应的product 如果有就不创建  没有就创建
                if (('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine))
                    &&invoice.Product_Export_Model__c==null&&invoice.SAP_Product_Export_Model__c!=null
                    &&factoryMap.get(invoice.SAP_Product_Export_Model__c)==null&&!exportModelFlag.contains(invoice.SAP_Product_Export_Model__c)) {
                    Product__c product = new Product__c();
                    product.Name = invoice.SAP_Product_Export_Model__c;
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
                    exportModelFlag.add(invoice.SAP_Product_Export_Model__c);
                }
                //如果为电视和手机产品线的时候 用直接创建product
                if (('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine))
                    &&invoice.Product_Factory_Model__c!=null&&invoice.Product_Export_Model__c==null
                    &&!factoryModelFlag.contains(invoice.Product_Factory_Model__c)
                    &&factoryMap.get(invoice.Product_Factory_Model__c)==null) {
                    Product__c product1 = new Product__c();
                    product1.Name = invoice.Product_Factory_Model__c;
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
                    factoryModelFlag.add(invoice.Product_Factory_Model__c);
                }
                //如果为AC产品线或者其他产品线的时候
                if (('AC'.equals(productLine)||'LCAC'.equals(productLine)||'Small Domestic Home Appliances'.equals(productLine)||'Cooking'.equals(productLine)||'Dishwasher'.equals(productLine))
                    && invoice.SAP_Product_Export_Model__c!=null && invoice.Product_Export_Model__c==null && !exportModelFlag.contains(invoice.SAP_Product_Export_Model__c)
                    &&factoryMap.get(invoice.SAP_Product_Export_Model__c)==null) {
                    Product__c product2 = new Product__c();
                    product2.Name = invoice.SAP_Product_Export_Model__c;
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
                    exportModelFlag.add(invoice.SAP_Product_Export_Model__c);
                }
            }
            Database.insert(customerModelProductList);
            Database.insert(productList);
            System.debug('添加成功');
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('CreateSAPInvoiceProduct', errorMsg);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}