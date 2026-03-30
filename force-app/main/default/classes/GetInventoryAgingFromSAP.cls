/**********************************************************************
 * function:获取来自SAP系统的 库存账龄
 * @author:WFC
 * @url: /services/apexrest/rest
 * @data: Inventory_Aging   Inventory_Aging__c
 * date:2020-09
 *************************************************************************/

@RestResource(urlMapping='/getInventoryAgingFromSAP')
global with sharing class GetInventoryAgingFromSAP {

global class AppInput {
    List<InventoryAgingData> InventoryAgingList;
}

global class AppOutPut {
    String FailReason;
    String IsSuccess;
}
global class InventoryAgingData {
    public String AbnormalInventoryTotalQty;        //库存总量异常
    public String AbnormalInventoryTotalAmt;        //库存总量合计
    public String AClassQtyOverPlannedTurnover;     //A级数量异常-超过计划营业额
    public String AClassAmtOverPlannedTurnover;     //A级数量总计-超过计划营业额
    public String DivisionText;                     //部门文本
    public String LocationCategory;                 //位置分类
    public String StorageLocation;                  //存储位置
    public String CustomerMode;                     //客户型号
    public String Material;                         //材料
    public String CurrentQty;                       //目前的异常数量
    public String CurrentAmt;                       //目前的总量
    public String CurrentAmtAdjust;                 //目前调整总量
    public String X1monthQty;
    public String X1monthAmt;
    public String X2monthsQty;
    public String X2monthsAmt;
    public String X3monthsQty;
    public String X3monthsAmt;
    public String X4_6monthQty;
    public String X4_6monthAmt;
    public String X7mon_1YQty;
    public String X7mon_1YAmt;
    public String X1_2yearQty;
    public String X1_2yearAmt;
    public String Over2yearQty;
    public String Over2yearAmt;
    public String SalesOrganization;
    public String FactoryMode;
    public String Division;
    public String Brand;
    public String BrandDescription;
    public String Vendor;
    public String VendorName;
}



@HttpPost
global static GetInventoryAgingFromSAP.AppOutPut adoPost() {
    //GetInventoryAgingFromSAP
    RestRequest req = RestContext.request;
    String reqBody = req.requestBody.tostring();

    system.debug('doPost now, body : ' + reqBody);

    GetInventoryAgingFromSAP.AppInput input = new GetInventoryAgingFromSAP.AppInput();
    GetInventoryAgingFromSAP.AppOutPut result = new GetInventoryAgingFromSAP.AppOutPut();
    try{
        input = (GetInventoryAgingFromSAP.AppInput) JSON.deserialize(reqBody, GetInventoryAgingFromSAP.AppInput.class);
        System.debug('input===>:' + input);
        //空数据
        if (input.InventoryAgingList == null || input.InventoryAgingList.isEmpty()) {
            result.IsSuccess = 'False';
            result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
            return result;
        }else{
            List<Inventory_Aging__c> inserList = new List<Inventory_Aging__c>();

            // json中的所有的客户型号集合
            Set<String> CustomerModelSet = new Set<String>();

            // group数据集合
            Map<String,InventoryAgingData> groupMap = new Map<String,InventoryAgingData>();

            // 国家SalesOrganization
            String SalesOrganization = '';

            for (GetInventoryAgingFromSAP.InventoryAgingData reqInventoryData : input.InventoryAgingList) {
                CustomerModelSet.add(reqInventoryData.CustomerMode);
                // groupMap中的Key
                String groupKey = reqInventoryData.DivisionText + reqInventoryData.LocationCategory + reqInventoryData.StorageLocation + reqInventoryData.CustomerMode + reqInventoryData.Material;
                if(groupMap.containsKey(groupKey)){
                    // 存在则进行合并
                    InventoryAgingData oldData = groupMap.get(groupKey);
                    
                    oldData.AbnormalInventoryTotalQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.AbnormalInventoryTotalQty)? '0':reqInventoryData.AbnormalInventoryTotalQty) +
                        Decimal.valueOf(String.isBlank(oldData.AbnormalInventoryTotalQty) ? '0':oldData.AbnormalInventoryTotalQty));
                    oldData.AbnormalInventoryTotalAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.AbnormalInventoryTotalAmt)? '0':reqInventoryData.AbnormalInventoryTotalAmt) +
                        Decimal.valueOf(String.isBlank(oldData.AbnormalInventoryTotalAmt)? '0':oldData.AbnormalInventoryTotalAmt));
                    oldData.AClassQtyOverPlannedTurnover = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.AClassQtyOverPlannedTurnover)? '0':reqInventoryData.AClassQtyOverPlannedTurnover) + 
                        Decimal.valueOf(String.isBlank(oldData.AClassQtyOverPlannedTurnover)? '0':oldData.AClassQtyOverPlannedTurnover));
                    oldData.AClassAmtOverPlannedTurnover = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.AClassAmtOverPlannedTurnover)? '0':reqInventoryData.AClassAmtOverPlannedTurnover) +
                        Decimal.valueOf(String.isBlank(oldData.AClassAmtOverPlannedTurnover)? '0':oldData.AClassAmtOverPlannedTurnover));
                    oldData.CurrentAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.CurrentAmt)? '0':reqInventoryData.CurrentAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.CurrentAmt)? '0':oldData.CurrentAmt));
                    oldData.CurrentQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.CurrentQty)? '0':reqInventoryData.CurrentQty) + 
                        Decimal.valueOf(String.isBlank(oldData.CurrentQty)? '0':oldData.CurrentQty));
                    oldData.X1monthQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X1monthQty)? '0':reqInventoryData.X1monthQty) + 
                        Decimal.valueOf(String.isBlank(oldData.X1monthQty)? '0':oldData.X1monthQty));
                    oldData.X1monthAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X1monthAmt)? '0':reqInventoryData.X1monthAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X1monthAmt)? '0':oldData.X1monthAmt));
                    oldData.X2monthsQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X2monthsQty)? '0':reqInventoryData.X2monthsQty) +
                        Decimal.valueOf(String.isBlank(oldData.X2monthsQty)? '0':oldData.X2monthsQty));
                    oldData.X2monthsAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X2monthsAmt)? '0':reqInventoryData.X2monthsAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X2monthsAmt)? '0':oldData.X2monthsAmt));
                    oldData.X3monthsQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X3monthsQty)? '0':reqInventoryData.X3monthsQty) + 
                        Decimal.valueOf(String.isBlank(oldData.X3monthsQty)? '0':oldData.X3monthsQty));
                    oldData.X3monthsAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X3monthsAmt)? '0':reqInventoryData.X3monthsAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X3monthsAmt)? '0':oldData.X3monthsAmt));
                    oldData.X4_6monthQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X4_6monthQty)? '0':reqInventoryData.X4_6monthQty) + 
                        Decimal.valueOf(String.isBlank(oldData.X4_6monthQty)? '0':oldData.X4_6monthQty));
                    oldData.X4_6monthAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X4_6monthAmt)? '0':reqInventoryData.X4_6monthAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X4_6monthAmt)? '0':oldData.X4_6monthAmt));
                    oldData.X7mon_1YQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X7mon_1YQty)? '0':reqInventoryData.X7mon_1YQty) + 
                        Decimal.valueOf(String.isBlank(oldData.X7mon_1YQty)? '0':oldData.X7mon_1YQty));
                    oldData.X7mon_1YAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X7mon_1YAmt)? '0':reqInventoryData.X7mon_1YAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X7mon_1YAmt)? '0':oldData.X7mon_1YAmt));
                    oldData.X1_2yearQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X1_2yearQty)? '0':reqInventoryData.X1_2yearQty) + 
                        Decimal.valueOf(String.isBlank(oldData.X1_2yearQty)? '0':oldData.X1_2yearQty));
                    oldData.X1_2yearAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.X1_2yearAmt)? '0':reqInventoryData.X1_2yearAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.X1_2yearAmt)? '0':oldData.X1_2yearAmt));
                    oldData.Over2yearQty = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.Over2yearQty)? '0':reqInventoryData.Over2yearQty) + 
                        Decimal.valueOf(String.isBlank(oldData.Over2yearQty)? '0':oldData.Over2yearQty));
                    oldData.Over2yearAmt = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.Over2yearAmt)? '0':reqInventoryData.Over2yearAmt) + 
                        Decimal.valueOf(String.isBlank(oldData.Over2yearAmt)? '0':oldData.Over2yearAmt));
                    oldData.CurrentAmtAdjust = String.valueOf(Decimal.valueOf(String.isBlank(reqInventoryData.CurrentAmtAdjust)? '0':reqInventoryData.CurrentAmtAdjust) + 
                        Decimal.valueOf(String.isBlank(oldData.CurrentAmtAdjust)? '0':oldData.CurrentAmtAdjust));

                    groupMap.put(groupKey, oldData);
                
                } else{
                    // 不存在则保存在map中
                    groupMap.put(groupKey, reqInventoryData);
                }
            }

            Map<String,String> HisenseEntity2SFSalesRegionMap = new Map<String,String>();
            for(Mapping__c mp : [Select Name,Mapping_Code__c,Mapping_Description__c from Mapping__c where recordType.developerName = 'Business_Orgnization_and_Name_Mapping']){
                HisenseEntity2SFSalesRegionMap.put(mp.Name,mp.Mapping_Description__c);
            }

            Map<String,String> CustomerProductEXTID2IDMap = new Map<String,String>();
            for(Customer_Model_Product__c cmp : [Select id,ExternalId__c from Customer_Model_Product__c where name in: CustomerModelSet]){
                CustomerProductEXTID2IDMap.put(cmp.ExternalId__c,cmp.id);
            }

            // 赋值入库
            for(InventoryAgingData reqInventoryData : groupMap.values()){

                Inventory_Aging__c data = new Inventory_Aging__c();

                data.Abnormal_Inventory_Total_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.AbnormalInventoryTotalQty)? '0':reqInventoryData.AbnormalInventoryTotalQty);
                data.Abnormal_Inventory_Total_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.AbnormalInventoryTotalAmt)? '0':reqInventoryData.AbnormalInventoryTotalAmt);
                data.A_Class_Qty_Over_planned_turnover__c = Decimal.valueOf(String.isBlank(reqInventoryData.AClassQtyOverPlannedTurnover)? '0':reqInventoryData.AClassQtyOverPlannedTurnover);
                data.A_Class_Amt_Over_planned_turnover__c = Decimal.valueOf(String.isBlank(reqInventoryData.AClassAmtOverPlannedTurnover)? '0':reqInventoryData.AClassAmtOverPlannedTurnover);
                data.Division_text__c = reqInventoryData.DivisionText == null ? '' : reqInventoryData.DivisionText;
                data.Location_Category__c = reqInventoryData.LocationCategory == null ? '' : reqInventoryData.LocationCategory;
                data.Storage_Location__c = reqInventoryData.StorageLocation == null ? '' : reqInventoryData.StorageLocation;
                // data.Customer_Mode__c = reqInventoryData.CustomerMode == null ? '' : reqInventoryData.CustomerMode;
                data.Customer_Mode__c = CustomerProductEXTID2IDMap.get(reqInventoryData.CustomerMode + HisenseEntity2SFSalesRegionMap.get(reqInventoryData.SalesOrganization));
                data.Customer_Model__c = reqInventoryData.CustomerMode == null ? '' : reqInventoryData.CustomerMode;
                data.Material__c = reqInventoryData.Material == null ? '' : reqInventoryData.Material;
                data.Sales_Organization__c = reqInventoryData.SalesOrganization == null ? '' : reqInventoryData.SalesOrganization;
                data.Current_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.CurrentAmt)? '0':reqInventoryData.CurrentAmt);
                data.Current_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.CurrentQty)? '0':reqInventoryData.CurrentQty);
                data.X1month_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X1monthQty)? '0':reqInventoryData.X1monthQty);
                data.X1month_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X1monthAmt)? '0':reqInventoryData.X1monthAmt);
                data.X2months_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X2monthsQty)? '0':reqInventoryData.X2monthsQty);
                data.X2months_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X2monthsAmt)? '0':reqInventoryData.X2monthsAmt);
                data.X3months_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X3monthsQty)? '0':reqInventoryData.X3monthsQty);
                data.X3months_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X3monthsAmt)? '0':reqInventoryData.X3monthsAmt);
                data.X4_6month_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X4_6monthQty)? '0':reqInventoryData.X4_6monthQty);
                data.X4_6month_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X4_6monthAmt)? '0':reqInventoryData.X4_6monthAmt);
                data.X7mon_1Y_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X7mon_1YQty)? '0':reqInventoryData.X7mon_1YQty);
                data.X7mon_1Y_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X7mon_1YAmt)? '0':reqInventoryData.X7mon_1YAmt);
                data.X1_2year_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.X1_2yearQty)? '0':reqInventoryData.X1_2yearQty);
                data.X1_2year_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.X1_2yearAmt)? '0':reqInventoryData.X1_2yearAmt);
                data.Over_2year_Qty__c = Decimal.valueOf(String.isBlank(reqInventoryData.Over2yearQty)? '0':reqInventoryData.Over2yearQty);
                data.Over_2year_Amt__c = Decimal.valueOf(String.isBlank(reqInventoryData.Over2yearAmt)? '0':reqInventoryData.Over2yearAmt);
                data.Factory_Mode__c = reqInventoryData.FactoryMode == null ? '' : reqInventoryData.FactoryMode;
                data.Division__c = reqInventoryData.Division == null ? '' : reqInventoryData.Division;
                data.Brand__c = reqInventoryData.Brand == null ? '' : reqInventoryData.Brand;
                data.Brand_Description__c = reqInventoryData.BrandDescription == null ? '' : reqInventoryData.BrandDescription;
                data.Vendor__c = reqInventoryData.Vendor == null ? '' : reqInventoryData.Vendor;
                data.Vendor_Name__c = reqInventoryData.VendorName == null ? '' : reqInventoryData.VendorName;
                data.Current_Amt_Adjust__c = Decimal.valueOf(String.isBlank(reqInventoryData.CurrentAmtAdjust)? '0':reqInventoryData.CurrentAmtAdjust);
                data.External_Key__c = data.Division_text__c + data.Location_Category__c + data.Storage_Location__c + data.Material__c + data.Sales_Organization__c + data.Customer_Mode__c;
                
                SalesOrganization = data.Sales_Organization__c;

                inserList.add(data);
            }
            
            System.debug(inserList.size());
            // Database.upsert(inserList);
            // Database.upsert(inserList,Inventory_Aging__c.Fields.ExternalKey__c);

            // 删除原始数据 
            // List<Inventory_Aging__c> oldList = [select id from Inventory_Aging__c where Sales_Organization__c =: SalesOrganization];
            List<Inventory_Aging__c> oldList = [select id from Inventory_Aging__c];
            Database.delete(oldList);

            List<Database.SaveResult> insertResult = Database.insert(inserList, false);
            // 插入不成功
            for (Database.SaveResult r : insertResult){
                if (!r.isSuccess()){
                    for (Database.Error e : r.getErrors()){ 
                        //日志内容
                        InterfaceLog__c ic = new InterfaceLog__c();
                        ic.Class__c = 'GetInventoryAgingFromSAP';
                        ic.Time__c = System.Now();
                        ic.ReturnCode__c = '0';
                        //ic.Req_Json__c = reqBody;
                        ic.ErrorMsg__c = '报错的这条库存数据是：'+ r.getId() + 'error has occurred.' + e.getStatusCode() + ': ' + e.getMessage() + '报错eee是：'+ e;
                        insert ic;
                    }
                }
            }
            System.debug('同步成功！');

            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetInventoryAgingFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            // ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = '';
            insert ic;

            result.IsSuccess = 'true';
            result.FailReason = '';
            System.debug(result);
            return result;

        }
        //错误数据
    }catch(Exception e) {
        System.debug('error------' + e.getMessage()+e.getLineNumber());
        //日志内容
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'GetInventoryAgingFromSAP';
        ic.Time__c = System.Now();
        ic.ReturnCode__c = '0';
        // ic.Req_Json__c = reqBody;
        ic.ErrorMsg__c = e.getMessage()+e.getLineNumber();
        insert ic;

        result.IsSuccess = 'False';
        result.FailReason = e.getMessage() + 'FailMessage:';
        //result.FailReason = e.getMessage() + 'FailMessage:' + debugString;
        return result;
    }

}
}