global class PhotoDownloadProcessScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // 定义销售区域
        String[] salesRegion = new String[] {'Hisense South Africa','Hisense Indonesia', 'Hisense Chile', 'Hisense Japan', 'Hisense Peru',
            'Hisense Colombia', 'Hisense Argentina', 'Hisense West Africa', 'Hisense Saudi', 'Hisense Canada',
            'Hisense USA', 'Hisense Mexico', 'Hisense Thailand', 'Hisense Vietnam', 'Hisense Malaysia', 'Hisense Philippines','Hisense Australia'};
        // 定义其他参数（根据需要调整）
        String shopId = null; // 如果需要特定店铺，可以设置
        Date yesterday = Date.today().addDays(-1);
        Date oneMonthAgo = yesterday.addDays(-30);
        String channel = null; // 如果需要特定渠道，可以设置
        String walker = null; // 如果需要特定检查员，可以设置

        // 启动批量作业
        Database.executeBatch(new PhotoDownloadProcessBatch(salesRegion, shopId, oneMonthAgo, yesterday, channel, walker), 1000);
    }
}