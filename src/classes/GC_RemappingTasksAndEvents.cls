global class GC_RemappingTasksAndEvents implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingTasksAndEvents()
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
        List<Task> TaskList = new List<Task>();
        List<Event> EventList = new List<Event>();
        List<TaskRelation> TaskRelationList = new List<TaskRelation>();
        List<TaskWhoRelation> TaskWhoRelationList = new List<TaskWhoRelation>();
        List<EventRelation> EventRelationList = new List<EventRelation>();
        List<EventWhoRelation> EventWhoRelationList = new List<EventWhoRelation>();
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(Task tsk : [Select Id,WhoId From Task where WhoId IN :DuplicateContactIds])
        {
        tsk.WhoId = DuplicateToGoldenMap.get(tsk.WhoId);
        TaskList.add(tsk);
        }
        try
            {
                if(TaskList.size() > 0)
                {
                    update TaskList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('Remapping tasks error','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
            
             for(Event evt : [Select Id,WhoId From Event where WhoId IN :DuplicateContactIds])
        {
        evt.WhoId = DuplicateToGoldenMap.get(evt.WhoId);
        EventList.add(evt);
        }
        try
            {
                if(EventList.size() > 0)
                {
                    update EventList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('Remapping Events error','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
            
            
             for(EventRelation evt : [Select Id,RelationId From EventRelation where RelationId IN :DuplicateContactIds])
        {
        EventRelation newevt = new EventRelation();
        newevt = evt.clone();
        newevt.RelationId = DuplicateToGoldenMap.get(evt.RelationId);
        EventRelationList.add(evt);
        }
        try
            {
                if(EventRelationList.size() > 0)
                {
                    insert EventRelationList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('Remapping EventRelations error','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}