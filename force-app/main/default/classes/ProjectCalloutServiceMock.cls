@isTest
global class ProjectCalloutServiceMock implements HttpCalloutMock {
    //Implement http mock callout here
    global HTTPResponse respond(HttpRequest request) {
        // create a fake response
        String body = '{"opportunityId":"00641000004EKmFAAW","opportunityName": "Super-Duper Big Deal","accountName": "ACME Corp, Inc.", "closeDate": "2016-10-30","amount": 150000}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatus('OK');
        response.setStatusCode(201);
        return response;
    }
}
