/**********************************************************************
 * function:对外查询LDAP信息
 * @url: /services/apexrest/rest
 * @data: ACProductInfo
 * date:2023-12-27
*************************************************************************/
@RestResource(urlMapping='/getLDAPInfo')
global with sharing class GetLDAPInfo {
    
    @HttpPost
    global static ExhibitionSSOVerifyPanGu.VerifyData doPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"ProductList": [{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "B","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"},{"FactoryModel": "A","HighEnd": "","OutdoorProductModel": "+AST-09UR4SVE10B(P)","IndoorEnclosure": "G1X","RemoteControlModel": "J1-01","OutdoorProductionModel": "+AST-09UR4SVE1(WLP)(D)","PressModel": "美芝-ASM89D18UFZ","WiFIModuleRequirements": "(按工厂)是","OutdoorEnclosure": "W1M","IDUSize": "","ODUSize": "","IDUPackageSize": "900×335×260","ODUPackageSize": "830×315×530"}],"access_token": "Bearer SESSION_ID_REMOVED"}';
        system.debug('doPost now, body : ' + reqBody);
        try {
            Map<String, Object> mso = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
            // return JSON.serialize(ExhibitionSSOVerify.verifyInternalRegistration(String.valueOf(mso.get('params'))));
            // return ExhibitionSSOVerify.verifyInternalRegistration('uid=' + String.valueOf(mso.get('uid')));
            return ExhibitionSSOVerifyPanGu.verifyInternalRegistration('uid=' + String.valueOf(mso.get('uid')));
        } catch (Exception e) {
            System.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            ExhibitionSSOVerifyPanGu.VerifyData d = new ExhibitionSSOVerifyPanGu.VerifyData();
            d.code = -1;
            d.message = e.getMessage();
            return d;
            // return JSON.serialize(d);
        }
    }
}