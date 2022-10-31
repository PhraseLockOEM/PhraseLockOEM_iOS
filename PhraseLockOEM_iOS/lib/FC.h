//
//  FC.h
//  PhraseLockOEM
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef FC_h
#define FC_h

NSData* derEncodeSignature(NSData *signature);
NSData* derEncodeSignatureRev(NSData *signature);
NSData* derDecodeSignature(NSData *der, int keySize);

uint8_t* revertByteArry(uint8_t* a,  uint16_t len);
NSData* hexStringToNSData(NSString* hexString);
NSData* hexStringToNSDataReverse(NSString* hexString);
NSString * stringToHex(NSString * str);
NSString * stringToHex2(NSString *str);
NSString* byteArrayToHex(uint8_t *d, uint16_t len);
NSString* NSDataToHex(NSData *data);

void dump(char *text, uint8_t *d, int length);
void dumpData(uint8_t *d, int length);
void dumpARRAY(uint8_t *d, int length);
void dump2(char *text, uint8_t *d, int length);

#endif /* FC_h */
