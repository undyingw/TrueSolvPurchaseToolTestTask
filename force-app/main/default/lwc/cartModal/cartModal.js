import { LightningElement, api, track } from 'lwc';
import createPurchase from '@salesforce/apex/PurchaseController.createPurchase';

export default class CartModal extends LightningElement {
    @api accountId;
    @track cart = [];
    @track isOpen = false;

    // Колонки для таблицы
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Amount', fieldName: 'amount', type: 'number' },
        { label: 'Unit Price', fieldName: 'Price__c', type: 'currency' },
        { label: 'Total', fieldName: 'totalPrice', type: 'currency' }
    ];

    openModal(cart) {
        // Добавляем вычисляемое поле totalPrice
        this.cart = cart.map(c => ({
            ...c,
            totalPrice: c.amount * c.Price__c
        }));
        this.isOpen = true;
    }

    closeModal() {
        this.isOpen = false;
    }

    handleCheckout() {
        let payload = [];
        this.cart.forEach(c => {
            payload.push({ itemId: c.Id, amount: c.amount, unitCost: c.Price__c });
        });

        createPurchase({ accountId: this.accountId, cart: payload })
            .then(purchaseId => {
                window.open('/' + purchaseId, '_blank');
                this.isOpen = false;
            })
            .catch(error => {
                console.error('Error creating purchase', error);
            });
    }
}