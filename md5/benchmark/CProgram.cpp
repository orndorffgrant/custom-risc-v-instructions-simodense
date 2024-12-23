/* Copyright 2021 Philippos Papaphilippou

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <limits.h>
#include <sys/signal.h>

#include <stdlib.h>

#include "syscalls.c"


void md5_simd(uint32_t* dest, uint32_t* src);
void md5_c(uint32_t* dest, uint32_t* src);
void sort_chunks(uint32_t* dest, uint32_t* src, size_t len);
int comp (const void * elem1, const void * elem2);
void mergeSort(uint32_t* src,int l,int r);
int mergeSort_worker(uint32_t* src,int l,int r);
void memcpy_simd(uint32_t* dest, uint32_t* src, size_t len);

uint32_t* tmpv=((volatile uint32_t*)(0x04600000));

void main(int argc, char** argv) {
	uint32_t outp=0x0400fff0;
	
	int a=rand();
	printf("Hello!\n\n");

    char* message = "Hello ENPM808! This is my MD5 implementation in verilog";
	printf("Calculating the MD5 hash of \"%s\"\n", message);
    uint32_t srcA[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; 
    uint32_t srcB[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

	int uint32_i = 0;
	int message_i = 0;
	for (message_i = 0; message_i < (55 + 1 + 2); message_i++) {
		uint32_t tmp = 0;
		if (message_i == 55) {
			tmp = 0x80;
		} else if (message_i == 56) {
			tmp = 0xb8;
		} else if (message_i == 57) {
			tmp = 0x01;
		} else {
			tmp = message[message_i];
		}
		uint32_t curr = srcA[uint32_i];
		int mod = message_i % 4;
		curr = curr | (tmp << (mod*8));
		srcA[uint32_i] = curr;
		srcB[uint32_i] = curr;
		if (mod == 3) {
			uint32_i++;
		}
	}
    
	printf("Pre-padded message block:\n");
	for (int i = 0; i < 16; i++) {
		printf("%08x ", srcA[i]);
	}
	printf("\n");
	uint32_t destA[8] = {0, 0, 0, 0, 0, 0, 0, 0};
	uint32_t destB[4] = {0, 0, 0, 0};

    // Uncomment for the real FPGA instead, where 1GB is available
    // uint32_t* srcA = 0x50000000;
    // uint32_t* srcB = 0x60000000;

	// Temporary memory location to keep a series of -1s
	for (int i=0;i<32;i++){ //8 for 256-bit vector
		tmpv[i]=-1;
	}

	// Read cycles and instruction count	  		
	uint64_t time3 = time(); 
	uint64_t icount3 = insn();

	// Normal MD5
	md5_c(destB, srcB);

	// Read cycles and instruction count	
	uint64_t time4 = time() - time3;
	uint64_t icount4 = insn() - icount3;  
	
	// Print result
	printf(
		"\nMD5 normal C result:  %08x %08x %08x %08x\n",
		destB[0],
		destB[1],
		destB[2],
		destB[3]
	);
	// Print stats
	printf(
		"MD5 normal C took  %4llu cycles and %4llu instructions. CPI: %llu.%02llu\n",
		time4,
		icount4,
		time4 / icount4,
		((time4 % icount4) * 100) / icount4
	);

	// Read cycles and instruction count	  		
	uint64_t time1 = time(); 
	uint64_t icount1 = insn();
	
	// Custom MD5
	md5_simd(destA, srcA);

	// Read cycles and instruction count	
	uint64_t time2 = time() - time1;
	uint64_t icount2 = insn() - icount1;  
				
	// Print result
	printf(
		"\nMD5 with SIMD result: %08x %08x %08x %08x\n",
		destA[0],
		destA[1],
		destA[2],
		destA[3]
	);
	// Print stats
	printf(
		"MD5 with SIMD took %4llu cycles and %4llu instructions. CPI: %llu.%02llu\n",
		time2,
		icount2,
		time2 / icount2,
		((time2 % icount2) * 100) / icount2
	);
	
    
    while (1);
    return;
}


// (imm. format vrs1, vrd1, vrs2, vrd2)
#define v1_and_v2  ((((((( 1 <<3)| 1 ))<<3)| 2 )<<3)| 2)
#define v1  ((((((( 1 <<3)| 1 ))<<3)| 0 )<<3)| 0)
#define v2  ((((((( 2 <<3)| 2 ))<<3)| 0 )<<3)| 0)

void md5_simd(uint32_t* dest, uint32_t* src)
{ 
	// bug??
	int incr = sizeof(int)*2*4; // sizeof(int)*4*2 for 2 256-bit registers
  
	// Load vectors to v1 and v2
	//                                     offset     mem addr  vector-register
	asm volatile ("c0_lv x0, %0, %1, %2":: "r"(0   ), "r"(src), "I"(1<<(6)) );
	//                                     offset     mem addr  vector-register
	asm volatile ("c0_lv x0, %0, %1, %2":: "r"(incr), "r"(src), "I"(2<<(6)) );

	// c3 is md5 instruction
	asm volatile ("c3 x0, x0, %0":: "I"(v1_and_v2));

	// Store vector v1 to get result
	//                                     offset     mem addr  vector-register
	asm volatile ("c0_sv x0, %0, %1, %2":: "r"(0   ), "r"(dest), "I"(1<<(6+3)) );
}


// C md5 implementation taken from https://github.com/Zunawe/md5-c
/*
 * Constants defined by the MD5 algorithm
 */
