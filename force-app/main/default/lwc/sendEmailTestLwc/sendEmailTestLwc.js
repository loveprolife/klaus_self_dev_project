import { LightningElement, track } from 'lwc';
import sendData from '@salesforce/apex/SendEmailTestController.sendData';

export default class MyComponent extends LightningElement {
    @track roomId = '';
    @track template = '';

    handleRoomIdChange(event) {
        this.roomId = event.target.value;
    }

    handleEmailChange(event) {
        this.template = event.target.value;
    }

    handleSubmit() {
        sendData({ roomId: this.roomId, template: this.template })
            .then(result => {
                // Handle success
                console.log('Data sent successfully');
            })
            .catch(error => {
                // Handle error
                console.error('Error sending data', error);
            });
    }
}