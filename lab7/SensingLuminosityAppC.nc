#include "SensingLuminosity.h"
configuration SensingLuminosityAppC{
}
implementation{
	
	components 
		SensingLuminosityC, 
		MainC, 
		ActiveMessageC, 
		LedsC, 
		new TimerMilliC() as Timer, 
		new DemoSensorC() as PhotoSensor, 
		new AMSenderC(AM_LUMINOSITY), 
		new AMReceiverC(AM_LUMINOSITY); 
	
	
		SensingLuminosityC.Boot -> MainC; 
		SensingLuminosityC.RadioControl -> ActiveMessageC; 
		SensingLuminosityC.AMSend -> AMSenderC; 
		SensingLuminosityC.Receive -> AMReceiverC; 
		SensingLuminosityC.Timer -> Timer; 
		SensingLuminosityC.ReadLuminosity -> PhotoSensor; 
		SensingLuminosityC.Leds -> LedsC;
	
}