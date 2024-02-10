#ifndef DEFAULT_RUN_COUNT
	#define DEFAULT_RUN_COUNT 1
#endif


#ifdef __OBJC__
	@import Foundation;
#endif


#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/time.h>


#define var  __auto_type
#define let  const var


#define bench_loop  for (size_t run = 0; run < runCount; run++)

#define bench_start( no ) let startTime ## no = getTime()

#define bench_stop( no, name ) \
	printf("%s took %0.3f\n", name, getTime() - startTime ## no)


static int benchmark( size_t runCount );


static
double getTime( )
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec +  (tv.tv_usec / 1000000.0));
}


int main( int argc, char * argv[ ] )
{
	int result = 0;

	size_t runCount = 0;
	if (argc < 2) {
		runCount = DEFAULT_RUN_COUNT;
	} else {
		sscanf(argv[1], "%zu", &runCount);
	}

#ifdef __OBJC__
	@autoreleasepool {
		result = benchmark(runCount);
	}
#else
	result = benchmark(runCount);
#endif

	return result;
}
