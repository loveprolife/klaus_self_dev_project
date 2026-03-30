/**
 * @description List Container for Collection Operation
 * @author Bright Xu
 * Modifications Log
 * Ver	Date		Author		Modification
 * 1.0	2019-02-10	Bright Xu	Initial Version
*/
public class LisqContainer{
    
    public static LisqContainer NewEmpty()
    {
        return new LisqContainer(new List<object>());
    }
    
    public List<object> Source{
        get;
        private set;
    }

    public LisqContainer(List<object> source){
        this.Source = source;
    }

    public Object get(Integer i) {
        return Source.get(i);
    }

    public Integer Size()
    {
        return Source.size();
    }
    
    public List<SObject> ToSobjectList()
    {
        if(Source == null) return null;
        List<SObject> res = new List<SObject>();
        for(object obj : Source)
        {
            res.add((SObject)obj);
        }
        return res;
    }
    
    // convert source to List<string>
    public List<String> ToS()
    {
        return ToS(true);
    }

    // convert source to List<string>, if element is null, include it or not
    public List<String> ToS(boolean contains_null)
    {
        return LisqHelper.ToS(Source,contains_null);
    }
    
    // return the source elements' id
    public List<String> ToIds()
    {
        return LisqHelper.ToIds(Source);
    }

    public List<String> SelectSField(string field){
        return SelectField(field).ToS();
    }

    // select the field of the source, and skip the null value of field
    public LisqContainer SelectField(string field){
        return SelectField(field, new Object[] {
            field, '!=', null
        });
    }
    
    // select the field of the source with a filter
    public LisqContainer SelectField( string field, Lisq.IFilter filter)
    {
        return new LisqContainer(LisqHelper.SelectField(Source,field,filter));
    }

    public LisqContainer SelectField( string field, object[] where_and_parameters)
    {
        return SelectField(field, new LisqUtils.AndFilters(where_and_parameters));
    }
    
    // Group by field
    public Map<string,LisqContainer> GroupByS(string field)
    {
        Map<object,List<object>> temp_m = LisqHelper.GroupBy(Source, field);
        Map<string,LisqContainer> result = new Map<string,LisqContainer>();
        for(object o : temp_m.keySet()){
            result.put(o+'',new LisqContainer(temp_m.get(o)));
        }
        return result;
    }

    // Group by 
    public Map<string,LisqContainer> GroupByS(Lisq.ISelect key_mapper)
    {
        Map<object,List<object>> temp_m = Lisq.GroupBy(Source, key_mapper);
        Map<string,LisqContainer> result = new Map<string,LisqContainer>();
        for(object o : temp_m.keySet()){
            result.put(o+'',new LisqContainer(temp_m.get(o)));
        }
        return result;
    }
    
    // to a map that key is value of field, it will skip the null value
    public Map<string, Sobject> ToMapS( string field )
    {
        Map<object,object> temp = LisqHelper.ToMap(Source, field);
        Map<string, Sobject> result = new Map<string, Sobject>();
        for (Object key : temp.keySet()) {
            result.put(key + '', ((Sobject)temp.get(key)));
        }
        
        return result;
    }
    
    
    // return the elsments what match the condition
    public LisqContainer Filter( Lisq.IFilter filter )
    {
        return new LisqContainer(Lisq.Filter(Source,filter));
    }

    // return the elsments what match the condition
    public LisqContainer WhereCustom( Lisq.IFilter filter )
    {
        return Filter(filter);
    }
    
    /**
     * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
     */
    public LisqContainer Where1( string field, string operator, object val )
    {
        return WhereOne(field, operator, val);
    }

    /**
     * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
     */
    public LisqContainer WhereOne( string field, string operator, object val )
    {
        return WhereAnd(new object[]{field, operator, val} );
    }

    /**
     * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
     */
    public LisqContainer WhereAnd( object[] parameters )
    {
        // System.debug('enter WhereAnd');
        return Filter(new LisqUtils.AndFilters(parameters) );
    }

    /**
     * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
     */
    public LisqContainer WhereOr( object[] parameters )
    {
        // System.debug('enter WhereOr');
        return Filter(new LisqUtils.OrFilters(parameters) );
    }
    
    public LisqContainer OrderBy()
    {
        return new LisqContainer(LisqHelper.OrderBy(Source));
    }

    // return the ordered elements with the value of field by asc
    public LisqContainer OrderBy(string field)
    {
        return new LisqContainer(LisqHelper.OrderBy(Source,field));
    }

    // return the ordered elements with the value by desc
    public LisqContainer OrderByDesc()
    {
        return new LisqContainer(LisqHelper.OrderByDesc(Source));
    }
    
    // return the ordered elements with the value of field by desc
    public LisqContainer OrderByDesc(string field)
    {
        return new LisqContainer(LisqHelper.OrderByDesc(Source,field));
    }
}