// c.go stand for cgo ;-)
package c

/*
#include <stdio.h>
#include <stdlib.h>

void printstring(const char *str)
{
	printf(str);
}
*/
import "C"
import "unsafe"

func C() {
	hi := C.CString("Hi from C\n")
	C.printstring(hi)
	C.free(unsafe.Pointer(hi))
}
