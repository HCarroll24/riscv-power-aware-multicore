// ============================================================================
// Copyright (c) 2024 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  No.80, Fenggong Rd., Hukou Township, Hsinchu County 303035. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================

#include <unistd.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/alt_alarm.h> // time tick function (alt_nticks(), alt_ticks_per_second())
#include "system.h"
#include "io.h"
#include "mem_verify.h"

// Generic memory configuration - modify these for different memory types
#define EXTERNAL_MEMORY_BASE    SDRAM_BASE
#define EXTERNAL_MEMORY_SPAN    SDRAM_SPAN
#define MEMORY_TYPE_NAME        "SDRAM"


typedef bool (*LP_VERIFY_FUNC)(void);


bool TEST_MEMORY(void);
bool TEST_MEMORY_QUICK(void);

typedef struct{
    LP_VERIFY_FUNC func;
    char szName[128];
}FUNC_INFO;

FUNC_INFO szFuncList[] = {
	{TEST_MEMORY,         "Memory Full Test"},
	{TEST_MEMORY_QUICK,   "Memory Quick Test"},

};


void GUI_ShowMenu(void){
    int nNum,i;

    nNum = sizeof(szFuncList)/sizeof(szFuncList[0]);
    printf("======= Agilex 3 NIOS Memory Test Program =======\r\n");
    for(i=0;i<nNum;i++){
        printf("[%d] %s\r\n", i, szFuncList[i].szName);
    }
    printf("Input your chioce:");
}

int GUI_QueryUser(void){
    int nChoice = 0;
    scanf("%d", &nChoice);
    printf("%d\r\n", nChoice);
    return nChoice;
}

//===============================================================
int main(void){
    int nChoice;
    int nNum;
    bool bPass;

    nNum = sizeof(szFuncList)/sizeof(szFuncList[0]);
    while(1){
    	GUI_ShowMenu();
        nChoice = GUI_QueryUser();
        if (nChoice >= 0 && nChoice < nNum){
            bPass = szFuncList[nChoice].func();
            printf("%s Test:%s\r\n", szFuncList[nChoice].szName, bPass?"PASS":"NG");
        }
    }

}


bool TEST_MEMORY(void){
	bool bPass, bLoop;
	int TestIndex ;
	alt_u32 InitValue = 0x01;
	bool bShowMessage = true;
	alt_u32 TimeStart, TimeElapsed;
	alt_u16 ButtonStatus;
	const alt_u8 ButtonMask = 0x0f; // 4 key
	const alt_u8 ButtonDefault = (~ButtonMask) & ButtonMask; // low active
	alt_u32 i = 0;

	// Auto-select unit: MB for <1GB, GB for >=1GB
	if (EXTERNAL_MEMORY_SPAN >= 1024*1024*1024) {
		printf("===== %s Test (Size=%dGB) =====\r\n", MEMORY_TYPE_NAME, EXTERNAL_MEMORY_SPAN/1024/1024/1024);
	} else {
		printf("===== %s Test (Size=%dMB) =====\r\n", MEMORY_TYPE_NAME, EXTERNAL_MEMORY_SPAN/1024/1024);
	}

        printf("\n==========================================================\n");

        printf("Press any BUTTON on the board to start test [BUTTON-0 for continued test] \n");
        printf("For continued test, press any BUTTON on the board to abort test.\n");
        ButtonStatus = ButtonDefault;
        while((ButtonStatus & ButtonMask) == ButtonDefault){
        	ButtonStatus = ~IORD(PIO_KEY_BASE, 0) & ButtonMask;
        	//ButtonStatus = 0x01;
        }

        if ((ButtonStatus & 0x01) == 0x01){
            bLoop = true;
            printf("Start continued test...\r\n");
        }else{
            bLoop = false;
        }
        usleep(300*1000);


		//
        bPass = true;
        TestIndex = 0;

        do{
        	TestIndex++;
        	printf("=====> %s Testing, Iteration: %d\n", MEMORY_TYPE_NAME, TestIndex);

        	TimeStart = alt_nticks();

        	////////////////////////////
        	// Testing //
        	// External Memory Testing
        	TimeStart = alt_nticks();
        	printf("== %s Testing...\r\n", MEMORY_TYPE_NAME);
       		bPass = TMEM_Verify(EXTERNAL_MEMORY_BASE, EXTERNAL_MEMORY_SPAN, InitValue << i,  bShowMessage);

        	TimeElapsed = alt_nticks() - TimeStart;
        	printf("%s test:%s, %d seconds\r\n", MEMORY_TYPE_NAME, bPass ? "Pass" : "NG", (int)(TimeElapsed/alt_ticks_per_second()));

        	i++;              // Change initial pattern for next iteration
        	if (i >= 32) i = 0; // Prevent overflow, cycle through 32 patterns

            if (bPass && bLoop){  // is abort loop?
            	ButtonStatus = ~IORD(PIO_KEY_BASE, 0) & ButtonMask;
            	if ((ButtonStatus & ButtonMask) != ButtonDefault)
            		bLoop = false; // press any key to abort continued test
            }


        }while(bLoop && bPass);

    return bPass;
}



