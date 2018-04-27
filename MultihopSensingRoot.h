#ifndef MULTIHOP_SENSING_ROOT_H
#define MULTIHOP_SENSING_ROOT_H
enum {
		NUMSAMPLES = 5,
		DATA_TYPE = 0x93,
		CONFIG_TYPE = 0x94,
		CONFIG_UPDATE_PERIOD = 5000,
		SAMPLING_PERIOD_1 = 64,
		SAMPLING_PERIOD_2 = 128
};
typedef nx_struct mydataformat {
	
		nx_uint16_t nodeid;
		nx_uint16_t samples[NUMSAMPLES];
		
} mydataformat_t;

typedef nx_struct myconfigformat {
	
		nx_uint16_t samplingperiod;
		
} myconfigformat_t;

#endif /* MULTIHOP_SENSING_ROOT_H */