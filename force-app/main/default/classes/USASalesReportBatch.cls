/**********************************************************************
 * function: 美国销售监控报表-USA
 * @author:Yanhao
 * @url: /services/apexrest/rest
 * @data: USA Sales Monitoring Report   USA_Sales_Monitoring_Report__c
 * @Time:2019-11
 *************************************************************************/

global class USASalesReportBatch implements Database.Batchable<sObject> {
public String query;
public String year;
public String month;
public String day;
public Date today;
public Date startDate;


//特定是美国的
//public String hEnityList = '8110';
Set<String> hEnity = new Set<String>();

global USASalesReportBatch() {

	//Set<String> hEnity = new Set<String>();
	hEnity.add('8110');

	/*
	        this.query = 'SELECT id,Customer__c,Customer__r.name, Brand__c, Customer_Model_From_SAP__c, Invoiced_Amount_BC__c, Invoiced_Qty__c,Required_Delivery_Date__c, Product_Line_Code__c,' + 'DN_Qty__c,Pending_DN_Qty__c, ' +
	             'Programname__c, Shippingcondition__c,Invoice_No__r.InvoiceTotalAmountAfterRebate__c, Latestshipoutdate__c, DNNo__r.Loading_Date__c from SAP_Sales_Actual__c where Sales_Orgnization__c IN:hEnity ';
	 */
	this.query = 'SELECT id,Customer__c,Customer__r.name, Brand__c, Customer_Model_From_SAP__c, Invoiced_Amount_BC__c, Invoiced_Qty__c,Required_Delivery_Date__c, Product_Line_Code__c,' + 'DN_Qty__c,Pending_DN_Qty__c, ' +
	             'Order_Item_No__c,DNNo__c,Invoice_No__c,Programname__c,SO_No__c, PO_No__c,SO_Type__c, Order_Item_No__r.Order__r.Order_Classification__c,Shippingcondition__c,Invoice_No__r.SAP_Invoice_No__c,DNNo__r.SAP_Delivery_Order_No__c,Pending_DN_Amount_BC__c,Invoice_No__r.InvoiceTotalAmountAfterRebate__c, Latestshipoutdate__c, DNNo__r.Loading_Date__c,Invoice_No__r.Invoice_Date__c from SAP_Sales_Actual__c where Sales_Orgnization__c IN:hEnity ';
}

global Database.QueryLocator start(Database.BatchableContext bc) {
	return Database.getQueryLocator(query);
}


global void execute(Database.BatchableContext BC, list<SAP_Sales_Actual__c> salesReport) {
	//System.debug('接收的List的大小是:'+salesReport.size());

	try {
		List<USA_Sales_Monitoring_Report__c> reportDataList = new List<USA_Sales_Monitoring_Report__c>();//最后要进行数据库更新的list

		for (SAP_Sales_Actual__c salesReportData : salesReport) {
			String productLine = '';
			productLine = salesReportData.Product_Line_Code__c;
			String CEorHAFlag = this.ceORha(productLine);
			USA_Sales_Monitoring_Report__c reportDataObj = new USA_Sales_Monitoring_Report__c();

			reportDataObj.Customer__c = salesReportData.Customer__c;
			reportDataObj.Invoice_Price__c =  convertNull(salesReportData.Invoiced_Amount_BC__c);
			reportDataObj.Brand__c = salesReportData.Brand__c == null ? '' : salesReportData.Brand__c;
			reportDataObj.Invoiced_QTY__c =  convertNull(salesReportData.Invoiced_QTY__c);
			//转换 LatestShipOutDate
			Date LatestShipOutDate_cov = this.stringToDate(salesReportData.Latestshipoutdate__c);
			reportDataObj.Latestshipoutdate__c = LatestShipOutDate_cov;
			//转换Loading date
			Date Loading_Date_cov = this.stringToDate(salesReportData.DNNo__r.Loading_Date__c);
			reportDataObj.LoadingDate__c =  Loading_Date_cov;
			reportDataObj.Model__c = salesReportData.Customer_Model_From_SAP__c == null ? '' : salesReportData.Customer_Model_From_SAP__c;
			//转换Required_Delivery_Date
			Date Required_Delivery_Date_cov = this.dateTidmeToDate(salesReportData.Required_Delivery_Date__c);
			reportDataObj.Required_Delivery_Date__c = Required_Delivery_Date_cov;

			reportDataObj.CEorHA__c = CEorHAFlag;
			//把PO SO SAP号给带出来
			/*

			   reportDataObj.Order_Item__c = salesReportData.Order_Item_No__c == null ? '' : salesReportData.Order_Item_No__c;
			   reportDataObj.Delivery_Order__c = salesReportData.Order_Item_No__c == null ? '' : salesReportData.DNNo__c;
			   reportDataObj.Invoice__c = salesReportData.Order_Item_No__c == null ? '' : salesReportData.Invoice_No__c;
			   //Order_Item_No__r.Order__c,DNNo__c,Invoice_No__c
			 */
			//文本填进去
			//reportDataObj.Order_Item__c = salesReportData.Order_Item_No__c == null ? '' : salesReportData.Order_Item_No__c;
			reportDataObj.SO_No__c = salesReportData.SO_No__c == null ? '' : salesReportData.SO_No__c;
			reportDataObj.PO_No__c = salesReportData.PO_No__c == null ? '' : salesReportData.PO_No__c;
			reportDataObj.Order_class__c = salesReportData.Order_Item_No__r.Order__r.Order_Classification__c == null ? '' : salesReportData.Order_Item_No__r.Order__r.Order_Classification__c;
			reportDataObj.Order_Type__c = salesReportData.SO_Type__c == null ? '' : salesReportData.SO_Type__c;
			reportDataObj.Invoice_No__c = salesReportData.Invoice_No__r.SAP_Invoice_No__c == null ? '' : salesReportData.Invoice_No__r.SAP_Invoice_No__c;
			reportDataObj.Delivery_No__c = salesReportData.DNNo__r.SAP_Delivery_Order_No__c == null ? '' : salesReportData.DNNo__r.SAP_Delivery_Order_No__c;


			if(CEorHAFlag == 'CE') {
				//黑电Actual sales 赋值
				//reportDataObj.CEorHA__c = 'CE';

				System.debug('CE- Invoiced_QTY__c:' + reportDataObj.Invoiced_QTY__c);



				//黑电是否为当月，处理逻辑
				if(salesReportData.Programname__c == 'ZRSD028') {
					reportDataObj.Programname__c = salesReportData.Programname__c;

					if(salesReportData.Shippingcondition__c == '01') {//Shippingcondition是01的/

						Boolean isCurrMonth = this.isCurrentMonth(Loading_Date_cov);
						if(isCurrMonth) {
							//当月的
							reportDataObj.ZRSD028__c = salesReportData.DN_Qty__c;
						}else{
							//下月
							reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
						}
					}else{//Shippingcondition不是01的
						Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);
						if(RDDisCurrMonth) {//如果RDD是当月的:
							reportDataObj.ZRSD028__c = salesReportData.DN_Qty__c;
						}else{//如果RDD不是当月的，则记到下一月
							reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
						}
					}
				}else if(salesReportData.Programname__c == 'ZSD005') {
					reportDataObj.Programname__c = salesReportData.Programname__c;
					Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);

					/*
					   //目前没有Latest ship out time
					   if(salesReportData.Shippingcondition__c == '01') {
					        //先转换Latest ship out date 为Date格式

					        String LatestShipOutDate = salesReportData.Latestshipoutdate__c;
					        //Date LatestShipOutDate_cov = this.stringToDate(LatestShipOutDate);
					        Boolean LSODisCurrMonth = this.isCurrentMonth(LatestShipOutDate_cov);
					        //如果Latest ship out date = 当月。则放到当月
					        if(LSODisCurrMonth) {
					                reportDataObj.ZSD005__c = salesReportData.DN_Qty__c;
					        }else{//LatestShipOutDate不是当月的，则记到下一月
					                reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
					        }
					   }*/


					if(salesReportData.Shippingcondition__c == '01') {
						if(RDDisCurrMonth) {
							reportDataObj.ZSD005__c = salesReportData.DN_Qty__c;
						}else{//如果RDD不是当月的，则记到下一月
							reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
						}
					}else{
						if(RDDisCurrMonth) {
							reportDataObj.ZSD005__c = salesReportData.DN_Qty__c;
						}else{//如果RDD不是当月的，则记到下一月
							reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
						}
					}
					//新建ZGRT14__c 字段  按开票日期做判断  Invoice_No__r.Invoice_Date__c
				}else if(salesReportData.Programname__c == 'ZGRT14') {
					reportDataObj.Programname__c = salesReportData.Programname__c;
					//订单类型为ZOR4： 开票日期为当月的放当月
					if(salesReportData.SO_Type__c == 'ZOR4') {

						if(isCurrentMonth2(salesReportData.Invoice_No__r.Invoice_Date__c)) {
							reportDataObj.ZGRT14__c = salesReportData.DN_Qty__c;

						}else{
							//下月
							reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
						}
					}

					/*
					   if(salesReportData.Shippingcondition__c == '01') {//Shippingcondition是01的/

					        Boolean isCurrMonth = this.isCurrentMonth(Loading_Date_cov);
					        if(isCurrMonth) {
					                //当月的
					                reportDataObj.ZGRT14 = salesReportData.DN_Qty__c;
					        }else{
					                //下月
					                reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
					        }
					   }else{//Shippingcondition不是01的
					        Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);
					        if(RDDisCurrMonth) {//如果RDD是当月的:
					                reportDataObj.ZGRT14 = salesReportData.DN_Qty__c;
					        }else{//如果RDD不是当月的，则记到下一月
					                reportDataObj.Ship_on_following_month__c = salesReportData.DN_Qty__c;
					        }
					   }
					 */

				}


			}else if (CEorHAFlag == 'HA') {
				//白电处理逻辑
				//ÍÍreportDataObj.CEorHA__c = 'HA';
				//白电Actual sales 赋值
				//reportDataObj.CEorHA__c = 'CE';
				System.debug('HA- Invoiced_QTY__c:' + reportDataObj.Invoiced_QTY__c);
				//白电的 Pending ship&inv within Curr. mo. Amt.  这个字段取   Pending_DN_Amount_BC__c
				//Pending_ship_inv_within_Curr_mo_Amt__c
				reportDataObj.Pending_ship_inv_within_Curr_mo_Amt__c = convertNull(salesReportData.Pending_DN_Amount_BC__c);

				//白电是否为当月，处理逻辑
				if(salesReportData.Programname__c == 'ZRSD028') {
					reportDataObj.Programname__c = salesReportData.Programname__c;
					Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);
					if(RDDisCurrMonth) {        //如果RDD是当月的:
						reportDataObj.ZRSD028__c = salesReportData.Pending_DN_Qty__c;
						//HA Amount 字段逻辑更改 --当月
						reportDataObj.Invoiced_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
						System.debug('ZRSD028 Invoiced_Amount_HA__c：' + reportDataObj.Invoiced_Amount_HA__c);
					}else{        //如果RDD不是当月的，则记到下一月
						//HA Amount 字段逻辑更改 --次月
						reportDataObj.Ship_on_following_month_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
						reportDataObj.Ship_on_following_month__c = salesReportData.Pending_DN_Qty__c;
					}

				}else if(salesReportData.Programname__c == 'ZSD005') {
					reportDataObj.Programname__c = salesReportData.Programname__c;
					Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);
					if(RDDisCurrMonth) { //如果RDD是当月的:
						reportDataObj.ZSD005__c = salesReportData.Pending_DN_Qty__c;
						//Amount 字段逻辑更改 --当月
						reportDataObj.Invoiced_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
						System.debug('ZSD005 Invoiced_Amount_HA__c：' + reportDataObj.Invoiced_Amount_HA__c);

					}else{  //如果RDD不是当月的，则记到下一月
						reportDataObj.Ship_on_following_month__c = salesReportData.Pending_DN_Qty__c;

						//HA Amount 字段逻辑更改 --次月
						reportDataObj.Ship_on_following_month_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
					}
				}else if(salesReportData.Programname__c == 'ZGRT14') {
					reportDataObj.Programname__c = salesReportData.Programname__c;
					Boolean RDDisCurrMonth = this.isCurrentMonth2(salesReportData.Required_Delivery_Date__c);
					if(RDDisCurrMonth) { //如果RDD是当月的:
						reportDataObj.ZSD005__c = salesReportData.Pending_DN_Qty__c;
						//Amount 字段逻辑更改 --当月
						reportDataObj.Invoiced_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
						System.debug('ZGRT14 Invoiced_Amount_HA__c：' + reportDataObj.Invoiced_Amount_HA__c);
					}else{  //如果RDD不是当月的，则记到下一月
						reportDataObj.Ship_on_following_month__c = salesReportData.Pending_DN_Qty__c;

						//HA Amount 字段逻辑更改 --次月
						reportDataObj.Ship_on_following_month_Amount_HA__c = convertNull(salesReportData.Invoice_No__r.InvoiceTotalAmountAfterRebate__c);
					}
				}
			}

			reportDataList.add(reportDataObj);
			//System.debug('有CE HA的List的大小是:' + reportDataList.size());
		}

		Database.upsert(reportDataList);//数据库更新
	}catch(Exception e) {
		System.debug('出错：' + e.getMessage() +' 行号是： '+e.getLineNumber());
		//日志内容
		InterfaceLog__c ic = new InterfaceLog__c();
		ic.Class__c = 'USASalesReport';
		ic.Time__c = System.Now();
		ic.ReturnCode__c = '0';
		ic.ErrorMsg__c = e.getMessage()+e.getLineNumber();
		insert ic;
	}


}

