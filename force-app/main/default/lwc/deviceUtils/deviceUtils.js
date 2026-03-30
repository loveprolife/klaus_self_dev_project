// deviceUtils.js
const generateDeviceId = () => {
    // 获取设备指纹特性
    const userAgent = navigator.userAgent || 'Unknown';
    const screenSize = `${screen.width}x${screen.height}`;
    const pixelRatio = window.devicePixelRatio || 0;

    // 组合特性生成唯一标识符
    const deviceFingerprint = `${userAgent}-${screenSize}-${pixelRatio}`;
    console.log(deviceFingerprint);
    // 返回哈希值作为唯一标识符
    return hashString(deviceFingerprint);
};

const hashString = (str) => {
    let hash = 0x811c9dc5; // FNV offset basis
    for (let i = 0; i < str.length; i++) {
        hash ^= str.charCodeAt(i);
        hash += (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24);
    }
    return (hash >>> 0).toString(16); // 转为8位十六进制字符串
};

// 导出模块方法
export { generateDeviceId };