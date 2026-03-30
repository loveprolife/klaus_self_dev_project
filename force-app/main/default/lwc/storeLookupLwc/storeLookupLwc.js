/*
API : 50
Source : lwcFactory.com
*/
import {LightningElement,api,wire} from "lwc";
// import apex method from salesforce module
import getLookupData from "@salesforce/apex/LookupController.getLookupData";
import getDefaultRecord from "@salesforce/apex/LookupController.getDefaultRecord";
// import getIconName from "@salesforce/apex/LookupController.getIconName";
import CUSTOMLOOKUP_SEARCH from '@salesforce/label/c.CUSTOMLOOKUP_SEARCH';

const DELAY = 300; // dealy apex callout timing in miliseconds
let getNameFoo = null;
class Model {
	getNameFun;
	constructor(obj) {
		for (let key in obj) {
			this[key] = obj[key];
		}
		// this.getNameFun = getNameFun;
	}

	get displayName() {
		let name = this.Name;
		
		if (getNameFoo) {
			name = getNameFoo(this);
		}
		if (!name) {
			name = this.Id;
		}
		if(this.Name_Description__c && this.Name_Description__c != ''){
			name = this.Name_Description__c + '-' + name;
		}
		return name;
	}
}
export default class StoreLookupLwc extends LightningElement {
	// public properties with initial default values
	@api label = "";
	@api placeholder = this.CUSTOMLOOKUP_SEARCH;
	@api readOnly;
	@api showLabel = false;
	@api objName = "Account";
	@api recordId = "";
	@api noRecordTips = "No Records Found....";
	@api getNameFun;
	@api dropDownStyle;
	@api op = {};
	option = {};
	@api updateOption(op) {
		this.option = op;
	}
	isSearch = false;
	// private properties
	lstResult = []; // to store list of returned records
	@api searchKey = ""; // to store input field value
	isSearchLoading = false; // to control loading spinner
	delayTimeout;
	selectedRecord = {}; // to store selected lookup record in object formate

	get drpDwnStl() {
		let style = 'margin-top:0px;'
		if (this.dropDownStyle) {
			style += this.dropDownStyle;
		}
		return style;
	}
	get hasRecords() {
		return this.lstResult && this.lstResult.length > 0;
	}

	get optionJson() {
		return JSON.stringify(this.option);
	}

	// initial function to populate default selected lookup record if recordId provided
	connectedCallback() {
		this.option = this.op;
		getNameFoo = this.getNameFun;
		getDefaultRecord({
				recordId: this.recordId,
				objName: this.objName,
				option: this.optionJson
        })
        .then((result) => {
            if (result != null) {
                this.selectedRecord = new Model(result.data.data);
                this.objName = result.data.objName;
                this.iconName = result.data.iconName;
				if (this.selectedRecord && this.selectedRecord.Id) {
					this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
				}
                if (!this.label) {
                    this.label = this.objName;
                }
            }
        })
        .catch((error) => {
            this.error = error;
            this.selectedRecord = {};
        });

		// getIconName({
		//     sObjectName: this.objName,
		// }).then((result) => {
		//     if(result != null){
		//         this.iconName = result;
		//     }
		// })
		// .catch((error) => {
		//     this.error = error;
		// });
	}

	iconName = "standard:account";
	// @wire(getIconName, {sObjectName: '$objName'})
	//     gettingiconName({ error, data }) {
	//         console.log('$objName');
	//         console.log(this.objName);
	//         if (data) {
	//             this.iconName = data;
	//         }
	//         else if (error) {
	//             console.log('Error is ' + JSON.stringify(error));
	//         }
	//     }

	toModels(data) {
		let res = [];
		for (let index = 0; data && index < data.length; index++) {
			res.push(new Model(data[index]));
		}
		return res;
	}

	// wire function property to fetch search record based on user input
	@wire(getLookupData, {
		searchKey: "$searchKey",
		objName: "$objName",
		optionJson: "$optionJson"
	})
	searchResult(value) {
		const { data, error } = value; // destructure the provisioned value
		this.isSearchLoading = false;
		if (data) {
			//  this.hasRecords = data.length == 0 ? false : true;
			this.lstResult = this.toModels(data);
			//  this.lstResult = JSON.parse(JSON.stringify(data));
		} else if (error) {
			console.log("(error---> " + JSON.stringify(error));
		}
	}

	// update searchKey property on input field change
	handleKeyChange(event) {

		if(this.isSearch){
			this.handleRemove();
		}
		// Debouncing this method: Do not update the reactive property as long as this function is
		// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
		this.isSearchLoading = true;
		window.clearTimeout(this.delayTimeout);
		const searchKey = event.target.value;

		this.delayTimeout = setTimeout(() => {
			this.searchKey = searchKey;
		}, DELAY);
	}

	// method to toggle lookup result section on UI
	toggleResult(event) {
		const lookupInputContainer = this.template.querySelector(
			".lookupInputContainer"
		);
		const clsList = lookupInputContainer.classList;
		const whichEvent = event.target.getAttribute("data-source");
		switch (whichEvent) {
			case "searchInputField":
				clsList.add("slds-is-open");
				break;
			case "lookupContainer":
				clsList.remove("slds-is-open");
				break;
		}
	}

	// method to clear selected lookup record
	@api
	handleRemove() {
		this.searchKey = "";
		this.selectedRecord = {};
		this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function

		// remove selected pill and display input field again
		const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
		searchBoxWrapper.classList.remove("slds-hide");
		searchBoxWrapper.classList.add("slds-show");

		const pillDiv = this.template.querySelector(".pillDiv");
		pillDiv.classList.remove("slds-show");
		pillDiv.classList.add("slds-hide");

		this.isSearch = false;
	}

	// method to update selected record from search result
	handelSelectedRecord(event) {
		var objId = event.target.getAttribute("data-recid"); // get selected record Id
		this.selectedRecord = this.lstResult.find((data) => data.Id === objId); // find selected record from list
		this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
		this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
	}

	/*COMMON HELPER METHOD STARTED*/

	handelSelectRecordHelper() {
		this.template
			.querySelector(".lookupInputContainer")
			.classList.remove("slds-is-open");

		const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
		searchBoxWrapper.classList.remove("slds-show");
		searchBoxWrapper.classList.add("slds-hide");

		const pillDiv = this.template.querySelector(".pillDiv");
		pillDiv.classList.remove("slds-hide");
		pillDiv.classList.add("slds-show");

		this.isSearch = true;
	}

	// send selected lookup record to parent component using custom event
	lookupUpdatehandler(value) {
		const oEvent = new CustomEvent("lookupupdate", {
			detail: {
				selectedRecord: value
			}
		});
		this.dispatchEvent(oEvent);
	}

	get displayStyle() {
		return this.readOnly ? 'cursor: no-drop;box-shadow: none;border: 0;' : '';
	}
}