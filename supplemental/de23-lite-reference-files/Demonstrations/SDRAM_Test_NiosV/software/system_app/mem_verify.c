#include <stdio.h>
#include <stdlib.h> // malloc, free
#include <string.h>
#include <stddef.h>
#include <unistd.h>  // usleep (unix standard?)
#include <stdbool.h>
#include <sys/alt_cache.h>
#include <sys/alt_alarm.h> // time tick function (alt_nticks(), alt_ticks_per_second())
#include "alt_types.h"  // alt_u32
#include "mem_verify.h"
#include "io.h"

//#define SHOW_PROGRESS


bool TMEM_Verify(alt_u32 BaseAddr, alt_u32 ByteLen, alt_u32 InitValue, bool bShowMessage){
    bool bPass = true;
    typedef alt_u32 my_data;
    my_data szData[257];
    alt_64 i, nRemainedLen, nAccessLen;
    my_data *pDes, *pSrc;
    alt_64 nItemNum, nPos;
    const alt_64 my_data_size = sizeof(my_data);
    int nProgressIndex=0;
    alt_u64 szProgress[10];
    
    if (bShowMessage){
        for(i=0;i<10;i++){
            szProgress[i] = ByteLen/10*(i+1);     
        }
    }        
    
    
    nItemNum = sizeof(szData)/sizeof(szData[0]);
    for(i=0;i<nItemNum;i++){
        if (i == 0)
            szData[i] = InitValue;
        else     
            szData[i] = szData[i-1] * 13;
    }
    szData[nItemNum-1] = 0xAAAAAAAA;
    szData[nItemNum-2] = 0x55555555;
    szData[nItemNum-3] = 0x00000000;
    szData[nItemNum-4] = 0xFFFFFFFF;

    if (bShowMessage)    
        printf("write...\n");
    // write
    pDes = (my_data *)BaseAddr;
    nAccessLen = sizeof(szData);
    nItemNum = nAccessLen / my_data_size;
    nPos = 0;
    while(nPos < ByteLen){
        nRemainedLen = ByteLen - nPos;
        if (nAccessLen > nRemainedLen){
            nAccessLen = nRemainedLen;
            nItemNum = nAccessLen / my_data_size;
        }    
        memcpy(pDes, szData, nAccessLen);
        pDes += nItemNum;
        nPos += nAccessLen;
        
        if (bShowMessage){
            if (nProgressIndex <= 9 && nPos >= szProgress[nProgressIndex]){
                nProgressIndex++;
                printf("%02d%% ", nProgressIndex*10);
            }
        }            
    } 
    
    alt_dcache_flush_all();
    
    if (bShowMessage){
        nProgressIndex = 0;
        printf("\nread/verify...\n");
    }        
    
    // read & verify
    pSrc = (my_data *)BaseAddr;
    nAccessLen = sizeof(szData);
    nItemNum = nAccessLen / my_data_size;
    nPos = 0;
    while(bPass && nPos < ByteLen){
        nRemainedLen = ByteLen - nPos;
        if (nAccessLen > nRemainedLen){
            nAccessLen = nRemainedLen;
            nItemNum = nAccessLen / my_data_size;
        }            
        pDes = szData;
        for(i=0;i<nItemNum && bPass;i++){
            if (*pSrc++ != *pDes++){ 
                if (bShowMessage)        
                    printf("verify ng, read=%08Xh, expected=%08Xh, WordIndex=%llXh\n", (int)*(pSrc-1), (int)szData[i], (alt_u64)((nPos/my_data_size)+i));
                bPass = false;
            }    
        }
        nPos += nAccessLen;
        if (bShowMessage){
            if (nProgressIndex <= 9 && nPos >= szProgress[nProgressIndex]){
                nProgressIndex++;
                printf("%02d%% ", nProgressIndex*10);
            }
        }            
    }     

    if (bShowMessage)    
        printf("\n");
    
    return bPass;
}


