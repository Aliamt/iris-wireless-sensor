#include "Timer.h" 
#include "SensingLuminosity.h" 


module SensingLuminosityC{ 
	uses{ 
		interface Boot; 
		interface Leds; 
		interface Timer<TMilli>; 
		interface Read<uint16_t> as ReadLuminosity; 
		interface SplitControl as RadioControl; 
		interface AMSend; 
		interface Receive; 
	} 
} 
implementation{ 
	message_t mymessage; 
	bool busy; 
	mydataformat_t mydata; 
	uint8_t currentsamplenum; 
	bool dontcount; 
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
		if (sizeof(mydata) > call AMSend.maxPayloadLength()) { 
			report_problem(); 
		} 
		else { 
			memcpy(call AMSend.getPayload(&mymessage, sizeof(mydata)), 
					&mydata, sizeof(mydata)); 
			if (call AMSend.send(AM_LUMINOSITY, &mymessage, sizeof(mydata)) == SUCCESS) { 
				busy = TRUE; 
			} 
		} 
	} 
	event void Boot.booted(){ 
		mydata.samplingperiod = DEFAULT_PERIOD; 
		mydata.nodeid = TOS_NODE_ID; 
		if (call RadioControl.start() != SUCCESS){ 
			report_problem(); 
		} 
	} 
	event void RadioControl.startDone(error_t error){ 
		if (error != SUCCESS){ 
			report_problem(); 
		} 
		else { 
			call Timer.startPeriodic(mydata.samplingperiod); 
			currentsamplenum = 0; 
		} 
	} 
	event void RadioControl.stopDone(error_t error){}
	
	event void Timer.fired() {
		if (currentsamplenum < NUMSAMPLES) { 
		
		if  (call ReadLuminosity.read()!= SUCCESS){
			report_problem(); 
		}
		
			// Request a measurement of the luminosity, and if the request is not granted, 
			// report the problem using the function report_problem(). 
		 }
		else { 
			if (!busy) { 
				post sendpacket(); 
			} 
			currentsamplenum = 0; 
			if (!dontcount) { 
				mydata.count++; 
			} 
			dontcount = FALSE; 
			
		} 
	} 
	event void ReadLuminosity.readDone(error_t error, uint16_t sample) { 
		// Check whether the measurement was done successfully. If it was not, make the sample 
		// equal to the highest possible number it can take on and report the problem using the 
		// function report_problem(). If it was, store the measurement in the corresponding 
		
		// location. 
		if (error == SUCCESS) { 
			mydata.samples[currentsamplenum]=sample;
		} 
		else {
			
			mydata.samples[currentsamplenum]= 0xFFFF;
			report_problem(); 
			}
		currentsamplenum++; 
	} 
	event void AMSend.sendDone(message_t * txmessage, error_t error) { 
		if (error != SUCCESS) { 
			report_problem(); 
		} 
		else { 
			report_transmission(); 
		} 
		busy = FALSE; 
	} 
	event message_t * Receive.receive(message_t * rxmessage, void * payload, uint8_t payloadsize) { 
		mydataformat_t * rxpayload = payload; 
		if (rxpayload->nodeid == NODE_ID1 || rxpayload->nodeid == NODE_ID2) { 
			report_reception(); 
			if (rxpayload->version > mydata.version) { 
				mydata.version = rxpayload->version; 
				mydata.samplingperiod = rxpayload->samplingperiod; 
				call Timer.startPeriodic(mydata.samplingperiod); 
			} 
			if (rxpayload->count > mydata.count) { 
				mydata.count = rxpayload->count; 
				dontcount = TRUE; 
			} 
		} 
		return rxmessage; 
	} 
} 
	
	