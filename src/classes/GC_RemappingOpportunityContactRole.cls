global class GC_RemappingOpportunityContactRole implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingOpportunityContactRole()
    {

         duplicateContactQuery = 'Select Id,DuplicateContactID__c,GoldenContactID__c  From GoldenContactMapping__c';
 
       
    }     
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(duplicateContactQuery);
    }
  
    global void execute(Database.BatchableContext BC, List<GoldenContactMapping__c> scope)
    {
        Set<Id> DuplicateContactIds = new Set<Id>();
        Map<Id,Id> DuplicateToGoldenMap = new Map<Id,Id>();
        List<OpportunityContactRole> OpportunityContactList = new List<OpportunityContactRole>();
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(OpportunityContactRole opporContact: [Select Id,ContactId From OpportunityContactRole where ContactId IN :DuplicateContactIds])
        {
        opporContact.ContactId = DuplicateToGoldenMap.get(opporContact.ContactId );
        OpportunityContactList.add(opporContact);
        }
        try
            {
                if(OpportunityContactList.size() > 0)
                {
                    update OpportunityContactList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('GC_RemappingOpportunityContactRole','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}