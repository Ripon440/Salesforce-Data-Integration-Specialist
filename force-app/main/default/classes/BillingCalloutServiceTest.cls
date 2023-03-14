@isTest
private class BillingCalloutServiceTest {
    //Implement mock callout tests here
    @TestSetup
    static void makeData() {
        ServiceCredentials__c serviceCredentials = new ServiceCredentials__c();
        serviceCredentials.Name = 'BillingServiceCredential';
        serviceCredentials.Username__c = 'dsfddfdsf';
        serviceCredentials.Password__c = 'bsPasfdsgdss1';
        insert serviceCredentials;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity 1',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );

        insert opp;

        List<Project__c> projects = new List<Project__c>();
        for (Integer i = 0; i < 3; i++) {
            Project__c p = new Project__c();
            p.ProjectRef__c = 'akfhsdadf' + i;
            p.Name = 'Test Project ' + i;
            p.Start_Date__c = Date.today() + 1;
            p.End_Date__c = Date.today() + 2;
            p.Billable_Amount__c = 2321.2312;
            p.Status__c = 'Running';
            p.Opportunity__c = opp.Id;
            projects.add(p);
        }
        insert projects;
    }

    @isTest
    static void testUpdateProject() {
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        Project__c project = getProject('Test Project 0');
        project.Status__c = 'Billable';

        Test.startTest();
        update project;
        Test.stopTest();

        Project__c response = getProject('Test Project 0');
        System.debug('before --> ' + project);
        System.debug('after --> ' + response);
    }

    public static Project__c getProject(String name) {
        return [SELECT Id, Name, Status__c FROM Project__c WHERE Name = :name LIMIT 1];
    }
}
