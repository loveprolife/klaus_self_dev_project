import LightningElementEx from './lightningElementEx';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class LightningNavigationElement extends NavigationMixin(LightningElementEx) {

    goToRecord(rId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId,
                actionName: 'view'
            },
        });
    }

    createRecord(sobjectName, defaultValues, recordTypeId, nooverride, replace) {
        let para = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: sobjectName,
                actionName: 'new'
            }
        };
        if (defaultValues) {
            if (!para.state) {
                para.state = {}
            }
            para.state.defaultFieldValues = encodeDefaultFieldValues(defaultValues);
        }

        if (recordTypeId) {
            if (!para.state) {
                para.state = {}
            }
            para.state.recordTypeId = recordTypeId;
        }
        
        if (nooverride) {
            if (!para.state) {
                para.state = {}
            }
            para.state.nooverride = 1;
        }

        this[NavigationMixin.Navigate](para, replace ? true : false);
    }

    editRecord(recordId) {
        let para = {
            type: 'standard__objectPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit'
            }
        };
        this[NavigationMixin.Navigate](para);
    }

    goToObject(sobjectName, listViewName) {
        let para = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: sobjectName,
                actionName: 'home'
            }
        };
        if (listViewName) {
            para.attributes.actionName = 'list';
            para.state.filterName = listViewName;
        }
        this[NavigationMixin.Navigate](para);
    }

    goToLwc(lwcName, state) {
        if (!state) {
            state = {};
        }
        state.lwcName = lwcName;
        this.goToComponent('c__LWCWrapper', state);
    }

    goToVf(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

    goToComponent(componentName, state) {
        let para = {
            type: 'standard__component',
            attributes: {
                componentName : componentName
            },
            state: {
                "c__timestamp" : Date.now()
            }
        };
        if (state) {
            for (let key in state) {
                para.state[key] = state[key];
                if (key.indexOf('c__') != 0) {
                    para.state['c__' + key] = state[key];
                }
            }
        }
        this[NavigationMixin.Navigate](para);
    }

    filePreview(documentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                // recordId : documentId,
                // recordIds: documentId,
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: documentId
            }
        })
    }

    goToRelatedList(objectApiName, recordId, relation) {
        this.navigate({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                relationshipApiName: relation,
                actionName: 'view'
            },
        });
    }

    navigate(para) {
        this[NavigationMixin.Navigate](para);
    }

    goToRecordEdit(rId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId,
                actionName: 'view'
            },
        });
    }

    goToRecordBySkip(rId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId,
                actionName: 'view'
            },
            state: {
                c__skip: true
            }
            
        });
    }

    goTochart(rId,sobjectName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId,
                objectApiName: sobjectName,
                actionName: 'view'
            },
            state: {
                queryScope: userFolders
            }
            
        });
    }
}