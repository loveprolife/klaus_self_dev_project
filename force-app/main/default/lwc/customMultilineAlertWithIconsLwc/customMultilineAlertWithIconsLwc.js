import { LightningElement, api } from 'lwc';

export default class CustomMultilineAlertWithIcons extends LightningElement {
    @api message;
    @api title;
    @api iconType = 'success'; // 默认图标类型为成功

    // 关闭模态框的方法
    handleClose() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    // 将消息字符串根据换行符分割成数组
    get lines() {
        return this.message ? this.message.split('\n') : [];
    }

    // 根据图标类型获取对应的 SLDS 图标类名和图标链接
    get iconInfo() {
        switch (this.iconType) {
            case 'success':
                return {
                    class: 'slds-icon-utility-success',
                    link: 'success'
                };
            case 'info':
                return {
                    class: 'slds-icon-utility-info',
                    link: 'info'
                };
            default:
                return {
                    class: 'slds-icon-utility-success',
                    link: 'success'
                };
        }
    }
}