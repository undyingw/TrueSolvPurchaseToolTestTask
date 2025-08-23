import { LightningElement, track, wire } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';

export default class ItemList extends LightningElement {
    @track items = [];
    @track cart = [];

    @wire(getItems)
    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleAddToCart(event) {
        const itemId = event.target.dataset.id;
        const item = this.items.find(i => i.Id === itemId);

        let existing = this.cart.find(c => c.Id === itemId);
        if (existing) {
            existing.amount += 1;
        } else {
            this.cart.push({ ...item, amount: 1 });
        }
    }

    handleOpenCart() {
        this.template.querySelector('c-cart-modal').openModal(this.cart);
    }
}