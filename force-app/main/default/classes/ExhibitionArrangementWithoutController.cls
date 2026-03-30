public without sharing class ExhibitionArrangementWithoutController {
    @AuraEnabled
    public static ConResponse selExhibitionArrangementId(String name,String email,String exhibitionArrId) {
        System.debug('name:'+name);
        System.debug('email:'+email);
        System.debug('exhibitionArrId:'+exhibitionArrId);
        ConResponse resp = new ConResponse();
        try {

            String splitStr = name.split('/')[0].trim();
            List<Internal_Registration__c> intList = [SELECT Id, Name_CN__c, Email__c,
                                            Exhibition_Id__c,Exhibition_Id__r.Name   
                                            FROM Internal_Registration__c
                                            WHERE Name_CN__c =: splitStr AND Email__c =: email];
        
            System.debug('intList:'+intList);
            if (intList.size()>0) {
                Set<String> intIds = new Set<String>();
                for (Internal_Registration__c inRe : intList) {
                    intIds.add(inRe.Id);
                }
                Map<String, String> mso = new Map<String, String>();
                resp.data = mso;
                List<Exhibition_Arrangement__c> exhibArrList = [SELECT Id, Internal_Registration__c, Exhibition_Management__r.Name
                                            FROM Exhibition_Arrangement__c
                                            WHERE Internal_Registration__c IN: intIds 
                                            AND Id =: exhibitionArrId];
                if (exhibArrList.size()==1) {
                    mso.put('exhibitionArrangementId',exhibArrList[0].Id);
                    mso.put('exhibitionName',exhibArrList[0].Exhibition_Management__r.Name);
                    mso.put('internalRegistrationId', exhibArrList[0].Internal_Registration__c);

                    return getInitData(exhibArrList[0].Id);
                }else{
                    resp.code = -1;
                    resp.message = '行程信息不存在！';
                }
                
            }else{
                resp.code = -1;
                resp.message = '登录数据不存在！';
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse saveExhibitionArrangement(String jsonStr) {
        System.debug('jsonStr--=='+jsonStr);
        ConResponse resp = new ConResponse();
        try {
            Exhibition_Arrangement__c exhibArrList = (Exhibition_Arrangement__c)JSON.deserialize(jsonStr, Exhibition_Arrangement__c.class);
            System.debug('exhibArrList : '+exhibArrList);
            
            update exhibArrList;
            sendEmail(exhibArrList.Id);

            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId) {

        ConResponse resp = new ConResponse();
        try{
            Map<String, Object> mso = new Map<String, Object>();
            List<Exhibition_Arrangement__c> recordList = [SELECT Exhibition_Hotel__c, Exhibition_Management__r.LastRegistrationDate__c,
            Designated_Hotel__c, Exhibition_Management__c, Exhibition_Management__r.Name, Exhibition_Management__r.StartDate__c, Exhibition_Management__r.EndDate__c,
            Inbound_Flight_No__c,Return_Flight_No__c,Arrival_Date__c,Return_Date__c,Hotel_Name__c,Hotel_End_Date__c,Hotel_Start_Date__c,
            Is_Not_Flight__c, Is_Not_Need_Vehicle__c, Is_Not_Vehicle__c, PresenceDate__c, Internal_Registration__c
                                                        FROM Exhibition_Arrangement__c 
                                                        WHERE Id =: recordId];
            if(recordList.size() > 0) {
                Exhibition_Arrangement__c record = recordList[0];
                mso.put('isOverLastRegistrationDate', true);
                if (record.Exhibition_Management__r.LastRegistrationDate__c != NULL) 
                    mso.put('isOverLastRegistrationDate', Date.today()<=record.Exhibition_Management__r.LastRegistrationDate__c ? false : true);

                // mso.put('isDesignated', record.Designated_Hotel__c);
                // mso.put('Inbound_Flight_No__c',record.Inbound_Flight_No__c);
                // mso.put('Return_Flight_No__c',record.Return_Flight_No__c);
                // mso.put('Arrival_Date__c',record.Arrival_Date__c);
                // mso.put('Return_Date__c',record.Return_Date__c);
                // mso.put('Hotel_Name__c',record.Hotel_Name__c);
                // mso.put('Hotel_Start_Date__c',record.Hotel_Start_Date__c);
                // mso.put('Hotel_End_Date__c',record.Hotel_End_Date__c);
                // mso.put('Exhibition_Hotel__c', record.Exhibition_Hotel__c);

                // mso.put('isNotFlight', record.Is_Not_Flight__c);
                // mso.put('isNotNeedVehicle', record.Is_Not_Need_Vehicle__c);

                String managementId = record.Exhibition_Management__c;
                List<Exhibition_Hotel__c> allHotelList = [SELECT Id, Name
                                                                    FROM Exhibition_Hotel__c 
                                                                    WHERE Exhibition_Management__c =: managementId ORDER BY Name];

                List<Map<String, String>> hotelInfoMapList = new List<Map<String, String>>();
                for(Exhibition_Hotel__c item : allHotelList) {
                    hotelInfoMapList.add(new Map<String, String> {
                        'label' => item.Name,
                        'value' => item.Id
                    });
                }
                mso.put('options', hotelInfoMapList);

                Date startDate = record.Exhibition_Management__r.StartDate__c;
                Date endDate = record.Exhibition_Management__r.EndDate__c;
                // List<Map<String, String>> presenceOptions = new List<Map<String, String>>();
                // Date presenceStartDate = startDate;
                // Date presenceEndDate = endDate;
                // if((record.Arrival_Date__c != null) && (presenceStartDate < record.Arrival_Date__c)) {
                //     presenceStartDate = record.Arrival_Date__c;
                // } 
                // if((record.Hotel_Start_Date__c != null) && presenceStartDate < record.Hotel_Start_Date__c) {
                //     presenceStartDate = record.Hotel_Start_Date__c;
                // }

                // if((record.Return_Date__c != null) && (presenceEndDate > record.Return_Date__c)) {
                //     presenceEndDate = record.Return_Date__c;
                // } 
                // if((record.Hotel_End_Date__c != null) && presenceEndDate > record.Hotel_End_Date__c) {
                //     presenceEndDate = record.Hotel_End_Date__c;
                // }

                // Boolean isNewRecord = false;
                // if((!record.Is_Not_Flight__c && (record.Inbound_Flight_No__c == null)) || 
                //     (!record.Designated_Hotel__c && (record.Hotel_Start_Date__c == null)) || 
                //     (!record.Is_Not_Need_Vehicle__c && record.Is_Not_Vehicle__c)) {
                //     isNewRecord = true;
                //     record.PresenceInformation__c = '';
                // }
                // for(Date indexDate = presenceStartDate ; indexDate <= presenceEndDate;) {
                //     presenceOptions.add(new Map<String, String> {
                //         'label' => indexDate.format(),
                //         'value' => indexDate.format()
                //     });
                //     if(isNewRecord) {
                //         record.PresenceInformation__c += indexDate + ',';
                //     }
                //     indexDate=indexDate.addDays(1);
                // }
                // mso.put('presenceOptions', presenceOptions);

                mso.put('startDate', startDate);
                mso.put('endDate', endDate);
                mso.put('recordInfo', record);

                mso.put('datas', getExhibionVeBooking(record.Internal_Registration__c, record.Id));

                mso.put('exhibitionArrangementId', record.Id);
                mso.put('exhibitionName', record.Exhibition_Management__r.Name);
                mso.put('internalRegistrationId', record.Internal_Registration__c);

                resp.data = mso;
            } else {
                resp.code = -1;
                resp.message = 'no hotel';
            }
            }catch(Exception e) {
                resp.code = -1;
                resp.message = e.getMessage() + '\n' + e.getStackTraceString();
            }
            
            return resp;

    }

    //插入
    @AuraEnabled(cacheable=false)
    public static ConResponse createdRecord(String intId, String arrId, String carType, Date carDate) {
        ConResponse resp = new ConResponse();
        try {
            if (carDate < Date.today()) {
                resp.code = -1;
                resp.message = '用车时间不小于当前时间！';
                return resp;
            }
            Exhibition_Vehical_Booking__c evb = new Exhibition_Vehical_Booking__c(
                Exhibition_Arrangement__c = (Id)arrId,
                Internal_Registration__c = (Id)intId,
                Vehicle_Type__c = carType,
                Date__c = (Date)carDate
                );
            INSERT evb;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    //删除
    @AuraEnabled(cacheable=false)
    public static ConResponse delRecord(List<String> bookIdList) {
        ConResponse resp = new ConResponse();
        try {
            Database.delete((List<Id>)bookIdList);
          // Database.delete((Id)bookId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    //Upsert
    @AuraEnabled(cacheable=false)
    public static ConResponse upsertRecords(String jsonStr, String intId, String arrId) {
        ConResponse resp = new ConResponse();
        try {
            List<Exhibition_Vehical_Booking__c> exhibArrList = (List<Exhibition_Vehical_Booking__c>)JSON.deserialize(jsonStr,List<Exhibition_Vehical_Booking__c>.class);
            List<Exhibition_Vehical_Booking__c> upsertList = new List<Exhibition_Vehical_Booking__c>();
            for (Exhibition_Vehical_Booking__c item: exhibArrList) {
                String idStr = (String)item.Id;
                if (idStr.length() != 18 ) {
                   Exhibition_Vehical_Booking__c newItem = new Exhibition_Vehical_Booking__c(
                    Exhibition_Arrangement__c = (Id)arrId,
                    Internal_Registration__c = (Id)intId,
                    Vehicle_Type__c = item.Vehicle_Type__c,
                    Date__c = (Date)item.Date__c
                    );
                   upsertList.add(newItem);
                }else{
                    upsertList.add(item);
                }
                
                
            }
            Database.upsert(upsertList, Exhibition_Vehical_Booking__c.Id);
          // Database.delete((Id)bookId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            String a = ''+e.getMessage();
            // a.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            // if () {
                
            // }
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    //删除还未被安排的车辆信息
    @AuraEnabled(cacheable=false)
    public static ConResponse delVehicalBookingExpectArranged(String exhibitionArrangementId, String internalRegistrationId) {
        ConResponse resp = new ConResponse();
        try {
            List<Exhibition_Vehical_Booking__c> evbIdList = new  List<Exhibition_Vehical_Booking__c>();
            for (Exhibition_Vehical_Booking__c item: [SELECT Id FROM Exhibition_Vehical_Booking__c 
                WHERE Exhibition_Arrangement__c =:exhibitionArrangementId 
                AND  Internal_Registration__c =: internalRegistrationId
                AND Is_Arranged__c = FALSE]) {
                evbIdList.add(item);
            }
            if (!evbIdList.isEmpty()) Database.delete(evbIdList);
            System.debug('Ethan=========='+evbIdList);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            String a = ''+e.getMessage();
            // a.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            // if () {
                
            // }
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    public static void sendEmail(Id exhibitionArrangementId){
        String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0] + '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';
        String aurl = SITE_URL_FRO+exhibitionArrangementId;

        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Exhibition_Arrangement_Has_Submited' LIMIT 1];
        // System.Url.getOrgDomainUrl().toExternalForm()
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();

        List<Exhibition_Arrangement__c> exhibArrList = [SELECT Id, Internal_Registration__r.Name_CN__c, Internal_Registration__r.Name_EN__c, Internal_Registration__r.Email__c,Is_Not_Vehicle__c,
            (SELECT Id, Vehicle_Type__c, Date__c, Plate_Number__c, Vehical_Driver__c, Pick_Up_Point__c,Is_Arranged__c FROM Vehical_Bookings__r)
                                            FROM Exhibition_Arrangement__c
                                            WHERE Id =: exhibitionArrangementId];
        if (exhibArrList.size() > 0) {
            //判断是否填写了车辆信息
            Boolean isNotVehicle = true;
           if (!exhibArrList[0].Vehical_Bookings__r.isEmpty()) {
               isNotVehicle = false;
           }
           exhibArrList[0].Is_Not_Vehicle__c = isNotVehicle;
           UPDATE exhibArrList[0];

            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            String toName = exhibArrList[0].Internal_Registration__r.Name_CN__c;
            String toEmail = exhibArrList[0].Internal_Registration__r.Email__c;
                // String vehicleInfo = '';
                // if (item.Vehicle_Type__c != NULL) vehicleInfo+=('<li>车辆类型：'+item.Vehicle_Type__c + '</li>'); 
                // if (item.Date__c != NULL && item.Departure_Time_Invsion__c != NULL) vehicleInfo+=('<li>发车时间：'+item.Date__c.year()+'-'+item.Date__c.month()+'-'+item.Date__c.day()+' '+item.Departure_Time_Invsion__c+ '</li>');
                // if (item.Plate_Number__c != NULL) vehicleInfo+=('<li>车牌号：'+item.Plate_Number__c + '</li>');
                // if (item.Vehical_Driver__c != NULL) vehicleInfo+=('<li>司机：'+item.Vehical_Driver__c + '</li>');
                // if (item.Pick_Up_Point__c != NULL) vehicleInfo+=('<li>上车地点：'+item.Pick_Up_Point__c + '</li>')
            // System.Label.Exhibition_Vehical_Tip
            String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, aurl});
            System.debug(bodyFormat);

            singleEmail.setTemplateId(emtemp.Id);
            singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
            singleEmail.setSubject(emtemp.Subject);
            singleEmail.setHtmlBody(bodyFormat);
            singleEmail.setToAddresses(new List<String>{toEmail});
            sendEmailList.add(singleEmail);
        }

    
        if (sendEmailList.size() > 0) {
            System.debug('------------>ready send ! ');
            try {
                Messaging.sendEmail(sendEmailList);
            }
            catch (Exception e) {
                System.debug('ExhibitionArrangementWithoutController.sendEmail->'+e.getLineNumber()+e.getMessage());
            }
        }

    }


    @AuraEnabled(cacheable=false)
    public static List<Exhibition_Vehical_Booking__c> getExhibionVeBooking(String intId, String arrId) {
        return [
            SELECT Id, Vehicle_Type__c, Date__c, Plate_Number__c, Pick_Up_Point__c, Is_Arranged__c, Vehical_Driver__c, Departure_Time__c,Departure_Time_Invsion__c
            FROM Exhibition_Vehical_Booking__c
            WHERE Exhibition_Arrangement__c =:arrId
            AND Internal_Registration__c =:intId
            // AND Is_Arranged__c = true
            ORDER BY Is_Arranged__c DESC,Date__c ASC
        ];
    }

    @AuraEnabled(cacheable=false)
    public static List<Exhibition_Vehical_Booking__c> getExhibionVeBookingNotArranged(String intId, String arrId) {
        return [
            SELECT Id, Vehicle_Type__c, Date__c, Plate_Number__c, Pick_Up_Point__c, Is_Arranged__c, Vehical_Driver__c, Departure_Time__c, Departure_Time_Invsion__c
            FROM Exhibition_Vehical_Booking__c
            WHERE Exhibition_Arrangement__c =:arrId
            AND Internal_Registration__c =:intId
            AND Is_Arranged__c = FALSE
            ORDER BY Date__c
        ];
    }

}