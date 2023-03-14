public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(
        Map<Id, Project__c> oldProjectMap,
        Map<Id, Project__c> newProjectMap,
        List<Project__c> newProjectList
    ) {
        List<Project__c> projectList = new List<Project__c>();

        for (Project__c record : newProjectList) {
            if (record.Status__c == 'Billable' && oldProjectMap.get(record.Id)?.Status__c != 'Billable') {
                projectList.add(record);
            }
        }

        if (projectList.size() <= 0) {
            return;
        }

        sendToBillingSystem((String) projectList[0].Id);
    }

    @Future(callout=true)
    public static void sendToBillingSystem(String projectId) {
        try {
            Project__c record = [
                SELECT Id, Name, Status__c, Billable_Amount__c, ProjectRef__c
                FROM Project__c
                WHERE Id = :projectId
                WITH SECURITY_ENFORCED
            ];

            BillingServiceProxy.project project = new BillingServiceProxy.project();
            project.username = ServiceCredentials__c.getValues('BillingServiceCredential')?.Username__c;
            project.password = ServiceCredentials__c.getValues('BillingServiceCredential')?.Password__c;
            project.billAmount = record.Billable_Amount__c;
            project.projectid = record.ProjectRef__c;

            BillingServiceProxy.InvoicesPortSoap11 bill = new BillingServiceProxy.InvoicesPortSoap11();

            String response = bill.billProject(project);

            System.debug('response --> ' + response);

            if (response == 'OK') {
                record.Status__c = 'Billed';
                update record;
            }
        } catch (Exception e) {
            System.debug('Error -> ' + e.getMessage());
        }
    }
}
