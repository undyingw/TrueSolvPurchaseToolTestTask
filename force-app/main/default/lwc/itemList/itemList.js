import { LightningElement, track, wire, api } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getItems';
import searchItems from '@salesforce/apex/ItemController.searchItems';
import getItemsByFilter from '@salesforce/apex/ItemController.getItemsByFilter';
import { getRecord } from 'lightning/uiRecordApi';
import ISMANAGER_FIELD from '@salesforce/schema/User.IsManager__c';
import USER_ID from '@salesforce/user/Id';

export default class ItemList extends LightningElement {
    @track items = [];
    @track cart = [];
    @api accountId;

    familyOptions = [
        { label: 'All', value: '' },
        { label: 'Electronics', value: 'Electronics' },
        { label: 'Books', value: 'Books' }
    ];
    typeOptions = [
        { label: 'All', value: '' },
        { label: 'New', value: 'New' },
        { label: 'Used', value: 'Used' }
    ];

    familyValue = '';
    typeValue = '';
    isManager = false;

    // if user is manager
    @wire(getRecord, { recordId: USER_ID, fields: [ISMANAGER_FIELD] })
    wiredUser({ data, error }) {
        if (data) {
            this.isManager = data.fields.IsManager__c.value;
        } else if (error) {
            console.error(error);
        }
    }

    // getting goods
    @wire(getItems)
    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleSearch(event) {
        const key = event.target.value;
        if (key) {
            searchItems({ searchKey: key })
                .then(result => {
                    this.items = result;
                })
                .catch(error => console.error(error));
        } else {
            this.loadItems();
        }
    }

    handleFamily(event) {
        this.familyValue = event.detail.value;
        this.loadItems();
    }

    handleType(event) {
        this.typeValue = event.detail.value;
        this.loadItems();
    }

    loadItems() {
        if (this.familyValue && this.typeValue) {
            getItemsByFilter({ familyValue: this.familyValue, typeValue: this.typeValue })
                .then(result => {
                    this.items = result;
                })
                .catch(error => console.error(error));
        } else {
            getItems()
                .then(result => {
                    this.items = result;
                })
                .catch(error => console.error(error));
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

    handleShowDetails(event) {
        const itemId = event.target.dataset.id;
        this.template.querySelector('c-item-details-modal').openModal(itemId);
    }

    handleOpenCreate() {
        this.template.querySelector('c-create-item-modal').openModal();
    }
}