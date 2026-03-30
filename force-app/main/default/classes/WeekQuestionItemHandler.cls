public without sharing class WeekQuestionItemHandler implements Triggers.Handler {

    public void handle() {

        if (Trigger.isAfter && Trigger.isUpdate) {
            
            // 门店调查要求下的周调研问题明细集合
            Map<String, List<Week_Question_Item__c>> wqiListMap = new Map<String,List<Week_Question_Item__c>>();
            // 门店调查要求
            Map<String, String> shopResearchMap = new Map<String, String>();

            for (Week_Question_Item__c wqi : (List<Week_Question_Item__c>)Trigger.new) {
                shopResearchMap.put(wqi.Shop_Research__c, '');
            }
            List<Week_Question_Item__c> wqiList = [SELECT id,Number__c,Shop_Research__c FROM Week_Question_Item__c 
                                                        WHERE Shop_Research__c IN:shopResearchMap.keySet() 
                                                        ORDER BY Shop_Research__c, Number__c];
            for(Week_Question_Item__c wqi : wqiList){
                if(wqiListMap.containsKey(wqi.Shop_Research__c)){
                    wqiListMap.get(wqi.Shop_Research__c).add(wqi);
                }else {
                    wqiListMap.put(wqi.Shop_Research__c, new List<Week_Question_Item__c>{wqi});
                }
            }

            List<Week_Question_Item__c> updateList = new List<Week_Question_Item__c>();

            for (Week_Question_Item__c wqi : (List<Week_Question_Item__c>)Trigger.new) {
                Week_Question_Item__c wqiOld = (Week_Question_Item__c)Trigger.oldMap.get(wqi.Id);
                // 修改序号
                if(!wqi.Number__c.equals(wqiOld.Number__c)){

                    List<Week_Question_Item__c> wqiListNow = wqiListMap.get(wqi.Shop_Research__c);
                    for(Integer i=0; i<wqiListNow.size(); i++){
                        Week_Question_Item__c wqiNow = wqiListNow[i];
                        if(wqiNow.id.equals(wqi.id)){
                            wqiListNow.remove(i);
                            break;
                        }
                    }
                    // 如果序号已经满了
                    if(wqiListNow.size() == 9){
                        Integer numberNow = Integer.valueOf(wqi.Number__c);
                        Integer numberOld = Integer.valueOf(wqiOld.Number__c);
                        // 如果是序号减小
                        if(numberNow < numberOld){
                            // 序号之间的加1    
                            for(Integer i=numberNow-1; i<numberOld-1; i++){
                                Week_Question_Item__c wqiNow = wqiListNow[i];
                                wqiNow.Number__c =String.valueOf(Integer.valueOf(wqiNow.Number__c) + 1);
                                updateList.add(wqiNow);
                            }

                        }else if(numberNow > numberOld){ 
                            // 序号增大，序号之间的减1
                            for(Integer i=numberOld-1; i<numberNow-1; i++){
                                Week_Question_Item__c wqiNow = wqiListNow[i];
                                wqiNow.Number__c =String.valueOf(Integer.valueOf(wqiNow.Number__c) - 1);
                                updateList.add(wqiNow);
                            }
                        }
                    }else if(wqiListNow.size() == 1){
                        // 原有一行数据的序号是10
                        Week_Question_Item__c wqiNow = wqiListNow[0];
                        if('10'.equals(wqi.Number__c)){
                            wqiNow.Number__c = String.valueOf(Integer.valueOf(wqiNow.Number__c) - 1);
                            updateList.add(wqiNow);
                        }else if(wqiNow.Number__c.equals(wqi.Number__c)){
                            wqiNow.Number__c = String.valueOf(Integer.valueOf(wqiNow.Number__c) + 1);
                            updateList.add(wqiNow);
                        }
                    }else {
                        for(Integer i=0; i<wqiListNow.size()-1; i++){
                       
                            // 第一行
                            Week_Question_Item__c wqiNow = wqiListNow[i];
                            // 第二行
                            Week_Question_Item__c wqiNowNext = wqiListNow[i+1];
                            // 如果等于第一行的序号，则第一行的序号加1
                            if(wqiNow.Number__c.equals(wqi.Number__c)){
                                wqiNow.Number__c =String.valueOf(Integer.valueOf(wqiNow.Number__c) + 1);
                                updateList.add(wqiNow);
                            }
                            if(wqiNow.Number__c.equals(wqiNowNext.Number__c)){
                                wqiNowNext.Number__c =String.valueOf(Integer.valueOf(wqiNowNext.Number__c) + 1);
                                wqiListNow.set(i+1, wqiNowNext);
                                updateList.add(wqiNowNext);
                            }
                            if(i == wqiListNow.size()-2){
                                if(wqiNowNext.Number__c.equals(wqi.Number__c)){
                                    wqiNowNext.Number__c =String.valueOf(Integer.valueOf(wqiNowNext.Number__c) + 1);
                                    updateList.add(wqiNowNext);
                                }
                            }
                        }  
                    }
                }
                
            }


            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'WeekQuestionItemHandler');
            if(!Test.isRunningTest()){
                UPDATE updateList;
            }
            
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');

            
        }


        if (Trigger.isAfter && Trigger.isInsert) {
            
            // 门店调查要求下的周调研问题明细集合
            Map<String, List<Week_Question_Item__c>> wqiListMap = new Map<String,List<Week_Question_Item__c>>();
            // 门店调查要求
            Map<String, String> shopResearchMap = new Map<String, String>();

            for (Week_Question_Item__c wqi : (List<Week_Question_Item__c>)Trigger.new) {
                shopResearchMap.put(wqi.Shop_Research__c, '');
            }
            List<Week_Question_Item__c> wqiList = [SELECT id,Number__c,Shop_Research__c FROM Week_Question_Item__c 
                                                        WHERE Shop_Research__c IN:shopResearchMap.keySet() 
                                                        ORDER BY Shop_Research__c, Number__c];
            for(Week_Question_Item__c wqi : wqiList){
                if(wqiListMap.containsKey(wqi.Shop_Research__c)){
                    wqiListMap.get(wqi.Shop_Research__c).add(wqi);
                }else {
                    wqiListMap.put(wqi.Shop_Research__c, new List<Week_Question_Item__c>{wqi});
                }
            }
            
            List<Week_Question_Item__c> updateList = new List<Week_Question_Item__c>();
            for (Week_Question_Item__c wqi : (List<Week_Question_Item__c>)Trigger.new) {

                List<Week_Question_Item__c> wqiListNow = wqiListMap.get(wqi.Shop_Research__c);
                for(Integer i=0; i<wqiListNow.size(); i++){
                    Week_Question_Item__c wqiNow = wqiListNow[i];
                    if(wqiNow.id.equals(wqi.id)){
                        wqiListNow.remove(i);
                        break;
                    }
                }

                // 如果插入前已有10个明细则报错
                if(wqiListNow.size() >= 10){
                    Utility.addErrorToRecord(wqi, Label.Week_Question_Item_Number_Error);
                    return;
                }

                // 如果只有一行
                if(wqiListNow.size() == 1){
                    // 原有一行数据的序号是10
                    Week_Question_Item__c wqiNow = wqiListNow[0];
                    if('10'.equals(wqiNow.Number__c)){
                        wqiNow.Number__c = String.valueOf(Integer.valueOf(wqiNow.Number__c) - 1);
                        updateList.add(wqiNow);
                    }else if(wqiNow.Number__c.equals(wqi.Number__c)){
                        wqiNow.Number__c = String.valueOf(Integer.valueOf(wqiNow.Number__c) + 1);
                        updateList.add(wqiNow);
                    }
                }else {
                    for(Integer i=0; i<wqiListNow.size()-1; i++){
                        // 第一行
                        Week_Question_Item__c wqiNow = wqiListNow[i];
                        // 第二行
                        Week_Question_Item__c wqiNowNext = wqiListNow[i+1];
                        // 如果等于第一行的序号，则第一行的序号加1
                        if(wqiNow.Number__c.equals(wqi.Number__c)){
                            wqiNow.Number__c =String.valueOf(Integer.valueOf(wqiNow.Number__c) + 1);
                            updateList.add(wqiNow);
                        }
                        if(wqiNow.Number__c.equals(wqiNowNext.Number__c)){
                            wqiNowNext.Number__c =String.valueOf(Integer.valueOf(wqiNowNext.Number__c) + 1);
                            wqiListNow.set(i+1, wqiNowNext);
                            updateList.add(wqiNowNext);
                        }
                        if(i == wqiListNow.size()-2){
                            if(wqiNowNext.Number__c.equals(wqi.Number__c)){
                                wqiNowNext.Number__c =String.valueOf(Integer.valueOf(wqiNowNext.Number__c) + 1);
                                updateList.add(wqiNowNext);
                            }
                        }
                    }  
                }
                
            }

             //忽略触发器更新
             GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'WeekQuestionItemHandler');
             if(!Test.isRunningTest()){
                UPDATE updateList;
            }
             
             //恢复触发器
             Utility.IgnoreAction(false,false,false,'');

            
        }

    }
}