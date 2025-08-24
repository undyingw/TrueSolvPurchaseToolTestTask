import { LightningElement, track } from 'lwc';
export default class CreateItemModal extends LightningElement {
    @track isOpen = false;

    openModal() {
        this.isOpen = true;
    }

    closeModal() {
        this.isOpen = false;
    }

    handleSuccess() {
        this.isOpen = false;
    }
}