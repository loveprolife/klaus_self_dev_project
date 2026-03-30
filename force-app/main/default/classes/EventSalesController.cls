/*
 * @Author: WFC
 * @Date: 2025-03-03 15:27:43
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-18 17:11:03
 * @Description: Event 模块
 * @FilePath: \testuat\force-app\main\default\classes\EventSalesController.cls
 */
public without sharing class EventSalesController{
    public static String accessories = Schema.SobjectType.Event_Sales__c.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
    public static String discount = Schema.SobjectType.Event_Sales__c.getRecordTypeInfosByDeveloperName().get('Discount').getRecordTypeId();
    public static String product = Schema.SobjectType.Event_Sales__c.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
    public static String warranty = Schema.SobjectType.Event_Sales__c.getRecordTypeInfosByDeveloperName().get('Warranty').getRecordTypeId();
    // 汇率
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-03-04 13:57:00
     * @Description: 根据id查询 Event_Receipt__c 表
     */
    @AuraEnabled
    public static Event_Receipt__c searchEventReceipt(String recordId){
        return [SELECT Id, Sales_Region__c, CurrencyIsoCode
                FROM Event_Receipt__c
                WHERE Id = :recordId
                LIMIT 1];
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-03-04 13:57:05
     * @Description: 根据id查询 Product__c 表
     */
    @AuraEnabled
    public static Product__c searchProductInfo(String productId, String currencyIsoCode){
        Product__c product = [SELECT Id, Guiding_Price__c, CurrencyIsoCode
                              FROM Product__c
                              WHERE Id = :productId
                              LIMIT 1];
        // 产品汇率
        Decimal rate = currencyRateMap.get(product.CurrencyIsoCode);
        // Event Receipt 汇率
        Decimal receiptRate = currencyRateMap.get(currencyIsoCode);
        if (product.Guiding_Price__c != null){
            Decimal price = product.Guiding_Price__c / rate * receiptRate;
            product.Guiding_Price__c = price.divide(1, 2);
            product.CurrencyIsoCode = currencyIsoCode;
            return product;
        } else{
            return null;
        }
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2025-03-04 13:57:12
     * @Description: 保存 Event Sales
     */
    @AuraEnabled
    public static ConResponse saveEventSalesDetail(String eventReceiptJson, String eventSalesJson, String eventSalesAccessoriesJson, Boolean isShowWarranty, Boolean isShowAccessories, String type){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        // 处理前端数据
        Event_Receipt__c eventReceipt = (Event_Receipt__c) JSON.deserialize(eventReceiptJson, Event_Receipt__c.class);
        Event_Sales__c eventSales = (Event_Sales__c) JSON.deserialize(eventSalesJson, Event_Sales__c.class);
        Event_Sales__c eventSalesAcc = (Event_Sales__c) JSON.deserialize(eventSalesAccessoriesJson, Event_Sales__c.class);
        System.debug('wwwww--type--' + type);
        System.debug('wwwww--eventReceipt--' + JSON.serialize(eventReceiptJson));
        System.debug('wwwww--eventSales--' + JSON.serialize(eventSalesJson));
        System.debug('wwwww--eventSalesAcc--' + JSON.serialize(eventSalesAccessoriesJson));

        List<Event_Sales__c> insertList = new List<Event_Sales__c>();
        // 生成唯一值，关联一起创建的Event Sales
        Blob b = Crypto.GenerateAESKey(128);
        String key = EncodingUtil.ConvertTohex(b);
        // 根据type区分逻辑
        if (type == 'Product'){
            // Product 类型
            Event_Sales__c eventSalesProduct = new Event_Sales__c();
            eventSalesProduct.Event_Receipt__c = eventReceipt.Id;
            eventSalesProduct.RecordTypeId = product;
            eventSalesProduct.Product__c = eventSales.Product__c;
            eventSalesProduct.Unit_Price__c = eventSales.Unit_Price__c;
            eventSalesProduct.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
            eventSalesProduct.Quantity__c = eventSales.Quantity__c;
            eventSalesProduct.Sales_Region__c = eventReceipt.Sales_Region__c;
            eventSalesProduct.Key__c = key;
            insertList.add(eventSalesProduct);

            // 保修信息
            if (isShowWarranty){
                Event_Sales__c eventSalesWarranty = new Event_Sales__c();
                eventSalesWarranty.Event_Receipt__c = eventReceipt.Id;
                eventSalesWarranty.RecordTypeId = warranty;
                eventSalesWarranty.Product__c = eventSales.Product__c;
                eventSalesWarranty.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                eventSalesWarranty.Sales_Region__c = eventReceipt.Sales_Region__c;
                eventSalesWarranty.Quantity__c = 1;
                eventSalesWarranty.Key__c = key;

                eventSalesWarranty.Warranty_period_increase__c = eventSales.Warranty_period_increase__c;
                eventSalesWarranty.Warranty_price_increase__c = eventSales.Warranty_price_increase__c;
                insertList.add(eventSalesWarranty);
            }
            // Accessories 类型
            if (isShowAccessories){
                Event_Sales__c eventSalesAccessories = new Event_Sales__c();
                eventSalesAccessories.Event_Receipt__c = eventReceipt.Id;
                eventSalesAccessories.RecordTypeId = accessories;
                eventSalesAccessories.Accessories__c = eventSalesAcc.Accessories__c;
                eventSalesAccessories.Unit_Price__c = eventSalesAcc.Unit_Price__c;
                eventSalesAccessories.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                eventSalesAccessories.Quantity__c = eventSalesAcc.Quantity__c;
                eventSalesAccessories.Sales_Region__c = eventReceipt.Sales_Region__c;
                eventSalesAccessories.Key__c = key;
                insertList.add(eventSalesAccessories);
            }
            // Discount 类型
            if (eventSales.Discount__c != null){
                Event_Sales__c eventSalesDiscount = new Event_Sales__c();
                eventSalesDiscount.Event_Receipt__c = eventReceipt.Id;
                eventSalesDiscount.RecordTypeId = discount;
                eventSalesDiscount.Product__c = eventSales.Product__c;
                eventSalesDiscount.Discount__c = eventSales.Discount__c;
                eventSalesDiscount.Unit_Price__c = eventSales.Discount__c;
                eventSalesDiscount.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
                eventSalesDiscount.Quantity__c = 1;
                eventSalesDiscount.Sales_Region__c = eventReceipt.Sales_Region__c;
                eventSalesDiscount.Key__c = key;
                insertList.add(eventSalesDiscount);
            }
        } else if (type == 'Discount'){
            Event_Sales__c eventSalesDiscount = new Event_Sales__c();
            eventSalesDiscount.Event_Receipt__c = eventReceipt.Id;
            eventSalesDiscount.RecordTypeId = discount;
            eventSalesDiscount.Description__c = eventSales.Description__c;
            eventSalesDiscount.Discount__c = eventSales.Discount__c;
            eventSalesDiscount.Unit_Price__c = eventSales.Discount__c;
            eventSalesDiscount.CurrencyIsoCode = eventReceipt.CurrencyIsoCode;
            eventSalesDiscount.Quantity__c = 1;
            eventSalesDiscount.Sales_Region__c = eventReceipt.Sales_Region__c;
            eventSalesDiscount.Key__c = key;
            insertList.add(eventSalesDiscount);
        }


        List<Database.SaveResult> srList = Database.insert (insertList, false);
        for (Database.SaveResult r : srList){
            if (!r.isSuccess()){
                String errorMessage = '';
                for (Database.Error err : r.getErrors()){
                    errorMessage += err.getMessage();
                }
                resp.code = -1;
                resp.message = errorMessage;
            }
        }

        resp.data = mso;
        return resp;
    }

    // @AuraEnabled
    // public static ContentVersion generatePDF(String recordId){
    //     PageReference pdfPage = Page.EventReceiptPDFPage; // Visualforce 页面名称
    //     pdfPage.getParameters().put('ID', recordId); // 传递参数（可选）
    //     Blob pdfBlob = pdfPage.getContentAsPDF(); // 获取 PDF 的 Blob 数据
    //     ContentVersion cv = new ContentVersion(
    //         Title = 'GeneratedPDF.pdf', 
    //         PathOnClient = 'GeneratedPDF.pdf', 
    //         VersionData = pdfBlob, 
    //         FirstPublishLocationId = recordId
    //     );
    //     insert cv;
    //     return [SELECT Id, Title, FileExtension, VersionData, ContentDocumentId
    //             FROM ContentVersion
    //             WHERE Id = :cv.Id AND IsLatest = true
    //             LIMIT 1];
    // }

    @AuraEnabled
    public static ContentVersion generatePDF(String recordId){
        Event_Receipt__c eventReceipt = [SELECT Id, Name, Event_Subject__c, Customer_Name__c, Invoice_date__c, Address__c, Mobile_Number__c, CurrencyIsoCode, Total__c, Event_Subject__r.GST__c, Promoter_Note__c
                                         FROM Event_Receipt__c
                                         WHERE Id = :recordId
                                         LIMIT 1];

        // 获取Visualforce Page的PDF内容
        try{
            PageReference pdfPage = Page.EventReceiptPDFPage;
            pdfPage.getParameters().put('ID', recordId);
            Blob pdfBlob;
            pdfBlob = pdfPage.getContentAsPDF();

            // 查询现有 ContentDocument 记录
            List<ContentDocument> cdList = [SELECT Id
                                            FROM ContentDocument
                                            WHERE LatestPublishedVersion.Download_Key__c = :recordId];
            // 删除ContentDocument数据
            if (cdList != null && cdList.size() > 0){
                delete cdList;
            }

            // 创建File对象
            ContentVersion file = new ContentVersion(
                Title = eventReceipt.Name + '_' + Datetime.now().format('yyyyMMdd'), 
                PathOnClient = eventReceipt.Name + '_' + Datetime.now().format('yyyyMMdd') + '.pdf', 
                VersionData = pdfBlob, 
                FirstPublishLocationId = recordId, 
                IsMajorVersion = true, 
                Download_Key__c = recordId
            );
            insert file;

            return [SELECT Id, Title, FileExtension, VersionData, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :file.Id];

        } catch (Exception e){
            return null;
        }
    }

}