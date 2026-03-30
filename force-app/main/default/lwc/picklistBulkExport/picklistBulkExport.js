import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import exportPicklists from '@salesforce/apex/PicklistBulkExportController.exportPicklists';

export default class PicklistBulkExport extends NavigationMixin(LightningElement) {
    objectNames = '';

    handleChange(e) {
        this.objectNames = e.target.value;
    }

    async download() {
        const csv = await exportPicklists({ objectNames: this.objectNames });
        if (!csv) return;
        const blob = new Blob([csv], { type: 'text/plain' }); // 关键改动
        const url  = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `picklists_${new Date().toISOString().slice(0,19)}.csv`;
        link.click();
        URL.revokeObjectURL(url);
    }
}