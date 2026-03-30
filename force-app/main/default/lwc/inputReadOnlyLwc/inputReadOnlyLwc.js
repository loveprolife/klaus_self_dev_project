import { LightningElement,api } from 'lwc';

export default class InputReadOnlyLwc extends LightningElement {

    @api label;
    @api value;

    get showLabel() {
        return true && this.label;
    }
}