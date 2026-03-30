/**********************************************************************
* Name: InspectionShopTaskViewInMobileController
* Object: Inspection_Shop_Task__c
* Purpose: InspectionShopTaskViewInMobileLWC Controller
* Author: yong
* Create Date: 2023-06-28
*************************************************************************/
public with sharing class InspectionShopTaskViewInMobileController {

    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title,Profile.Name FROM User WHERE Id = : UserInfo.getUserId()][0];

    @AuraEnabled
    public static Map<String, List<Options>> setGridOptions(String countryId, 
            String regionId, String provinceId, String cityId, String districtId){

        if(String.isNotBlank(countryId)){
            countryId = countryId.left(15);
        }
        if(String.isNotBlank(regionId)){
            regionId = regionId.left(15);
        }
        if(String.isNotBlank(provinceId)){
            provinceId = provinceId.left(15);
        }
        if(String.isNotBlank(cityId)){
            cityId = cityId.left(15);
        }
        if(String.isNotBlank(districtId)){
            districtId = districtId.left(15);
        }

        List<Gridding__c> allGrids = [SELECT Id, Name, DivisionUnit__c, Gridding_Recursion_ID__c FROM Gridding__c];
        // Map<String, Gridding__c> allGridsMap = new Map<String, Gridding__c>();
        // for(Gridding__c g : allGrids){
        //     allGridsMap.put(String.valueOf(g.Id).left(15), g);
        // }

        Options all = new Options();
        all.label = System.label.All;
        all.value = System.label.All;

        Map<String, List<Options>> gridsMap = new Map<String, List<Options>>();

        // //门店初始化
        // List<String> ownerKeyList = getRelatedUserId(); //根据当前用户角色获取相关用户
        // List<Responsible_Person__c> rpList = getResponsPerson(ownerKeyList);
        
        Set<String> gridKeySet = new Set<String>(); 
        Set<String> gridKeySet2 = new Set<String>(); 

        // for(Responsible_Person__c rp: rpList){
        //     if(String.isNotBlank(rp.Shop_Name__r.Grid__c)){
        //         gridKeySet.add(String.valueOf(rp.Shop_Name__r.Grid__c).left(15));
        //         gridKeySet.addAll(rp.Shop_Name__r.Grid__r.Gridding_Recursion_ID__c.split('-'));
        //     }
        // }
        // String sql = 'Select id, Name, DivisionUnit__c, Gridding_Recursion_ID__c from Gridding__c ';
        // String con = '';
        // for(String gk : gridKeySet){
        //     con += ' Gridding_Recursion_ID__c like \'%' + gk + '%\'' + ' or ';
        // }

        if(allGrids != null && allGrids.size() > 0){
            // sql += ' where ' + con.left(con.length() - 4);
            // System.debug('sql:' + sql);
            // List<Gridding__c> grids = Database.query(sql);
            // List<Gridding__c> resultRrids = new List<Gridding__c>();

            // for(Gridding__c g : grids){
            //     for(String idStr : g.Gridding_Recursion_ID__c.split('-')){
            //         if(gridKeySet.contains(idStr)){
            //             resultRrids.add(allGridsMap.get(idStr));
            //         }
            //     }
            // }

            for(Gridding__c g : allGrids){

                if(!gridKeySet2.add(g.Id)){
                    continue;
                }
                Options op = new Options();
                op.label = g.Name;
                op.value = g.Id;
                if(g.DivisionUnit__c == '国家'){
                    if(!gridsMap.containsKey('Country')){
                        List<Options> lgs = new List<Options>();
                        lgs.add(all);
                        gridsMap.put('Country', lgs);
                    }
                    
                    gridsMap.get('Country').add(op);
                }
                if(g.DivisionUnit__c == '大区'){
                    if(!gridsMap.containsKey('Region')){
                        List<Options> lgs = new List<Options>();
                        lgs.add(all);
                        gridsMap.put('Region', lgs);
                    }

                    if(String.isNotBlank(countryId) && countryId != System.label.All && !g.Gridding_Recursion_ID__c.contains(countryId)){
                        continue;
                    }
                    gridsMap.get('Region').add(op);
                }
                if(g.DivisionUnit__c == '都道府県名'){
                    if(!gridsMap.containsKey('Province')){
                        List<Options> lgs = new List<Options>();
                        lgs.add(all);
                        gridsMap.put('Province', lgs);
                    }

                    if(String.isNotBlank(countryId) && countryId != System.label.All && !g.Gridding_Recursion_ID__c.contains(countryId)){
                        continue;
                    }
                    if(String.isNotBlank(regionId) && regionId != System.label.All && !g.Gridding_Recursion_ID__c.contains(regionId)){
                        continue;
                    }
                    
                    gridsMap.get('Province').add(op);
                }
                if(g.DivisionUnit__c == '市'){
                    if(!gridsMap.containsKey('City')){
                        List<Options> lgs = new List<Options>();
                        lgs.add(all);
                        gridsMap.put('City', lgs);
                    }
                    if(String.isNotBlank(countryId) && countryId != System.label.All && !g.Gridding_Recursion_ID__c.contains(countryId)){
                        continue;
                    }
                    if(String.isNotBlank(regionId) && regionId != System.label.All && !g.Gridding_Recursion_ID__c.contains(regionId)){
                        continue;
                    }
                    if(String.isNotBlank(provinceId) && provinceId != System.label.All && !g.Gridding_Recursion_ID__c.contains(provinceId)){
                        continue;
                    }
                    gridsMap.get('City').add(op);
                }
                if(g.DivisionUnit__c == '区'){
                    if(!gridsMap.containsKey('District')){
                        List<Options> lgs = new List<Options>();
                        lgs.add(all);
                        gridsMap.put('District', lgs);
                    }
                    if(String.isNotBlank(countryId) && countryId != System.label.All && !g.Gridding_Recursion_ID__c.contains(countryId)){
                        continue;
                    }
                    if(String.isNotBlank(regionId) && regionId != System.label.All && !g.Gridding_Recursion_ID__c.contains(regionId)){
                        continue;
                    }
                    if(String.isNotBlank(provinceId) && provinceId != System.label.All && !g.Gridding_Recursion_ID__c.contains(provinceId)){
                        continue;
                    }
                    if(String.isNotBlank(cityId) && cityId != System.label.All && !g.Gridding_Recursion_ID__c.contains(cityId)){
                        continue;
                    }
                    gridsMap.get('District').add(op);
                }
            }
        }
        
        return gridsMap;
    }

    @AuraEnabled
    public static List<Options> getShopOptions(String channelId, String countryId, 
    String regionId, String provinceId, String cityId, String districtId){

        if(String.isNotBlank(countryId)){
            countryId = countryId.left(15);
        }
        if(String.isNotBlank(regionId)){
            regionId = regionId.left(15);
        }
        if(String.isNotBlank(provinceId)){
            provinceId = provinceId.left(15);
        }
        if(String.isNotBlank(cityId)){
            cityId = cityId.left(15);
        }
        if(String.isNotBlank(districtId)){
            districtId = districtId.left(15);
        }
        List<Options> shopOptions = new List<Options>();

        Options all = new Options();
        all.label = System.label.All;
        all.value = System.label.All;

        //门店初始化
        //List<String> ownerKeyList = getRelatedUserId(); //根据当前用户角色获取相关用户
        //List<Responsible_Person__c> rpList = getResponsPerson(ownerKeyList);
        

        String sql = 'Select Id, Name, Address1__c, Channel_Item__c, Grid__r.Gridding_Recursion_ID__c From Shop__c where Sales_Region__c = \'' + user.Sales_Region__c + '\'';

        if(String.isNotBlank(channelId) && channelId != System.label.All){
            sql += ' and Channel_Item__c = \'' + channelId + '\'';
        }

        if(String.isNotBlank(districtId) && districtId != System.label.All){
                sql += ' and Grid__r.Gridding_Recursion_ID__c like \'%'+districtId+'%\' ';
        }

        if(String.isNotBlank(cityId) && cityId != System.label.All){
                sql += ' and Grid__r.Gridding_Recursion_ID__c like \'%'+cityId+'%\' ';
        }
        
        if(String.isNotBlank(provinceId) && provinceId != System.label.All){
                sql += ' and Grid__r.Gridding_Recursion_ID__c like \'%'+provinceId+'%\' ';
        }

        if(String.isNotBlank(regionId) && regionId != System.label.All){
                sql += ' and Grid__r.Gridding_Recursion_ID__c like \'%'+regionId+'%\' ';
        }

        if(String.isNotBlank(countryId) && countryId != System.label.All){
                sql += ' and Grid__r.Gridding_Recursion_ID__c like \'%'+countryId+'%\' ';
        }

        if('Hisense South Africa'.equals(user.Sales_Region__c) || 'Hisense Japan'.equals(user.Sales_Region__c)){
            List<String> ownerKeyList = getRelatedUserId(); //根据当前用户角色获取相关用户
            List<Responsible_Person__c> rpList = getResponsPerson(ownerKeyList);
            String storeIds = '';
            for(Responsible_Person__c rp : rpList){
                storeIds += '\'' + rp.Shop_Name__c + '\',';
            }
            if(String.isNotBlank(storeIds)){
                storeIds = storeIds.substring(0, storeIds.length() - 1);
            }

            sql += ' and Id in  ('+storeIds+')';
        }

        List<Shop__c> storeList = Database.query(sql);

        Set<String> shopKeySet = new Set<String>(); 
        shopOptions.add(all);
        for(Shop__c shop: storeList){
    
            Options op = new Options();
            if(user.Sales_Region__c == 'Hisense Canada'){
                op.label = shop.Address1__c;
            }else{
                op.label = shop.Name;
            }
            op.value = shop.Id;
            if(!shopKeySet.contains(shop.Id)){
                System.debug('Shop name-----'+shop.Name);
                shopOptions.add(op);
                shopKeySet.add(shop.Id);
            }
        }
        return shopOptions;
    }
    @AuraEnabled
    public static OutPut initData(){
        OutPut out = new OutPut();
        String year = String.valueOf(Date.today().year());
        String month = String.valueOf(Date.today().month());
        String day = String.valueOf(Date.today().day());

        Options all = new Options();
        all.label = System.label.All;
        all.value = System.label.All;

        //门店初始化
        List<String> ownerKeyList = getRelatedUserId(); //根据当前用户角色获取相关用户
        List<Responsible_Person__c> rpList = getResponsPerson(ownerKeyList);

        String sql = 'Select Id, Name, Address1__c, Channel_Item__c, Channel_item__r.Name, Grid__r.Gridding_Recursion_ID__c From Shop__c where Sales_Region__c = \'' + user.Sales_Region__c + '\'';

        if('Hisense South Africa'.equals(user.Sales_Region__c) || 'Hisense Japan'.equals(user.Sales_Region__c)){
            String storeIds = '';
            for(Responsible_Person__c rp : rpList){
                storeIds += '\'' + rp.Shop_Name__c + '\',';
            }
            if(String.isNotBlank(storeIds)){
                storeIds = storeIds.substring(0, storeIds.length() - 1);
            }

            sql += ' and Id in  ('+storeIds+')';
        }

        List<Shop__c> storeList = Database.query(sql);

        List<Options> shopOptions = new List<Options>();
        Set<String> shopKeySet = new Set<String>(); 
        shopOptions.add(all);

        List<Options> channelOptions = new List<Options>();
        Set<String> channelKeySet = new Set<String>(); 
        channelOptions.add(all);
        for(Shop__c shop: storeList){
            Options op = new Options();
            if(user.Sales_Region__c == 'Hisense Canada'){
                op.label = shop.Address1__c;
            }else{
                op.label = shop.Name;
            }
            
            op.value = shop.Id;
            if(!shopKeySet.contains(shop.Id)){
                System.debug('Shop name-----'+shop.Name);
                shopOptions.add(op);
                shopKeySet.add(shop.Id);
            }

            Options op1 = new Options();
            op1.label = shop.Channel_item__r.Name;
            op1.value = shop.Channel_Item__c;
            if(String.isNotBlank(shop.Channel_Item__c) && !channelKeySet.contains(shop.Channel_Item__c)){
                channelOptions.add(op1);
                channelKeySet.add(shop.Channel_Item__c);
            }
        }
        //所有人初始化
        List<Options> ownerOptions = new List<Options>();
        ownerOptions.add(all);
        // List<Inspection_Shop_Task__c> istList = getData(null,null,null,null,null);
        for(Inspection_Shop_Task__c ist: [SELECT Id,Name,Inspection_Plan__r.Owner.Name,Inspection_Plan__r.OwnerId FROM Inspection_Shop_Task__c WHERE Inspection_Plan__c != null AND Inspection_Plan__r.OwnerId IN: ownerKeyList]){
            Options op = new Options();
            op.label = ist.Inspection_Plan__r.Owner.Name;
            op.value = ist.Inspection_Plan__r.OwnerId;
            ownerOptions.add(op);
        }

        //状态初始化
        Map<String,String> statusMap = getPicklistLabelValueMap('Inspection_Shop_Task__c','Status__c');
        List<Options> statusOptions = new List<Options>();
        // Set<String> statusKeySet = new Set<String>(); 
        statusOptions.add(all);
        for(String label: statusMap.keySet()){
            Options op = new Options();
            op.label = label;
            op.value = statusMap.get(label);
            if(!statusOptions.contains(op)){
                statusOptions.add(op);
            }
        }
        //日期 日 初始化
        List<Options> dayOptions = new List<Options>();
        dayOptions = getCurrentMonthDays(year,month);

        //渠道初始化
        // List<Channel_item__c> channels = [SELECT Id,Name FROM Channel_item__c WHERE SBU__c = :user.Sales_Region__c];
        // List<Options> channelOptions = new List<Options>();
        // channelOptions.add(all);
        // for(Channel_item__c ci: channels){
        //     Options op = new Options();
        //     op.label = ci.Name;
        //     op.value = ci.Id;
        //     channelOptions.add(op);
        // }
        
        out.ownerName = UserInfo.getName();
        out.ownerId = UserInfo.getUserId();
        out.relatedUserIdList = ownerKeyList;
        out.year = year;
        out.month = month;
        out.day = day;
        out.dayList = dayOptions;
        out.shopList = shopOptions;
        out.channelList = channelOptions;
        out.ownerList = ownerOptions;
        out.statusList = statusOptions;

        out.inspectionDateLabel = Schema.sObjectType.Inspection_Shop_Task__c.fields.Inspection_Date__c.getLabel();
        out.channelLabel = Schema.sObjectType.Shop__c.fields.Channel_item__c.getLabel();
        out.shopLabel = Schema.sObjectType.Inspection_Shop_Task__c.fields.Shop__c.getLabel();
        out.noteLabel = Schema.sObjectType.Inspection_Shop_Task__c.fields.Note__c.getLabel();
        out.statusLabel = Schema.sObjectType.Inspection_Shop_Task__c.fields.Status__c.getLabel();
        out.ownerLabel = Schema.sObjectType.Inspection_Shop_Task__c.fields.OwnerId.getLabel();

        out.istList = getData(JSON.serialize(ownerKeyList),year,month,System.label.All,null,null,null,true,null,null,null,null,null);//巡店任务初始化数据
        System.debug('out.istList.size()-------------------'+out.istList.size());
        out.isSuccess = true;
        out.errorMsg = null;
        return out;
    }
    @AuraEnabled
    public static List<Inspection_Shop_Task__c> getData(String ownerIdListJson,String year,
    String month,String day, String channelId, String shopId,String status,Boolean isToday,
    String countryId,String regionId, String provinceId, String cityId, String districtId){

        if(String.isNotBlank(countryId)){
            countryId = countryId.left(15);
        }
        if(String.isNotBlank(regionId)){
            regionId = regionId.left(15);
        }
        if(String.isNotBlank(provinceId)){
            provinceId = provinceId.left(15);
        }
        if(String.isNotBlank(cityId)){
            cityId = cityId.left(15);
        }
        if(String.isNotBlank(districtId)){
            districtId = districtId.left(15);
        }
        Integer yearIntegerStart ;
        Integer monthIntegerStart ;
        Integer yearIntegerEnd ;
        Integer monthIntegerEnd ;
        Integer dayIntegerStart ;
        Integer dayIntegerEnd ;

        if(year == System.label.All){
            yearIntegerStart = 2021;
            yearIntegerEnd = 2050;
            monthIntegerStart = 1;
            monthIntegerEnd = 12;
            dayIntegerStart = 1;
            dayIntegerEnd = Date.daysInMonth(yearIntegerEnd, monthIntegerEnd);
        }else{
            yearIntegerStart = Integer.valueOf(year);
            yearIntegerEnd = Integer.valueOf(year);
            if(month == System.label.All){
                monthIntegerStart = 1;
                monthIntegerEnd = 12;
                dayIntegerStart = 1;
                dayIntegerEnd = Date.daysInMonth(yearIntegerEnd, monthIntegerEnd);
            }else{
                monthIntegerStart = Integer.valueOf(month);
                monthIntegerEnd = Integer.valueOf(month);
                if(day == System.label.All){
                    dayIntegerStart = 1;
                    dayIntegerEnd = Date.daysInMonth(yearIntegerEnd, monthIntegerEnd);
                }else{
                    dayIntegerStart = Integer.valueOf(day);
                    dayIntegerEnd = Integer.valueOf(day);
                }
            }
        }
        
        String startDate = String.valueof(Date.newInstance(yearIntegerStart,monthIntegerStart,dayIntegerStart)).remove('00:00:00');
        String endDate =  String.valueof(Date.newInstance(yearIntegerEnd,monthIntegerEnd,dayIntegerEnd)).remove('00:00:00');
        Integer i = 0;
        String str = 'SELECT Id,Name,Inspection_Date__c,Status__c,Inspection_Plan__c,Inspection_Plan__r.OwnerId,Inspection_Plan__r.Owner.Name,Shop__c,Shop__r.Name,Shop__r.Sales_Region__c,Daily_Inspection_Report__c,Note__c';
        str += ' FROM Inspection_Shop_Task__c ';
        if(isToday){
            str += ' Where Shop__c != null AND ';
            str += ' Inspection_Date__c = ' + String.valueof(Date.today()).remove('00:00:00');
            if(ownerIdListJson != null && ownerIdListJson != System.label.All){
                List<String> ownerList = (List<String>)JSON.deserialize(ownerIdListJson,List<String>.class);
                str += ' AND ';
                String ownerStr = '(';
                for(Integer k = 0;k < ownerList.Size(); k++){
                    if(k>0){
                        ownerStr += ',';
                    }
                    ownerStr += '\'' + ownerList[k] + '\'';
                }
                ownerStr += ')';
                str += ' Inspection_Plan__r.OwnerId IN ' + ownerStr ;
            }
        }else{
            if(ownerIdListJson != null || year != null || month != null || shopId != null){
                str += ' Where Shop__c != null AND ';
                
                if(ownerIdListJson != null && ownerIdListJson != System.label.All){
                    List<String> ownerList = (List<String>)JSON.deserialize(ownerIdListJson,List<String>.class);
                    String ownerStr = '(';
                    for(Integer k = 0;k < ownerList.Size(); k++){
                        if(k>0){
                            ownerStr += ',';
                        }
                        ownerStr += '\'' + ownerList[k] + '\'';
                    }
                    ownerStr += ')';
                    str += ' Inspection_Plan__r.OwnerId IN ' + ownerStr ;
                    i++;
                }else{
                    // str += ' Inspection_Plan__r.OwnerId = \'' + UserInfo.getUserId() + '\'';
                }
                if(year != null && month != null){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Inspection_Date__c >= ' + startDate + ' AND Inspection_Date__c <= ' + endDate;
                    i++;
                }
                if(String.isNotBlank(countryId) && countryId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Grid__r.Gridding_Recursion_ID__c like \'%' + countryId + '%\'';
                    i++;
                }
                if(String.isNotBlank(regionId) && regionId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Grid__r.Gridding_Recursion_ID__c like \'%' + regionId + '%\'';
                    i++;
                }
                if(String.isNotBlank(provinceId) && provinceId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Grid__r.Gridding_Recursion_ID__c like \'%' + provinceId + '%\'';
                    i++;
                }
                if(String.isNotBlank(cityId) && cityId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Grid__r.Gridding_Recursion_ID__c like \'%' + cityId + '%\'';
                    i++;
                }
                if(String.isNotBlank(districtId) && districtId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Grid__r.Gridding_Recursion_ID__c like \'%' + districtId + '%\'';
                    i++;
                }

                
                if(String.isNotBlank(channelId) && channelId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__r.Channel_Item__c = \'' + channelId + '\'';
                    i++;
                }
                if(shopId != null && shopId != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Shop__c = \'' + shopId + '\'';
                    i++;
                }
                if(status != null && status != System.label.All){
                    if(i>0){
                        str += ' AND ';
                    }
                    str += ' Status__c = \'' + status + '\'';
                }
            }
        }
        str += ' ORDER BY Inspection_Date__c ';
        System.debug('str----'+str);
        return Database.query(str);
    }

    @AuraEnabled
    public static OutPut newData(Inspection_Shop_Task__c newData,Boolean isToday){
        System.debug('newData----'+newData);
        OutPut out = new OutPut();
        out.isSuccess = true;
        String year;
        String month;
        Boolean flag= false;
        String errMsg = '';
        //数据校验
        if(newData.Shop__c == null){
            flag = true;
            errMsg += Schema.sObjectType.Inspection_Shop_Task__c.fields.Shop__c.getLabel();
        }
        if(newData.Status__c == null){
            flag = true;
            errMsg += Schema.sObjectType.Inspection_Shop_Task__c.fields.Status__c.getLabel();
        }
        if(newData.Inspection_Date__c == null){
            flag = true;
            errMsg += Schema.sObjectType.Inspection_Shop_Task__c.fields.Inspection_Date__c.getLabel();
        }
        if(flag){
            out.isSuccess = false;
            out.errorMsg = System.label.Missing_Fields + errMsg;//Missing Fields :
            return out;
        }
        if(newData.Inspection_Date__c < Date.today()){
            out.isSuccess = false;
            out.errorMsg = System.label.Inspection_Task_Create_Limits;
            return out;
        }
        //验证门店是否属于当前用户
        // List<Responsible_Person__c> rpList =  getResponsPerson(getRelatedUserId());
        // LisqContainer lisq = new LisqContainer(rpList);
        // List<String> shopIdList = lisq.SelectSField('Shop_Name__c');
        // if(!shopIdList.contains(newData.Shop__c)){
        //     out.isSuccess = false;
        //     out.errorMsg = System.label.Select_Shop_Limits;//'No access to select this shop';
        //     return out;
        // }
        //数据补充
        year = String.valueOf(newData.Inspection_Date__c.year());
        month = String.valueOf(newData.Inspection_Date__c.month());
        List<Inspection_Shop_Plan__c> ispList = [SELECT Id,Name ,Inspection_Year__c,Inspection_Month__c,OwnerId,Status__c
                                                    FROM Inspection_Shop_Plan__c
                                                    WHERE Inspection_Year__c =: year AND Inspection_Month__c =: month AND OwnerId =: newData.OwnerId];
        if(ispList.size()>0){
            if(ispList[0].Status__c != 'New' && ispList[0].Status__c != 'Rejected'){
                out.isSuccess = false;
                out.errorMsg = System.label.Inspection_Task_Create_Limits2;
                return out;
            }else{
                newData.Inspection_Plan__c = ispList[0].Id;
            }
        }else{
            Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
            isp.Inspection_Year__c = year;
            isp.Inspection_Month__c = month;
            isp.OwnerId = newData.OwnerId;
            try{
                insert isp;
                newData.Inspection_Plan__c = isp.Id;
            }catch(Exception e){
                System.debug('Error: '+ e.getMessage() + '   ' + e.getLineNumber());
                out.isSuccess = false;
                out.errorMsg = e.getMessage() + '   ' + e.getLineNumber();
                return out;
            }
            
            // out.isSuccess = false;
            // out.errorMsg = System.label.No_Current_Month_Plan;//'No plan is created for the current month';
            // return out;
        }
        try{
            insert newData;
        }catch(Exception e){
            out.isSuccess = false;
            out.errorMsg = e.getMessage() + ':  ' + e.getLineNumber();
            return out;
        }
        out.istList = getData(JSON.serialize(getRelatedUserId()),year,month,System.label.All,null,null,null,isToday,null,null,null,null,null);

        return out;
    }
    @AuraEnabled
    public static List<Options> getCurrentMonthDays(String year,String month){
        if(year.remove('"') == System.label.All || month.remove('"') == System.label.All){
            return null;
        }
        List<Options> optionsList = new List<Options>();
        Options all = new Options();
        all.label = System.label.All;
        all.value = System.label.All;
        optionsList.add(all);
        Integer yearInteger = Integer.valueOf(year.remove('"'));
        Integer monthInteger = Integer.valueOf(month.remove('"'));
        for(Integer i=0;i<Date.daysInMonth(yearInteger, monthInteger);i++){
            Options op = new Options();
            op.label = String.valueOf(i+1);
            op.value = String.valueOf(i+1);
            optionsList.add(op);
        }
        return optionsList;
    }
    public static List<Responsible_Person__c> getResponsPerson(List<String> ownerId) {
    	return [
    		SELECT 
    			Id,
    			Shop_Name__c,
    			Principal__c,
    			Shop_Name__r.Owner.Name,
    			Shop_Name__r.Name,
                Shop_Name__r.Address1__c,
    			Shop_Name__r.Shop_Level__c,
    			Shop_Name__r.Account__r.Name,
                Shop_Name__r.Channel_item__c,
                Shop_Name__r.Channel_item__r.Name,
                Shop_Name__r.Grid__c,
                Shop_Name__r.Grid__r.Gridding_Recursion_ID__c
    		FROM 
    			Responsible_Person__c
    		WHERE 
    			Principal__c IN: ownerId 
                //AND (RecordType__c = '巡店员' OR RecordType__c = 'Regional Manager' OR RecordType__c = 'Backup Floorwalker')
			ORDER BY Shop_Name__r.name
    	];

        
    }
    public static List<String> getRelatedUserId(){
        List<String> userIdList = new List<String>();
        List<String> floorWalkerRole = new List<String>();
        floorWalkerRole.add('ID_Floorwalker');
        floorWalkerRole.add('CL_Floorwalker');
        floorWalkerRole.add('SA_Blitz_Field_Reps');
        User u = [SELECT Id,Name,UserRole.Name,Profile.Name,ManagerId FROM User WHERE Id =: UserInfo.getUserId()];
        //巡店员   仅匹配自身Responsible_Person__c
        // if(u.UserRole.Name == 'ID Floor Worker' || u.UserRole.Name == 'CL Floor Worker' || u.UserRole.Name == 'SA Blitz Field Reps'){
            userIdList.add(UserInfo.getUserId());
        // }
        //District域经理  匹配自身及下属巡店员Responsible_Person__c
        if(u.UserRole.Name == 'ID_Training_Manager' || u.UserRole.Name == 'CL_Supivisior' || u.UserRole.Name == 'SA_Regional_Manager' || u.Profile.Name == 'System Administrator'){
            System.debug('Current UserRole:  ' + u.UserRole.Name);
            System.debug('Current Profile:  ' + u.Profile.Name);
            List<User> uList = [SELECT Id,Name ,UserRole.Name,ManagerId FROM User WHERE ManagerId =:UserInfo.getUserId() AND UserRole.DeveloperName IN: floorWalkerRole];
            System.debug('Related User Number:  ' + uList.size());
            for(User ur : uList){
                userIdList.add(ur.Id);
                System.debug('Related User Name:  ' + ur.Name);
            }
        }
        System.debug('RelatedUserId----------------'+userIdList);
        return userIdList;
    }

    public static Map<String,string > getPicklistLabelValueMap(String objectName,String fieldName){ 
        Map<String,String> picklistMap = new Map<String,String>();
        Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        for(Schema.PicklistEntry a : picklistEntries){
            picklistMap.put(a.getLabel(),a.getValue());
        }
        return picklistMap;
    } 

    public class OutPut {

        @AuraEnabled
        public Map<String, List<Options>> gridsMap {get; set;}

		@AuraEnabled
		public List<Inspection_Shop_Task__c> istList {get; set;}

        @AuraEnabled
		public String ownerName {get; set;}

        @AuraEnabled
		public String ownerId {get; set;}

        @AuraEnabled
		public List<String> relatedUserIdList {get; set;}

        @AuraEnabled
		public String year {get; set;}

        @AuraEnabled
		public String month {get; set;}

        @AuraEnabled
		public String day {get; set;}

        @AuraEnabled
		public List<Options> dayList {get; set;}

        @AuraEnabled
        public List<Options> channelList {get; set;}

        @AuraEnabled
		public List<Options> shopList {get; set;}

        @AuraEnabled
		public List<Options> ownerList {get; set;}

        @AuraEnabled
		public List<Options> statusList {get; set;}

        @AuraEnabled
        public String inspectionDateLabel {get; set;}

        @AuraEnabled
        public String channelLabel {get; set;}

        @AuraEnabled
        public String shopLabel {get; set;}

        @AuraEnabled
        public String noteLabel {get; set;}

        @AuraEnabled
        public String statusLabel {get; set;}

        @AuraEnabled
        public String ownerLabel {get; set;}

        //--------------------------------

        @AuraEnabled
		public Boolean isSuccess {get; set;}

		@AuraEnabled
		public String errorMsg {get; set;}

	} 
    public class Options {

		@AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

    }

}