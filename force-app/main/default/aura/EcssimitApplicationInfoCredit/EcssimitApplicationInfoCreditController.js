/*
 * @Author: WFC
 * @Date: 2023-10-26 17:03:48
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-19 10:25:09
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\CreditLimitApplicationRRInfoCMP\CreditLimitApplicationRRInfoCMPController.js
 */
({
	myAction : function(component, event, helper) {

        const translate = {  
            'ECSS扫描结果': 'ecssResult',          
            '数据提供方编码' : 'dataSupplierCode',
            '数据提供方名称' : 'dataSupplierName',
            'RPL记录编码' : 'referenceId',
            '类型' : 'type',
            '法律法规' : 'lawsAndRegulation',
            '清单类型' : 'listType',
            '名称' : 'name',
            '国家/地区' : 'country',
            '城市' : 'city',
            '地址' : 'screet',
            '邮编' : 'zip',
            '扫描结果' : 'matchedResult' 
        } 

		var recordId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        var ecssList = [];
        action.setParams({recordId : recordId});
        action.setCallback(this, function(data) {
            
            jsonData = JSON.parse(data.getReturnValue());
            for(var i=0;i<jsonData.ecssList.length;i++){

                var rrAuditItem = {};
                // rrAuditItem.Id = jsonData.ecssList[i].Id;
                // rrAuditItem.ecss_result__c = translate[jsonData.ecssList[i].ecss_result__c];
                // rrAuditItem.dataSupplierCode__c = translate[jsonData.ecssList[i].dataSupplierCode__c];
                // rrAuditItem.dataSupplierName__c = translate[jsonData.ecssList[i].dataSupplierName__c];
                // rrAuditItem.type__c = jsonData.ecssList[i].type__c;
                // rrAuditItem.referenceId__c = translate[jsonData.ecssList[i].referenceId__c];
                // rrAuditItem.lawsAndRegulation__c = jsonData.ecssList[i].lawsAndRegulation__c;
                // rrAuditItem.listType__c = jsonData.ecssList[i].listType__c;
                // rrAuditItem.name__c = jsonData.ecssList[i].name__c;
                // rrAuditItem.country__c = translate[jsonData.ecssList[i].country__c];
                // rrAuditItem.city__c = jsonData.ecssList[i].city__c;
                // rrAuditItem.street__c = jsonData.ecssList[i].street__c;
                // rrAuditItem.zip__c = jsonData.ecssList[i].zip__c;
                // rrAuditItem.matchedResult__c = jsonData.ecssList[i].matchedResult__c;
                rrAuditItem.Id = jsonData.ecssList[i].Id;
                rrAuditItem.ecss_result__c = jsonData.ecssList[i].ecss_result__c;
                rrAuditItem.dataSupplierCode__c = jsonData.ecssList[i].dataSupplierCode__c;
                rrAuditItem.dataSupplierName__c = jsonData.ecssList[i].dataSupplierName__c;
                rrAuditItem.type__c = jsonData.ecssList[i].type__c;
                rrAuditItem.referenceId__c = jsonData.ecssList[i].referenceId__c;
                rrAuditItem.lawsAndRegulation__c = jsonData.ecssList[i].lawsAndRegulation__c;
                rrAuditItem.listType__c = jsonData.ecssList[i].listType__c;
                rrAuditItem.name__c = jsonData.ecssList[i].name__c;
                rrAuditItem.country__c = jsonData.ecssList[i].country__c;
                rrAuditItem.city__c = jsonData.ecssList[i].city__c;
                rrAuditItem.street__c = jsonData.ecssList[i].street__c;
                rrAuditItem.zip__c = jsonData.ecssList[i].zip__c;
                rrAuditItem.matchedResult__c = jsonData.ecssList[i].matchedResult__c;
                ecssList.push(rrAuditItem);
            };
           
            component.set("v.rrAuditListData",ecssList);
        });
        $A.enqueueAction(action);
	},

    admit : function(component, event, helper) {
        component.set("v.loaded",true);

        const translate = {
            'ECSS扫描结果': 'ecssResult',        
            '数据提供方编码' : 'dataSupplierCode',
            '数据提供方名称' : 'dataSupplierName',
            'RPL记录编码' : 'referenceId',
            '类型' : 'type',
            '法律法规' : 'lawsAndRegulation',
            '清单类型' : 'listType',
            '名称' : 'name',
            '国家/地区' : 'country',
            '城市' : 'city',
            '地址' : 'screet',
            '邮编' : 'zip',
            '扫描结果' : 'matchedResult' 
        } 

        var recordId = component.get("v.recordId");
        var action = component.get("c.syncData");
        var jsonData;
        var ecssList = [];
        action.setParams({recordId : recordId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            //alert(jsonData);
                for(var i=0;i<jsonData.ecssList.length;i++){
                    var rrAuditItem = {};                   

                    rrAuditItem.Id = jsonData.ecssList[i].Id;
                    rrAuditItem.ecss_result__c = jsonData.ecssList[i].ecss_result__c;
                    rrAuditItem.dataSupplierCode__c = jsonData.ecssList[i].dataSupplierCode__c;
                    rrAuditItem.dataSupplierName__c = jsonData.ecssList[i].dataSupplierName__c;
                    rrAuditItem.type__c = jsonData.ecssList[i].type__c;
                    rrAuditItem.referenceId__c = jsonData.ecssList[i].referenceId__c;
                    rrAuditItem.lawsAndRegulation__c = jsonData.ecssList[i].lawsAndRegulation__c;
                    rrAuditItem.listType__c = jsonData.ecssList[i].listType__c;
                    rrAuditItem.name__c = jsonData.ecssList[i].name__c;
                    rrAuditItem.country__c = jsonData.ecssList[i].country__c;
                    rrAuditItem.city__c = jsonData.ecssList[i].city__c;
                    rrAuditItem.street__c = jsonData.ecssList[i].street__c;
                    rrAuditItem.zip__c = jsonData.ecssList[i].zip__c;
                    rrAuditItem.matchedResult__c = jsonData.ecssList[i].matchedResult__c;
                    ecssList.push(rrAuditItem);
                };
            
                component.set("v.rrAuditListData",ecssList);
                component.set("v.loaded",false);
        });
        $A.enqueueAction(action);
	},
})