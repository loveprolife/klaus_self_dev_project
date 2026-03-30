/*
 * @Author: WFC
 * @Date: 2025-08-21 09:56:40
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-30 09:41:51
 * @Description: SAPGetOrderInvoiceNoInsert 定时任务
 * @FilePath: \testuat\force-app\main\default\classes\SAPGetOrderInvoiceNoInsertSchedulable.cls
 */
global class SAPGetOrderInvoiceNoInsertSchedulable implements Schedulable{
    public String companyCode = '';
    public String orderTypeCode = '';
    public String syncStartDate = '';
    public String syncEndDate = '';
    public Integer urlIndex = 0;
    global SAPGetOrderInvoiceNoInsertSchedulable(String companyCode, String orderTypeCode, String syncStartDate, String syncEndDate, Integer urlIndex){
        this.companyCode = companyCode;
        this.orderTypeCode = orderTypeCode;
        this.syncStartDate = syncStartDate;
        this.syncEndDate = syncEndDate;
        this.urlIndex = urlIndex;
    }

    global SAPGetOrderInvoiceNoInsertSchedulable(String companyCode, String orderTypeCode, Integer urlIndex){
        this.companyCode = companyCode;
        this.orderTypeCode = orderTypeCode;
        this.urlIndex = urlIndex;
    }

    global void execute(SchedulableContext sc){
        List<String> companyCodeList = this.companyCode.split(',');
        List<String> orderTypeCodeList = this.orderTypeCode.split(',');
        SAPGetOrderInvoiceNoInsert.executionInterface(companyCodeList, syncStartDate, syncEndDate, orderTypeCodeList, urlIndex);
    }

}