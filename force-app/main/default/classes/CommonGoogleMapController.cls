public without sharing class CommonGoogleMapController {
    
    public string lexOrigin { 
        get { 
            return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        } 
    }

    @AuraEnabled(cacheable = true)
    public static string getVisualforceOrigin() {
        string visualOrigin;
        string baseUrl = URL.getOrgDomainUrl().toExternalForm(); 
        visualOrigin = baseUrl.split('.sandbox.')[0] + '--c.' + 'sandbox.vf.force.com';
        return visualOrigin;
    }
}