
#define DEFAULT_RUN_COUNT 200000000

#include "../include/common.h"


static
int add( int a, int b ) { return (a + b); }


@interface Indirect : NSObject
	- (int)add:(int)a to:(int)b;
@end


@interface Direct : NSObject
	- (int)add:(int)a to:(int)b __attribute__((objc_direct));
@end


@implementation Direct
	- (int)add:(int)a to:(int)b { return (a + b);  }
@end


@implementation Indirect
	- (int)add:(int)a to:(int)b { return (a + b);  }
@end



static
int benchmark( size_t runCount )
{
	srandomdev();
	let a = (int)random();
	let b = (int)random();
	let c = a + b;

	bench_start(1);
	bench_loop {
		if (add(add(a, b), run) != c + (int)run ) exit(1);
	}
	bench_stop(1, "C Function Call");


	let o1 = [Indirect new];
	bench_start(2);
	bench_loop {
		if ([o1 add:[o1 add:a to: b] to:run] != c + (int)run) exit(1);
	}
	bench_stop(2, "Obj-C Standard Call");


	let o2 = [Direct new];
	bench_start(3);
	bench_loop {
		if ([o2 add:[o2 add:a to: b] to:run] != c + (int)run) exit(1);
	}
	bench_stop(3, "Obj-C Direct Call");

	return 0;
}
