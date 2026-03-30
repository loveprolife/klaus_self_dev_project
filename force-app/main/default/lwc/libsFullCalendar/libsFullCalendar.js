import { LightningElement ,wire,track} from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone'
import FULL_CALENDAR from '@salesforce/resourceUrl/fullCalendar';
import JQUERY from '@salesforce/resourceUrl/AnyEventCal';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getRoomList from '@salesforce/apex/RoomBookController.getRoom';
import getBookingList from '@salesforce/apex/RoomBookController.getBooking';
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ROOM_BOOKING from "@salesforce/schema/Expo_Meeting_Room__c";
import NAME from "@salesforce/schema/Expo_Meeting_Room__c.Name";
import SUNJECT from "@salesforce/schema/Expo_Meeting_Room__c.note__c";
import START_TIME from "@salesforce/schema/Expo_Meeting_Room__c.StartTime__c";
import END_TIME from "@salesforce/schema/Expo_Meeting_Room__c.EndTime__c";
import ROOM from "@salesforce/schema/Expo_Meeting_Room__c.Expo_Meeting_Booking_Info__c";
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from "lightning/refresh";




/**
 * When using this component in an LWR site, please import the below custom implementation of 'loadScript' module
 * instead of the one from 'lightning/platformResourceLoader'
 *
 * import { loadScript } from 'c/resourceLoader';
 *
 * This workaround is implemented to get around a limitation of the Lightning Locker library in LWR sites.
 * Read more about it in the "Lightning Locker Limitations" section of the documentation
 * https://developer.salesforce.com/docs/atlas.en-us.exp_cloud_lwr.meta/exp_cloud_lwr/template_limitations.htm
 */

export default class LibsFullCalendar extends NavigationMixin(LightningElement) {
    @track
   show = false;
   @track
   MeetingRooms;
   @track
   Bookings;
   BookId;
   BookName;
   BookSubject;
   BookStart;
   BookStartBJ;
   BookEnd;
   BookEndBJ;
   BookRoom;
   @track
   TIME_ZONE;
   isCalInitialized = false;  
   error;
   
   //刷新页面
   beginRefresh() {
    this.dispatchEvent(new RefreshEvent());
  }
   //处理预定提报表单OnChange事件
   handleNameChange(event) {
    this.BookId = undefined;
    this.BookName = event.target.value;
  }
  handleSubjectChange(event) {
    this.BookId = undefined;
    this.BookSubject = event.target.value;
  }
  handleStartChange(event) {
    this.BookId = undefined;
    this.BookStart = event.target.value;
    this.BookStartBJ=moment(this.BookStart).tz('Asia/Macau').format('lll');
  }
  handleEndChange(event) {
    this.BookId = undefined;
    this.BookEnd = event.target.value;
    this.BookEndBJ=moment(this.BookEnd).tz('Asia/Macau').format('lll');
  }
  handleRoomChange(event) {
    this.BookId = undefined;
    this.BookRoom = event.target.value;
  }
   showModal() {
    this.show=true
    
   };

