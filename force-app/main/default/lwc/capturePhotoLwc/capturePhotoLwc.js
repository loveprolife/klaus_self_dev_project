import { api } from 'lwc';
import { LightningElementEx } from 'c/lwcUtils'
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import compress from '@salesforce/resourceUrl/compress';
import { createRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CaptureDebugConfig from '@salesforce/label/c.CaptureDebugConfig';

import CheckInCheckOut_PHOTO from '@salesforce/label/c.CheckInCheckOut_PHOTO';


export default class CapturePhotoLwc extends LightningElementEx {
    
    label = {
        CheckInCheckOut_PHOTO
    }
    @api isCompress;
    @api forceDebug;
    debugModeConfig = {
        "IsOpen" : false,
        "Users": [""]
    };

    get debugMode() {
        return this.forceDebug || this.debugModeConfig && this.debugModeConfig.IsOpen && this.debugModeConfig.Users  && this.debugModeConfig.Users.indexOf(this.CASESAFEID(USER_ID)) > -1;
    }

    loadCompress;
    get cps() {
        return this.loadCompress && this.isCompress;
    }
    streamObj = null;
    faceMode = "environment";
    // capturestatus = true;
    initWidth = 2880;
    initHeight = 3840;
    actualWidth = 0;
    actualHeight = 0;
    width = 0;
    height = 0;
    clientModel;
    canvas;
    acturalCanvas;
    video;
    inited;
    opening = true;
    // initedSuccess = true;
    initing;
    message = '10';
    messageLog = [];

    get context() {
        return this.canvas ? this.canvas.getContext('2d') : {};
    }

    get videoStyle() {
        return "width:100%;" + (this.opening ? '' : 'display:none;');
    }

    get canvasStyle() {
        return "background:#FAF0E6;" + (this.opening ? 'display:none;' : '');
    }

    get captureIconUrl() {
        return "/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#" + (this.opening ? 'photo' : 'refresh');
    }

    connectedCallback() {
        try {
            this.debugModeConfig = JSON.parse(CaptureDebugConfig);
        } catch (error) {
            
        }
        var userAgent = navigator.userAgent;
        if (/android|Android/.test(userAgent)) { 
            this.clientModel = 'Android';
        } else if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent)) {
            this.clientModel = 'iOS';
        } else {
            this.clientModel = 'Other';
        }
        loadScript(this, compress).then(()=>{
            this.loadCompress = true;
        }).catch((error) => {
            this.showWarning(this.customLabel.CompressLoadFailed)
        });
    }

    renderedCallback() {
        this.canvas = this.template.querySelector('.canvas')
        if (!this.inited && this.canvas) {
            this.inited = true;
            this.video = this.template.querySelector('video')
            this.width = this.video.offsetWidth;
            this.height = (this.width / 3 * 4)
            this.log('User is:' + USER_ID);
            this.log('User is:' + this.CASESAFEID(USER_ID));
            this.log('this.width:' + this.width + ',this.height:' + this.height);
            this.video.style.height = this.height+ 'px';
            this.video.width = this.initWidth;
            this.video.height = this.initHeight;
            this.canvas.width = this.video.width = this.width;
            this.canvas.height = this.video.height = this.height;
            this.getModelInformation();
            this.videoStart();
        }
    }

    getModelInformation() {
        const userAgent = navigator.userAgent;

        // 屏幕宽度
        this.log('设备浏览器窗口 width:');
        this.log(window.screen.width);
        // 屏幕高度
        this.log('设备浏览器窗口 height:');
        this.log(window.screen.height);
        // CSS像素比
        this.log('设备物理像素与CSS像素比率 resolution:');
        this.log(window.devicePixelRatio);
        // 设备信息
        this.log('用户代理信息:');
        this.log('userAgent:'+navigator.userAgent);
        this.log('浏览器供应商信息:');
        this.log('vendor:'+navigator.vendor);
        this.log('运行浏览器操作系统平台:');
        this.log('platform:'+navigator.platform);
        this.log('用户操作系统:');
        this.log('oscpu:'+navigator.oscpu);
        this.log('浏览器相关版本+操作系统信息:');
        this.log(navigator.appVersion);
        // this.log(userAgent.toString());
    }

    videoStart() {
        if (this.initing) {
            return;
        }
        this.log('-----------------start click-----------------');
        // capturestatus = true;
        this.opening = true;
        // this.initedSuccess = false;
        this.initing = true;
        // 获取设备信息
        navigator.mediaDevices.enumerateDevices().then((devices) => {
            this.log('devices 信息获取');
            this.log('devices:');
            this.log(JSON.stringify(devices));
        }).catch((err) => {
            this.log('devices 信息获取 Error');
            this.log(err.name + ": " + err.message);
            this.saveLog();
        });

        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        // video.oncanplay = setTimeout(showButton,100);;
        // let canvas = document.getElementById('canvas');

        // this.log(1)
        this.log('开始访问媒体设备')
        if (navigator.mediaDevices.getUserMedia || navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia) {
            // this.log(4)
            //调用用户媒体设备, 访问摄像头
            try{
                let constraints = {
                    audio:false, 
                    video: {
                        width:this.initHeight, 
                        height:this.initWidth, 
                        facingMode: { exact: this.faceMode }
                    }
                }
                this.log('constraints:' + JSON.stringify(constraints));
                this.getUserMedia(constraints);
            }catch(e){
                this.log(e);
                this.saveLog();
            }
        } else {
            // this.log(5)
            this.log('媒体设备访问失败')
            this.showError('不支持访问用户媒体');
            this.saveLog();
        }
    }

      // //访问用户媒体设备的兼容方法
    getUserMedia(constraints) {
        let success = (stream) => {
            this.log('访问媒体设备成功')
            //兼容webkit核心浏览器
            // let CompatibleURL = window.URL || window.webkitURL;
            //将视频流设置为video元素的源
            // console.this.log(JSON.stringify(stream));
    
            //video.src = CompatibleURL.createObjectURL(stream);
            this.streamObj = this.video.srcObject = stream;
            this.video.play();
                    //setTimeout(showButton,100);
            stream.getVideoTracks().forEach(track => {
                this.log('aspectRatio:'+track.getSettings().aspectRatio)
                this.actualWidth = track.getSettings().width;
                this.actualHeight = track.getSettings().height;
                this.log('width:'+track.getSettings().width)
                this.log('height:'+track.getSettings().height)
            })
            this.initing = false;
            // this.initedSuccess = true;
        }
    
        let error = (error) => {
            this.log(`访问用户媒体设备失败${error.name}, ${error.message}`);
            this.log('访问用户媒体设备失败');
            this.showError('access camera failed!(' + error.name +  ')');
            this.log( error.name + '\n' + error.message);
            this.initing = false;
            this.saveLog();
        }

        if (navigator.mediaDevices.getUserMedia) {
            // this.log(5)
            this.log('进入最新的标准API start');
            //this.log(navigator.mediaDevices.getUserMedia)
            //最新的标准API
            navigator.mediaDevices.getUserMedia(constraints).then(success).catch(error);
            // this.log(6)
            
            this.log('进入最新的标准API end');
        } else if (navigator.webkitGetUserMedia) {
            this.log('进入webkit核心浏览器 start');
            // this.log(7)
            //webkit核心浏览器
            navigator.webkitGetUserMedia(constraints, success, error)
            // this.log(8)
            this.log('进入webkit核心浏览器 end');
        } else if (navigator.mozGetUserMedia) {
            this.log('进入firfox浏览器 start');
            // this.log(9)
            //firfox浏览器
            navigator.mozGetUserMedia(constraints, success, error);
            // this.log(10)
            this.log('进入firfox浏览器 end');
        } else if (navigator.getUserMedia) {
            // this.log(11)
            this.log('进入旧版API start');
            //旧版API
            navigator.getUserMedia(constraints, success, error);
            // this.log(12)
            this.log('进入旧版API end');
        } else {
            this.log('进入else');
            this.saveLog();
        }
    }

    handleCapture() {
        this.log('-------------handleCapture-------------')
        if (this.opening) {
            try {
                this.log('this.width:' + this.width + ',this.height:' + this.height);
                let mapWidth = this.actualWidth * this.height / this.actualHeight;
                let start = (this.width - mapWidth) / 2;
                let dx = start;
                let dw = mapWidth;
                this.log('dx:' + dx + ', dw:' + dw);
                // this.context.drawImage(this.video, 0, 0, this.width, this.height);
                let acturalCanvas = this.acturalCanvas = this.template.querySelector('.acturalCanvas');
                acturalCanvas.width = this.actualWidth;
                acturalCanvas.height = this.actualHeight;
                this.context.drawImage(this.video, dx, 0, dw, this.height);
                acturalCanvas.getContext('2d').drawImage(this.video, 0, 0, this.actualWidth, this.actualHeight);

            } catch (error) {
                this.log(JSON.stringify(error));
            }
            // this.context.drawImage(video, 0, 0, 240/window.devicePixelRatio, 320/window.devicePixelRatio);
            // this.context.drawImage(video, 0, 0, window.screen.height, window.screen.height,width);
            // document.getElementById('video').style.display = "none";
            // document.getElementById('canvas').style.display = "unset";
            this.closeCamra();
            this.opening = false;
            // document.getElementById('showlwc').style.display = "unset";
            // document.getElementById('replace').style.display = "none";
            // document.getElementById('capture').style.color = "";
        } else {
            this.videoStart();
        }
    }

    handleSwitch() {
        this.closeCamra();
        if (this.faceMode=="environment") {
            this.faceMode="user";
        } else {
            this.faceMode="environment"
        }
        this.videoStart();
    }
            
    
    closeCamra() {
        if(this.streamObj) {
            this.streamObj.getTracks().forEach(track => {
                this.log('stop');
                track.stop();
            })
        }
    }

    complete(isSuccess = false, isCompress = false, base64 = '') {
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    isSuccess : isSuccess,
                    data : {
                        isCompress : isCompress,
                        base64 : base64
                    }
                }
            })
        );
    }

    handleOk() {
        // document.getElementById('bodyAll').style.display = "none";

        // 将canvas转换为目标大小的base64编码
        let compressedDataUrl = this.acturalCanvas.toDataURL('image/jpeg');
        if (this.cps) {
            new Promise(resolve => {
                ccc(compressedDataUrl).then(d => {
                    resolve(d);
                })
            }).then(d => {
                this.log('compress success.');
                this.complete(true, true, d.base64);
            }).catch(err => {
                this.log('compress error:' + JSON.stringify(err));
                this.saveLog(()=>{
                    this.complete(true, false, compressedDataUrl)
                });
            })
        } else {
            this.complete(true, false, compressedDataUrl);
        }
        
    }

    handleClose() {
        this.closeCamra();
        this.complete();
    }
    
    
    log(msg) {
        console.log(msg);
        this.message += msg + '\n';
        this.messageLog.push(msg);
    }

    saveLog(foo) {
        createRecord({
            apiName: 'TIMBASURVEYS__Log__c',
            fields: {
                Equipment_Info__c : this.messageLog.join('\n'),
                OwnerId : USER_ID
            }
        }).then(newRecord => {
            this.log(newRecord);
            this.messageLog = [];
            if (foo) {
                foo();
            }
        })
        .catch(error => {
            // Handle error
            this.log(USER_ID + ' ' + this.getErrorMessage(error));
            if (foo) {
                foo();
            }
        });
    }
}