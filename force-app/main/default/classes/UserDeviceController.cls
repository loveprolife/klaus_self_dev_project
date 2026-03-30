public class UserDeviceController{
    private final List<DeviceWrapper> devices;

    public String targetId{ get; set; }

    public UserDeviceController(){
        targetId = '';
        List<UserDevice> userDeviceList = [SELECT Id, User.Name, DeviceType, PlatformType, Status
                                           FROM UserDevice];
        devices = new List<DeviceWrapper>();
        for (UserDevice d : userDeviceList){
            DeviceWrapper a = new DeviceWrapper();
            a.id = d.id;
            a.userName = d.User.Name;
            a.deviceType = d.DeviceType;
            a.platformType = d.PlatformType;
            a.status = d.Status;
            devices.add(a);
        }
    }

    public List<DeviceWrapper> getDevice(){
        return devices;
    }

}