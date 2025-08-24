@isTest
public class PurchaseLineTriggerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Acc');
        insert acc;

        Item__c item = new Item__c(
            Name = 'Tablet',
            Description__c = 'Tablet device',
            Family__c = 'Electronics',
            Type__c = 'New',
            Price__c = 300
        );
        insert item;

        Purchase__c p = new Purchase__c(Client_ID__c = acc.Id);
        insert p;

        PurchaseLine__c pl = new PurchaseLine__c(
            Purchase_Id__c = p.Id,
            Item_Id__c = item.Id,
            Amount__c = 1,
            UnitCost__c = 300
        );
        insert pl;
    }

    @isTest
    static void testTriggerUpdateTotals() {
        Purchase__c p = [SELECT Id, TotalItems__c, GrandTotal__c FROM Purchase__c LIMIT 1];
        System.assert(p.TotalItems__c >= 1, 'Total items should be updated by trigger');
        System.assert(p.GrandTotal__c > 0, 'Grand total should be updated by trigger');
    }
}