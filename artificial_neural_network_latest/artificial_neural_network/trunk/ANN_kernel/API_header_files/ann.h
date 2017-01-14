/*
 * ann.h
 *
 *  Description: This header file helps programmers to access correctly to ANN IP core weight and bias memories.
 *               User must edit ANN_BASEADDRESS, NLAYER, and definitions of layer inputs and neurons.
 *               MAX_MUL macro can be calculated manually, or relay on automated calculation if NLAYER<=4.
 *               A Wyb(x) macro must be declared on the code per layer of the ANN IP core.
 *               Those macro declare the 2D weight arrays and 1D bias arrays needed to access ANN IP core memories.
 *
 *  Created on: 17/05/2016
 *      Author: David A
 */

#ifndef ANN_H
#define ANN_H

/* Base address of weight and bias memories of the ANN IP core */
// Example for Xilinx's SDK using the example wrapper for Vivado. Correct user base address must be defined here:
#define ANN_BASEADDRESS XPAR_ANN_0_WYB_S_AXI_BASEADDR

/* Number of layers */
#define NLAYER 4

/* Number of inputs and neurons of each layer */
// Add or remove as many layers as needed:
#define NumIn0 16
#define NumN0 13
#define NumIn1 NumN0
#define NumN1 6
#define NumIn2 NumN1
#define NumN2 13
#define NumIn3 NumN2
#define NumN3 16

/* (optional) Redefine number of neurons in the last layer as number of outputs */
#define NumOut NumN3

/* Next-power-of-two of inputs and neurons of each layer */
// Define a next-power-of-two macro per parameter in the number of inputs and neurons of each layer list:
// NOTE: next_2power(x) macro function calculates the next-power-of-two of x for x<=256. If x>256 it still returns 256.
#define NumN0_b2  next_2power(NumN0)
#define NumIn0_b2  next_2power(NumIn0)
#define NumN1_b2  next_2power(NumN1)
#define NumIn1_b2  next_2power(NumIn1)
#define NumN2_b2  next_2power(NumN2)
#define NumIn2_b2  next_2power(NumIn2)
#define NumN3_b2  next_2power(NumN3)
#define NumIn3_b2  next_2power(NumIn3)

/* Maximum multiplication of the next-power-of-two of inputs by the next-power-of-two of neurons */
// MAX_MUL macro can be defined manually, or automatically if NLAYER<=4.
// To define it manually user must determine which layer has the maximum of these products, and edit MAX_MUL definition:
// In the example is layer 0 (or layer 3 with same MAX_MUL), 256 > 128
//    NumIn0 = 16 ==> NumIn0_b2 = 16
//    NumN0 = 13  ==> NumN0_b2 = 16
//          NumN0_b2*NumIn0_b2=16*16=256
//    NumIn1 = 13 ==> NumIn1_b2 = 16
//    NumN1 = 6   ==> NumN1_b2 = 8
//          NumN1_b2*NumIn1_b2=16*8=128
//    NumIn2 = 6  ==> NumIn2_b2 = 8
//    NumN2 = 13  ==> NumN2_b2 = 16
//          NumN2_b2*NumIn2_b2=8*16=128
//    NumIn3 = 13 ==> NumIn3_b2 = 16
//    NumN3 = 16  ==> NumN3_b2 = 16
//          NumN3_b2*NumIn3_b2=16*16=256

//#define MAX_MUL (NumN0_b2*NumIn0_b2) //Uncomment and edit this manual definition of MAX_MUL for manual definition of MAX_MUL

// Automated calculation of MAX_MUL for NLAYER<=4:
#ifndef MAX_MUL
#if NLAYER > 4
#error MAX_MUL cannot be automatically calculated if NLAYER>4. Define MAX_MUL manually or complete the automaed calculation of MAX_MUL preprocessor code.
#endif
#define max2(x,y)  ( ((x) < (y)) ? y : x )
#define MAX_0 (NumN0_b2*NumIn0_b2)
#if NLAYER > 1
    #define MAX_1 max2((NumN1_b2*NumIn1_b2),MAX_0)
    #if NLAYER > 2
        #define MAX_2 max2((NumN2_b2*NumIn2_b2),MAX_1)
        #if NLAYER == 4
            #define MAX_MUL max2((NumN3_b2*NumIn3_b2),MAX_2)
        #elif NLAYER == 3
            #define MAX_MUL MAX_2
        #endif //NLAYER == 4
    #elif NLAYER == 2
        #define MAX_MUL MAX_1
    #endif //NLAYER > 2
#else //NLAYER == 1
    #define MAX_MUL MAX_0
#endif //NLAYER > 1
#endif

/* Definition of the macro function next_2power(x) */
// It calculates the next-power-of-two of x for x<=256. If x>256 it still returns 256.
#define next_2power(x)  ( ((x) > 128) ? 256 : ((x) > 64) ? 128 : ((x) > 32) ? 64 : ((x) > 16) ? 32 : ((x) > 8) ? 16 : ((x) > 4) ? 8 : ((x) > 2) ? 4 : ((x) > 1) ? 2 : 1 )

/* When this macro is expanded for a particular layer x, it declares pointers to the weight 2D array, bias 1D array, and unused spaces; and initializes them with a proper address */
// Declare a Wvb(x) macro per layer on the user's ANN, each time with a different layer number x, from 0 to NLAYER-1.
// Example: For a two layer ANN (NLAYER 2)
//    Wvb(0)  // declares and initializes int (*W0)[NumN0][NumIn0_b2], (*b0)[NumN0];
//    Wyb(1)  // declares and initializes int (*W1)[NumN1][NumIn1_b2], (*b1)[NumN1];
// The unused spaces (*NOT_EXISTx0) and (*NOT_EXISTx1) are declared in order to prevent the use of these space address for other proposes. Although it does not assure it will not be used.
#define Wyb(x)  volatile int (*W##x)[NumN##x][NumIn##x##_b2] = (void *) ANN_BASEADDRESS + MAX_MUL*2*x*sizeof(int), \
(*NOT_EXIST##x##0)[MAX_MUL-NumN##x*NumIn##x##_b2] = (void *) ANN_BASEADDRESS + (NumN##x*NumIn##x##_b2 + MAX_MUL*2*x)*sizeof(int), \
(*b##x)[NumN##x] = (void *) ANN_BASEADDRESS + MAX_MUL*(2*x+1)*sizeof(int), \
(*NOT_EXIST##x##1)[MAX_MUL-NumN##x] = (void *) ANN_BASEADDRESS + (NumN##x + MAX_MUL*(2*x+1))*sizeof(int);

#endif // ANN_H
