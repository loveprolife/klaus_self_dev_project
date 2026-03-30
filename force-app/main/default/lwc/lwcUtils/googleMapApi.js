export default class GoogleMapApi {

    init(config) {
        this.ele = config.ele;
        this.callback = config.callback;
        this.visualForceOrigin = config.visualForceOrigin;
        this.iframeId = config.iframeId;
        console.log('LwcUtils GoogleMapApi init');
        // 监听事件
        const iframe = this.ele.template.querySelector("iframe[name='"+this.iframeId+"']");
        
        window.addEventListener('message', (event) => {
            console.log('=====> LWC get data from VF <=====');
            console.log('Child Component Origin: ', JSON.stringify(event.origin));
            console.log('Message from Child Component: ', JSON.stringify(event.data));
            // if (event.origin !== this.visualForceOrigin.data) return;
            if (typeof(event.data) != 'string') {
                
                return ;
            }
            var dataMsg = JSON.parse(event.data);
            // if (event.data.key === 'GOOGLE_MAP_API') {
            //     this.callback(event.data.info, this.ele);
            // }
            if (dataMsg.key === 'GOOGLE_MAP_API') {
                this.callback(dataMsg.info, this.ele);
            }
        });
    }

    // Post Message
    sendMessageToChild(info) {
        this.ele = info.ele;
        this.iframeId = info.iframeId;
        this.data = info.data;

        const iframe = this.ele.template.querySelector("iframe[name='"+this.iframeId+"']");
        const message = {
            key: 'GOOGLE_MAP_API',
            info: JSON.stringify(this.data)
        };
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.postMessage(JSON.stringify(message), '*');
        }
        
    }
}