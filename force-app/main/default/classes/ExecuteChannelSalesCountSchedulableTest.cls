@isTest
public class ExecuteChannelSalesCountSchedulableTest {
    @isTest
    static void methodTest1(){

        ExecuteChannelSalesCountSchedulable test = new ExecuteChannelSalesCountSchedulable(2024,05);
        SchedulableContext sc;
        test.execute(sc);

        ExecuteChannelSalesCountSchedulable test1 = new ExecuteChannelSalesCountSchedulable();
        SchedulableContext sc1;
        test1.execute(sc1);
    }
}