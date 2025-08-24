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
            Type__c = 'New',
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

        List<PurchaseController.CartItem> cart = new List<PurchaseController.CartItem>{ci};

        Test.startTest();
        Id purchaseId = PurchaseController.createPurchase(acc.Id, cart);
        Test.stopTest();

        System.assertNotEquals(null, purchaseId, 'Purchase id should not be null');
    }
}