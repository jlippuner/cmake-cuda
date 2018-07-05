#include "example.cuh"

#include <cstdio>
#include <stdexcept>

#include <cuda_runtime.h>

#define CUCHK(cmd) {                                                            \
  auto errorCode = (cmd);                                                       \
  if (errorCode != cudaSuccess) {                                               \
    char buf[1024];                                                             \
    sprintf(buf, "CUDA ERROR %i at %s:%i: %s", errorCode, __FILE__, __LINE__,   \
        cudaGetErrorString(errorCode));                                         \
    throw std::runtime_error(buf);                                              \
  }                                                                             \
}

__global__ void kernel(int *num_threads) {
  if ((threadIdx.x == 0) && (blockIdx.x == 0)) {
    *num_threads = blockDim.x * gridDim.x;
  }
}

void HelloWorld_Device() {
  int *d_num_threads, *h_num_threads;

  // allocate memory
  h_num_threads = (int*)malloc(sizeof(int));
  CUCHK(cudaMalloc(&d_num_threads, sizeof(int)));

  // run kernel
  kernel<<<256, 8>>>(d_num_threads);
  CUCHK(cudaDeviceSynchronize());

  // copy result back to host
  CUCHK(cudaMemcpy(h_num_threads, d_num_threads, sizeof(int), cudaMemcpyDeviceToHost));

  printf("Hello world from GPU with %i threads\n", *h_num_threads);

  // free memory
  free(h_num_threads);
  CUCHK(cudaFree(d_num_threads));
}
