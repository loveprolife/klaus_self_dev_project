/**********************************************************************
* 名称: CreateNewMonthPlanController
* 功能: 
* 巡店计划控制类
* Author: Gerry
* Create Date: 2021-12-14
*************************************************************************/
public without sharing class CreateNewMonthPlanController {
	private static String INSPECTION_PROFILE = '巡店员';
	private static String MANAGER_PROFILE = '零售经理';
	@AuraEnabled
    public static OutPut getData(String planId) {
    	try {
    		if (String.isBlank(planId)) {
    			String year = String.valueOf(System.today().year());
    			String month = String.valueOf(System.today().month());
    			return haveRepeatingData(year, month,System.UserInfo.getUserId());	
    		}else{
    			OutPut out = builtOut(planId);	
    			return out; 
    		}
    			
    	}
    	catch (Exception e) {
    		OutPut out = new OutPut();
    		out.MonthPlans = null;
    		out.ShopPlanData = null;
    		out.isSucess = false;
    		out.errorMsg = System.Label.Error +e.getLineNumber()+e.getMessage();
    		return out; 
    	}
    	
    	
    }

    @AuraEnabled
    public static OutPut haveRepeatingData(String year, String month,String ownerId) {
    	try {
    		List<Inspection_Shop_Plan__c> shopPlanList = [
    													SELECT 
    														Id,
    														Name,
    														Inspection_Year__c,
    														Inspection_Month__c 
    													FROM 
    														Inspection_Shop_Plan__c 
    													WHERE 
    														Inspection_Year__c =:year 
    														AND Inspection_Month__c =:month
    														AND OwnerId__c =: ownerId];
											
	    	//如果有重复数据
	    	if (shopPlanList.size() > 0) {
				return builtOut(shopPlanList[0].Id);
	    	}else{//如果没有重复数据
	    		Integer yearNow = System.today().year();
	    		Integer mothonNow = System.today().month();
	    		if ((Integer.valueOf(year) < yearNow) || (Integer.valueOf(year) == yearNow &&(mothonNow>Integer.valueOf(month)))) {
	    			OutPut out = new Output();
		    		out.isSucess = true;
		    		out.errorMsg = System.Label.OnlyThisOrFutureMonth;
		    		out.showSaveButton = false;
		    		out.canCreate = false;
		    		return out;		
	    		}
	    		OutPut out = new OutPut();
	    		out.canCreate = true;
	    		Inspection_Shop_Plan__c shopPlan = new Inspection_Shop_Plan__c();
	    		shopPlan.Inspection_Year__c = year;
	    		shopPlan.Inspection_Month__c = month;
		    	out.ownerName = System.UserInfo.getName();
				out.ownerId = System.UserInfo.getUserId();
	    		out.ShopPlanData = shopPlan;
	    		out.showSaveButton = true;
	    		out.plannedQuantitySum = 0;
	    		out.actualQuantitySum = 0;
	    		out.nowDate = String.valueOf(System.today());

				//所有巡店员
				// List<User> walkerOptions = getAllFloorWalkers();
				// System.debug('walkerOptions: '+ walkerOptions);
				// out.floorwalkers = walkerOptions;
				//是否可选择巡店员
				out.canSelectFloorwalker = getSelectWalkersPermission();

	    		//week显示
		    	Map<Integer,String> weekMap = new Map<Integer,String>{
		    		1=>'月',
		    		2=>'火',
		    		3=>'水',
		    		4=>'木',
		    		5=>'金',
		    		6=>'土',
		    		7=>'日'
		    		
		    	};
	    		Integer monthInteger = Integer.valueOf(month);
		    	Integer yeaInteger = Integer.valueOf(year);
		    	Integer days = Date.daysInMonth(yeaInteger, monthInteger);//选择月份天数
	    		List<Responsible_Person__c> personList = getResponsPerson(System.UserInfo.getUserId());
		    	List<MonthPlan> monthPlanList = new List<MonthPlan>();
		    	Integer i = 1;

		    	//日期数据构建
		    	List<DayAndWeek> dayAndWeekDate = new List<DayAndWeek>();
		    	for (Integer j = 1; j <= days; j++) {
		    		DayAndWeek dayWeek = new DayAndWeek();
		    		dayWeek.label = String.valueOf(j);
	    			dayWeek.value = String.valueOf(j);
	    			Integer week = Integer.valueOf(Datetime.newInstance(yeaInteger, monthInteger, j).format('u'));
	    			dayWeek.week = weekMap.get(week);
	    			dayAndWeekDate.add(dayWeek);
	    			if (week == 6 || week == 7) {
	    				dayWeek.isWeekend = true;	
	    			}else{
	    				dayWeek.isWeekend = false;
	    			}
		    	}
		    	out.dayAndWeekDate = dayAndWeekDate;

		    	//门店+巡店任务数据构建
		    	for (Responsible_Person__c person : personList) {
		    		MonthPlan monthPlan = new MonthPlan();
		    		monthPlan.shopId = person.Shop_Name__c;
		    		monthPlan.planNum = String.valueOf(i);	
		    		monthPlan.shopOwner = person.Shop_Name__r.Account__r.Name;
		    		monthPlan.shopName = person.Shop_Name__r.Name;
		    		monthPlan.shopLevel = person.Shop_Name__r.Shop_Level__c;
		    		monthPlan.plannedQuantity = 0;
		    		monthPlan.actualQuantity = 0;
		    		List<DayOption> dayOptionList = new List<DayOption>();
		    		for (Integer j = 1; j <= days; j++) {
		    			DayOption dateOption = new DayOption();
		    			dateOption.index = String.valueOf(j);
	    				dateOption.status1 = '';
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+person.Shop_Name__c+':'+i;
	    				if (out.dayAndWeekDate[j-1].isWeekend) {
	    					dateOption.isWeekend = true;	
	    				}else{
	    					dateOption.isWeekend = false;
	    				}
		    			dayOptionList.add(dateOption);	
		    		}
		    		monthPlan.dayOptions = dayOptionList;
		    		monthPlanList.add(monthPlan);
		    		i++;
		    	}
		    	out.taskMap = new Map<String,Inspection_Shop_Task__c>();
		    	out.MonthPlans = monthPlanList;
		    	out.isSucess = true;
		    	out.errorMsg = '';
		    	return out;
	    	}    
    	}
    	catch (Exception e) {
    		OutPut out = new OutPut();
    		out.MonthPlans = null;
    		out.ShopPlanData = null;
    		out.isSucess = false;
    		out.errorMsg = System.Label.Error  +e.getLineNumber()+e.getMessage();
    		return out;    
    	}
    } 
	
	@AuraEnabled
    public static Output saveData(Inspection_Shop_Plan__c shopPlan, String taskMapDataJSON, String planId, Boolean jump, String year, String month, String ownerId) {
    	Savepoint sp;
    	try {
    		sp = Database.setSavepoint();
    		if (String.isBlank(planId)) {//新建
    			String jumpYear;
    			String jumpMonth;
    			if (jump) {
    				jumpYear = shopPlan.Inspection_Year__c;
    				jumpMonth = shopPlan.Inspection_Month__c;
    				shopPlan.Inspection_Year__c = year;	
    				shopPlan.Inspection_Month__c = month;		
    			}
	    		// Inspection_Shop_Plan__c shopPlan = (Inspection_Shop_Plan__c)JSON.deserialize(inspectionShopPlanJson, Inspection_Shop_Plan__c.class);
	    		Database.insert(shopPlan);
	    		Map<String,Inspection_Shop_Task__c> taskMapData = (Map<String,Inspection_Shop_Task__c>)JSON.deserialize(taskMapDataJSON, Map<String,Inspection_Shop_Task__c>.class);
	    		
	    		//需要插入的Task
	    		List<Inspection_Shop_Task__c> shopTaskList = new List<Inspection_Shop_Task__c>();
	    		for (String key : taskMapData.keySet()) {
	    			taskMapData.get(key).Inspection_Plan__c = shopPlan.Id;
	    			shopTaskList.add(taskMapData.get(key));			
	    		}
	    		Database.upsert(shopTaskList);	
	    		if (jump) {
	    			return haveRepeatingData(jumpYear, jumpMonth,ownerId);	
	    		}else{
	    			OutPut out = builtOut(shopPlan.Id);	
	    			return out;
	    		}
	    	}else{//编辑
	    		String jumpYear;
    			String jumpMonth;
    			if (jump) {
    				jumpYear = shopPlan.Inspection_Year__c;
    				jumpMonth = shopPlan.Inspection_Month__c;		
    			}
	    		Map<String,Inspection_Shop_Task__c> taskMapData = (Map<String,Inspection_Shop_Task__c>)JSON.deserialize(taskMapDataJSON, Map<String,Inspection_Shop_Task__c>.class);
	    		System.debug('taskMapData'+taskMapData);
	    		//需要插入的Task
	    		List<Inspection_Shop_Task__c> shopTaskList = new List<Inspection_Shop_Task__c>();

	    		//需要删除的task
	    		List<Inspection_Shop_Task__c> shopTaskDeleteTaskList = new List<Inspection_Shop_Task__c>();
	    		for (String key : taskMapData.keySet()) {
	    			if (key.contains('DELETE')) {
	    				shopTaskDeleteTaskList.add(taskMapData.get(key));	
	    			}

	    			if (key.contains('NEW')) {
	    				shopTaskList.add(taskMapData.get(key));	
	    			}		
	    		}

	    		Database.delete(shopTaskDeleteTaskList);
	    		System.debug('shopTaskList'+shopTaskList);
	    		System.debug('shopTaskList'+shopTaskList.size());
	    		Database.upsert(shopTaskList);
	    		if (jump) {
	    			return haveRepeatingData(jumpYear, jumpMonth,ownerId);		
	    		}else{
	    			OutPut out = builtOut(planId);	
    				return out; 	
	    		}
	    	} 
    	}
    	catch (Exception e) {
    		Database.rollback(sp);
    		OutPut out = new OutPut();
    		out.MonthPlans = null;
    		out.ShopPlanData = null;
    		out.isSucess = false;
    		out.errorMsg = System.Label.Error+e.getLineNumber()+e.getMessage();
    		System.debug(out.errorMsg);
    		return out;      
    	}
    }

    public static Output builtOut(String planId) {
    	OutPut out = new OutPut();
    	out.canCreate = true;
		out.nowDate = String.valueOf(System.today());
		//week显示
    	Map<Integer,String> weekMap = new Map<Integer,String>{
    		1=>'月',
    		2=>'火',
    		3=>'水',
    		4=>'木',
    		5=>'金',
    		6=>'土',
    		7=>'日'
    	};
		
    	System.debug('planId: '+ planId);
    	if (String.isNotBlank(planId)) {
			//所有巡店员
			// List<User> walkerOptions = getAllFloorWalkers();
			// System.debug('walkerOptions2: '+ walkerOptions);
			// out.floorwalkers = walkerOptions;
			//是否可选择巡店员
			out.canSelectFloorwalker = getSelectWalkersPermission();
			
    		out.showSaveButton = true;	
    		out.ShopPlanData = getPlan(planId);//巡店日报	
    		out.ownerName = out.ShopPlanData.Owner.Name;
			out.ownerId = out.ShopPlanData.Owner.Id;
    		Integer month = Integer.valueOf(out.ShopPlanData.Inspection_Month__c);
	    	Integer year = Integer.valueOf(out.ShopPlanData.Inspection_Year__c);
	    	Integer yearNow = System.today().year();
    		Integer mothonNow = System.today().month();
    		//日报所有人Id
    		if (out.ShopPlanData.OwnerId__c != System.UserInfo.getUserId()) {
    			out.showSaveButton = false;	
    		}
    		if ((Integer.valueOf(year) < yearNow) || (Integer.valueOf(year) == yearNow &&(mothonNow>Integer.valueOf(month)))) {
    			out.showSaveButton = false;	
    		}
	    	Integer days = Date.daysInMonth(year, month);//选择月份天数
    		List<Responsible_Person__c> personList = getResponsPerson(out.ShopPlanData.OwnerId__c);
	    	List<MonthPlan> monthPlanList = new List<MonthPlan>();
	    	Integer plannedQuantitySum = 0;
	    	Integer actualQuantitySum = 0;
	    	//门店+日期Map
	    	Map<String,Inspection_Shop_Task__c> shopTaskMap = new Map<String,Inspection_Shop_Task__c>();
	    	for (Inspection_Shop_Task__c shopTask : [
	        	SELECT 
	        		Id,
	        		Shop__c,
	        		Inspection_Date__c,
	        		Result__c,
	        		Inspection_Target__c,
	        		Inspection_Plan_Commnets__c,
	        		Remark__c,
	        		Inspection_Plan__c,
	        		Status__c,
	        		Daily_Inspection_Report__c
	        	FROM 
	        		Inspection_Shop_Task__c
	        	WHERE 
	        		Inspection_Plan__c =: planId
	    	]) {
	    		//去掉前置0
	    		String monthSting = String.valueOf(shopTask.Inspection_Date__c.month());
	    		// if (monthSting.indexOf('0')==0) {
	    		// 	System.debug('进入清0逻辑');
	    		// 	monthSting.replace('0', '');	
	    		// }

	    		String dayString = String.valueOf(shopTask.Inspection_Date__c.day());
	    		// if (dayString.indexOf('0')==0) {
	    		// 	dayString.replace('0', '');	
	    		// }
	    		String keystr = shopTask.Shop__c+''+
				    			shopTask.Inspection_Date__c.year()+
				    			'-'+monthSting+
				    			'-'+dayString+'NEW';
	    		shopTaskMap.put(keystr,shopTask);
	    		plannedQuantitySum++;	
	    		if ('已到访'.equals(shopTask.Status__c) || '计划外到访'.equals(shopTask.Status__c)) {
	    			actualQuantitySum++;	
	    		}
	    	}
	    	out.taskMap = shopTaskMap;
	    	out.plannedQuantitySum = plannedQuantitySum;
	    	out.actualQuantitySum = actualQuantitySum;
	    	Integer i = 1;

	    	//日期数据构建
	    	List<DayAndWeek> dayAndWeekDate = new List<DayAndWeek>();
	    	for (Integer j = 1; j <= days; j++) {
	    		DayAndWeek dayWeek = new DayAndWeek();
	    		dayWeek.label = String.valueOf(j);
    			dayWeek.value = String.valueOf(j);
    			Integer week = Integer.valueOf(Datetime.newInstance(year, month, j).format('u'));
    			dayWeek.week = weekMap.get(week);
    			if (week == 6 ||week == 7) {
    				dayWeek.isWeekend = true;	
    			}else{
    				dayWeek.isWeekend = false;	
    			}
    			dayAndWeekDate.add(dayWeek);
	    	}
	    	out.dayAndWeekDate = dayAndWeekDate;

	    	//门店+巡店任务数据构建
	    	for (Responsible_Person__c person : personList) {
	    		MonthPlan monthPlan = new MonthPlan();
	    		monthPlan.shopId = person.Shop_Name__c;
	    		monthPlan.planNum = String.valueOf(i);	
	    		monthPlan.shopOwner = person.Shop_Name__r.Account__r.Name;
	    		monthPlan.shopName = person.Shop_Name__r.Name;
	    		monthPlan.shopLevel = person.Shop_Name__r.Shop_Level__c;
	    		List<DayOption> dayOptionList = new List<DayOption>();
	    		Integer plannedQuantity = 0;
	    		Integer actualQuantity = 0;
	    		for (Integer j = 1; j <= days; j++) {
	    			DayOption dateOption = new DayOption();
	    			dateOption.index = String.valueOf(j);
	    			if (out.dayAndWeekDate[j-1].isWeekend) {
    					dateOption.isWeekend = true;	
    				}else{
    					dateOption.isWeekend = false;	
    				}
	    			Inspection_Shop_Task__c shopTaskOfDay = shopTaskMap.get(person.Shop_Name__c+''+year+'-'+month+'-'+j+'NEW');
	    			if (shopTaskOfDay != null) {
	    				plannedQuantity++;
	    				if ('已到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '●';	
	    					actualQuantity++;
	    				}
	    				if ('未到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '〇';	
	    				}
	    				if ('计划外到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '▲';
	    					actualQuantity++;	
	    				}
	    				// dateOption.task = shopTaskOfDay;
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+shopTaskOfDay.Id+':'+person.Shop_Name__c+':'+i;
	    			}else{
	    				dateOption.status1 = '';
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+person.Shop_Name__c+':'+i;
	    			}
	    			dayOptionList.add(dateOption);	
	    		}
	    		monthPlan.plannedQuantity = plannedQuantity;
		    	monthPlan.actualQuantity = actualQuantity;
	    		monthPlan.dayOptions = dayOptionList;
	    		monthPlanList.add(monthPlan);
	    		i++;
	    	}
	    	out.MonthPlans = monthPlanList;
    	}
    	// else{
    	// 	Inspection_Shop_Plan__c shopPlan = new Inspection_Shop_Plan__c();
    	// 	shopPlan.Inspection_Year__c = '';
    	// 	shopPlan.Inspection_Year__c = '';
    	// 	out.plannedQuantitySum = 0;
	    // 	out.actualQuantitySum = 0;
	    // 	out.ownerName = System.UserInfo.getName();
    	// 	out.ShopPlanData = shopPlan;
    	// 	out.taskMap = new Map<String,Inspection_Shop_Task__c>();
    	// }
    	out.isSucess = true;
    	out.errorMsg = '';
    	return out;  	
    }

    @AuraEnabled
    public static InspectionReport getReport(String taskId) {
    	InspectionReport inspectionReport = new InspectionReport();
    	try {
    		List<Inspection_Shop_Task__c> taskList = [SELECT 
    															Id,
    															ImageUrl__c,
    															Result__c,
    															Remark__c,
    															Shop__r.Name,
    															ProductCatalogConfirm__c,
                                                                StoreMaintain__c,
                                                                CorporateInformation__c,
                                                                StoreInformation__c,
                                                                CompetitiveInformation__c	
    														FROM 
    															Inspection_Shop_Task__c
    														WHERE 
    														 	Id = :taskId];
    		if (taskList.size()>0) {
    			Report re = new Report();
		    	re.ShopReport = taskList[0].Result__c;
		    	re.InspectionReport = taskList[0].Remark__c;
		    	re.InspectionPicture = taskList[0].ImageUrl__c;
		    	re.ShopName = taskList[0].Shop__r.Name;
		    	re.productCatalogConfirm = taskList[0].ProductCatalogConfirm__c;
		    	re.storeMaintain = taskList[0].StoreMaintain__c;
		    	re.corporateInformation = taskList[0].CorporateInformation__c;
		    	re.storeInformation = taskList[0].StoreInformation__c;
		    	re.competitiveInformation = taskList[0].CompetitiveInformation__c;
		    	inspectionReport.report = re;												 	

		    	//巡店出样检查
		    	inspectionReport.siList = new List<SamplingInspection>();
		    	Integer siIndex = 1;
		    	for (Sampling_Inspection__c si : [ SELECT 
		    												(SELECT Id,ReRe__c,Sample_Images__c FROM Sample_Images__r),Product__r.Series__c,Product__r.Name,ReRe__c,Sample_Images_Url__c,Placement_Status__c
		    											FROM 
		    												Sampling_Inspection__c
		    											WHERE 
		    												Inspection_Shop_Task__c =:taskList[0].Id
		    											]) {
		    		SamplingInspection siData = new SamplingInspection();
		    		if (si.Sample_Images__r.size()>0) {
                        siData.imageNum = si.Sample_Images__r.size();
                        siData.sampleImageList = new List<SampleImagesData>();
                        for (Integer iamgeIndex = 0 ; iamgeIndex<si.Sample_Images__r.size(); iamgeIndex++) {
                            SampleImagesData sid = new SampleImagesData();
                            sid.index = String.valueOf(iamgeIndex+1);
                            sid.sampleImages = si.Sample_Images__r[iamgeIndex];
                            siData.sampleImageList.add(sid);  
                        }
                    }else{
                        siData.imageNum = 0;
                        siData.sampleImageList = new List<SampleImagesData>();
                    }
		    		siData.Index = String.valueOf(siIndex);	
		    		siData.PlacementStatus = si.Placement_Status__c;
		    		// siData.SamplingStandardName = si.Sampling_Standard__r.Name;
					siData.ProductName = si.Product__r.Name;
					// siData.TagPrice = String.valueOf(si.Tag_Price__c);
					// siData.Point = String.valueOf(si.Point__c);
					siData.ReRe = si.ReRe__c;
					siData.series = si.Product__r.Series__c;
					// siData.SampleImages = si.Sample_Images_Url__c; 
			    	inspectionReport.siList.add(siData);
			    	siIndex++;
		    	}
	    	}
	    	inspectionReport.isSucess = true;
	    	inspectionReport.errorMsg = '';
	    	System.debug('inspectionReport'+inspectionReport);
	    	return inspectionReport;    
    	}
    	catch (Exception e) {
    		inspectionReport.isSucess = false;
	    	inspectionReport.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
	    	return inspectionReport;        
    	}
    }
    /**
     * @description 获取当前用户所负责的门店
     * @param planId 巡检计划Id
     */
    public static List<Responsible_Person__c> getResponsPerson(String ownerId) {

    	return [
    		SELECT 
    			Id,
    			Shop_Name__c,
    			Principal__c,
    			Shop_Name__r.Owner.Name,
    			Shop_Name__r.Name,
    			Shop_Name__r.Shop_Level__c,
    			Shop_Name__r.Account__r.Name
    		FROM 
    			Responsible_Person__c
    		WHERE 
    			Principal__c =: ownerId
				AND RecordType__c = '巡店员'
			ORDER BY Shop_Name__r.Account__r.name
    	];

    }

    /**
     * @description 获取巡检计划
     * @param planId 巡检计划Id
     */
    public static Inspection_Shop_Plan__c getPlan(String planId) {

    	return [
    		SELECT 
    			Id,
    			Name,
    			Inspection_Year__c,
    			Inspection_Month__c,
    			OwnerId__c,
    			Owner.Name
    		FROM 
    			Inspection_Shop_Plan__c
    		WHERE 
    			Id =: planId Limit 1
    	];	
    }

	/**
     * @description 获取所有巡店员
     */
	public static List<User> getAllFloorWalkers() {
		List<User> walkerOptions = new List<User>();
		//所有巡店员
		Id floorwalkerPID = [SELECT Id From Profile Where Name = :INSPECTION_PROFILE].Id;
		List<User> floorwalkerList = [
									SELECT 
										Id,
										Name
									FROM
										User
									WHERE
										ProfileId = :floorwalkerPID];
		System.debug('floorwalkerList: ' + Json.serialize(floorwalkerList));
		//所有巡店员
		if(floorwalkerList != null && floorwalkerList.size() > 0) {
			walkerOptions.addAll(floorwalkerList);
		}
		return walkerOptions;
	}

	/**
     * @description 判断是否需要选择巡店员
     */
	public static Boolean getSelectWalkersPermission() {
		//当前用户简档
		Profile currentUserPro = [SELECT Id,Name FROM Profile Where Id = :UserInfo.getProfileId()];
		System.debug('currentUserPro: '+ currentUserPro.Name);
		//当前用户是否零售经理
		if(currentUserPro.Name == MANAGER_PROFILE) {
			return true;
		} else {
			return false;
		}
	}

	@AuraEnabled
	public static List<FloorwalkerData> filterFloorwalker(String name) {
		List<FloorwalkerData> floorwalkerDatas = new List<FloorwalkerData>();
		//巡店员
		Id floorwalkerPID = [SELECT Id From Profile Where Name = :INSPECTION_PROFILE].Id;
		if(name.trim().length() > 0) {
			String condition = '%' + name.trim() + '%';
			List<User> floorwalkerList = [
										SELECT 
											Id,
											Name
										FROM
											User
										WHERE
											ProfileId = :floorwalkerPID
										AND 
											Name LIKE :condition];
			
			if(floorwalkerList != null && floorwalkerList.size() > 0) {
				for(User walker : floorwalkerList) {
					FloorwalkerData data = new FloorwalkerData();
					data.userName = walker.Name;
					data.userId = walker.Id;
					floorwalkerDatas.add(data);
				}
			}
		}
		
		return floorwalkerDatas;
	}

    public class InspectionReport {
    	@AuraEnabled
		public Boolean isSucess {get; set;}

		@AuraEnabled
		public String errorMsg {get; set;}

    	@AuraEnabled
    	public Report report {get; set;}

    	@AuraEnabled
    	public List<SamplingInspection> siList {get; set;}

    }

    public class SamplingInspection {
    	@AuraEnabled
    	public String Index {get; set;}

    	@AuraEnabled
    	public String series {get; set;}	

    	@AuraEnabled
    	public String PlacementStatus {get; set;}	

    	@AuraEnabled
    	public String SamplingStandardName {get; set;}	

    	@AuraEnabled
    	public String ProductName {get; set;}	

    	@AuraEnabled
        public Integer imageNum {get; set;}

    	// @AuraEnabled
    	// public String TagPrice {get; set;}

    	// @AuraEnabled
    	// public String Point {get; set;}	

    	@AuraEnabled
    	public String ReRe {get; set;}	

    	@AuraEnabled
        public List<SampleImagesData> sampleImageList {get; set;}
    }

    public class SampleImagesData {
        @AuraEnabled
        public Sample_Images__c sampleImages {get; set;}   

        @AuraEnabled
        public String index {get; set;} 
    }

    // public class ShopCompetitiveProduct {
    // 	@AuraEnabled
    // 	public String Index {get; set;}	
    	
    // 	@AuraEnabled
    // 	public String Brand {get; set;}	

    // 	@AuraEnabled
    // 	public String Size {get; set;}	

    // 	@AuraEnabled
    // 	public String ProductName {get; set;}	

    // 	@AuraEnabled
    // 	public String TagPrice {get; set;}	

    // 	@AuraEnabled
    // 	public String ActualPrice {get; set;}	

    // 	@AuraEnabled
    // 	public String WeekendFavorable {get; set;}	

    // 	@AuraEnabled
    // 	public String TradeInOffers {get; set;}	

    // 	@AuraEnabled
    // 	public String Point {get; set;}
    // }

    public class Report {
    	@AuraEnabled
    	public String corporateInformation {get; set;}

    	@AuraEnabled
    	public String storeInformation {get; set;}

    	@AuraEnabled
    	public String competitiveInformation {get; set;}

    	@AuraEnabled
    	public String productCatalogConfirm {get; set;}

    	@AuraEnabled
    	public String storeMaintain {get; set;}

    	@AuraEnabled
    	public String ShopName {get; set;}
    	
    	@AuraEnabled
    	public String ShopReport {get; set;}

    	@AuraEnabled
    	public String InspectionReport {get; set;}

    	@AuraEnabled
    	public String InspectionPicture {get; set;}

    	@AuraEnabled
    	public String InspectionStatus {get; set;}
    }
	
	public class OutPut {
		@AuraEnabled
		public Boolean canCreate {get; set;}

		@AuraEnabled
		public Boolean showSaveButton {get; set;}

		@AuraEnabled
		public Inspection_Shop_Plan__c ShopPlanData {get; set;}

		@AuraEnabled
		public List<MonthPlan> MonthPlans {get; set;}

		@AuraEnabled
		public Boolean isSucess {get; set;}

		@AuraEnabled
		public String ownerName {get; set;}

		@AuraEnabled
		public String errorMsg {get; set;}

		@AuraEnabled
		public List<DayAndWeek> dayAndWeekDate {get; set;}
		
		@AuraEnabled
		public String nowDate {get; set;}

		@AuraEnabled
		public String recordId {get; set;}

		@AuraEnabled
		public Boolean isDuplication {get; set;}

		@AuraEnabled
		public Map<String,Inspection_Shop_Task__c> taskMap {get; set;}

		@AuraEnabled
		public Integer plannedQuantitySum {get; set;}

		@AuraEnabled
		public Integer actualQuantitySum {get; set;}
		
		//巡店员
		// @AuraEnabled
		// public List<User> floorwalkers {get; set;}

		//巡店员是否可选
		@AuraEnabled
		public Boolean canSelectFloorwalker {get; set;}

		@AuraEnabled
		public String ownerId {get; set;}
	} 

	public class MonthPlan {
		@AuraEnabled
		public String planNum {get; set;}

		@AuraEnabled
		public String shopOwner {get; set;}

		@AuraEnabled
		public String shopName {get; set;}

		@AuraEnabled
		public String shopLevel {get; set;}

		@AuraEnabled
		public String shopId {get; set;}

		@AuraEnabled
		public List<DayOption> dayOptions {get; set;}

		@AuraEnabled
		public Integer plannedQuantity {get; set;}

		@AuraEnabled
		public Integer actualQuantity {get; set;} 
	}

	public class DayAndWeek {
		@AuraEnabled
		public String label {get; set;}
		
		@AuraEnabled
		public String value {get; set;}

		@AuraEnabled
		public String week {get; set;}	

		@AuraEnabled
		public Boolean isWeekend {get; set;}	
	}

	public Class DayOption {

		@AuraEnabled
		public Boolean isWeekend {get; set;}
		
		@AuraEnabled
		public String index {get; set;}	

		@AuraEnabled
		public String taskAndDate {get; set;}

		@AuraEnabled
		public String status1 {get; set;}

		// @AuraEnabled
		// public Inspection_Shop_Task__c task;
	}

	public class FloorwalkerData {
    	@AuraEnabled
		public String userName {get; set;}

		@AuraEnabled
		public String userId {get; set;}
    }

}