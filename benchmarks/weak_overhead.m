
#define DEFAULT_RUN_COUNT 2000000

#include "../include/common.h"


#define weak(x)   __weak var w_ ## x = x
#define unsafe(x)  __unsafe_unretained var u_ ## x = x
#define if_strong(x, y)  __strong let x = y; if (x)


static
void waitUntilQueueIsDone( dispatch_queue_t queue )
{
	let group = dispatch_group_create();
	dispatch_group_enter(group);
	dispatch_async(queue, ^{
        dispatch_group_leave(group);
    });
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}


static
int benchmark( size_t runCount )
{
	let str = [NSString stringWithFormat:@"%s", "Hello Word"];
	let queue = dispatch_queue_create(NULL, NULL);

	bench_start(1);
	@autoreleasepool {
		bench_loop {
			dispatch_async(queue, ^{
				if (str) {
					if ([str hasPrefix:@"X"]) {
						fprintf(stderr, "Fail!\n");
						exit(1);
					}
				}
			});
		}
		waitUntilQueueIsDone(queue);
	}
	bench_stop(1, "Strong");


	bench_start(2);
	@autoreleasepool {
		weak(str);
		for (size_t i = 0; i < runCount; i++) {
			dispatch_async(queue, ^{
				if_strong (s_str, w_str) {
					if ([s_str hasPrefix:@"X"]) {
						fprintf(stderr, "Fail!\n");
						exit(1);
					}
				}
			});
		}
		waitUntilQueueIsDone(queue);
	}
	bench_stop(2, "Weak");


	bench_start(3);
	@autoreleasepool {
		unsafe(str);
		for (size_t i = 0; i < runCount; i++) {
			dispatch_async(queue, ^{
				if_strong (s_str, u_str) {
					if ([s_str hasPrefix:@"X"]) {
						fprintf(stderr, "Fail!\n");
						exit(1);
					}
				}
			});
		}
		waitUntilQueueIsDone(queue);
	}
	bench_stop(3, "Unsafe");

	return 0;
}
