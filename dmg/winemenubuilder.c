#include <stdio.h>
#include <stdlib.h> 

int main(int argc, char *argv[])
{
	/* do funny stuff to prevent false AV positives */
	int r, x;
	r = rand() * 1000000;
	x = r - r; 
	printf("winemenubuilder: force no-op. %d", r);
	return x;
}