bool TEST_MEMORY_QUICK(void){
	bool bPass, bLoop;
	int TestIndex ;
	alt_u32 TimeStart, TimeElapsed;
	alt_u16 ButtonStatus;
	const alt_u8 ButtonMask = 0x0f; // 4 key
	const alt_u8 ButtonDefault = (~ButtonMask) & ButtonMask; // low active

	// Auto-select unit: MB for <1GB, GB for >=1GB
	if (EXTERNAL_MEMORY_SPAN >= 1024*1024*1024) {
		printf("===== %s Test (Size=%dGB) =====\r\n", MEMORY_TYPE_NAME, EXTERNAL_MEMORY_SPAN/1024/1024/1024);
	} else {
		printf("===== %s Test (Size=%dMB) =====\r\n", MEMORY_TYPE_NAME, EXTERNAL_MEMORY_SPAN/1024/1024);
	}

        printf("\n==========================================================\n");

        printf("Press any BUTTON on the board to start test [BUTTON-0 for continued test].\n");
        ButtonStatus = ButtonDefault;
        while((ButtonStatus & ButtonMask) == ButtonDefault){
        	ButtonStatus = ~IORD(PIO_KEY_BASE, 0) & ButtonMask; // button is low active
        	//ButtonStatus = 0x01;
        }

        if ((ButtonStatus & 0x01) == 0x01){ // key0 is press
            bLoop = true;
            printf("Start continued test...\r\n");
        }else{
            bLoop = false;
        }
        usleep(300*1000);


		//
        bPass = true;
        TestIndex = 0;

        do{
        	TestIndex++;
        	printf("=====> %s Testing, Iteration: %d\n", MEMORY_TYPE_NAME, TestIndex);


        	TimeStart = alt_nticks();


        	////////////////////////////
        	// Testing //
        	// External Memory Testing
        	TimeStart = alt_nticks();
        	printf("== %s Testing...\r\n", MEMORY_TYPE_NAME);


            bPass = TMEM_QuickVerify(EXTERNAL_MEMORY_BASE, EXTERNAL_MEMORY_SPAN, 32,  24);

        	TimeElapsed = alt_nticks() - TimeStart;
        	printf("%s test:%s, %d seconds\r\n", MEMORY_TYPE_NAME, bPass ? "Pass" : "NG", (int)(TimeElapsed/alt_ticks_per_second()));


            if (bPass && bLoop){  // is abort loop?
            	ButtonStatus = ~IORD(PIO_KEY_BASE, 0) & ButtonMask;
            	printf("ButtonStatus=%xh\r\n", ButtonStatus);
            	if ((ButtonStatus & ButtonMask) != ButtonDefault){
            		bLoop = false; // press any key to abort continued test
            		printf("bLoop = false\r\n");
            	}
            }


        }while(bLoop && bPass);


    return bPass;
}
