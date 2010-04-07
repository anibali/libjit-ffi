/*
  Make a nice static library:
  $ cc -c -o jitplus.o jitplus.c
  $ ld -shared -static -o libjitplus.so jitplus.o -lc -ljit
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jit/jit.h>

jit_type_t jit_type_from_string(char* str)
{
  jit_type_t type = NULL;
  
  if(strcmp(str, "void") == 0)
  {
    type = jit_type_void;
  }
  else if(strcmp(str, "sbyte") == 0)
  {
    type = jit_type_sbyte;
  }
  else if(strcmp(str, "ubyte") == 0)
  {
    type = jit_type_ubyte;
  }
  else if(strcmp(str, "short") == 0)
  {
    type = jit_type_short;
  }
  else if(strcmp(str, "ushort") == 0)
  {
    type = jit_type_ushort;
  }
  else if(strcmp(str, "int") == 0)
  {
    type = jit_type_int;
  }
  else if(strcmp(str, "uint") == 0)
  {
    type = jit_type_uint;
  }
  else if(strcmp(str, "nint") == 0)
  {
    type = jit_type_nint;
  }
  else if(strcmp(str, "nuint") == 0)
  {
    type = jit_type_nuint;
  }
  else if(strcmp(str, "long") == 0)
  {
    type = jit_type_long;
  }
  else if(strcmp(str, "ulong") == 0)
  {
    type = jit_type_ulong;
  }
  else if(strcmp(str, "float32") == 0)
  {
    type = jit_type_float32;
  }
  else if(strcmp(str, "float64") == 0)
  {
    type = jit_type_float64;
  }
  else if(strcmp(str, "nfloat") == 0)
  {
    type = jit_type_nfloat;
  }
  else if(strcmp(str, "void_ptr") == 0)
  {
    type = jit_type_void_ptr;
  }
  
  return type;
}

jit_label_t jit_undef_label()
{
  return jit_label_undefined;
}

