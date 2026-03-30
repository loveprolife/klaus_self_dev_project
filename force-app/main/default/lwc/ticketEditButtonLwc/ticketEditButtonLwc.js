import { LightningNavigationElement } from 'c/lwcUtils';
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import Ticket_Feedback_Reminder from '@salesforce/label/c.Ticket_Feedback_Reminder';
import Ticket_Error_Assigned from '@salesforce/label/c.Ticket_Error_Assigned';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';

import saveRecord from '@salesforce/apex/TicketResolvedButtonController.editSaveRecord';
import getInitData from '@salesforce/apex/TicketResolvedButtonController.editGetInitData';

export default class TicketResolvedButtonLwc extends LightningNavigationElement {

    @api lwcName = 'TicketResolvedButtonLwc';

    @api recordId;

    @track displaySaveButton;
    @track readonly;

    @track isOwner;
    @track isFelipe;
    @track isAssigned;
    @track oldStatus;
    @track ticket = {
        index: 0
    };

    @track isChile;
    @track fields = {};
    @track isShowSpinner = false;

    // AfterSalesService = [];
    // Agency = [];
    // Marketing = [];
    // Sales = [];

    label = {INSPECTION_REPORT_MSG_DEPARTMENT_USER};

    connectedCallback() {
        this.isShowSpinner = true;
        console.log('connectedCallback!! ——> recordId：' + this.recordId);
        if (this.recordId) {
            getInitData({
                recordId: this.recordId,
            }).then(data => {
                console.log('getInitData：');
                if (data.isSuccess) {
                    for (let key in data.data) {
                        this[key] = data.data[key];
                    }
                    this.displaySaveButton = (data.data.isOwner || data.data.isAssigned || data.data.isFelipe);
                    this.readonly = !this.displaySaveButton;
                    this.oldStatus = this.ticket.Status__c;
                    console.log('isChile: ' + this.isChile);
                    this.isShowSpinner = false;
                } else {
                    this.showError(data.message);
                }
            })
        }
        this.isShowSpinner = false;
    }

    yes(event) {
        this.isShowSpinner = true;
        let checkResult = this.saveCheck();
        if (checkResult.flag) {
            if (this.ticket.isUpdated || this.departmentTicket) {
                console.log('update ticket:  ' + JSON.stringify(this.ticket));
                saveRecord({
                    recordJson: JSON.stringify(this.ticket),
                }).then(rs => {
                    this.isShowSpinner = false;
                    if (rs.isSuccess) {
                        console.log('rs：' + JSON.stringify(rs));
                        console.log('rs.message：' + rs.message);
                        const event = new ShowToastEvent({
                            title: 'result',
                            variant: 'success',
                            message: rs.message
                        });
                        // if (rs.code != 0) {
                        //     event.variant = 'error';
                        // }
                        this.dispatchEvent(new CustomEvent('refreshview'));
                        this.dispatchEvent(event);
                        this.dispatchEvent(new CloseActionScreenEvent());
                        this.dispatchEvent(new CustomEvent('closemodal'));
                        // window.location.reload();
                    } else {
                        this.showError(rs.message);
                    }
                });
            } else {
                this.isShowSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(new CustomEvent('closemodal'));
            }
        } else {
            this.showError(checkResult.message);
            this.isShowSpinner = false;
        }

    }

    cancel(event) {
        console.log("cancel:");
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    get options() {
        if (this.isOwner || this.isFelipe) {
            return [
                { label: 'Open', value: 'Open' },
                { label: 'Closed', value: 'Closed' },
            ];
        } else {
            return [
                { label: 'Open', value: 'Open' },
                { label: 'Resolved', value: 'Resolved' },
            ];
        }

    }

    handleChange(event) {
        this.ticket.Status__c = event.detail.value;
        this.ticket.isUpdated = true;
    }

    handleFieldChange(event) {
        console.log('event.target.value：' + event.target.value);
        this.ticket[event.target.dataset.fieldName] = event.target.value;
        this.ticket.isUpdated = true;
    }

    // 添加用户（自定义lookupFilter）
    // lookupUserFilter = {
    //     'lookup': 'CustomLookupProvider.UserFilter'
    // }
    // handleTicketAssignedToChange(event) {
    //     console.log('handleTicketAssignedToChange -----：');
    //     if (event.detail.selectedRecord == undefined) {
    //         this.ticket.AssignedTo__c = null;
    //     } else {
    //         this.ticket.AssignedTo__c = event.detail.selectedRecord.Id;
    //     }
    //     this.ticket.isUpdated = true;
    // }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

    saveCheck() {
        let result = {
            flag: true,
            message: '',
        }
        if ((this.oldStatus != this.ticket.Status__c) && (!this.isFilledOut(this.ticket.Newest_Feedback__c))) {
            result.flag = false;
            // result.message = 'Status Changed, Feedback is required!';
            result.message = Ticket_Feedback_Reminder;
        }

        if ((!this.isChile) && (!this.isFilledOut(this.ticket.AssignedTo__c))) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.AssignedTo__c;
            return result;
        }

        if ((this.isChile) && (!this.isFilledOut(this.ticket.AssignedTo__c) && !this.isFilledOut(this.ticket.Department__c))) {
            result.flag = false;
            result.message = Ticket_Fields_Check.format(this.fields.AssignedTo__c, this.fields.Department__c);
            return result;
        }

        // if (this.isFilledOut(this.ticket.Department__c) && this.isFilledOut(this.ticket.AssignedTo__c)) {
        //     let userMatch = false;
        //     console.log('Department User List: ' + this[this.ticket.Department__c]);
        //     console.log('AssignedTo__c: ' + this.ticket.AssignedTo__c);
        //     if (this[this.ticket.Department__c].length > 0) {
        //         for (let index = 0; index < this[this.ticket.Department__c].length; index++) {
        //             console.log('this[this.ticket.Department__c][index]: ' + this[this.ticket.Department__c][index]);
        //             if (this[this.ticket.Department__c][index] == this.ticket.AssignedTo__c) {
        //                 userMatch = true;
        //             }
        //         }
        //     }

        //     if (!userMatch) {
        //         result.flag = false;
        //         result.message = Ticket_Error_Assigned;
        //         return result;
        //     }
        // }
        return result;
    }

}