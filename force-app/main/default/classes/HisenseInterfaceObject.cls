/**********************************************************************
Name:  HisenseInterfaceObject 
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL                                
1.0 -    Pierre            2019-02-27         Created
***********************************************************************/
global class HisenseInterfaceObject {
    //订单列表
    global class OrderNumberList{                  
        public List<String>   OrderNumberList     {get;set;}     //产品明细列表                                                       
        public String OrderItemNumber {get;set;}                                    
    }

    //删除订单
    global class DeletedOrder{
        public String  OrderNo      {get;set;}   //订单                             
    }

    //接口返回
    global class GetDeletedOrderFromSAPResult{
        public String IsSuccess {get; set;} 
        public String FailReason {get; set;} 
    }

        //同步信用额度条件
    global class SyncCreditLimitCondition {
        public String SAPCustomerCode {get; set;} //同步CustomerSAP编号
    }

        //同步信用额度结果
    global class SyncCreditLimitResult {
        public String SAPCustomerCode {get; set;} //同步CustomerSAP编号
        public String TotalQuota {get; set;} //信用额度
        public String UsedQuota {get; set;} //已用额度
        public String RemainQuota {get; set;} //剩余额度
        public String TotalOverdueAmount {get; set;} //超期未回款总额
        public String CreditCurrency {get; set;} //额度币种
        public String OverdueCurrency {get; set;} //超期未回款币种
        public String IsSuccess {get; set;} 
        public String FailReason {get; set;} 
        public String rst {get; set;} 
        public String rstMsg {get; set;} 
        public String token {get; set;} 
        public String CreditAccountCode {get; set;} 
        public String CreditAccountName {get; set;} 
    }
    //同步ACProduct ---- 暂未使用
    // global class ACProductInfo{
    //      public String FactoryModel {get; set;}  
    //      public String HighEnd {get; set;}
    //      public String OutdoorProductModel {get; set;}
    //      public String ProductPositioning {get; set;}
    //      public String IndoorEnclosure {get; set;}
    //      public String RemoteControlModel {get; set;}
    //      public String OutdoorProductionModel {get; set;}
    //      public String PressModel {get; set;}
    //      public String WiFIModuleRequirements {get; set;}
    //      public String OutdoorEnclosure {get; set;}
    // }                   

}