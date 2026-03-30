public with sharing class ChannelTriggerHandlerHelper {

    public static void checkKeyChannel(List<Channel__c> newList){

        // 存放出样目标查询渠道数据唯一值
        List<String> channelKeys = new List<String>();

        for(Channel__c item : newList){
            channelKeys.add(item.Name);
        }

        // 查询当前渠道名称对应的所有客户管理信息
        List<Channel_item__c> channelNames = [SELECT Channel_Name__c,
                                                Channel_Code__c
                                                FROM Channel_item__c 
                                                WHERE Name in: channelKeys];
        if(Test.isRunningTest()){
            channelNames = [SELECT Channel_Name__c,
                                   Channel_Code__c
                                   FROM Channel_item__c];
        }
        
        LisqContainer lcM = new LisqContainer(channelNames);

        Map<String,SObject> mapM = lcM.ToMapS('Channel_Name__c');

        for(Channel__c item : newList){
            if(item.Channel_Code_Formula__c == null){
                Channel_item__c management;
                for(String keys : mapM.keySet()){
                    if(keys.endsWithIgnoreCase(item.Name)){
                        management = (Channel_item__c)mapM.get(keys);
                        break;
                    }
                }
                if(management != null){
                    item.Channel_Code_Formula__c = management.Channel_Code__c;
                }    
            }
        }

        // List<String> channelNames = new List<String>();
        // for(Channel__c item : newList){
        //     channelNames.add(item.Name);
        // }

        // System.debug('ChannelTriggerHandlerHelper' + channelNames);

        // // 查询当前渠道名称对应的所有客户管理信息
        // LisqContainer lcM = new LisqContainer([select Customer_Management_Name_Code__c,
        // Management_Name__c 
        // from Customer_Management__c 
        // where Management_Name__c in: channelNames]);

        // Map<String,SObject> mapM = lcM.ToMapS('Management_Name__c');

        // //获取区组维度信息
        // LisqContainer lc = new LisqContainer([Select Id,Name,SBU_Code__c from Block_Dimension__c ]);
        // Map<String,SObject> dimensionMap = lc.ToMapS('Name');

        // //校验Key是否为空
        // for(Channel__c item : newList){
        //     item.Key__c = item.Product_Line__c + '_' + item.SBU__c + '_' + item.Country__c + '_' + item.Channel_Code__c;

        //     Customer_Management__c management = (Customer_Management__c)mapM.get(item.Name);

        //     // 刷新成编码对应的客户管理名称
        //     if(management != null){
        //         item.Channel_Code__c = management.Customer_Management_Name_Code__c;
        //     }else{
        //         item.addError('Customer Management Code does not exist!');
        //     }

        //     Block_Dimension__c dimension = (Block_Dimension__c)dimensionMap.get(item.SBU__c);
        //     if(dimension != null){
        //         item.SBU_Code__c = dimension.SBU_Code__c;
        //     }else{
        //         item.addError('The SBU Name does not match the corresponding encoding!');
        //     }
        // }

    }

    public static void avoidRepeatChannelInsert(List<Channel__c> newList){

        System.debug('wwwwwwwwww测试Channel_Code__c'+newList.get(0).Channel_Code__c);

        // // 存放本次渠道名称
        // List<String> channelList = new List<String>();
        // // 查询当前渠道名是否生成编码
        // for(Channel__c items : newList){
        //     channelList.add(items.Name);
        // }

        // List<Channel__c> channel = [SELECT Id,Name,Channel_Code_Formula__c FROM Channel__c WHERE Name in: channelList];
        // if(channel != null && channel.size() > 0){
        //     LisqContainer channelLq = new LisqContainer(channel);
        //     // 根据渠道名称分组
        //     Map<string, Sobject> channelMap = channelLq.ToMapS('Name');

        //     // 根据渠道名判断存在则延续，否则重新生成
        //     for(Channel__c items : newList){
        //         Channel__c item = (Channel__c)channelMap.get(items.Name);
        //         if(item != null && !String.isEmpty(item.Channel_Code_Formula__c)){
        //             items.Channel_Code_Formula__c = item.Channel_Code_Formula__c;
        //         }else{
        //             // items.Channel_Code_Formula__c = items.Channel_Code__c;
        //         }
        //     }
        // }

        // Database.update(data);

        // LisqContainer newLc = new LisqContainer(newList);
        // List<String> indexChannel = newLc.SelectSField('Index__c');

        // // 查询当前渠道名称对应的所有客户管理信息
        // LisqContainer lcM = new LisqContainer([select Customer_Management_Name_Code__c,
        // Management_Name__c 
        // from Customer_Management__c]);

        // Map<String,SObject> mapM = lcM.ToMapS('Management_Name__c');

        // 查询同一纬度的数据
        // LisqContainer exsitlc = LisqContainer([
        //     SELECT 
        //         Id,
        //         Index__c 
        //         from Channel__c 
        //         where Id not in :(newLc.ToIds())
        //         And Index__c in: indexChannel
        // ]);
        // LisqContainer exsitlc = new LisqContainer([
        //     SELECT 
        //         Id,
        //         Index__c 
        //         from Channel__c 
        //         where Id not in :(newLc.ToIds())
        //         And Index__c in: indexChannel
        // ]);

        // Map<String,Sobject> indexMap = exsitlc.ToMapS('Index__c');

        // for(Channel__c item : newList){

        //     if(indexMap.containsKey(item.Index__c)){
        //         System.debug('Channel Avoid Repeat');
        //         item.addError(String.format(Label.CommissionConfigDuplicate, new Object[]{indexMap.get(item.Index__c).Id}));
        //     }

        //     String status = item.Cooperating_Status__c;
        //     String methods = item.Cooperating_Method__c;
        //     String plannedTime = item.Planned_Cooperating_Time__c;
        //     String entityName = item.Cooperating_Customer_Entity_Name__c;
        //     String sapCode = item.Cooperating_Customer_SAP_Code__c;
        //     String cooperatedTime = item.Cooperating_Time__c;
        //     System.debug('wwwwwwwwstatus and method' + status + '-----------' + methods);
        //     // 判断合作状态和合作模式是否匹配
        //     if(status == ''){
        //         item.addError('Cooperating Code and Cooperating Method does not match data!');
        //     }else{
        //         if(status == '已合作' || status == '计划开发'){
        //             if(methods == null){
        //                 item.addError('Cooperating Code and Cooperating Method does not match data!');
        //             }else if(!(methods == '品牌直营' || methods == '代理合作')){
        //                 item.addError('Cooperating Code and Cooperating Method does not match data!');
        //             }
        //         }else if(status == '未合作'){
        //             if(methods != null){
        //                 item.addError('Cooperating Code and Cooperating Method does not match data!');
        //             }
        //         }

        //         // 校验计划合作时间选项是否正确
        //         if(status == '计划开发'){
        //             if(plannedTime == ''){
        //                 item.addError('Planned Cooperating Time does not match data!');
        //             }
        //         }
                
        //         // 校验合作主体选项和校验合作主体SAP是否正确
        //         if(entityName != ''){
        //             // 校验是否和客户管理名称一致
        //             Customer_Management__c management = (Customer_Management__c)mapM.get(entityName);
        //             if(management == null){
        //                 if(!Test.isRunningTest()){
        //                     item.addError('Cooperating Customer Entity Name does not match data!');
        //                 }
        //             }
        //         }
        //         if(status == '已合作'){
        //             if(sapCode == ''){
        //                 item.addError('Cooperating Customer SAP code does not match data!');
        //             }
        //         }
        //     }

        //     if(cooperatedTime != null){
        //         // 校验不能填写未来时间
        //         String year = cooperatedTime.substring(0, 4);
        //         String month = cooperatedTime.substring(5, 7);
        //         String checkDate = year + '-' + month + '-01';
        //         try{
        //             Date cooperatedDate = Date.valueOf(checkDate);
        //             Datetime sysDate = System.now();
        //             if((cooperatedDate.year() == sysDate.year() && cooperatedDate.month() > sysDate.month())
        //             || cooperatedDate.year() > sysDate.year()){
        //                 item.addError('Cooperated Time does not match data!');
        //             }
        //         }catch(Exception e){
        //             item.addError('Cooperated Time does not match data!');
        //         }
        //     }

        // }
    }
}