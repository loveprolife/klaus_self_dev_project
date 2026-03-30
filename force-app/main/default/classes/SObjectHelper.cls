public without sharing class SObjectHelper {
    

    private static Map<string,Map<String, Schema.SObjectField>> sobject_field_map = new Map<string,Map<String, Schema.SObjectField>>();

    public static Map<String, String> getFieldLabelMap(String objName) {
        Map<String, Schema.SObjectField> temp = GetFieldMap(objName);
        Map<String, String> result = new Map<String, String>();
        if (temp == null) {
            return result;
        }

        for (String key : temp.keySet()) {
            result.put(temp.get(key).getDescribe().getName(), temp.get(key).getDescribe().getLabel());
        }

        return result;
    }

    public static Map<String, Schema.SObjectField> GetFieldMap(string obj_name)
    {
        Map<String, Schema.SObjectField> fm = null;
        if(string.isBlank(obj_name))return fm;

        if(sobject_field_map.containsKey(obj_name))
        {
            fm = sobject_field_map.get(obj_name);
        }
        else
        {
            fm = GetFields(obj_name);
            if (fm != null) {
                sobject_field_map.put(obj_name, fm);
            }
        }
        return fm;
    }
    
    public static Map<String, Schema.SObjectField> GetFields(Sobject sobj ){
        return GetFields(sobj.getSObjectType().getDescribe().getName());
    }
    
    public static Map<String, Schema.SObjectField> GetFields(string obj_name )
    {
        Map<String, Schema.SObjectType> mss = Schema.getGlobalDescribe();
        if(mss.containsKey(obj_name)){
            return Transform(mss.get(obj_name).getDescribe().fields.getMap());
        }
        else{
            return null;
        }
    }
    /*
    public static Map<String, Schema.FieldSet> GetFieldSets(string obj_name )
    {
        Map<String, Schema.SObjectType> mss = Schema.getGlobalDescribe();
        if(!mss.containsKey(obj_name))return null;
        Map<String, Schema.FieldSet> mssfs = mss.get(obj_name).getDescribe().fieldSets.getMap();
        return mssfs;
    }
    
    public static Map<String, Schema.FieldSetMember> GetFieldSet(string obj_name,string field_set_name )
    {
        Map<String, Schema.FieldSet> mssfs = GetFieldSets(obj_name);
        if(!mssfs.containsKey(field_set_name))return null;
        Map<String, Schema.FieldSetMember> result = new Map<String, Schema.FieldSetMember>();
        for(Schema.FieldSetMember member : mssfs.get(field_set_name).getFields()){
            Schema.SObjectField ssf = member.getSObjectField();
            result.put(ssf.getDescribe().getName(),member);
        }
        return result;
    }*/
    
    static Map<String, Schema.SObjectField> Transform(Map<String, Schema.SObjectField> mssof){
        if(mssof == null)return null;
        Map<String, Schema.SObjectField> result = new Map<String, Schema.SObjectField>();
        for(string key : mssof.keySet()){
            result.put(mssof.get(key).getDescribe().getName(),mssof.get(key));
        }
        return result;
    }
    /*
    static Map<String, Schema.FieldSet> Transform(Map<String, Schema.FieldSet> mssfs){
        if(mssfs == null)return null;
        Map<String, Schema.FieldSet> result = new Map<String, Schema.FieldSet>();
        for(string key : mssfs.keySet()){
            result.put(mssfs.get(key).getName(),mssfs.get(key));
        }
        return result;
    }*/
    
    
    
    
    public static string GetFieldDescription(string object_name, string field_name){

        if(string.isBlank(object_name) || String.isBlank(field_name))return null;

        // List<FieldDefinition> fd = [Select Label, QualifiedApiName, Description from FieldDefinition Where EntityDefinition.QualifiedApiName=:object_name and QualifiedApiName=:field_name];
        List<FieldDefinition> fds = GetFieldDefinitions(object_name);
        for(FieldDefinition fd : fds)
        {
            if(fd.QualifiedApiName == field_name){
                return fd.Description;
            }
        }
        return null;
    }
    
    public static List<FieldDefinition> GetFieldDefinitions(string object_name){
        return [Select Label, QualifiedApiName, Description from FieldDefinition Where EntityDefinition.QualifiedApiName=:object_name];
    }
    
        

    /**
     * get sobject field value, support forign field if it was queried
     * e.g. GetSObjectField(lead_obj,'Owner.Name')
     */
    public static object GetSObjectField(object o,string f_str){
        return GetSObjectField((sobject)o,f_str);
    }
    
    /**
     * get sobject field value, support forign field if it was queried
     * e.g. GetSObjectField(lead_obj,'Owner.Name')
     */
    public static object GetSObjectField(sobject o,string f_str){
        List<string> fields = f_str.split('\\.');
        //system.debug('fields = ' + fields);
        sobject temp = o;
        Object result = null;
        for(integer i =0; i < fields.size();i++){
            
            if(temp == null) return null;

            if(i==fields.size()-1){
                result = temp.get(fields[i]);
            }
            else{
                temp = temp.getSObject(fields[i]);
            }
            
            /*
            if(result instanceof SObject){
                temp = (SObject)result;
                continue;
            }
            break;*/
        }
        
        return result;
    }
    
    public static SObject first(List<SObject> soList) {
        if(soList == null || soList.size() == 0) {
            return null;
        }
        
        return soList[0];
    }
}