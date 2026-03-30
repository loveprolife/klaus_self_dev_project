public without sharing class ExhibitionMRRTriggerHanderHelper {

	private final static String NOT_EXIST_MEETING_ROOM_INFO = '必须关联到会议室信息对象';
	private final static String OUT_OF_TIME = '开始时间和结束时间必须在可用时间之内';
	private final static String TIME_ERROR = '结束时间必须大于开始时间';
	private final static String APPLY_NAME = '申请人：';
	private final static String APPLY_PHONE = '申请人电话：';
	private final static String REPETITION_TIME = '此时间段已被申请：';
	private final static String TIP_MSG = '请与发生冲突的会议预订进行协调！';

    public static void validateRepetitionTime(List<Exhibition_Meeting_Room_Reservation__c> newList) {

    	//过滤启用的新预订
    	LisqContainer emrrLisqContainer = new LisqContainer(newList);
    	emrrLisqContainer = emrrLisqContainer.Where1('Is_Active__c', '=', true);




    	if (emrrLisqContainer.Size() > 0) {
    	    List<Exhibition_Meeting_Room_Reservation__c> nextStepList  = validateWriteError(emrrLisqContainer.ToSobjectList());
    	    if (nextStepList.size() > 0) {
    	        List<String> meetingRoomInfoIdList = new LisqContainer(nextStepList).SelectSField('Exhibition_Metting_Room_Info__c');
    	        // List<Date> reservationDateList = new LisqContainer(nextStepList).SelectSField('Metting_Date__c');

    	        LisqContainer existDataLisqContainer = new LisqContainer([
    	        	SELECT Id, Metting_Start_Time__c, Metting_End_Time__c, Exhibition_Metting_Room_Info__c, Applicant_Name__c, Applicant_Phone_Number__c,
    	        		Start_Time__c, End_Time__c, Metting_Date__c
    	        	FROM Exhibition_Meeting_Room_Reservation__c
    	        	WHERE Is_Active__c = TRUE AND Exhibition_Metting_Room_Info__c IN: meetingRoomInfoIdList 
    	        	// AND Metting_Date__c IN: reservationDateList
    	        	]);

    	        if (existDataLisqContainer.Size() > 0) {
    	            //ToMapS
    	            // Map<String, Sobject> existDataMap = existDataLisqContainer.ToMapS('Exhibition_Metting_Room_Info__c');
    	            for (Exhibition_Meeting_Room_Reservation__c item: nextStepList) {
    	            	 // LisqContainer repetionTimeLisqContainer = new LisqContainer()
    	            	LisqContainer existFilterData = existDataLisqContainer.WhereCustom(new LisqUtils.AndFilters(
			                new LisqUtils.FieldCompare('Exhibition_Metting_Room_Info__c', '=', item.Exhibition_Metting_Room_Info__c),
			                new LisqUtils.FieldCompare('Metting_Date__c', '=', item.Metting_Date__c),
			                new LisqUtils.NotFilter(
			                    new LisqUtils.OrFilters(new Object[]{
			                        'Metting_End_Time__c', '<', item.Metting_Start_Time__c,
			                        'Metting_Start_Time__c', '>', item.Metting_End_Time__c
			                    })
                			)
            			));

	    	            //抛出报错
	    	            List<String> errors = new List<String>();
	    	            Exhibition_Meeting_Room_Reservation__c errorContain = null;
	    	            for (Exhibition_Meeting_Room_Reservation__c item1: (List<Exhibition_Meeting_Room_Reservation__c>)existFilterData.ToSobjectList()) {
	    	            	errors.add(REPETITION_TIME+ APPLY_NAME+item1.Applicant_Name__c+APPLY_PHONE+item1.Applicant_Phone_Number__c+
	    	            		', 会议申请日期：'+item1.Metting_Date__c+', 会议开始时间：'+item1.Metting_Start_Time__c+', 会议结束时间：'+item1.Metting_End_Time__c);
	    	            }

	    	            if (errors.size() > 0) {
			                item.addError(String.join(errors, ';') + TIP_MSG);
			                return;
			            }
    	            }
    	        }
    	    }
    	}
    }

    public static List<Exhibition_Meeting_Room_Reservation__c> validateWriteError(List<Exhibition_Meeting_Room_Reservation__c> validateWriteList){

    	List<Exhibition_Meeting_Room_Reservation__c> nextStepValidList = new List<Exhibition_Meeting_Room_Reservation__c>();

    	for (Exhibition_Meeting_Room_Reservation__c item: validateWriteList) {
    		//TODO: 申请人是否必填验证
    		if (item.Metting_Date__c < item.Start_Date__c || item.Metting_Date__c > item.End_Date__c)
    			item.addError('会议申请日期必须在 '+ item.Start_Date__c + ' - '+ item.End_Date__c + ' 之间!');
    		else if (item.Metting_Start_Time__c > item.Metting_End_Time__c) 
    			item.addError(TIME_ERROR);
    		else if (item.Exhibition_Metting_Room_Info__c == NULL) 
    		    item.addError(NOT_EXIST_MEETING_ROOM_INFO);
    		else if (item.Metting_Start_Time__c > item.End_Time__c || item.Metting_End_Time__c <  item.Start_Time__c)
    			item.addError(OUT_OF_TIME+'可用开始时间为：'+item.Start_Time__c+' 可用结束时间为：'+item.End_Time__c );
    		else 
    			nextStepValidList.add(item);
    	}

    	return nextStepValidList;

    	


    }
}