trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete) {
    Set<Id> purchaseIds = new Set<Id>();

    // Собираем Id из новых записей
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (PurchaseLine__c pl : Trigger.new) {
            if (pl.Purchase_Id__c != null) {
                purchaseIds.add(pl.Purchase_Id__c);
            }
        }
    }

    // Собираем Id из старых записей (на случай update/delete)
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (PurchaseLine__c pl : Trigger.old) {
            if (pl.Purchase_Id__c != null) {
                purchaseIds.add(pl.Purchase_Id__c);
            }
        }
    }

    if (purchaseIds.isEmpty()) {
        return; // нечего обновлять
    }

    // --- 1. Считаем количество (SUM(Amount__c)) через агрегат ---
    List<AggregateResult> results = [
        SELECT Purchase_Id__c purchaseId,
               SUM(Amount__c) totalItems
        FROM PurchaseLine__c
        WHERE Purchase_Id__c IN :purchaseIds
        GROUP BY Purchase_Id__c
    ];

    // --- 2. Считаем общую сумму (Amount * UnitCost) вручную ---
    Map<Id, Decimal> costByPurchase = new Map<Id, Decimal>();

    for (PurchaseLine__c line : [
        SELECT Purchase_Id__c, Amount__c, UnitCost__c
        FROM PurchaseLine__c
        WHERE Purchase_Id__c IN :purchaseIds
    ]) {
        if (line.Purchase_Id__c == null) continue;

        Decimal current = costByPurchase.containsKey(line.Purchase_Id__c)
            ? costByPurchase.get(line.Purchase_Id__c) : 0;

        costByPurchase.put(line.Purchase_Id__c,
            current + ( (line.Amount__c != null ? line.Amount__c : 0) *
                        (line.UnitCost__c != null ? line.UnitCost__c : 0) )
        );
    }

    // --- 3. Собираем обновляемые Purchase ---
    Map<Id, Purchase__c> purchaseMap = new Map<Id, Purchase__c>();

    // инициализируем нулями
    for (Id pid : purchaseIds) {
        purchaseMap.put(pid, new Purchase__c(
            Id = pid,
            TotalItems__c = 0,
            GrandTotal__c = 0
        ));
    }

    // записываем количество из агрегата
    for (AggregateResult ar : results) {
        Id pid = (Id) ar.get('purchaseId');
        Decimal totalItems = (Decimal) ar.get('totalItems');

        if (purchaseMap.containsKey(pid)) {
            purchaseMap.get(pid).TotalItems__c = totalItems != null ? totalItems : 0;
        }
    }

    // записываем сумму (Amount * UnitCost)
    for (Id pid : costByPurchase.keySet()) {
        if (purchaseMap.containsKey(pid)) {
            purchaseMap.get(pid).GrandTotal__c = costByPurchase.get(pid);
        }
    }

    // --- 4. Обновляем ---
    if (!purchaseMap.isEmpty()) {
        update purchaseMap.values();
    }
}