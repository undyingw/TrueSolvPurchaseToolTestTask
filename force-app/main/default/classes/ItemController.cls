public with sharing class ItemController {

    // get goods
    @AuraEnabled(cacheable=true)
    public static List<Item__c> getAllItems() {
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            ORDER BY Name
        ];
    }

    // get goods by type and family
    @AuraEnabled(cacheable=true)
    public static List<Item__c> getItemsByFilter(String familyValue, String typeValue) {
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            WHERE Family__c = :familyValue AND Type__c = :typeValue
            ORDER BY Name
        ];
    }

    // search by name and description
    @AuraEnabled(cacheable=true)
    public static List<Item__c> searchItems(String searchKey) {
        String likeExp = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            WHERE Name LIKE :likeExp OR Description__c LIKE :likeExp
            ORDER BY Name
        ];
    }

    // search for details
    @AuraEnabled(cacheable=true)
    public static Item__c getItemDetails(Id itemId) {
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            WHERE Id = :itemId
            LIMIT 1
        ];
    }

    // create purchase and lines
    @AuraEnabled
    public static Id checkoutCart(Id accountId, List<PurchaseLine__c> cartLines) {
    
        Purchase__c purchase = new Purchase__c();
        purchase.Client_ID__c = accountId;
        purchase.TotalItems__c = 0;   // will be changed by the trigger
        purchase.GrandTotal__c = 0;   // 
        insert purchase;

        
        for (PurchaseLine__c line : cartLines) {
            line.Purchase_Id__c = purchase.Id;
        }
        insert cartLines;

        return purchase.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Item__c> getItems() {
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            ORDER BY Name
        ];
    }
}