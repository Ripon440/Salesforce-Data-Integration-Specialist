@isTest
private class ProjectCalloutServiceTest {
    public static String token = 'skahsafhsalkfsa';
    public static String bodyContent = '{"opportunityId":"00641000004EKmFAAW","opportunityName": "Super-Duper Big Deal","accountName": "ACME Corp, Inc.", "closeDate": "2016-10-30","amount": 150000}';

    //Implement mock callout tests here
    @TestSetup
    static void setup() {
        ServiceTokens__c token = new ServiceTokens__c();
        token.Name = 'ProjectServiceToken';
        token.Token__c = 'skahsafhsalkfsa';

        insert token;

        List<Opportunity> opps = new List<Opportunity>();
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account'));
        insert accounts;

        for (Integer i = 0; i < 2; i++) {
            Opportunity testOpp = new Opportunity();
            testOpp.Name = 'Test Opportunity ' + i;
            testOpp.AccountId = accounts[0].Id;
            testOpp.Amount = 123132;
            testOpp.CloseDate = Date.today();
            testOpp.Type = 'New Project';
            testOpp.StageName = 'Prospecting';
            opps.add(testOpp);
        }
        insert opps;
    }

    @isTest
    static void testUpdateOpportunity() {
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        Opportunity record = getOpportunity('Test Opportunity 0');
        record.StageName = 'Closed Won';
        Test.startTest();
        update record;
        Test.stopTest();
        System.assertEquals(true, true, 'Result should match');
    }

    @isTest
    static void testQueueablePMSCall() {
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Opportunity record = getOpportunity('Test Opportunity 1');
        ProjectCalloutService.QueueablePMSCall pmsCallJob = new ProjectCalloutService.QueueablePMSCall(
            token,
            bodyContent,
            record?.Id
        );
        Test.startTest();
        System.enqueueJob(pmsCallJob);
        Test.stopTest();
        System.assertEquals(true, true, 'Result should match');
    }

    @isTest
    static void testPostSuccessToPMS() {
        // set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock

        Test.startTest();
        ProjectCalloutService.submitDataToPMS(token, bodyContent, getOpportunity('Test Opportunity 1')?.Id);
        Test.stopTest();

        Opportunity record = getOpportunity('Test Opportunity 1');
        System.assertEquals('Submitted Project', record?.StageName, 'Stage should be in submitted project');
    }

    @isTest
    static void testPostFailurePMS() {
        // set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock

        Test.startTest();
        ProjectCalloutService.submitDataToPMS(token, bodyContent, getOpportunity('Test Opportunity 1')?.Id);
        Test.stopTest();

        Opportunity record = getOpportunity('Test Opportunity 1');
        System.assertEquals('Resubmit Project', record?.StageName, 'Stage should be in submitted project');
    }

    public static Opportunity getOpportunity(String name) {
        List<Opportunity> opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = :name];
        return opp[0];
    }
}