#define A 0x67452301
#define B 0xefcdab89
#define C 0x98badcfe
#define D 0x10325476

static uint32_t S[] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                       5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
                       4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                       6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

static uint32_t K[] = {0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                       0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                       0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                       0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                       0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                       0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                       0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                       0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                       0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                       0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                       0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
                       0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                       0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                       0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                       0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                       0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};

/*
 * Bit-manipulation functions defined by the MD5 algorithm
 */
#define F(X, Y, Z) ((X & Y) | (~X & Z))
#define G(X, Y, Z) ((X & Z) | (Y & ~Z))
#define H(X, Y, Z) (X ^ Y ^ Z)
#define I(X, Y, Z) (Y ^ (X | ~Z))
/*
 * Rotates a 32-bit word left by n bits
 */
uint32_t rotateLeft(uint32_t x, uint32_t n){
    return (x << n) | (x >> (32 - n));
}

/*
 * Step on 512 bits of input with the main MD5 algorithm.
 */
void md5Step(uint32_t *buffer, uint32_t *input){
    uint32_t AA = buffer[0];
    uint32_t BB = buffer[1];
    uint32_t CC = buffer[2];
    uint32_t DD = buffer[3];

    uint32_t E;

    unsigned int j;

    for(unsigned int i = 0; i < 64; ++i){
        switch(i / 16){
            case 0:
                E = F(BB, CC, DD);
                j = i;
                break;
            case 1:
                E = G(BB, CC, DD);
                j = ((i * 5) + 1) % 16;
                break;
            case 2:
                E = H(BB, CC, DD);
                j = ((i * 3) + 5) % 16;
                break;
            default:
                E = I(BB, CC, DD);
                j = (i * 7) % 16;
                break;
        }

        uint32_t temp = DD;
        DD = CC;
        CC = BB;
        BB = BB + rotateLeft(AA + E + K[i] + input[j], S[i]);
        AA = temp;
    }

    buffer[0] += AA;
    buffer[1] += BB;
    buffer[2] += CC;
    buffer[3] += DD;
}
void md5_c(uint32_t* dest, uint32_t* src)
{ 
    dest[0] = A;
	dest[1] = B;
	dest[2] = C;
	dest[3] = D;
	md5Step(dest, src);
}

// Sort-in-chunks function
void sort_chunks(uint32_t* dest, uint32_t* src, size_t len)
{ 
  int incr = sizeof(int)*2*4; // sizeof(int)*4*2 for 2 256-bit registers
  
  for (int i=0; i<len; i+=incr*2){
	// Load vectors to v1 and v2
  	asm volatile ("c0_lv x0, %0, %1, %2":: "r"(i   ), "r"(src), "I"(1<<(6)) );
  	asm volatile ("c0_lv x0, %0, %1, %2":: "r"(i+incr), "r"(src), "I"(2<<(6)) );
  	
  	// Sort them individually 
  	asm volatile ("c2 x0, x0, %0":: "I"(v1));
  	asm volatile ("c2 x0, x0, %0":: "I"(v2));
  	
  	// And then merge together
  	asm volatile ("c1 x0, x0, %0":: "I"(v1_and_v2));
  	
  	// Store vectors v1 and v2
  	asm volatile ("c0_sv x0, %0, %1, %2":: "r"(i   ), "r"(dest), "I"(1<<(6+3)) );
  	asm volatile ("c0_sv x0, %0, %1, %2":: "r"(i+incr), "r"(dest), "I"(2<<(6+3)) );
  }
}

// Custom memcpy() that uses the registers
void memcpy_simd(uint32_t* dest, uint32_t* src, size_t len)
{ // when using malloc be careful to use alligned malloc
  int incr = 256/8; // 256-bit registers
  for (int i=0; i<len; i+=incr){
  	
  	asm volatile ("c0_lv x0, %0, %1, %2":: "r"(i), "r"(src), "I"(1<<(6)) );
  	asm volatile ("c0_sv x0, %0, %1, %2":: "r"(i), "r"(dest), "I"(1<<(6+3)) );
  }
}

