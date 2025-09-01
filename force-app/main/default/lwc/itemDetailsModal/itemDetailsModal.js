import getItemDetails from '@salesforce/apex/ItemController.getItemDetails';
import { LightningElement, api, track } from 'lwc';

export default class ItemDetailsModal extends LightningElement {
    @track isOpen = false;
    @track item;

    @api openModal(itemId) {
        getItemDetails({ itemId: itemId })
            .then(result => {
                this.item = result;
                this.isOpen = true;
            })
            .catch(error => {
                console.error('Error loading item details', error);
            });
    }

    @api closeModal() {
        this.isOpen = false;
    }
}