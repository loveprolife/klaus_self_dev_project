import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import FORM_FACTOR from '@salesforce/client/formFactor';
import INSPECTION_REPORT_MSG_Cancel from '@salesforce/label/c.INSPECTION_REPORT_MSG_Cancel';
import INSPECTION_REPORT_MSG_Ok from '@salesforce/label/c.INSPECTION_REPORT_MSG_Ok';

export default class ModalLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_MSG_Cancel,
        INSPECTION_REPORT_MSG_Ok
    }
    @api staticMode;
    @api hideOk;
    @api okLabel;
    @api hideClose;
    @api closeLabel;
    @api hideCloseIcon;
    @api styleWidth;
    // @api styleHeight;
    get modalHeight() {
        var height = 'height: 100%';
				
        try {
            if (this.root) {
                var doc = document.documentElement.clientHeight;
    
                var rooth = this.root.childNodes[0].offsetHeight
                height = doc<rooth ? 'height: '+rooth+'px;' : 'height: 100%;';
            }
        } catch (error) {
            
        }
				
        return height;
    }
    
    @track root;
    

    get displayCloseIcon() {
        return !this.hideCloseIcon;
    }

    get containerStyle() {
        return this.styleWidth ? 'style="width: ' + this.styleWidth + ';max-width:' + this.styleWidth + '"' : '';
    }

    get hasFooter() {
        return !(this.hideClose && this.hideOk);
    }

    openModal;
    get openStatus() {
        return this.staticMode || this.openModal;
    }

    get modalClass() {
        let cls = "slds-modal slds-backdrop ";
        if (this.openModal) {
            cls += ' slds-fade-in-open'
        } else {
            cls += ' slds-fade-in-close'
        }
        return cls;
    }

    get mobileButton() {
        let cls = "";
        console.log('FORM_FACTOR：' + FORM_FACTOR);
        if (FORM_FACTOR === 'Small') {
            cls += 'padding: 0 0.6rem; line-height: 1.8rem; font-size: 13px; margin: 0 0.5rem; ';
        }

        // cls += 'padding: var(--slds-c-button-spacing, var(--sds-c-button-spacing, 0));';
        // cls += 'line-height: var(--slds-c-button-line-height, var(--sds-c-button-line-height, 0));';

        return cls;
    }

    @api title;
		
    connectedCallback() {
        if (!this.okLabel) {
            this.okLabel = 'OK';
        }

        if (!this.closeLabel) {
            this.closeLabel = 'Close';
        }
    }


    @api
    showModal(ele) {
        this.root = ele;
        if (this.openModal) {
            return;
        }
        this.openModal = true;
        //this.dispatchEvent(new CustomEvent('show'));
    }

    handleClose() {
        if (this.closeModal()) {
            this.dispatchEvent(new CustomEvent('close'));
        }
    }

    @api
    closeModal() {
        if (!this.openModal) {
            return false;
        }
        this.openModal = false;
        return true;
    }

    handleOk() {
        this.dispatchEvent(new CustomEvent('ok'));
    }
}