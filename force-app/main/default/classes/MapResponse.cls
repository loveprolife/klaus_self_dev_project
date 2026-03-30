public class MapResponse extends ConResponse{
	
    private Map<String, Object> mso;
    
    public MapResponse() {
        super.data = mso = new Map<String, Object>();
    }
    public void put(String key, object val) {
        mso.put(key, val);
    }
    
    public Object get(String key) {
        return mso.get(key);
    }
    
    public Boolean containsKey(String key) {
        return mso.containsKey(key);
    }
}