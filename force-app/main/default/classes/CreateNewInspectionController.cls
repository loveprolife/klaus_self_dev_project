/**********************************************************************
* Name: CreateNewInspectionController
* Object: Inspection_Shop_Plan__c
* Purpose: CreateNewInspection Controller
* Author: yong
* Create Date: 2023-06-21
*************************************************************************/
public without sharing class CreateNewInspectionController {
	// private static String INSPECTION_PROFILE = '巡店员';
	private static String MANAGER_PROFILE = '零售经理';

	//存放过滤客户条件值
	private static String CUSTOMER_OPTION_VALUE = '';
	//存放过滤区域条件值
	private static String GRID_OPTION_VALUE = '';
	//存放过滤渠道条件值
	private static String CHANNEL_OPTION_VALUE = '';
	//存放过滤城市条件值
	private static String CITY_OPTION_VALUE = '';
	//存放过滤门店等级条件值
	private static String STORE_LEVEL_OPTION_VALUE = '';
	//存放过滤门店名称条件值
	private static String STORE_NAME_OPTION_VALUE = '';

	public static Boolean showApproveAction(String recordId) {
		User u = new User(
			Id = UserInfo.getUserId(),
			ProfileId = UserInfo.getProfileId(),
			UserRoleId = UserInfo.getUserRoleId()
		);
		return showApproveAction(recordId, u);
	}

	public static Boolean showApproveAction(String recordId, User u) {
		System.debug('recordId=' + recordId);
		ProcessInstanceWorkitem item = (ProcessInstanceWorkitem)SObjectHelper.first([
			SELECT 
				Id, 
				ProcessInstanceId, 
				OriginalActorId, 
				OriginalActor.Name,
				OriginalActor.UserRoleId,
				ActorId, 
				Actor.Name,
				ElapsedTimeInDays, 
				ElapsedTimeInHours, 
				ElapsedTimeInMinutes, 
				IsDeleted, 
				CreatedDate, 
				CreatedById, 
				SystemModstamp 
			FROM ProcessInstanceWorkitem 
			where ProcessInstance.TargetObjectId = :recordId
		]);
		if (item == null || item.OriginalActor.UserRoleId == null) {
			System.debug('item == null || OriginalActor.UserRoleId == null');
			return false;
		}

		if (UserUtility.IsSystemAdministrator(u.ProfileId) || u.Id == item.OriginalActorId) {
			return true;
		}

		System.debug('OriginalActor.UserRoleId=' + item.OriginalActor.UserRoleId);
		return new Map<Id, UserRole>(UserUtility.getParentRoles(item.OriginalActor.UserRoleId)).keySet().contains(u.UserRoleId);
	}

 /**
  * @Param: 
  * @Return: 
  * @Author: WFC
  * @Date: 2025-07-18 10:55:20
  * @Description: 初始化巡店计划页面
  */	
	@AuraEnabled
    public static OutPut getData(String planId, String customerValue, String gridName, String city, String storeLevel, String storeName) {
    	try {

			CUSTOMER_OPTION_VALUE = customerValue;
			GRID_OPTION_VALUE = gridName;
			CITY_OPTION_VALUE = city;
			STORE_LEVEL_OPTION_VALUE = storeLevel;
			STORE_NAME_OPTION_VALUE = storeName;

    		if (String.isBlank(planId)) {
    			String year = String.valueOf(System.today().year());
    			String month = String.valueOf(System.today().month());
    			return haveRepeatingData(year, month, System.UserInfo.getUserId(),'','','','','','');	
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

	/**
	* @Param: 
	* @Return: 
	* @Author: WFC
	* @Date: 2025-07-18 09:30:22
	* @Description: 保存Inspection_Shop_Task__c
	*/	
	@AuraEnabled
    public static Map<String, Object> addPlanTask(String shopId, String inspectionDate, String inspectionPlanId, String ownerId) {
		Map<String, Object> resultMap = new Map<String, Object>();
		resultMap.put('isExceedTimelimit', false);
		Savepoint sp;
		try {
			Inspection_Shop_Task__c task = new Inspection_Shop_Task__c();
			task.Inspection_Plan__c = inspectionPlanId;
			task.Shop__c = shopId;
			task.Status__c = '未到访';
			task.Inspection_Date__c = Date.valueOf(inspectionDate);
			task.OwnerId = ownerId;
			Database.SaveResult result = Database.insert(task, false);
			if(!result.isSuccess()) {
                String error = '';
                for (Database.Error err : result.getErrors()) {
                    error += err.getMessage();
                }
                resultMap.put('isSuccess', false);
                resultMap.put('errorMsg', error);
				return resultMap;
            }

			// 计划监控
			// 查询字典表
			List<Dictionary__c> dictionaryList = Utility.getDictionaryByType('Inspection Plan');
			Map<String, Decimal> dictionaryMap = new Map<String, Decimal>();
			for(Dictionary__c dictionary : dictionaryList){
				dictionaryMap.put(dictionary.Sales_Region__c + dictionary.Store_Level__c, dictionary.Overdue__c);
			}
			// 当前任务触发flow后，查询 Last_Task_Date__c
			Inspection_Shop_Task__c currentTask = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c
													FROM Inspection_Shop_Task__c 
													WHERE Id = :task.Id
													LIMIT 1];
			// 查询上一次任务
			List<Inspection_Shop_Task__c> lastTaskList = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c
												FROM Inspection_Shop_Task__c 
												WHERE OwnerId =: ownerId
												AND Inspection_Date__c < :Date.valueOf(inspectionDate)
												AND Shop__c = :shopId
												ORDER BY Inspection_Date__c DESC
												LIMIT 1];
			// 查询下一次task任务，是否需要处理计划监控
			List<Inspection_Shop_Task__c> nextTaskList = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c
													FROM Inspection_Shop_Task__c 
													WHERE OwnerId = :ownerId
													AND Shop__c = :shopId
													AND Inspection_Date__c > :Date.valueOf(inspectionDate)
													ORDER BY Inspection_Date__c
													LIMIT 1];
			if(dictionaryMap.get(currentTask.Shop__r.Sales_Region_Lookup__c + currentTask.Shop__r.Shop_Level__c) != null){
				// 字典表配置的数据
				Decimal overdue = dictionaryMap.get(currentTask.Shop__r.Sales_Region_Lookup__c + currentTask.Shop__r.Shop_Level__c);
				// 如果存在上一次任务
				if(lastTaskList != null && lastTaskList.size() > 0){
					Inspection_Shop_Task__c lastTask = lastTaskList[0];
					// 与上一次任务时间间隔
					Integer interval = lastTask.Inspection_Date__c.daysBetween(currentTask.Inspection_Date__c);
					if(interval > overdue){
						// 需要提示
						resultMap.put('isExceedTimelimit', true);
					}
				}
				if(nextTaskList != null && nextTaskList.size() > 0){
					Inspection_Shop_Task__c nextTask = nextTaskList[0];
					Integer nextInterval = currentTask.Inspection_Date__c.daysBetween(nextTask.Inspection_Date__c);
					if(nextInterval > overdue){
						// 需要提示
						resultMap.put('isExceedTimelimitNext', true);
						resultMap.put('nextTaskId', nextTask.Id);
					}else {
						resultMap.put('isExceedTimelimitNext', false);
						resultMap.put('nextTaskId', nextTask.Id);
					}	
				}
			}
			GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'addPlanTask');
			// 如果存在上一次任务
			if(lastTaskList != null && lastTaskList.size() > 0){
				currentTask.Last_Task_Date__c = lastTaskList[0].Inspection_Date__c;
				update currentTask;
			}
			if(nextTaskList != null && nextTaskList.size() > 0){
				nextTaskList[0].Last_Task_Date__c = currentTask.Inspection_Date__c;
				update nextTaskList[0];
			}
			//恢复触发器
			Utility.IgnoreAction(false,false,false,'');
			resultMap.put('task', task);
			resultMap.put('isSuccess', true);
			return resultMap;
		}catch(Exception e) {
			Database.rollback(sp);
			resultMap.put('isSuccess', false);
			resultMap.put('errorMsg', e);
			Utility.IgnoreAction(false,false,false,'');
			return resultMap;
		}
    }
 /**
  * @Param: 
  * @Return: 
  * @Author: WFC
  * @Date: 2025-07-21 16:33:07
  * @Description: 删除task
  */	
	@AuraEnabled
    public static Map<String, Object> deleteRecord(String recordId){
		Map<String, Object> resultMap = new Map<String, Object>();
		Inspection_Shop_Task__c task = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c, OwnerId, Shop__c
										FROM Inspection_Shop_Task__c 
										WHERE Id = :recordId
										LIMIT 1];
		String ownerId = task.OwnerId;
		String shopId = task.Shop__c;
		Date inspectionDate = task.Inspection_Date__c;
		// 查询下一次task任务，是否需要处理计划监控
		List<Inspection_Shop_Task__c> nextTaskList = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c
														FROM Inspection_Shop_Task__c 
														WHERE OwnerId = :ownerId
														AND Shop__c = :shopId
														AND Inspection_Date__c > :inspectionDate
														AND Inspection_Date__c = THIS_MONTH
														ORDER BY Inspection_Date__c
														LIMIT 1];
		// 查询上一次task任务，是否需要处理计划监控
		List<Inspection_Shop_Task__c> lastTaskList = [SELECT Id, Last_Task_Date__c, Inspection_Date__c, Shop__r.Sales_Region_Lookup__c, Shop__r.Shop_Level__c
														FROM Inspection_Shop_Task__c 
														WHERE OwnerId = :ownerId
														AND Shop__c = :shopId
														AND Inspection_Date__c < :inspectionDate
														ORDER BY Inspection_Date__c DESC
														LIMIT 1];

		// 查询字典表
		List<Dictionary__c> dictionaryList = Utility.getDictionaryByType('Inspection Plan');
		Map<String, Decimal> dictionaryMap = new Map<String, Decimal>();
		for(Dictionary__c dictionary : dictionaryList){
			dictionaryMap.put(dictionary.Sales_Region__c + dictionary.Store_Level__c, dictionary.Overdue__c);
		}
		if(dictionaryMap.get(task.Shop__r.Sales_Region_Lookup__c + task.Shop__r.Shop_Level__c) != null){
			// 字典表配置的数据
			Decimal overdue = dictionaryMap.get(task.Shop__r.Sales_Region_Lookup__c + task.Shop__r.Shop_Level__c);
			// 如果有上一次任务
			if(lastTaskList != null && lastTaskList.size() > 0){
				Inspection_Shop_Task__c lastTask = lastTaskList[0];
				// 如果有下一次任务，则处理下一次任务 计划监控
				if(nextTaskList != null && nextTaskList.size() > 0){
					Inspection_Shop_Task__c nextTask = nextTaskList[0];
					Integer tempOverdue = lastTask.Inspection_Date__c.daysBetween(nextTask.Inspection_Date__c);
					if(tempOverdue > overdue){
						// 需要提示
						resultMap.put('isExceedTimelimitNext', true);
						resultMap.put('nextTaskId', nextTask.Id);
					}else {
						resultMap.put('isExceedTimelimitNext', false);
						resultMap.put('nextTaskId', nextTask.Id);
					}
				}
			}else {
				// 没有之前的任务，删除后下一次任务是首次任务
				if(nextTaskList != null && nextTaskList.size() > 0){
					Inspection_Shop_Task__c nextTask = nextTaskList[0];
					resultMap.put('isExceedTimelimitNext', false);
					resultMap.put('nextTaskId', nextTask.Id);
				}
			}
		}
		// 修改下一次任务的 Last_Task_Date__c
		if(nextTaskList != null && nextTaskList.size() > 0){
			Inspection_Shop_Task__c nextTask = nextTaskList[0];
			if(lastTaskList != null && lastTaskList.size() > 0){
				Inspection_Shop_Task__c lastTask = lastTaskList[0];
				nextTask.Last_Task_Date__c = lastTask.Inspection_Date__c;
			}else {
				nextTask.Last_Task_Date__c = null;
			}
			update nextTask;
		}

        Database.delete (recordId);
        return resultMap;
    }

	/**
	* @Param: 
	* @Return: 
	* @Author: WFC
	* @Date: 2025-07-18 10:30:30
	* @Description: 保存note
	*/	
	@AuraEnabled
    public static Boolean saveNote(Inspection_Shop_Task__c shopTask) {
		update shopTask;
		return true;
    }

	@AuraEnabled
    public static Inspection_Shop_Task__c getNoteByTaskId(String taskId) {
		return [SELECT Id, Note__c FROM Inspection_Shop_Task__c WHERE Id =:taskId];
    }

    @AuraEnabled
    public static OutPut haveRepeatingData(String year, String month,String ownerId,
											String customerValue,String gridName,
											String channelValue,String city, String storeLevel, String storeName) {
    	try {
    		List<Inspection_Shop_Plan__c> shopPlanList = [
    													SELECT 
    														Id,
    														Name,
    														Inspection_Year__c,
    														Inspection_Month__c ,
															Status__c,
															ownerId
    													FROM 
    														Inspection_Shop_Plan__c 
    													WHERE 
    														Inspection_Year__c =:year 
    														AND Inspection_Month__c =:month
    														AND OwnerId__c =: ownerId];
					
			CUSTOMER_OPTION_VALUE = customerValue;
			GRID_OPTION_VALUE = gridName;
			CHANNEL_OPTION_VALUE = channelValue;
			CITY_OPTION_VALUE = city;
			STORE_LEVEL_OPTION_VALUE = storeLevel;
			STORE_NAME_OPTION_VALUE = storeName;

	    	//如果有重复数据
	    	if (shopPlanList.size() > 0) {
				return builtOut(shopPlanList[0].Id);
	    	}else{//如果没有重复数据
	    		Integer yearNow = System.today().year();
	    		Integer mothonNow = System.today().month();
	    		// if ((Integer.valueOf(year) < yearNow) || (Integer.valueOf(year) == yearNow &&(mothonNow>Integer.valueOf(month)))) {
	    		// 	OutPut out = new Output();
		    	// 	out.isSucess = true;
		    	// 	out.errorMsg = System.Label.OnlyThisOrFutureMonth;
		    	// 	out.showSaveButton = false;
		    	// 	out.canCreate = false;
		    	// 	return out;		
	    		// }
	    		OutPut out = new OutPut();
	    		out.canCreate = true;
				out.isCurrentApprover = false;
	    		Inspection_Shop_Plan__c shopPlan = new Inspection_Shop_Plan__c();
	    		shopPlan.Inspection_Year__c = year;
	    		shopPlan.Inspection_Month__c = month;
				if(ownerId != null){
					List<User> uList = [SELECT Id,Name FROM User WHERE Id =: ownerId];
					if(uList.size()>0){
						out.ownerName = uList[0].Name;
						out.ownerId = ownerId;
						shopPlan.OwnerId = ownerId;
					}else{
						out.ownerName = System.UserInfo.getName();
						out.ownerId = System.UserInfo.getUserId();
						shopPlan.OwnerId = System.UserInfo.getUserId();
					}
				}else{
					out.ownerName = System.UserInfo.getName();
					out.ownerId = System.UserInfo.getUserId();
					shopPlan.OwnerId = System.UserInfo.getUserId();
				}
				insert shopPlan;
		    	
	    		out.ShopPlanData = shopPlan;
	    		out.showSaveButton = true;
	    		out.plannedQuantitySum = 0;
	    		out.actualQuantitySum = 0;
				out.visitedQuantitySum = 0;
				out.unVisitedQuantitySum = 0;
				out.unscheduledQuantitySum = 0;
	    		out.nowDate = String.valueOf(System.today());

				//所有巡店员
				out.currentUserRole = getCurrentUserRole(UserInfo.getUserId());
				List<String> userIdList = getRelatedUserId(out.currentUserRole);
				userIdList.add(out.ownerId);
				List<User> walkerOptions = getAllFloorWalkers(userIdList);
				if(out.ShopPlanData.Submiter__c == UserInfo.getUserId()){
					out.isSubmiter = true;
				}else{
					out.isSubmiter = false;
				}
				
				// System.debug('walkerOptions: '+ walkerOptions);
				out.floorwalkers = walkerOptions;
				//是否可选择巡店员
				out.canSelectFloorwalker = getSelectWalkersPermission();

	    		//week显示
		    	Map<Integer,String> weekMap = new Map<Integer,String>{
		    		1=>'Mon',
		    		2=>'Tue',
		    		3=>'Wed',
		    		4=>'Thu',
		    		5=>'Fri',
		    		6=>'Sat',
		    		7=>'Sun'
		    		
		    	};

				User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id =: out.ownerId];

				//新增返回SalesRegion字段 20241101 YYL
				out.salesRegion = user.sales_region__c;

				if('Japan' == user.Country__c || 'Hisense Japan' == user.sales_region__c){
					weekMap = new Map<Integer,String>{
						1=>'月',
						2=>'火',
						3=>'水',
						4=>'木',
						5=>'金',
						6=>'土',
						7=>'日'
					};
				}
	    		Integer monthInteger = Integer.valueOf(month);
		    	Integer yeaInteger = Integer.valueOf(year);
		    	Integer days = Date.daysInMonth(yeaInteger, monthInteger);//选择月份天数
				List<Responsible_Person__c> personList = new List<Responsible_Person__c>();
				if(ownerId != null){
					personList = getResponsPerson(ownerId);
				}else{
					personList = getResponsPerson(System.UserInfo.getUserId());
				}
	    		
		    	List<MonthPlan> monthPlanList = new List<MonthPlan>();
		    	List<MonthPlan> monthPlanBackupList = new List<MonthPlan>();//Add By Ethan 20231012
		    	String backupRecordType = 'Backup Floorwalker';//Add By Ethan 20231012
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

					//拦截非客户筛选值的数据
					if(CUSTOMER_OPTION_VALUE != null && !CUSTOMER_OPTION_VALUE.equals('')){
						if(!CUSTOMER_OPTION_VALUE.equals(person.Shop_Name__r.Account__r.Name)){
							continue;
						}
					}
					//拦截非区域筛选值的数据
					if(GRID_OPTION_VALUE != null && !GRID_OPTION_VALUE.equals('')){
						if(!GRID_OPTION_VALUE.equals(person.shop_Name__r.Grid__r.Name)){
							continue;
						}
					}

					//拦截非渠道筛选值的数据 20241101 YYL
					if(CHANNEL_OPTION_VALUE != null && !CHANNEL_OPTION_VALUE.equals('')){
						if(!CHANNEL_OPTION_VALUE.equals(person.shop_Name__r.Channel_Name__c)){
							continue;
						}
					}

					//拦截非城市筛选值的数据 20241101 YYL
					if(CITY_OPTION_VALUE != null && !CITY_OPTION_VALUE.equals('')){
						if(!CITY_OPTION_VALUE.equals(person.shop_Name__r.City__c)){
							continue;
						}
					}

					//拦截非门店等级筛选值的数据
					if(STORE_LEVEL_OPTION_VALUE != null && !STORE_LEVEL_OPTION_VALUE.equals('')){
						if(!STORE_LEVEL_OPTION_VALUE.equals(person.shop_Name__r.Shop_Level__c)){
							continue;
						}
					}

					//拦截非门店等级筛选值的数据
					if(STORE_NAME_OPTION_VALUE != null && !STORE_NAME_OPTION_VALUE.equals('')){
						// if(!STORE_NAME_OPTION_VALUE.equals(person.shop_Name__r.Name)){
						if(!person.shop_Name__r.Name.toLowerCase().contains(STORE_NAME_OPTION_VALUE.toLowerCase())){
							continue;
						}
					}

		    		MonthPlan monthPlan = new MonthPlan();
		    		monthPlan.shopId = person.Shop_Name__c;
		    		// monthPlan.planNum = String.valueOf(i);//20230112
		    		monthPlan.shopOwner = person.Shop_Name__r.Account__r.Name;
		    		monthPlan.shopName = person.Shop_Name__r.Name;
		    		monthPlan.shopLevel = person.Shop_Name__r.Shop_Level__c;
					monthPlan.shopGridding = person.Shop_Name__r.Grid__r.Name;
					monthPlan.shopChannel = person.Shop_Name__r.Channel_Name__c;
					monthPlan.shopCity = person.Shop_Name__r.City__c;
		    		monthPlan.plannedQuantity = 0;
		    		monthPlan.actualQuantity = 0;
					monthPlan.unscheduledQuantity = 0;
					//Modified By Ethan 20231013 S  20240417改为和Floorwalker一样
					//if (backupRecordType != person.RecordType__c) {
						monthPlan.isBackup = false;
						monthPlan.planNum = String.valueOf(i);
					    List<DayOption> dayOptionList = new List<DayOption>();
			    		for (Integer j = 1; j <= days; j++) {
			    			DayOption dateOption = new DayOption();
							Blob b = Crypto.GenerateAESKey(128);
                        	String h = EncodingUtil.ConvertTohex(b);
							dateOption.tempId = h;
			    			dateOption.index = String.valueOf(j);
		    				dateOption.status1 = '';
		    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+person.Shop_Name__c+':'+i;
							dateOption.taskId = '';
							dateOption.taskDate = Date.newInstance(Integer.valueOf(year) ,Integer.valueOf(month), j);
							dateOption.note = '';
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
					// }else{
					// 	monthPlan.isBackup = true;
					// 	monthPlanBackupList.add(monthPlan);
					// }
		    		
		    	}
		    	Integer k = monthPlanList.size()+1;
				if(Test.isRunningTest()){
					monthPlanBackupList = monthPlanList;
				}
		    	for (MonthPlan item: monthPlanBackupList) {
		    		item.planNum = String.valueOf(k);
		    		List<DayOption> dayOptionList = new List<DayOption>();
		    		for (Integer j = 1; j <= days; j++) {
		    			DayOption dateOption = new DayOption();
						Blob b = Crypto.GenerateAESKey(128);
						String h = EncodingUtil.ConvertTohex(b);
						dateOption.tempId = h;
		    			dateOption.index = String.valueOf(j);
	    				dateOption.status1 = '';
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+item.shopId+':'+k;
						dateOption.taskId = '';
						dateOption.taskDate = Date.newInstance(Integer.valueOf(year) ,Integer.valueOf(month), j);
						dateOption.note = '';
	    				if (out.dayAndWeekDate[j-1].isWeekend) {
	    					dateOption.isWeekend = true;	
	    				}else{
	    					dateOption.isWeekend = false;
	    				}
		    			dayOptionList.add(dateOption);	
		    		}
		    		item.dayOptions = dayOptionList;
					if(!Test.isRunningTest()){
						monthPlanList.add(item);
					}
	    			k++;
		    	}
		    	//Modified By Ethan 20231013 E


		    	out.taskMap = new Map<String,Inspection_Shop_Task__c>();
		    	out.MonthPlans = monthPlanList;
				
				out.approve1Label = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Approver1__c.getLabel();
				out.approve2Label = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Approver2__c.getLabel();
				out.statusLabel = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Status__c.getLabel();
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
    		out.errorMsg = System.Label.Error  + e.getLineNumber() + e.getMessage();
    		return out;    
    	}
    } 

 	/**
	* @Param: 
	* @Return: 
	* @Author: WFC
	* @Date: 2025-07-17 10:55:59
	* @Description: 保存巡店计划数据
	*/	
	@AuraEnabled
    public static Output saveData(Inspection_Shop_Plan__c shopPlan, String taskMapDataJSON, String planId, Boolean jump, String year, String month, String ownerId,String approver1,String approver2) {
		shopPlan.Approver1__c = approver1;
		shopPlan.Approver2__c = approver2;
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
				shopPlan.OwnerId = OwnerId;
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
	    			return haveRepeatingData(jumpYear, jumpMonth,ownerId,'','','','','','');	
	    		}else{
	    			OutPut out = builtOut(shopPlan.Id);	
	    			return out;
	    		}
	    	}else{//编辑
				update shopPlan;
	    		String jumpYear;
    			String jumpMonth;
    			if (jump) {
    				jumpYear = shopPlan.Inspection_Year__c;
    				jumpMonth = shopPlan.Inspection_Month__c;		
    			}
	    		Map<String,Inspection_Shop_Task__c> taskMapData = (Map<String,Inspection_Shop_Task__c>)JSON.deserialize(taskMapDataJSON, Map<String,Inspection_Shop_Task__c>.class);
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
	    		Database.upsert(shopTaskList);
	    		if (jump) {
	    			return haveRepeatingData(jumpYear, jumpMonth,ownerId,'','','','','','');		
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
    		return out;      
    	}
    }

    public static Output builtOut(String planId) {
    	OutPut out = new OutPut();
    	out.canCreate = true;
		out.nowDate = String.valueOf(System.today());
		out.isCurrentApprover = isCurrentApprover(planId);
		//week显示
    	Map<Integer,String> weekMap = new Map<Integer,String>{
    		1=>'Mon',
            2=>'Tue',
            3=>'Wed',
            4=>'Thu',
            5=>'Fri',
            6=>'Sat',
            7=>'Sun'
    	};
		Integer visitedQuantitySum = 0;
		Integer unVisitedQuantitySum = 0;
		Integer unscheduledQuantitySum = 0;
    	if (String.isNotBlank(planId)) {
			
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

			User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id =: out.ownerId];

			//新增返回SalesRegion字段 20241101 YYL
			out.salesRegion = user.sales_region__c;
			
			if('Japan' == user.Country__c || 'Hisense Japan' == user.sales_region__c){
				weekMap = new Map<Integer,String>{
					1=>'月',
					2=>'火',
					3=>'水',
					4=>'木',
					5=>'金',
					6=>'土',
					7=>'日'
				};
			}
			
			//所有巡店员
			out.currentUserRole = getCurrentUserRole(UserInfo.getUserId());
			List<String> userIdList = getRelatedUserId(out.currentUserRole);
			userIdList.add(out.ownerId);
			List<User> walkerOptions = getAllFloorWalkers(userIdList);
			// System.debug('walkerOptions2: '+ walkerOptions);
			out.floorwalkers = walkerOptions;
    		//日报所有人Id
    		// if (out.ShopPlanData.OwnerId__c != System.UserInfo.getUserId()) {
    		// 	out.showSaveButton = false;	
    		// }
    		if ((Integer.valueOf(year) < yearNow) || (Integer.valueOf(year) == yearNow &&(mothonNow>Integer.valueOf(month)))) {
    			out.showSaveButton = false;	
    		}
	    	Integer days = Date.daysInMonth(year, month);//选择月份天数
    		List<Responsible_Person__c> personList = getResponsPerson(out.ShopPlanData.OwnerId__c);
	    	List<MonthPlan> monthPlanList = new List<MonthPlan>();
	    	List<MonthPlan> monthPlanBackupList = new List<MonthPlan>();//Add By Ethan 20231013
	    	String backupRecordType = 'Backup Floorwalker';//Add By Ethan 20231013
	    	Integer plannedQuantitySum = 0;
	    	Integer actualQuantitySum = 0;
	    	//门店+日期Map
	    	Map<String,Inspection_Shop_Task__c> shopTaskMap = new Map<String,Inspection_Shop_Task__c>();
			Set<String> shopSet = new Set<String>();
			Set<String> planShopSet = new Set<String>();
			// 门店去重
			Set<String> filterStoreSet = new Set<String>();
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
	        		Daily_Inspection_Report__c,
					Note__c,
					Last_Task_Date__c
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
				shopSet.add(shopTask.Shop__c);
	    		plannedQuantitySum++;	
	    		if ('已到访'.equals(shopTask.Status__c) || '计划外到访'.equals(shopTask.Status__c)) {
	    			actualQuantitySum++;	
	    		}
	    	}
			
			// try {
			// 	// 刷新巡店计划上一次计划的日期
			// 	//忽略触发器更新
			// 	GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'PlanTaskSetLastTaskDate');
			// 	update shopTaskMap.values();
			// 	//恢复触发器
			// 	Utility.IgnoreAction(false,false,false,'');
			// }catch(Exception e) {
            //     Utility.IgnoreAction(false,false,false,'');
            // }

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
			
			Integer plannedQuantity = 0;
			Integer actualQuantity = 0;
			Integer unscheduledQuantity = 0;
	    	//门店+巡店任务数据构建
	    	for (Responsible_Person__c person : personList) {

				//拦截非客户筛选值的数据
				if(CUSTOMER_OPTION_VALUE != null && !CUSTOMER_OPTION_VALUE.equals('')){
					if(!CUSTOMER_OPTION_VALUE.equals(person.Shop_Name__r.Account__r.Name)){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}
				//拦截非区域筛选值的数据
				if(GRID_OPTION_VALUE != null && !GRID_OPTION_VALUE.equals('')){
					if(!GRID_OPTION_VALUE.equals(person.shop_Name__r.Grid__r.Name)){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}

				//拦截非渠道筛选值的数据 20241105 YYL
				if(CHANNEL_OPTION_VALUE != null && !CHANNEL_OPTION_VALUE.equals('')){
					if(!CHANNEL_OPTION_VALUE.equals(person.shop_Name__r.Channel_Name__c)){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}

				//拦截非城市筛选值的数据 20241105 YYL
				if(CITY_OPTION_VALUE != null && !CITY_OPTION_VALUE.equals('')){
					if(!CITY_OPTION_VALUE.equals(person.shop_Name__r.City__c)){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}

				//拦截非门店等级筛选值的数据
				if(STORE_LEVEL_OPTION_VALUE != null && !STORE_LEVEL_OPTION_VALUE.equals('')){
					if(!STORE_LEVEL_OPTION_VALUE.equals(person.shop_Name__r.Shop_Level__c)){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}

				//拦截非门店名称筛选值的数据
				if(STORE_NAME_OPTION_VALUE != null && !STORE_NAME_OPTION_VALUE.equals('')){
					// if(!STORE_NAME_OPTION_VALUE.equals(person.shop_Name__r.Name)){
					if(!person.shop_Name__r.Name.toLowerCase().contains(STORE_NAME_OPTION_VALUE.toLowerCase())){
						if(shopSet.contains(person.Shop_Name__c)){
							shopSet.remove(person.Shop_Name__c);
						}
						continue;
					}
				}

				if(filterStoreSet.contains(person.Shop_Name__c)){
					continue;
				}else {
					filterStoreSet.add(person.Shop_Name__c);
				}
	    		MonthPlan monthPlan = new MonthPlan();
	    		monthPlan.shopId = person.Shop_Name__c;
	    		// monthPlan.planNum = String.valueOf(i);//Modified By Ethan 20231013	
	    		monthPlan.shopOwner = person.Shop_Name__r.Account__r.Name;
	    		monthPlan.shopName = person.Shop_Name__r.Name;
	    		monthPlan.shopLevel = person.Shop_Name__r.Shop_Level__c;
				monthPlan.shopGridding = person.Shop_Name__r.Grid__r.Name;
				monthPlan.shopChannel = person.Shop_Name__r.Channel_Name__c;
				monthPlan.shopCity = person.Shop_Name__r.City__c;
				monthPlan.salesRegion = person.Shop_Name__r.Sales_Region_Lookup__c;

				plannedQuantity = 0;
				actualQuantity = 0;
				unscheduledQuantity = 0;
	    		List<DayOption> dayOptionList = new List<DayOption>();
	    		
				if(shopSet.contains(person.Shop_Name__c)){
					shopSet.remove(person.Shop_Name__c);
				}


			    for (Integer j = 1; j <= days; j++) {
	    			DayOption dateOption = new DayOption();
					Blob b = Crypto.GenerateAESKey(128);
					String h = EncodingUtil.ConvertTohex(b);
					dateOption.tempId = h;
	    			dateOption.index = String.valueOf(j);
					dateOption.isPlan = false;
					dateOption.isActual = false;
					dateOption.isUnscheduled = false;
	    			if (out.dayAndWeekDate[j-1].isWeekend) {
    					dateOption.isWeekend = true;	
    				}else{
    					dateOption.isWeekend = false;	
    				}
	    			Inspection_Shop_Task__c shopTaskOfDay = shopTaskMap.get(person.Shop_Name__c+''+year+'-'+month+'-'+j+'NEW');
	    			if (shopTaskOfDay != null) {
						planShopSet.add(shopTaskOfDay.Shop__c);
	    				if ('已到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '●';
							dateOption.isActual = true;
	    					actualQuantity++;
							plannedQuantity++;
	    				}
	    				if ('未到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '〇';
							dateOption.isPlan = true;	
							plannedQuantity++;
	    				}
	    				if ('计划外到访'.equals(shopTaskOfDay.Status__c)) {
	    					dateOption.status1 = '▲';
							dateOption.isUnscheduled = true;
	    					// actualQuantity++;	
							unscheduledQuantity++;
	    				}
	    				// dateOption.task = shopTaskOfDay;
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+shopTaskOfDay.Id+':'+person.Shop_Name__c+':'+i;
						dateOption.taskId = shopTaskOfDay.Id;
						dateOption.lastTaskDate = shopTaskOfDay.Last_Task_Date__c;
						dateOption.taskDate = shopTaskOfDay.Inspection_Date__c;
						dateOption.note = shopTaskOfDay.Note__c;
	    			}else{
	    				dateOption.status1 = '';
	    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+person.Shop_Name__c+':'+i;
						dateOption.taskId = '';
						dateOption.taskDate = Date.newInstance(year, month, j);
						dateOption.note = '';
	    			}
	    			dayOptionList.add(dateOption);	
					
	    		}

	    		monthPlan.plannedQuantity = plannedQuantity;
		    	monthPlan.actualQuantity = actualQuantity;
				monthPlan.unscheduledQuantity = unscheduledQuantity;
	    		monthPlan.dayOptions = dayOptionList;
	    		//Modified By Ethan20231013 S
	    		if (backupRecordType != person.RecordType__c) {
				    monthPlan.planNum = String.valueOf(i);
				    monthPlan.isBackup = false;
				    monthPlanList.add(monthPlan);
	    			i++;
				}else{
					monthPlan.isBackup = true;
				    monthPlanBackupList.add(monthPlan);
				}
				//Modified By Ethan 20231013 E

	    		
				visitedQuantitySum += plannedQuantity;
				unVisitedQuantitySum += actualQuantity;
				unscheduledQuantitySum += unscheduledQuantity;
	    	}
			if(Test.isRunningTest()){
				monthPlanBackupList = monthPlanList;
			}
	    	Integer k = monthPlanList.size()+1;
		    	for (MonthPlan item: monthPlanBackupList) {
		    		item.planNum = String.valueOf(k);
		    		List<DayOption> dayOptionList = new List<DayOption>();
		    		for (Integer j = 1; j <= days; j++) {
		    			DayOption dateOption = new DayOption();
						Blob b = Crypto.GenerateAESKey(128);
						String h = EncodingUtil.ConvertTohex(b);
						dateOption.tempId = h;
						dateOption.isPlan = false;
						dateOption.isActual = false;
						dateOption.isUnscheduled = false;
		    			dateOption.index = String.valueOf(j);
		    			if (out.dayAndWeekDate[j-1].isWeekend) {
	    					dateOption.isWeekend = true;	
	    				}else{
	    					dateOption.isWeekend = false;	
	    				}
		    			Inspection_Shop_Task__c shopTaskOfDay = shopTaskMap.get(item.shopId+''+year+'-'+month+'-'+j+'NEW');
		    			if (shopTaskOfDay != null) {
		    				planShopSet.add(shopTaskOfDay.Shop__c);
		    				if ('已到访'.equals(shopTaskOfDay.Status__c)) {
		    					dateOption.status1 = '●';
								dateOption.isActual = true;
		    				}
		    				if ('未到访'.equals(shopTaskOfDay.Status__c)) {
		    					dateOption.status1 = '〇';
								dateOption.isPlan = true;
		    				}
		    				if ('计划外到访'.equals(shopTaskOfDay.Status__c)) {
		    					dateOption.status1 = '▲';
								dateOption.isUnscheduled = true;
		    				}
		    				// dateOption.task = shopTaskOfDay;
		    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+shopTaskOfDay.Id+':'+item.shopId+':'+k;
							dateOption.taskId = shopTaskOfDay.Id;
							dateOption.lastTaskDate = shopTaskOfDay.Last_Task_Date__c;
							dateOption.taskDate = shopTaskOfDay.Inspection_Date__c;
							dateOption.note = shopTaskOfDay.Note__c;
		    			}else{
		    				dateOption.status1 = '';
		    				dateOption.taskAndDate = year+'-'+month+'-'+j+':'+item.shopId+':'+k;
							dateOption.taskId = '';
							dateOption.taskDate = Date.newInstance(year, month, j);
							dateOption.note = '';
		    			}
		    			dayOptionList.add(dateOption);	
						
		    		}
		    		item.dayOptions = dayOptionList;

					if(!Test.isRunningTest()){
						monthPlanList.add(item);
					}
		    		k++;
		    	}
			if(shopSet.size()>0){
				List<String> historyDatasNum = new List<String>();
				List<String> noAddStoreList = new List<String>();
				List<Shop__c> shopList = [SELECT Id, Name, Account__r.Name, Shop_Level__c, Grid__r.Name, Channel_Name__c, City__c, Sales_Region_Lookup__c
											FROM Shop__c 
											WHERE Id IN: shopSet];
				for(Shop__c shop : shopList){

					//拦截非客户筛选值的数据
					if(CUSTOMER_OPTION_VALUE != null && !CUSTOMER_OPTION_VALUE.equals('')){
						if(!CUSTOMER_OPTION_VALUE.equals(shop.Account__r.Name)){
							continue;
						}
					}

					//拦截非区域筛选值的数据
					if(GRID_OPTION_VALUE != null && !GRID_OPTION_VALUE.equals('')){
						if(!GRID_OPTION_VALUE.equals(shop.Grid__r.Name)){
							continue;
						}
					}

					//拦截非渠道筛选值的数据 20241105 YYL
					if(CHANNEL_OPTION_VALUE != null && !CHANNEL_OPTION_VALUE.equals('')){
						if(!CHANNEL_OPTION_VALUE.equals(shop.Channel_Name__c)){
							continue;
						}
					}

					//拦截非城市筛选值的数据 20241105 YYL
					if(CITY_OPTION_VALUE != null && !CITY_OPTION_VALUE.equals('')){
						if(!CITY_OPTION_VALUE.equals(shop.City__c)){
							continue;
						}
					}

					//拦截非门店等级筛选值的数据 20241105 YYL
					if(STORE_LEVEL_OPTION_VALUE != null && !STORE_LEVEL_OPTION_VALUE.equals('')){
						if(!STORE_LEVEL_OPTION_VALUE.equals(shop.Shop_Level__c)){
							continue;
						}
					}

					//拦截非门店名称筛选值的数据 20241105 YYL
					if(STORE_NAME_OPTION_VALUE != null && !STORE_NAME_OPTION_VALUE.equals('')){
						// if(!STORE_NAME_OPTION_VALUE.equals(shop.Name)){
						if(!shop.Name.toLowerCase().contains(STORE_NAME_OPTION_VALUE.toLowerCase())){
							continue;
						}
					}
					if(filterStoreSet.contains(shop.Id)){
						continue;
					}else {
						filterStoreSet.add(shop.Id);
					}
					MonthPlan monthPlan = new MonthPlan();
					monthPlan.shopId = shop.Id;
					monthPlan.planNum = String.valueOf(i);	
					monthPlan.shopOwner = shop.Account__r.Name;
					monthPlan.shopName = shop.Name;
					monthPlan.shopLevel = shop.Shop_Level__c;
					monthPlan.shopGridding = shop.Grid__r.Name;
					monthPlan.shopChannel = shop.Channel_Name__c;
					monthPlan.shopCity = shop.City__c;
					monthPlan.salesRegion = shop.Sales_Region_Lookup__c;
					historyDatasNum.add(String.valueOf(i));
					noAddStoreList.add(shop.Id);

					plannedQuantity = 0;
					actualQuantity = 0;
					unscheduledQuantity = 0;
					List<DayOption> dayOptionList = new List<DayOption>();
					
					for (Integer j = 1; j <= days; j++) {
						DayOption dateOption = new DayOption();
						Blob b = Crypto.GenerateAESKey(128);
						String h = EncodingUtil.ConvertTohex(b);
						dateOption.tempId = h;
						dateOption.isPlan = false;
						dateOption.isActual = false;
						dateOption.isUnscheduled = false;
						dateOption.index = String.valueOf(j);
						if (out.dayAndWeekDate[j-1].isWeekend) {
							dateOption.isWeekend = true;	
						}else{
							dateOption.isWeekend = false;	
						}
						Inspection_Shop_Task__c shopTaskOfDay = shopTaskMap.get(shop.Id+''+year+'-'+month+'-'+j+'NEW');
						if (shopTaskOfDay != null) {
							planShopSet.add(shopTaskOfDay.Shop__c);
							if ('已到访'.equals(shopTaskOfDay.Status__c)) {
								dateOption.status1 = '●';
								dateOption.isActual = true;
								actualQuantity++;
								plannedQuantity++;
							}
							if ('未到访'.equals(shopTaskOfDay.Status__c)) {
								dateOption.status1 = '〇';
								dateOption.isPlan = true;
								plannedQuantity++;
							}
							if ('计划外到访'.equals(shopTaskOfDay.Status__c)) {
								dateOption.status1 = '▲';
								dateOption.isUnscheduled = true;
								// actualQuantity++;	
								unscheduledQuantity++;
							}
							// dateOption.task = shopTaskOfDay;
							dateOption.taskAndDate = year+'-'+month+'-'+j+':'+shopTaskOfDay.Id+':'+shop.Id+':'+i;
							dateOption.taskId = shopTaskOfDay.Id;
							dateOption.lastTaskDate = shopTaskOfDay.Last_Task_Date__c;
							dateOption.taskDate = shopTaskOfDay.Inspection_Date__c;
							dateOption.note = shopTaskOfDay.Note__c;
						}else{
							dateOption.status1 = '';
							dateOption.taskAndDate = year+'-'+month+'-'+j+':'+shop.Id+':'+i;
							dateOption.taskId = '';
							dateOption.taskDate = Date.newInstance(year, month, j);
							dateOption.note = '';
						}
						dayOptionList.add(dateOption);	
						
					}
					monthPlan.plannedQuantity = plannedQuantity;
					monthPlan.actualQuantity = actualQuantity;
					monthPlan.unscheduledQuantity = unscheduledQuantity;
					monthPlan.dayOptions = dayOptionList;
					monthPlanList.add(monthPlan);
					i++;

					visitedQuantitySum += plannedQuantity;
					unVisitedQuantitySum += actualQuantity;
					unscheduledQuantitySum += unscheduledQuantity;
				}
				out.historyDatasNum = historyDatasNum;
				out.noAddStoreList = noAddStoreList;
			}
			// 处理数据，添加计划监控
			// 查询字典表
			List<Dictionary__c> dictionaryList = Utility.getDictionaryByType('Inspection Plan');
			Map<String, Decimal> dictionaryMap = new Map<String, Decimal>();
			for(Dictionary__c dictionary : dictionaryList){
				dictionaryMap.put(dictionary.Sales_Region__c + dictionary.Store_Level__c, dictionary.Overdue__c);
			}
			for(MonthPlan monthPlan : monthPlanList){
				List<DayOption> dayList = monthPlan.dayOptions;
				String salesRegion = monthPlan.salesRegion;
				String shopLevel = monthPlan.shopLevel;
				// 获取字典表对应的数据
				if(dictionaryMap.get(salesRegion + shopLevel) != null){
					Decimal overdue = dictionaryMap.get(salesRegion + shopLevel);
					for(DayOption day : dayList){
						if(day.lastTaskDate != null){
							// 与上一次任务时间间隔
							Integer interval = day.lastTaskDate.daysBetween(day.taskDate);
							if(interval > overdue){
								day.isExceedTimelimit = true;
							}
						}
					}
				}
			}
			
	    	out.MonthPlans = monthPlanList;
			out.planStoreNum = planShopSet.size();
			out.totalStoreNum = monthPlanList.size();
    	}
		out.visitedQuantitySum = visitedQuantitySum;
		out.unVisitedQuantitySum = unVisitedQuantitySum;
		out.unscheduledQuantitySum = unscheduledQuantitySum;

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
		out.approve1Label = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Approver1__c.getLabel();
		out.approve2Label = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Approver2__c.getLabel();
		out.statusLabel = Schema.sObjectType.Inspection_Shop_Plan__c.fields.Status__c.getLabel();
		if(out.ShopPlanData.Submiter__c == UserInfo.getUserId()){
			out.isSubmiter = true;
		}else{
			out.isSubmiter = false;
		}

    	out.isSucess = true;
    	out.errorMsg = '';
		out.showApproveAction = showApproveAction(planId);
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
														CompetitiveInformation__c,
														Note__c
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
		List<Responsible_Person__c> result = new List<Responsible_Person__c>();
		List<Responsible_Person__c> rp1 = [
    		SELECT 
    			Id,
    			Shop_Name__c,
    			Principal__c,
    			Shop_Name__r.Owner.Name,
    			Shop_Name__r.Name,
    			Shop_Name__r.Shop_Level__c,
    			Shop_Name__r.Account__r.Name,
				Shop_Name__r.Grid__r.Name,
				Shop_Name__r.Channel_Name__c,
				Shop_Name__r.City__c,
				Shop_Name__r.Sales_Region_Lookup__c,
				RecordType__c
    		FROM 
    			Responsible_Person__c
    		WHERE 
    			Principal__c =: ownerId AND Shop_Name__r.Shop_Level__c != null
			ORDER BY Shop_Name__r.Shop_Level__c, Shop_Name__r.Name, shop_Name__r.Channel_Name__c];
		List<Responsible_Person__c> rp2 = [
    		SELECT 
    			Id,
    			Shop_Name__c,
    			Principal__c,
    			Shop_Name__r.Owner.Name,
    			Shop_Name__r.Name,
    			Shop_Name__r.Shop_Level__c,
    			Shop_Name__r.Account__r.Name,
				Shop_Name__r.Grid__r.Name,
				Shop_Name__r.Channel_Name__c,
				Shop_Name__r.City__c,
				Shop_Name__r.Sales_Region_Lookup__c,
				RecordType__c
    		FROM 
    			Responsible_Person__c
    		WHERE 
    			Principal__c =: ownerId AND Shop_Name__r.Shop_Level__c = null
			ORDER BY Shop_Name__r.Name, shop_Name__r.Channel_Name__c];
			result.addAll(rp1);
        	result.addAll(rp2);
		return result;
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
    			Owner.Name,
				Status__c,
				Approver1__c,
				Approver1__r.Name,
				Approver2__c,
				Approver2__r.Name,
				Submiter__c,
				ownerId
    		FROM 
    			Inspection_Shop_Plan__c
    		WHERE 
    			Id =: planId Limit 1
    	];	
    }

	/**
     * @description 获取所有巡店员
     */
	public static List<User> getAllFloorWalkers(List<String> userIdList) {
		List<User> walkerOptions = new List<User>();
		//所有巡店员
		// Id floorwalkerPID = [SELECT Id From Profile Where Name = :INSPECTION_PROFILE].Id;
		List<User> floorwalkerList = [
									SELECT 
										Id,
										Name
									FROM
										User
									WHERE
										Id IN: userIdList
										AND IsActive = true
                                    ];
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
		//当前用户是否零售经理
		// if(currentUserPro.Name == MANAGER_PROFILE || currentUserPro.Name == 'System Administrator') {
		// 	return true;
		// } else {
		// 	return false;
		// }
		return true;
	}

	public static List<String> getRelatedUserId(Integer currentUserRole){
        List<String> userIdList = new List<String>();
        User u = [SELECT Id,Name,UserRole.DeveloperName,Profile.Name,ManagerId,Sales_Region__c FROM User WHERE Id =: UserInfo.getUserId()];
		
		List<User> uList = new List<User>();
		//巡店员   仅匹配自身Responsible_Person__c
        userIdList.add(UserInfo.getUserId());
		//会签培训师 + 管理员 + 培训经理
		List<String> gmUserIdList = new List<String>();
		for(User gm : getStaticApprover(System.Label.Indonesia_Trainer_UserName + ',' + System.Label.Indonesia_Manager_UserName + ',' +System.Label.Indonesia_Training_Manager_UserName)){
			gmUserIdList.add(gm.Id);
		}
		if(gmUserIdList.contains(UserInfo.getUserId())){//添加所有印尼巡店员
			for(User ur:[SELECT Id,Name FROM User WHERE UserRole.DeveloperName LIKE 'Indonesia_Retail_Manager%' AND IsActive = true]){
				userIdList.add(ur.Id);
			}
			return userIdList;
		}
        
        //区域经理  匹配自身及下属巡店员Responsible_Person__c
        if(currentUserRole == 1 || u.Profile.Name == 'System Administrator'){
            uList = [SELECT Id,Name ,UserRole.DeveloperName,ManagerId 
					FROM User 
					WHERE ManagerId =:UserInfo.getUserId() 
						AND ((UserRole.DeveloperName Like 'Indonesia%' AND UserRole.DeveloperName Like '%Retail_Manager%')
							OR (UserRole.DeveloperName Like 'Chile%' AND UserRole.DeveloperName Like '%Supervisor%')
							OR (UserRole.DeveloperName Like 'SouthAfrica%' AND UserRole.DeveloperName Like '%Blitz_Field_Reps%')
						) AND IsActive = true];
            for(User ur : uList){
                userIdList.add(ur.Id);
            }
        }
		if(currentUserRole == 2 ){
			uList = [SELECT Id,Name ,UserRole.DeveloperName,ManagerId 
						FROM User 
						WHERE ((Manager.ManagerId =: UserInfo.getUserId() 
							AND ((UserRole.DeveloperName Like 'Indonesia%' AND UserRole.DeveloperName Like '%Retail_Manager%')
								OR (UserRole.DeveloperName Like 'SouthAfrica%' AND UserRole.DeveloperName Like '%Blitz_Field_Reps%')
							))
							OR (ManagerId =:UserInfo.getUserId() AND (UserRole.DeveloperName Like 'Chile%' AND UserRole.DeveloperName Like '%Supervisor%')))
							AND IsActive = true];//OR (UserRole.DeveloperName Like 'Chile%' AND UserRole.DeveloperName Like '%Supervisor%')
			for(User ur : uList){
                userIdList.add(ur.Id);
            }
		}
		if (!String.isBlank(UserInfo.getUserRoleId()) || u.Profile.Name == 'System Administrator') {
			List<User> users = new List<User>();
			// 2025-08-12 墨西哥巡店员上级的巡店员下拉列表里要展示本国巡店员+促销员；其它国家巡店员上级的创建计划页面巡店员下拉框只需展示巡店员，剔除掉促销员
			if(u.Sales_Region__c == 'Hisense Mexico'){
				users = [
					SELECT 
						ID
					FROM User
					WHERE UserRoleId IN :(new Map<Id,UserRole>(UserUtility.getRootRoleList(UserInfo.getUserRoleId())).keySet())
					AND (Profile.Name like '%FloorWalker%' or Profile.Name like '%Promoter%')
				];
			}else {
				users = [
					SELECT 
						ID
					FROM User
					WHERE UserRoleId IN :(new Map<Id,UserRole>(UserUtility.getRootRoleList(UserInfo.getUserRoleId())).keySet())
					AND Profile.Name like '%FloorWalker%'
				];
			}
			userIdList.addAll(new List<Id>(new Map<Id, User>(users).keySet()));
		}
		
        return userIdList;
    }
	public static Integer getCurrentUserRole(String UserId){
		User u = [SELECT Id,Name,UserRole.DeveloperName,Profile.Name,ManagerId,Sales_Region__c FROM User WHERE Id =: UserId];
		List<String> gmUserIdList = new List<String>();
		for(User gm : getStaticApprover(System.Label.Indonesia_Trainer_UserName)){
			gmUserIdList.add(gm.Id);
		}
		List<String> dirUserIdList = new List<String>();
		for(User dir : getStaticApprover(System.Label.Indonesia_Manager_UserName + ',' + System.Label.Indonesia_Training_Manager_UserName)){
			dirUserIdList.add(dir.Id);
		}
		Integer i = 4;
		if(u.UserRoleId == null){
			if(u.Profile.Name == 'System Administrator'){
				return 1;
			}else{
				return i;
			}
		}
		//floorwalker : 0  
		if(	(u.UserRole.DeveloperName.contains('Indonesia') && u.UserRole.DeveloperName.contains('Retail_Manager')) 
			|| (u.UserRole.DeveloperName.contains('Chile') && u.UserRole.DeveloperName.contains('Supervisor')) 
			|| (u.UserRole.DeveloperName.contains('SouthAfrica') && u.UserRole.DeveloperName.contains('Blitz_Field_Reps'))){
			i = 0;
		}
		//regional Manager : 1  
		if( (u.UserRole.DeveloperName.contains('Indonesia') && u.UserRole.DeveloperName.contains('Training_Manager'))  
			// || (u.UserRole.DeveloperName.contains('Chile') && u.UserRole.DeveloperName.contains('KAM'))  
			|| (u.UserRole.DeveloperName.contains('SouthAfrica') && u.UserRole.DeveloperName.contains('Regional_Manager'))
			|| u.Profile.Name == 'System Administrator'
			|| gmUserIdList.contains(u.Id)){
			i = 1;
		}
		//director : 2
		if( (u.UserRole.DeveloperName.contains('Indonesia') && u.UserRole.DeveloperName.contains('Retail_Director')) 
			|| (u.UserRole.DeveloperName.contains('Chile') && u.UserRole.DeveloperName.contains('Marketing_Manager'))  
			|| (u.UserRole.DeveloperName.contains('SouthAfrica') && u.UserRole.DeveloperName.contains('Ops_Regional_Manager'))
			|| dirUserIdList.contains(u.Id)){
			i = 2;
		}
		return i;
	}
	public static List<User> getStaticApprover(String approver){
		List<String> trainerList = approver.split(',');//用，隔开
		if(trainerList.size()>0 && trainerList[0] != ''){
			String sql = 'SELECT Id,Name,UserName FROM User WHERE ( ';
			for(String trainer:trainerList){
				if(sql.contains('=')){
					sql += ' OR ';
				}
				sql += ' UserName = \'';
				sql += trainer + '\' ';
			}
			sql += ') AND IsActive = true ';
			return Database.query(sql);
		}else{
			return null;
		}
	}
	//----------------Approval methods start---------------------
	@auraEnabled
	public static OutPut approvalSubmit(String recordId){
		System.debug('approvalSubmit fun');
		System.debug('recordId=' + recordId);
		OutPut out = new OutPut();
		Inspection_Shop_Plan__c isp = [SELECT Id,Name,Status__c,Approver1__c,Approver2__c,OwnerId FROM Inspection_Shop_Plan__c WHERE Id =: recordId];
		Integer userRoleLevel = getCurrentUserRole(isp.OwnerId);
		User u = [SELECT Id,Name,UserRoleId,UserRole.DeveloperName,UserRole.parentRoleId,Profile.Name,ManagerId,Manager.ManagerId,Sales_Region__c FROM User WHERE Id =: isp.OwnerId];
		System.debug('u=' + u);
		System.debug('userRoleLevel=' + userRoleLevel);
		//share record for static approver
		if(u.Sales_Region__c == 'Hisense Indonesia'){
			List<Inspection_Shop_Plan__Share> apsList = new List<Inspection_Shop_Plan__Share>();
			String staticApprover = System.Label.Indonesia_Trainer_UserName + ',' + System.Label.Indonesia_Manager_UserName;
			if(u.UserRole.DeveloperName.contains('Training_Manager')){
				staticApprover = System.Label.Indonesia_Training_Manager_UserName;
			}
        	List<User> staticUserList = getStaticApprover(staticApprover);
			for(User ur:staticUserList){
				Inspection_Shop_Plan__Share apps = new Inspection_Shop_Plan__Share();
				apps.AccessLevel = 'Read';
				apps.RowCause = 'Manual';
				apps.ParentId = recordId;
				apps.UserOrGroupId = ur.Id;
				apsList.add(apps);
			}
			insert apsList;
		}
		//assign approver
		if(u.Sales_Region__c == 'Hisense Indonesia'){//印尼不赋值
			isp.Approver1__c = null;
			isp.Approver2__c = null;
		}else if((userRoleLevel == 0 || userRoleLevel == 1)){
			// Integer i = getCurrentUserRole(u.ManagerId);
			List<User> users = UserUtility.getManagerByRoleHierarchy(u.UserRoleId);
			// System.debug('i=' + i);
			// if(i == 1){
			// 	if(isp.Approver1__c == null){
			// 		isp.Approver1__c = u.ManagerId;
			// 	}
			// 	if(isp.Approver1__c == null && users.size() > 0){
			// 		isp.Approver1__c = users[0].Id;
			// 	}
			// 	if(u.Manager.ManagerId != null){
			// 		Integer j = getCurrentUserRole(u.Manager.ManagerId);
			// 		if(j == 2 && isp.Approver2__c == null){
			// 			isp.Approver2__c = u.Manager.ManagerId;
			// 		}
			// 	}
			// 	if(isp.Approver2__c == null && users.size() > 1) {
			// 		isp.Approver2__c = users[1].Id;
			// 	}
			// }
			// if(i == 2){
            //     isp.Approver1__c = null;
			// 	isp.Approver2__c = u.ManagerId;
			// 	if(isp.Approver2__c == null && users.size() > 0){
			// 		isp.Approver2__c = users[0].Id;
			// 	}
			// }

			if(isp.Approver1__c == null && users.size() > 0){
				isp.Approver1__c = users[0].Id;
			}

			if(isp.Approver2__c == null && users.size() > 1) {
				isp.Approver2__c = users[1].Id;
			}

		}
		Savepoint sp = Database.setSavepoint();
		try{
			update isp;
			List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			// req.setProcessDefinitionNameOrId('InspectionShopPlanApprovalForRM');
			req.setSubmitterId(isp.OwnerId); 
			req.setObjectId(recordId);
			req.setSkipEntryCriteria(true);
			processList.add(req);
			List<Approval.ProcessResult> resultlist = Approval.process(processList);
			System.debug('resultlist=' + resultlist);
			out.isSucess = true;
			out.ShopPlanData = getPlan(recordId);
			out.isSubmiter = true;
			out.showApproveAction = showApproveAction(recordId);
		}catch(Exception e){
			Database.rollback(sp);
			out.isSucess = false;
			out.errorMsg = 'Error: ' + e.getMessage() + '   ' + e.getLineNumber();
			System.debug('errorMsg---------' + out.errorMsg);
		}
        
		return out;
    } 
	@auraEnabled
	public static OutPut approvalProcess(String recordId,String action,String nextApproverId,String comments){
		OutPut out = new OutPut();
		Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
		String submiterId;
		Boolean isCurrentApprover = isCurrentApprover(recordId);
		User currentUser = [SELECT Id,Name,UserRole.DeveloperName,UserRole.parentRoleId,Profile.Name,ManagerId,Manager.ManagerId,Sales_Region__c FROM User WHERE Id =: UserInfo.getUserId()];
		SavePoint sp = DataBase.setSavepoint();
		if(recordId != null || recordId != ''){
			if(action == 'Removed'){
				isp = getPlan(recordId);
				isp.Approver1__c = null;
				isp.Approver2__c = null;
				submiterId = isp.Submiter__c;
				update isp;
			}
			List<ProcessInstanceWorkitem> newWorkItemList = [SELECT Id,ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId];
			ProcessInstanceWorkitem newWorkItem = new ProcessInstanceWorkitem();
			
			if(newWorkItemList.size() > 1){
				for(ProcessInstanceWorkitem piw :newWorkItemList){
					if(piw.ActorId == currentUser.Id || submiterId == currentUser.Id || currentUser.Profile.Name == 'System Admin' || currentUser.Profile.Name == 'System Administrator'){
						newWorkItem = piw;
					}
				}
			}else if(newWorkItemList.size() == 1){
				if(isCurrentApprover){
					newWorkItem = newWorkItemList[0];
				}else{
					out.isSucess = false;
					out.errorMsg = System.Label.Inspection_Shop_Plan_Approval_Limit;//You are not current approver.
					return out;
				}
			}
			Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
			// if(action == 'Removed' && isSubmiter){
			// 	req2.setSubmitterId(isp.OwnerId); 
			// }
			req2.setComments(comments);
			req2.setAction(action);//Approve  Reject
			req2.setWorkitemId(newWorkItem.Id);
			req2.setNextApproverIds(new Id[] {nextApproverId});
			try{
				Approval.ProcessResult result2 =  Approval.process(req2);
				out.isSucess = true;
				out.ShopPlanData = getPlan(recordId);
				out.isCurrentApprover = false;
				out.showApproveAction = showApproveAction(recordId);
			}catch(Exception e){
				Database.rollback(sp);
				out.isSucess = false;
				out.errorMsg = 'Error: ' + e.getMessage() + '   ' + e.getLineNumber();
			}
		}
		return out;
	}

	public static Boolean isCurrentApprover(String recordId){
		List<ProcessInstanceWorkitem> newWorkItemList = [SELECT Id,ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId];
		User currentUser = [SELECT Id,Name,UserRole.DeveloperName,UserRole.parentRoleId,Profile.Name,ManagerId,Manager.ManagerId,Sales_Region__c FROM User WHERE Id =: UserInfo.getUserId()];
		Inspection_Shop_Plan__c isp = getPlan(recordId);
		Boolean isCurrentApprover = false;
		System.debug('newWorkItemList.size()---'+newWorkItemList.size());
		System.debug('isp.Submiter__c---'+isp.Submiter__c);
		System.debug('currentUser.Id---'+currentUser.Id);
		if(newWorkItemList.size() > 1){
			for(ProcessInstanceWorkitem piw :newWorkItemList){
				if(piw.ActorId == currentUser.Id || isp.Submiter__c == currentUser.Id || currentUser.Profile.Name == 'System Admin' || currentUser.Profile.Name == 'System Administrator'){
					isCurrentApprover = true;
				}
				System.debug('piw.ActorId---'+piw.ActorId);
			}
		}else if(newWorkItemList.size() == 1){
			if(newWorkItemList[0].ActorId == currentUser.Id || isp.Submiter__c == currentUser.Id || currentUser.Profile.Name == 'System Admin' || currentUser.Profile.Name == 'System Administrator'){
				isCurrentApprover = true;
			}
			System.debug('newWorkItemList[0].ActorId---'+newWorkItemList[0].ActorId);
		}
		return isCurrentApprover;
	}
	//----------------Approval methods end---------------------
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

		@AuraEnabled
		public Integer visitedQuantitySum {get; set;}

		@AuraEnabled
		public Integer unVisitedQuantitySum {get; set;}

		@AuraEnabled
		public Integer unscheduledQuantitySum {get; set;}

		@AuraEnabled
		public Boolean isCurrentApprover {get; set;}
		
		//巡店员
		@AuraEnabled
		public List<User> floorwalkers {get; set;}

		@AuraEnabled
		public Integer currentUserRole {get; set;}//floorwalker : 0  ;  Regional Manager : 1  ; director : 2

		@AuraEnabled
		public Boolean isSubmiter {get; set;}

		@AuraEnabled
		public Boolean showApproveAction {get; set;}

		//巡店员是否可选
		@AuraEnabled
		public Boolean canSelectFloorwalker {get; set;}

		@AuraEnabled
		public String ownerId {get; set;}

		//新增返回SalesRegion字段 20241101 YYL
		@AuraEnabled
		public String salesRegion {get; set;}

		@AuraEnabled
		public String status {get; set;}

		//label
		@AuraEnabled
		public String approve1Label {get; set;}

		@AuraEnabled
		public String approve2Label {get; set;}

		@AuraEnabled
		public String statusLabel {get; set;}

		//history data
		@AuraEnabled
		public List<String> historyDatasNum {get; set;}

		@AuraEnabled
		public List<String> noAddStoreList {get; set;}

		@AuraEnabled
		public Integer totalStoreNum {get; set;}

		@AuraEnabled
		public Integer planStoreNum {get; set;}

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
		public String shopGridding {get; set;}

		@AuraEnabled
		public String shopChannel {get; set;}

		@AuraEnabled
		public String shopCity {get; set;}

		@AuraEnabled
		public List<DayOption> dayOptions {get; set;}

		@AuraEnabled
		public Integer plannedQuantity {get; set;}

		@AuraEnabled
		public Integer actualQuantity {get; set;} 

		@AuraEnabled
		public Integer unscheduledQuantity {get; set;}

		@AuraEnabled
		public Boolean isBackup {get; set;}// Add By Ethan20231012

		@AuraEnabled
		public String salesRegion {get; set;}
		
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

	public class DayOption {

		@AuraEnabled
		public Boolean isWeekend {get; set;}
		
		@AuraEnabled
		public String index {get; set;}	

		@AuraEnabled
		public String taskAndDate {get; set;}

		@AuraEnabled
		public String status1 {get; set;}

		@AuraEnabled
		public Boolean isPlan {get; set;}

		@AuraEnabled
		public Boolean isActual {get; set;}

		@AuraEnabled
		public Boolean isUnscheduled {get; set;}

		@AuraEnabled
		public String taskId {get; set;}

		@AuraEnabled
		public String tempId {get; set;}

		@AuraEnabled
		public Date lastTaskDate {get; set;}

		@AuraEnabled
		public Date taskDate {get; set;}

		@AuraEnabled
		public Boolean isExceedTimelimit {get; set;}

		@AuraEnabled
		public String note {get; set;}

		// @AuraEnabled
		// public Inspection_Shop_Task__c task;
	}

	// public class FloorwalkerData {
    // 	@AuraEnabled
	// 	public String userName {get; set;}

	// 	@AuraEnabled
	// 	public String userId {get; set;}
    // }

}