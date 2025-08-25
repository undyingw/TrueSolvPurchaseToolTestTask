public with sharing class PurchaseController {
    public class CartItem {
        @AuraEnabled public Id itemId;
        @AuraEnabled public Integer amount;
        @AuraEnabled public Decimal unitCost;
    }

    @AuraEnabled
    public static Id createPurchase(Id accountId, List<CartItem> cart) {
        Purchase__c purchase = new Purchase__c();
        purchase.Client_ID__c = accountId;
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

    @AuraEnabled(cacheable=true)
    public static List<Purchase__c> getPurchasesByAccount(Id accountId) {
    // Проверяем что accountId передан
    if (accountId == null) {
        throw new AuraHandledException('Account ID is required');
    }
    
    // Проверяем права на объект
    if (!Purchase__c.SObjectType.getDescribe().isAccessible()) {
        throw new AuraHandledException('No access to Purchase records');
    }
    
    // фильтруем только по конкретному аккаунту
    return [
        SELECT Id, Client_ID__c, TotalItems__c, GrandTotal__c, CreatedDate
        FROM Purchase__c 
        WHERE Client_ID__c = :accountId
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
    ];
    }

    @AuraEnabled(cacheable=true) 
    public static Purchase__c getPurchase(Id purchaseId, Id accountId) {
    if (purchaseId == null || accountId == null) {
        throw new AuraHandledException('Purchase ID and Account ID are required');
    }
    
    if (!Purchase__c.SObjectType.getDescribe().isAccessible()) {
        throw new AuraHandledException('No access to Purchase records');
    }
    
    List<Purchase__c> purchases = [
        SELECT Id, Client_ID__c, TotalItems__c, GrandTotal__c, CreatedDate
        FROM Purchase__c 
        WHERE Id = :purchaseId 
        AND Client_ID__c = :accountId  
        WITH SECURITY_ENFORCED
        LIMIT 1
    ];
    
    if (purchases.isEmpty()) {
        throw new AuraHandledException('Purchase not found or access denied');
    }
    
    return purchases[0];
    }
}