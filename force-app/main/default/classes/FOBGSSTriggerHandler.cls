/**************************************************************************************************
 * FOBGSSTriggerHandler
 * Purpose:FOBGSS Trigger处理逻辑
 * Author: wfc
 * Create Date: 2021-10-27
***************************************************************************************************/
public class FOBGSSTriggerHandler extends TriggerHandler{

    public override void beforeInsert(){
        for (FOB_GSS__c fobGSS : ((list<FOB_GSS__c>)Trigger.new)) {
            String plCode = fobGSS.Product_Line_Code__c;
            if(plCode == '61'){
                fobGSS.Product_Line__c = 'AC';
            }else if(plCode == '62'){
                fobGSS.Product_Line__c = 'Refrigerator';
            }else if(plCode == '63'){
                fobGSS.Product_Line__c = 'Freezer';
            }else if(plCode == '64'){
                fobGSS.Product_Line__c = 'WM';
            }
        }
    }
}