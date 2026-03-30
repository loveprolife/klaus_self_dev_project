public class TicketLinkLwcController {
    @AuraEnabled
    public static ConResponse getInitData() {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        String userId = UserInfo.getUserId();

        mso.put('reports',getExistTicketBaseStoreIdAndUser(userId));
        

        return resp;
    }
    
    // 获取Ticket
    public static List<Ticket__c> getExistTicketBaseStoreIdAndUser(String userId) {
        return [
                SELECT 
                    Id,
                    InspectionReport__c,
                    Name,
                    ClosedDailyInspectionReport__c,
                    Subject__c,
                    Description__c,
                    AssignedTo__c,
                    AssignedTo__r.name,
                    Status__c,
                    Priority__c,
                    DueDate__c,
                    LastModifiedDate,
                    CreatedDate
                FROM Ticket__c
                WHERE 
                    CreatedById = : userId
                ORDER BY DueDate__c DESC
                LIMIT 5];
    }

}