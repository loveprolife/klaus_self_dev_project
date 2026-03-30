public class CustomerProductLineYRUpdateSchedulable implements Schedulable{
    
    public void execute(SchedulableContext sc){
        String dateString = System.now().format('mmdd');
        String currentDay = System.now().format('dd');
        //根据系统设置设定的Batch运行时间进行年度产品线排行的更新，目前设置为01/02
        if(dateString.equals(Label.Customer_Product_Line_Year_Rank_Update_Date) || Test.isRunningTest()){
            Database.executeBatch(new CustomerProductLineYearRankUpdateBatch(),200);
        }
        //月度提醒黑电直发成本组更新成本价，目前设置为每月12号
        if(currentDay.equals(Label.Price_Book_Cost_Price_Update_Reminder_Day) || Test.isRunningTest()){
            String roleName = Label.Role_Name_Sales_CE_Cost;
            List<User> productUserList = [SELECT Id,Name FROM User 
                                            where UserRole.DeveloperName =:roleName AND IsActive = true];
            List<Task> tasks = new List<Task>();
            for(User productUser : productUserList){
                Task task = new Task();
                task.Subject = Label.Price_Book_Cost_Price_Update_Reminder_Task_Subject;//'Monthly Cost Price Update Reminder';
                task.Description = Label.Price_Book_Cost_Price_Update_Reminder_Task_Description;//'Please login into the system as soon as possible to maintain the cost price updated in the current month';
                task.Status = 'Not Started';
                task.Priority = 'High';
                task.OwnerId = productUser.Id;
                task.IsReminderSet = true;
                task.ReminderDateTime = Datetime.now();
                tasks.add(task);
            }
            insert tasks;    
        }
    }

}