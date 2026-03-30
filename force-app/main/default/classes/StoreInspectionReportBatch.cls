/*
 * @Author: WFC
 * @Date: 2024-04-01 11:03:43
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-02 09:39:47
 * @Description:  StoreInspectionReportBatch sir = new StoreInspectionReportBatch();
    Database.executeBatch(sir,200);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\StoreInspectionReportBatch.cls
 */
global class StoreInspectionReportBatch implements Database.Batchable<sObject>{
    public String query;
    public Integer year;
    public Integer month;

    global StoreInspectionReportBatch(){
        this.year = System.today().year();
        this.month = System.today().month();
    }

    global StoreInspectionReportBatch(Integer year, Integer month){
        this.year = year;
        this.month = month;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        Datetime monthFirstDay = Datetime.newInstanceGmt(this.year, this.month, 1);
        Datetime nextMonthFirstDay = monthFirstDay.addMonths(1);
        this.query = 'SELECT Id FROM Shop__c WHERE CreatedDate < :nextMonthFirstDay';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Shop__c> shopList){
        Datetime monthFirstDay = Datetime.newInstanceGmt(this.year, this.month, 1);
        Datetime nextMonthFirstDay = monthFirstDay.addMonths(1);
        Date monthFirstDayDate = Date.valueOf(monthFirstDay.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())));
        Date nextMonthFirstDayDate = Date.valueOf(nextMonthFirstDay.format('yyyy-MM-dd', String.valueOf(System.UserInfo.getTimeZone())));
        // 门店&巡店日报中间表
        List<Store_Inspection_Report__c> addList = new List<Store_Inspection_Report__c>();
        // 门店id集合
        Set<Id> shopId = new Set<Id>();
        for (Shop__c shop : shopList){
            shopId.add(shop.Id);
        }
        // 查询门店是否有巡店员
        Map<Id, Boolean> responsiblePersonMap = new Map<Id, Boolean>();
        List<Responsible_Person__c> responsiblePersonList = [SELECT Id, Shop_Name__c
                                                             FROM Responsible_Person__c
                                                             WHERE Shop_Name__c IN:shopId 
                                                             AND RecordType__c IN ('巡店员', 'Backup Floorwalker') 
                                                             AND CreatedDate < :nextMonthFirstDay];
        for (Responsible_Person__c rp : responsiblePersonList){
            responsiblePersonMap.put(rp.Shop_Name__c, true);
        }
        // 查询当月时间维度筛选巡店报告数
        Map<Id, Integer> inspectionMap = new Map<Id, Integer>();
        Map<Id, Set<Id>> inspectionPersonMap = new Map<Id, Set<Id>>();
        List<Daily_Inspection_Report__c> inspectionList = [SELECT Id, Store__c, OwnerId
                                                           FROM Daily_Inspection_Report__c
                                                           WHERE Store__c IN:shopId 
                                                           AND Report_Date__c >= :monthFirstDayDate 
                                                           AND Report_Date__c < :nextMonthFirstDayDate 
                                                           AND Status__c = 'Submitted'];
        for (Daily_Inspection_Report__c inspection : inspectionList){
            if (inspectionMap.containsKey(inspection.Store__c)){
                inspectionMap.put(inspection.Store__c, inspectionMap.get(inspection.Store__c) + 1);
            } else{
                inspectionMap.put(inspection.Store__c, 1);
            }
            if (inspectionPersonMap.containsKey(inspection.Store__c)){
                inspectionPersonMap.get(inspection.Store__c).add(inspection.OwnerId);
            } else{
                inspectionPersonMap.put(inspection.Store__c, new Set<Id>{ inspection.OwnerId });
            }
        }
        // 查询工单数信息
        Map<Id, Integer> ticketAllNumberMap = new Map<Id, Integer>();
        Map<Id, Integer> ticketReslovedNumberMap = new Map<Id, Integer>();
        Map<Id, Integer> ticketNoReslovedNumberMap = new Map<Id, Integer>();
        List<Ticket__c> ticketList = [SELECT Id, InspectionReport__r.Store__c, DueDate__c, Status__c
                                      FROM Ticket__c
                                      WHERE RecordType.name = 'Floorwalker'
                                      AND InspectionReport__r.Status__c ='Submitted' 
                                      AND InspectionReport__r.Store__c IN:shopId 
                                      AND InspectionReport__r.Report_Date__c >= :monthFirstDayDate 
                                      AND InspectionReport__r.Report_Date__c < :nextMonthFirstDayDate];
        for(Ticket__c ticket : ticketList){
            if (ticketAllNumberMap.containsKey(ticket.InspectionReport__r.Store__c)){
                ticketAllNumberMap.put(ticket.InspectionReport__r.Store__c, ticketAllNumberMap.get(ticket.InspectionReport__r.Store__c) + 1);
            } else{
                ticketAllNumberMap.put(ticket.InspectionReport__r.Store__c, 1);
            }
            if(ticket.Status__c == 'Open' && ticket.DueDate__c < System.today()){
                if (ticketNoReslovedNumberMap.containsKey(ticket.InspectionReport__r.Store__c)){
                    ticketNoReslovedNumberMap.put(ticket.InspectionReport__r.Store__c, ticketNoReslovedNumberMap.get(ticket.InspectionReport__r.Store__c) + 1);
                } else{
                    ticketNoReslovedNumberMap.put(ticket.InspectionReport__r.Store__c, 1);
                }
            }else {
                if (ticketReslovedNumberMap.containsKey(ticket.InspectionReport__r.Store__c)){
                    ticketReslovedNumberMap.put(ticket.InspectionReport__r.Store__c, ticketReslovedNumberMap.get(ticket.InspectionReport__r.Store__c) + 1);
                } else{
                    ticketReslovedNumberMap.put(ticket.InspectionReport__r.Store__c, 1);
                }
            }
        }

        for (Shop__c shop : shopList){
            Store_Inspection_Report__c sir = new Store_Inspection_Report__c();
            sir.Year__c = this.year;
            sir.Month__c = this.month;
            sir.Store__c = shop.Id;
            sir.Key__c = this.year + '-' + this.month + '-' + shop.Id;
            sir.Have_Responsible_Person__c = responsiblePersonMap.containsKey(shop.Id) ? true : false;
            sir.Have_Inspection_Report__c = inspectionMap.containsKey(shop.Id) ? true : false;
            sir.Inspection_Report_Number__c = inspectionMap.containsKey(shop.Id) ? inspectionMap.get(shop.Id) : 0;
            sir.Responsible_Person_Number__c = inspectionPersonMap.containsKey(shop.Id) ? inspectionPersonMap.get(shop.Id).size() : 0;
            sir.Ticket_Number__c = ticketAllNumberMap.containsKey(shop.Id) ? ticketAllNumberMap.get(shop.Id) : 0;
            sir.Ticket_Resloved_Number__c = ticketReslovedNumberMap.containsKey(shop.Id) ? ticketReslovedNumberMap.get(shop.Id) : 0;
            sir.Ticket_No_Resloved_Number__c = ticketNoReslovedNumberMap.containsKey(shop.Id) ? ticketNoReslovedNumberMap.get(shop.Id) : 0;

            addList.add(sir);
        }
        Database.upsert(addList, Store_Inspection_Report__c.Fields.key__c, false);
    }

    global void finish(Database.BatchableContext BC){
        Utility.refreshReportCustom('StoreInspectionReportBatch');
    }

}