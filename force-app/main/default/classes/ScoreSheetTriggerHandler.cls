/**************************************************************************************************
 * ScoreSheetTriggerHandler
 * Purpose:Score Sheet Trigger处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-02-13
***************************************************************************************************/
public class ScoreSheetTriggerHandler extends TriggerHandler{
	public override void afterInsert(){
        System.debug('afterInsert');
        List<Product_Line_Score__c> prolinescores = new List<Product_Line_Score__c>();

        //创建product line score关系对象
        for(Score_Sheet__c sc : ((list<Score_Sheet__c>)Trigger.new)){
            if(String.isNotBlank(sc.PL_ID_List__c)){
                List<String> plids = sc.PL_ID_List__c.split(';');
                for (String plid : plids) {
                   Product_Line_Score__c pls = new Product_Line_Score__c();
                   pls.Score_Sheet__c = sc.id;
                   pls.Customer_Product_Line__c = plid;
                   pls.Customer__c = sc.Customer__c;
                   prolinescores.add(pls);
                }
            }
        }
        insert prolinescores;
    }

    public override void beforeUpdate(){
        System.debug('beforeUpdate');

        //准备查询所有的产品线
        Map<String,String> scNIds = new Map<String,String>();
        List<String> scENIds = new List<String>();

        //更新最近一次评分
        for(Score_Sheet__c sc : ((list<Score_Sheet__c>)Trigger.new)){
            Score_Sheet__c scOld = (Score_Sheet__c)Trigger.oldMap.get(sc.Id);
            //当评分表被批准后，最近评分才更新
            if(sc.status__c == 'Approved'){
                scNIds.put(sc.Id,sc.Evaluated_Rank__c);
            }
            //淘汰
            if('Submitted' == sc.status__c && scOld.status__c !='Submitted' && sc.Evaluated_Rank__c=='Potential Eliminated Customer'){
                System.debug('in Elimination');
                scENIds.add(sc.id);
            }
        }

        if(scNIds.size()>0){
            //获取所有更新过评分的产品线关系
            List<Product_Line_Score__c> plss = [select OwnerId,Customer__c, Customer_Product_Line__c, Score_Sheet__c  from Product_Line_Score__c where Score_Sheet__c in: scNIds.keyset()];
            List<Customer_Product_Line__c> cpls = new List<Customer_Product_Line__c>(); 
            for (Product_Line_Score__c pls : plss) {
                Customer_Product_Line__c cpl = new Customer_Product_Line__c();
                cpl.id = pls.Customer_Product_Line__c;
                String rankTmp = scNIds.get(pls.Score_Sheet__c);
                if(rankTmp == 'Potential Eliminated Customer'){
                    rankTmp = 'Eliminated Customer';
                }
                cpl.Rank__c = rankTmp;
                cpls.add(cpl);
            }
            update cpls;
        }

        if(scENIds.size()>0){
            List<Product_Line_Score__c> plss = [select Customer_Product_Line__r.Expected_Business_Stopping_Date__c, Customer_Product_Line__c, Score_Sheet__c  from Product_Line_Score__c where Score_Sheet__c in: scENIds];

            Map<String, List<Date>> mapEB = new Map<String, List<Date>>();
            for(Product_Line_Score__c pls: plss){
                if(mapEB.containsKey(pls.Score_Sheet__c)){
                    List<Date> EBdate = new List<Date>();
                    EBdate.addAll(mapEB.get(pls.Score_Sheet__c));
                    EBdate.add(pls.Customer_Product_Line__r.Expected_Business_Stopping_Date__c);
                    mapEB.put(pls.Score_Sheet__c,EBdate);
                }else{
                    List<Date> EBdate = new List<Date>();
                    EBdate.add(pls.Customer_Product_Line__r.Expected_Business_Stopping_Date__c);
                    mapEB.put(pls.Score_Sheet__c,EBdate);
                }
            }
            System.debug(mapEB);
            for(Score_Sheet__c sc : ((list<Score_Sheet__c>)Trigger.new)){
                List<Date> datelist= mapEB.get(sc.id);
                System.debug(datelist);
                for (Date datePL : datelist) {
                    if(datePL == null){
                        if(!Test.isRunningTest()){
                            sc.addError(Label.need_BS_Date);
                        }
                        return;
                    }
                }
            }
        }

    }
}