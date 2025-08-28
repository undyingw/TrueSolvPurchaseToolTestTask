@isTest
public class ItemControllerTest {
    
    @testSetup
    static void setupData() {
        // Техника
        Item__c item1 = new Item__c(
            Name = 'Laptop',
            Description__c = 'Nice laptop',
            Family__c = 'Electronics',
            Type__c = 'Electronics',
            Price__c = 1000
        );
        insert item1;

        // Одежда
        Item__c item2 = new Item__c(
            Name = 'Dress',
            Description__c = 'Good dress',
            Family__c = 'Clothes',
            Type__c = 'Clothes',
            Price__c = 20
        );
        insert item2;

        // Наушники
        Item__c item3 = new Item__c(
            Name = 'Headphones',
            Description__c = 'Wireless headphones',
            Family__c = 'Electronics',
            Type__c = 'Electronics',
            Price__c = 200
        );
        insert item3;

        // Аккаунт для теста (для checkoutCart)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    static void testGetAllItems() {
        Test.startTest();
        List<Item__c> items = ItemController.getAllItems();
        Test.stopTest();

        System.assert(items.size() >= 3, 'Должно вернуться как минимум 3 товара');
        System.assertEquals('Dress', items[0].Name, 'Товары должны быть отсортированы по имени');
    }

    @isTest
    static void testGetItemsByFilter() {
        Test.startTest();
        List<Item__c> electronics = ItemController.getItemsByFilter('Electronics', 'Electronics');
        Test.stopTest();

        System.assert(electronics.size() >= 1, 'Должны вернуться товары категории "Electronics" с корректным типом');

        // Граничный случай: пустые параметры
        List<Item__c> emptyResult = ItemController.getItemsByFilter('', '');
        System.assertEquals(0, emptyResult.size(), 'Пустой фильтр должен вернуть пустой список');
    }

    @isTest
    static void testSearchItems() {
        Test.startTest();
        List<Item__c> found = ItemController.searchItems('Laptop');
        Test.stopTest();

        System.assertEquals(1, found.size(), 'Ожидается один товар Laptop');
        System.assertEquals('Laptop', found[0].Name);

        // Граничный случай: пустой запрос
        List<Item__c> none = ItemController.searchItems('');
        System.assertEquals(0, none.size(), 'Пустой поиск должен вернуть пустой список');

        // Граничный случай: поиск по описанию
        List<Item__c> headphones = ItemController.searchItems('Wireless');
        System.assertEquals(1, headphones.size(), 'Должны найтись наушники по описанию');
    }

    @isTest
    static void testGetItemDetails() {
        Item__c anyItem = [SELECT Id FROM Item__c WHERE Name = 'Dress' LIMIT 1];

        Test.startTest();
        Item__c detail = ItemController.getItemDetails(anyItem.Id);
        Test.stopTest();

        System.assertNotEquals(null, detail, 'Детали товара должны быть возвращены');
        System.assertEquals('Dress', detail.Name);
    }

    /**
     * Тест проверяет полный сценарий "checkoutCart":
     * - создаётся новый Purchase__c
     * - к нему добавляются строки PurchaseLine__c
     * - триггер автоматически пересчитывает TotalItems__c и GrandTotal__c
     * Таким образом, гарантируется, что корзина оформляется корректно.
    */
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

        System.assertNotEquals(null, purchaseId, 'Покупка должна быть создана');

        Purchase__c purchase = [SELECT Id, TotalItems__c, GrandTotal__c 
                                FROM Purchase__c WHERE Id = :purchaseId LIMIT 1];
        System.assertEquals(2, purchase.TotalItems__c, 'Общее количество должно соответствовать количеству товаров');
        System.assertEquals(2 * laptop.Price__c, purchase.GrandTotal__c, 'Сумма должна равняться количеству * цене');
        
        List<PurchaseLine__c> lines = [SELECT Id, Purchase_Id__c FROM PurchaseLine__c WHERE Purchase_Id__c = :purchaseId];
        System.assertEquals(1, lines.size(), 'Строка корзины должна быть связана с покупкой');
    }
}