global virtual class SC_Base {
    public String salesQuery = 'SELECT Id,Name,Customer__c,IsKeyUser__c,Product_Line__c,IsDeleted,Sales__c '
        +'FROM Sales__c WHERE Sales__r.IsActive=true ';

    public String startDate;
    public String endDate;
    public List<Sales__c> salesList;
    public Set<String> customerIdSet;

    global SC_Base() {
        Date today = System.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1);
        this.startDate = yesterday.format();
        this.endDate = tomorrow.format();
    }

    global SC_Base(String startDate, String endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public List<Sales__c> updatedList(){
        List<Sales__c> r = new List<Sales__c>();
        if(this.salesList!=null){
            for(Sales__c sales: this.salesList) {
                if(!sales.IsDeleted){
                    r.add(sales);
                }
            }
        }
        return r;
    }

    public List<Sales__c> deletedList(){
        List<Sales__c> r = new List<Sales__c>();
        if(this.salesList!=null){
            for(Sales__c sales: this.salesList) {
                if(sales.IsDeleted){
                    r.add(sales);
                }
            }
        }
        return r;
    }
}