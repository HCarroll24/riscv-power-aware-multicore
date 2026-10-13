/*************************************************************************
 * @file:   test_prog.c
 * @author: carrollh@msoe.edu <Hunter Carroll>
 * @date:   6 October 2026
 * @brief:  Test program for RV32I pipelined processor to confirm proper
 *          funcitonality without "toy" test programs where I choose what
 *          happens. Confirming working with actual program.
*************************************************************************/
#define LED         0xFF200000  // red leds
#define SEG7_3_0    0xFF200020  // 7 segment hex3-hex0
#define SEG7_5_4    0XFF200030  // 7 segment hex5-hex4
#define SW          0xFF200040  // slider switches
#define BTN         0xFF200050  // KEY1 - KEY0

/**
 * @brief Main function that will have subroutines
 * 
 * @return int 0
 */
int main(void) {
    int compare = 0;
    int start = 10;
    int count = 0;

    /* Infinite Loop */
    for(int i = 0; i < 5; i++) {
        increment(&compare);
        decrement(&start);
        if (compare % 1 == start % 2) {
            count++;
        }
    }
}

/**
 * @brief Increments variable by 1
 * 
 * @param x variable to be incremented
 */
void increment(int *x) {
    (*x)++;
}

/**
 * @brief Subtracts x by 1
 * 
 * @param x variable to be decreased
 */
void decrement(int *x) {
    (*x)--;
}

/**
 * @brief Checks if number is greater than 10
 * 
 * @param num number to check against
 * @return int 1 if true, 0 if false
 */
int check(int num) {
    if (num > 10) {
        return 1;
    }
    return 0;
}