public with sharing class InspectionPDFPageController {
    
    public Daily_Inspection_Report__c insepction{ get; set; }
    public String checkIn{ get; set; }
    public String checkOut{ get; set; }
    public String html{ get; set; }
    public List<OutPut> outPut{ get; set; }
    public List<SelectOption> yesNO{ get; set; }
    public List<String> linkList{ get; set; }

    // 初始化巡店员日报pdf导出数据
    public InspectionPDFPageController() {

        String id = ApexPages.CurrentPage().getParameters().get('ID');

        insepction = [SELECT Id,
                             Name,
                             Store__r.Name,
                             Store__r.Address1__c,
                             Store__r.Sales_Region__c,
                             Channel__c,
                             CreatedBy.Name,
                             Status__c,
                             Distance__c,
                             Note__c,
                             Report_Date__c,
                             Inspect_Type__c,
                             NeedCheckIn__c,
                             OwnerId 
                             FROM Daily_Inspection_Report__c 
                             WHERE Id =: id];

        // if(insepction.NeedCheckIn__c && insepction.Inspect_Type__c != 'Remote Inspection'){
            // 考勤ExId
            String externalId = insepction.OwnerId + '_' + String.valueOf(insepction.Report_Date__c);

            // 查询当天考勤信息
            List<Promoter_Attendance__c> attendanceList = [SELECT SignInTime__c,
                                                                SignOutTime__c, 
                                                                CheckIn_Date__c 
                                                                FROM Promoter_Attendance__c 
                                                                WHERE ExternalId__c =: externalId];
            if(attendanceList != null && attendanceList.size() > 0){
                Promoter_Attendance__c attendance = attendanceList[0];
                String checkInDate = String.valueOf(attendance.CheckIn_Date__c).subString(0,10);
                if(attendance.SignInTime__c != null){
                    checkIn = checkInDate + ' ' + String.valueOf(attendance.SignInTime__c).subString(0,5);
                }

                if(attendance.SignOutTime__c != null){
                    checkOut = checkInDate + ' ' +String.valueOf(attendance.SignOutTime__c).subString(0,5);
                }

                // 查询签到信息
                List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(attendance.Id, insepction.Report_Date__c, insepction.Store__c);
                if(paiList != null && paiList.size() > 0){
                    // 附件部分
                    List<ContentDocumentLink> cdlList = paiList[0].ContentDocumentLinks;
                    if(cdlList != null && cdlList.size() > 0){
                        linkList = new List<String>();
                        for(ContentDocumentLink cdLink : cdlList){
                            linkList.add('/sfc/servlet.shepherd/version/download/' + cdLink.ContentDocument.LatestPublishedVersionId);
                        }
                    }
                }
            }

            // 查询当前巡店员日报国家对应的大类信息
            List<Inspection_Product_Item__c> insepctionItem = getInspectionProductItem(insepction.Id);

            outPut = new List<OutPut>();
            if(insepctionItem != null && insepctionItem.size() > 0){

                // 获取Inspection_Product_Item__c Id
                LisqContainer lqItem = new LisqContainer(insepctionItem);
                List<String> ids = lqItem.SelectSField('Id');

                // 查询当前日报所有的检查项详情
                List<CheckResult__c> checkResult = getCheckResultAll(insepction.Id);
                NewSamplingAndTicketProController.setCheckItemLanguage(checkResult);

                List<Sampling_Inspection__c> insepctionSam = getSamplingInspectionItem(ids);

                // 根据巡店员日报一级大类分组
                Map<String,Map<String,List<CheckResult__c>>> groupCheckResult = new Map<String,Map<String,List<CheckResult__c>>>();
                for(CheckResult__c res : checkResult){
    
                    Map<String,List<CheckResult__c>> groupCheckType = groupCheckResult.get(res.Inspection_Product_Item__c);

                    if(groupCheckType != null && groupCheckType.size() > 0){

                        List<CheckResult__c> checkResultList = groupCheckType.get(res.CheckItem__r.Item_Type__c);
                        if(checkResultList == null || checkResultList.size() == 0){
                            checkResultList = new List<CheckResult__c>();
                        }

                        checkResultList.add(res);
                        groupCheckType.put(res.CheckItem__r.Item_Type__c, checkResultList);

                    }else{
                        List<CheckResult__c> checkResultList = new List<CheckResult__c>();
                        checkResultList.add(res);

                        groupCheckType = new Map<String,List<CheckResult__c>>(); 
                        groupCheckType.put(res.CheckItem__r.Item_Type__c, checkResultList);

                    }

                    groupCheckResult.put(res.Inspection_Product_Item__c,groupCheckType);
                }

                Map<String,Map<String,List<SamplingCheckResult>>> groupSamplingInspection = new Map<String,Map<String,List<SamplingCheckResult>>>();
                if(insepctionSam != null && insepctionSam.size() > 0){

                    // 根据出样查询对应的检查项模块
                    LisqContainer lqSam = new LisqContainer(insepctionSam);
                    List<String> samIds = lqSam.SelectSField('Id');
                    List<CheckResult__c> samCheckResult = getSamCheckResult(samIds);

                    // 根据出样id分组
                    Map<String,List<CheckResult__c>> groupSamCheck = new Map<String,List<CheckResult__c>>();
                    if(samCheckResult != null && samCheckResult.size() > 0){
                        for(CheckResult__c res : samCheckResult){
                            List<CheckResult__c> checkResultList = groupSamCheck.get(res.Sampling_Inspection__c);
                            if(checkResultList == null || checkResultList.size() == 0){
                                checkResultList = new List<CheckResult__c>();
                            }

                            checkResultList.add(res);
                            groupSamCheck.put(res.Sampling_Inspection__c,checkResultList);
                        }
                    }

                    for(Sampling_Inspection__c samItem : insepctionSam){
                        Map<String,List<SamplingCheckResult>> groupSampling = groupSamplingInspection.get(samItem.Inspection_Product_Item__c);

                        SamplingCheckResult samResult = new SamplingCheckResult();
                        samResult.samplingInspection = samItem;

                        List<CheckResult__c> result = groupSamCheck.get(samItem.Id);
                        if(result != null && result.size() > 0){
                            samResult.checkResultList = result;
                        }

                        if(groupSampling != null && groupSampling.size() > 0){
                            List<SamplingCheckResult> sam = groupSampling.get(samItem.Product__r.Product_Line__c);

                            if(sam == null || sam.size() == 0){
                                sam = new List<SamplingCheckResult>();
                            }

                            sam.add(samResult);
                            groupSampling.put(samItem.Product__r.Product_Line__c,sam);

                        }else{
                            List<SamplingCheckResult> sam = new List<SamplingCheckResult>();
                            sam.add(samResult);

                            groupSampling = new Map<String,List<SamplingCheckResult>>();
                            groupSampling.put(samItem.Product__r.Product_Line__c,sam);
                        }

                        groupSamplingInspection.put(samItem.Inspection_Product_Item__c,groupSampling);
                    }
                }

                for(Inspection_Product_Item__c item : insepctionItem){
                    OutPut out = new OutPut();
                    out.type = item.Type__c;

                    Map<String,List<CheckResult__c>> itemType = groupCheckResult.get(item.Id);
                    Map<String,List<SamplingCheckResult>> samType = groupSamplingInspection.get(item.Id);
                    if(itemType != null && itemType.size() > 0){
                        List<CheckResult> checkResultData = new List<CheckResult>();
                        for(String key : itemType.keySet()){
                            CheckResult itemData = new CheckResult();
                            itemData.itemType = key;
                            itemData.checkResultList = itemType.get(key);

                            checkResultData.add(itemData);
                        }
                        out.data = checkResultData;
                    }

                    if(samType != null && samType.size() > 0){
                        List<SamplingInspectionData> samResultData = new List<SamplingInspectionData>();
                        for(String key : samType.keySet()){
                            SamplingInspectionData si = new SamplingInspectionData();
                            si.productLine = key;
                            si.samplingCheckResult = samType.get(key);

                            samResultData.add(si);
                        }

                        out.dataSam = samResultData;
                    }

                    outPut.add(out);
                }
                System.debug('wwwwoutPut' + JSON.serialize(outPut));
            }else{
                // checklist部分
                Map<String,Map<String, List<CheckResult__c>>> checkResults = NewInspectorDailyReportController.getCheckResult(insepction.Id);

                System.debug('wwww' + JSON.serialize(checkResults));

                if(checkResults != null && checkResults.size() > 0){
                    for(String key : checkResults.keySet()){
                        OutPut out = new OutPut();
                        out.type = key;
                        List<checkResult> temp = new List<checkResult>();
                        Map<String, List<CheckResult__c>> itemType = checkResults.get(key);
                        if(itemType != null && itemType.size() > 0){
                            for(String keyItem : itemType.keySet()){
                                List<CheckResult__c> checkResult = itemType.get(keyItem);
                                if(checkResult != null && checkResult.size() > 0){
                                    // 总分，得分
                                    Decimal allScore = 0; 
                                    Decimal score = 0;
                                    for(CheckResult__c cr : checkResult){
                                        allScore += Decimal.valueOf(cr.CheckItem__r.MaximumScore__c);
                                        score += cr.Scores__c > 0 ? cr.Scores__c : 0;
                                    }

                                    CheckResult itemData = new CheckResult();
                                    itemData.itemType = keyItem + ' ('+ score + '/' + allScore + ')';
                                    itemData.checkResultListT = checkResult;

                                    temp.add(itemData);
                                }
                            }
                            out.data = temp;
                        }
                        outPut.add(out);
                    }
                }

                // 出样部分
                List<Sampling_Inspection__c> insepctionSam = getSamplingInspection(insepction.Id);
                // 系统中产品线顺序
                List<Map<String, String>> productLineMapList = NewInspectorDailyReportController.getPickList('Product__c','Product_Line__c');
                List<String> productLineReferenceList = new List<String>();
                for(Map<String, String> pl : productLineMapList){
                    productLineReferenceList.add(pl.get('label'));
                }
                // 分产品线
                Set<String> productLineSet = new Set<String>();
                // key：产品线，value：出样检查集合
                Map<String, List<Sampling_Inspection__c>> inspectionProuductLineMap = new Map<String, List<Sampling_Inspection__c>>();
                if(insepctionSam != null && insepctionSam.size() > 0){
                    // 产品线排序
                    for(Sampling_Inspection__c si : insepctionSam){
                        productLineSet.add(si.Product__r.Product_Line__c);
                        if(inspectionProuductLineMap.containsKey(si.Product__r.Product_Line__c)){
                            inspectionProuductLineMap.get(si.Product__r.Product_Line__c).add(si);
                        }else {
                            inspectionProuductLineMap.put(si.Product__r.Product_Line__c, new List<Sampling_Inspection__c>{ si });
                        }
                    }
                    List<String> productLineList = CustomSorterContoller.sortByReference(new List<String>(productLineSet), productLineReferenceList);
                    List<SamplingInspectionData> sidList = new List<SamplingInspectionData>();
                    // 处理数据，页面展示
                    for(String productLine : productLineList){
                        OutPut out = new OutPut();
                        out.type = productLine;
                        
                        List<Sampling_Inspection__c> tempList = inspectionProuductLineMap.get(productLine);
                        List<SamplingCheckResult> samplingCheckResultList = new List<SamplingCheckResult>();
                        for(Sampling_Inspection__c si : tempList){
                            SamplingCheckResult scr = new SamplingCheckResult();
                            scr.samplingInspection = si;

                            samplingCheckResultList.add(scr);
                        }
                        SamplingInspectionData samplingInspectionData = new SamplingInspectionData();
                        samplingInspectionData.samplingCheckResult = samplingCheckResultList;
                        out.dataSam = new List<SamplingInspectionData> {samplingInspectionData};

                        outPut.add(out);
                    }
                }
            }
        // }
     }


    // public InspectionPDFPageController() {
    //     insepction = [SELECT Id,
    //                          Name,
    //                          Store__r.Name,
    //                          Store__r.Address1__c,
    //                          Store__r.Sales_Region__c,
    //                          Channel__c,
    //                          CreatedBy.Name,
    //                          Status__c,
    //                          Distance__c,
    //                          Note__c,
    //                          Report_Date__c,
    //                          Inspect_Type__c,
    //                          NeedCheckIn__c,
    //                          OwnerId 
    //                          FROM Daily_Inspection_Report__c 
    //                          WHERE Id = 'a1aA2000000FPyzIAG'];

    //     if(insepction.NeedCheckIn__c && insepction.Inspect_Type__c != 'Remote Inspection'){
    //         // 考勤ExId
    //         String externalId = insepction.OwnerId + '_' + String.valueOf(insepction.Report_Date__c);

    //         // 查询当天考勤信息
    //         List<Promoter_Attendance__c> attendanceList = [SELECT SignInTime__c,
    //                                                             SignOutTime__c, 
    //                                                             CheckIn_Date__c 
    //                                                             FROM Promoter_Attendance__c 
    //                                                             WHERE ExternalId__c =: externalId];
    //         if(attendanceList != null && attendanceList.size() > 0){
    //             Promoter_Attendance__c attendance = attendanceList[0];
    //             String checkInDate = String.valueOf(attendance.CheckIn_Date__c).subString(0,10);
    //             if(attendance.SignInTime__c != null){
    //                 checkIn = checkInDate + ' ' + String.valueOf(attendance.SignInTime__c).subString(0,5);
    //             }

    //             if(attendance.SignOutTime__c != null){
    //                 checkOut = checkInDate + ' ' +String.valueOf(attendance.SignOutTime__c).subString(0,5);
    //             }

    //             // 查询签到信息
    //             // List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(attendance.Id, insepction.Report_Date__c, insepction.Store__c);
    //         }

    //         // 查询当前巡店员日报国家对应的大类信息
    //         List<Inspection_Product_Item__c> insepctionItem = getInspectionProductItem(insepction.Id);

    //         // String salesRegion = insepction.Store__r.Sales_Region__c;
    //         // 根据门店salesregion 查询所有检查项大类
    //         // List<Category_Relationship__c> checkType = [SELECT Id FROM Category_Relationship__c WHERE Sales_Region__c =: salesRegion];
    //         // 查询当前日报所有的检查项详情
    //         // List<CheckResult__c> checkResult = [SELECT Id,
    //         //                                            CheckItem__r.Item_Type__c,
    //         //                                            CheckItem__r.Question_Type__c,
    //         //                                            CheckItem__r.Description__c,
    //         //                                            Response__c,
    //         //                                            Inspection_Product_Item__c 
    //         //                                            FROM CheckResult__c 
    //         //                                            WHERE InspectorDailyReport__c =: insepction.Id];

    //         List<CheckResult__c> checkResultParent = getCheckResultParent(insepction.Id);
    //         List<CheckResult__c> checkResultChildren = getCheckResultChildren(insepction.Id);
    //         NewSamplingAndTicketProController.setCheckItemLanguage(checkResultParent);
    //         NewSamplingAndTicketProController.setCheckItemLanguage(checkResultChildren);

    //         // 根据巡店员日报一级大类分组
    //         Map<String,Map<String,List<CheckResult__c>>> groupCheckResult = new Map<String,Map<String,List<CheckResult__c>>>();
    //         for(CheckResult__c res : checkResultParent){
 
    //             Map<String,List<CheckResult__c>> groupCheckType = groupCheckResult.get(res.Inspection_Product_Item__c);

    //             if(groupCheckType != null && groupCheckType.size() > 0){

    //                 List<CheckResult__c> checkResultList = groupCheckType.get(res.CheckItem__r.Item_Type__c);
    //                 if(checkResultList == null || checkResultList.size() == 0){
    //                     checkResultList = new List<CheckResult__c>();
    //                 }

    //                 checkResultList.add(res);
    //                 groupCheckType.put(res.CheckItem__r.Item_Type__c, checkResultList);

    //             }else{
    //                 List<CheckResult__c> checkResultList = new List<CheckResult__c>();
    //                 checkResultList.add(res);

    //                 groupCheckType = new Map<String,List<CheckResult__c>>(); 
    //                 groupCheckType.put(res.CheckItem__r.Item_Type__c, checkResultList);

    //             }

    //             groupCheckResult.put(res.Inspection_Product_Item__c,groupCheckType);
    //         }

    //         // 根据parentId 分组
    //         Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

    //         if(checkResultChildren != null && checkResultChildren.size() > 0){
    //             for(CheckResult__c children : checkResultChildren){
    //                 List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

    //                 if(resultChildren == null){
    //                     resultChildren = new List<CheckResult__c>();
    //                 }
    //                 resultChildren.add(children);
    //                 groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
    //             }
    //         }

    //         outPut = new List<OutPut>();
    //         if(insepctionItem != null && insepctionItem.size() > 0){
    //             for(Inspection_Product_Item__c item : insepctionItem){
    //                 OutPut out = new OutPut();
    //                 out.type = item.Type__c;

    //                 Map<String,List<CheckResult__c>> itemType = groupCheckResult.get(item.Id);
    //                 if(itemType != null && itemType.size() > 0){
    //                     List<CheckResult> checkResultData = new List<CheckResult>();
    //                     for(String key : itemType.keySet()){
    //                         CheckResult itemData = new CheckResult();
    //                         itemData.itemType = key;
    //                         List<CheckResult__c> checkResult = itemType.get(key);
    //                         // itemData.checkResultList = i

    //                         List<CheckResultData> resultDataList = new List<CheckResultData>();
    //                         // 处理父子问题逻辑
    //                         for(CheckResult__c parent : checkResult){
    //                             CheckResultData parentData = new CheckResultData();
    //                             parentData.parent = parent;

    //                             // 存放拼接的h5标签
    //                             String childrenHtml = '';
    //                             if(groupParent != null && groupParent.size() > 0){
    //                                 childrenHtml += checkResultRecursionInit(parent,groupParent);
    //                             }
                                
    //                             System.debug('wwwwchildrenHtml' + childrenHtml);

    //                             parentData.childrenHtml = childrenHtml;

    //                             resultDataList.add(parentData);
    //                         }

    //                         itemData.checkResultList = resultDataList;
    //                         checkResultData.add(itemData);
    //                     }
    //                     out.data = checkResultData;
    //                 }

    //                 outPut.add(out);
    //             }
    //             System.debug('wwwwoutPut' + JSON.serialize(outPut));
    //         }
    //     }
    //  }

     // 处理展示的checkResult
    // public static String checkResultRecursionInit(CheckResult__c checkResultParent,       
    //                                         Map<String,List<CheckResult__c>> groupParent){

    //     List<CheckResult__c> resultGroupParent = groupParent.get(checkResultParent.CheckItem__c);
    //     String childrenHtml = '';

    //     if(resultGroupParent != null && resultGroupParent.size() > 0){

    //         // 根据Index分组 YYL 20250305
    //         Map<Decimal,List<CheckResult__c>> indexGroupParent = new Map<Decimal,List<CheckResult__c>>();
    //         for(CheckResult__c indexResult : resultGroupParent){
    //             List<CheckResult__c> indexResultItem = indexGroupParent.get(indexResult.Index__c);
    //             if(indexResultItem == null){
    //                 indexResultItem = new List<CheckResult__c>();
    //             }
    //             indexResultItem.add(indexResult);
    //             indexGroupParent.put(indexResult.Index__c,indexResultItem);
    //         }

    //         if(!indexGroupParent.isEmpty()){
    //             for(Decimal key : indexGroupParent.keySet()){
    //                 // 处理父级下关联问题
    //                 for(CheckResult__c parent : indexGroupParent.get(key)){
    //                     CheckResult__c checkResultChildren = new CheckResult__c();
    //                     childrenHtml += '<h3>Children</h3>';
    //                     childrenHtml += '<div class="outputPanelType">';
    //                     childrenHtml += '' + parent.CheckItem__r.Description__c + '';
    //                     childrenHtml += '</div>';
    //                     childrenHtml += '<div>';
    //                     childrenHtml += '<input type="text" value="' + parent.Response__c + '"/>';
    //                     childrenHtml += '</div>';
                        
    //                     childrenHtml += checkResultRecursionInit(checkResultChildren,groupParent);
    //                 }
    //             }
    //         }
    //     }

    //     return childrenHtml;
    // }

    /**
     * @description 获取签到信息
     * @param   AttendanceId    考勤id
     * @param   todayDate       当天日期
     * @param   storeId         门店id
     * @return  打卡列表
     */
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationBasedAttendanceId(String AttendanceId, Date todayDate, String storeId) {
        return [
                SELECT 
                    Id,
                    CheckIn_Date__c,
                    CheckIn_Time__c,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Shop_Center_Location__Latitude__s,
                    Shop__r.Shop_Center_Location__Longitude__s,
                    Remark__c, 
                    Distance__c,
                    Location__c,
                    Location__Latitude__s,
                    Location__Longitude__s,
                    CreatedBy.Name,
                    (SELECT Id, ContentDocument.LatestPublishedVersionId
                        FROM ContentDocumentLinks)
                FROM Promoter_Attendance_Information__c 
                WHERE 
                    Promoter_Attendance__c =: AttendanceId 
                AND Type__c = 'Check in'
                AND CheckIn_Date__c = : todayDate
                AND Shop__c = : storeId];
    }

    /**
     * @description 获取巡店员日报字表详情
     * @param   AttendanceId    考勤id
     * @return  打卡列表
     */
    public static List<Inspection_Product_Item__c> getInspectionProductItem(String recordId){
        return [SELECT Id,
                       Type__c,
                       Product_Lines__c,
                       Status__c,
                       Product_Line_Checked__c,
                       Patrol_Mode__c,Inspection_Report__r.Store__r.Sales_Region__c 
                       FROM Inspection_Product_Item__c 
                       WHERE Inspection_Report__c =: recordId];
    }

    // 查询全部大类父级的check Result信息
    public static List<CheckResult__c> getCheckResultAll(String recordId){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,  
                       Index__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: recordId
                       AND CheckItem__r.Active__c = true
                       AND CheckItem__r.Item_Type__c != 'Sampling Product Check'
                ];
    }

    // 根据出样信息查询对应的check Result信息
    public static List<CheckResult__c> getSamCheckResult(List<String> samIds){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Sampling_Inspection__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Sampling_Inspection__c IN: samIds
                       AND CheckItem__r.Active__c = true
                ];
    }

    // 查询当前大类父级的check Result信息
    public static List<CheckResult__c> getCheckResultParent(String recordId){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: recordId
                       AND CheckItem__r.Parent__c = NULL
                       AND CheckItem__r.Active__c = true
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类子级的check Result信息
    public static List<CheckResult__c> getCheckResultChildren(String recordId){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: recordId
                       AND CheckItem__r.Parent__c != NULL
                       AND CheckItem__r.Active__c = true
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询出样计划信息
    public static List<Sampling_Inspection__c> getSamplingInspectionItem(List<String> recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    Display_Type__c,
                    Display_Status__c,
                    On_Wall_Display__c,
                    POP__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Img_Status__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c,
                    Inspection_Product_Item__c
                FROM Sampling_Inspection__c 
                WHERE Inspection_Product_Item__c IN: recordId
                ORDER BY Product__r.Product_Line__c DESC];
    }

    public static List<Sampling_Inspection__c> getSamplingInspection(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    Display_Type__c,
                    Display_Status__c,
                    On_Wall_Display__c,
                    POP__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Img_Status__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c,
                    Inspection_Report__c
                FROM Sampling_Inspection__c 
                WHERE Inspection_Report__c =: recordId
                ORDER BY Product__r.Product_Line__c DESC];
    }

    public class OutPut{
        public String type{get;set;}
        public List<checkResult> data{get;set;}
        public List<SamplingInspectionData> dataSam{get;set;}
    }

    public class CheckResult{
        public String itemType{get;set;}
        // 四期数据
        public List<CheckResult__c> checkResultList{get;set;}
        // 三期数据
        public List<CheckResult__c> checkResultListT{get;set;}
    }

    public class SamplingInspectionData{
        public String productLine{get;set;}
        public List<SamplingCheckResult> samplingCheckResult{get;set;}
    }

    public class SamplingCheckResult{
        public Sampling_Inspection__c samplingInspection{get;set;}
        public List<CheckResult__c> checkResultList{get;set;}
    }

    // public class OutPut{
    //     public String type{get;set;}
    //     public List<checkResult> data{get;set;}
    // }

    // public class CheckResult{
    //     public String itemType{get;set;}
    //     public List<CheckResultData> checkResultList{get;set;}
    // }

    public class CheckResultData{
        public CheckResult__c parent{get;set;}

        // 拼接子问题循环h5页面
        public String childrenHtml{get;set;}
    }
}