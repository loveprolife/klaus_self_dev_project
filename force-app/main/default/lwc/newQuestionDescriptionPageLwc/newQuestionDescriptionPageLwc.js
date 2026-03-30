/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Cancel from '@salesforce/label/c.Cancel'
import Save from '@salesforce/label/c.Save'
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK'

export default class NewQuestionDescriptionPageLwc extends LightningNavigationElement {
    label = {
        Cancel,
        Save,
        INSPECTION_REPORT_BACK,
    }

    @api questionDescriptionEn;
    @api questionDescriptionCn;

    handleShowAllPage() {
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    questionDescriptionEn : this.questionDescriptionEn,
                    questionDescriptionCn : this.questionDescriptionCn,
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

    handleChangeQuestionDescriptionCn(event) {
        let value = event.target.value;
        this.questionDescriptionCn = value;
    }

    handleChangeQuestionDescriptionEn(event) {
        let value = event.target.value;
        this.questionDescriptionEn = value;
    }
}