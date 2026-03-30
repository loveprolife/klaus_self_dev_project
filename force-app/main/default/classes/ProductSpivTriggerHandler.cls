/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 25-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
public class ProductSpivTriggerHandler extends BaseTriggerHandler{
	protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        ProductSpivTriggerHandlerHelper.checkNewSpiv(newList);       
        ProductSpivTriggerHandlerHelper.checkSpiv(newList);
    }
    public override void beforeUpdate(){
        ProductSpivTriggerHandlerHelper.checkNewSpiv(newList);       
        ProductSpivTriggerHandlerHelper.checkUpdateSpiv(newList);
    }
}