@isTest
public class ResponsiblePersonShareDelBatchTest{
    @isTest
    Static void testMethod1(){

        ResponsiblePersonShareDelBatch bps = new ResponsiblePersonShareDelBatch('Promoter_Attendance__Share');
        Database.executeBatch(bps, 20);
    }

}