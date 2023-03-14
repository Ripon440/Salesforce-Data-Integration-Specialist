public class ProjectCalloutService {
    //skeleton of opportunity records that have to post to external service
    public class OpportunityToPMS {
        public String opportunityId;
        public String opportunityName;
        public String accountName;
        public Date closeDate;
        public Integer amount;
    }

    //Complete the implementation for business and callout logic
    @InvocableMethod(label='Update record to external PMS' description='Make a post callout to external PMS system')
    public static void postOpportunityToPMS(List<Id> opportunities) {
        List<Opportunity> opp = [
            SELECT Id, Name, Account.Name, Amount, CloseDate
            FROM Opportunity
            WHERE Id = :opportunities[0]
            WITH SECURITY_ENFORCED
        ];
        OpportunityToPMS record = new OpportunityToPMS();
        record.opportunityId = opp[0].Id;
        record.opportunityName = opp[0].Name;
        record.accountName = opp[0].Account?.Name;
        record.closeDate = opp[0].CloseDate;
        record.amount = (Integer) opp[0].Amount;

        String token = ServiceTokens__c.getValues('ProjectServiceToken')?.Token__c;
        // instantiate new instance of the Queueable class
        QueueablePMSCall postOpportunity = new QueueablePMSCall(token, JSON.serialize(record), opp[0].Id);
        // enqueue the job for processing
        System.enqueueJob(postOpportunity);
    }

    public class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
        private String token;
        private String data;
        private String oppId;

        public QueueablePMSCall(String token, String data, String oppId) {
            this.token = token;
            this.data = data;
            this.oppId = oppId;
        }

        public void execute(QueueableContext context) {
            // Execute the asyncronues method
            try {
                submitDataToPMS(token, data, oppId);
            } catch (Exception e) {
                System.debug('Error ---> ' + e.getMessage());
            }
        }
    }

    @Future(callout=true)
    public static void submitDataToPMS(String token, String data, String oppId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('token', token);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(data);

        Http http = new Http();
        HttpResponse response = http.send(request);

        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED];

        if (response.getStatusCode() != 201) {
            opp.StageName = 'Resubmit Project';
        } else {
            opp.StageName = 'Submitted Project';
        }
        update opp;
    }
}
