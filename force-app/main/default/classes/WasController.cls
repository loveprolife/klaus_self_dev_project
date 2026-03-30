/*
 * @Author: WFC
 * @Date: 2024-11-05 15:00:06
 * @LastEditors: WFC
 * @LastEditTime: 2024-11-06 17:53:41
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\classes\WasController.cls
 */
public without sharing class WasController{
    public String userName{ get; set; }

    public WasController(){
        User user = [SELECT Id, UserName
                     FROM User
                     WHERE Id = :UserInfo.getUserId()
                     LIMIT 1];
        // 截取@前面用户名
        String[] parts = user.UserName.split('@');
        if (parts.size() > 0){
            userName = parts[0];
        }
    }

}