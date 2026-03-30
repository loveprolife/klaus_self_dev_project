import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import FORM_FACTOR from '@salesforce/client/formFactor';

const popEvent = (_this, evt) => {
    _this.dispatchEvent(evt);
}

const showSuccess = (_this,message)=>{
    const evt = new ShowToastEvent({
        title: ' ',
        message: message,
        variant: 'success'
    });
    popEvent(_this, evt)
}

const showWarning = (_this,message)=>{
    const evt = new ShowToastEvent({
        title: ' ',
        message:  message,
        variant: 'warning'
    });
    popEvent(_this, evt)
}

// const showFail = (_this,message)=>{
//     const evt = new ShowToastEvent({
//         title: 'Fail',
//         message: _this.lwcName + ':' +  message,
//         variant: 'error',
//         mode : 'sticky'
//     });
//     popEvent(_this, evt)
// }

const showError = (_this,message)=>{
    console.log('_this.lwcName------------'+_this.lwcName);
    const evt = new ShowToastEvent({
        title: ' ',
        message: message,
        variant: 'error',
        mode : 'dismissible'
    });
    popEvent(_this, evt)
}

const getErrorMessage = (_this,error,whereStr) => {
    let message = ''
    if (error) {
        do {
            if (error.message) {
                message = error.message;
                break;
            }

            if(error.body) {
                if(error.body.message){
                    message = error.body.message;
                    break;
                }

                if(error.body.fieldErrors && error.body.fieldErrors.length){
                    for (let f in error.body.fieldErrors) {
                        error.body.fieldErrors[f].forEach(element => {
                            message += f + ":" + element.message  + ";";
                        });
                    }
                    break;
                }

                if(error.body.pageErrors && error.body.pageErrors.length){
                    error.body.pageErrors.forEach(element => {
                        message += element.message + ";";
                    });
                    break;
                }
            }

            message = JSON.stringify(error)
        } while (0);
    } else {
        message = 'error';
    }
    
    console.log(message);
    let em = {
        '没有访问权限':/.+没有.+访问权限/,
        'You do not have access' : /You do not have access.+/
    }
    
    for(let k in em){

        if(em[k].test(message)){
            message = k;
        }
    }
    if (!whereStr) {
        whereStr = '';
    }
    message = whereStr + message;
    console.log(message);
    return message;
}

const catchError = (_this,error,whereStr) =>{
    let message = getErrorMessage(_this,error,whereStr);
    // showError(_this,message);
    const evt = new ShowToastEvent({
        title: 'Error',
        message: _this.lwcName ? _this.lwcName + ':' +  message : message,
        variant: 'error',
        mode : 'sticky'
    });
    popEvent(_this, evt)
}

export default class LightningElementEx extends LightningElement {
    @api recordId;
    _browser;
    displayMap = {};

    hasInit;
    get browser() {
    //     if (!this._browser) {
    //         this._browser = dollarA ? dollarA.get('$Browser') : {};
    //     }
    //     return this._browser;
        return {};
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    doInit() {}

    renderedCallback() {
        if (this.recordId && !this.hasInit) {
            this.hasInit = true;
            this.doInit();
        }
    }

    showSuccess(message) {
        showSuccess(this, message);
    }

    showWarning(message) {
        showWarning(this, message);
    }

    
    showError(message) {
        showError(this, message);
    }

    showToast(config) {
        popEvent(this, config);
    }

    catchError(error, message) {
        catchError(this, error, message);
    }

    getErrorMessage(error, message) {
        return getErrorMessage(this, error, message);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async refreshView() {
        await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
    }

    async refreshRecords(ids) {
        await notifyRecordUpdateAvailable(ids.map(iid=>{return {recordId:iid};}));
    }

    hideElement(querySelector) {
        let e = this.template.querySelector(querySelector);
        if (e) {
            this.displayMap[e] = e.style.display;
            e.style.display = 'none'
        }
    }

    showElement(querySelector) {
        let e = this.template.querySelector(querySelector);
        if (e) {
            e.style.display = this.displayMap[e] === undefined ? '' : this.displayMap[e]
        }
    }

    CASESAFEID(id15) {
        if (!id15 || id15.length != 15) {
            return id15;
        }
        
        let addon = "";
        for (let block = 0; block < 3; block++) {
            let loop = 0;
            for (let position = 0; position < 5; position++) {
                let current = id15.charAt(block * 5 + position);
                if (current >= "A" && current <= "Z") loop += 1 << position;
            }
            addon += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(loop);
        }
    
        return id15 + addon;
    }
}