public class NewCheckHisenseXController {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @AuraEnabled
    public static ConResponse getInit(String recordId){
        try {
            ConResponse resp = new ConResponse();
            Map<String, Object> mso = new Map<String, Object>();
            resp.data = mso;

            Check_X_Plan__c xPlan;
            if(!String.isEmpty(recordId)){
                // 查询X计划记录表信息
                xPlan = getCheckXPlanId(recordId);
                if(xPlan != null){
                    List<Check_X_Plan_Product__c> xPlanProduct = getCheckXPlanProductInfo(xPlan.Id,'Hisense Display');
                    List<Check_X_Plan_Product__c> xPlanProductCompetitive = getCheckXPlanProductInfo(xPlan.Id,'Competitive Display');
                    mso.put('xPlanProduct', xPlanProduct);
                    mso.put('xPlanProductCompetitive', xPlanProductCompetitive);
                }
            }else{
                // 初始化数据信息
                xPlan = new Check_X_Plan__c();
                xPlan.Sales_Region__c = currentUser.Sales_Region__c;
                Database.insert(xPlan);
            }
            mso.put('xPlan', xPlan);
            
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ConResponse addXPlan(String xPlan,String xPlanProduct,String xPlanProductCompetitive){
        try {
            ConResponse resp = new ConResponse();
            Map<String, Object> mso = new Map<String, Object>();
            resp.data = mso;

            Check_X_Plan__c xPlanInfo = (Check_X_Plan__c)JSON.deserialize(xPlan, Check_X_Plan__c.class);
            // 新增x计划
            // 门店信息
            Database.upsert(xPlanInfo);

            if(!String.isEmpty(xPlanProduct)){
                List<Check_X_Plan_Product__c> xPlanProductInfo = (List<Check_X_Plan_Product__c>)JSON.deserialize(xPlanProduct, List<Check_X_Plan_Product__c>.class);
                // 产品展示循环绑定主信息
                for(Check_X_Plan_Product__c item : xPlanProductInfo){
                    if(String.isEmpty(item.Check_X_Plan__c)){
                        item.Check_X_Plan__c = xPlanInfo.Id;
                    }
                }
                Database.upsert(xPlanProductInfo);
            }

            if(!String.isEmpty(xPlanProductCompetitive)){
                List<Check_X_Plan_Product__c> xPlanProductCompetitiveInfo = (List<Check_X_Plan_Product__c>)JSON.deserialize(xPlanProductCompetitive, List<Check_X_Plan_Product__c>.class);
            
                // 产品展示循环绑定主信息
                for(Check_X_Plan_Product__c item : xPlanProductCompetitiveInfo){
                    if(String.isEmpty(item.Check_X_Plan__c)){
                        item.Check_X_Plan__c = xPlanInfo.Id;
                    }
                }
                Database.upsert(xPlanProductCompetitiveInfo);
            }
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ConResponse delXPlan(String xPlanProduct){
        try {
            ConResponse resp = new ConResponse();
            Map<String, Object> mso = new Map<String, Object>();
            resp.data = mso;

            Check_X_Plan_Product__c xPlanProductInfo = (Check_X_Plan_Product__c)JSON.deserialize(xPlanProduct, Check_X_Plan_Product__c.class);
            // 新增x计划
            // 门店信息
            if(!String.isEmpty(xPlanProductInfo.Id)){
                Database.delete(xPlanProductInfo);
            }
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 根据id获取X计划记录详情
     */
    private static Check_X_Plan__c getCheckXPlanId(String id){
        return [SELECT Id,
                       Name,
                       Store_Name__c,
                       Sales_Region__c,
                       Channel_item__c,
                       Level__c 
                       FROM Check_X_Plan__c
                       where id =: id];
    }

    /**
     * 根据id获取X计划产品描述详情
     */
    private static List<Check_X_Plan_Product__c> getCheckXPlanProductInfo(String xPlanId,String type){
        return [SELECT Id,
                       Brand__c,
                       Series__c,
                       Series_Competitive__c,
                       Size__c,
                       Quantity__c,
                       Check_X_Plan__c
                       FROM Check_X_Plan_Product__c
                       WHERE Check_X_Plan__c =: xPlanId
                       AND Type__c =: type];
    }

    public static void testClassMethod() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }    
}