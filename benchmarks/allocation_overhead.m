
#define DEFAULT_RUN_COUNT 5000000

#include "../include/common.h"

static
void xorRaw (
	size_t ptrSize,
	const void * restrict ptr1,
	const void * restrict ptr2,
	void * ptrOut )
{
	uint8_t * pout = ptrOut;
	const uint8_t * p1 = ptr1;
	const uint8_t * p2 = ptr2;
	for (size_t i = 0; i < ptrSize; i++) *(pout++) = *(p1++) ^ *(p2++);
}


static
NSData * xorData (
	NSData * data1,
	NSData * data2 )
{
	NSMutableData * out = [NSMutableData dataWithCapacity:data1.length];
	const uint8_t * p1 = data1.bytes;
	const uint8_t * p2 = data2.bytes;
	uint8_t * pout = out.mutableBytes;
	for (size_t i = 0; i < data1.length; i++) *(pout++) = *(p1++) ^ *(p2++);
	return out;
}



static
int benchmark( size_t runCount )
{
	uint8_t dest[16] = { 0 };
	uint8_t source1[16] = "E2nqx5RQwmk5bOy1";
	uint8_t source2[16] = "rVCsvlLd5qBFszNw";


	bench_start(1);
	bench_loop {
		xorRaw(16, source1, source2, dest);
	}
	bench_stop(1, "Static");


	bench_start(2);
	bench_loop {
		NSData * src1 = [NSData dataWithBytes:source1 length:sizeof(source1)];
		NSData * src2 = [NSData dataWithBytes:source2 length:sizeof(source2)];
		NSData * res = xorData(src1, src2);
	}
	bench_stop(2, "NSData");


	bench_start(3);
	{
		NSData * src1 = [NSData dataWithBytes:source1 length:sizeof(source1)];
		NSData * src2 = [NSData dataWithBytes:source2 length:sizeof(source2)];
		bench_loop {
			NSData * res = xorData(src1, src2);
		}
	}
	bench_stop(3, "Static NSData");


	bench_start(4);
	{
		NSData * src1 = [NSData dataWithBytes:source1 length:sizeof(source1)];
		NSData * src2 = [NSData dataWithBytes:source2 length:sizeof(source2)];
		NSMutableData * res = [NSMutableData dataWithLength:16];
		bench_loop {
			xorRaw(16, src1.bytes, src2.bytes, res.mutableBytes);
		}
	}
	bench_stop(4, "NSData Storage");


	bench_start(5);
	{
		bench_loop {
			void * res = malloc(sizeof(dest));
			xorRaw(16, source1, source2, dest);
			free(res);
		}
	}
	bench_stop(5, "Malloc Storage");

	return 0;
}