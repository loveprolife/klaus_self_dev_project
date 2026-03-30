/*
 * @Author: WFC
 * @Date: 2026-01-12 14:19:01
 * @LastEditors: WFC
 * @LastEditTime: 2026-01-13 10:38:59
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\ssoTokenBridge\ssoTokenBridge.js
 */
import { LightningElement, api } from 'lwc';

const ALLOWED_ORIGINS = [
    // 将允许的来源加入白名单，确保只接收来自目标域的消息
    'https://mail.hisense.com'
];

/**
 * ssoTokenBridge
 * 桥接组件，用于从第三方iframe页面获取SSO登录令牌。
 * 该组件作为中间层，接收来自iframe的postMessage消息，并转发给调用方。
 */
export default class SsoTokenBridge extends LightningElement {
    @api targetOrigin = '*'; // 目标域，用于安全验证
    @api messageType = 'ssoToken'; // 消息类型
    
    token;
    error;
    
    connectedCallback() {
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    handleMessage = (event) => {
        console.log('wwwww11111');
        // 安全校验：仅接收来自白名单来源的消息
        if (this.targetOrigin !== '*' && !ALLOWED_ORIGINS.includes(event.origin)) {
            return;
        }
        
        const data = event.data;
        if (!data || typeof data !== 'object') {
            return;
        }
        
        // 仅处理指定类型的消息
        if (data.type !== this.messageType) {
            return;
        }
        
        const incomingToken = data.ssoLoginToken || (data.payload && data.payload.ssoLoginToken);
        if (!incomingToken || typeof incomingToken !== 'string') {
            this.error = '收到的消息中没有有效的 ssoLoginToken';
            this.dispatchTokenEvent();
            return;
        }

        this.token = incomingToken;
        this.error = undefined;
        this.dispatchTokenEvent();
    };

    dispatchTokenEvent() {
        const tokenEvent = new CustomEvent('tokengot', {
            detail: {
                token: this.token,
                error: this.error
            }
        });
        this.dispatchEvent(tokenEvent);
    }
}