import { LightningElement, track, wire,api } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import TEXT_LN_ENDPOINT from '@salesforce/label/c.TEXT_LN_ENDPOINT';
import TEXT_LN_APP_ID from '@salesforce/label/c.TEXT_LN_APP_ID';
import TEXT_LN_SECRET_CODE from '@salesforce/label/c.TEXT_LN_SECRET_CODE';
import TEXT_LN_ENDPOINT_UNIVERSAL from '@salesforce/label/c.TEXT_LN_ENDPOINT_UNIVERSAL';
import CARD_SCAN from '@salesforce/label/c.Exhibition_Scan_Image';
import CARD_SCAN_SHOW from '@salesforce/label/c.Exhibition_Scan_Image_Tip_Show';
import CARD_SCAN_HIDDEN from '@salesforce/label/c.Exhibition_Scan_Image_Tip_Hidden';


/** code错误码
错误码	描述
40101	x-ti-app-id 或 x-ti-secret-code 为空
40102	x-ti-app-id 或 x-ti-secret-code 无效，验证失败
40103	客户端IP不在白名单
40003	余额不足，请充值后再使用
40004	参数错误，请查看技术文档，检查传参
40007	机器人不存在或未发布
40008	机器人未开通，请至市场开通后重试
40301	图片类型不支持
40302	上传文件大小不符，文件大小不超过 10M
40303	文件类型不支持
40304	图片尺寸不符，图像宽高须介于 20 和 10000（像素）之间
40305	识别文件未上传
30203	基础服务故障，请稍后重试
500	服务器内部错误
**/

/** bcKey  bcDescription
family_name 姓
given_name 名
name 姓名
telephone 手机
work_tel 电话
fax 传真
email 邮件
company 公司
department 部门
title 职称
address 地址
url 网址
other 其他信息
QQ QQ
crop_image 切图的base64编码,返回JPEG的格式图像
**/

function BusinessCardInfo(code,msg,dataList){
    this.code = code;
    this.msg = msg;
    this.dataList = dataList;
	}
function BusinessCardSingle(bcKey,bcDescription, bcValue){
	this.bcKey = bcKey;
	this.bcDescription = bcDescription;
	this.bcValue = bcValue;
}
const POST_METHOD = 'POST'; //POST method
const CONTENT_TYPE = 'application/octet-stream';
const ENDPOINT = TEXT_LN_ENDPOINT;//API endpoint
const APP_ID =  TEXT_LN_APP_ID;
const SECRET_CODE =  TEXT_LN_SECRET_CODE;
const PAR_STR = '?crop_image=0';//URL参数，不返回图片切图
const ENDPOINT_UNIVERSAL = TEXT_LN_ENDPOINT_UNIVERSAL;
export default class textLnBasicLwc extends LightningElement {
	@api textLnType;//调用的哪个api
	@api isApplied;//是否已被调用
	@track TextLnAPIUrl = 'https://api.textin.com/robot/v1.0/api/';
	@track errorMsg = 'Error type! Please input image/png, image/jpg, image/jpeg '
	@track resourceFile;
	@track againResourceFile;
	@track isShowAllInfo = false;
	@track isShowBt = false;
	hidLabel = CARD_SCAN_HIDDEN;
	showLabel = CARD_SCAN_SHOW;
	@track btlabel = CARD_SCAN_SHOW
	@track universalText = '';
	//Sys_Lang
	sysLang = LANG;
	@track tipLabel = CARD_SCAN;


	// @track file

	
	connectedCallback() {
	  	console.log('textLnBasicLwc--------');
	  	console.log('textLnType-->'+this.textLnType);
	  	this.TextLnAPIUrl = ENDPOINT+this.textLnType + PAR_STR;
	  	// if ('zh-Hans-CN' == this.sysLang) {
	  	// 	this.tipLabel = '名片扫码';
	  	// 	this.btlabel = '展开详情'
	  	// }
	  	// console.log('TextLnAPIUrl------------>1'+this.TextLnAPIUrl);
	 }


