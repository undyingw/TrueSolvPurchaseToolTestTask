public with sharing class PurchaseController {
    public class CartItem {
        @AuraEnabled public Id itemId;
        @AuraEnabled public Integer amount;
        @AuraEnabled public Decimal unitCost;
    }

    @AuraEnabled
    public static Id createPurchase(Id accountId, List<CartItem> cart) {
        Purchase__c purchase = new Purchase__c();
        purchase.ClientId__c = accountId;
        insert purchase;

        List<PurchaseLine__c> lines = new List<PurchaseLine__c>();
        for (CartItem c : cart) {
            PurchaseLine__c line = new PurchaseLine__c();
            line.Purchase_Id__c = purchase.Id;
            line.Item_Id__c = c.itemId;
            line.Amount__c = c.amount;
            line.UnitCost__c = c.unitCost;
            lines.add(line);
        }
        insert lines;

        return purchase.Id;
    }
}