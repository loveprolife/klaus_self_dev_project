/*
 * @Author: WFC
 * @Date: 2025-11-27 09:45:20
 * @LastEditors: Do not edit
 * @LastEditTime: 2026-01-27 16:21:01
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\qbiEmbed\qbiEmbed.js
 */
import { LightningElement, api, wire, track } from 'lwc';
// 导入Apex方法
import getCurrentUserLanguage from '@salesforce/apex/UserLangController.getCurrentUserLanguage';

export default class QbiEmbed extends LightningElement {
    // 基础 QBI URL，可在页面构建器中配置
    @api qbiUrl = '';
    @api cardTitle = '';
    @api showFooter = false;
    @api iconName = '';

    // 控制是否在 src 上追加参数
    @api appendParams = false;

    // 传参方式一：以 key=value&key2=value2 的形式传入，便于管理员在页面构建器上配置
    // 例如：reportId=abc123&lang=zh-CN
    @api queryString;

    // 传参方式二：传入 JSON 字符串，支持复杂对象，组件内部会扁平化到查询参数
    // 例如：{"reportId":"abc123","filters":{"country":"CN","year":2026}}
    @api queryParamsJson;

    // 可选：当需要覆盖已有同名参数时，是否允许覆盖（默认 true）
    // LWC 要求 @api 暴露的布尔属性默认值必须为 false（LWC1099），此处遵循规则，默认 false。
    // 若需要开启覆盖，请在页面构建器中勾选该布尔属性。
    @api allowOverride = false;

    // 多语言参数
    @api languageName = 'languageCode';
    @api languageLocale;

    _height = '480px';
    @api
    set Height(value) {
        this._height = value + 'px';
    }
    get Height() {
        return this._height;
    }

    // 嵌入地址
    @track computedSrc;
    // 当前用户信息
    @track user;

    // 调用Apex获取语言
    @wire(getCurrentUserLanguage)
    wiredUserLang({ data, error }) {
        if (data) {
            if (this.languageLocale == null || this.languageLocale == '' || this.languageLocale == undefined) {
                this.languageLocale = data.language;
            }
            this.user = data.user;
            console.log('wwww兜底方案获取的用户纯语言：', this.languageLocale);
            this.computedSrc = this.getComputedSrc();
        } else if (error) {
            console.error('wwww获取语言失败：', error);
            this.languageLocale = 'en_GB'; // 兜底默认值
            this.computedSrc = this.getComputedSrc();
        }
    }

    getComputedSrc() {
        if (!this.qbiUrl) return '';
        // this.qbiUrl = this.qbiUrl + '?languageCode=' + this.languageLocale;
        this.qbiUrl = `${this.qbiUrl}?${this.languageName}=${this.languageLocale}`;
        // qbi嵌入需要LDAP和sbu参数
        if (this.user) {
            this.qbiUrl = `${this.qbiUrl}&LDAP=${this.user.FederationIdentifier}&sbu=${this.user.Sales_Region__c}`;
        }
        console.log('wwww--开始：' + new URL(this.qbiUrl));
        if (!this.appendParams) return this.qbiUrl;

        try {
            const url = new URL(this.qbiUrl);

            // 1) 先解析 queryString（key=value&key2=value2）
            if (this.queryString) {
                // 将 & 误编码纠正为 &
                const normalized = this.queryString.replace(/&/g, '&').replace(/\s+/g, ' ');
                const pairs = normalized.split('&').filter(Boolean);
                for (const p of pairs) {
                    const [kRaw, vRaw] = p.split('=');
                    if (!kRaw) continue;
                    const key = decodeURIComponent(kRaw);
                    const val = vRaw !== undefined ? decodeURIComponent(vRaw) : '';
                    if (this.allowOverride || !url.searchParams.has(key)) {
                        url.searchParams.set(key, val);
                    }
                }
            }

            // 2) 再解析 JSON（深度展开为 a.b=c 的结构或直接序列化为字符串）
            if (this.queryParamsJson) {
                let obj;
                try {
                    obj = typeof this.queryParamsJson === 'string'
                        ? JSON.parse(this.queryParamsJson)
                        : this.queryParamsJson;
                } catch (e) {
                    // 非法 JSON，作为字符串传递
                    if (this.allowOverride || !url.searchParams.has('params')) {
                        url.searchParams.set('params', String(this.queryParamsJson));
                    }
                    return url.toString();
                }

                const appendKv = (k, v) => {
                    if (v === null || v === undefined) return;
                    const value = typeof v === 'object' ? JSON.stringify(v) : String(v);
                    if (this.allowOverride || !url.searchParams.has(k)) {
                        url.searchParams.set(k, value);
                    }
                };

                const flatten = (prefix, value) => {
                    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
                        for (const childKey of Object.keys(value)) {
                            const nextKey = prefix ? `${prefix}.${childKey}` : childKey;
                            flatten(nextKey, value[childKey]);
                        }
                    } else {
                        appendKv(prefix, value);
                    }
                };

                if (obj && typeof obj === 'object') {
                    flatten('', obj);
                }
            }

            console.log('wwww----' + url.toString());
            return url.toString();
        } catch (e) {
            console.log('wwww----' + this.qbiUr);
            // 非法 URL 时，直接返回原字符串便于排查
            return this.qbiUrl;
        }
    }

    renderedCallback() {
        var reportContainer = this.template.querySelector('.frame-wrap');
        reportContainer.style.height = this.Height;
    }

}