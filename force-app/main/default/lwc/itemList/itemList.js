import { LightningElement, track, wire, api } from 'lwc';
import getItems from '@salesforce/apex/ItemController.getAllItems';
import searchItems from '@salesforce/apex/ItemController.searchItems';
import getItemsByFilter from '@salesforce/apex/ItemController.getItemsByFilter';
import { getRecord } from 'lightning/uiRecordApi';
import ISMANAGER_FIELD from '@salesforce/schema/User.isManager__c';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import NUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

export default class ItemList extends LightningElement {
    @track items = [];
    @track cart = [];
    @api recordId;

    // данные аккаунта
    @track accountName;
    @track accountNumber;
    @track accountIndustry;

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

    // Если юзер менеджер
    @wire(getRecord, { recordId: USER_ID, fields: [ISMANAGER_FIELD] })
    wiredUser({ data, error }) {
        if (data && data.fields && data.fields.isManager__c) {
            this.isManager = data.fields.isManager__c.value;
        } else if (error) {
         console.error(error);
        }
    }

    // Аккаунт
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, NUMBER_FIELD, INDUSTRY_FIELD] })
    wiredAccount({ data, error }) {
        if (data && data.fields) {
            this.accountName = data.fields.Name ? data.fields.Name.value : null;
            this.accountNumber = data.fields.AccountNumber ? data.fields.AccountNumber.value : null;
            this.accountIndustry = data.fields.Industry ? data.fields.Industry.value : null;
        } else if (error) {
            console.error(error);
        }
    }

    // Получение всех товаров
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