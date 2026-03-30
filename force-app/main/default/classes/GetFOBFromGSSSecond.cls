/**********************************************************************
* Name: GetFOBFromGSSSecond
* Object: FOB_GSS__c 
* Purpose: 
* upsert FOB_GSS__c
* Author: wfc
* Create Date: 2021-11-12
*************************************************************************/
public class GetFOBFromGSSSecond implements Queueable {
    
        private List<FOB_GSS__c> fobGSSList;
        
        public GetFOBFromGSSSecond(List<FOB_GSS__c> fobGSSList) {
            this.fobGSSList = fobGSSList;
        }
    
        public void execute(QueueableContext context) {
            List<Database.upsertResult> resultsOrderProduct = Database.upsert(fobGSSList,FOB_GSS__c.Fields.Batch_Number__c,false);
            //日志内容
            Utility.insertLog('GetFOBFromGSS', '1', null, null);
        }   
    }