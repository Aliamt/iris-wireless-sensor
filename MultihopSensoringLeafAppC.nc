#include "MultihopSensoringLeaf.h"
configuration MultihopSensoringLeafAppC{
}
implementation{
	components
			MultihopSensoringLeafC,
			MainC,
			LedsC,
			new TimerMilliC() as Timer,
			new DemoSensorC() as PhotoSensor,
			ActiveMessageC,
			CollectionC,
			DisseminationC,
			new CollectionSenderC(DATA_TYPE) as CollectionSender,
			new DisseminatorC(myconfigformat_t, CONFIG_TYPE) as DisseminationReceiver;
	
			MultihopSensoringLeafC.Boot -> MainC;
			MultihopSensoringLeafC.RadioControl -> ActiveMessageC;
			MultihopSensoringLeafC.CollectionControl -> CollectionC;
			MultihopSensoringLeafC.DisseminationControl -> DisseminationC;
			MultihopSensoringLeafC.RadioSend -> CollectionSender;
			MultihopSensoringLeafC.RadioReceive -> DisseminationReceiver;
			MultihopSensoringLeafC.Timer -> Timer;
			MultihopSensoringLeafC.ReadLuminosity -> PhotoSensor;
			MultihopSensoringLeafC.Leds -> LedsC;
}