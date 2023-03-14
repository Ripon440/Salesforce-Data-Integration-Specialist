@RestResource(urlMapping='/project/*')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(
        String ProjectRef,
        String ProjectName,
        String OpportunityId,
        Date StartDate,
        Date EndDate,
        Double Amount,
        String Status
    ) {
        Savepoint sp = Database.setSavepoint();
        try {
            Project__c projectRecord = new Project__c();

            List<Project__c> projectList = [
                SELECT
                    Id,
                    Name,
                    ProjectRef__c,
                    Opportunity__c,
                    Start_Date__c,
                    End_Date__c,
                    Billable_Amount__c,
                    Status__c
                FROM Project__c
                WHERE Name = :ProjectName AND Opportunity__c = :OpportunityId
            ];

            if (projectList.size() > 0) {
                projectRecord.Id = projectList[0]?.Id;
            } else {
                projectRecord.Opportunity__c = OpportunityId;
            }

            projectRecord.ProjectRef__c = ProjectRef;
            projectRecord.Name = ProjectName;
            projectRecord.Start_Date__c = StartDate;
            projectRecord.End_Date__c = EndDate;
            projectRecord.Billable_Amount__c = Amount;
            projectRecord.Status__c = Status;

            upsert projectRecord;

            Opportunity oppRecord = [
                SELECT Id, DeliveryInstallationStatus__c
                FROM Opportunity
                WHERE Id = :OpportunityId
                WITH SECURITY_ENFORCED
            ];
            oppRecord.DeliveryInstallationStatus__c = 'In progress';
            update oppRecord;

            return 'OK';
        } catch (Exception e) {
            Database.rollback(sp);
            return e.getMessage();
        }
    }
}
