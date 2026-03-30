global class HisenseSSORegHandler implements Auth.RegistrationHandler{
    global User createUser(Id portalId, Auth.UserData data){
        system.System.debug('In create user');
        system.System.debug('portalId： '+portalId);
        system.System.debug('UserData:  '+data);
        User u = [SELECT ID FROM User Where id = : data.identifier limit 1];
        return u;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
    }
}