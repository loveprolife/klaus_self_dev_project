/******************************************************************************
 ************************
 * Name: SetStorePromoterBatch
 * Description:  设置门店表促销员字段
 * TestClassName:  SetStorePromoterBatchTest
 * Version History: 0.01
 * Date: 2024-11-27
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public with sharing class SetStorePromoterBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 进入Batch前执行方法
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryS = 'select Id from shop__c where Sales_Region__c = \'Hisense Vietnam\'';
        return Database.getQueryLocator(queryS);
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 循环执行 将Channel__c的Name替换为Sellout_Raw_Data__c中的channelName__c
     */
    public void execute(Database.BatchableContext BC, list<shop__c> storeList) {

        for(Shop__c c : storeList){
            List<Responsible_Person__c> rpList = [select Principal_Text__c from Responsible_Person__c where Shop_Name__c = :c.Id and Is_Active_Formula__c = true and RecordType__c = '促销员'];
            if(rpList != null && rpList.size() > 0){
                String promoters = '';
                for(Responsible_Person__c rp : rpList){
                    promoters += rp.Principal_Text__c + ',';
                }
                if(promoters != ''){
                    c.Have_Promoter_Text__c = promoters.removeEnd(',');
                }else{
                    c.Have_Promoter_Text__c = '';
                }
            }
        }

        //更新
        Database.update(storeList);
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 执行完Batch后进入，记录日志
     */
    public void finish(Database.BatchableContext BC) {
        Utility.insertLog('SetStorePromoterBatch', '1', '', '');
    }

}