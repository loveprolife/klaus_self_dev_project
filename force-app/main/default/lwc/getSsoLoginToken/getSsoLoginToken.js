import { LightningElement } from 'lwc';

const ALLOWED_ORIGINS = [
    // 将允许的来源加入白名单，确保只接收来自目标域的消息
    'https://mail.hisense.com'
];

/**
 * getSsoLoginToken
 * 通过嵌入 iframe 的外部页面并使用 postMessage 获取 ssoLoginToken。
 * 重要：由于同源策略，父页面无法直接读取 iframe 的 cookie，
 * 需要对方页面在拿到 token 后使用 window.parent.postMessage 主动发送给本组件。
 *
 * 期望对方页面发送的消息格式：
 * window.parent.postMessage(
 *   { type: 'ssoToken', ssoLoginToken: 'xxxxx' },
 *   'https://yourLightningDomain.my.site.com' // 或者对应的托管域
 * );
 */
export default class GetSsoLoginToken extends LightningElement {
    isLoading = true;
    token;
    error;

    iframeEl;

    connectedCallback() {
        window.addEventListener('message', this.handleMessage);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage);
    }

    handleIframeLoad = () => {
        // 仅用于 UI 提示加载状态，无法在此读取 iframe cookie
        this.isLoading = false;
    };

    handleMessage = (event) => {
        // 安全校验：仅接收来自白名单来源的消息
        if (!ALLOWED_ORIGINS.includes(event.origin)) {
            return;
        }
        const data = event.data;
        if (!data || typeof data !== 'object') {
            return;
        }
        // 仅处理类型为 ssoToken 的消息
        if (data.type !== 'ssoToken') {
            return;
        }
        const incomingToken = data.ssoLoginToken || (data.payload && data.payload.ssoLoginToken);
        if (!incomingToken || typeof incomingToken !== 'string') {
            this.error = '收到的消息中没有有效的 ssoLoginToken';
            return;
        }

        this.token = incomingToken;
        this.error = undefined;
    };
}