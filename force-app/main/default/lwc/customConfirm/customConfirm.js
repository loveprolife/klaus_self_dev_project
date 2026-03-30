import { LightningElement, api } from 'lwc';

export default class CustomConfirm extends LightningElement {
    @api modalTitle = '确认';
    @api message = '';
    @api confirmLabel = '是';
    @api cancelLabel = '否';
    
    // 关闭模态框
    close(result) {
        // 触发自定义事件通知父组件
        this.dispatchEvent(new CustomEvent('confirmclosed', { 
            detail: { confirmed: result } 
        }));
        // 关闭模态框
        const modal = this.template.querySelector('lightning-modal');
        if (modal) {
            modal.close();
        }
    }
    
    handleConfirm() {
        this.close(true);
    }
    
    handleCancel() {
        this.close(false);
    }
    
    handleClose() {
        this.close(false);
    }
}