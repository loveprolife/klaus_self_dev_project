public without sharing  class TextLnController {
	@AuraEnabled 
	public static ReturnData createRecord(String expoId, String lastNameCN, String lastNameEN, String firstNameCN, String firstNameEN, String telphone, String email,
		String wordTel, String qqWechatNumber, String fax, String duty, String department, String address, String url, String companyCN, String companyEN, Boolean isPresent, String dataJson) {

		ReturnData returnData = new ReturnData();

		try {
			ExpoInfo__c expoInfo = [SELECT TitleEN__c,TitleCN__c FROM ExpoInfo__c WHERE Id =: expoId];

		    // ExpoApplyInfo__c expo = new ExpoApplyInfo__c();
			ExpoApplyInfo__c expo = (ExpoApplyInfo__c)JSON.deserializeStrict(dataJson, ExpoApplyInfo__c.class); 

			if(String.isBlank(expo.ProductInterestEN__c) && String.isNotBlank(expo.ProductInterestCN__c)) {

				//产品偏好配置表全量查询做英文-中文 Map
				Map<String, String> proCNtoENMap = new Map<String, String>();
				for (ExpoProductPreference__c proItem: [SELECT Id, Name, ProductEN__c FROM ExpoProductPreference__c WHERE ProductEN__c<>NULL AND Name <> NULL]) {
					proCNtoENMap.put(proItem.Name, proItem.ProductEN__c);
				}

				expo.ProductInterestEN__c = '';
				for(String proLine : expo.ProductInterestCN__c.split(';')) {
                    if(proCNtoENMap.containskey(proLine)) {
                        expo.ProductInterestEN__c += proCNtoENMap.get(proLine) + ';';
                    }
                }
			}
			if(String.isNotBlank(expo.Country__c)) {
				expo.CountryRegionCN__c = expo.Country__c;
			}
			expo.ExpoId__c = expoId;
			expo.LastNameCN__c = lastNameCN;
			expo.LastNameEN__c = lastNameEN;
			expo.FirstNameCN__c = firstNameCN;
			expo.FirstNameEN__c = firstNameEN;
			expo.Telephone__c = telphone;
			expo.Email__c = email;
			expo.WorkTel__c = wordTel;
			expo.QqWechatNumber__c = qqWechatNumber;
			expo.Fax__c = fax;
			expo.Duty__c = duty;
			expo.Department__c = department;
			expo.Address__c = address;
			expo.Url__c = url;
			expo.CompanyCN__c = companyCN;
			expo.CompanyEN__c = companyEN;
			expo.Is_Present__c = isPresent;
			expo.AgreeStored__c = true;
			expo.AgreePrivatePolicy__c = true;

			expo.ExpoTitleEN__c = expoInfo.TitleEN__c;
			expo.ExpoTitleCN__c = expoInfo.TitleCN__c;

			INSERT expo;

			returnData.recordId = expo.Id;

			expo = [SELECT ReceptionUserInfo__c FROM ExpoApplyInfo__c WHERE Id =:expo.Id];
			if(String.isNotBlank(expo.ReceptionUserInfo__c)) {
				// for(String item : expo.ReceptionUserInfo__c.split('-')) {
				// 	returnData.message += item + '\n';
				// }

				// List<String> personInfo = expo.ReceptionUserInfo__c.split('-');
				// returnData.message = '姓名：' + personInfo[0] + '; 联系电话: ' + personInfo[1] + '; 邮箱: ' + personInfo[2];

				List<Map<String, String>> infoMapList = (List<Map<String, String>>)JSON.deserialize(expo.ReceptionUserInfo__c, List<Map<String, String>>.class);
				Integer index = 1;
				for(Map<String, String> infoMap : infoMapList) {
					returnData.message += '接待人员' + index + '\n';
					for(String key : infoMap.keyset()) {
						returnData.message += key + ': ' + infoMap.get(key) + '\n';
					}
					returnData.message += '\n';
					index += 1;
				}
			}

			queryOwnerInfo(expoId);



		}
		catch (Exception e) {
			returnData.isSuccess = false;
			returnData.message = e.getMessage()+e.getCause();
		}

		return returnData;
		
		


	}

	public static void queryOwnerInfo(String expoId) {
		CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Custom_Notification'];
		for (ExpoApplyInfo__c item: [SELECT Id, Name, Owner_User5__r.Name, Owner_User1__r.Name, Owner_User2__r.Name, Owner_User3__r.Name, Owner_User4__r.Name,
			Owner_User5__c, Owner_User1__c, Owner_User2__c, Owner_User3__c, Owner_User4__c,CreatedById  
			FROM ExpoApplyInfo__c WHERE Id =: expoId]) {
			String currentSysLang = UserInfo.getLanguage();
			String userOnwerName1 = item.Owner_User1__c != NULL ? item.Owner_User1__r.Name : ' ';
			String userOnwerName2 = item.Owner_User2__c != NULL ? item.Owner_User2__r.Name : ' ';
			String userOnwerName3 = item.Owner_User3__c != NULL ? item.Owner_User3__r.Name : ' ';
			String userOnwerName4 = item.Owner_User4__c != NULL ? item.Owner_User4__r.Name : ' ';
			String userOnwerName5 = item.Owner_User5__c != NULL ? item.Owner_User5__r.Name : ' ';
			String userOnwerName = userOnwerName1 + ' '+userOnwerName2 + ' '+userOnwerName3 + ' '+userOnwerName4 + ' '+userOnwerName5 + ' ';
			String titleStr = '负责人已分配！';
			if (!String.isBlank(userOnwerName)) {
			    notifyUsers(notificationType, new Set<String>{item.CreatedById}, item.Id, titleStr, '负责人分别为：'+userOnwerName);
			}
		}
	}

	//自定义通知
    public static void notifyUsers(CustomNotificationType notificationType, Set<String> recipientsIds, String targetId, String titleStr, String bodyStr) {

        
        System.debug('userid--->'+recipientsIds);
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(titleStr);
        notification.setBody(bodyStr);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getLineNumber()+e.getMessage());
        }
    }


	// 获取展会信息
	@AuraEnabled 
	public static ConResponse getExhibitionOptions() {
		ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

		List<Map<String, String>> exhibitionOptions = new List<Map<String, String>>();
		List<ExpoInfo__c> exhibitionList = [SELECT Id, Name, StartDate__c, EndDate__c
													FROM ExpoInfo__c 
													WHERE StartDate__c <= TODAY AND EndDate__c >= TODAY ORDER BY Name];
		for(ExpoInfo__c item : exhibitionList) {
			exhibitionOptions.add(new Map<String, String>{
                'label' => item.Name,
                'value' => item.Id
            });
		}
		mso.put('exhibitionOptions', exhibitionOptions);
		mso.put('fields', SObjectHelper.getFieldLabelMap('ExpoApplyInfo__c'));

		List<ExpoCountrysBazaar__c> countryInfoList = [SELECT Id, Name, NameEN__c, Region__c FROM ExpoCountrysBazaar__c];
		Map<String, List<Map<String, String>>> countryListMap = new Map<String, List<Map<String, String>>>();
		for(ExpoCountrysBazaar__c country : countryInfoList) {
			if(countryListMap.containsKey(country.Region__c)) {
				countryListMap.get(country.Region__c).add(new Map<String, String>{
					'label' => country.Name,
                	'value' => country.Name
				});
			} else {
				countryListMap.put(country.Region__c, new List<Map<String, String>>{ 
					new Map<String, String>{
						'label' => country.Name,
                		'value' => country.Name
					}
				});
			}
		}
		mso.put('countryListMap', countryListMap);
		return resp;
	}


    public class ReturnData{
    	@AuraEnabled 
    	public Boolean isSuccess;
    	@AuraEnabled 
    	public String message;
    	@AuraEnabled 
    	public String recordId;

    	public ReturnData() {
    		this.isSuccess = true;
    		this.message = '';
    		this.recordId = '';
    	}

    }
}