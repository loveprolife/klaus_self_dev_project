public class CustomerOrderInventoryDailyJob implements Queueable {
    
        public List<Customer_Order_Inventory_Daily__c> coidList { get; set; }

        public CustomerOrderInventoryDailyJob(List<Customer_Order_Inventory_Daily__c> coidList){
            this.coidList = coidList;
        }
        
        public void execute(QueueableContext context) {
            Database.update(coidList);
        }
 }