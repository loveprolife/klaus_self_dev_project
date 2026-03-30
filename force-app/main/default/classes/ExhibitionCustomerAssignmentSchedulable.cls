global without sharing class ExhibitionCustomerAssignmentSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {

        // 展会内部报名截至的第二天开始为参展客户匹配接待人员
        // 每天上午九点运行
        Database.executeBatch(new ExhibitionCustomerAssignmentBatch());
    }
}