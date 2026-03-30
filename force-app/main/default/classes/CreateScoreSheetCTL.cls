public without sharing class CreateScoreSheetCTL {
    public Class InitDataWarp{
        public List<Customer_Product_Line__c> plList;
    }

    public class initSC{
        public String recordType;
        public String status;

        //Oversea Company
        public String rank;
        public String customerCredit;
        public String paymentOverdueTimes;
        public String growthPotential;//
        public String salesForecastExecution;//
        public String customerRelationship;
        
        //OME
        public String salesVolumeOEM;
        public String customerCreditOME;
        public String growthPotentialOEM;
        public String salesforecastExecutionOEM;
        public String customerRelationshipOEM;
        public String cooperateWithPLOEM;

        //Agency 老客戶
        public String customerCreditAgency;
    }
    //Last modified by johnson 20190729
    public static Map<String,String> scoreSheetRdTypeMap = Utility.getRecordTypeMapBySobj('Score_Sheet__c');

    @AuraEnabled 
    public static String initData(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.plList = new List<Customer_Product_Line__c>();
        List<Customer_Product_Line__c> proLineList = new List<Customer_Product_Line__c>();
        proLineList = [select id,Product_Line_Name__c,Classification__c,Development_Stage__c,customer__r.Approval_Status__c  from Customer_Product_Line__c where Customer__c =: accId];

        initData.plList = proLineList;
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }

    @AuraEnabled 
    public static String getScoreInfo(String accId,String classification,String plIds){
        try{
            // Account acc = new Account();
            // acc = [select Customer_Sales_Scale__c,rank__c,Approval_Status__c,Payback_Overdue_Number__c from account where id =: accId];
            
            // //获取最新的信用数据
            // Credit_Limit_Application__c cla = new Credit_Limit_Application__c();
            // List<Credit_Limit_Application__c> clas = [select Credit_Rating__c,LastModifiedDate from Credit_Limit_Application__c where Customer__c =: accId order by LastModifiedDate desc];
            // if(clas.size() > 0)
            //     cla = clas[0];

            // //获取该客户的其他业务线
            // List<String> plidss = plIds.split(';');
            // List<Customer_Product_Line__c> cplsOLD= [select Rank__c from Customer_Product_Line__c where id not in :plidss and Customer__c =:accId and Rank__c <> '' order by Rank__c ];

            // List<Customer_Product_Line__c> cplsNEW= [select Prospective_Rank__c from Customer_Product_Line__c where id not in :plidss and Customer__c =:accId and Prospective_Rank__c <> '' order by Prospective_Rank__c ];

            // //获取拜访记录
            // Map<Object,integer> visitRoleMap = new Map<Object,integer>();
            // AggregateResult[] groupedResults = [select Hisense_Participant_Position__c,count(id)  from Visit_Participant__c where Visit_Date__c = LAST_YEAR  and Hisense_Participant_Position__c  <>'' and Customer_Visit__r.Customer__c =:accId group by Hisense_Participant_Position__c ];
            // System.debug(groupedResults);
            // if(groupedResults.size()>0){
            //     for(AggregateResult ar : groupedResults){
            //         visitRoleMap.put(ar.get('Hisense_Participant_Position__c'),(integer)ar.get('expr0'));
            //     }   	
            // }

            // String accStatus = acc.Approval_Status__c;//新老客户通过客户状态判断
            // initSC initSC = new initSC();
                
            // //初始化记录类型
            // if('Approved' == accStatus){
            //     //老客户
            //     initSC.status = 'Draft';
            //     if('Agency Customer' == Classification || 'Agency + OEM Customer'==Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Sales_Department_new_Agency_Score');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Sales Department (Agency) Score').getRecordTypeId();
            //         // 从RR系统取得最近评级	Customer Credit
            //         Schema.DescribeFieldResult fieldResult = Score_Sheet__c.Customer_Credit_Agency__c.getDescribe();
            //         initSC.customerCreditAgency = convertCustomerCredit(cla.Credit_Rating__c,fieldResult);
            //     }
            //     if('OEM Customer' == Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Sales_Department_OEM_Score');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Sales Department (OEM) Score').getRecordTypeId();
            //         // 銷售規模
            //         Schema.DescribeFieldResult fieldResultSV = Score_Sheet__c.Sales_Volume__c.getDescribe();
            //         initSC.salesVolumeOEM = convertSalesVolume(acc.Customer_Sales_Scale__c,fieldResultSV);
            //         //信用
            //         Schema.DescribeFieldResult fieldResult = Score_Sheet__c.Customer_Credit_OEM__c.getDescribe();
            //         initSC.customerCreditOME = convertCustomerCredit(cla.Credit_Rating__c,fieldResult);
            //         //TODO "新客户手动填写；老客户自动填写：老客户按照收入增长比例判断  (今年收入-去年收入）/去年收入"	Growth Potential(OEM)
            //         initSC.growthPotentialOEM =  '5';
            //         //TODO "新客户手动填写；老客户自动填写：根据月度执行率相加后平均"	Sales Forecast and Execution(OEM)
            //         initSC.salesforecastExecutionOEM = '5';
            //         // 根据登记的拜访记录自动填写，总数满足要求就可以：即以季度为例，一年有四次即可	Customer Relationship
            //         Schema.DescribeFieldResult fieldResultCR = Score_Sheet__c.Customer_Relationship_OEM__c.getDescribe();
            //         initSC.customerRelationshipOEM = convertRelation(visitRoleMap,fieldResultCR);
            //         // 根据客户的产品线信息自动带出
            //         if(cplsOLD.size() > 0){
            //             Schema.DescribeFieldResult fieldResultCP = Score_Sheet__c.Cooperate_with_other_product_lines_OEM__c.getDescribe();
            //             initSC.cooperateWithPLOEM = convertCooperateWithPLOEM(cplsOLD[0].Rank__c,fieldResultCP);
            //         }else{
            //             initSC.cooperateWithPLOEM = '0';
            //         }
            //     }
            //     if('Customer of Oversea Company' == Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Oversea_Company_Score');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Oversea Company Score').getRecordTypeId();
            //         // 根据销售在客户主数据维护信息自动评分，不可修改	Industry Ranking
            //         Schema.DescribeFieldResult fieldResultIR = Score_Sheet__c.Industry_Ranking__c.getDescribe();
            //         initSC.rank = convertIndustryRanking(acc.rank__c,fieldResultIR);
            //         // 从RR系统取得最近评级	Customer Credit
            //         Schema.DescribeFieldResult fieldResult = Score_Sheet__c.Customer_Credit__c.getDescribe();
            //         initSC.customerCredit = convertCustomerCredit(cla.Credit_Rating__c,fieldResult);
            //         // 根据财务在客户主数据维护信息自动评分，不可修改	Payment Collection Overdue Times
            //         Schema.DescribeFieldResult fieldResultPCO = Score_Sheet__c.Payment_Collection_Overdue_Times__c.getDescribe();
            //         initSC.paymentOverdueTimes = convertPaymentCollectionOverdueTimes(acc.Payback_Overdue_Number__c,fieldResultPCO);
            //         //TODO "新客户手动填写；老客户自动填写：老客户按照收入增长比例判断  (今年收入-去年收入）/去年收入"	Growth Potential(OEM)
            //         initSC.growthPotential =  '5';
            //         //TODO "新客户手动填写；老客户自动填写：根据月度执行率相加后平均"	Sales Forecast and Execution(OEM)
            //         //月度预测与实际报表 的 已开票收入/实际收入
            //         initSC.salesForecastExecution = '5';
            //         // 根据登记的拜访记录自动填写，总数满足要求就可以：即以季度为例，一年有四次即可	Customer Relationship
            //         Schema.DescribeFieldResult fieldResultCR = Score_Sheet__c.Customer_Relationship__c.getDescribe();
            //         initSC.customerRelationship = convertRelation(visitRoleMap,fieldResultCR);
            //     }
            // }else{
            //     //新客户
            //     initSC.status = 'initialize';
            //     if('Agency Customer' == Classification || 'Agency + OEM Customer'==Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Sales_Department_new_Agency_Score');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Sales Department (new Agency) Score').getRecordTypeId();
            //         //全部手動填寫
            //     }
            //     if('OEM Customer' == Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Sales_Department_new_OEM_Score');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Sales Department (new OEM) Score').getRecordTypeId();
            //         // 銷售規模
            //         Schema.DescribeFieldResult fieldResultSV = Score_Sheet__c.Sales_Volume__c.getDescribe();
            //         initSC.salesVolumeOEM = convertSalesVolume(acc.Customer_Sales_Scale__c,fieldResultSV);
            //         //信用
            //         Schema.DescribeFieldResult fieldResult = Score_Sheet__c.Customer_Credit_OEM__c.getDescribe();
            //         initSC.customerCreditOME = convertCustomerCredit(cla.Credit_Rating__c,fieldResult);
            //         // 根据登记的拜访记录自动填写，总数满足要求就可以：即以季度为例，一年有四次即可	Customer Relationship
            //         Schema.DescribeFieldResult fieldResultCR = Score_Sheet__c.Customer_Relationship_OEM__c.getDescribe();
            //         initSC.customerRelationshipOEM = convertRelation(visitRoleMap,fieldResultCR);
            //         // 根据客户的产品线信息自动带出
            //         if(cplsNEW.size() > 0){
            //             Schema.DescribeFieldResult fieldResultCP = Score_Sheet__c.Cooperate_with_other_product_lines_OEM__c.getDescribe();
            //             initSC.cooperateWithPLOEM = convertCooperateWithPLOEM(cplsNEW[0].Prospective_Rank__c,fieldResultCP);
            //         }else{
            //             initSC.cooperateWithPLOEM = '0';
            //         }
            //     }
            //     if('Customer of Oversea Company' == Classification){
            //         initSC.recordType = scoreSheetRdTypeMap.get('Oversea_Company_Score_New');//Schema.SObjectType.Score_Sheet__c.getRecordTypeInfosByName().get('Oversea Company Score(New)').getRecordTypeId();
            //         // 根据销售在客户主数据维护信息自动评分，不可修改	Industry Ranking
            //         Schema.DescribeFieldResult fieldResultIR = Score_Sheet__c.Industry_Ranking__c.getDescribe();
            //         initSC.rank = convertIndustryRanking(acc.rank__c,fieldResultIR);
            //         // 从RR系统取得最近评级	Customer Credit
            //         Schema.DescribeFieldResult fieldResult = Score_Sheet__c.Customer_Credit__c.getDescribe();
            //         initSC.customerCredit = convertCustomerCredit(cla.Credit_Rating__c,fieldResult);
            //         // 根据财务在客户主数据维护信息自动评分，不可修改	Payment Collection Overdue Times
            //         Schema.DescribeFieldResult fieldResultPCO = Score_Sheet__c.Payment_Collection_Overdue_Times__c.getDescribe();
            //         initSC.paymentOverdueTimes = convertPaymentCollectionOverdueTimes(acc.Payback_Overdue_Number__c,fieldResultPCO);
            //         // 1)好（总经理年度一次，总监层月度一次）2)一般（总监层季度一次）3)差（总监层半年或年度一次）根据登记的拜访记录自动填写，总数满足要求就可以：即以季度为例，一年有四次即可	Customer Relationship
            //         Schema.DescribeFieldResult fieldResultCR = Score_Sheet__c.Customer_Relationship__c.getDescribe();
            //         initSC.customerRelationship = convertRelation(visitRoleMap,fieldResultCR);
            //     }
            // }
            // System.debug(initSC);


            // 新打分表逻辑
            initSC initSC = new initSC();
            if('Agency Customer' == Classification){
                initSC.recordType = scoreSheetRdTypeMap.get('New_Brand_Customer_selection_and_evaluation_criteria');
            }else if('OEM Customer' == Classification){
                initSC.recordType = scoreSheetRdTypeMap.get('New_OEM_Customer_selection_and_evaluation_criteria');
            }else if('Customer of Oversea Company' == Classification){
                initSC.recordType = scoreSheetRdTypeMap.get('Customer_selection_and_evaluation_criteria');
            }
            return JSON.serialize(initSC);

        }catch(Exception e){
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            return e.getMessage() + '  Line:' +e.getLineNumber();
        }
        
    }

    // private Static String convertRelation(Map<Object,integer> visitsRoleMap,Schema.DescribeFieldResult fieldResult){
    //     String result = '0';

    //     integer countGM = visitsRoleMap.get('General Manager');
    //     integer countDIR = visitsRoleMap.get('Sales Director');

    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}

    //     if(countGM>=1 || countDIR>=12){
    //         // result = pickListValuesMap.get('Good (Management level annual meeting & director level monthly meeting)');
    //         result = '5';
    //     }

    //     if(countDIR>=4){
    //         // result = pickListValuesMap.get('Average (No meeting with management level &director level quarterly meeting)');
    //         result = '3';
    //     }
    //     return result;
    // }

    // private Static String convertCooperateWithPLOEM(String rank,Schema.DescribeFieldResult fieldResult){
    //     String cooperateWithPLOEM;
    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}
    //     if(rank == 'Strategy Customer'){
    //         cooperateWithPLOEM = pickListValuesMap.get('1)Existing strategy customer of other product line');
    //     }else if(rank == 'Quality Customer'){
    //         cooperateWithPLOEM = pickListValuesMap.get('2)Existing quality customer of other product line');
    //     }else if(rank == 'Normal Customer'){
    //         cooperateWithPLOEM = pickListValuesMap.get('3)Existing normal customer of other product line');
    //     }else{
    //         cooperateWithPLOEM = pickListValuesMap.get('4)First cooperation');
    //     }
    //     return cooperateWithPLOEM;
    // }

    // private static String convertIndustryRanking(String accRank,Schema.DescribeFieldResult fieldResult){
    //     String rank;
    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}
    //     if(String.isBlank(accRank)){
    //         return pickListValuesMap.get('No limit');
    //     }
    //     System.debug('accRank:' +accRank);
    //     Integer accRanking = accRank.contains('>')? 0 : Integer.valueOf(accRank);
    //     if(accRank == '>20'){
    //         rank = pickListValuesMap.get('No limit');
    //     }else if(accRanking<=5){
    //         rank = pickListValuesMap.get('Top 5 (Operator/Professional Channel Top 3)');
    //     }else if(5 < accRanking && accRanking <=10){
    //         rank = pickListValuesMap.get('Top 10 (Operator/Professional channel Top 5)');
    //     }else if(10 < accRanking && accRanking <=20){
    //         rank = pickListValuesMap.get('Top 20 (Operators/Professional channel after the Top 5)');
    //     }
    //     return rank;
    // }

    // private static String convertPaymentCollectionOverdueTimes(Decimal overdueTimes,Schema.DescribeFieldResult fieldResult){
    //     String result;
    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}
    //     if(overdueTimes==0){
    //         result = pickListValuesMap.get('1)0');
    //     }else if(overdueTimes==1){
    //         result = pickListValuesMap.get('2)1');
    //     }else if(overdueTimes==2){
    //         result = pickListValuesMap.get('3)2');
    //     }else if(overdueTimes>=3){
    //         result = pickListValuesMap.get('4)>= 3');
    //     }
    //     return result;
    // }

    // private static String convertSalesVolume(Decimal salesVolume,Schema.DescribeFieldResult fieldResult){
    //     String result;
    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}
    //     if(salesVolume>=10000000){
    //         result = pickListValuesMap.get('10 million US dollars and above');
    //     }else if(salesVolume>=5000000){
    //         result = pickListValuesMap.get('500 (inclusive) - 10 million US dollars');
    //     }else if(salesVolume>=2000000){
    //         result = pickListValuesMap.get('200 (inclusive) - $5 million');
    //     }else {
    //         result = pickListValuesMap.get('Less than 2 million US dollars');
    //     }
    //     return result;
    // }

    // private static String convertCustomerCredit(String accCredit,Schema.DescribeFieldResult fieldResult){
    //     String credit;
        
    //     Map<String,String> pickListValuesMap= new Map<String,String>();
	// 	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	// 	for( Schema.PicklistEntry pickListVal : ple){
	// 		pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
	// 	}
    //     if(accCredit == 'D' || accCredit == 'E'){
    //         credit = pickListValuesMap.get('D');
    //     }else if(accCredit == 'C'){
    //         credit = pickListValuesMap.get('C');
    //     }else if(accCredit == 'B'){
    //         credit = pickListValuesMap.get('B');
    //     }else if(accCredit == 'A'){
    //         credit = pickListValuesMap.get('A');
    //     }
    //     return credit;
    // }
}