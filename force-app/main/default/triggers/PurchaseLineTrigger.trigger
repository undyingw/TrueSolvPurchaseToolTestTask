trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete) {
    Set<Id> purchaseIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate) {
        for (PurchaseLine__c pl : Trigger.new) {
            purchaseIds.add(pl.Purchase_Id__c);
        }
    }

    if (Trigger.isDelete) {
        for (PurchaseLine__c pl : Trigger.old) {
            purchaseIds.add(pl.Purchase_Id__c);
        }
    }

    List<Purchase__c> purchasesToUpdate = new List<Purchase__c>();

    for (Id pid : purchaseIds) {
        List<PurchaseLine__c> lines = [
            SELECT Amount__c, UnitCost__c
            FROM PurchaseLine__c
            WHERE Purchase_Id__c = :pid
        ];

        Decimal totalItems = 0;
        Decimal totalSum = 0;

        for (PurchaseLine__c line : lines) {
            totalItems += line.Amount__c;
            totalSum += line.Amount__c * line.UnitCost__c;
        }

        Purchase__c p = new Purchase__c();
        p.Id = pid;
        p.TotalItems__c = totalItems;
        p.GrandTotal__c = totalSum;
        purchasesToUpdate.add(p);
    }


    update purchasesToUpdate;
}