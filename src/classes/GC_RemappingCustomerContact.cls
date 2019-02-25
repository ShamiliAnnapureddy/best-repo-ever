global class GC_RemappingCustomerContact implements Database.Batchable<sObject>,Database.Stateful
{
    
    global String duplicateContactQuery;
    global GC_RemappingCustomerContact()
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
        List<Customer_Contact__c> CustomerContactList = new List<Customer_Contact__c>();
        
        for(GoldenContactMapping__c gCon : scope)
        {
            DuplicateToGoldenMap.put(gCon.DuplicateContactID__c,gCon.GoldenContactID__c);
            DuplicateContactIds.add(gCon.DuplicateContactID__c);
        }      
        
         
        for(Customer_Contact__c CustContact : [Select Id,Contact__c From Customer_Contact__c where Contact__c IN :DuplicateContactIds])
        {
        CustContact.Contact__c = DuplicateToGoldenMap.get(CustContact.Contact__c);
        CustomerContactList.add(CustContact);
        }
        try
            {
                if(CustomerContactList.size() > 0)
                {
                    update CustomerContactList;
                }
            }
        catch(Exception e)
            {
              Batch_Util exceptionClass = new Batch_Util();
               insert exceptionClass.createException('GC Remapping Customer Contact','Batch Execute',e);
                system.debug('Error Message'+e.getMessage());
            }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
      
    }   
    
}