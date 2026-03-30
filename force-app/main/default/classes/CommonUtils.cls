/**
 * @description CommonUtils for Apex
 * @author Bright Xu
 * Modifications Log
 * Ver	Date		Author		Modification
 * 1.0	2019-02-10	Bright Xu	Initial Version
*/
public class CommonUtils{  
    
    private static string[] ss = new string[]{'Integer','Long','Decimal','Double'};

    public static string GetType(Object o) {
        if(o==null) return null;              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

    public static Boolean IsNumberic(object o){
        return ss.contains(getType(o));
    }
    
    public static string GetStr(object res)
    {
        if(res == null)return '';
        return res+'';
    }
    
    public static string AppendStr(object res, object dst)
    {
        string res1 = '';
        string dst1 = '';
        if(res!=null)res1+=res;
        if(dst!=null)dst1+=dst;
        return res1 + dst1;
    }
    
    public static string subStr(String s, Integer length) {
        return subStr(s, 0 ,length);
    }
    public static string subStr(String s, Integer start, Integer length) {
        if(s == null) return null;
        
        if(length <= 0 || start >= s.length()) {
            return '';
        }
        
        if(start+length >= s.length()) {
            length = s.length();
        }
        return s.substring(start, length);
    }
    
    public static string JsonSerializeObject(object obj)
    {
        string type_name = GetType(obj);
        if(type_name == null)return null;
        if(IsNumberic(obj)){
            return obj + '';
        }

        if(obj instanceof Map<string,object> ){
            Map<string,object> m = (Map<string,object>)obj;
            Map<string,object> temp = new Map<string,object>();
            for (string key : m.keySet()) {
                Object o = m.get(key);
                if(o != null){
                    temp.put(key, o);
                }
            }
            return JSON.serialize(temp);
        }
        else{
            return Json.serialize(obj);
        }
    }
    
}