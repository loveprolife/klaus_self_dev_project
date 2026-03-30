public class ExportController{
    public List<Sampling_Target__c> sampling{ get; set; }

    public ExportController(){
        sampling = [SELECT id, Region__c, SBU__c, Channel__c, Channel_Code__c, Product_Line__c, Brand__c, Platform_Model__c, USD__c, Total_Sample_Targeted_Qty_in_2024__c
                    FROM Sampling_Target__c];
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-10 15:14:44
     * @Description: samplingConditionUploadTemplateLWC 导出excel
     */
    @AuraEnabled
    public static List<List<Object>> getSamplingTargetData(){
        List<List<Object>> returnList = new List<List<Object>>();
        // 标题头
        List<Object> title = new List<Object>();
        title.add('大区(Region)');
        title.add('海外公司 SBU(SBU)');
        title.add('渠道名称 Channel (与渠道信息一致)');
        title.add('客户管理名称编码(Channel code)');
        title.add('产品线Product line');
        title.add('品牌Brand');
        title.add('平台型号Platform Model (系统匹配)');
        title.add('价格段Price(USD)(匹配信数)');
        title.add('2024累计出样目标Total Sample Targeted Qty in 2024');
        title.add('出样状态：包括已完成、出样中、撤样中、已撤样和仅线上销售');
        title.add('累计实际出样数量Actual Sample Qty(市场月度更新)');
        returnList.add(title);
        // 内容
        List<Sampling_Target__c> stList = [SELECT id, Region__c, SBU__c, Channel__c, Channel_Code__c, Product_Line__c, Brand__c, Platform_Model__c, USD__c, Total_Sample_Targeted_Qty_in_2024__c
                                           FROM Sampling_Target__c];
        for (Sampling_Target__c st : stList){
            //正则表达
            List<Object> body = new List<Object>();
            body.add(st.Region__c != null ? st.Region__c + '' : '');
            body.add(st.SBU__c != null ? st.SBU__c + '' : '');
            body.add(st.Channel__c != null ? st.Channel__c + '' : '');
            body.add(st.Channel_Code__c != null ? st.Channel_Code__c + '' : '');
            body.add(st.Product_Line__c != null ? st.Product_Line__c + '' : '');
            body.add(st.Brand__c != null ? st.Brand__c + '' : '');
            body.add(st.Platform_Model__c != null ? st.Platform_Model__c + '' : '');
            body.add(st.USD__c != null ? st.USD__c + '' : '');
            body.add(st.Total_Sample_Targeted_Qty_in_2024__c != null ? (st.Total_Sample_Targeted_Qty_in_2024__c + '').replaceAll('0+?$', '').replaceAll('[.]$', '') : '');
            body.add('');
            body.add('');
            returnList.add(body);
        }
        return returnList;
    }

    /**
     * @Param:
     * @Return:
     * @Author: LZX
     * @Date: 2025-02-26 15:14:44
     * @Description: samplingConditionUploadTemplateLWC 导出excel
     */
    @AuraEnabled
    public static List<List<Object>> getSAWeeklySalesTargetTemplateData(){
        List<List<Object>> returnList = new List<List<Object>>();
        // 标题头
        List<Object> title = new List<Object>();
        title.add('Sales Region');
        //title.add('Channel');
        title.add('Store');
        //title.add('Product Line');
        title.add('Model');
        title.add('From Week');
        title.add('To Week');
        title.add('RSP');
        title.add('Target');
        //title.add('');
        returnList.add(title);
        // 示例
        // List<Object> example = new List<Object>();
        // example.add('Hisense South Africa');
        // example.add('Game');
        // example.add('GAME KLERKSDORP');
        // example.add('TV');
        // example.add('75U7N');
        // example.add('WK8');
        // example.add('WK12');
        // example.add('19999');
        // example.add('30');
        // example.add('Example');
        // returnList.add(example);

        // 查询自定义元数据记录
        List<SA_Weekly_Sales_Target_Product__mdt> metadataRecords = [SELECT Id, Channel__c, Product_Line__c, Product__c FROM SA_Weekly_Sales_Target_Product__mdt order by Channel__c];
        
        Set<String> channelSet = new Set<String>();
        for (SA_Weekly_Sales_Target_Product__mdt record : metadataRecords) {
            channelSet.add(record.Channel__c);
        }
        // 内容
        List<Responsible_Person__c> stList = [select Shop_Name__r.Sales_Region__c,Shop_Name__r.Channel_Name__c,Shop_Name__r.Name from Responsible_Person__c where Shop_Name__r.Channel_item__r.SBU__c = 'Hisense South Africa' and RecordType__c = '促销员' and Shop_Name__r.Channel_Name__c in :channelSet order by Shop_Name__r.Channel_Name__c];
        Set<String> checkSet = new Set<String>();
        
        for (Responsible_Person__c st : stList){
            if(checkSet.add(st.Shop_Name__r.Sales_Region__c + st.Shop_Name__r.Channel_Name__c + st.Shop_Name__r.Name)){
                
                for (SA_Weekly_Sales_Target_Product__mdt record : metadataRecords) {
                     
                    String[] productArr = new String[] {record.Channel__c, record.Product_Line__c, record.Product__c};
                    if(!productArr[0].equals(st.Shop_Name__r.Channel_Name__c)){
                        continue;
                    }

                    List<Object> body = new List<Object>();
                    body.add(String.isNotBlank(st.Shop_Name__r.Sales_Region__c) ? st.Shop_Name__r.Sales_Region__c : '');
                    //body.add(String.isNotBlank(st.Shop_Name__r.Channel_Name__c) ? st.Shop_Name__r.Channel_Name__c : '');
                    body.add(String.isNotBlank(st.Shop_Name__r.Name) ? st.Shop_Name__r.Name : '');
                    //body.add(productArr[1]);
                    body.add(productArr[2]);
                    body.add('');
                    body.add('');
                    body.add('');
                    body.add('');
                    returnList.add(body);
                }
            }
        }
        return returnList;
    }

    // public PageReference exportGoods() {
    //     return new PageReference('/apex/ExportPage');
    // }
    // public PageReference exportSamplingTarget() {
    //     return new PageReference('/apex/ExportPage');
    // }
}