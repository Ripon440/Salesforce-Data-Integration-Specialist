@isTest
private class ProjectRESTServiceTest {
    //Implement Apex REST service tests here
    @TestSetup
    static void makeData() {
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity ' + i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today();
            oppList.add(opp);
        }

        insert oppList;

        Project__c record = new Project__c(
            ProjectRef__c = 'asdfasdfa',
            Opportunity__c = oppList[1].Id,
            Name = 'Test Project 2',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today(),
            Billable_Amount__c = 213.21321,
            Status__c = 'Running'
        );
        insert record;
    }

    @isTest
    static void testCreateProject() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity 0' LIMIT 1];
        String ProjectRef = 'sdfasdfas';
        String ProjectName = 'Sample Project Name';
        String OpportunityId = opp.Id;
        Date StartDate = Date.today();
        Date EndDate = Date.today();
        Double Amount = 12312.21312;
        String Status = 'Running';

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            ProjectRef,
            ProjectName,
            OpportunityId,
            StartDate,
            EndDate,
            Amount,
            Status
        );
        System.assertEquals('OK', response, 'Respone should return OK');
        Test.stopTest();
    }

    @isTest
    static void testUpdateProject() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];
        Project__c project = [
            SELECT Id, Name, ProjectRef__c, Opportunity__c, Start_Date__c, End_Date__c, Billable_Amount__c, Status__c
            FROM Project__c
            WHERE Name = 'Test Project 2' AND Opportunity__c = :opp.Id
            LIMIT 1
        ];
        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            'jksadfsakfsak',
            project.Name,
            (String) opp.Id,
            Date.today() + 1,
            Date.today() + 2,
            (Double) 21321.213,
            'Billable'
        );
        System.assertEquals('OK', response, 'Respone should return OK');
        Test.stopTest();
    }

    @isTest
    static void testExceptionHandle() {
        String ProjectRef = 'sdfasdfas';
        String ProjectName = 'Sample Project Name';
        String OpportunityId = 'asfjhsakjfsa';
        Date StartDate = Date.today();
        Date EndDate = Date.today();
        Double Amount = 12312.21312;
        String Status = 'Running';

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            ProjectRef,
            ProjectName,
            OpportunityId,
            StartDate,
            EndDate,
            Amount,
            Status
        );
        Boolean isError = false;
        if (response.contains('Invalid')) {
            isError = true;
        }
        System.assertEquals(true, isError, 'Response should have an invalid keyword.');
        Test.stopTest();
    }
}
