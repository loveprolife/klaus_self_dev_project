public class SFTPCalloutService {
    public static void uploadFileToSFTP(String fileContent, String fileName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // 替换为SFTP服务API端点（需提前授权远程站点）
        request.setEndpoint('https://sftp.example.com/upload');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/octet-stream');
        request.setHeader('Content-Disposition', 'attachment; filename="' + fileName + '"');
        request.setBodyAsBlob(Blob.valueOf(fileContent));
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            System.debug('文件上传成功: ' + response.getBody());
        } else {
            System.debug('上传失败，状态码: ' + response.getStatusCode());
        }
    }
}