global withOut sharing class CustomerProductSalesReportSchedulable implements Schedulable {

    public String orderDate;
    public String salesRegion;

    global CustomerProductSalesReportSchedulable(String salesRegion, String orderDate ){
            this.orderDate = orderDate;
            this.salesRegion = salesRegion;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CustomerProductSalesReportDelBatch(this.salesRegion,this.orderDate),200);
    }
}