	handleInputChange(event){ 
        console.log('handleInputChange---');
        //增加事件
        const onstartEvt = new CustomEvent('startscan',{});
								this.dispatchEvent(onstartEvt);

        this.isShowBt = true;
        this.isShowAllInfo = false;
        this.btlabel = this.showLabel;
        this.resourceFile = event.target.files;
		if(!this.judgeFieldValueEmpty(event.target.files)) {
			let file = event.target.files[0];
			// this.resourceFile = file;
			let childToParentValue = [];
			 Promise.resolve(file)
              .then((file1) => {
                // 1-1. Read file to Binary
                return this.readAsArrayBuffer(file1);
              })
              .then((blob) => {
              		var xhr = new XMLHttpRequest()
			        xhr.open('POST', this.TextLnAPIUrl)
			        xhr.setRequestHeader('Content-Type', CONTENT_TYPE)
			        xhr.setRequestHeader('x-ti-app-id', APP_ID)
			        xhr.setRequestHeader('x-ti-secret-code', SECRET_CODE)
			        xhr.send(blob);
			        var that = this;
					xhr.onreadystatechange = function () {
			            if (xhr.readyState === 4) {
			                xhr.onreadystatechange = null
			                var response = xhr.response
			                var obj = {}
			                try {
			                    obj = JSON.parse(response) // 转化为对象
			                } catch (e) {
				            	const passEvent = new CustomEvent('getbusinesscardinfo', 
				            		{detail:{BusinessCardInfos : new BusinessCardInfo(200, e, null)} 
									        });
								that.dispatchEvent(passEvent);
			                	return 
			                }
			                if (obj.code != 200){
			                	const passEvent = new CustomEvent('getbusinesscardinfo', 
				            		{detail:{BusinessCardInfos : new BusinessCardInfo(obj.code, obj.message, null)} 
									        });
								that.dispatchEvent(passEvent);
			                	return
			                }  

			                var list = obj.result.item_list
			                if (!list || !list.length){
			                	const passEvent = new CustomEvent('getbusinesscardinfo', 
				            		{detail:{BusinessCardInfos : new BusinessCardInfo(201, 'null', null)} 
									        });
								that.dispatchEvent(passEvent);
			                	return  
			                } 
			            	// console.log('list'+JSON.stringify(list));
			            	list = JSON.parse(JSON.stringify(list));
			            	const cardInfoList  =  new Array();//[]
			            	for (var i = 0; i < list.length; i++) {
			            		if (list[i].value) {
			            			cardInfoList.push(new BusinessCardSingle(list[i].key, list[i].description, list[i].value))
			            		}
			            	}
			            	// console.log('cardInfoList-->'+JSON.stringify(cardInfoList));
			            	// console.log('---toParents--->'+that.toParentInfos);
			            	const passEvent = new CustomEvent('getbusinesscardinfo', {
								            detail:{BusinessCardInfos : new BusinessCardInfo(obj.code, obj.message, cardInfoList)
								            	} 
								        });
							that.dispatchEvent(passEvent);
			            	return 

			        	}	 
			    	}
		                	
                })
           }

    }