// RS1, RD1, RS2, RD2 -> 1, 3, 2, 0
#define imm2  ((((((( 1 <<3)| 3 ))<<3)| 2 )<<3)| 0)
#define imm3  ((((((( 1 <<3)| 0 ))<<3)| 2 )<<3)| 3)
void merge_simd(uint32_t* inA, uint32_t* inB, uint32_t* dest, size_t lenA, size_t lenB)
{ 
	int incr = 8; // 4 for 128-bit registers, 8 for 256-bit	
	
  	uint32_t* inA_end = inA+(lenA/4);
  	uint32_t* inB_end = inB+(lenB/4);
  	uint32_t* dest_end = dest+(lenB/2);
  	int next_source;
  	  	
	// Load first 4 elements of each lists into vectors v1 and v2
  	asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inA), "I"(1<<(6)) ); inA+=incr;
  	asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inB), "I"(2<<(6)) ); inB+=incr;

	// Do the first merge
   	asm volatile ("c1 %0, x0, %1":"=r" (next_source): "I"(imm2));

   	// And update both v1 and v2 (next code will take care of the next_source)
	if (!next_source) {
  		if (inB!=inB_end){
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inB), "I"(2<<(6)) );  inB+=incr;
  		} 
  	} else {
  		if (inA!=inA_end){
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inA), "I"(1<<(6)) );  inA+=incr;
  		} 
  	}
	
	while (inA!=inA_end && inB!=inB_end){	
		
		// Based on the last call of c1, fetch either from A or B
  		if (next_source) {
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inB), "I"(2<<(6)) );  inB+=incr;
  		} else {
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inA), "I"(1<<(6)) );  inA+=incr;		
  		}
  		
  		// Store bottom of the current vectors (v3)
  		asm volatile ("c0_sv x0, x0, %0, %1":: "r"(dest), "I"(3<<(6+3)) ); dest+=incr;
  		
  		// Merge using current vectors
  		asm volatile ("c1 %0, x0, %1":"=r" (next_source): "I"(imm2));  		
  	}
  	
  	// Store bottom of the current vectors (v3)
  	asm volatile ("c0_sv x0, x0, %0, %1":: "r"(dest), "I"(3<<(6+3)) ); dest+=incr;
  	

	// Handle ending in a similar manner, but add "-1"s whenever one input finishes
	while (dest!=dest_end){ 
		
  		if (next_source) {
  			if (inB!=inB_end){
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inB), "I"(2<<(6)) );  inB+=incr;
  			} else
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(tmpv), "I"(2<<(6)) ); 
  		}
  		
  		if (!next_source){
  			if (inA!=inA_end){
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(inA), "I"(1<<(6)) );  inA+=incr;
  			} else
  			asm volatile ("c0_lv x0, x0, %0, %1":: "r"(tmpv), "I"(1<<(6)) ); 		
  		}
  		
  		asm volatile ("c1 %0, x0, %1":"=r" (next_source): "I"(imm2));
  		
  		asm volatile ("c0_sv x0, x0, %0, %1":: "r"(dest), "I"(3<<(6+3)) ); dest+=incr;
  	}
	
	// Reset the state of merge for the next call, by setting rd=0 (x0)
	asm volatile ("c1 x0, x0, %0":: "I"(0));		
}

// Merge sort implementation
void mergeSort(uint32_t* src,int l,int r){

	// Call the recursive function
	int dest_phase=mergeSort_worker(src,l,r);
	uint32_t* tmp= 0x70000000;
	
	// But transfer the temporary data to the result, in case the result ended up there
	if (dest_phase==1){
		memcpy_simd(src,tmp,r*4);
	}
}

// Recursive merge function
int mergeSort_worker(uint32_t* src,int l,int r){

    if(l+16==r){ 
    	// 16-element chunks have been already sorted  	
        return 0;
    }

    int m = (l+r)/2;
    
    // Call the recursive function twice
    mergeSort_worker(src,l,m);
    int dest_phase = mergeSort_worker(src,m,r);
    
    int len = (r-l)/2;

    uint32_t* tmp;
    if (dest_phase==0){
    	tmp = 0x70000000;    	
    } else {
    	tmp = src;
    	src = 0x70000000;    
    }
    
    // High-throughput merge using the merge_simd() function     
    merge_simd(src+l, src+l+len ,tmp+l, len*4, len*4);        
    
    return !dest_phase;
}


// Comparator for ascending elements
int comp (const void * elem1, const void * elem2) 
{
    int f = *((int*)elem1);
    int s = *((int*)elem2);
    if (f > s) return  1;
    if (f < s) return -1;
    return 0;
}
