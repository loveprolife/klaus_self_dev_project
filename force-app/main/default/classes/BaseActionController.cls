public virtual class BaseActionController {
	
    public static SObject first(List<SObject> soList) {
        return SObjectHelper.first(soList);
    }
}