    handerClick(){
		this.isShowAllInfo = !this.isShowAllInfo
		let showstr = this.showLabel;
		let hiddenStr = this.hidLabel;
		this.btlabel = this.isShowAllInfo ? hiddenStr : showstr;
		console.log('handerClick---');
		console.log('file--->'+this.resourceFile);
		if(!this.judgeFieldValueEmpty(this.resourceFile) && hiddenStr == this.btlabel && this.againResourceFile != this.resourceFile) {
			let file = this.resourceFile[0];
			Promise.resolve(file)
              .then((file1) => {
                return this.readAsArrayBuffer(file1);
              })
              .then((blob) => {
              		let xhr = new XMLHttpRequest()
			        xhr.open('POST', ENDPOINT_UNIVERSAL)
			        xhr.setRequestHeader('Content-Type', CONTENT_TYPE)
			        xhr.setRequestHeader('x-ti-app-id', APP_ID)
			        xhr.setRequestHeader('x-ti-secret-code', SECRET_CODE)
			        // console.log('blob--->'+blob);
			        xhr.send(blob);
			        var that = this;
					xhr.onreadystatechange = function () {
			            if (xhr.readyState === 4) {
			                xhr.onreadystatechange = null
			                var response = xhr.response
			                var obj = {}
			                try {
			                	console.log('response---->'+JSON.stringify(response));
			                    obj = JSON.parse(response) // 转化为对象
			                } catch (e) {
				    //         	const passEvent = new CustomEvent('getbusinesscardinfo', 
				    //         		{detail:{BusinessCardInfos : new BusinessCardInfo(200, e, null)} 
								// 	        });
								// that.dispatchEvent(passEvent);
								console.log('row 184',e, response);
			                	return 
			                }
			                if (obj.code != 200){
			     //            	const passEvent = new CustomEvent('getbusinesscardinfo', 
				    //         		{detail:{BusinessCardInfos : new BusinessCardInfo(obj.code, obj.message, null)} 
								// 	        });
								// that.dispatchEvent(passEvent);
								console.log('row 193'+e);
			                	return
			                }  

			                var list = obj.result.lines
			                if (!list || !list.length){
			     //            	const passEvent = new CustomEvent('getbusinesscardinfo', 
				    //         		{detail:{BusinessCardInfos : new BusinessCardInfo(201, 'null', null)} 
								// 	        });
								// that.dispatchEvent(passEvent);
								console.log('row 202'+e);
			                	return  
			                } 
			            	// console.log('list'+JSON.stringify(list));
			            	that.universalText = '';
			            	list = JSON.parse(JSON.stringify(list));
			            	for (var i = 0; i < list.length; i++) {
			            		if (list[i].text) {
			            			that.universalText += list[i].text + '\n';
			            		}
			            	}

			            	// console.log('universalText-->'+JSON.stringify(that.universalText));
			            	// console.log('---toParents--->'+that.toParentInfos);
			    //         	const passEvent = new CustomEvent('getbusinesscardinfo', {
							// 	            detail:{BusinessCardInfos : new BusinessCardInfo(obj.code, obj.message, cardInfoList)
							// 	            	} 
							// 	        });
							// that.dispatchEvent(passEvent);
			            	return 

			        	}	 
			    	}
		                	
                })
        }

        this.againResourceFile = this.resourceFile;

	}

    //读取为ArrayBuffer
    readAsArrayBuffer(file) {
	    return new Promise(function(resolve, reject){
	        var reader = new FileReader();
	        reader.onload = function() {            
	            resolve(reader.result);
	        }
	        reader.onerror = function() {
	            reject(reader.error);
	        }
	        reader.onabort = function() {
	            reject(new Error('Upload aborted.'));
	        }
	        reader.readAsArrayBuffer(file);
	    });
	}

	
	//是否不为空
	judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }

    //是否是图片的后缀名
    judeFieldValueIsImgType(fieldName){
		//后缀获取
		if (!this.judeFieldValueIsImgType(fieldName)) {
			let suffix = '';
			const flieArr = fieldName.split('.');
			suffix = flieArr[flieArr.length - 1];
			if(suffix!=""){
			suffix = suffix.toLocaleLowerCase();
			// 图片格式
			const imglist = ['png', 'jpg', 'jpeg', 'bmp', 'gif'];
			// 进行图片匹配
			result = imglist.find(item => item === suffix);

			if (result)  return true;

			}

			return false;
		}

    }




    BusinessCardInfoFuc(code,msg,dataList){
    	return {"code": code,
    			"msg": msg,
    			'data': dataList
    			 }
	}


    fucFetchReq(url, data){
    	return fetch(url, {
			  method: POST_METHOD, // or 'PUT'
			  // credentials: 'include', 
			  body: data, // data can be `string` or {object}!
			  headers: {
			    'Content-Type': CONTENT_TYPE,
			    'x-ti-app-id' : APP_ID,
				'x-ti-secret-code' : SECRET_CODE
			  }
			}).then(response => response.json())
    }


}