import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import NUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

export default class AccountPurchaseApp extends LightningElement {
    @api recordId;
    @track account;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, NUMBER_FIELD, INDUSTRY_FIELD] })
    wiredAccount({ data, error }) {
        if (data) {
            this.account = {
                Name: data.fields.Name.value,
                AccountNumber: data.fields.AccountNumber.value,
                Industry: data.fields.Industry.value
            };
        } else if (error) {
            console.error(error);
        }
    }
}