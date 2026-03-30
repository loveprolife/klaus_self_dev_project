import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordFiles from '@salesforce/apex/FileUploadController.getRecordFiles';
import deleteFileLink from '@salesforce/apex/FileUploadController.deleteFileLink';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class FileUpload extends LightningElement {
    // Public API
    @api recordId;
    @api label = '图片上传';
    @api multiple = false;
    @api accept = '.jpg,.jpeg,.png,.bmp,.pjpeg';
    @api disabled = false;
    @api allowDelete = false;

    get acceptedFormats() {
        // return ['.jpg','.jpeg','.png','.bmp','.pjpeg'];
        return this.accept.split(',');
    }

    // UI state
    @track files = [];
    isLoading = false;

    // Preview state
    showPreview = false;
    previewUrl;

    // Derived
    get showUploader() {
        return !!this.recordId && !this.disabled;
    }

    get uploadButtonLabel() {
        return '选择或拍摄图片';
    }

    get hasFiles() {
        return this.files && this.files.length > 0;
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    // Provide a field for template binding: templates cannot call functions directly
    // so bind to a getter that returns a function, then use property access in template.
    get smallThumbUrlBuilder() {
        return (versionId) => this.buildSmallThumbUrl(versionId);
    }

    connectedCallback() {
        this.loadFiles();
    }

    async loadFiles() {
        if (!this.recordId) return;
        this.isLoading = true;
        try {
            const data = await getRecordFiles({ recordId: this.recordId });
            // Normalize; compose small/large URLs for template binding (no call expressions allowed)
            this.files = (data || []).map((d) => ({
                ...d,
                smallUrl: this.buildSmallThumbUrl(d.contentVersionId),
                largeUrl: this.buildLargeThumbUrl(d.contentVersionId, d.ContentBodyId, d.fileType),
                deletable: this.allowDelete && d.deletable
            }));
        } catch (e) {
            this.showToast('加载失败', this.extractError(e), 'error');
        } finally {
            this.isLoading = false;
        }
        console.log('wwwww----' + JSON.stringify(this.files));
    }

    async handleUploadFinished(event) {
        // 上传完成后，等待平台完成链接建立再刷新，避免 cache 返回旧数据
        try {
            this.showToast('上传成功', '图片已上传', 'success');

            // 等待 ContentDocumentLink 持久化（移动端/社区站点时尤为必要）
            await new Promise((resolve) => setTimeout(resolve, 400));

            // 重新加载文件列表
            await this.loadFiles();

            // 触发一次轻微重渲染，确保 UI 刷新
            this.files = [...this.files];

            // 向父级派发事件
            this.dispatchEvent(new CustomEvent('uploadsuccess', { detail: event.detail.files }));
        } catch (e) {
            this.showToast('刷新失败', this.extractError(e), 'error');
        }
    }

    handlePreview(evt) {
        const versionId = evt.currentTarget?.dataset?.versionId;
        const contentBodyId = evt.currentTarget?.dataset?.contentBodyId;
        const fileType = evt.currentTarget?.dataset?.fileType;
        if (!versionId || !contentBodyId || !fileType) return;
        this.previewUrl = this.buildLargeThumbUrl(versionId, contentBodyId, fileType);
        this.showPreview = true;
    }

    closePreview() {
        this.showPreview = false;
        this.previewUrl = undefined;
    }

    async handleDelete(evt) {
        // 从 data-* 安全读取并去除空白，避免传空导致 Missing ContentDocumentLink Id
        const linkIdRaw = evt.currentTarget && evt.currentTarget.dataset ? evt.currentTarget.dataset.linkId : null;
        const docIdRaw = evt.currentTarget && evt.currentTarget.dataset ? evt.currentTarget.dataset.docId : null;
        const linkId = (linkIdRaw || '').trim();
        const docId = (docIdRaw || '').trim();

        if (!this.allowDelete || !linkId) {
            this.showToast('提示', '未获取到图片关联 Id，无法删除', 'warning');
            return;
        }

        // 简单确认
        // eslint-disable-next-line no-alert
        const ok = confirm('确定删除该图片关联吗？');
        if (!ok) return;

        this.isLoading = true;
        try {
            // 注意：Apex @AuraEnabled 方法的参数传递需要按命名参数对象包装
            const req = { contentDocumentId: docId || null, contentDocumentLinkId: linkId, recordId: this.recordId || null };
            const res = await deleteFileLink(req);
            if (res && res.success) {
                this.showToast('已删除', '图片已移除', 'success');
                await this.loadFiles();
                this.dispatchEvent(new CustomEvent('deletesuccess', { detail: { linkId, docId } }));
            } else {
                throw new Error(res ? res.message : '删除失败');
            }
        } catch (e) {
            this.showToast('删除失败', this.extractError(e), 'error');
            this.dispatchEvent(new CustomEvent('deleteerror', { detail: { message: this.extractError(e) } }));
        } finally {
            this.isLoading = false;
        }
    }

    // Build thumbnail/preview URLs for ContentVersion renditions
    buildSmallThumbUrl(versionId) {
        // Use absolute URL to avoid base path issues in Experience Cloud / mobile
        return `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=${versionId}`;
    }
    buildLargeThumbUrl(versionId, contentBodyId, fileType) {
        // Try FULL first, fallback to JPG at image tag level via onerror handler
        // return `${window.location.origin}/sfc/servlet.shepherd/version/renditionDownload?rendition=FULL&versionId=${versionId}`
         return `/sfc/servlet.shepherd/version/renditionDownload?versionId=${versionId}`+
                `&operationContext=CHATTER&contentId=${contentBodyId}&rendition=ORIGINAL_${fileType}`;
    }

    extractError(e) {
        if (!e) return 'Unknown error';
        if (Array.isArray(e.body)) {
            return e.body.map((x) => x.message).join(', ');
        }
        if (e.body && typeof e.body.message === 'string') return e.body.message;
        if (typeof e.message === 'string') return e.message;
        return 'Unknown error';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}