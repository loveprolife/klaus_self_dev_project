/*
 * @Author: WFC
 * @Date: 2026-03-02 15:55:32
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-03 16:04:57
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\googleMapExplorer\googleMapExplorer.js
 */
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GOOGLE_MAPS_IFRAME from '@salesforce/resourceUrl/GoogleMapsIframe';

// const GOOGLE_MAPS_API_KEY = 'AIzaSyAevReUCBK5ntbBf525M-O31NcDc_Q-130';
const GOOGLE_MAPS_API_KEY = 'AIzaSyAcOEfLoy_AJ_9SjrdbbPQLyTqGQWwkPiU';
export default class GoogleMapExplorer extends LightningElement {
    @track iframeUrl;
    @track isLoading = true;
    @track searchQuery = '';
    @track markers = [];
    @track selectedMarkerIndex = -1;

    iframe;
    messageHandler;

    connectedCallback() {
        // 构建 iframe URL
        this.iframeUrl = GOOGLE_MAPS_IFRAME + '/google-map-iframe.html';
    }

    renderedCallback() {
        // 获取 iframe 元素
        this.iframe = this.template.querySelector('iframe');
        
        // 设置消息监听
        if (!this.messageHandler) {
            this.messageHandler = this.handleIframeMessage.bind(this);
            window.addEventListener('message', this.messageHandler);
        }
    }

    disconnectedCallback() {
        // 清理消息监听
        if (this.messageHandler) {
            window.removeEventListener('message', this.messageHandler);
            this.messageHandler = null;
        }
    }

    handleIframeMessage(event) {
        // 验证消息来源
        if (event.source !== this.iframe?.contentWindow) return;

        const data = event.data;
        
        switch (data.type) {
            case 'mapLoaded':
                this.isLoading = false;
                this.showToast('成功', '地图加载完成', 'success');
                break;
                
            case 'markerSelected':
                this.handleMarkerSelected(data.data);
                break;
                
            case 'markerUpdated':
                this.handleMarkerUpdated(data.data);
                break;
                
            case 'markersData':
                this.markers = data.data;
                break;
                
            case 'markersCleared':
                this.markers = [];
                this.selectedMarkerIndex = -1;
                break;
        }
    }

    handleMarkerSelected(markerData) {
        const index = this.markers.findIndex(m => m.id === markerData.id);
        if (index !== -1) {
            this.selectedMarkerIndex = index;
        }
        
        this.showToast('信息', `选中: ${markerData.title}`, 'info');
    }

    handleMarkerUpdated(markerData) {
        const index = this.markers.findIndex(m => m.id === markerData.id);
        if (index !== -1) {
            this.markers = [
                ...this.markers.slice(0, index),
                markerData,
                ...this.markers.slice(index + 1)
            ];
        }
    }

    handleSearchInput(event) {
        this.searchQuery = event.target.value;
    }

    handleSearchKeyup(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    handleSearch() {
        if (!this.searchQuery || !this.iframe) return;
        
        this.iframe.contentWindow.postMessage({
            type: 'search',
            query: this.searchQuery
        }, '*');
    }

    getCurrentLocation() {
        if (this.iframe) {
            this.iframe.contentWindow.postMessage({
                type: 'getCurrentLocation'
            }, '*');
        }
    }

    clearAllMarkers() {
        if (this.iframe) {
            this.iframe.contentWindow.postMessage({
                type: 'clearMarkers'
            }, '*');
        }
    }

    handleDeleteMarker(event) {
        const markerId = event.target.dataset.id;
        // 这里需要 iframe 支持删除特定标记的功能
        // 可以扩展 iframe 的消息处理来支持
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}