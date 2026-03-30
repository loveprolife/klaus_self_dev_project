@isTest
global class SyncCustomerCreditInfoToRR_Mock implements HTTPCalloutMock{
    global HttpResponse respond(HTTPRequest req){

        String body = '{"IsSuccess":"true","FailReason":""}';

        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}