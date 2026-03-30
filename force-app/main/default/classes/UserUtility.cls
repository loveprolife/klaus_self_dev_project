public without sharing class UserUtility {
    
    private static Id sys_admin_profile_id = null;
    private static final PermissionSet adminPermissionSet = [SELECT profileId  FROM PermissionSet WHERE IsOwnedByProfile = true AND IsCustom = false and permissionsmanageusers = true limit 1];
    private static User sysadmin = null;
    public static final User currentUser = [SELECT Id,Name, Username, FirstName, LastName, Email, Profile.Name, UserRole.Name, UserRole.DeveloperName,UserPreferencesUserDebugModePref,TIMBASURVEYS__SurveyReminder__c,TIMBASURVEYS__reminderStringSize__c,AccountCode__c,Country__c,Direct_Sales_Department_Location__c,HisenseSSOName__c,Position__c,Sales_Region__c,User_Full_Name__c,Management_Level__c,Plan_Login_Num__c,Plan_Customer_Visit_Num__c,Office__c,Email_Key__c,Department__c,Role_Type__c from User where Id = :UserInfo.getUserId() limit 1];

    public static Boolean IsSystemAdministrator() {
        return IsSystemAdministrator(UserInfo.getProfileId());
    }

    public static Boolean IsSystemAdministrator(String profileId){
        return profileId == GetSystemAdminProfileId();
    }

    public static Id GetSystemAdminProfileId(){
        if (sys_admin_profile_id == null ) {
            sys_admin_profile_id = adminPermissionSet.profileId;
            return adminPermissionSet.profileId;
        }
        else {
            return sys_admin_profile_id;
        }
    }

    public static User getSystemAdmin() {
        if (sysadmin == null) {
            sysadmin = [
                SELECT
                    ID,
                    UserName,
                    Name,
                    Email,
                    ProFileId
                FROM User
                WHERE IsActive = true 
                    AND ProFileId = :GetSystemAdminProfileId()
                LIMIT 1
            ];
        }
        return sysadmin;
    }

    public static final List<UserRole> allRoles = [
        SELECT
            ID,
            Name,
            DeveloperName,
            ParentRoleId
        FROM UserRole
    ];

    public static List<User> getManagerByRoleHierarchy(String roleId) {
        return getManagerByRoleHierarchy(roleId, true);
    }

    public static List<User> getManagerByRoleHierarchy(String roleId, Boolean isActive) {
        List<User> users = new List<User>();
        if (roleId == null) {
            return users;
        }

        List<UserRole> parentRoles = getParentRoles(roleId);
        List<User> queryUsers = [
            SELECT 
                ID,
                Name,
                UserName,
                FirstName,
                LastName,
                ManagerId,
                Sales_Region__c,
                Country__c,
                UserRoleId
            FROM User
            WHERE UserRoleId IN :(new Map<Id, UserRole>(parentRoles).keySet())
                AND IsActive = :isActive
        ];
        for (UserRole ur : parentRoles) {
            for (User u : queryUsers) {
                if (u.UserRoleId == ur.Id) {
                    users.add(u);
                }
            }
        }

        return users;
    }

    /**
     * @description 获取角色及其所有祖先角色
     * @param   角色id
     * @return
     */
    public static List<UserRole> getParentRoles(String roleId) {
        return getParentRoles(allRoles, roleId);
    }
    

    /**
     * @description 在指定的角色范围内获取角色及其所有祖先角色
     * @param   角色id
     * @return
     */
    public static List<UserRole> getParentRoles(List<UserRole> roleList, String roleId) {
        List<UserRole> roles = new List<UserRole>();
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>(roleList);
        Integer deep = 0;
        for (Integer i = 0; i < 200; i++) {
            if(roleMap.containsKey(roleId)) {
                if (i != 0) {
                    roles.add(roleMap.get(roleId));
                }
                roleId = roleMap.get(roleId).ParentRoleId;
            } else {
                break;
            }
        }
        
        return roles;
    }

    /**
     * @description 获取角色树
     * @param       顶级角色id
     * @return
     */
    public static Map<String, object> getRootRoleMap(String rootId) {
        Map<String, object> result = new Map<String, object>();
		getRootRoles(rootId, result, null);
        return result;
	}
    
    /**
     * @description 获取角色一下的所有列表
     * @param       顶级角色
     * @return
     */
    public static List<UserRole> getRootRoleList(String rootId) {
        List<UserRole> resultList = new List<UserRole>();
		getRootRoles(rootId, null, resultList);
        return resultList;
	}

    /**
     * @description 获取角色以下的所有角色
     * @param   顶级角色id
     * @param   用于接收返回的map
     * @param   用于接收返回的List
     * @return
     */
    public static void getRootRoles(String rootId, Map<String, object> resultMap, List<UserRole> resultList) {
        getRoleCore(rootId, allRoles, resultMap, resultList, 0);
    }

	public static void getRoleCore(String parentId, List<UserRole> roleList, Map<String, object> resultMap, List<UserRole> resultList, Integer deep) {
		if (deep > 20) {
			return;
		}
        /*if(currentUR != null) {
            system.debug(''.leftPad(deep, '-') + currentUR.Id + ',' + currentUR.Name);
        }
        String parentId = currentUR == null ? null : currentUR.Id;*/
		Map<String, object> temp = new Map<String, object>();
		for (UserRole ur : roleList) {
			if (ur.ParentRoleId == parentId) {
                if(resultMap != null) {
                    resultMap.put(ur.Id, temp);
                }
				if(resultList != null) {
                    resultList.add(ur);
                }
                //system.debug(''.leftPad(deep + 1, '-') + ur.Id + ',' + ur.Name);
				getRoleCore(ur.Id, roleList, temp, resultList, deep + 1);
			}
		}
	}

}