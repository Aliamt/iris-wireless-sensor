#ifndef MULTIHOP_SENSORING_LEAF_H
#define MULTIHOP_SENSORING_LEAF_H
enum {
		NUMSAMPLES = 5,
		DEFAULT_PERIOD = 64,
		DATA_TYPE = 0x93,
		CONFIG_TYPE = 0x94
};

typedef nx_struct mydataformat {
		nx_uint16_t nodeid;
		nx_uint16_t samples[NUMSAMPLES];
		nx_uint16_t samplingperiod;
} mydataformat_t;

typedef nx_struct myconfigformat {
		nx_uint16_t samplingperiod;
		nx_uint16_t tamara;
} myconfigformat_t;

#endif /* MULTIHOP_SENSORING_LEAF_H */