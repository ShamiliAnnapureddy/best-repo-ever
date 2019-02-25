global class GC_EntitySubscriptions implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_EntitySubscriptions()
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
        List<EntitySubscription> EntitySubscriptionList = new List<EntitySubscription>();
        
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(EntitySubscription ConvContact : [Select Id,ParentID From EntitySubscription where ParentID  IN :DuplicateContactIds])
        {
         ConvContact  =  new EntitySubscription();
        ConvContact.ParentID = DuplicateToGoldenMap.get(ConvContact.ParentID);
        EntitySubscriptionList.add(ConvContact);
        }
        
      
        try
            {
                if(EntitySubscriptionList.size() > 0)
                {
                    insert EntitySubscriptionList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('Remapping EntitySubscription List ','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}