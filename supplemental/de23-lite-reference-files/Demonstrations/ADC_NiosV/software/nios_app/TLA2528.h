/*
 * TLA2528.h
 *
 *  Created on: May 21, 2025
 *      Author: User
 */

#ifndef TLA2528_H_
#define TLA2528_H_

#include <stdint.h>
#include "I2C.h"

// REGISTER
#define REG_SYSTEM_STATUS 	0x00
#define REG_GENERAL_CFG		0x01
#define REG_DATA_CFG		0x02
#define REG_OSR_CFG 		0x03 // oversampling ratio. default no
#define REG_OPMODE_CFG		0x04
#define REG_PIN_CFG			0x05 // analog input (default)  or digital input
#define REG_GPIO_CFG		0x07 // digital direction
#define REG_GPO_DRIVE_CFG 	0x09
#define REG_GPO_VALUE		0x0B
#define REG_GPI_VALUE		0x0D
#define REG_SEQUENCE_CFG	0x10 // SEQ_MODE. default manual mode
#define REG_CHANNEL_SEL 	0x11 // MANUAL_CHID[3:0] used in manual mode
#define REG_AUTO_SEQ_CH_SEL 0x12

// OPCODE
#define OP_NO 			0x00 // no operation
#define OP_REG_READ 	0x10 // single register read
#define OP_REG_WRITE 	0x08 // single register write
#define OP_SET_BIT	 	0x18 // set bit
#define OP_CLEAR_BIT 	0x20 // clear bit
#define OP_READING_BLOCK 	0x30 // Reading a continuous block of registers
#define OP_WRITING_BLOCK 	0x40 // Writing a continuous block of registers

// REG_SEQUENCE_CFG
#define SEQ_START_BIT_MASK	0x08
#define SEQ_MOD_BIT_MASK	0x07

#define TLA2528_I2C_ADDRESS 0x10  // 7-bit addr. 8-bit 0x20/21

class TLA2528 : public I2C {
protected:

	bool Write_Reg(alt_u8 nRegAddr, alt_u8 nValue);
	bool Read_Reg(alt_u8 nRegAddr, alt_u8 *pnRead8);
	bool Read_Data16(alt_u16 *pnRead16);

public:
	TLA2528(const char *pDevName, alt_u32 nDeviceAddr=TLA2528_I2C_ADDRESS);
	virtual ~TLA2528();

	bool Softreset();
	bool Read_8CH_ManualMode(uint16_t szCH[8], bool bShowData);

};

#endif /* TLA2528_H_ */
