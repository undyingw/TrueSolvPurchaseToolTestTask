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
    }

    @isTest
    static void testInsertUpdatesTotals() {
        Purchase__c p = [SELECT Id FROM Purchase__c LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseLine__c pl = new PurchaseLine__c(
            Purchase_Id__c = p.Id,
            Item_Id__c = item.Id,
            Amount__c = 2,
            UnitCost__c = item.Price__c
        );

        Test.startTest();
        insert pl;
        Test.stopTest();

        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :p.Id];
        System.assertEquals(2, p.TotalItems__c, 'После вставки должно быть 2 шт.');
        System.assertEquals(2 * item.Price__c, p.GrandTotal__c, 'Общая сумма должна совпадать');
    }

    @isTest
    static void testUpdateUpdatesTotals() {
        Purchase__c p = [SELECT Id FROM Purchase__c LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseLine__c pl = new PurchaseLine__c(
            Purchase_Id__c = p.Id,
            Item_Id__c = item.Id,
            Amount__c = 1,
            UnitCost__c = item.Price__c
        );
        insert pl;

        pl.Amount__c = 5;
        Test.startTest();
        update pl;
        Test.stopTest();

        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :p.Id];
        System.assertEquals(5, p.TotalItems__c, 'После апдейта должно быть 5 шт.');
        System.assertEquals(5 * item.Price__c, p.GrandTotal__c, 'Общая сумма должна обновиться');
    }

    @isTest
    static void testDeleteUpdatesTotals() {
        Purchase__c p = [SELECT Id FROM Purchase__c LIMIT 1];
        Item__c item = [SELECT Id, Price__c FROM Item__c LIMIT 1];

        PurchaseLine__c pl = new PurchaseLine__c(
            Purchase_Id__c = p.Id,
            Item_Id__c = item.Id,
            Amount__c = 3,
            UnitCost__c = item.Price__c
        );
        insert pl;

        delete pl;

        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :p.Id];
        System.assertEquals(0, p.TotalItems__c, 'После удаления должно быть 0 шт.');
        System.assertEquals(0, p.GrandTotal__c, 'После удаления сумма должна быть 0');
    }
}