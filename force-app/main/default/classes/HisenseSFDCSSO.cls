/**********************************************************************
 * function:SSO to Hisense
 * @author:xiao-weil
 * date:2019-03-15
*************************************************************************/
global class HisenseSFDCSSO extends Auth.AuthProviderPluginClass {
               
    private String customMetadataTypeApiName = 'HisenseSSOAuth__mdt'; // api name for the custom metadata type created for this 

    private String clientId;
    private String clientSecret;
    private String accessTokenUrl;
    private String authorizationUrl;
    private String grantType;
    private String userInfoUrl;
    public String redirectUri;

    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        /*
      Get all the fields required to form the authorization code url and return a pagereference to that url.
      I am using the api names of fields in my custom setting below. This is the same setting which was
      returned from the previous method.
    */
        system.debug('In SSO initiate!' + stateToPropagate);
        clientId = authProviderConfiguration.get('Client_Id__c');
        authorizationUrl = authProviderConfiguration.get('Authorization_URL__c');
        redirectUri = authProviderConfiguration.get('Redirect_URL__c');
        String url = authorizationUrl + '?client_id='+clientId+'&redirect_uri='+redirectUri+'&response_type=code'+'&target_uri='+'https://hisenseint.lightning.force.com/lightning/page/home'+'&state='+stateToPropagate;

        return new PageReference(url);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        system.debug('In SSO callback!');
        clientId = authProviderConfiguration.get('Client_Id__c');
        clientSecret = authProviderConfiguration.get('Client_Secret__c');
        redirectUri = authProviderConfiguration.get('Redirect_URL__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');

        /*
        Code is required, state is optional 
        i.e. you'll get it if you passed it in the auth. code url in the above method.
        */
        system.debug('state: ' + state);
        system.debug('state.queryParameters: ' + state.queryParameters);
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');

        /*
        Make a new HTTP Request to the access token URL.
        Make sure to pass the code received above in the request.
        */
        HttpRequest req = new HttpRequest();
        String url = accessTokenUrl+ '?code='+code+'&client_id='+clientId+'&client_secret='+clientSecret+'&redirect_uri='+redirectUri+'&state='+sfdcState;
        system.debug('url:' + url);
        req.setEndpoint(url);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('bodyRes:' + responseBody);
 
        System.PageReference pageReference = new System.PageReference('/?' + responseBody);
        Map<String,String> parameters = pageReference.getParameters();
        
        String access_token = parameters.get('access_token'); 
        String expires = parameters.get('expires');

        system.debug(parameters);

        // Pass auth. provider name, access token, refresh token and state in the below method respectively.
        return new Auth.AuthProviderTokenResponse('HisenseSSOAuth', access_token, null, sfdcState);
    }


    /* 
    This method is responsible to get the user information used for authentication from the external api.
    You can find a URL from the third party api that you can hit to get the current authenticated user info.
    If there is no such URL, you can also hard code values,
    you can also store the values in custom metadata and use that.
    */
    global Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        system.debug('In SSO getUserInfo!');
        /*
        Getting the user info url from the custom metadata.
        Getting the access token from the response we got from access token url.
        */
        system.debug(response);
        userInfoUrl = authProviderConfiguration.get('User_Info_URL__c');
        String token = response.oauthToken;

        /*
        Making a new HTTP request to get the user information,
        in this case we need to manually set the access token in header.
        Format is:-
        Key:- Authorization
        Value:- <Token-Type><space><access-token> 
        Example Value:- Bearer 123123123
        */
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(userInfoUrl+'?access_token='+token);

        // Set the method type according to third party api, you can also make a post request here.
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        system.debug(responseBody);
        // Make a wrapper according to the response of User Info URL.
        UserInfoResponse infoApiResponse = (UserInfoResponse) JSON.deserialize(responseBody, UserInfoResponse.class);

        String userId, fullName, firstName, lastName, locale, loginURL;

        // Hardcoding the locale, you can also store it in custom metadata.
        locale = 'en-au';

        /* 
        Getting the login URL from custom metadata,
        it is usually the login URL of your 3rd party API portal.
        */
        loginURL = authProviderConfiguration.get('Base_URL__c');
        system.debug(infoApiResponse);
        userId = infoApiResponse.id;
        // fullName = infoApiResponse.attributes.userName[0];
        // firstName = infoApiResponse.attributes.userName[0];
        //lastName = infoApiResponse.attributes[2].[0];

        /*
        Format or below returned userdata instance:- 
            UserData (
            identifier, => user id
            firstName, => first name of authenticated user
            lastName, => last name of authenticated user
            fullName, => full name of authenticated user
            email, => email of authenticated user
            link, => link of authenticated user profile (Ex:- https://www.facebook.com/sfdcstop)
            userName, => username of authenticated user
            locale, => standard locale of authenticated user
            provider, => name of your 3rd party provider
            siteLoginUrl, => 3rd party login page url
            attributeMap => any other data from 3rd party that you can store as map of <string, string>
            )
        You can also pass null or hardcode value if something is not available as shown below.
        */
        List<User> us = [SELECT ID,username FROM User Where HisenseSSOName__c  = : userId limit 1];
        if(us!=null && us.size()>0){
            User u = us.get(0);
            return new Auth.UserData(
                u.id,
                'name1',
                'name2',
                'name1name2',
                u.username,
                null, 
                u.username,
                null,
                'HisenseSSOAuth',
                loginURL,
                new Map<String,String>()
                );
        }else {
            return new Auth.UserData(
                'id',
                'name1',
                'name2',
                'name1name2',
                null,
                null, 
                null,
                null,
                'HisenseSSOAuth',
                loginURL,
                new Map<String,String>()
                );
        }
        
    }

    /*
    Wrapper class to handle User Info API response.
    Create a wrapper class according to the response you're getting,
    like below sample will work if your response is as follows:-

    {
        "login":"123123123", 
        "fullName":"Rahul Malhotra",
        "firstName":"Rahul",
        "lastName":"Malhotra"
    }

    */
  
    public class UserInfoResponse {
        public String id;
    }
}