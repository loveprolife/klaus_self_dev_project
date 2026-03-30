// Generic interface-like utility for inserting list data into any SObject
// Usage examples:
// 1) Insert from list of maps:
//    List<Map<String, Object>> rows = new List<Map<String, Object>>{
//        new Map<String, Object>{ 'Name' => 'Acme', 'Phone' => '123' },
//        new Map<String, Object>{ 'Name' => 'Global Media', 'Phone' => '456' }
//    };
//    Database.UpsertResult[] results = GeneralInterface.insertList('Account', '', rows, true);
//
// 2) Insert from list of SObjects:
//    List<SObject> accs = new List<SObject>();
//    Account a = new Account(Name='Test Co'); accs.add(a);
//    Database.UpsertResult[] results2 = GeneralInterface.insertList('Account', '', accs, false);
//
// Notes:
// - objectApiName: e.g., 'Account', 'Custom__c'
// - dataList: each map is fieldApiName -> value
// - unknown fields are ignored
// - non-insertable fields are skipped
// - basic type coercion provided
// - relationship fields: provide Id directly, or nested map with 'Id' key
public without sharing class GeneralInterface{
    // Insert from list of maps. Set allOrNone per your need.
    public static Database.UpsertResult[] insertList(String objectApiName, String keyField, List<Map<String, Object>> dataList, Boolean allOrNone){
        if (String.isBlank(objectApiName)){
            throw new IllegalArgumentException('objectApiName is required');
        }
        if (dataList == null){
            dataList = new List<Map<String, Object>>();
        }

        Schema.SObjectType sObjType = getSObjectType(objectApiName);
        Schema.DescribeSObjectResult d = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fields = d.fields.getMap();

        List<SObject> toInsert = new List<SObject>();
        for (Map<String, Object> row : dataList){
            if (row == null)
                continue;
            // SObject sobj = d.newSObject();
            SObject sobj = (SObject) Type.forName(objectApiName).newInstance();

            for (String key : row.keySet()){
                if (String.isBlank(key))
                    continue;
                Schema.SObjectField f = fields.get(key);
                if (f == null){
                    // ignore unknown fields
                    continue;
                }
                Schema.DescribeFieldResult fd = f.getDescribe();
                if (!fd.isCreateable()){
                    // skip non-insertable fields
                    continue;
                }
                Object rawVal = row.get(key);
                Object coerced = coerceValue(fd, rawVal);
                try{
                    sobj.put(key, coerced);
                } catch (Exception e){
                    // ignore invalid assignment
                }
            }
            toInsert.add(sobj);
        }

        if (toInsert.isEmpty()){
            return new List<Database.UpsertResult>();
        }
        if (String.isNotBlank(keyField)){
            return Database.upsert (toInsert, fields.get(keyField), allOrNone == null ? false : allOrNone);
        } else{
            return Database.upsert (toInsert, allOrNone == null ? false : allOrNone);
        }
    }

    // Overload with default allOrNone=false for convenience
    public static Database.UpsertResult[] insertList(String objectApiName, String keyField, List<Map<String, Object>> dataList){
        return insertList(objectApiName, keyField, dataList, false);
    }

    // Insert from list of SObject records whose type matches objectApiName
    public static Database.UpsertResult[] insertList(String objectApiName, String keyField, List<SObject> records, Boolean allOrNone){
        if (String.isBlank(objectApiName)){
            throw new IllegalArgumentException('objectApiName is required');
        }
        if (records == null || records.isEmpty()){
            return new List<Database.UpsertResult>();
        }
        Schema.SObjectType sObjType = getSObjectType(objectApiName);
        Schema.DescribeSObjectResult d = sObjType.getDescribe();
        String expectedType = String.valueOf(d.getName());

        // Filter/convert records that match type; ignore mismatches
        List<SObject> toInsert = new List<SObject>();
        Map<String, Schema.SObjectField> fields = d.fields.getMap();
        for (SObject r : records){
            if (r == null)
                continue;
            if (String.valueOf(r.getSObjectType().getDescribe().getName()) == expectedType){
                toInsert.add(r);
            } else{
                // attempt shallow retype by creating new SObject and copying createable fields
                SObject converted = (SObject) Type.forName(objectApiName).newInstance();
                for (String fname : fields.keySet()){
                    Schema.DescribeFieldResult fd = fields.get(fname).getDescribe();
                    if (!fd.isCreateable())
                        continue;
                    try{
                        converted.put(fname, r.get(fname));
                    } catch (Exception ex){
                        // ignore
                    }
                }
                toInsert.add(converted);
            }
        }
        if (toInsert.isEmpty()){
            return new List<Database.UpsertResult>();
        }
        if (String.isBlank(keyField)){
            return Database.upsert (toInsert, fields.get(keyField), allOrNone == null ? false : allOrNone);
        } else{
            return Database.upsert (toInsert, allOrNone == null ? false : allOrNone);
        }
    }

    // Overload default allOrNone=false
    public static Database.UpsertResult[] insertList(String objectApiName, String keyField, List<SObject> records){
        return insertList(objectApiName, keyField, records, false);
    }

    // Helpers
    private static Schema.SObjectType getSObjectType(String objectApiName){
        Map<String, Schema.SObjectType> g = Schema.getGlobalDescribe();
        Schema.SObjectType t = g.get(objectApiName);
        if (t == null){
            // try case-insensitive match
            for (String k : g.keySet()){
                if (k != null && k.equalsIgnoreCase(objectApiName)){
                    t = g.get(k);
                    break;
                }
            }
        }
        if (t == null){
            throw new IllegalArgumentException('Unknown sObject: ' + objectApiName);
        }
        return t;
    }

    // Basic type coercion to improve robustness across map inputs
    private static Object coerceValue(Schema.DescribeFieldResult fd, Object raw){
        if (raw == null)
            return null;
        Schema.DisplayType dt = fd.getType();

        // handle nested map for relationship fields: expect {'Id' => 'xxxxx'}
        if (raw instanceof Map<String, Object>){
            Map<String, Object> m = (Map<String, Object>)raw;
            if (m.containsKey('Id')){
                return m.get('Id');
            }
        }

        // If already correct type or Id, return
        if (dt == Schema.DisplayType.REFERENCE){
            // expect Id string
            if (raw instanceof Id)
                return raw;
            if (raw instanceof String)
                return (String) raw;
        }

        try{
            if (dt == Schema.DisplayType.STRING){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.PICKLIST){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.MULTIPICKLIST){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.BOOLEAN){
                if (raw instanceof Boolean)
                    return raw;
                String s = String.valueOf(raw);
                if (s == null)
                    return null;
                s = s.trim().toLowerCase();
                if (s == 'true' || s == '1' || s == 'yes' || s == 'y')
                    return true;
                if (s == 'false' || s == '0' || s == 'no' || s == 'n')
                    return false;
                return null;
            } else if (dt == Schema.DisplayType.INTEGER){
                if (raw instanceof Integer)
                    return raw;
                if (raw instanceof Long)
                    return Integer.valueOf((Long) raw);
                if (raw instanceof Decimal)
                    return Integer.valueOf(((Decimal) raw).intValue());
                return Integer.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.LONG){
                if (raw instanceof Long)
                    return raw;
                if (raw instanceof Integer)
                    return Integer.valueOf((Integer) raw);
                if (raw instanceof Decimal)
                    return Decimal.valueOf(((Decimal) raw).longValue());
                return Decimal.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.CURRENCY){
                if (raw instanceof Decimal)
                    return raw;
                return Decimal.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.DOUBLE){
                if (raw instanceof Decimal)
                    return raw;
                return Decimal.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.PERCENT){
                if (raw instanceof Decimal)
                    return raw;
                return Decimal.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.DATE){
                if (raw instanceof Date)
                    return raw;
                return Date.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.DATETIME){
                if (raw instanceof Datetime)
                    return raw;
                return Datetime.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.TIME){
                if (raw instanceof Time)
                    return raw;
                return Datetime.valueOf(String.valueOf(raw));
            } else if (dt == Schema.DisplayType.EMAIL){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.URL){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.PHONE){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.REFERENCE){
                return raw;
            }
            // handled above
            else if (dt == Schema.DisplayType.ID){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.TEXTAREA){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.ENCRYPTEDSTRING){
                return String.valueOf(raw);
            } else if (dt == Schema.DisplayType.BASE64){
                if (raw instanceof Blob)
                    return raw;
                // cannot reliably coerce; return null to avoid errors
                return null;
            } else if (dt == Schema.DisplayType.LOCATION){
                // Expect Map with 'latitude' and 'longitude'
                if (raw instanceof Map<String, Object>){
                    Map<String, Object> m = (Map<String, Object>)raw;
                    Object lat = m.get('latitude');
                    Object lng = m.get('longitude');
                    if (lat != null && lng != null){
                        return Location.newInstance(Decimal.valueOf(String.valueOf(lat)), Decimal.valueOf(String.valueOf(lng)));
                    }
                }
                return null;
            } else{
                return raw;
            }
        } catch (Exception e){
            // Fallback: return null if coercion fails
            return null;
        }
    }

}