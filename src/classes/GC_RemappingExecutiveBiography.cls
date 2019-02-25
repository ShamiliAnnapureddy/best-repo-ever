global class GC_RemappingExecutiveBiography implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingExecutiveBiography()
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
        List<Executive_Biography__c> ExecBioList = new List<Executive_Biography__c>();
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(Executive_Biography__c ExecBio : [Select Id,Contact__c From Executive_Biography__c where Contact__c IN :DuplicateContactIds])
        {
        ExecBio.Contact__c = DuplicateToGoldenMap.get(ExecBio.Contact__c);
        ExecBioList.add(ExecBio);
        }
        try
            {
                if(ExecBioList.size() > 0)
                {
                    update ExecBioList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('GC Remapping Exceutive biography','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}