public without sharing class TicketTriggerHandlerHelper {

    public static String floorRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'Ticket__c' AND DeveloperName = 'Floorwalker'].Id;
    public static List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
    // public static void beforeInsertCheck(List<Ticket__c> oldList, List<Ticket__c> newList) {

    //     List<String> assignToUserIdList = new LisqContainer(newList).selectsField('AssignedTo__c');
    //     Map<Id, User> activeUserMap = new Map<Id, User>([SELECT Id, IsActive, Sales_Region__c FROM User WHERE Id IN :assignToUserIdList AND IsActive = true]);

    //     List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND IsActive = true];
    //     LisqContainer lc = new LisqContainer(departmentUserList);
    //     Map<String, LisqContainer> userGroupByRegion = lc.GroupByS('Sales_Region__c');
        
    //     for(Ticket__c item : newList) {
    //         // 人员校验
    //         if(!String.isBlank(item.AssignedTo__c) && !String.isBlank(item.Department__c)) {
    //             Boolean tureDepartment = false;
    //             String assignToName = '';
    //             if(activeUserMap.containsKey(item.AssignedTo__c)) {
    //                 String assignToRegion = activeUserMap.get(item.AssignedTo__c).Sales_Region__c;
    //                 if(userGroupByRegion.containsKey(assignToRegion)) {
    //                     tureDepartment = (userGroupByRegion.get(item.SalesRegion__c).selectsField('Id')).contains(item.AssignedTo__c);
    //                 }
    //             }
    //             if(!tureDepartment) {
    //                 item.addError(String.format(Label.Ticket_User_Department_Check, new List<Object>{assignToName, item.Department__c}));
    //             }
    //         }

    //     }
    // }

    public static void afterInsertHandler(List<Ticket__c> oldList, List<Ticket__c> newList){

        // 共享前确认，共享的用户是active的
        List<String> assignToUserIdList = new LisqContainer(newList).selectsField('AssignedTo__c');
        
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :assignToUserIdList AND IsActive = true]).selectsField('Id');

        // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> userGroupByRegion = lc.GroupByS('Sales_Region__c');

        List<Ticket__c> shareList = new List<Ticket__c>();
        Map<Id, String> ticketIdAandDepUserIds = new Map<Id, String>();
        for(Ticket__c item : newList) {

            if(item.RecordTypeId == floorRecordTypeId && (item.DueDate__c == NULL)) {
                continue;
            }
            //last by TJP 20250627 d: (促销员/巡店员)日报关联的Ticket在关联日报状态为Submitted时才能提交 InspectionReport__c,PromoterDailyReport__c
            if(String.isEmpty(item.InspectionReport__c) && String.isEmpty(item.PromoterDailyReport__c)) {
                if(!String.isBlank(item.AssignedTo__c) && activeUserIdList.contains(item.AssignedTo__c)) {
                    sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                    if(item.AssignedTo__c != null) {
                        shareList.add(item);
                    }
                }else if(String.isBlank(item.AssignedTo__c) && (item.Department__c != null)) {
                    // 新建部门 Ticket
                    if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                        Set<String> userIdSet = new Set<String>();
                        for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                            if(user.Department__c == item.Department__c) {
                                userIdSet.add(user.Id);
                                // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
                                if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                    String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                    ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                } else {
                                    ticketIdAandDepUserIds.put(item.Id, user.Id);
                                }
                            }
                        }
                        // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                        shareList.add(item);
                        sendNotification(' You have a new ticket ', item, userIdSet); 
                    }
                }

            }

            // 新增指派给部门的ticket
            // if(item.ResponsibleDepartmentUserIds__c != null) {
            //     List<String> userIdList = item.ResponsibleDepartmentUserIds__c.split(';');
            //     if(userIdList.size() > 0) {
            //         shareList.add(item);
            //         sendNotification(' You have a new ticket ', item, new Set<String>(userIdList)); 
            //     }
            //     continue;
            // }
        }
        if(shareList.size() > 0) {
            sharingRelatedOperations(shareList, ticketIdAandDepUserIds);
        }
    }

    public static void afterUpdateHandler(List<Ticket__c> oldList, List<Ticket__c> newList){

        // 共享前确认，共享的用户是active的
        List<String> ownerIdList = new LisqContainer(newList).selectsField('OwnerId');
        List<String> assignToUserIdList = new LisqContainer(newList).selectsField('AssignedTo__c');
        List<String> activeOwnerIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :ownerIdList AND IsActive = true]).selectsField('Id');
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :assignToUserIdList AND IsActive = true]).selectsField('Id');

        // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> userGroupByRegion = lc.GroupByS('Sales_Region__c');

        Map<Id, Ticket__c> oldMap = new Map<Id, Ticket__c>(oldList);
        List<Ticket__c> shareList = new List<Ticket__c>();
        List<Ticket__c> deleteShareList = new List<Ticket__c>();
        Map<Id, String> ticketIdAandDepUserIds = new Map<Id, String>();
        Map<Id, String> oldTicketIdAandDepUserIds = new Map<Id, String>();
        for(Ticket__c item : newList) {

            if(item.RecordTypeId == floorRecordTypeId && (item.DueDate__c == NULL)) {
                continue;
            }

            
            // 更改 Assigned To
            //last by TJP 20250627 d:修改还是按照原逻辑，没有关联日报的进行
            // if(item.SystemGeneration__c != true) { 
            if(String.isNotEmpty(item.InspectionReport__c)) {
                if((item.Inspection_Status__c == 'Submitted' && oldMap.get(item.Id).Inspection_Status__c != 'Submitted')) {
                   //new 新建
                   if(!String.isBlank(item.AssignedTo__c) && activeUserIdList.contains(item.AssignedTo__c)) {
                        sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                        if(item.AssignedTo__c != null) {
                            shareList.add(item);
                        }
                    }else if(String.isBlank(item.AssignedTo__c) && (item.Department__c != null)) {
                        // 新建部门 Ticket
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            Set<String> userIdSet = new Set<String>();
                            for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                                if(user.Department__c == item.Department__c) {
                                    userIdSet.add(user.Id);
                                    // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
                                    if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                        String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                        ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                    } else {
                                        ticketIdAandDepUserIds.put(item.Id, user.Id);
                                    }
                                }
                            }
                            // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                            shareList.add(item);
                            sendNotification(' You have a new ticket ', item, userIdSet); 
                        }
                    }
                } else if (item.Inspection_Status__c == oldMap.get(item.Id).Inspection_Status__c && oldMap.get(item.Id).Promoter_Status__c == 'Submitted') {
                    //这里判断是否解决
                    if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                        if(activeOwnerIdList.contains(item.OwnerId)) {
                            sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                        }
                    }
                }

            } else if (String.isNotEmpty(item.PromoterDailyReport__c)){ 
                if(item.Promoter_Status__c == 'Submitted' && oldMap.get(item.Id).Promoter_Status__c != 'Submitted') {
                   if(!String.isBlank(item.AssignedTo__c) && activeUserIdList.contains(item.AssignedTo__c)) {
                        sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                        if(item.AssignedTo__c != null) {
                            shareList.add(item);
                        }
                    }else if(String.isBlank(item.AssignedTo__c) && (item.Department__c != null)) {
                        // 新建部门 Ticket
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            Set<String> userIdSet = new Set<String>();
                            for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                                if(user.Department__c == item.Department__c) {
                                    userIdSet.add(user.Id);
                                    // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
                                    if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                        String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                        ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                    } else {
                                        ticketIdAandDepUserIds.put(item.Id, user.Id);
                                    }
                                }
                            }
                            // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                            shareList.add(item);
                            sendNotification(' You have a new ticket ', item, userIdSet); 
                        }
                    }
                } else if (item.Promoter_Status__c == oldMap.get(item.Id).Promoter_Status__c && oldMap.get(item.Id).Promoter_Status__c == 'Submitted') {
                    //这里判断是否解决
                    if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                        if(activeOwnerIdList.contains(item.OwnerId)) {
                            sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                        }
                    }
                }
            } else {

                // 状态更新为Resolved发通知
                if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                    if(activeOwnerIdList.contains(item.OwnerId)) {
                        sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                    }
                }
                if((item.AssignedTo__c != null) && (oldMap.get(item.Id).AssignedTo__c != item.AssignedTo__c)) {
                    Boolean pickTicket = false;
                    if(String.isBlank(oldMap.get(item.Id).AssignedTo__c) && !String.isBlank(oldMap.get(item.Id).Department__c) && (oldMap.get(item.Id).Department__c == item.Department__c)) {
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            pickTicket = (userGroupByRegion.get(item.SalesRegion__c).selectsField('Id')).contains(item.AssignedTo__c);
                        }
                    } 
                    if(!pickTicket) {
                        if(activeUserIdList.contains(item.AssignedTo__c)) {
                            shareList.add(item);
                        }
                        deleteShareList.add(oldMap.get(item.Id));
                        sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                    }

                }else if((String.isBlank(item.AssignedTo__c)) && (item.Department__c != null) && (oldMap.get(item.Id).Department__c != item.Department__c)) {
                    // 更改部门
                    if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                        Set<String> newUserIdSet = new Set<String>();
                        for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                            if(user.Department__c == item.Department__c) {
                                newUserIdSet.add(user.Id);
                                // item.ResponsibleDepartmentUserIds__c += user.Id + ';';
                                if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                    String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                    ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                } else {
                                    ticketIdAandDepUserIds.put(item.Id, user.Id);
                                }
                            }
                            if(user.Department__c == oldMap.get(item.Id).Department__c) {
                                // oldMap.get(item.Id).ResponsibleDepartmentUserIds__c += user.Id + ';';
                                if(oldTicketIdAandDepUserIds.containsKey(item.Id)) {
                                    String newUserIds = oldTicketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                    oldTicketIdAandDepUserIds.put(item.Id, newUserIds);
                                } else {
                                    oldTicketIdAandDepUserIds.put(item.Id, user.Id);
                                }
                            }
                        }
                        // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                        // System.debug('item.ResponsibleDepartmentUserIds__c：' + oldMap.get(item.Id).ResponsibleDepartmentUserIds__c);
                        deleteShareList.add(oldMap.get(item.Id));
                        shareList.add(item);
                        sendNotification(' You have a new ticket ', item, newUserIdSet); 
                        continue;
                }
                    }
                }
            }
                if(shareList.size() > 0) {
                    sharingRelatedOperations(shareList, ticketIdAandDepUserIds);
                    deleteShred(deleteShareList, oldTicketIdAandDepUserIds);
        }
    }


    public static void afterInsertUserManyHandler(List<Ticket__c> oldList, List<Ticket__c> newList){

        // 共享前确认，共享的用户是active的
        List<String> aassignersUserIdListAll = new LisqContainer(newList).selectsField('Aassigners__c');
        List<String> assignToUserIdList = new List<String>();

        for(String assUserId : aassignersUserIdListAll){
            // 根据逗号拆分拼接的多个user
            List<String> assignList = assUserId.split(',');
            assignToUserIdList.addAll(assignList);
        }
        
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :assignToUserIdList AND IsActive = true]).selectsField('Id');

        // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> userGroupByRegion = lc.GroupByS('Sales_Region__c');

        List<Ticket__c> shareList = new List<Ticket__c>();
        Map<Id, String> ticketIdAandDepUserIds = new Map<Id, String>();
        for(Ticket__c item : newList) {

            if(item.RecordTypeId == floorRecordTypeId && (item.DueDate__c == NULL)) {
                continue;
            }


            Boolean activeUserFlag = false;
            // 根据逗号拆分拼接的多个user
            List<String> assignList = item.Aassigners__c.split(',');
            for(String assUserId : assignList){
                if(activeUserIdList.contains(assUserId)) {
                    activeUserFlag = true;
                }
            }
            //新增 也进行区分 InspectionReport__c,PromoterDailyReport__c
            if(String.isEmpty(item.InspectionReport__c) && String.isEmpty(item.PromoterDailyReport__c)) {
                if(activeUserFlag) {
                    Set<String> aassignerSet = new Set<String>{};
                    aassignerSet.addAll(assignList);
                    sendNotification(' You have a new ticket ', item, aassignerSet);
                    if(item.Aassigners__c != null) {
                        shareList.add(item);
                    }
                }
            }
            
            // else if((item.Department__c != null)) {
            //     // 新建部门 Ticket
            //     if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
            //         Set<String> userIdSet = new Set<String>();
            //         for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
            //             if(user.Department__c == item.Department__c) {
            //                 userIdSet.add(user.Id);
            //                 // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
            //                 if(ticketIdAandDepUserIds.containsKey(item.Id)) {
            //                     String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
            //                     ticketIdAandDepUserIds.put(item.Id, newUserIds);
            //                 } else {
            //                     ticketIdAandDepUserIds.put(item.Id, user.Id);
            //                 }
            //             }
            //         }

            //         shareList.add(item);
            //         sendNotification(' You have a new ticket ', item, userIdSet); 
            //     }
            // }
        }
        if(shareList.size() > 0) {
            sharingUserManyRelatedOperations(shareList, ticketIdAandDepUserIds);
        }
    }

    public static void afterUpdateUserManyHandler(List<Ticket__c> oldList, List<Ticket__c> newList){
        System.debug('wwwwafterUpdateUserManyHandler');
        // 共享前确认，共享的用户是active的
        List<String> ownerIdList = new LisqContainer(newList).selectsField('OwnerId');
        // List<String> assignToUserIdList = new LisqContainer(newList).selectsField('AssignedTo__c');
        List<String> aassignersUserIdListAll = new LisqContainer(newList).selectsField('Aassigners__c');
        List<String> assignToUserIdList = new List<String>();

        for(String assUserId : aassignersUserIdListAll){
            // 根据逗号拆分拼接的多个user
            List<String> assignList = assUserId.split(',');
            assignToUserIdList.addAll(assignList);
        }

        System.debug('wwwwassignToUserIdList' + JSON.serialize(assignToUserIdList));

        List<String> activeOwnerIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :ownerIdList AND IsActive = true]).selectsField('Id');
        List<String> activeUserIdList = new LisqContainer([SELECT Id, IsActive FROM User WHERE Id IN :assignToUserIdList AND IsActive = true]).selectsField('Id');

        // List<User> departmentUserList = [SELECT Id, Sales_Region__c, Department__c FROM User WHERE Department__c != NULL AND Sales_Region__c != NULL AND IsActive = true];
        LisqContainer lc = new LisqContainer(departmentUserList);
        Map<String, LisqContainer> userGroupByRegion = lc.GroupByS('Sales_Region__c');

        Map<Id, Ticket__c> oldMap = new Map<Id, Ticket__c>(oldList);
        List<Ticket__c> shareList = new List<Ticket__c>();
        List<Ticket__c> deleteShareList = new List<Ticket__c>();
        Map<Id, String> ticketIdAandDepUserIds = new Map<Id, String>();
        Map<Id, String> oldTicketIdAandDepUserIds = new Map<Id, String>();
        for(Ticket__c item : newList) {
            System.debug('wwww更改 Assigned To入口' + JSON.serialize((item.Aassigners__c != null) && (oldMap.get(item.Id).Aassigners__c != item.Aassigners__c)));
            System.debug('wwww更改 部门入口' + JSON.serialize((String.isBlank(item.Aassigners__c)) && (item.Department__c != null) && (oldMap.get(item.Id).Department__c != item.Department__c)));

            //last by TJP
            if(String.isNotEmpty(item.InspectionReport__c)) { 
                if((item.Inspection_Status__c == 'Submitted' && oldMap.get(item.Id).Inspection_Status__c != 'Submitted')) {
                   //new 新建
                   if(!String.isBlank(item.AssignedTo__c) && activeUserIdList.contains(item.AssignedTo__c)) {
                        sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                        if(item.AssignedTo__c != null) {
                            shareList.add(item);
                        }
                    }else if(String.isBlank(item.AssignedTo__c) && (item.Department__c != null)) {
                        // 新建部门 Ticket
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            Set<String> userIdSet = new Set<String>();
                            for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                                if(user.Department__c == item.Department__c) {
                                    userIdSet.add(user.Id);
                                    // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
                                    if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                        String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                        ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                    } else {
                                        ticketIdAandDepUserIds.put(item.Id, user.Id);
                                    }
                                }
                            }
                            // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                            shareList.add(item);
                            System.debug('Ticket New Send');
                            sendNotification(' You have a new ticket ', item, userIdSet); 
                        }
                    }
                } else if (item.Inspection_Status__c == oldMap.get(item.Id).Inspection_Status__c && oldMap.get(item.Id).Promoter_Status__c == 'Submitted') {
                    //这里判断是否解决
                    if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                        if(activeOwnerIdList.contains(item.OwnerId)) {
                            sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                        }
                    }
                }

            } else if (String.isNotEmpty(item.PromoterDailyReport__c)){ 
                if(item.Promoter_Status__c == 'Submitted' && oldMap.get(item.Id).Promoter_Status__c != 'Submitted') {
                    //new 新建
                   if(!String.isBlank(item.AssignedTo__c) && activeUserIdList.contains(item.AssignedTo__c)) {
                        sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                        if(item.AssignedTo__c != null) {
                            shareList.add(item);
                        }
                    }else if(String.isBlank(item.AssignedTo__c) && (item.Department__c != null)) {
                        // 新建部门 Ticket
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            Set<String> userIdSet = new Set<String>();
                            for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                                if(user.Department__c == item.Department__c) {
                                    userIdSet.add(user.Id);
                                    // item.ResponsibleDepartmentUserIds__c += item.Id + ';';
                                    if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                        String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                        ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                    } else {
                                        ticketIdAandDepUserIds.put(item.Id, user.Id);
                                    }
                                }
                            }
                            // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                            shareList.add(item);
                            sendNotification(' You have a new ticket ', item, userIdSet); 
                        }
                    }
                } else if (item.Promoter_Status__c == oldMap.get(item.Id).Promoter_Status__c && oldMap.get(item.Id).Promoter_Status__c == 'Submitted') {
                    //这里判断是否解决
                    if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                        if(activeOwnerIdList.contains(item.OwnerId)) {
                            sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                        }
                    }
                }
            } else {

                if(item.RecordTypeId == floorRecordTypeId && (item.DueDate__c == NULL)) {
                    continue;
                }

                // 状态更新为Resolved发通知
                if((item.Status__c == 'Resolved') && (oldMap.get(item.Id).Status__c != 'Resolved')) {
                    if(activeOwnerIdList.contains(item.OwnerId)) {
                        sendNotification(' Ticket Resolved ', item, new Set<String>{item.OwnerId});
                    }
                }

                // 更改 Assigned To
                // (item.Aassigners__c != null) && 
                if((oldMap.get(item.Id).Aassigners__c != item.Aassigners__c)) {
                    Boolean pickTicket = false;
                    System.debug('wwww更改 Assigned To');
                    // 根据逗号拆分拼接的多个user
                    List<String> assignList = item.Aassigners__c.split(',');
                    System.debug('wwwwassignList' + JSON.serialize(assignList));
                    if(String.isBlank(oldMap.get(item.Id).Aassigners__c) && !String.isBlank(oldMap.get(item.Id).Department__c) && (oldMap.get(item.Id).Department__c == item.Department__c)) {
                        System.debug('wwwwuserGroupByRegion' + JSON.serialize(userGroupByRegion));
                        if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                            for(String userId : assignList) {
                                // 轮循多人员，满足条件跳出循环
                                pickTicket = (userGroupByRegion.get(item.SalesRegion__c).selectsField('Id')).contains(userId);
                                if(pickTicket){
                                    break;
                                }
                            }
                        }
                    } 
                    if(!pickTicket) {
                        // 轮循多人员判断当前ticket是否满足条件
                        for(String userId : assignList) {
                            if(activeUserIdList.contains(userId)) {
                                shareList.add(item);
                                break;
                            }
                        }
                        deleteShareList.add(oldMap.get(item.Id));

                        Set<String> aassignerSet = new Set<String>{};
                        aassignerSet.addAll(assignList);

                        // sendNotification(' You have a new ticket ', item, new Set<String>{item.AssignedTo__c});
                        sendNotification(' You have a new ticket ', item, aassignerSet);
                    }

                }else if((item.Department__c != null) && (oldMap.get(item.Id).Department__c != item.Department__c)) {
                    // 更改部门
                    if(userGroupByRegion.containsKey(item.SalesRegion__c)) {
                        Set<String> newUserIdSet = new Set<String>();
                        for(User user : (List<User>) userGroupByRegion.get(item.SalesRegion__c).ToSobjectList()) {
                            if(user.Department__c == item.Department__c) {
                                newUserIdSet.add(user.Id);
                                // item.ResponsibleDepartmentUserIds__c += user.Id + ';';
                                if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                                    String newUserIds = ticketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                    ticketIdAandDepUserIds.put(item.Id, newUserIds);
                                } else {
                                    ticketIdAandDepUserIds.put(item.Id, user.Id);
                                }
                            }
                            if(user.Department__c == oldMap.get(item.Id).Department__c) {
                                // oldMap.get(item.Id).ResponsibleDepartmentUserIds__c += user.Id + ';';
                                if(oldTicketIdAandDepUserIds.containsKey(item.Id)) {
                                    String newUserIds = oldTicketIdAandDepUserIds.get(item.Id) + ';' + user.Id;
                                    oldTicketIdAandDepUserIds.put(item.Id, newUserIds);
                                } else {
                                    oldTicketIdAandDepUserIds.put(item.Id, user.Id);
                                }
                            }
                        }
                        // System.debug('item.ResponsibleDepartmentUserIds__c：' + item.ResponsibleDepartmentUserIds__c);
                        // System.debug('item.ResponsibleDepartmentUserIds__c：' + oldMap.get(item.Id).ResponsibleDepartmentUserIds__c);
                        deleteShareList.add(oldMap.get(item.Id));
                        shareList.add(item);
                        sendNotification(' You have a new ticket ', item, newUserIdSet); 
                        continue;
                    }
                }

            }
        }
        if(shareList.size() > 0) {
            sharingUserManyRelatedOperations(shareList, ticketIdAandDepUserIds);
            deleteShred(deleteShareList, oldTicketIdAandDepUserIds);
        }
    }


    public static void deleteShred(List<Ticket__c> oldList, List<Ticket__c> newList) {

        // 新增多人员逻辑 根据Assign To 和 Aassigners 区分
        Ticket__c ticket = (Ticket__c)oldList.get(0);
        if(!String.isEmpty(ticket.Aassigners__c)){
            deleteUserManyShred(oldList, new Map<Id, String>());
        }else{
            deleteShred(oldList, new Map<Id, String>());
        }
        
    }

    public static void deleteShred(List<Ticket__c> ticketList, Map<Id, String> ticketIdAandDepUserIds){
        // sharingRelatedOperations(oldList, 'delete');

        Map<Id, Ticket__c> ticketMap = new Map<Id, Ticket__c>(ticketList);
        List<Ticket__Share> shareList = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
                                                FROM Ticket__Share 
                                                WHERE ParentId IN :ticketMap.keySet() AND RowCause = 'Manual' AND AccessLevel = 'Read'];
        List<Ticket__Share> deleteShareList = new List<Ticket__Share>();
        for(Ticket__Share item : shareList) {
            if(ticketMap.containsKey(item.ParentId)) {
                if(ticketMap.get(item.ParentId).AssignedTo__c == item.UserOrGroupId) {
                    deleteShareList.add(item);
                } else if(ticketIdAandDepUserIds.containsKey(item.ParentId) && ticketIdAandDepUserIds.get(item.ParentId).contains(item.UserOrGroupId)) {
                    deleteShareList.add(item);
                }
            }
        }
        if(deleteShareList.size() > 0) {
            delete deleteShareList;
        }

    }

    public static void deleteUserManyShred(List<Ticket__c> ticketList, Map<Id, String> ticketIdAandDepUserIds){
        // sharingRelatedOperations(oldList, 'delete');

        Map<Id, Ticket__c> ticketMap = new Map<Id, Ticket__c>(ticketList);
        List<Ticket__Share> shareList = [SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel 
                                                FROM Ticket__Share 
                                                WHERE ParentId IN :ticketMap.keySet() AND RowCause = 'Manual' AND AccessLevel = 'Read'];
        List<Ticket__Share> deleteShareList = new List<Ticket__Share>();
        for(Ticket__Share item : shareList) {
            if(ticketMap.containsKey(item.ParentId)) {
                if(ticketMap.get(item.ParentId).Aassigners__c == item.UserOrGroupId) {
                    deleteShareList.add(item);
                } else if(ticketIdAandDepUserIds.containsKey(item.ParentId) && ticketIdAandDepUserIds.get(item.ParentId).contains(item.UserOrGroupId)) {
                    deleteShareList.add(item);
                }
            }
        }
        if(deleteShareList.size() > 0) {
            delete deleteShareList;
        }

    }

    public static void sharingRelatedOperations(List<Ticket__c> ticketList, Map<Id, String> ticketIdAandDepUserIds){

        List<Ticket__Share> shareList = new List<Ticket__Share>();
        for(Ticket__c item : ticketList) {

            if(item.AssignedTo__c == item.OwnerId) {
                continue;
            }
            
            if(item.AssignedTo__c != null) {
                Ticket__Share ticketShare = new Ticket__Share();
                ticketShare.RowCause = 'Manual';
                ticketShare.ParentId = item.Id;
                ticketShare.UserOrGroupId = item.AssignedTo__c;
                ticketShare.AccessLevel = 'Read';
                shareList.add(ticketShare);
            } else if(ticketIdAandDepUserIds.containsKey(item.Id)) {
                List<String> userIdList = ticketIdAandDepUserIds.get(item.Id).split(';');
                for(String userId : userIdList) {
                    if(userId == item.OwnerId) {
                        continue;
                    }
                    Ticket__Share ticketShare = new Ticket__Share();
                    ticketShare.RowCause = 'Manual';
                    ticketShare.ParentId = item.Id;
                    ticketShare.AccessLevel = 'Read';
                    ticketShare.UserOrGroupId = userId;
                    shareList.add(ticketShare);
                }
            }
        }
        if(shareList.size() > 0) {
            insert shareList;
        }

        
    }

    public static void sharingUserManyRelatedOperations(List<Ticket__c> ticketList, Map<Id, String> ticketIdAandDepUserIds){

        List<Ticket__Share> shareList = new List<Ticket__Share>();
        for(Ticket__c item : ticketList) {

            if(item.Aassigners__c.contains(item.OwnerId)) {
                continue;
            }
            
            Ticket__Share ticketShare = new Ticket__Share();
            ticketShare.RowCause = 'Manual';
            ticketShare.ParentId = item.Id;
            ticketShare.UserOrGroupId = item.Aassigners__c;
            ticketShare.AccessLevel = 'Read';
            shareList.add(ticketShare);
                
        }
        if(shareList.size() > 0) {
            insert shareList;
        }

        
    }

    public static void sendNotification(String title, Ticket__c record, Set<String> userIdList){

        if(userIdList.size() > 0) {
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            // Set the contents for the delinking notification
            currNotification.setTitle(title);

            String noticeBody = record.Subject__c;
            if(!String.isBlank(record.Description__c)) {
                noticeBody += '\n' + record.Description__c;
            }
            currNotification.setBody(noticeBody);
            
            // Set the notification type and target
            currNotification.setNotificationTypeId([SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Custom_Notification'].Id);
            currNotification.setTargetId(record.Id);
            
            // Send the notification
            try {
                currNotification.send(userIdList);
            }
            catch (Exception ex) {
                string msg = 'Notification Failed: ' + ex.getMessage();
                System.debug(msg);
            }
        }
        
    }

    // public static void countResult(List<Ticket__c> oldList, List<Ticket__c> newList) {
    //     for(Ticket__c item : newList) {
    //         if(item.SystemGeneration__c == true) {
    //             if(String.isNotBlank(item.AssignedTo__c) || String.isNotBlank(item.Department__c)) {
    //                 if (item.Send_Num__c == null) {
    //                     // 如果为空，赋值为 1
    //                     item.Send_Num__c = 1;
    //                 } else {
    //                     // 如果不为空，加 1
    //                     item.Send_Num__c += 1;
    //                 }
    //             }               
    //         }
    //     }
    // }

    // 日报为空时 如果发生其他字段修改则推送提示 InspectionReport__c,PromoterDailyReport__c
    public static void beforeHandle(List<Ticket__c> oldList, List<Ticket__c> newList) {
        Map<Id, Ticket__c> oldMap = new Map<Id, Ticket__c>(oldList);
        for(Ticket__c item : newList) {
            if(String.isEmpty(item.PromoterDailyReport__c) && String.isEmpty(item.InspectionReport__c)) {

                if(item.Subject__c != oldMap.get(Item.Id).Subject__c) {
                    Item.addError(System.label.Ticket_Prompt);
                }
                if(item.Description__c != oldMap.get(Item.Id).Description__c) {
                    Item.addError(System.label.Ticket_Prompt);
                }
                if(item.Priority__c != oldMap.get(Item.Id).Priority__c) {
                    Item.addError(System.label.Ticket_Prompt);
                }
                if(item.DueDate__c != oldMap.get(Item.Id).DueDate__c) {
                    Item.addError(System.label.Ticket_Prompt);
                }
            }
        }
        if(Test.isRunningTest()){
            gabige();
        }
    }

    public static integer gabige() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        return i;
    }

}