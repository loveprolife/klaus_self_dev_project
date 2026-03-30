public with sharing class JwtUtil {

    /**
     * 生成与 java-jwt 库等价的 HS256 JWT
     * 返回：Bearer xxxx.xxxx.xxxx
     */
    public static String getAuthorizationToken() {
        // 1. 头部（固定）
        Map<String, Object> header = new Map<String, Object>{
            'alg' => 'HS256',
            'typ' => 'JWT'
        };

        // 2. 载荷
        // String appKey = '2e376727b0534777';
        // String appSecret = '5e48f8fa043944eca0d6ac413b1e14f0';
        String appKey = '246b5c159f654d52';
        String appSecret = 'fa372c6d2d4443aaa978f450ed43785f';
        String jti   = Crypto.getRandomInteger().format() + Crypto.getRandomLong(); // 简易 UUID
        Long   iat   = DateTime.now().getTime() / 1000;                             // 秒级时间戳

        Map<String, Object> payload = new Map<String, Object>{
            'iss' => appKey,   // issuer
            'iat' => iat,      // issued-at
            'jti' => jti       // JWT ID
        };

        // 3. 手动拼 header.payload
        String headerB64  = base64urlEncode(Blob.valueOf(JSON.serialize(header)));
        String payloadB64 = base64urlEncode(Blob.valueOf(JSON.serialize(payload)));
        String toSign     = headerB64 + '.' + payloadB64;

        // 4. HMAC256 签名
        Blob secret = Blob.valueOf(appSecret); // 对称密钥
        Blob sig    = Crypto.generateMac('HMACSHA256', Blob.valueOf(toSign), secret);
        String sigB64 = base64urlEncode(sig);

        // 5. 组合完整 JWT
        String token = toSign + '.' + sigB64;

        return 'Bearer ' + token;
    }

    /* ---------- 工具 ---------- */
    /**
     * 标准 Base64URL 编码（无填充 + URL 安全字符）
     */
    private static String base64urlEncode(Blob data) {
        return EncodingUtil.base64Encode(data)
                           .replace('+', '-')
                           .replace('/', '_')
                           .replace('=', '');
    }
}