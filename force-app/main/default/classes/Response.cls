public virtual class Response {
    
    @AuraEnabled 
    public object data {get; set;}
    @AuraEnabled 
    public String message {get; set;}
}