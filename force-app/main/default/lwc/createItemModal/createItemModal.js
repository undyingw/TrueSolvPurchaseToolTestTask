import getImageUrl from '@salesforce/apex/UnsplashService.getImageUrl';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Item__c.Id';
import IMAGE_FIELD from '@salesforce/schema/Item__c.Image__c';
import { LightningElement, api, track } from 'lwc';

export default class CreateItemModal extends LightningElement {
    @track isOpen = false;

    @api openModal() {
        this.isOpen = true;
    }

    @api closeModal() {
        this.isOpen = false;
    }

    handleSuccess(event) {
        const itemId = event.detail.id;
        const itemName = event.detail.fields.Name.value;

        // обращаемся к Unsplash
        getImageUrl({ query: itemName })
            .then(url => {
                if (url) {
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = itemId;
                    fields[IMAGE_FIELD.fieldApiName] = url;

                    const recordInput = { fields };
                    updateRecord(recordInput);
                }
            })
            .catch(err => console.error(err));

        this.isOpen = false;
    }
}