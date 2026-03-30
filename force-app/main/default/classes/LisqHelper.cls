/**
 * @description List Query Helper, Extend Lisq
 * @author Bright Xu
 * Modifications Log
 * Ver	Date		Author		Modification
 * 1.0	2019-02-10	Bright Xu	Initial Version
*/
public class LisqHelper {
       
    public static double Sum(List<object> source, string field)
    {
        return Lisq.Sum(source, new LisqUtils.ConvertToNumber(field));
    }
    
    public static double Average(List<object> source, string field)
    {
        return Lisq.Average(source, new LisqUtils.ConvertToNumber(field));
    }
    
    public static List<String> ToS(List<object> source)
    {
        return ToS(source,true);
    }
    
    public static List<String> ToS(List<object> source,boolean contains_null)
    {
        List<string> ls = new List<string>();
        for(object o : source)
        {
            if(o == null && contains_null)ls.add(null);
            else ls.add(o + '');
        }
        return ls;
    }
    
    public static List<String> ToIds(List<object> source)
    {
        List<string> ls = new List<string>();
        for(object o : source)
        {
            ls.add(((SObject)o).Id);
        }
        return ls;
    }
    
    public static List<object> SelectField(List<object> source, string field){
        return SelectField(source, field,null);
    }

    public static List<object> SelectField(List<object> source, string field, Lisq.IFilter filter){
        return Lisq.SelectNew(source, new LisqUtils.SObjectSelectField(field),filter);
    }

    public static List<object> joinFields(List<object> source, string[] fields, String separator){
        return joinFields(source, fields, separator, null);
    }

    public static List<object> joinFields(List<object> source, string[] fields, String separator, Lisq.IFilter filter){
        return Lisq.SelectNew(source, new LisqUtils.SObjectJoinField(fields, separator), filter);
    }
	
    public static List<object> SelectObject(List<object> source, string class_name, Map<string,string> field_mapping,boolean skip_null )
    {
        return Lisq.SelectNew(source, new LisqUtils.SObjectSelectObject(class_name,field_mapping,skip_null));
    }
    
    public static Map<string,List<object>> GroupByS(List<object> source, string field){
        return LisqHelper.ToS(GroupBy(source, field));
    }
    
    public static Map<object,List<object>> GroupBy(List<object> source, string field){
        return Lisq.GroupBy(source, new LisqUtils.SObjectSelectField(field));
    }
    
    public static Map<String, SObject> subMap(Map<String, SObject> msso, List<String> keys) {
        if (keys == null) {
            return null;
        }

        Map<String, SObject> temp = new Map<String, SObject>();
        for (String key : keys) {
            if (msso.containsKey(key)) {
                temp.put(key, msso.get(key));
            }
        }
        return temp;
    }
    
    public static Map<string,List<object>> ToS(Map<object,List<object>> source)
    {
        Map<string,List<object>> mso = new Map<string,List<object>>();
        for(object o : source.keySet())
        {
            mso.put(o+'', source.get(o));
        }
        return mso;
    }
    
    public static Map<string,object> ToMapS(List<object> source, string field )
    {
        return LisqHelper.ToS(Lisq.ToMap(source, new LisqUtils.SObjectSelectField(field), true, true));
    }
    
    public static Map<object,object> ToMap(List<object> source, string field )
    {
        return Lisq.ToMap(source, new LisqUtils.SObjectSelectField(field), true, true);
    }
    
    public static Map<string,object> ToS(Map<object,object> source)
    {
        Map<string,object> mso = new Map<string,object>();
        for(object o : source.keySet())
        {
            mso.put(o+'', source.get(o));
        }
        return mso;
    }

    public static List<object> OrderBy(List<object> source )
    {

        if (source == null || source.size() == 0 || !(CommonUtils.IsNumberic(source[0]) || source[0] instanceof String)) {
            return source;
        }

        List<object> result = new List<object>();
        for(object key : source)
        {
            result.add(key);
        }
        result.sort();
        return result;
    }
    
    // 返回升序结果
    public static List<object> OrderBy(List<object> source, string field )
    {
        if(string.isBlank(field))return source;
        List<object> null_field_list = Lisq.Filter(source, new LisqUtils.FieldCompare(field,'IsBlank'));
        Map<object,List<object>> mslo = GroupBy(source,field);
        List<object> sorted_keys = new List<object>(mslo.keyset());
        sorted_keys.sort();
        List<object> result = new List<object>(null_field_list);
        for(object key : sorted_keys)
        {
            result.addAll(mslo.get(key));
        }
        return result;
        //return Lisq.Sort(source,new LisqUtils.ObjectComparable(field),true);
    }

    // 返回降序结果
    public static List<object> OrderByDesc(List<object> source)
    {
        if (source == null || source.size() == 0 || !(CommonUtils.IsNumberic(source[0]) || source[0] instanceof String)) {
            return source;
        }
		List<object> aes = OrderBy(source);        
        List<object> result = new List<object>();
        for(integer i = aes.size()-1;i>=0;i--)
        {
            result.add(aes[i]);
        }
        
        return result;
    }
    
    // 返回降序结果
    public static List<object> OrderByDesc(List<object> source, string field )
    {
        if(string.isBlank(field))return source;
		List<object> aes = OrderBy(source,field);        
        List<object> result = new List<object>();
        for(integer i = aes.size()-1;i>=0;i--)
        {
            result.add(aes[i]);
        }
        
        return result;
        //return Lisq.Sort(source,new LisqUtils.ObjectComparable(field),false);
    }
}