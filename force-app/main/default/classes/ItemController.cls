public with sharing class ItemController {

    @AuraEnabled(cacheable=true)
    public static List<Item__c> getAllItems() {
        if (!Item__c.SObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient access to Item records');
        }
        
        try {
            return [
                SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
                FROM Item__c
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 1000
            ];
        } catch (QueryException e) {
            System.debug('QueryException in getAllItems: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving items: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Item__c> getItemsByFilter(String familyValue, String typeValue) {
        // Валидация входных параметров
        if (String.isBlank(familyValue) || String.isBlank(typeValue)) {
            return new List<Item__c>();
        }
        
        // Проверка прав доступа
        if (!Item__c.SObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient access to Item records');
        }
        
        // Защита от SOQL инъекций
        String safeFamilyValue = String.escapeSingleQuotes(familyValue.trim());
        String safeTypeValue = String.escapeSingleQuotes(typeValue.trim());
        
        try {
            return [
                SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
                FROM Item__c
                WHERE Family__c = :safeFamilyValue AND Type__c = :safeTypeValue
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 1000
            ];
        } catch (QueryException e) {
            System.debug('QueryException in getItemsByFilter: ' + e.getMessage());
            throw new AuraHandledException('Error filtering items');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Item__c> searchItems(String searchKey) {
        // Валидация входного параметра
        if (String.isBlank(searchKey)) {
            return new List<Item__c>();
        }
        
        // Проверка прав доступа
        if (!Item__c.SObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient access to Item records');
        }
        
        // ЗАЩИТА от SOQL инъекций: экранирование спецсимволов
        String safeTerm = String.escapeSingleQuotes(searchKey.trim());
        
        // Ограничение длины для защиты от DoS
        if (safeTerm.length() > 100) {
            safeTerm = safeTerm.substring(0, 100);
        }
        
        // Дополнительная защита: удаляем опасные символы
        safeTerm = safeTerm.replaceAll('[^a-zA-Z0-9\\s]', '');
        
        String likeExp = '%' + safeTerm + '%';
        
        try {
            return [
                SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
                FROM Item__c
                WHERE (Name LIKE :likeExp OR Description__c LIKE :likeExp)
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 50
            ];
        } catch (QueryException e) {
            System.debug('QueryException in searchItems: ' + e.getMessage());
            throw new AuraHandledException('Error searching items');
        }
    }


    @AuraEnabled(cacheable=true)
    public static Item__c getItemDetails(Id itemId) {
        return [
            SELECT Id, Name, Description__c, Family__c, Type__c, Image__c, Price__c
            FROM Item__c
            WHERE Id = :itemId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Id checkoutCart(Id accountId, List<PurchaseLine__c> cartLines) {
        Purchase__c purchase = new Purchase__c();
        purchase.Client_ID__c = accountId;
        purchase.TotalItems__c = 0;  
        purchase.GrandTotal__c = 0;   
        insert purchase;

        for (PurchaseLine__c line : cartLines) {
            line.Purchase_Id__c = purchase.Id;
        }
        insert cartLines;

        return purchase.Id;
    }

    
}