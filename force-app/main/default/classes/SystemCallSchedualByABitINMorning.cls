/**
 * @description       : 每日凌晨1点定时任务
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 05-11-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global class SystemCallSchedualByABitINMorning implements Schedulable {

    public String companyCode;

    global SystemCallSchedualByABitINMorning() {
        this.companyCode = '8410';
    }

    global void execute(SchedulableContext sc) {
        String dateYesterday = String.valueOf(System.now().addDays(-1).format('yyyy-MM-dd'));

        //门店接口调用
        Output getShopOutput = new Output();
        getShopOutput.AccountGroup = 'C000';
        getShopOutput.SyncStartDate = dateYesterday;
        getShopOutput.syncEndDate = dateYesterday;
        getShopOutput.CompanyCodeList = new List<String>{'8410'};
        if (!Test.isRunningTest()) {
            GetCustomerInfoFromSAP.getCustomerInfo(new List<String>{'8410', JSON.serialize(getShopOutput)}, '', '');
        }

        String ISDATE = System.now().addDays(-1).format('yyyyMMdd') + '';
        String IEDATE = System.now().addDays(-1).format('yyyyMMdd') + '';

        if (!Test.isRunningTest()) {

            //Utility.setNextSchedulable('SystemCallSchedualByMorningGetPerson', 10);

            // //门店巡店员接口
            // GetResponsiblePersonFROMSAP.getPersonInfo(companyCode, ISDATE, IEDATE);
    
            //机型属性同步接口
            GetProductModelFROMSAP.getProduct(ISDATE,IEDATE);
        }

        //销售目标不定时导入, 每天运行定时
        Share_Common_IntegrationBatch salesTargetBranchCompanyUseBatch = new Share_Common_IntegrationBatch(
            'Sales_Target_Branch_Company_Use__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(salesTargetBranchCompanyUseBatch, 30);
    }

    public class Output{
        public String SyncStartDate;
        public String SyncEndDate;
        public String AccountGroup;
        public String CustomerCode;
        public List<String> CompanyCodeList;

        public Output(){
            this.SyncStartDate = '';
            this.SyncEndDate = '';
            this.AccountGroup = '';
            this.CustomerCode = '';
            this.CompanyCodeList = new List<String>();
        }
    }
}