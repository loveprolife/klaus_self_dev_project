global without sharing class AutoCheckOutSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {

        // 南非促销员晚七点后开始自动签退
        // 南非当地时间晚上七点开始每半小时执行一次
        Time southAfricaTime = AutoCheckOutBatch.getSouthAfricaTime();
        if (southAfricaTime >= Time.newInstance(19, 0, 0, 0)) {
            Database.executeBatch(new AutoCheckOutBatch());
        }
    }
}