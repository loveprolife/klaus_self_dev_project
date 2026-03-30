/*
 * @Author: WFC
 * @Date: 2025-03-05 09:38:23
 * @LastEditors: WFC
 * @LastEditTime: 2025-10-31 14:06:53
 * @Description: Event Receipt 打印PDF
 * @FilePath: \testuat\force-app\main\default\classes\EventReceiptPrintPDFController.cls
 */
public without sharing class EventReceiptPrintPDFController{
    public Event_Receipt__c eventReceipt{ get; set; }

    public Events__c events{ get; set; }

    public String dateFormatString{ get; set; }

    public List<Event_Sales__c> eventSalesList{ get; set; }

    public Decimal gst{ get; set; }

    public Decimal gstTotalShow{ get; set; }

    public Decimal totalShow{ get; set; }

    public Boolean nextPage{ get; set; }

    public Boolean showBalance{ get; set; }

    public static String warranty = Schema.SobjectType.Event_Sales__c.getRecordTypeInfosByDeveloperName().get('Warranty').getRecordTypeId();
    public EventReceiptPrintPDFController(){
        System.debug('wwww---EventReceiptPrintPDFController starts...');
        // 获取 id
        String eventReceiptId = ApexPages.CurrentPage().getParameters().get('ID');
        System.debug('wwww---eventReceiptId:' + eventReceiptId);
        Set<String> localeSet = new Set<String>{ 'zh_SG', 'fr_FR' };
        String userLocale = UserInfo.getLocale();
        System.debug('wwwwww-----' + userLocale);
        if (localeSet.contains(userLocale)){
            dateFormatString = 'dd-MM-yyyy';
        } else{
            dateFormatString = 'yyyy-MM-dd';
        }
        eventReceipt = [SELECT Id, Name, Event_Subject__c, Customer_Name__c, Invoice_date__c, Address__c, Mobile_Number__c, CurrencyIsoCode, Total__c, Event_Subject__r.GST__c, Promoter_Note__c, Deposit__c, Outstanding_Balance__c
                        FROM Event_Receipt__c
                        WHERE Id = :eventReceiptId
                        LIMIT 1];
        events = [SELECT Id, Company_Information__c, Terms_Condition__c
                  FROM Events__c
                  WHERE Id = :eventReceipt.Event_Subject__c
                  LIMIT 1];
        eventSalesList = [SELECT Id, Quantity__c, Unit_Price__c, Sub_Total__c, PDF_Index__c, PDF_Item__c, RecordTypeId, Warranty_price_increase__c
                          FROM Event_Sales__c
                          WHERE Event_Receipt__c = :eventReceiptId
                          ORDER BY Name];
        Integer i = 1;
        for (Event_Sales__c eventSales : eventSalesList){
            eventSales.PDF_Index__c = i;
            if (eventSales.RecordTypeId == warranty){
                eventSales.Unit_Price__c = eventSales.Warranty_price_increase__c;
            }
            i++;
        }
        if (eventReceipt.Total__c != null && eventReceipt.Event_Subject__r.GST__c != null){
            Decimal total = eventReceipt.Total__c;
            gst = eventReceipt.Event_Subject__r.GST__c;
            gstTotalShow = (total / (1 + gst / 100) * gst / 100).divide(1, 2);
            totalShow = total.divide(1, 2);
        }
        nextPage = false;
        showBalance = true;
        if(eventReceipt.Outstanding_Balance__c == 0){
            showBalance = false;
        }
        if (String.isNotBlank(events.Terms_Condition__c)){
            nextPage = true;
        }

        ApexPages.currentPage().getHeaders().put('content-disposition', '; filename=' + eventReceipt.Name + '_' + Datetime.now().format('yyyyMMdd') + '.pdf');
    }

    @AuraEnabled
    public static Map<String, String> downloadFile(String recordId){
        Map<String, String> resultMap = new Map<String, String>();

        Event_Receipt__c eventReceipt = [SELECT Id, Name, Event_Subject__c, Customer_Name__c, Invoice_date__c, Address__c, Mobile_Number__c, CurrencyIsoCode, Total__c, Event_Subject__r.GST__c, Promoter_Note__c
                                         FROM Event_Receipt__c
                                         WHERE Id = :recordId
                                         LIMIT 1];
        try{
            // 查询现有 ContentDocument 记录
            List<ContentDocument> cdList = [SELECT Id
                                            FROM ContentDocument
                                            WHERE LatestPublishedVersion.Download_Key__c = :recordId];
            // 删除ContentDocument数据
            if (cdList != null && cdList.size() > 0){
                delete cdList;
            }
            // 获取Visualforce Page的PDF内容
            PageReference pdfPage = Page.EventReceiptPDFPage;
            pdfPage.getParameters().put('ID', recordId);
            Blob pdfBlob;
            if (Test.isRunningTest()){
                pdfBlob = Blob.valueOf('Test');
            } else{
                pdfBlob = pdfPage.getContentAsPDF();
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

            ContentVersion qrcv = [SELECT Id, ContentDocumentId
                                   FROM ContentVersion
                                   WHERE Id = :file.Id];

            resultMap.put('ContentDocumentId', qrcv.ContentDocumentId);
        } catch (Exception e){
            throw new AuraHandledException('PDF生成失败: ' + e.getMessage());
        }

        return resultMap;
    }

}