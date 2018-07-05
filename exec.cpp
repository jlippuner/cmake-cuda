#include "example.cpp"
#include "example.cuh"

int main(int, char**) {
  HelloWorld_Host host;
  host.Print();

  HelloWorld_Device();

  return 0;
}
