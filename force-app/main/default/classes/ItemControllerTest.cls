@isTest
public class ItemControllerTest {
    
    @testSetup
    static void setupData() {
        Item__c item1 = new Item__c(
            Name = 'Laptop',
            Description__c = 'Nice laptop',
            Family__c = 'Electronics',
            Type__c = 'New',
            Price__c = 1000
        );
        insert item1;

        Item__c item2 = new Item__c(
            Name = 'Book',
            Description__c = 'Good book',
            Family__c = 'Books',
            Type__c = 'Used',
            Price__c = 20
        );
        insert item2;
    }

    @isTest
    static void testGetItems() {
        List<Item__c> items = ItemController.getItems();
        System.assert(items.size() > 0, 'Items should be returned');
    }

    @isTest
    static void testSearchItems() {
        List<Item__c> found = ItemController.searchItems('Laptop');
        System.assertEquals(1, found.size(), 'One laptop expected');
    }

    @isTest
    static void testGetItemDetails() {
        Item__c anyItem = [SELECT Id FROM Item__c LIMIT 1];
        Item__c detail = ItemController.getItemDetails(anyItem.Id);
        System.assertNotEquals(null, detail, 'Detail should be returned');
    }
}