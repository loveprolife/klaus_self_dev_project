global class ExecuteChannelSalesCountSchedulable implements Schedulable{

    // 年份
    private Integer dateYear;
    // 月份 
    private Integer dateMonth;

    public ExecuteChannelSalesCountSchedulable(Integer dateYear,Integer dateMonth) {
        this.dateYear = dateYear;
        this.dateMonth = dateMonth;
    }

    public ExecuteChannelSalesCountSchedulable() {
        this.dateYear = System.today().year();
        this.dateMonth = System.today().month();
    }

    global void execute(SchedulableContext sc){

        ChannelSalesCountSchedulable cscs1 = new ChannelSalesCountSchedulable('Hisense Indonesia', dateYear, dateMonth,true);
        SchedulableContext sc1;
        cscs1.execute(sc1);

        ChannelSalesCountSchedulable cscs2 = new ChannelSalesCountSchedulable('Hisense Indonesia', dateYear, dateMonth,false);
        SchedulableContext sc2;
        cscs2.execute(sc2);

        ChannelSalesCountSchedulable cscs3 = new ChannelSalesCountSchedulable('Hisense Malaysia', dateYear, dateMonth,false);
        SchedulableContext sc3;
        cscs3.execute(sc3);

        ChannelSalesCountSchedulable cscs4 = new ChannelSalesCountSchedulable('Hisense Malaysia', dateYear, dateMonth,false);
        SchedulableContext sc4;
        cscs4.execute(sc4);

        ChannelSalesCountSchedulable cscs5 = new ChannelSalesCountSchedulable('Hisense Thailand', dateYear, dateMonth,false);
        SchedulableContext sc5;
        cscs5.execute(sc5);

        ChannelSalesCountSchedulable cscs6 = new ChannelSalesCountSchedulable('Hisense Thailand', dateYear, dateMonth,false);
        SchedulableContext sc6;
        cscs6.execute(sc6);

        ChannelSalesCountSchedulable cscs7 = new ChannelSalesCountSchedulable('Hisense Vietnam', dateYear, dateMonth,false);
        SchedulableContext sc7;
        cscs7.execute(sc7);

        ChannelSalesCountSchedulable cscs8 = new ChannelSalesCountSchedulable('Hisense Vietnam', dateYear, dateMonth,false);
        SchedulableContext sc8;
        cscs8.execute(sc8);

        ChannelSalesCountSchedulable cscs9 = new ChannelSalesCountSchedulable('Hisense Philippines', dateYear, dateMonth,false);
        SchedulableContext sc9;
        cscs9.execute(sc9);

        ChannelSalesCountSchedulable cscs0 = new ChannelSalesCountSchedulable('Hisense Philippines', dateYear, dateMonth,false);
        SchedulableContext sc0;
        cscs0.execute(sc0);
    }

}