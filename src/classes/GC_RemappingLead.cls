global class GC_RemappingLead implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingLead()
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
        List<Lead> LeadList = new List<Lead>();
        
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(Lead ConvContact : [Select Id,ConvertedContactId From Lead where ConvertedContactId  IN :DuplicateContactIds])
        {
        ConvContact.ConvertedContactId = DuplicateToGoldenMap.get(ConvContact.ConvertedContactId);
        LeadList.add(ConvContact);
        }
        
        for(Lead ConvContact : [Select Id,Lead_Submitter_Lookup__c From Lead where Lead_Submitter_Lookup__c  IN :DuplicateContactIds])
        {
        ConvContact.Lead_Submitter_Lookup__c  = DuplicateToGoldenMap.get(ConvContact.Lead_Submitter_Lookup__c);
        LeadList.add(ConvContact);
        }
        try
            {
                if(LeadList.size() > 0)
                {
                    update LeadList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('Remapping Lead List ','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}