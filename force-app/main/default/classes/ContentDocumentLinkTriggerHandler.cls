/**************************************************************************************************
 * ContentDocumentLinkTriggerHandler
 * Purpose:ContentDocumentLinkTrigger处理逻辑
 * Author: lizunxing
 * Create Date: 2025-03-30
 ***************************************************************************************************/
public class ContentDocumentLinkTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id, Sales_Region__c
                                      FROM User
                                      WHERE Id = :UserInfo.getUserId()];
    public void handle(){
        if (Trigger.isAfter && Trigger.isInsert){
            System.debug('======ContentDocumentLinkTriggerHandler======');

            for (ContentDocumentLink cdl : ((list<ContentDocumentLink>)Trigger.new )){
                String[] salesRegions = new String[]{ 'Hisense Canada', 'Hisense USA', 'Hisense Peru', 'Hisense International', 'Hisense Mexico' };

                if (salesRegions.contains(currentUser.sales_region__c)){
                    Id recordId = (Id) cdl.LinkedEntityId;
                    SObjectType objectType = recordId.getSObjectType();
                    Schema.DescribeSObjectResult describeResult = objectType.getDescribe();

                    List<Image_Ai_Interface__c> imageAis = [Select Name, Type__c, Url__c
                                                            from Image_Ai_Interface__c];
                    Map<String, Image_Ai_Interface__c> mapImageAi = new Map<String, Image_Ai_Interface__c>();
                    for (Image_Ai_Interface__c imageAi : imageAis){
                        mapImageAi.put(imageAi.Name, imageAi);
                    }

                    if ('Sampling_Inspection__c'.equals(describeResult.getName())){
                        Sampling_Inspection__c si = [Select id, Product__r.Product_line__c
                                                     from Sampling_Inspection__c
                                                     where id = :recordId];
                        if ('TV'.equals(si.Product__r.Product_line__c)){
                            String base64Code = convertFileToBase64(cdl.ContentDocumentId);

                            List<String> interfaceNames = new List<String>{ '电视黑屏检核', '品类检核' };
                            for (String interfaceName : interfaceNames){
                                Image_Ai_Interface__c imageAi = mapImageAi.get(interfaceName);
                                if (imageAi != null){
                                    Image image = new Image(
                                        Name = interfaceName, 
                                        Record_Id__c = recordId, 
                                        ContentDocumentId = cdl.ContentDocumentId
                                    );
                                    insert image;

                                    Rest_ImageAI.imageAi(image.Id, imageAi.Type__c, imageAi.Url__c, base64Code);
                                }

                            }
                        }
                    }

                    if ('CheckResult__c'.equals(describeResult.getName())){
                        CheckResult__c cr = [select id, CheckItem__r.Has_Image_AI__c, CheckItem__r.Image_AI__c
                                             from CheckResult__c
                                             where id = :recordId];
                        if (cr.CheckItem__r.Has_Image_AI__c && String.isNotBlank(cr.CheckItem__r.Image_AI__c)){
                            String base64Code = convertFileToBase64(cdl.ContentDocumentId);
                            for (String imageAiName : cr.CheckItem__r.Image_AI__c.split(';')){

                                if (imageAiName.equals('打卡图像相似度检测')){

                                } else{
                                    Image_Ai_Interface__c imageAi = mapImageAi.get(imageAiName);
                                    if (imageAi != null){
                                        Image image = new Image(
                                            Name = imageAiName, 
                                            Record_Id__c = recordId, 
                                            ContentDocumentId = cdl.ContentDocumentId
                                        );
                                        insert image;
                                        Rest_ImageAI.imageAi(image.Id, imageAi.Type__c, imageAi.Url__c, base64Code);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static String convertFileToBase64(String fileId){
        // 查询 ContentVersion 记录
        ContentVersion contentVersion = [SELECT VersionData
                                         FROM ContentVersion
                                         WHERE ContentDocumentId = :fileId
                                         LIMIT 1];
        if (contentVersion != null && contentVersion.VersionData != null){
            // 将文件内容转换为 Base64 编码
            return EncodingUtil.base64Encode(contentVersion.VersionData);
        }
        return null;
    }

    //异步调用图片AI接口
    // public class AsyncCallImageAi implements Queueable{
    //     public ContentDocumentLink cdl { get; set; }
    //     public AsyncCallImageAi(ContentDocumentLink cdl){
    //         this.cdl = cdl;
    //     }
    //     public void execute(QueueableContext context) {
    //     }
    // }
}