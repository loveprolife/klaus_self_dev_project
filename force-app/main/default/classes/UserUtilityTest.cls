@isTest
public with sharing class UserUtilityTest {
    
    @isTest
    static void Test1() {
        UserUtility.getParentRoles(UserUtility.allRoles[0].Id);
        UserUtility.getRootRoleMap(UserUtility.allRoles[0].Id);
        UserUtility.getRootRoleList(UserUtility.allRoles[0].Id);
        UserUtility.getSystemAdmin();
        UserUtility.IsSystemAdministrator();
        UserUtility.getManagerByRoleHierarchy(UserInfo.getProfileId());
    }
}