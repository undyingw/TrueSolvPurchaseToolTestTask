@isTest
public class ItemControllerTest {
    
    @testSetup
    static void setupData() {
        // Техника
        Item__c item1 = new Item__c(
            Name = 'Laptop',
            Description__c = 'Nice laptop',
            Family__c = 'option1',
            Type__c = 'Electronics',
            Price__c = 1000
        );
        insert item1;

        // Книга
        Item__c item2 = new Item__c(
            Name = 'Dress',
            Description__c = 'Good dress',
            Family__c = 'option2',
            Type__c = 'Clothes',
            Price__c = 20
        );
        insert item2;

        // Наушники
        Item__c item3 = new Item__c(
            Name = 'Headphones',
            Description__c = 'Wireless headphones',
            Family__c = 'option3',
            Type__c = 'Electronics',
            Price__c = 200
        );
        insert item3;

        // аккаунт для теста (для checkoutCart)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    static void testGetAllItems() {
        Test.startTest();
        List<Item__c> items = ItemController.getAllItems();
        Test.stopTest();

        System.assert(items.size() >= 3, 'Should return at least 3 items');
        System.assertEquals('Book', items[0].Name, 'Items should be ordered by Name');
    }

    @isTest
    static void testGetItemsByFilter() {
        Test.startTest();
        List<Item__c> electronics = ItemController.getItemsByFilter('option1', 'Electronics');
        Test.stopTest();

        System.assert(electronics.size() >= 1, 'Should return electronics with valid type');

        // Edge case: пустые параметры
        List<Item__c> emptyResult = ItemController.getItemsByFilter('', '');
        System.assertEquals(0, emptyResult.size(), 'Empty filter should return empty list');
    }

    @isTest
    static void testSearchItems() {
        Test.startTest();
        List<Item__c> found = ItemController.searchItems('Laptop');
        Test.stopTest();

        System.assertEquals(1, found.size(), 'One Laptop expected');
        System.assertEquals('Laptop', found[0].Name);

        // Edge case: пустой запрос
        List<Item__c> none = ItemController.searchItems('');
        System.assertEquals(0, none.size(), 'Empty search should return empty list');

        // Edge case: поиск по Description
        List<Item__c> headphones = ItemController.searchItems('Wireless');
        System.assertEquals(1, headphones.size(), 'Should find headphones by description');
    }

    @isTest
    static void testGetItemDetails() {
        Item__c anyItem = [SELECT Id FROM Item__c WHERE Name = 'Dress' LIMIT 1];

        Test.startTest();
        Item__c detail = ItemController.getItemDetails(anyItem.Id);
        Test.stopTest();

        System.assertNotEquals(null, detail, 'Details should be returned');
        System.assertEquals('Dress', detail.Name);
    }

    @isTest
    static void testCheckoutCart() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Item__c laptop = [SELECT Id, Price__c FROM Item__c WHERE Name = 'Laptop' LIMIT 1];

        PurchaseLine__c line = new PurchaseLine__c(
            Item_Id__c = laptop.Id,
            Amount__c = 2,
            UnitCost__c = laptop.Price__c
        );

        Test.startTest();
        Id purchaseId = ItemController.checkoutCart(acc.Id, new List<PurchaseLine__c>{ line });
        Test.stopTest();

        System.assertNotEquals(null, purchaseId, 'Purchase should be created');

        Purchase__c purchase = [SELECT Id, TotalItems__c, GrandTotal__c 
                                FROM Purchase__c WHERE Id = :purchaseId LIMIT 1];
        System.assertEquals(0, purchase.TotalItems__c, 'Totals should be 0 initially (trigger will recalc)');
        System.assertEquals(0, purchase.GrandTotal__c, 'GrandTotal should be 0 initially');
        
        List<PurchaseLine__c> lines = [SELECT Id, Purchase_Id__c FROM PurchaseLine__c WHERE Purchase_Id__c = :purchaseId];
        System.assertEquals(1, lines.size(), 'Cart line should be linked to purchase');
    }
}