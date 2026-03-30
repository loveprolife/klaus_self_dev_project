public without sharing class ExhibitionArrangementTriggerHelper {

	private static String formatDate(Date dt) {
        return DateTime.newInstance(dt.year(), dt.month(), dt.day(), 0 , 0, 0).format('yyyy-MM-dd');
    }
    

	/**
     * @description 行程信息自动关联到展会
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
	public static void relateExhibiton(List<Exhibition_Arrangement__c> newList) {
		List<Id> irIdList = new LisqContainer(newList).SelectSField('Internal_Registration__c');
		Map<Id, Internal_Registration__c> idIrSobjectMap = new Map<Id, Internal_Registration__c>(
			[SELECT Id, Exhibition_Id__c, Exhibition_Id__r.StartDate__c, Exhibition_Id__r.EndDate__c FROM Internal_Registration__c WHERE Id IN: irIdList]);
		for (Exhibition_Arrangement__c ea: newList) {
			ea.Exhibition_Management__c = idIrSobjectMap.get(ea.Internal_Registration__c) != NULL ? idIrSobjectMap.get(ea.Internal_Registration__c).Exhibition_Id__c : NULL;
			if(idIrSobjectMap.containsKey(ea.Internal_Registration__c) && String.isNotBlank(ea.PresenceDate__c)) {
                Date startd = idIrSobjectMap.get(ea.Internal_Registration__c).Exhibition_Id__r.StartDate__c;
                Date endd = idIrSobjectMap.get(ea.Internal_Registration__c).Exhibition_Id__r.EndDate__c;
                String[] ds = new String[]{};
                try{
                    ds = ea.PresenceDate__c.split(';');
                    List<String> dates = new List<String>();
                    for(String d : ds) {
                        if(!String.isBlank(d)) {
                            Date dt1 = Date.valueOf(startd.year() + '-' + d);
                            Date dt2 = Date.valueOf(endd.year() + '-' + d);
                            if(dt1 >= startd && dt1 <= endd) {
                                dates.add(formatDate(dt1));
                            }
                            else if(dt2 >= startd && dt2 <= endd) {
                                dates.add(formatDate(dt2));
                            } else {
                                ea.addError(d + ' is out of range ' + startd.format() + '~' + endd.format());
                            }
                        }
                    }
                    // ea.PresenceInformation__c = String.join(dates, ',');
                }catch(Exception e){
                    ea.addError(e.getMessage());
                }
            }
		}
	}
    

	/**
     * @description 行程信息有变更 通知创建人
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
   	public static void sendEmail(List<Exhibition_Arrangement__c> newList, List<Exhibition_Arrangement__c> oldList){
		Map<Id, Exhibition_Arrangement__c> oldMap = new Map<Id, Exhibition_Arrangement__c>(oldList);

		EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
			FROM EmailTemplate
			WHERE DeveloperName = 'Exhibition_Arrangement_Change' LIMIT 1];
		EmailTemplate tempOfSMS = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
									FROM EmailTemplate
									WHERE DeveloperName = 'Exhibition_Arrangement_Change_SMS' LIMIT 1];
		// System.Url.getOrgDomainUrl().toExternalForm()
		List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();       
		//20240901注释掉SMS推送
		// Map<String, List<String>> personInfoMap = new Map<String, List<String>>();
		for (Exhibition_Arrangement__c item : newList) {//是否和旧的做对比 TODO 旧的用Map
				Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();

				String toEmail = item.Creator_Email__c;
				String aurl = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Exhibition_Arrangement__c/'+item.Id+'/view';
				String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{'您所创建的行程信息有变更！', aurl});

				// String toName = item.Name_CN__c != NULL ? item.Name_CN__c : item.Name_EN__c;
				// String strDate = String.valueOf(exhiMap.get(item.Exhibition_Id__c).StartDate__c);
				// String exhiName = exhiMap.get(item.Exhibition_Id__c).TitleCN__c;
				// String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, strDate, exhiName});
				// singleEmail.setCcAddresses(item.Email__c);
				// singleEmail.setHtmlBody(bodyFormat);
				System.debug('emailstr-->'+bodyFormat);
				singleEmail.setSaveAsActivity(false);
				singleEmail.setTemplateId(emtemp.Id);
				//设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
				singleEmail.setSubject(emtemp.Subject + '');
				singleEmail.setHtmlBody(bodyFormat);
				singleEmail.setToAddresses(new List<String>{toEmail});
				sendEmailList.add(singleEmail);

				// 短信
				String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0] + '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id='+item.Id;
				//20240901注释掉SMS推送
				// String bodyFormatSMS = String.format(tempOfSMS.Body, new List<String>{ SITE_URL_FRO});
				
				// List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplateBodyRes = Messaging.renderEmailTemplate(tempOfSMS.Id, item.Id, new List<String>{tempOfSMS.Body});
				
				//20240901注释掉SMS推送
				// if(personInfoMap.containskey(item.UserPhone__c)) {
				// 	personInfoMap.get(item.UserPhone__c).add(bodyFormatSMS);
				// } else {
				// 	personInfoMap.put(item.UserPhone__c, new List<String>{bodyFormatSMS});
				// }
		}

		if (sendEmailList.size() > 0) {
			System.debug('------------>ready send ! ');
			try {
				Messaging.sendEmail(sendEmailList);
			}
			catch (Exception e) {

			}

		}
		//20240901注释掉SMS推送
		// if(personInfoMap.keyset().size() > 0) {
        //     ExpoApplyInfoTriggerHanderHelper.sendMessage(Json.serialize(personInfoMap));
        // }
	}
}