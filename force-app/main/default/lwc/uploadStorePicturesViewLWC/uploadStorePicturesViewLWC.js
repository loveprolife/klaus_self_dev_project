import { LightningElement, track, wire,api } from 'lwc';
import {LightningNavigationElement} from 'c/lwcUtils'
import getContentVersionIdListById from '@salesforce/apex/uploadStorePicturesController.getContentVersionIdListById';
import isCurrentUserView from '@salesforce/apex/uploadStorePicturesController.isCurrentUserView';
import Store_Pic_Title from '@salesforce/label/c.Store_Pic_Title';


export default class uploadStorePicturesViewLWC extends LightningNavigationElement {

	get shorePicTitle() {
		return this.showLabel ? Store_Pic_Title : '';
	}

	@api recordId;
	@api showLabel;
	@track recordIds = [];
	@track isShowPic = false;
	notupload = false;

	@api getImagesCount() {
		return this.recordIds ? this.recordIds.length : 0;
	}

	connectedCallback() {
		console.log('this.recordId========'+this.recordId);
		if (this.recordId == undefined || this.recordId == null || this.recordId == '') {
			this.showError('No Record!');
		}else{
			// isCurrentUserView().then(re=>{
			// 	console.log('当前用户是否能看到？'+re.data);
			// 	if (re.isSuccess) {
			// 		if (re.data) {
						getContentVersionIdListById({recordId : this.recordId}).then(res=>{
										if (res.isSuccess) {
											this.recordIds = res.data;
											console.log('this.recordIds====='+this.recordIds);
											if (this.recordIds.length > 0) {
												this.isShowPic = true;
											}
										}else{
											this.showError('系统异常：'+res.message);
										}
									})
			// 		}
			// 	}
			// })

									
		}

	}


	handleSelectFiles(event) {
        console.log(event.detail);
    }

}