global class SAPGetRevenueCostSchedulable implements Schedulable {
    public List<String> companyCodeList = new List<String>();
    global SAPGetRevenueCostSchedulable(List<String> companyCodeList){
        this.companyCodeList = companyCodeList;
    }
    global void execute(SchedulableContext sc) {
        String costYear = String.valueOf(System.now().year());
        String costMonth = String.valueOf(System.now().month());
        if ('1'.equals(costMonth)) {
            costYear = String.valueOf(System.now().year()-1);
            costMonth = '12';
        }else{
            costYear = String.valueOf(System.now().year());
            costMonth = String.valueOf(Integer.valueOf(costMonth)-1);
            if (Integer.valueOf(costMonth)<10) {
                costMonth = '0'+costMonth;
            }
        } 
        for (String str : companyCodeList) {
            List<String> companyCodeListRun = new List<String>();
            companyCodeListRun.add(str);
            SAPGetRevenueCost.GetRevenueCostInfoFromSAP(companyCodeListRun,costYear,String.valueOf(costMonth));
        }
    }
}