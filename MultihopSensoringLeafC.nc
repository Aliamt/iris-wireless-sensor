#include "Timer.h" 
#include "MultihopSensoringLeaf.h"
module MultihopSensoringLeafC{
	uses{
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		interface Read<uint16_t> as ReadLuminosity;
		interface SplitControl as RadioControl;
		interface StdControl as CollectionControl;
		interface StdControl as DisseminationControl;
		interface Send as RadioSend;
		interface DisseminationValue<myconfigformat_t> as RadioReceive;
	}
}

implementation{
	message_t mymessage;
	bool busy;
	mydataformat_t mydata;
	uint8_t currentsamplenum;
	myconfigformat_t myconfig;
		
	void report_problem() {
		call Leds.led2Toggle();
	}
	
	void report_transmission() {
		call Leds.led0Toggle();
	}
	
	void report_reception() {
		call Leds.led1Toggle();
	}	
	task void sendpacket() {
		if (sizeof(mydata) > call RadioSend.maxPayloadLength()) {
			report_problem();
		}
		else {
			memcpy(call RadioSend.getPayload(&mymessage, sizeof(mydata)),&mydata, sizeof(mydata));
					
			if (call RadioSend.send(&mymessage, sizeof(mydata)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
	
	
	event void Boot.booted(){
		myconfig.samplingperiod = DEFAULT_PERIOD;
		mydata.nodeid = TOS_NODE_ID;
		//mydata.tamara = DEFAULT_PERIOD*10;
	//	myconfig.samplingperiod=tamara;
		if (call RadioControl.start() != SUCCESS){
			report_problem();
		}
	}
	
	
	event void RadioControl.startDone(error_t error){
		if (error != SUCCESS){
			report_problem();
		}
		else {
			if (call CollectionControl.start() != SUCCESS) {
			report_problem();	
		}
			if (call DisseminationControl.start() != SUCCESS) {
			report_problem();	
		}
		currentsamplenum = 0;
		mydata.nodeid = TOS_NODE_ID;
		call Timer.startPeriodic(myconfig.samplingperiod);
	}
}
	
	
	event void RadioControl.stopDone(error_t error){}
	
	
	
	event void Timer.fired() {
		if (currentsamplenum < NUMSAMPLES) {
			if (call ReadLuminosity.read() != SUCCESS);{
				report_problem();
			}

		}
	
		else {
			if (!busy) {
				post sendpacket();
			}
			currentsamplenum = 0;
		}
	}
	
	
	
	event void ReadLuminosity.readDone(error_t error, uint16_t sample) {
		if (error != SUCCESS){
			sample = 0xffff;
			report_problem();
		}
		mydata.samples[currentsamplenum] = sample,
		currentsamplenum++;
	}
	
	
	
		event void RadioSend.sendDone(message_t * txmessage, error_t error) {
			if (error != SUCCESS) {
			report_problem();
			}
		else {
			report_transmission();
			}
		busy = FALSE;
	}
	
	

		event void RadioReceive.changed() {
			myconfigformat_t * newconfigptr = call RadioReceive.get();
			report_reception();
			
			mydata.samplingperiod = newconfigptr->samplingperiod;
			
			
		    call Timer.startPeriodic(mydata.samplingperiod);
			}		
}
