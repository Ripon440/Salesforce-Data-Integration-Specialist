trigger ProjectTrigger on Project__c(after update) {
    //Call the Billing Service callout logic here
    BillingCalloutService.callBillingService(Trigger.oldMap, Trigger.newMap, Trigger.new);
}
