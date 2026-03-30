public without sharing class SyncExhibitionPersonnelToOA {
    // private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CUSTOMERINFO_CREATE_SEND';
    // private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    // private static String password = Interface_Url__c.getValues('SAP').Password__c;

    private static String url = System.Label.Exhibition_OA_API_URL;

    private static List<String> strList = new List<String>();

    /* Cutomer Information */
    public class CustomerInfo {
        //展会信息
        public String ExhibitionId;
        public String ExhibitionCode;
        public String ExhibitionName;
        public String ExhibitionNameEN;
        public String ExhibitionAddress;
        public String ExhibitionAddressEN;
        public String ExhibitionIntro;
        public String ExhibitionIntroEN;
        public String ExhibitionDetail;
        public String ExhibitionDetailEN;
        public String ExhibitionCoverImgPublicLink;
        public String ExhibitionCoverImg;
        public String ExhibitionOfficialLink;
        public String ExhibitionSession;
        public String ExhibitionStartDate;
        public String ExhibitionEndDate;
        public String ExhibitionLastRegistrationDate;
        public Boolean ExhibitionDisplayInThePortal;


        //员工信息
        public List <InternalInfo> InternalInfoList;
        
    }


    public class InternalInfo {
        public String InternalId;
        public String InternalEmployeeNumber;
        public String InternalNmae;
        public String InternalNameEN;
        public String InternalGender;
        public String InternalBirthday;
        public String InternalPhone;
        public String InternalEmail;
        public String InternalRegion;
        public String InternalCompanyAbbr;
        public String InternalApprovalStatus;
        public String InternalPosition;
        public String InternalIDCardNo;
        public String InternalPassportNo;
        public String InternalPassportExpirationDate;
        public String InternalIsValidSchengenVisa;
        public String InternalContactName;
        public String InternalExhibitionResponsibility;
        public String InternalContactEmail;
        public String InternalPurposeOfExhibition;
        public String InternalCertificateType;
        public String InternalDeliverable;
    }

    public class ResDeta {
        public String fdCode;//1成功
        public String fdMessage;
        public String fdId;
        public String fdNo;
    }

    public static String getSubmitter() {
        String loginName = Label.Default_OA_Submitter;
        User u = [SELECT ID, HisenseSSOName__c FROM USER WHERE ID = :(UserInfo.getUserId())];
        // if (!String.isBlank(u.HisenseSSOName__c)) {
        //     loginName = u.HisenseSSOName__c;
        // }
        // if (String.isBlank(loginName)) {
        //     loginName = 'cuijie3';
        // }
        loginName = 'exhibition';
        String docCreator = '{"LoginName":"' + loginName + '"}';
        return docCreator;
    }

    //部门审批
    @AuraEnabled
    public static String postCustomerInfomationToOA(String customerId,String oneApp,String twoApp,String opinion,List<Object> intIds) {
        Id cid= Id.valueOf(customerId);
        String objectName = cid.getSObjectType().getDescribe().getName();


        List<ExpoInfo__c> expoInfoList = [SELECT Id,Name,TitleCN__c,TitleEN__c,AddressEN__c,
                                            OutLineCN__c,OutLineEN__c,ContentCN__c,ContentEN__c,CoverImg__c,
                                            CoverImgPublicLink__c,Link__c,Flag__c,StartDate__c,EndDate__c,Tips__c,
                                            LastRegistrationDate__c,DisplayInThePortal__c 
                                            FROM ExpoInfo__c 
                                            WHERE Id =: customerId];

        System.debug('expoInfoList--='+expoInfoList);
        if (expoInfoList.size()==0) {
            return 'failure: Data does not exist! ';
        }
        System.debug('一级审批人信息' + oneApp);
        System.debug('二级审批人信息' + twoApp);

        List<Mapping_Configuration__c> mapConList = [SELECT Id,Name,OAXH__c,OA_Interactive__c,OA_Purpose_Exhibition__c,
                                            OA_Internal_Name__c,OA_Exhibition_Nmae__c,OA_Position__c,
                                            OA_Phone__c,OA_Description__c,OA_Email__c,OA_Department_Name__c,
                                            OA_Department_Code__c,Approval_Node1__c,Approval_Node2__c,
                                            OA_Opinion__c,Map_Name__c  
                                            FROM Mapping_Configuration__c 
                                            WHERE Map_Name__c ='OADepartmentApproval'];

        Map<String,Object> resData = new Map<String,Object>();
        resData.put(mapConList[0].OA_Exhibition_Nmae__c,expoInfoList[0].Name);//展会名称
        resData.put(mapConList[0].OA_Description__c, CommonUtils.getStr(expoInfoList[0].Tips__c));//OutLineCN__c简述说明 <==> Tips费用说明2025-03
        resData.put(mapConList[0].Approval_Node1__c,oneApp);//审批节点1
        resData.put(mapConList[0].Approval_Node2__c,twoApp);//审批节点2
        resData.put(mapConList[0].OA_Opinion__c,opinion);//处理意见
        Set<String> idSet = new Set<String>();
        for (Object obj : intIds) {
            idSet.add((String)obj);
        }

        List<Internal_Registration__c> inRegList = [SELECT Id,Exhibition_Id__c,Name_CN__c,
                                                 Position__c,Purpose_Of_Exhibition__c,
                                                 Deliverable__c,Email__c,Phone__c,
                                                 Department_Code__c,Department_Name__c,Company_Abbr__c,
                                                 Approval_Cycle__c,
                                                 XHNumber__c,Is_Valid_US_Schengen_Visa__c   
                                                 FROM Internal_Registration__c 
                                                 WHERE Id IN: idSet];



        List<String> resNameList = new List<String>();
        List<String> resPositionList = new List<String>();
        List<String> resDepaNameList = new List<String>();
        List<String> resDepaCodeList = new List<String>();
        List<String> resPurposeList = new List<String>();
        List<String> resDeliverableList = new List<String>();
        List<String> resEmailList = new List<String>();
        List<String> resPhoneList = new List<String>();
        List<String> resXHList = new List<String>();                                           
        // List<Boolean> resXHList = new List<Boolean>();                                         
        if (inRegList.size()>0) {
            for (Internal_Registration__c intReg : inRegList) {
                String department = intReg.Company_Abbr__c;
                String nameDepart;
                if(String.isNotEmpty(department)){nameDepart = ProcessStringLock(department);}
                resNameList.add(intReg.Name_CN__c);
                resPositionList.add(intReg.Position__c);
                resDepaNameList.add(nameDepart);
                resDepaCodeList.add(intReg.Department_Code__c);
                resPurposeList.add(intReg.Purpose_Of_Exhibition__c);
                resDeliverableList.add(intReg.Deliverable__c);
                resEmailList.add(intReg.Email__c);
                resPhoneList.add(intReg.Phone__c);
                resXHList.add(intReg.Is_Valid_US_Schengen_Visa__c + ''); //<--TJP 20241209 XHNumber__c =change=> Is_Valid_US_Schengen_Visa__c-->
            }
        }else{
            return 'failure: Data does not exist! ';
        }

        resData.put(mapConList[0].OA_Internal_Name__c,resNameList);//姓名
        resData.put(mapConList[0].OA_Position__c,resPositionList);//岗位
        resData.put(mapConList[0].OA_Department_Name__c,resDepaNameList);//部门名称
        // resData.put(mapConList[0].OA_Department_Code__c,resDepaCodeList);//部门编码 <==> 参展证类型
        resData.put(mapConList[0].OA_Purpose_Exhibition__c,resPurposeList);//参展目的
        resData.put(mapConList[0].OA_Interactive__c,resDeliverableList);//交付物
        resData.put(mapConList[0].OA_Email__c,resEmailList);//邮箱
        resData.put(mapConList[0].OA_Phone__c,resPhoneList);//电话
        resData.put(mapConList[0].OAXH__c,resXHList);//信鸿号 <--20241208 TJP 字段修改 信鸿号改为 Is_Valid_US_Schengen_Visa__c 字段-->
        

        String bodyData = JSON.serialize(resData);
        System.debug('XXXX' + bodyData);
        String docCreator = getSubmitter();
        //Ethan 动态存储
        // String fdTemplateId = '18905be693e1c2c434aa8044a17a436d';
        String fdTemplateId = mapConList[0].Name;
        String origin = 'HIDEMO';
        String docStatus = '20';

        String body = '';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docSubject"\r\n\r\n';
        body += CommonUtils.getStr(expoInfoList[0].TitleCN__c) + '参展人员信息提报|' + CommonUtils.getStr(expoInfoList[0].TitleEN__c) + ' Participant Submit' + '\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="fdTemplateId"\r\n\r\n';
        body += fdTemplateId+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docCreator"\r\n\r\n';
        body += docCreator+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="origin"\r\n\r\n';
        body += origin+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docStatus"\r\n\r\n';
        body += docStatus+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="formValues"\r\n\r\n';
        body += bodyData+'\r\n';
        body += '----------------------------829282981397893098228886--\r\n';
        System.debug('body:: ' + body); 

        ResDeta input = new ResDeta();
        String bodyRes;
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SyncExhibitionPersonnelToOA';
        ic.Time__c = System.Now();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'multipart/form-data; boundary=--------------------------829282981397893098228886');
            request.setTimeout(12000); // timeout in milliseconds
            request.setBody(body);
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            ResDeta input_login = new ResDeta();
            input_login = (ResDeta) JSON.deserialize(bodyRes, ResDeta.class);
            System.debug('~~~~~~~~~~~~~~');
            System.debug('input_login '+input_login);

            //handle log
            if (input_login.fdCode == '1') {
                List<Internal_Registration__c> updateIntReg = new List<Internal_Registration__c>();
                //同步成功，更新字段
                if (inRegList.size()>0) {
                    for (Internal_Registration__c intData : inRegList) {
                        Internal_Registration__c intReg = new Internal_Registration__c();
                        intReg.Approval_FDID__c = input_login.fdId;
                        if(String.isNotEmpty(oneApp)){intReg.Approval_Status__c = '部门审批中';} else {intReg.Approval_Status__c = '分管领导/大区总审批中';}
                        intReg.Id = intData.Id;
                        updateIntReg.add(intReg);
                    }
                }
                if (updateIntReg.size()>0) {
                    update updateIntReg;
                }
                ic.ReturnCode__c = '1';
                ic.Res_Json__c = body;
                ic.Req_Json__c = bodyRes;
                ic.IsSuccess__c = true;
                insert ic;
                // Utility.insertLog('SyncExhibitionPersonnelToOA', '1', body, bodyRes);
            } else {
                //log
                // Utility.insertLog('SyncExhibitionPersonnelToOA', '0', body, input_login.fdMessage);
                ic.ReturnCode__c = '0';
                ic.Res_Json__c = body;
                ic.Req_Json__c = input_login.fdMessage;
                ic.IsSuccess__c = false;
                insert ic;
                return input_login.fdMessage;
            }
        } catch(Exception e) {
            //Integration Log
            // Utility.insertLog('SyncExhibitionPersonnelToOA', '0', body, 'failure: SF Sync Customer Information to OA Failed! ' + e.getMessage());
            ic.ReturnCode__c = '0';
            ic.Res_Json__c = body;
            ic.Req_Json__c = 'failure: SF Sync Customer Information to OA Failed!'+e.getMessage();
            ic.IsSuccess__c = false;
            insert ic;
            return 'failure: SF Sync Customer Information to OA Failed! ' + e.getMessage();
        }
        
        return 'SUCCESS';
    }

    public static String ProcessStringLock(String input) {
        if (!input.contains('\\')) { // 注意：需要转义反斜杠
            System.debug('字段中不包含 \\');
            return input;
        }
        // System.debug('部门' + inter.Company_Abbr__c);
        List<String> parts = input.split('\\\\', -1);
        Integer backslashCount = parts.size() - 1; 
        
        if (backslashCount < 2) {
            System.debug('\\ 的数量不超过两个，当前数量为：' + backslashCount);
            return input;
        } else {
            String result = '';
            for (Integer i = parts.size() - 3; i < parts.size(); i++) {
                result += '\\' + parts[i]; // 注意：重新添加转义的 \ 作为分隔符
            }
		    result = result.substring(1, result.length());
            System.debug('截取结果：' + result);
            return result;
        }

       
    }

    //总办审批
    @AuraEnabled
    public static String postCustomerInfomationToOAExecutive(String customerId,String oneApp,String twoApp) {
        Id cid= Id.valueOf(customerId);
        String objectName = cid.getSObjectType().getDescribe().getName();


        List<ExpoInfo__c> expoInfoList = [SELECT Id,Name,TitleCN__c,TitleEN__c,AddressEN__c,
                                            OutLineCN__c,OutLineEN__c,ContentCN__c,ContentEN__c,CoverImg__c,
                                            CoverImgPublicLink__c,Link__c,Flag__c,StartDate__c,EndDate__c,
                                            LastRegistrationDate__c,DisplayInThePortal__c 
                                            FROM ExpoInfo__c 
                                            WHERE Id =: customerId];

        System.debug('expoInfoList--='+expoInfoList);
        if (expoInfoList.size()==0) {
            return 'failure: Data does not exist! ';
        }

        List<Mapping_Configuration__c> mapConList = [SELECT Id,Name,OAXH__c,OA_Interactive__c,OA_Purpose_Exhibition__c,
                                            OA_Internal_Name__c,OA_Exhibition_Nmae__c,OA_Position__c,
                                            OA_Phone__c,OA_Description__c,OA_Email__c,OA_Department_Name__c,
                                            OA_Department_Code__c,Approval_Node1__c,Approval_Node2__c,
                                            Map_Name__c  
                                            FROM Mapping_Configuration__c 
                                            WHERE Map_Name__c ='OAExecutiveApproval'];

        Map<String,Object> resData = new Map<String,Object>();
        resData.put(mapConList[0].OA_Exhibition_Nmae__c,expoInfoList[0].Name);//展会名称
        resData.put(mapConList[0].OA_Description__c,expoInfoList[0].OutLineCN__c);//简述说明
        resData.put(mapConList[0].Approval_Node1__c,oneApp);//审批节点1
        resData.put(mapConList[0].Approval_Node2__c,twoApp);//审批节点2


        List<Internal_Registration__c> inRegList = [SELECT Id,Exhibition_Id__c,Name_CN__c,
                                                 Position__c,Purpose_Of_Exhibition__c,
                                                 Deliverable__c,Email__c,Phone__c,
                                                 Department_Code__c,Department_Name__c,
                                                 XHNumber__c,Is_Valid_US_Schengen_Visa__c      
                                                 FROM Internal_Registration__c 
                                                 WHERE Exhibition_Id__c =: customerId 
                                                 AND (Approval_Status__c = '部门审批通过' OR Approval_Status__c = '审批驳回')];



        List<String> resNameList = new List<String>();
        List<String> resPositionList = new List<String>();
        List<String> resDepaNameList = new List<String>();
        List<String> resDepaCodeList = new List<String>();
        List<String> resPurposeList = new List<String>();
        List<String> resDeliverableList = new List<String>();
        List<String> resEmailList = new List<String>();
        List<String> resPhoneList = new List<String>();
        List<String> resXHList = new List<String>();
        // List<Boolean> resXHList = new List<Boolean>();                                          
        if (inRegList.size()>0) {
            for (Internal_Registration__c intReg : inRegList) {
                resNameList.add(intReg.Name_CN__c);
                resPositionList.add(intReg.Position__c);
                resDepaNameList.add(intReg.Department_Name__c);
                resDepaCodeList.add(intReg.Department_Code__c);
                resPurposeList.add(intReg.Purpose_Of_Exhibition__c);
                resDeliverableList.add(intReg.Deliverable__c);
                resEmailList.add(intReg.Email__c);
                resPhoneList.add(intReg.Phone__c);
                resXHList.add(intReg.XHNumber__c);
            }
        }else{
            return 'failure: Data does not exist! ';
        }


        resData.put(mapConList[0].OA_Internal_Name__c,resNameList);//姓名
        resData.put(mapConList[0].OA_Position__c,resPositionList);//岗位
        resData.put(mapConList[0].OA_Department_Name__c,resDepaNameList);//部门名称
        // resData.put(mapConList[0].OA_Department_Code__c,resDepaCodeList);//部门编码
        resData.put(mapConList[0].OA_Purpose_Exhibition__c,resPurposeList);//参展目的
        resData.put(mapConList[0].OA_Interactive__c,resDeliverableList);//交付物
        // resData.put(mapConList[0].OA_Email__c,resEmailList);//邮箱
        // resData.put(mapConList[0].OA_Phone__c,resPhoneList);//电话
        // resData.put(mapConList[0].OAXH__c,resXHList);//信鸿号

        String bodyData = JSON.serialize(resData);

        String docCreator = getSubmitter();
        //Ethan 动态存储
        // String fdTemplateId = '18905be693e1c2c434aa8044a17a436d';
        String fdTemplateId = mapConList[0].Name;
        String origin = 'HIDEMO';
        String docStatus = '20';

        String body = '';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docSubject"\r\n\r\n';
        body += CommonUtils.getStr(expoInfoList[0].TitleCN__c) + '参展人员信息提报|' + CommonUtils.getStr(expoInfoList[0].TitleEN__c) + ' Participant Submit' + '\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="fdTemplateId"\r\n\r\n';
        body += fdTemplateId+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docCreator"\r\n\r\n';
        body += docCreator+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="origin"\r\n\r\n';
        body += origin+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="docStatus"\r\n\r\n';
        body += docStatus+'\r\n';
        body += '----------------------------829282981397893098228886\r\n';
        body += 'Content-Disposition: form-data; name="formValues"\r\n\r\n';
        body += bodyData+'\r\n';
        body += '----------------------------829282981397893098228886--\r\n';
        System.debug('body:: ' + body); 

        ResDeta input = new ResDeta();
        String bodyRes;
        InterfaceLog__c ic = new InterfaceLog__c();
        ic.Class__c = 'SyncExhibitionPersonnelToOA';
        ic.Time__c = System.Now();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'multipart/form-data; boundary=--------------------------829282981397893098228886');
            request.setTimeout(12000); // timeout in milliseconds
            request.setBody(body);
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            ResDeta input_login = new ResDeta();
            input_login = (ResDeta) JSON.deserialize(bodyRes, ResDeta.class);
            System.debug('~~~~~~~~~~~~~~');
            System.debug('input_login '+input_login);

            //handle log
            if (input_login.fdCode == '1') {
                List<Internal_Registration__c> updateIntReg = new List<Internal_Registration__c>();
                //同步成功，更新字段
                if (inRegList.size()>0) {
                    for (Internal_Registration__c intData : inRegList) {
                        Internal_Registration__c intReg = new Internal_Registration__c();
                        intReg.Approval_FDID__c = input_login.fdId;
                        intReg.Approval_Status__c = '总办审批中';
                        intReg.Id = intData.Id;
                        updateIntReg.add(intReg);
                    }
                }
                if (updateIntReg.size()>0) {
                    update updateIntReg;
                }
                ic.ReturnCode__c = '1';
                ic.Res_Json__c = body;
                ic.Req_Json__c = bodyRes;
                ic.IsSuccess__c = true;
                insert ic;
                // Utility.insertLog('SyncExhibitionPersonnelToOA', '1', body, bodyRes);
            } else {
                //log
                // Utility.insertLog('SyncExhibitionPersonnelToOA', '0', body, input_login.fdMessage);
                ic.ReturnCode__c = '0';
                ic.Res_Json__c = body;
                ic.Req_Json__c = input_login.fdMessage;
                ic.IsSuccess__c = false;
                insert ic;
                return input_login.fdMessage;
            }
        } catch(Exception e) {
            //Integration Log
            // Utility.insertLog('SyncExhibitionPersonnelToOA', '0', body, 'failure: SF Sync Customer Information to OA Failed! ' + e.getMessage());
            ic.ReturnCode__c = '0';
            ic.Res_Json__c = body;
            ic.Req_Json__c = 'failure: SF Sync Customer Information to OA Failed!'+e.getMessage();
            ic.IsSuccess__c = false;
            insert ic;
            return 'failure: SF Sync Customer Information to OA Failed! ' + e.getMessage();
        }
        
        return 'SUCCESS';
    }

}