#include "MultihopSensingRoot.h"
module MultihopSensingRootC{
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		interface SplitControl as RadioControl;
		interface StdControl as DisseminationControl;
		interface StdControl as CollectionControl;
		interface DisseminationUpdate<myconfigformat_t> as RadioSend;
		interface Receive as RadioReceive;
		interface SplitControl as SerialControl;
		interface AMSend as SerialSend;
		interface Receive as SerialReceive;
		interface RootControl;
	}
}
implementation{	
	message_t mymessage;
	bool busy;
	myconfigformat_t myconfig;
//LED Displays
	void report_problem() {
		call Leds.led2Toggle();
	}
	void report_transmission() {
		call Leds.led0Toggle();
	}
	void report_reception() {
		call Leds.led1Toggle();
	}


//Boot event
	event void Boot.booted(){
		call SerialControl.start();
		call RadioControl.start();
	}

//Start Serial Control
	event void SerialControl.startDone(error_t error){
	//	if (error != SUCCESS)
	//		report_problem();
		}

//Start Radio Control
	event void RadioControl.startDone(error_t error){
		if (error != SUCCESS){
			report_problem();
		}
		else{
			call DisseminationControl.start();
			call CollectionControl.start();
			call RootControl.setRoot(); 
			call Timer.startPeriodic(CONFIG_UPDATE_PERIOD);
			myconfig.samplingperiod = SAMPLING_PERIOD_2;
			busy = FALSE;
		}
	}
	
//Stop Serial Control
	event void SerialControl.stopDone(error_t error) {
		}

//Stop Radio Control
	event void RadioControl.stopDone(error_t error){
		}
		
//Timer fired
	event void Timer.fired() {
		if (myconfig.samplingperiod == SAMPLING_PERIOD_1) {
			myconfig.samplingperiod = SAMPLING_PERIOD_2;
			}else{
				myconfig.samplingperiod = SAMPLING_PERIOD_1;
				}
				report_transmission();
			 call RadioSend.change(&myconfig);
			}

//RadioReceive event
	event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
		if (!busy) {
			if (len != sizeof(mydataformat_t) || call SerialSend.maxPayloadLength() < sizeof (mydataformat_t *)) {
				report_problem();
			}else{
				memcpy(call SerialSend.getPayload(&mymessage, sizeof(mydataformat_t)),(mydataformat_t *) payload, sizeof(mydataformat_t));
					if (call SerialSend.send(AM_BROADCAST_ADDR, &mymessage, sizeof(mydataformat_t)) == SUCCESS) {
				busy = TRUE;
				}
			}
		}
		report_reception();
		return msg;
	}
//Serial Send Done
	event void SerialSend.sendDone(message_t * msg, error_t error) {
			if ((error != SUCCESS) || msg != &mymessage) {
			report_problem();
			}else {
		busy = FALSE;
	}
}
//Serial Receive
	event message_t* SerialReceive.receive(message_t* msg, void* payload, uint8_t len) {	
		return msg;
	}
	
}
