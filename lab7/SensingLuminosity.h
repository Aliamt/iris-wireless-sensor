#ifndef SENSING_LUMINOSITY_H
#define SENSING_LUMINOSITY_H

enum { 
	NUMSAMPLES = 5, 
	DEFAULT_PERIOD = 64, 
	AM_LUMINOSITY = 0x93, 
	NODE_ID1 = 1, 
	NODE_ID2 = 2, 
	BASESTATION_ID = 0 
}; 
typedef nx_struct mydataformat { 
	nx_uint16_t version; 
	nx_uint16_t samplingperiod; 
	nx_uint16_t nodeid; 
	nx_uint16_t count; 
	nx_uint16_t samples[NUMSAMPLES]; 
} mydataformat_t; 

#endif /* SENSING_LUMINOSITY_H */
