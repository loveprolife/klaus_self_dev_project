/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Cancel from '@salesforce/label/c.Cancel'
import Save from '@salesforce/label/c.Save'
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';

export default class NewHelpTextPageLwc extends LightningNavigationElement {
    label = {
        Cancel,
        Save,
        INSPECTION_REPORT_BACK,
    }

    @api helpTextEn;
    @api helpTextCn;

    handleShowAllPage() {
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    helpTextEn : this.helpTextEn,
                    helpTextCn : this.helpTextCn,
                }
            })
        );
    }

    handleSave() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!',
                variant: 'success'
            }),
        );
    }

    handleChangeHelpTextCn(event) {
        let value = event.target.value;
        this.helpTextCn = value;
    }

    handleChangeHelpTextEn(event) {
        let value = event.target.value;
        this.helpTextEn = value;
    }
}