   cancel() {
    this.show = false
   }
   //删除
   navigateNext() {
    // Navigate to the Account home page
    this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'RoomBooking__c',
            actionName: 'list',
        },
        state: {
          filterName: 'Recent'
      }
    });
}
   //创建会议预定
   createAccount() {
    const fields = {};
    fields[NAME.fieldApiName] = this.BookName;
    fields[SUNJECT.fieldApiName] = this.BookSubject;
    fields[START_TIME.fieldApiName] = this.BookStart;
    fields[END_TIME.fieldApiName] = this.BookEnd;
    fields[ROOM.fieldApiName] = this.BookRoom;
    const recordInput = { apiName: ROOM_BOOKING.objectApiName, fields };
    createRecord(recordInput)
      .then((RoomBooking__c) => {
        this.BookId = RoomBooking__c.id;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Record created",
            variant: "success",
          }),
        );
        
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Please check whether your booking is greater than 90min or time conflict ",
            message: error.body.message,
            variant: "error",
            
          }),
        );
        console.info("error"+error)
      });
      this.show = false
  }
   

  
    @wire(getRoomList) wiredMeetingRoom({error,data}){
        if(data){
            this.MeetingRooms=data;
            this.error=undefined;
        }else if (error){
            this.error=error;
            this.MeetingRooms=undefined;
        }
    };
    @wire(getBookingList) wiredBooking({error,data}){
        if(data){
            this.Bookings=data;
            this.error=undefined;
        }else if (error){
            this.error=error;
            this.Bookings=undefined;
        }
    }
    //监听Event点击事件
    connectedCallback() {
      this.addEventListener('fceventclick', this.handleEventClick.bind(this));
      //this.addEventListener('mousewheel', this.handleScroll.bind(this));  
    }
    //渲染日历
    async renderedCallback() {
        if (this.isCalInitialized) {
            return;
        }
        this.isCalInitialized = true;
        

        try {
            await Promise.all([
                loadScript(this, JQUERY + '/jquery.min.js'),
                loadScript(this, FULL_CALENDAR + '/moment.min.js'),
                loadScript(this, FULL_CALENDAR + '/moment-timezone-with-data.min.js'),
                loadScript(this, FULL_CALENDAR + '/lib/main.js'),
                loadStyle(this, FULL_CALENDAR + '/lib/main.min.css')
            ]);
            
            this.initializeCalendar();
        } catch (error) {
            this.error = error;
        }
    }

    initializeCalendar() {
  
        var resourceMap=this.MeetingRooms;
        var eventMap=this.Bookings;
        var resourceArray =[];
        var eventArray=[];
        $.each(resourceMap,function(index,value){
            var newResource={
               index:index,
               id:value.Id,
                title:value.Name,
            }
            resourceArray.push(newResource);

        })
        console.info("resourceArray:"+resourceArray);
        $.each(eventMap,function(index,value){
            var newEvent={
               index:index,
               id:value.Id,
               title:value.Name,
               start:moment(value.StartTime__c).tz('Atlantic/Reykjavik').format(),
               end:moment(value.EndTime__c).tz('Atlantic/Reykjavik').format(),
               resourceId:value.Expo_Meeting_Booking_Info__c,
               color:value.Color__c,
               

            }
            console.info("newEvent:"+newEvent.color);
            console.info("value:"+value.logical_delete__c);

            eventArray.push(newEvent);
            console.info("Start:"+newEvent.start+value.StartTime__c)

        })
        console.info("eventArray:"+eventArray);
        console.info("timezone:"+TIME_ZONE);
        const calendarEl = this.template.querySelector('.calendar');
        // eslint-disable-next-line no-undef
        if (typeof FullCalendar === 'undefined') {
            throw new Error(
                'Could not load FullCalendar. Make sure that Lightning Web Security is enabled for your org. See link below.'
            );
        }
        // eslint-disable-next-line no-undef
        const calendar = new FullCalendar.Calendar(calendarEl, {
            
            initialView: 'resourceTimeGridDay',
            schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
            allDaySlot: false,
            slotMinTime: "09:00:00",
            slotMaxTime: "21:00:00",
            height: "auto",
            timeZone: 'Asia/Macau',
            resources: resourceArray,
            events:eventArray,
            eventClick: (info) =>{
                
              const selectedEvent = new CustomEvent('fceventclick', { detail: info });
              console.log("eventClick",info);
              this.dispatchEvent(selectedEvent);
            
      }

        }
        );
        calendar.render();
    }
    handleEventClick(event) {
      let info = event.detail;
      console.log('Event: ' + info.event.title);
      console.log('Coordinates: ' + info.jsEvent.pageX + ',' + info.jsEvent.pageY);
      console.log('View: ' + info.view.type);
      console.log(info);
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: info.event.id,
            actionName: 'view',
        },
      });
      // change the border color just for fun
      //info.el.style.borderColor = 'red';
  
    }

}