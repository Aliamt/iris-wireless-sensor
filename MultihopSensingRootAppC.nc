#include "MultihopSensingRoot.h"
configuration MultihopSensingRootAppC{
}
implementation{
	components
		MainC,
		MultihopSensingRootC,
		SerialActiveMessageC,
		new SerialAMReceiverC(CONFIG_TYPE) as SerialReceiver,
		new SerialAMSenderC(DATA_TYPE) as SerialSender,
		ActiveMessageC,
		DisseminationC,
		new DisseminatorC(myconfigformat_t, CONFIG_TYPE) as RadioSender,
		CollectionC as RadioReceiver,
		LedsC,
		new TimerMilliC() as Timer;
	MultihopSensingRootC.Boot -> MainC;
	MultihopSensingRootC.SerialControl -> SerialActiveMessageC;
	MultihopSensingRootC.SerialSend -> SerialSender;
	MultihopSensingRootC.SerialReceive -> SerialReceiver;
	MultihopSensingRootC.RadioControl -> ActiveMessageC;
	MultihopSensingRootC.CollectionControl -> RadioReceiver;
	MultihopSensingRootC.DisseminationControl -> DisseminationC;
	MultihopSensingRootC.RootControl -> RadioReceiver;
	MultihopSensingRootC.RadioSend -> RadioSender;
	MultihopSensingRootC.RadioReceive -> RadioReceiver.Receive[DATA_TYPE];
	MultihopSensingRootC.Timer -> Timer;
	MultihopSensingRootC.Leds -> LedsC;	
}
