@isTest
public class PurchaseControllerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name='Test Account');
        insert acc;

        Item__c item = new Item__c(
            Name = 'Phone',
            Description__c = 'Smartphone',
            Family__c = 'Electronics',
            Type__c = 'Electronics',
            Price__c = 500
        );
        insert item;
    }

    @isTest
    static void testCreatePurchase() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseController.CartItem ci = new PurchaseController.CartItem();
        ci.itemId = item.Id;
        ci.amount = 2;
        ci.unitCost = item.Price__c;

        Test.startTest();
        Id purchaseId = PurchaseController.createPurchase(acc.Id, new List<PurchaseController.CartItem>{ci});
        Test.stopTest();

        System.assertNotEquals(null, purchaseId, 'Purchase id should not be null');
    }

    @isTest
    static void testGetPurchasesByAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseController.CartItem ci = new PurchaseController.CartItem();
        ci.itemId = item.Id;
        ci.amount = 1;
        ci.unitCost = item.Price__c;
        Id purchaseId = PurchaseController.createPurchase(acc.Id, new List<PurchaseController.CartItem>{ci});

        Test.startTest();
        List<Purchase__c> purchases = PurchaseController.getPurchasesByAccount(acc.Id);
        Test.stopTest();

        System.assert(!purchases.isEmpty(), 'Должен вернуться хотя бы один заказ');
    }

    @isTest
    static void testGetPurchase() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseController.CartItem ci = new PurchaseController.CartItem();
        ci.itemId = item.Id;
        ci.amount = 1;
        ci.unitCost = item.Price__c;
        Id purchaseId = PurchaseController.createPurchase(acc.Id, new List<PurchaseController.CartItem>{ci});

        Test.startTest();
        Purchase__c purchase = PurchaseController.getPurchase(purchaseId, acc.Id);
        Test.stopTest();

        System.assertEquals(purchaseId, purchase.Id, 'Должен вернуться правильный заказ');
    }
}