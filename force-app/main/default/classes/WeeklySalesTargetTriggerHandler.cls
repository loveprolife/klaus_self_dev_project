public class WeeklySalesTargetTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public void handle() {
        if(Trigger.isBefore && Trigger.isInsert){
            for (Weekly_Sales_Target__c wst : ((list<Weekly_Sales_Target__c>)Trigger.new)) {

                if(wst.From_Week__c == wst.week__c && String.isNotBlank(wst.Store__c)){
                    List<Weekly_Sales_Target__c> lastCycle = [SELECT Id,From_Week__c,To_Week__c,Expect_Unit_Sell_Out__c FROM Weekly_Sales_Target__c 
                        WHERE Sales_Region__c =: wst.Sales_Region__c
                        AND Channel_item__c =: wst.Channel_item__c
                        AND Store__c =: wst.Store__c
                        AND Product_Line__c =: wst.Product_Line__c
                        AND Model__c =: wst.Model__c
                        AND Year__c =: System.now().year()
                        AND Week__c < :wst.Week__c
                        ORDER BY Week__c desc limit 1];
                  
                    if(lastCycle != null && lastCycle.size() > 0){

                        Weekly_Sales_Target__c lastWst = lastCycle.get(0);
                        if(lastWst.Expect_Unit_Sell_Out__c > 0){
                            wst.Not_completed_last_cycle__c = (lastWst.Expect_Unit_Sell_Out__c / (wst.To_Week__c - wst.From_Week__c + 1)).setScale(0, System.RoundingMode.HALF_UP);
                        }else{
                            wst.Not_completed_last_cycle__c = 0;
                        }
                    }
                }

                if(wst.Plan_Target__c == null){
                    wst.Plan_Target__c = 0;
                }
                if(wst.BA_ACH__c == null){
                    wst.BA_ACH__c = 0;
                }
                if(wst.RSP__c == null){
                    wst.RSP__c = 0;
                }
                if(wst.Not_completed_last_week__c == null){
                    wst.Not_completed_last_week__c = 0;
                }
                if(wst.Not_completed_last_cycle__c == null){
                    wst.Not_completed_last_cycle__c = 0;
                }
            }
        }

        if(Trigger.isAfter && Trigger.isInsert){
            for (Weekly_Sales_Target__c wst : ((list<Weekly_Sales_Target__c>)Trigger.new)) {
                if(wst.week__c != wst.To_Week__c && String.isNotBlank(wst.Store__c)){
                    GenerateWstByWeek g = new GenerateWstByWeek(wst, 'New');
                    g.GenerateWstByWeek();
                    //String jobID = System.enqueueJob(new GenerateWstByWeek(wst, 'New'));
                }
            }
        }


        if(Trigger.isBefore && Trigger.isUpdate){
            for (Weekly_Sales_Target__c wst : ((list<Weekly_Sales_Target__c>)Trigger.new)) {
                
                if(wst.Plan_Target__c == null){
                    wst.Plan_Target__c = 0;
                }
                if(wst.BA_ACH__c == null){
                    wst.BA_ACH__c = 0;
                }
                if(wst.RSP__c == null){
                    wst.RSP__c = 0;
                }
                if(wst.Not_completed_last_week__c == null){
                    wst.Not_completed_last_week__c = 0;
                }
                if(wst.Not_completed_last_cycle__c == null){
                    wst.Not_completed_last_cycle__c = 0;
                }
                
            }
        }

        if(Trigger.isAfter && Trigger.isUpdate){
            for (Weekly_Sales_Target__c wst : ((list<Weekly_Sales_Target__c>)Trigger.new)) {
                Weekly_Sales_Target__c wstOld = (Weekly_Sales_Target__c)Trigger.oldMap.get(wst.Id);
                if(wst.Expect_Unit_Sell_Out__c != wstOld.Expect_Unit_Sell_Out__c && String.isNotBlank(wst.Store__c)){
                    GenerateWstByWeek g = new GenerateWstByWeek(wst, 'Update');
                    g.GenerateWstByWeek();
                    //String jobID = System.enqueueJob(new GenerateWstByWeek(wst, 'Update'));
                }
            }
        }
    
        if (Trigger.isBefore && Trigger.isDelete) {
            for (Weekly_Sales_Target__c wst : ((list<Weekly_Sales_Target__c>)Trigger.old)) {
                if(!Test.isRunningTest() && !Label.Undo_Changes_Profile_Exclude.contains(currentUser.Profile.name)){
                    wst.addError('Cannot be deleted');
                    return;
                }
            }
        }

        if(Trigger.isAfter && Trigger.isDelete){

        }
    }

    //异步调用生成后续的周
    public class GenerateWstByWeek{
        Weekly_Sales_Target__c target;
        String actionFlg;
        public GenerateWstByWeek(Weekly_Sales_Target__c target, String actionFlg){
            this.target = target;
            this.actionFlg = actionFlg;
        }
        public void generateWstByWeek() {
            Weekly_Sales_Target__c thisWst = new Weekly_Sales_Target__c();
            if(actionFlg == 'New'){
                thisWst = target.clone();
                thisWst.Id = null;
                thisWst.Not_completed_last_week__c = target.Expect_Unit_Sell_Out__c;
                thisWst.week__c = target.week__c + 1;
                thisWst.External_key__c = thisWst.Sales_Region__c + '_' 
                                        + thisWst.Week__c + '_'
                                        + thisWst.Channel_item__c + '_'
                                        + thisWst.Store__c + '_'
                                        + thisWst.Product_Line__c + '_'
                                        + thisWst.Model__c + '_'
                                        + System.now().year();
                insert thisWst;
            }else{
                if(target.Week__c < target.To_Week__c){
                    thisWst.External_key__c = target.Sales_Region__c + '_' 
                                            + (target.Week__c+1) + '_'
                                            + target.Channel_item__c + '_'
                                            + target.Store__c + '_'
                                            + target.Product_Line__c + '_'
                                            + target.Model__c + '_'
                                            + System.now().year();
                    thisWst.Not_completed_last_cycle__c = target.Not_completed_last_cycle__c;
                    if(target.Expect_Unit_Sell_Out__c > 0){
                        thisWst.Not_completed_last_week__c = target.Expect_Unit_Sell_Out__c;
                    }else{
                        thisWst.Not_completed_last_week__c = 0;
                    }
                    
                    Database.upsert(thisWst,Weekly_Sales_Target__c.Fields.External_key__c,true);
                }else{
                    List<Weekly_Sales_Target__c> nextCycle = [SELECT Id,From_Week__c,To_Week__c FROM Weekly_Sales_Target__c 
                    WHERE Sales_Region__c =: target.Sales_Region__c
                    AND Channel_item__c =: target.Channel_item__c
                    AND Store__c =: target.Store__c
                    AND Product_Line__c =: target.Product_Line__c
                    AND Model__c =: target.Model__c
                    AND Year__c =: target.Year__c
                    AND Week__c > :target.To_Week__c
                    ORDER BY Week__c limit 1];

                    if(nextCycle != null && nextCycle.size() > 0){
                        thisWst = nextCycle.get(0);

                        if(target.Expect_Unit_Sell_Out__c > 0){
                            thisWst.Not_completed_last_cycle__c = (target.Expect_Unit_Sell_Out__c / (thisWst.To_Week__c - thisWst.From_Week__c + 1)).setScale(0, System.RoundingMode.HALF_UP);
                        }else{
                            thisWst.Not_completed_last_cycle__c = 0;
                        }
                        Database.update(thisWst, true);
                    }
                }
            }
        }
    }   

    // public void upsertChannel(){} {

    // }
}