/*
 * TMEM_QuickVerify - Quick memory test with address/data line verification
 * 
 * Parameters:
 *   BaseAddr   - Memory base address
 *   DataSize   - Total memory size in bytes
 *   DataWidth  - Data bus width in bits (typically 32)
 *   AddrWidth  - Address bus width for WORD addressing
 *                * For IORD/IOWR: offset parameter is in 32-bit words
 *                * Address width calculation: log2(DataSize/4) bits
 *                * Example: 64MB = 67,108,864 bytes = 16,777,216 words = 2^24 → 24 bits
 *
 * Address Line Parameter Setting Guide:
 *   Memory Size (bytes) → Word Count → Address Width
 *   1MB   (1,048,576)   → 262,144    → 18 bits
 *   4MB   (4,194,304)   → 1,048,576  → 20 bits
 *   16MB  (16,777,216)  → 4,194,304  → 22 bits
 *   64MB  (67,108,864)  → 16,777,216 → 24 bits
 *   256MB (268,435,456) → 67,108,864 → 26 bits
 *   1GB   (1,073,741,824) → 268,435,456 → 28 bits
 */
bool TMEM_QuickVerify(alt_u32 BaseAddr, alt_u32 DataSize, alt_u32 DataWidth, alt_u32 AddrWidth){
    bool bPass = true;
    const alt_u32 TestNum = 1024*1024*2;  // 2M random tests
    const alt_u32 TestPattern = 0xAA;     // Walking-1 test pattern
    alt_u32 mask, Read32, Addr32, TestData32, TestAddr32;
    int i;
    
    // Address Line Test (Walking-1 Pattern)
    // Tests each address line individually using IORD/IOWR word addressing
    // mask represents word offset: 0x1, 0x2, 0x4, 0x8, ..., 0x800000 (for 24-bit)
    // Actual memory addresses: BaseAddr+4, BaseAddr+8, BaseAddr+16, ..., BaseAddr+0x2000000
    mask = 0x01;
    for(i=0;i<AddrWidth && bPass;i++){
        //*(pMem + mask) = TestPattern;
        IOWR(BaseAddr, mask, TestPattern);
        //if (*(pMem + mask) != TestPattern)
        Read32 = IORD(BaseAddr, mask);
        if (Read32 != TestPattern)
            bPass = false;
        mask <<= 1;    // Shift to next address line (0x1→0x2→0x4→0x8...)
    }

    // Data Line Test (Walking-1 Pattern)
    // Tests each data line individually using different memory locations
    // Uses scattered addresses (i*13) to avoid memory array interactions
    mask = 0x01;
    for(i=0;i<DataWidth && bPass;i++){
        //*(pMem+i/32) = mask;
        Addr32 = i*13;                  // Use prime number (13) for scattered addressing
        IOWR(BaseAddr, Addr32, mask);   // Write single-bit pattern
        Read32 = IORD(BaseAddr, Addr32);
        //if (*(pMem+i/32) != mask)
        if (Read32 != mask)
            bPass = false;
        mask <<= 1;                     // Shift to next data line (D0→D1→D2→...→D31)
        if (mask == 0x00)               // Reset to D0 after D31 (handle 32-bit rollover)
            mask = 0x01;    
    }

    // Random Data Test
    // Performs comprehensive read/write verification with random addresses and data
    // Tests functional memory operation under realistic conditions
    srand(alt_nticks());                      // Seed random generator with current time
    for(i=0;i<TestNum && bPass;i++){
        TestAddr32 = rand()%(DataSize/4);     // Random word address within memory range
        TestData32 = rand();                  // Random 32-bit test data
        IOWR(BaseAddr, TestAddr32, TestData32);
        Read32 = IORD(BaseAddr, TestAddr32);
        if (Read32 != TestData32)
            bPass = false;
        
    }
    
    printf("%s\r\n", bPass ? "PASS" : "NG");

    return bPass;
}
