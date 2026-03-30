global class ExhibitionCallbackQueueable implements Queueable, Database.AllowsCallouts  {
	private final static String URL = System.Label.Exhibition_Portal_Callback_Url;
	private final static String TOKEN = System.Label.Exhibition_Portal_Callback_Token;

    global List<String> ids;
    global String objectName;
    global ExhibitionCallbackQueueable( List<String> ids, String objectName) {
        this.ids = ids;
        this.objectName = objectName;
    }
    global void execute(QueueableContext context) {
    	callbackSetData(ids, objectName);
    }

    global static void callbackSetData(List<String> ids, String objectName){
    	try {
    		Data data = new Data();
    		data.id = ids;
    		data.objectName = objectName;
    	    Http http = new Http();
		    HttpRequest req = new HttpRequest();
		    req.setHeader('Authorization', TOKEN);
		    req.setHeader('Content-Type','application/json; charset=UTF-8');
		    req.setEndpoint(URL);
		    req.setTimeout(120000);
		    req.setMethod('POST');
		    req.setBody(JSON.serialize(data));
		    HttpResponse res = http.send(req);
		    // res.setBody(JSON.serialize(data));
            System.debug('req----->'+JSON.serialize(data));
		    System.debug('res code----->'+res.getStatusCode());
            System.debug('res ----->'+ res);
    	}
    	catch (Exception e) {
    	    System.debug('ExhibitionCallbackQueueable Error----->'+e.getLineNumber()+e.getMessage());
    	}
    }


    global class Data{
    	global List<String> id = new List<String>();
    	global String objectName = '';
    }

}