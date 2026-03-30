public virtual class ConResponse extends Response {

    @AuraEnabled 
    public Integer code {get; set;}
    
    @AuraEnabled 
    public Boolean isSuccess {
        get {
            return code == 0;
        }
    }

    public ConResponse() {
        code = 0;
    }
}