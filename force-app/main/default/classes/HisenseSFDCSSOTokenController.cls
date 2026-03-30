/**
 * @author Agentforce
 * @description Token exchange placeholder for external system after Federated SAML SSO.
 *              This class exposes an AuraEnabled method to retrieve a short-lived access token
 *              from an external system via Named Credential. It returns a minimal DTO for LWC usage.
 *
 * Security Notes:
 * - Do NOT log or persist tokens.
 * - Use with sharing to respect sharing rules.
 * - Run database operations in USER_MODE if needed.
 * - Replace the placeholder endpoint/paths with real values and configure a Named Credential.
 */
public with sharing class HisenseSFDCSSOTokenController {
    /**
     * Public DTO for returning token details to LWC.
     */
    public class TokenResponse {
        @AuraEnabled public String token;
        @AuraEnabled public Datetime expiresAt;
        @AuraEnabled public String tokenType;
        @AuraEnabled public String raw; // optional: raw response (for troubleshooting only; consider removing in prod)
    }

    /**
     * Get token from external system after SAML SSO using a Named Credential callout.
     * Replace 'AnotherSystem_NC' with your real Named Credential.
     * This is a placeholder; adjust request/response mapping to your API contract.
     */
    @AuraEnabled(cacheable=false)
    public static TokenResponse getExternalToken() {
        // Placeholder: Build a callout to external token endpoint using Named Credential
        // Named Credential expected: "AnotherSystem_NC"
        // Endpoint example: callout:AnotherSystem_NC/sso/token
        // Method: POST
        // Body example: {"subject":"{SF User Info or Assertion Reference}"}
        // Auth: bound in Named Credential (JWT/Client Credentials/Custom Header)
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        // IMPORTANT: Update with your real Named Credential and path
        req.setEndpoint('callout:AnotherSystem_NC/sso/token');
        req.setMethod('POST');
        req.setTimeout(20000);
        req.setHeader('Content-Type', 'application/json');

        // Minimal subject context. DO NOT include sensitive data in plain text.
        Map<String, Object> body = new Map<String, Object>();
        body.put('sfUserId', UserInfo.getUserId());
        body.put('sfUsername', UserInfo.getUserName());
        // If the external system supports correlating SSO session via a server-side mechanism,
        // you might pass a correlationId instead.
        body.put('correlationId', Crypto.getRandomLong().format());

        req.setBody(JSON.serialize(body));

        try {
            HttpResponse res = http.send(req);
            Integer sc = res.getStatusCode();
            // Placeholder success mapping
            if (sc >= 200 && sc < 300) {
                // Attempt to map common token shapes
                // Example responses:
                // {"access_token":"xxx","expires_in":3600,"token_type":"Bearer"}
                // {"token":"xxx","expireAt":"2026-01-12T12:00:00Z","type":"Bearer"}
                Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String token = (String) (payload.containsKey('access_token') ? payload.get('access_token') : payload.get('token'));
                String tokenType = (String) (payload.containsKey('token_type') ? payload.get('token_type') : payload.get('type'));
                Datetime expiresAt;

                if (payload.containsKey('expires_in')) {
                    Object expInVal = payload.get('expires_in');
                    Long seconds = 0L;
                    if (expInVal instanceof Integer) {
                        seconds = (Long) expInVal;
                    } else if (expInVal instanceof Long) {
                        seconds = (Long) expInVal;
                    } else if (expInVal instanceof String) {
                        seconds = Long.valueOf((String) expInVal);
                    }
                    // Datetime.addSeconds 需要 Integer，范围校验后再转换
                    Integer secondsInt = (seconds > Integer.valueOf(2147483647)) ? 2147483647 : Integer.valueOf((String) String.valueOf(seconds));
                    expiresAt = Datetime.now().addSeconds(secondsInt);
                } else if (payload.containsKey('expireAt')) {
                    expiresAt = Datetime.valueOf((String) payload.get('expireAt'));
                } else if (payload.containsKey('expires_at')) {
                    expiresAt = Datetime.valueOf((String) payload.get('expires_at'));
                } else {
                    // No expiry provided; set a short default of now + 15 min
                    expiresAt = Datetime.now().addMinutes(15);
                }

                TokenResponse tr = new TokenResponse();
                tr.token = token;
                tr.expiresAt = expiresAt;
                tr.tokenType = tokenType != null ? tokenType : 'Bearer';
                // For placeholder visibility in early testing. Remove in production.
                tr.raw = res.getBody();
                return tr;
            } else {
                // Fallback placeholder: fabricate a short-lived token for wire-up tests (DO NOT use in production)
                TokenResponse tr = new TokenResponse();
                tr.token = 'PLACEHOLDER_TOKEN_ONLY_FOR_DEV_' + Crypto.getRandomInteger().format();
                tr.expiresAt = Datetime.now().addMinutes(5);
                tr.tokenType = 'Bearer';
                tr.raw = '{"placeholder":true,"reason":"non-2xx","statusCode":' + sc + '}';
                return tr;
            }
        } catch (Exception ex) {
            // Fallback placeholder for dev. Do not expose details to end-users.
            TokenResponse tr = new TokenResponse();
            tr.token = 'PLACEHOLDER_TOKEN_ON_EXCEPTION_' + Crypto.getRandomInteger().format();
            tr.expiresAt = Datetime.now().addMinutes(5);
            tr.tokenType = 'Bearer';
            tr.raw = '{"placeholder":true,"exception":"' + ex.getMessage() + '"}';
            return tr;
        }
    }
}