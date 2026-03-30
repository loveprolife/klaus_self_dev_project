public abstract class BaseTriggerHandler {
    
    public static Boolean beforeInsertTriggered = false;
    public static Boolean beforeUpdateTriggered = false;
    public static Boolean beforeDeleteTriggered = false;
    public static Boolean afterInsertTriggered = false;
    public static Boolean afterUpdateTriggered = false;
    public static Boolean afterDeleteTriggered = false;
    public static Boolean afterUndeleteTriggered = false;
    private static Map<String, sObject> configMap = null;
	
    static {
        try {
            configMap = new Map<String, sObject>();
            List<sObject> configList = Database.query('SELECT Id, DeveloperName, MasterLabel, Label, IsBefore__c, IsAfter__c, IsInsert__c, IsUpdate__c, IsDelete__c, IsUndelete__c, Description__c FROM TriggerManager__mdt');
            for(sObject sobj : configList) {
                String devName = String.valueOf(sobj.get('DeveloperName'));
				configMap.put(devName, sobj);
                debug(sobj);
            }
        } catch (Exception e) {
            system.debug(e.getMessage() + '\n' + e.getStackTraceString());
            configMap = null;
        }
    }
    
    static void debug(Object obj){
        System.debug(obj);
    }

    protected List<SObject> oldList = Trigger.old;
    protected List<SObject> newList = Trigger.new;

    public virtual void beforeInsert(){}
    public virtual void beforeUpdate(){}
    public virtual void beforeDelete(){}
    public virtual void afterInsert(){}
    public virtual void afterUpdate(){}
    public virtual void afterDelete(){}
    public virtual void afterUndelete(){}

    private Boolean isOn(String className, String fieldName) {
        String devName = className.replace('TriggerHandler', '');
        Boolean b = false;
        try {
            b = (Boolean)configMap.get(devName).get(fieldName + '__c');
            if(!b) {
                debug(devName + ' ' + fieldName + ' is false');
            }
        } catch (Exception e) {
            
        }
        return configMap == null || b;
    }

    public void run() {
        String className = getClassName();
        System.debug('className:' + className);
        if(!Utility.isTriggerDisabled()){
            if (Trigger.isBefore && isOn(className, 'isBefore')) {
                if (Trigger.isInsert && isOn(className, 'isInsert')) {
                    debug('beforeInsert is trigged');
                    this.beforeInsert();
                    beforeInsertTriggered = true;
                }

                if (Trigger.isUpdate && isOn(className, 'isUpdate')) {
                    debug('beforeUpdate is trigged');
                    this.beforeUpdate();
                    beforeUpdateTriggered = true;
                }

                if (Trigger.isDelete && isOn(className, 'isDelete')) {
                    debug('beforeDelete is trigged');
                    this.beforeDelete();
                    beforeDeleteTriggered = true;
                }
            }

            if (Trigger.isAfter && isOn(className, 'isAfter')) {
                if (Trigger.isInsert && isOn(className, 'isInsert')) {
                    debug('afterInsert is trigged');
                    this.afterInsert();
                    afterInsertTriggered = true;
                }

                if (Trigger.isUpdate && isOn(className, 'isUpdate')) {
                    debug('afterUpdate is trigged');
                    this.afterUpdate();
                    afterUpdateTriggered = true;
                }

                if (Trigger.isDelete && isOn(className, 'isDelete')) {
                    debug('afterDelete is trigged');
                    this.afterDelete();
                    afterDeleteTriggered = true;
                }

                if (Trigger.isUndelete && isOn(className, 'isUndelete')) {
                    debug('afterUndelete is trigged');
                    this.afterUndelete();
                    afterUndeleteTriggered = true;
                }
            }
        }
    }

    /**
     * @description 获取继承的handler类名，需要字类override
     * @return	String	类名
    */
    protected virtual String getClassName()
    {
        String className = '';
        try {
            throw new DMLException('');
        } catch (Exception e) {
            String[] ss = e.getStackTraceString().split('\n');
            if (ss.size() > 1) {
                className = ss[1].split('\\.')[1];
            }
        }
        return className;
    }  
}