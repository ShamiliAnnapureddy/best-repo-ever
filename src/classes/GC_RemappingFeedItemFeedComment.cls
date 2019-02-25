global class GC_RemappingFeedItemFeedComment implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingFeedItemFeedComment()
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
        List<FeedItem> FeedItemList = new List<FeedItem>();
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(FeedItem fitem: [Select Id,ParentId From FeedItem where ParentId IN :DuplicateContactIds])
        {
        fitem = fitem.clone();
        fitem.ParentId = DuplicateToGoldenMap.get(fitem.ParentId );
        FeedItemList.add(fitem);
        }
        try
            {
                if(FeedItemList.size() > 0)
                {
                    update FeedItemList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('GC_RemappingFeedItem','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}