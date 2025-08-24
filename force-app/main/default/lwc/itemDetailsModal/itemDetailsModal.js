import { LightningElement, track } from 'lwc';
import getItemDetails from '@salesforce/apex/ItemController.getItemDetails';

export default class ItemDetailsModal extends LightningElement {
    @track isOpen = false;
    @track item;

    openModal(itemId) {
        getItemDetails({ itemId })
            .then(result => {
                this.item = result;
                this.isOpen = true;
            });
    }

    closeModal() {
        this.isOpen = false;
    }
}