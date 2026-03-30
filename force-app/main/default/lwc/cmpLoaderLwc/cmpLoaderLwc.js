import { LightningElement, api } from 'lwc';

export default class CmpLoaderLwc extends LightningElement {

    //@api cmp;
    @api lwcName;
    @api events;
    @api para;
    componentConstructor;
    loaded;

    get eventArr() {
        return this.events ? (this.events + '').split(',') : [];
    }
    // Use connectedCallback() on the dynamic component
    // to signal when it's attached to the DOM
    connectedCallback() {
        if (this.lwcName) {
            import(this.lwcName)
            .then(({ default: ctor }) => {
                this.componentConstructor = ctor;
                // ctor
            })
            .catch((err) => {
                let msg = ''
                if (err) {
                    msg = JSON.stringify(err);
                } else {
                    msg = "Error importing component";
                }
                console.log(msg);
                this.dispatchEvent(new CustomEvent('load',{
                    detail: {
                        isSuccess : false,
                        message : 'lwcName is blank'
                    }
                }));
            });
        } else {
            this.dispatchEvent(new CustomEvent('load',{
                detail: {
                    isSuccess : false,
                    message : 'lwcName is blank'
                }
            }));
        }
    }

    renderedCallback() {
        // this.refs.myCmp will be available on the next rendering cycle after the constructor is set
        if (!this.loaded && this.refs.cmp) {
            this.loaded = true;
            console.log(this.refs.cmp);
            // this.refs.myCmp will contain a reference to the DOM node
            for (let index = 0; index < this.eventArr.length; index++) {
                const element = this.eventArr[index];
                if (element) {
                    this.refs.cmp.addEventListener(element, (evt) => {
                        // console.log("Notification event", evt);
                        this.dispatchEvent(new CustomEvent(element, evt));
                    });
                }
            }
            
            this.dispatchEvent(new CustomEvent('load',{
                detail: {
                    ref : this.refs.cmp,
                    isSuccess : true
                }
            }));
        }
    }
}