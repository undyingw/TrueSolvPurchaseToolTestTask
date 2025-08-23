import { LightningElement, api, track } from 'lwc';
import createPurchase from '@salesforce/apex/PurchaseController.createPurchase';

export default class CartModal extends LightningElement {
    @api accountId;
    @track cart = [];
    @track isOpen = false;

    openModal(cart) {
        this.cart = cart;
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
            });
    }
}