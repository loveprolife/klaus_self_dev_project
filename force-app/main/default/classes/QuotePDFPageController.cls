public with sharing class QuotePDFPageController {
	public static Map<String,Schema.SObjectField> quoteLoopMap = Schema.SObjectType.Quote__c.fields.getMap();
    public static Map<String,Schema.SObjectField> quoteItemLoopMap = Schema.SObjectType.Quote_Product__c.fields.getMap();
	public String quoteId{get;set;}
	public Quote__c thisQuote{get;set;}
	public Decimal totalQuantity{get;set;}
    public Decimal totalNumberOfContainers{get;set;}
    public String issuingDate{get;set;}
    //报价PDF打印初始化
    public QuotePDFPageController() {
        quoteId = ApexPages.CurrentPage().getParameters().get('ID');
        String quoteQueryStr = Utility.getQueryStringByFieldMap(quoteLoopMap);
        String quoteItemQueryStr = Utility.getQueryStringByFieldMap(quoteItemLoopMap);
        String querySql = 'SELECT ' + quoteQueryStr + ',RecordType.DeveloperName,(SELECT Product__r.Name,' +  
                         quoteItemQueryStr + ' FROM Quote_Products__r ORDER BY Product__r.Name ASC)' + 
                         ' FROM Quote__c WHERE Id =:quoteId';
        thisQuote = Database.query(querySql);
        issuingDate = System.now().format('yyyy/MM/dd');
        totalQuantity = 0;
        totalNumberOfContainers = 0;
        for(Quote_Product__c quoteItem : thisQuote.Quote_Products__r){
            if(quoteItem.Quantity__c <> null) {
                totalQuantity += quoteItem.Quantity__c;
            }
            if(quoteItem.Number_of_Containers__c <> null) {
                totalNumberOfContainers += quoteItem.Number_of_Containers__c; 
            }
        }
    }
}