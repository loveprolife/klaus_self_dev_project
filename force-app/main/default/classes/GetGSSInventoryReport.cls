/**********************************************************************
 * function:获取来自GSS系统的 库存信息报表
 * @author:Yanhao
 * @url: /services/apexrest/rest
 * @data: GSSInventoryReport   GSS_Inventory_Report__c
 * date:2019-09
 *************************************************************************/

//@RestResource(urlMapping='/getACProductFromGSS')
@RestResource(urlMapping='/getGSSInventoryReport')

global with sharing class GetGSSInventoryReport {

global class AppInput {
//inventoryReportData
//List<ACProductInfo> ProductList;
List<InventoryReportData> inventoryDataList;
}
global class AppOutPut {
String FailReason;
String IsSuccess;
}
global class InventoryReportData {

public String Id;                //序号
public String CustomerSAPCode;                //客户代码
//public String    CustomerCode;    //客户SAP代码
public String ProductionBase;                //生产基地
public String ProductCategory;                //产品大类
public String ProductType;                //产品类型
public String BatchNumber;                //批次号
public String SalesBigArea;                //销售大区
public String SalesSmallArea;                //销售小区
public String CustomerName;                //客户名称
public String Brand;                //品牌
public String FactoryModel;                //本厂型号
public String OrderCount;                //排产单数量
public String StockInCount;                //累计入库
public String FirstStockInDate;                //首次入仓时间
public String CycleTime;                //周期
public String CurrentDate;                //当前日期
public String LastStockInDate;                //最终入仓时间
public String ScheduledShippingTime;                //本版计划出运时间
public String PartialShippingTime;                //本版分批出运时间
public String StorageCount;                //库存数量
public String StockAge;                //库龄
public String Employee;                //业务员
public String SalesCoordinator;                //销售协调
public String ProductState;                //产品状态
public String CustomerModel;                //客户型号
public String ContractNumber;                //合同号
public String ShippingOrderNumber;                //落货纸号
public String OverdueReason;                //超期原因
public String DisposalMeasures;                //处理措施
public String EstimatedBillOfLadingDate;                //预计提单日期
public String ResponsiblePerson;                //责任人
public String Remark;                //备注
public String ExternalKey;                //外键：产品类型+批次号
}


@HttpPost
//global static GetACProductFromGSS.AppOutPut adoPost() {
global static GetGSSInventoryReport.AppOutPut adoPost() {
	//GetGSSInventoryReport
	RestRequest req = RestContext.request;
	String reqBody = req.requestBody.tostring();

	system.debug('doPost now, body : ' + reqBody);

	AppInput input = new AppInput();
	GetGSSInventoryReport.AppOutPut result = new GetGSSInventoryReport.AppOutPut();
	try{
		input = (GetGSSInventoryReport.AppInput) JSON.deserialize(reqBody, GetGSSInventoryReport.AppInput.class);

		System.debug('input===>:' + input);
		//空数据
		if (input.inventoryDataList == null || input.inventoryDataList.isEmpty()) {
			result.IsSuccess = 'False';
			result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
			return result;
		}else{
			//public String debugString;
			List<GSS_Inventory_Report__c> inserList = new List<GSS_Inventory_Report__c>();
			Set<String> GssAccountSet = new Set<String>();//GSS客户号集合
			Set<String> AccountSAPCodeSet = new Set<String>();//客户号集合
			Set<String> ProductLineSet = new Set<String>();//产品线集合


			//先对GSS传过来的客户和产品线信息进行处理，转换成10位客户号码和SF的产品线，非数字的客户代码排除掉
			for (GetGSSInventoryReport.InventoryReportData reqInventoryData : input.inventoryDataList) {
				//转换SAP code 加前导0
				String sapCode = reqInventoryData.CustomerSAPCode == null ? '' : reqInventoryData.CustomerSAPCode;
				GssAccountSet.add(sapCode);
				//首先判断一下 sapCode 的长度 和是否为一次性客户等(非数字)
				Pattern NUMBER_PATTERN = Pattern.compile('-?[0-9]+(\\.[0-9]+)?');
				//Boolean strResult = sapCode.matches('-?[0-9]+.？[0-9]*');
                Matcher isNum = NUMBER_PATTERN.matcher(sapCode);
				if (!isNum.matches()) {
					//不是数字暂不做处理
				}else{
                    Integer sapCodeLength = sapCode.length();
					if (sapCodeLength < 10) {
                        sapCode = ('0000000000' + sapCode).substring(sapCode.length());//加前导零
						AccountSAPCodeSet.add(sapCode);
					}
				}
			}


			//对发过来对客户代码，匹配上SF代码
			//产品线进行匹配，匹配上SF代码
			Map<String,String> SFCustomerSAPCode2SFCodeMap = new Map<String,String>();//Map中：SAP客户号，SF客户号
			Map<String,String> SFCustomerSAPCode2IdMap = new Map<String,String>();//Map中：SAP客户号，SF客户ID
			//
			for(Account ac : [Select Id,Customer_SF_Code__c,SAP_Customer_Code__c from Account where SAP_Customer_Code__c in: AccountSAPCodeSet]) {
				SFCustomerSAPCode2SFCodeMap.put(ac.SAP_Customer_Code__c,ac.Customer_SF_Code__c);
				SFCustomerSAPCode2IdMap.put(ac.SAP_Customer_Code__c,ac.Id);
			}


			for (GetGSSInventoryReport.InventoryReportData reqInventoryData : input.inventoryDataList) {

				GSS_Inventory_Report__c data = new GSS_Inventory_Report__c();

				data.Id__c = reqInventoryData.Id == null ? '' : reqInventoryData.Id;
				//先把GSS传过来的客户号码记录到CustomerSAPCode__c字段
				String gssCustomerCode;
				gssCustomerCode = reqInventoryData.CustomerSAPCode == null ? '' : reqInventoryData.CustomerSAPCode;
				data.CustomerSAPCode__c = gssCustomerCode;
				//判断这个客户在SF中有没有，如果没有，要剔除掉，不在这个表中匹配SF客户信息


				//首先判断一下 gssCustomerCode 的长度 和是否为一次性客户等(非数字)
				Pattern NUMBER_PATTERN = Pattern.compile('-?[0-9]+(\\.[0-9]+)?');
				//Boolean strResult = sapCode.matches('-?[0-9]+.？[0-9]*');
				Matcher isNum = NUMBER_PATTERN.matcher(gssCustomerCode);
				if (!isNum.matches()) {
					//不是数字暂不做处理
				}else{
					Integer gssCustomerCodeLength = gssCustomerCode.length();
					if (gssCustomerCodeLength < 10) {
						gssCustomerCode = ('0000000000' + gssCustomerCode).substring(gssCustomerCode.length());//加前导零
					}
				}

				//
				//客户ID放到表中
				data.Customer__c =  SFCustomerSAPCode2IdMap.get(gssCustomerCode);// == null ? '' :SFCustomerSAPCode2IdMap.get(gssCustomerCode);

				//产品线变成SF的text， GSS过来是产品大类,空调弄成ALL
				data.ProductLineText__c = '';
				String GSSPLText = reqInventoryData.ProductCategory;
				String SFPLText = '';
				if(GSSPLText.equals('冰箱')) {
					SFPLText = 'Refrigerator';
				}else if(GSSPLText.equals('冷柜')) {
					SFPLText = 'Freezer';
				}else if (GSSPLText.equals('洗衣机')) {
					SFPLText = 'WM';
				}else if(GSSPLText.equals('空调')) {
					SFPLText = 'AC;LCAC';
				}else if(GSSPLText.equals('电视')) {
					SFPLText = 'TV';
				}else {
					SFPLText = 'OtherPL';
				}
				data.ProductLineText__c = SFPLText;

				data.ProductionBase__c = reqInventoryData.ProductionBase == null ? '' : reqInventoryData.ProductionBase;
				data.ProductCategory__c = reqInventoryData.ProductCategory == null ? '' : reqInventoryData.ProductCategory;
				data.ProductType__c = reqInventoryData.ProductType == null ? '' : reqInventoryData.ProductType;
				data.BatchNumber__c = reqInventoryData.BatchNumber == null ? '' : reqInventoryData.BatchNumber;
				data.SalesBigArea__c = reqInventoryData.SalesBigArea == null ? '' : reqInventoryData.SalesBigArea;
				data.SalesSmallArea__c = reqInventoryData.SalesSmallArea == null ? '' : reqInventoryData.SalesSmallArea;
				data.CustomerName__c = reqInventoryData.CustomerName == null ? '' : reqInventoryData.CustomerName;
				data.Brand__c = reqInventoryData.Brand == null ? '' : reqInventoryData.Brand;
				data.FactoryModel__c = reqInventoryData.FactoryModel == null ? '' : reqInventoryData.FactoryModel;
				data.OrderCount__c = reqInventoryData.OrderCount == null ? '' : reqInventoryData.OrderCount;
				data.StockInCount__c = reqInventoryData.StockInCount == null ? '' : reqInventoryData.StockInCount;
				data.FirstStockInDate__c = reqInventoryData.FirstStockInDate == null ? '' : reqInventoryData.FirstStockInDate;
				data.CycleTime__c = reqInventoryData.CycleTime == null ? '' : reqInventoryData.CycleTime;
				data.CurrentDate__c = reqInventoryData.CurrentDate == null ? '' : reqInventoryData.CurrentDate;
				data.LastStockInDate__c = reqInventoryData.LastStockInDate == null ? '' : reqInventoryData.LastStockInDate;
				data.ScheduledShippingTime__c = reqInventoryData.ScheduledShippingTime == null ? '' : reqInventoryData.ScheduledShippingTime;
				data.PartialShippingTime__c = reqInventoryData.PartialShippingTime == null ? '' : reqInventoryData.PartialShippingTime;
				data.StorageCount__c = reqInventoryData.StorageCount == null ? '' : reqInventoryData.StorageCount;
				data.StockAge__c = reqInventoryData.StockAge == null ? '' : reqInventoryData.StockAge;
				data.Employee__c = reqInventoryData.Employee == null ? '' : reqInventoryData.Employee;
				data.SalesCoordinator__c = reqInventoryData.SalesCoordinator == null ? '' : reqInventoryData.SalesCoordinator;
				data.ProductState__c = reqInventoryData.ProductState == null ? '' : reqInventoryData.ProductState;
				data.CustomerModel__c = reqInventoryData.CustomerModel == null ? '' : reqInventoryData.CustomerModel;
				data.ContractNumber__c = reqInventoryData.ContractNumber == null ? '' : reqInventoryData.ContractNumber;
				data.ShippingOrderNumber__c = reqInventoryData.ShippingOrderNumber == null ? '' : reqInventoryData.ShippingOrderNumber;
				data.OverdueReason__c = reqInventoryData.OverdueReason == null ? '' : reqInventoryData.OverdueReason;
				data.DisposalMeasures__c = reqInventoryData.DisposalMeasures == null ? '' : reqInventoryData.DisposalMeasures;
				data.EstimatedBillOfLadingDate__c = reqInventoryData.EstimatedBillOfLadingDate == null ? '' : reqInventoryData.EstimatedBillOfLadingDate;
				data.ResponsiblePerson__c = reqInventoryData.ResponsiblePerson == null ? '' : reqInventoryData.ResponsiblePerson;
				data.Remark__c = reqInventoryData.Remark == null ? '' : reqInventoryData.Remark;
				
				//ProductType	产品类型 
				String ProductTypeTemp = reqInventoryData.ProductType == null ? '' : reqInventoryData.ProductType;
				//BatchNumber	批次号 
				String BatchNumberTemp = reqInventoryData.BatchNumber == null ? '' : reqInventoryData.BatchNumber;
				data.ExternalKey__c = ProductTypeTemp + BatchNumberTemp;
				inserList.add(data);
			}

			System.debug(inserList.size());
			//
			//Database.upsert(inserList,Product__c.Fields.Product_External_Id__c);
            //Database.upsert(inserList);
			Database.upsert(inserList,GSS_Inventory_Report__c.Fields.ExternalKey__c,false);
			System.debug('inserList:'+inserList);
			System.debug('同步成功！');

			//日志内容
			InterfaceLog__c ic = new InterfaceLog__c();
			ic.Class__c = 'GetGSSInventoryReport';
			ic.Time__c = System.Now();
			ic.ReturnCode__c = '1';
			ic.Req_Json__c = reqBody;
			ic.ErrorMsg__c = '';
			insert ic;

			result.IsSuccess = 'true';
			result.FailReason = '';
			System.debug(result);
			return result;

		}
		//错误数据
	}catch(Exception e) {
		System.debug(e.getMessage()+e.getLineNumber());
		//日志内容
		InterfaceLog__c ic = new InterfaceLog__c();
		ic.Class__c = 'GetGSSInventoryReport';
		ic.Time__c = System.Now();
		ic.ReturnCode__c = '0';
		ic.Req_Json__c = reqBody;
		ic.ErrorMsg__c = e.getMessage()+e.getLineNumber();
		insert ic;

		result.IsSuccess = 'False';
		result.FailReason = e.getMessage() + 'FailMessage:';
		//result.FailReason = e.getMessage() + 'FailMessage:' + debugString;
		return result;
	}

}
}