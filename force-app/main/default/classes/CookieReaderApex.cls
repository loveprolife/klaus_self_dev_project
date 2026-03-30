public with sharing class CookieReaderApex {
    // 暴露给LWC的@AuraEnabled方法，支持缓存（提高性能）
    @AuraEnabled(cacheable=true)
    public static String getCookieValue(String cookieName) {
        // 1. 获取当前页面所有Cookie
        Map<String, ApexPages.Cookie> cookieMap = ApexPages.currentPage().getCookies();
    
        // 2. 校验Cookie是否存在
        if (cookieMap == null || !cookieMap.containsKey(cookieName)) {
            return null; // 无对应Cookie返回null
        }
        // 3. 返回目标Cookie的值
        ApexPages.Cookie targetCookie = cookieMap.get(cookieName);
        return targetCookie.getValue();
    }
}