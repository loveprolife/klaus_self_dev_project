@isTest
global class CalloutMock implements HttpCalloutMock {
    public String str;
    public Integer code;

	public CalloutMock(String str){
		this.str = str;
    }
    public CalloutMock(String str, Integer code){
        this.str = str;
        this.code = code;
	}
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(str);
        response.setStatusCode(code == null? 200 : code);
        return response; 
    }
}