global void finish(Database.BatchableContext BC) {

}


//判断是CE还是HA
public String ceORha(String productLine) {
	String ceha = 'No product line or Not in Scope';
	if((productLine == '14') || (productLine == '16')  || (productLine == '17')  || (productLine == '49')  ) {
		ceha = 'CE';
	}else if((productLine == '61') || (productLine == '62') ||(productLine == '63') ||(productLine == '64') || (productLine == '69')  ||(productLine == '89') ) {
		ceha = 'HA';
	}else{
		ceha = 'Other Product Line:' + productLine;
	}
	return ceha;
}

//判断传进来的日期是否为 当月 （传入为Date格式）
public Boolean isCurrentMonth(Date dataDate) {
	Boolean isCurrentMonthFlag  = false;
	Integer currentMonth = Date.Today().Month();
	if(dataDate != null) {
		Integer dataMonth = dataDate.Month();
		if(currentMonth == dataMonth) {
			isCurrentMonthFlag = true;
		}
	}
	else{
		isCurrentMonthFlag = false;
	}
	return isCurrentMonthFlag;
}


//判断传进来的日期是否为 当月 （传入为Date/time格式）
public Boolean isCurrentMonth2(DateTime dataDateTime) {
	Boolean isCurrentMonthFlag  = false;
	Integer currentMonth = Date.Today().Month();
	Date myDate = Date.newinstance(dataDateTime.year(), dataDateTime.month(), dataDateTime.day());
	Integer dataMonth = myDate.Month();
	if(currentMonth == dataMonth) {
		isCurrentMonthFlag = true;
	}else{
		isCurrentMonthFlag = false;
	}
	return isCurrentMonthFlag;
}

//String 转 date格式    //////////////////////////////////////////////////////处理空值及错误
public Date stringToDate(String stringDate) {
	if(String.isNotBlank(stringDate)) {
		if(Integer.valueOf(stringDate.replace('-', '')) == 0) {
			return null;
		}
		Date newDate = Date.valueOf(stringDate);
		return newDate;
	}
	return null;
}


//Date/time 转 date格式  /////////////////////////////////////////////////////处理空值及错误
public Date dateTidmeToDate(DateTime dataDateTime) {
	Date myDate = Date.newinstance(dataDateTime.year(), dataDateTime.month(), dataDateTime.day());
	return myDate;
}

/*
   //String 转 date格式
   public Date stringToDate(String stringDate) {
    try{
        Date newDate = Date.valueOf(stringDate);
        return newDate;
    }catch{
        String stringDate = '2099-01-01'//如果传入的不是
        Date newDate = Date.valueOf(stringDate);
        return newDate;
    }
   }
 */


//转换null to 0
private static Decimal convertNull(Decimal num) {
	Decimal strConvert;
	if(num == null) {
		strConvert = 0;
	}else{
		strConvert = num;
	}
	return strConvert;
}
}