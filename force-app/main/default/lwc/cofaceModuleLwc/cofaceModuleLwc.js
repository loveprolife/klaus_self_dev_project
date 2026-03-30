import { LightningElement, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import LightningConfirm from 'lightning/confirm';
import CustomModal from 'c/customModal';
import { NavigationMixin } from 'lightning/navigation';

import getCofaceToken from '@salesforce/apex/CofaceModuleController.getCofaceToken';
import refreshToken from '@salesforce/apex/CofaceModuleController.refreshToken';
import getCofaceCountry from '@salesforce/apex/CofaceModuleController.getCofaceCountry';
import handleSearchCompanyByFilters from '@salesforce/apex/CofaceModuleController.handleSearchCompanyByFilters';
import searchReportDataByIconNumber from '@salesforce/apex/CofaceModuleController.searchReportDataByIconNumber';
import searchCompanyByIconNumber from '@salesforce/apex/CofaceModuleController.searchCompanyByIconNumber';
import saveReportOrder from '@salesforce/apex/CofaceModuleController.saveReportOrder';
import checkHistoricalReportOrder from '@salesforce/apex/CofaceModuleController.checkHistoricalReportOrder';

const MODE_COMPANY = 'COMPANY_NAME';
const MODE_IDENTIFIER = 'IDENTIFIER';

var timeIntervalRefreshToken;

export default class CofaceModuleLwc extends LightningNavigationElement {
    @track isShowSpinner = false;
    @track isShowOrderSpinner = false;

    // Modal state
    @track isDialogOpen = false;
    @track isReportDialopOpen = false;
    @track isImmediate;
    @track isMonitorable;
    @track reportType = '';
    @track reportTypeSlug = '';
    @track selectItem = {};
    @track selectItemOriginal = {};
    @track selectedItemId;
    @track iconNumber;
    @track lastIconNumber; // 最后一次查询公司的iconNubmer，唯一值，是否需要重新查一次接口
    @track reportData;
    @track companyInformation;
    @track legalForm;
    @track lastMajorUpdate;
    @track registrationDate;
    // 格式化后的日期
    @track registrationDateFormatted;
    @track lastMajorUpdateFormatted;

    // 第一行：互斥选择
    mode = MODE_COMPANY;
    modeOptions = [
        { label: '公司名称', value: MODE_COMPANY },
        { label: '识别号', value: MODE_IDENTIFIER }
    ];

    // 第二行及更多条件
    @track country = '';
    @track countryName = '';
    @track countrySpecial = false;
    countryOptions = [
        // { label: '中国', value: 'China' },
        // { label: '美国', value: 'USA' },
        // { label: '日本', value: 'Japan' },
        // { label: '德国', value: 'Germany' },
        // { label: '法国', value: 'France' },
        // { label: '英国', value: 'UK' }
    ];
    // 可输入模糊搜索所需的状态
    @track countrySearchText = '';
    @track showCountryDropdown = false;
    @track filteredCountryOptions = this.countryOptions;
    identifierTypeOptions = [
        { label: 'Legal id', value: 'legalId' },
        { label: 'Icon Number', value: 'icon' },
        { label: 'Easy Number', value: 'easy' },
    ];
    @track companyName = '';
    @track showMoreFilters = false;
    @track postalCode = '';
    @track city = '';

    @track identifierType = '';
    @track identifierValue = '';

    @track idToken = '';
    @track refreshToken = '';

    // 默认值与条件变化跟踪
    initialized = false;
    lastQueriedFilters = null;

    // 即时和调查选项
    @track availabilityOptions = [];
    @track availabilityValue = '';
    // 监控选项
    @track monitorableOptions = [];
    @track monitorableValue;
    // Show amounts in
    @track currencyValue = 'Local';
    @track languageValue = 'en';
    @track languageLabel = 'English';

    currencyOptions = [
        { label: "Local currency", value: "Local" },
        { label: "USD", value: "USD" },
        { label: "EUR", value: "EUR" },
        { label: "GBP", value: "GBP" },
    ];
    languageOptions = [
        { label: "Italian", value: "it" },
        { label: "Spanish", value: "es" },
        { label: "German", value: "de" },
        { label: "Polish", value: "pl" },
        { label: "English", value: "en" },
        { label: "French", value: "fr" },
    ];

    get currentFilters() {
        return {
            mode: this.mode,
            country: this.country,
            companyName: this.companyName && this.companyName.trim(),
            postalCode: this.postalCode && this.postalCode.trim(),
            city: this.city && this.city.trim(),
            identifierType: this.identifierType,
            identifierValue: this.identifierValue && this.identifierValue.trim()
        };
    }

    get hasChangesSinceLastQuery() {
        if (!this.lastQueriedFilters) return true;
        return JSON.stringify(this.currentFilters) !== JSON.stringify(this.lastQueriedFilters);
    }

    // 结果与已选用
    @track results = [];
    // 查询公司原始未处理数据
    @track resultsOriginal = [];
    // 悬停索引用于控制样式
    @track hoverIndex = -1;
    @track selectedList = [
        { id: 'sel-1', name: '示例公司 A', country: 'China' },
        { id: 'sel-2', name: '示例公司 B', country: 'USA' },
        { id: 'sel-3', name: '示例公司 C', country: 'Germany' }
    ];

    get isCompanyMode() {
        return this.mode === MODE_COMPANY;
    }

    get hasResults() {
        return this.results && this.results.length > 0;
    }

    get resultCount() {
        return this.results.length;
    }

    get noSelectedPlaceholder() {
        return !this.selectedList || this.selectedList.length === 0;
    }

    // 获取coface token方法
    @wire(getCofaceToken)
    wireGetCofaceToken({ error, data }) {
        if (data) {
            let tokenResult = JSON.parse(data);
            this.idToken = tokenResult.idToken;
            this.refreshToken = tokenResult.refreshToken;
            // 启用定时，token一个小时有效时间，超过后调用coface刷新token接口
            clearInterval(timeIntervalRefreshToken);
            timeIntervalRefreshToken = setInterval(() => {
                this.executeRefreshToken();
            }, 1000 * 60 * 60);
        } else if (error) {
            console.log(error);
            this.showError('Get Coface Token error');
        }
    }

    // 获取国家信息
    @wire(getCofaceCountry)
    wireGetCofaceCountry({ error, data }) {
        if (data) {
            this.countryOptions = data;
        } else if (error) {
            console.log(error);
            this.showError('Get Coface Country error');
        }
    }

    // 防抖标记：处理输入框 blur 与下拉点击的事件竞争，避免闪一下就消失
    _internalMouseDown = false;

    // 生命周期：初始化设置下拉默认第一个
    connectedCallback() {
        if (this.initialized) return;

        // 设置国家默认值为第一个
        if ((!this.country || this.country === '') && this.countryOptions && this.countryOptions.length > 0) {
            this.country = this.countryOptions[0].value;
        }
        // 初始化搜索框文本为当前国家名
        const cur = this.countryOptions.find(o => o.value === this.country);
        this.countrySearchText = cur ? cur.label : '';

        // 设置识别类型默认值为第一个
        if ((!this.identifierType || this.identifierType === '') && this.identifierTypeOptions && this.identifierTypeOptions.length > 0) {
            this.identifierType = this.identifierTypeOptions[0].value;
        }

        // 初始化筛选列表
        this.filteredCountryOptions = [...this.countryOptions];

        // 初始化上次查询条件为当前默认条件，首次点击若未修改条件则仍允许查询一次
        this.lastQueriedFilters = null;

        this.initialized = true;

        // 点击页面其他区域时关闭下拉
        window.addEventListener('click', this._handleOutsideClick, true);
    }

    disconnectedCallback() {
        window.removeEventListener('click', this._handleOutsideClick, true);
    }

    _handleOutsideClick = (evt) => {
        // 若点击发生在组件外部，关闭下拉
        if (!this._internalMouseDown) {
            this.showCountryDropdown = false;
        }
    };

    handleCountryMouseDown = () => {
        // 在 mousedown 阶段标记为内部交互，避免 blur 立即关闭
        this._internalMouseDown = true;
        // 同时确保下拉展开且展示全部项
        this.filteredCountryOptions = [...this.countryOptions];
        this.showCountryDropdown = true;
    };

    handleCountryBlur = () => {
        this.showCountryDropdown = false;
        // 重置标记
        this._internalMouseDown = false;
    };

    // 事件处理
    handleModeChange(event) {
        this.mode = event.detail.value;

        // 切换模式时，确保下拉保持默认第一个值
        // if (this.countryOptions?.length && !this.country) {
        //     this.country = this.countryOptions[0].value;
        // }
        if (this.identifierTypeOptions?.length && !this.identifierType) {
            this.identifierType = this.identifierTypeOptions[0].value;
        }

        // // 切换到识别号模式时，清理公司名称模式输入（可按需保留）
        // if (this.mode === MODE_IDENTIFIER) {
        //     this.companyName = '';
        //     this.postalCode = '';
        //     this.city = '';
        //     this.showMoreFilters = false;
        //     this.results = [];
        // } else {
        //     // 切换到公司名称模式时，清理识别号输入
        //     this.identifierValue = '';
        // }
    }

    // 可输入模糊搜索：获得焦点时展示所有国家列表
    handleCountryFocus = () => {
        // 再次点击展开时，始终展示所有国家
        this.filteredCountryOptions = [...this.countryOptions];
        this.showCountryDropdown = true;
    };

    // 输入时进行模糊筛选（label 与 value 均参与，忽略大小写）
    handleCountrySearchInput = (event) => {
        this.handleClearError(); 
        const txt = (event.target && event.target.value) ? event.target.value.trim() : '';
        this.countrySearchText = txt;

        if (!txt) {
            // 输入清空则显示所有
            this.filteredCountryOptions = [...this.countryOptions];
            this.showCountryDropdown = true;
            return;
        }

        const lower = txt.toLowerCase();
        this.filteredCountryOptions = this.countryOptions.filter(opt => {
            return (opt.label && opt.label.toLowerCase().includes(lower)) ||
                   (opt.value && opt.value.toLowerCase().includes(lower));
        });
        // 输入过程中保持展开，防止闪烁
        this.showCountryDropdown = true;
    };

    // 选择某一项
    handleCountrySelect = (event) => {
        const val = event.currentTarget?.dataset?.value;
        const label = event.currentTarget?.dataset?.label;
        const special = event.currentTarget?.dataset?.special;
        if (!val) return;

        this.country = val;
        this.countryName = label;
        this.countrySpecial = special;
        this.countrySearchText = label;
        // const cur = this.countryOptions.find(o => o.value === val);
        // this.countrySearchText = cur ? cur.label : val;

        // 标记内部交互，避免 blur 导致的“闪一下”
        this._internalMouseDown = true;

        // 选中后关闭下拉（延迟到下一个 tick，确保 blur/点击顺序正确）
        setTimeout(() => {
            this.showCountryDropdown = false;
            this._internalMouseDown = false;
        }, 0);

        event.preventDefault();


    };

    handleCompanyNameChange(event) {
        this.companyName = event.detail.value;
        this.handleClearError();
    }

    handlePostalCodeChange(event) {
        this.postalCode = event.detail.value;
    }

    handleCityChange(event) {
        this.city = event.detail.value;
    }

    handleIdentifierTypeChange(event) {
        this.identifierType = event.detail.value;
    }

    handleIdentifierValueChange(event) {
        this.identifierValue = event.detail.value;
        this.handleClearError();
    }

    toggleMoreFilters() {
        this.showMoreFilters = !this.showMoreFilters;
    }

    handleSearch() {
        // 必填校验
        if (this.isCompanyMode) {
            // 公司名称模式：国家+公司名称必填
            const countryCb = this.template.querySelector('.input-validate');
            const companyInput = this.template.querySelector('.input-validate-company-name');

            let hasError = false;
            if (!this.country) {
                this.countrySearchText = '';
                countryCb.setCustomValidity('请选择一个国家');
                countryCb.reportValidity();
                hasError = true;
            }
            if (!this.companyName || this.companyName.trim().length === 0) {
                if (companyInput) {
                    companyInput.setCustomValidity('请输入公司名称');
                    companyInput.reportValidity();
                }
                hasError = true;
            } else {
                companyInput && companyInput.setCustomValidity('');
            }

            if (hasError) return;
        } else {
            // 识别号模式：国家+识别类型+识别号必填
            const countryCb = this.template.querySelector('.input-validate');
            const idTypeCb = this.template.querySelector('.idType');
            const idInput = this.template.querySelector('.identifierValue');

            let hasError = false;

            if (!this.country) {
                this.countrySearchText = '';
                countryCb.setCustomValidity('请选择一个国家');
                countryCb.reportValidity();
                hasError = true;
            }
            if (!this.identifierType) {
                idTypeCb && idTypeCb.reportValidity();
                hasError = true;
            }
            if (!this.identifierValue || this.identifierValue.trim().length === 0) {
                if (idInput) {
                    idInput.setCustomValidity('请输入识别号');
                    idInput.reportValidity();
                }
                hasError = true;
            } else {
                idInput && idInput.setCustomValidity('');
            }

            if (hasError) return;
        }

        // 仅当条件发生变化时刷新列表（首次查询总是允许）
        if (this.lastQueriedFilters && !this.hasChangesSinceLastQuery) {
            // 条件未变化，不刷新；可选：给出轻提示
            // eslint-disable-next-line no-alert
            // alert('搜索条件未变化');
            return;
        }

        // 可能重新输入国家，不是从下拉列表中获取
        if(this.countrySearchText != this.countryName){
            this.country = '';
            this.countryName = '';
            this.countrySpecial = '';
            this.countrySearchText = '';
            return;
        }

        // // 纯前端模拟：基于输入生成 10 条公司
        // const baseName = this.isCompanyMode
        //     ? (this.companyName ? this.companyName.trim() : '公司')
        //     : (this.identifierValue ? `${this.identifierValue.trim()} 匹配公司` : '公司');

        // const country = this.country || 'N/A';
        // const city = this.city || 'N/A';
        // const postal = this.postalCode || 'N/A';

        // const mock = [];
        // for (let i = 1; i <= 10; i++) {
        //     mock.push({
        //         id: `mock-${Date.now()}-${i}`,
        //         name: `${baseName} - 模拟 ${i}`,
        //         country: country,
        //         city: city,
        //         postalCode: postal
        //     });
        // }
        // this.results = mock;

        console.log('wwwww-----' + JSON.stringify(this.currentFilters));
        this.isShowSpinner = true;
        
        // todo 查询公司信息
        handleSearchCompanyByFilters({
            idToken: this.idToken,
            lastQueriedFilters: JSON.stringify(this.currentFilters)
        })
        .then(data => {
            if(data && data.isSuccess){
                this.results = [];
                this.resultsOriginal = [];
                JSON.parse(data.companyData).forEach(item => {
                    const address = [item.address.address1 , item.address.address2, item.address.city, item.address.countryCode].filter(item => item !== '' && item !== undefined).join(',');
                    this.results.push({
                        id: item.id,
                        name: item.name,
                        countryCode: item.address.countryCode,
                        city: item.address.address1 + ',' + item.address.address2 + ',' + item.address.city,
                        postalCode: item.address.postalCode,
                        address: address,
                        externalIds: item.externalIds
                    });
                    this.resultsOriginal.push(item);
                });
            }else {
                this.showError(data.message);
            }
            this.isShowSpinner = false;
        })
        .catch((err) => {
            this.isShowSpinner = false;
            this.showError(err.message);
        });

        // 记录本次查询条件
        this.lastQueriedFilters = this.currentFilters;
    }

    handleArticleClick = (event) => {
        const id = event.currentTarget?.dataset?.id;
        const index = event.currentTarget?.dataset?.index;
        this.selectedItemId = id;
        this.isDialogOpen = true;

        this.selectItem = this.results[index] || null;
        this.selectItemOriginal = this.resultsOriginal[index] || null;

        // selectItem获取icon数据
        let iconNumber = '';
        let countryCode = '';
        if(this.selectItem.externalIds){
            this.selectItem.externalIds.forEach(external => {
                if(external.repositorySlug === 'icon'){
                    iconNumber = external.id;
                    this.iconNumber = external.id;
                }
            });
            countryCode = this.selectItem.countryCode;
        }else {
            return this.showError('系统错误，请联系管理员！');;
        }

        // 判断是否需要重新查接口数据
        if(this.lastIconNumber && this.lastIconNumber === iconNumber){
            return;
        }else {
            this.lastIconNumber = iconNumber;
        }
        // 清除公司详情数据
        this.clearCompanyInformation();

        // todo 查询/companies 接口，返回公司信息
        this.handlerSearchCompanyByIconNumber(iconNumber, countryCode);
        // todo 鼠标点击公司，查询/companies/products 接口，返回report等信息
        this.handlerSearchReportDataByIconNumber(iconNumber, countryCode);
    };

    handlerSearchReportDataByIconNumber(iconNumber, countryCode){
        this.isShowOrderSpinner = true;
        searchReportDataByIconNumber({
            idToken: this.idToken,
            iconNumber: iconNumber,
            countryCode: countryCode
        })
        .then(data => {
            this.isShowOrderSpinner = false;
            if(data && data.isSuccess){
                this.reportData = data.reportData;
            }else {
                this.isDialogOpen = false;
                this.showError(data.message);
            }
        })
        .catch((err) => {
            this.isDialogOpen = false;
            this.isShowOrderSpinner = false;
            this.showError(err.message);
        });
    }

    async handlerSearchCompanyByIconNumber(iconNumber, countryCode) {
        await searchCompanyByIconNumber({
            idToken: this.idToken,
            iconNumber: iconNumber,
            countryCode: countryCode
        })
        .then(data => {
            if(data && data.isSuccess){
                JSON.parse(data.companyInformation).forEach(item => {
                    this.companyInformation = item;
                    this.legalForm = item.legalForm?.label;
                    this.lastMajorUpdate = item.lastMajorUpdate;
                    this.registrationDate = item.registrationDate;
                    // 派生并格式化显示字段
                    this.registrationDateFormatted = this.formatYYYYMMDD(this.registrationDate);
                    this.lastMajorUpdateFormatted = this.formatZonedDateTime(this.lastMajorUpdate);
                });
            }
        })
    }

    handleCloseDialog = () => {
        this.isDialogOpen = false;
        this.isReportDialopOpen = false;
        this.selectedItemId = null;
    };

    handleReport = (event) => {
        // 打开下一步对话框
        this.isDialogOpen = false;
        this.isReportDialopOpen = true;

        // 重置上一次的可选项，避免累加
        this.availabilityOptions = [];
        this.availabilityValue = undefined;
        this.monitorableOptions = [];
        this.monitorableValue = undefined;
        this.isImmediate = undefined;
        this.isMonitorable = undefined;

        const label = event.target.label;
        const value = event.target.value;
        this.reportType = label;
        this.reportTypeSlug = value;

        // 基于 reportData 中与所选 reportType 匹配的项，计算可用性与是否可监控
        try {
            const reports = JSON.parse(this.reportData)?.reports || [];
            const matched = reports.find(r => r.slug === value);
            if (matched) {
                this.isImmediate = matched.availability; // e.g. 'immediate' or other
                this.isMonitorable = matched.isMonitorable === true;
            }
        } catch (e) {
            // 若解析失败，保持默认空选项
        }

        // 显示单选 “Investigation” 和（如支持）“Immediate”
        this.availabilityOptions = [{ label: 'Investigation', value: 'inquiry' }];
        // 默认选中 Investigation
        this.availabilityValue = 'inquiry';
        if (this.isImmediate && String(this.isImmediate).toLowerCase() === 'immediate') {
            this.availabilityOptions = [
                ...this.availabilityOptions,
                { label: 'Immediate', value: 'Immediate' }
            ];
        }

        // 有监控必选监控
        this.monitorableOptions = [];
        if (this.isMonitorable) {
            this.monitorableOptions =  [
                { label: 'Yes', value: 'Yes' }
            ];
            this.monitorableValue = 'Yes';
        }else {
            this.monitorableOptions =  [
                { label: 'No', value: 'No' }
            ];
            this.monitorableValue = 'No';
        }
    };

    handleMonitorable(event){
        this.monitorableValue = event.detail.value;
    }
    handleAvailability(event){
        this.availabilityValue = event.detail.value;
    }
    handleCurrency(event){
        this.currencyValue = event.detail.value;
    }
    handleLanguage(event){
        this.languageValue = event.detail.value;
        // 🔥 获取选中的 label
        const selectedOption = this.languageOptions.find(
            item => item.value === this.languageValue
        );
        this.languageLabel = selectedOption?.label;
    }

    handleBackReport = () => {
        this.isReportDialopOpen = false;
        this.isDialogOpen = true;
    }

    handleUrba360 = () => {
        // this.isDialogOpen = false;
    };

    handleSelect(event) {
        const id = event.currentTarget?.dataset?.id;
        const found = this.results.find(r => r.id === id);
        if (found) {
            // 防重复加入
            const exists = this.selectedList.some(s => s.name === found.name && s.country === found.country);
            if (!exists) {
                this.selectedList = [...this.selectedList, { id: `sel-${Date.now()}`, name: found.name, country: found.country }];
            }
        }
    }

    // 结果卡片悬停样式控制
    handleResultMouseEnter = (event) => {
        const idx = event.currentTarget?.dataset?.index;
        if (idx !== undefined && idx !== null) {
            this.hoverIndex = Number(idx);
            // 给当前卡片添加样式类（通过模板选择器添加以确保样式生效）
            try {
                event.currentTarget.classList.add('hovered');
            } catch(e) {
                // 忽略DOM异常
            }
        }
    };

    handleResultMouseLeave = (event) => {
        this.hoverIndex = -1;
        try {
            event.currentTarget.classList.remove('hovered');
        } catch(e) {
            // 忽略DOM异常
        }
    };


    // 刷新token方法
    executeRefreshToken(){
        refreshToken({
            refreshToken: this.refreshToken,
        })
        .then(data => {
            let tokenResult = JSON.parse(data);
            this.idToken = tokenResult.idToken;
        })
    }

    handleClearError() {
        const inputElement = this.template.querySelector('.input-validate');
        const inputElement1 = this.template.querySelector('.input-validate-company-name');
        const inputElement2 = this.template.querySelector('.identifierValue');
        // 核心方法：重置验证状态，清除红色边框和文字
        if(inputElement){
            inputElement.setCustomValidity(''); 
            inputElement.reportValidity();          
        }
        if(inputElement1){
            inputElement1.setCustomValidity(''); 
            inputElement1.reportValidity();          
        }
         if(inputElement2){
            inputElement2.setCustomValidity(''); 
            inputElement2.reportValidity();          
        }
    }

    clearCompanyInformation(){
        this.companyInformation = {};
        this.legalForm = '';
        this.lastMajorUpdate = '';
        this.registrationDate = '';
        this.registrationDateFormatted = '';
        this.lastMajorUpdateFormatted = '';
    }

    // 将YYYYMMDD转为YYYY-MM-DD
    formatYYYYMMDD(raw) {
        if (!raw) return '';
        // 仅保留数字
        const s = String(raw).replace(/\D/g, '');
        if (s.length !== 8) return String(raw); // 非预期长度则原样返回
        const y = s.slice(0, 4);
        const m = s.slice(4, 6);
        const d = s.slice(6, 8);
        return `${y}-${m}-${d}`;
    }

    // 将带时区时间（如 2026-03-17T01:00:00.000+01:00）按系统用户时区显示为YYYY-MM-DD HH:MM:SS
    formatZonedDateTime(raw) {
        if (!raw) return '';
        try {
            // 交给浏览器解析并自动按本地（系统/用户）时区转换
            const dt = new Date(raw);
            if (isNaN(dt.getTime())) {
                // 兜底：若不能被标准解析，尝试替换空格为T再解析
                const alt = new Date(String(raw).replace(' ', 'T'));
                if (isNaN(alt.getTime())) return String(raw);
                return this.formatDateTimeLocal(alt);
            }
            return this.formatDateTimeLocal(dt);
        } catch (e) {
            return String(raw);
        }
    }

    // 格式化为 YYYY-MM-DD HH:MM:SS（本地时区）
    formatDateTimeLocal(d) {
        const pad = (n) => (n < 10 ? '0' + n : '' + n);
        const yyyy = d.getFullYear();
        const mm = pad(d.getMonth() + 1);
        const dd = pad(d.getDate());
        const hh = pad(d.getHours());
        const mi = pad(d.getMinutes());
        const ss = pad(d.getSeconds());
        return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`;
    }
    @track showConfirmModal = false;
    // 下订单
    async handleOrderReport(){
        // todo先查询数据库，是否已经下过监控服务和普通服务，给前台提醒
        const historicalReportData = await checkHistoricalReportOrder({
            iconNumber: this.iconNumber,
            countryCode: this.country,
            reportTypeSlug: this.reportTypeSlug,
        });
        if(historicalReportData && historicalReportData.isHaveReport){
            const orderDate = this.formatZonedDateTime(historicalReportData.reportData.Order_Date__c);
            const startDate = historicalReportData.reportData.Start_Date__c;
            const endDate = historicalReportData.reportData.End_Date__c;
           // 有生效的监控报告，不能再次提交
           if(historicalReportData.isHaveMonitorable){
                const result = await CustomModal.open({
                    // LightningModal
                    size: 'small',
                    // ModalDemo
                    header: 'System Prompt',
                    body: `You have already ordered a monitoring report for this company.`,
                    reportData: [
                        { id: 1, label: 'Order Date: ', value: orderDate },
                        { id: 2, label: 'Start_Date: ', value: startDate },
                        { id: 3, label: 'End_Date: ', value: endDate },
                    ],
                    options: [
                        { id: 1, variant: 'neutral', label: 'Cancel' },
                        { id: 2, variant: 'brand', label: 'Navigate to report' },
                    ],
                    
                });
                // 打开订购的report
                if (result === 2) {
                    this.navigateRecord(historicalReportData.reportData.Id);
                }
                return;
           }else {
                // 无生效的监控报告，提示最近一次报告信息
                if(historicalReportData.reportData && historicalReportData.reportData.Id){
                    const result = await CustomModal.open({
                        // LightningModal
                        size: 'small',
                        // ModalDemo
                        header: 'System Prompt',
                        body: `You have already placed an order for a report with the latest date from this company.`,
                        reportData: [
                            { id: 1, label: 'Order Date: ', value: orderDate },
                        ],
                        options: [
                            { id: 1, variant: 'neutral', label: 'Cancel',},
                            { id: 2, variant: 'brand', label: 'Navigate to report', },
                            { id: 3, variant: 'brand', label: 'Order', className: 'my-brand', iconName: 'utility:checkout' },
                        ],
                    });
                    // 打开订购的report
                    if (result === 2) {
                        this.navigateRecord(historicalReportData.reportData.Id);
                        return;
                    }else if(result === 3){
                        // 继续订购
                        this.saveReportOrder();
                    }
                }
                return;
           }
        }else {
            // 没有订单，弹出对话框
            const result = await LightningConfirm.open({
                message: 'Are you sure you want to order this product?',
                variant: 'headerless',
                label: '',
                theme: 'success'
            });
            if (result) {
                this.saveReportOrder();
            }
        }
    }

    async saveReportOrder(){
        this.isShowOrderSpinner = true;
        // 整理订购参数
        let reportParam = {};
        reportParam.selectItemOriginal = this.selectItemOriginal;
        reportParam.reportType = this.reportType;
        reportParam.reportTypeSlug = this.reportTypeSlug;
        reportParam.isMonitorable = this.isMonitorable;
        reportParam.availabilityValue = this.availabilityValue;
        reportParam.currencyValue = this.currencyValue;
        reportParam.languageValue = this.languageValue;
        reportParam.languageLabel = this.languageLabel;
        reportParam.countrySpecial = this.countrySpecial;
        reportParam.countryName = this.countryName;
        reportParam.country = this.country;
        reportParam.iconNumber = this.iconNumber;
        
        saveReportOrder({
            idToken: this.idToken,
            reportParam: JSON.stringify(reportParam),
        }).then(data => {
            if(data && data.isSuccess){
                this.showSuccess('订购成功！');
                // 关闭弹出框
                this.isReportDialopOpen = false;
                this.isDialogOpen = false;
            }else {
                this.showError(data.message);
            }
            this.isShowOrderSpinner = false;
        }).catch(error => {
            this.showError(error.body.message);
            this.isShowOrderSpinner = false;
        });
    }

    // 跳转到新页面
    async  navigateRecord(rId){
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rId,
                actionName: 'view'
            }
        });
        window.open(url, '_blank');
    }
}