public class ChannelTriggerHandler extends BaseTriggerHandler{

    public override void beforeInsert(){
        ChannelTriggerHandlerHelper.checkKeyChannel(this.newList);
    }
    // 校验新增重复 纬度根据产品线 销售单元 销售国家 渠道
    public override void afterInsert(){
        ChannelTriggerHandlerHelper.avoidRepeatChannelInsert(this.newList);
    }
    public override void beforeUpdate(){
        ChannelTriggerHandlerHelper.checkKeyChannel(this.newList);
    }
    public override void afterUpdate(){
        ChannelTriggerHandlerHelper.avoidRepeatChannelInsert(this.newList);
    }
    
}