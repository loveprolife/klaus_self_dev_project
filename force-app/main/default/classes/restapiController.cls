/**
 * REST API 示例：获取与管理 Account 数据
 * 端点说明（部署后）：
 * - GET  /services/apexrest/accounts?q=Acme&limit=10      查询Account列表（按名称模糊）
 * - GET  /services/apexrest/accounts/{id}                    获取单条Account
 * - POST /services/apexrest/accounts                         创建Account（Body: {"Name":"New Acc","Phone":"123"}）
 *
 * 注意：
 * - 为简洁起见，这里演示性地返回了常用字段。生产建议结合字段级安全与对象级CRUD校验：
 *   Schema.sObjectType.Account.isAccessible()
 *   Security.stripInaccessible(AccessType.READABLE/CREATABLE, ...)
 */
@RestResource(urlMapping='/accounts/*')
global with sharing class restapiController {

    global class ApiResponse {
        public Boolean success;
        public Object data;
        public String message;
        public ApiResponse(Boolean success, Object data, String message) {
            this.success = success;
            this.data = data;
            this.message = message;
        }
    }

    // GET /services/apexrest/accounts?q=xxx&limit=10
    @HttpGet
    global static void getAccounts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // 如果路径中包含 Id（/accounts/{id}），则走单条查询
            String uri = req.requestURI != null ? req.requestURI : '';
            List<String> parts = uri.split('/');

            // 期望形如 .../services/apexrest/accounts/{id}
            // 简单判断：最后一段不是 'accounts' 且非空则当作 Id
            if (!parts.isEmpty()) {
                String last = parts.get(parts.size() - 1);
                if (last != null && last.toLowerCase() != 'accounts' && last.trim().length() > 0) {
                    returnOne(last);
                    return;
                }
            }

            // 列表查询逻辑
            String q = req.params.get('q');
            Integer lim = 20;
            if (req.params.containsKey('limit')) {
                try {
                    lim = Integer.valueOf(req.params.get('limit'));
                } catch (Exception e) {
                    // 非法limit则保留默认
                }
            }
            lim = Math.max(1, Math.min(lim, 200));

            String likeFilter = (q == null || q.trim().length() == 0) ? null : '%' + q.trim() + '%';

            List<Account> rows;
            if (likeFilter == null) {
                rows = [SELECT Id, Name, Phone, Type, Industry, BillingCountry, CreatedDate, LastModifiedDate
                        FROM Account
                        ORDER BY LastModifiedDate DESC
                        LIMIT :lim];
            } else {
                rows = [SELECT Id, Name, Phone, Type, Industry, BillingCountry, CreatedDate, LastModifiedDate
                        FROM Account
                        WHERE Name LIKE :likeFilter
                        ORDER BY LastModifiedDate DESC
                        LIMIT :lim];
            }

            // 只返回必要字段
            List<Map<String, Object>> data = new List<Map<String, Object>>();
            for (Account a : rows) {
                data.add(new Map<String, Object>{
                    'Id' => a.Id,
                    'Name' => a.Name,
                    'Phone' => a.Phone,
                    'Type' => a.Type,
                    'Industry' => a.Industry,
                    'BillingCountry' => a.BillingCountry,
                    'CreatedDate' => a.CreatedDate,
                    'LastModifiedDate' => a.LastModifiedDate
                });
            }

            writeJson(new ApiResponse(true, data, null), 200);
        } catch (Exception e) {
            writeJson(new ApiResponse(false, null, e.getMessage()), 500);
        }
    }

    // GET /services/apexrest/accounts/{id}
    private static void returnOne(String idOrKey) {
        try {
            Id recId;
            try {
                recId = (Id) idOrKey;
            } catch (Exception ex) {
                writeJson(new ApiResponse(false, null, 'Invalid Id: ' + idOrKey), 400);
                return;
            }

            Account a = [
                SELECT Id, Name, Phone, Type, Industry, BillingCountry, CreatedDate, LastModifiedDate
                FROM Account
                WHERE Id = :recId
                LIMIT 1
            ];

            Map<String, Object> data = new Map<String, Object>{
                'Id' => a.Id,
                'Name' => a.Name,
                'Phone' => a.Phone,
                'Type' => a.Type,
                'Industry' => a.Industry,
                'BillingCountry' => a.BillingCountry,
                'CreatedDate' => a.CreatedDate,
                'LastModifiedDate' => a.LastModifiedDate
            };

            writeJson(new ApiResponse(true, data, null), 200);
        } catch (QueryException qe) {
            writeJson(new ApiResponse(false, null, 'Account not found'), 404);
        } catch (Exception e) {
            writeJson(new ApiResponse(false, null, e.getMessage()), 500);
        }
    }

    // POST /services/apexrest/accounts
    // Body JSON 示例：{"Name":"New Acc","Phone":"123-456"}
    @HttpPost
    global static void createAccount() {
        RestRequest req = RestContext.request;

        try {
            if (req.requestBody == null) {
                writeJson(new ApiResponse(false, null, 'Empty request body'), 400);
                return;
            }
            String body = req.requestBody.toString();
            if (String.isBlank(body)) {
                writeJson(new ApiResponse(false, null, 'Empty request body'), 400);
                return;
            }

            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);

            Account a = new Account();
            if (payload.containsKey('Name')) a.Name = (String) payload.get('Name');
            if (payload.containsKey('Phone')) a.Phone = (String) payload.get('Phone');
            if (payload.containsKey('Type')) a.Type = (String) payload.get('Type');
            if (payload.containsKey('Industry')) a.Industry = (String) payload.get('Industry');
            if (payload.containsKey('BillingCountry')) a.BillingCountry = (String) payload.get('BillingCountry');

            // 简单校验示例
            if (String.isBlank(a.Name)) {
                writeJson(new ApiResponse(false, null, 'Name is required'), 400);
                return;
            }

            insert a;

            Map<String, Object> data = new Map<String, Object>{
                'Id' => a.Id,
                'Name' => a.Name
            };
            writeJson(new ApiResponse(true, data, null), 201);
        } catch (DmlException de) {
            writeJson(new ApiResponse(false, null, de.getDmlMessage(0)), 400);
        } catch (Exception e) {
            writeJson(new ApiResponse(false, null, e.getMessage()), 500);
        }
    }

    // 输出 JSON 的工具方法
    private static void writeJson(ApiResponse obj, Integer statusCode) {
        RestResponse res = RestContext.response;
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(obj));
    }
}