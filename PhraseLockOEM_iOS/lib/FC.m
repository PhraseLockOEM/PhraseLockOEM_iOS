//
//  FC.m
//  PhraseLockOEM
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "FC.h"

#pragma mark - DER <-> ASN.1 Converting -

static NSRange derDecodeSequence(const unsigned char *bytes, int length, int index) {
	NSRange result;
	result.location = NSNotFound;

	// Make sure we are long enough and have a sequence
	if (length - index > 2 && bytes[index] == 0x30) {

		// Make sure the input buffer is large enough
		int sequenceLength = bytes[index + 1];
		if (index + 2 + sequenceLength <= length) {
			result.location = index + 2;
			result.length = sequenceLength;
		}
	}

	return result;
}

static NSRange derDecodeInteger(const unsigned char *bytes, int length, int index) {
	NSRange result;
	result.location = NSNotFound;

	// Make sure we are long enough and have an integer
	if (length - index > 3 && bytes[index] == 0x02) {

		// Make sure the input buffer is large enough
		int integerLength = bytes[index + 1];
		if (index + 2 + integerLength <= length) {

			// Strip any leading zero, used to preserve sign
			if (bytes[index + 2] == 0x00) {
				result.location = index + 3;
				result.length = integerLength - 1;

			} else {
				result.location = index + 2;
				result.length = integerLength;
			}
		}
	}

	return result;
}

NSData* derDecodeSignature(NSData *der, int keySize) {
	int length = (int)[der length];
	const unsigned char *data = [der bytes];

	// Make sure we have a sequence
	NSRange sequence = derDecodeSequence(data, length, 0);
	if (sequence.location == NSNotFound) { return nil; }

	// Extract the r value (first item)
	NSRange rValue = derDecodeInteger(data, length, (int)sequence.location);
	if (rValue.location == NSNotFound || rValue.length > keySize) { return nil; }

	// Extract the s value (second item)
	int sStart = (int)rValue.location + (int)rValue.length;
	NSRange sValue = derDecodeInteger(data, length, sStart);
	if (sValue.location == NSNotFound || sValue.length > keySize) { return nil; }

	// Create an empty array with 0's
	unsigned char output[2 * keySize];
	bzero(output, 2 * keySize);

	// Copy the r and s value in, right aligned to zero adding
	[der getBytes:&output[keySize - rValue.length] range:NSMakeRange(rValue.location, rValue.length)];
	[der getBytes:&output[2 * keySize - sValue.length] range:NSMakeRange(sValue.location, sValue.length)];

	return [NSData dataWithBytes:output length:2 * keySize];
}

#pragma mark - ASN.1 <-> DER Converting -

static NSData* derEncodeInteger(NSData *value) {
	int length = (int)[value length];
	const unsigned char *data = [value bytes];

	int outputIndex = 0;
	unsigned char output[length + 3];
	memset(output,0,length + 3);
	
	output[outputIndex++] = 0x02;

	// Find the first non-zero entry in value
	int start = 0;
	while (start < length && data[start] == 0){ start++; }

	// Add the length and zero padding to preserve sign
	if (start == length || data[start] >= 0x80) {
		output[outputIndex++] = length - start + 1;
		output[outputIndex++] = 0x00;
	} else {
		output[outputIndex++] = length - start;
	}

	[value getBytes:&output[outputIndex] range:NSMakeRange(start, length - start)];
	outputIndex += length - start;
	
	return [NSData dataWithBytes:output length:outputIndex];
}

NSData* derEncodeSignature(NSData *signature) {

	int length = (int)[signature length];
	if (length % 2) { return nil; }

	NSData *rValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(0, length / 2)]);
	NSData *sValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(length / 2, length / 2)]);

	// Begin with the sequence tag and sequence length
	unsigned char header[2];
	header[0] = 0x30;
	header[1] = [rValue length] + [sValue length];

	// This requires a long definite octet stream (signatures aren't this long)
	if (header[1] >= 0x80) { return nil; }

	NSMutableData *encoded = [NSMutableData dataWithBytes:header length:2];
	[encoded appendData:rValue];
	[encoded appendData:sValue];

	return [encoded copy];
}

NSData* derEncodeSignatureRev(NSData *signature) {

	int length = (int)[signature length];
	if (length % 2) { return nil; }

	revertByteArry((uint8_t*)signature.bytes, 32);
	revertByteArry((uint8_t*)signature.bytes+32, 32);

	NSData *rValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(0, length / 2)]);
	NSData *sValue = derEncodeInteger([signature subdataWithRange:NSMakeRange(length / 2, length / 2)]);

	// Begin with the sequence tag and sequence length
	unsigned char header[2];
	header[0] = 0x30;
	header[1] = [rValue length] + [sValue length];

	// This requires a long definite octet stream (signatures aren't this long)
	if (header[1] >= 0x80) { return nil; }

	NSMutableData *encoded = [NSMutableData dataWithBytes:header length:2];
	[encoded appendData:rValue];
	[encoded appendData:sValue];

	return [encoded copy];
}

uint8_t* revertByteArry(uint8_t* a,  uint16_t len){
	uint8_t *b = malloc(len);
	memcpy(b,a,len);
	for(uint16_t i=0; i<len;i++){
		*(a+len-1-i)= *(b+i);
	}
	free(b);
	return a;
}

NSData* hexStringToNSData(NSString* hexString) {
	hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	int i;
	for (i=0; i < [hexString length]/2; i++) {
		byte_chars[0] = [hexString characterAtIndex:i*2];
		byte_chars[1] = [hexString characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1];
	}
	return commandToSend;
}

NSData* hexStringToNSDataReverse(NSString* hexString) {
	hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	int hexLen = (int)[hexString length]/2;
	char byte_chars[3] = {'\0','\0','\0'};
	int i;
	for (i=0; i < hexLen; i++) {
		byte_chars[0] = [hexString characterAtIndex:(hexLen-i-1)*2];
		byte_chars[1] = [hexString characterAtIndex:(hexLen-i-1)*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1];
	}
	return commandToSend;
}

NSString * stringToHex(NSString * str) {
	NSUInteger len = [str length];
	unichar *chars = malloc(len * sizeof(unichar));
	[str getCharacters:chars];
	NSMutableString *hexString = [[NSMutableString alloc] init];
	for(NSUInteger i = 0; i < len; i++ ){
		[hexString appendFormat:@"%02x", chars[i]];
	}
	free(chars);
	return hexString;
}

NSString * stringToHex2(NSString *str) {
	NSUInteger len = [str length];
	unichar *chars = malloc(len * sizeof(unichar));
	[str getCharacters:chars];
	NSMutableString *hexString = [[NSMutableString alloc] init];
	for(NSUInteger i = 0; i < len; i++ ){
		[hexString appendFormat:@"%02x", chars[i]];
	}
	free(chars);
	return hexString;
}

NSString* byteArrayToHex(uint8_t *d, uint16_t len) {
	NSMutableString *hexStr = [NSMutableString stringWithCapacity:len*2];
	for (int i = 0; i < len; i++) {
		[hexStr appendFormat:@"%02x", *(d+i)];
	}
	return [NSString stringWithString: hexStr];
}

NSString* NSDataToHex(NSData *data) {
	const unsigned char *dbytes = [data bytes];
	NSMutableString *hexStr =
	[NSMutableString stringWithCapacity:[data length]*2];
	int i;
	for (i = 0; i < [data length]; i++) {
		[hexStr appendFormat:@"%02x", dbytes[i]];
	}
	return [NSString stringWithString: hexStr];
}

void dump(char *text, uint8_t *d, int length) {
	int i;
	printf("%-20s", text);
	for (i = 0; i < length; ++i){
		//printf("%02x", d[BASE_32_BYTE_SIZE-i-1]);
		printf("%02x", d[i]);
	}
	printf("\n");
}

void dumpData(uint8_t *d, int length) {
	int i;
	for (i = 0; i < length; ++i){
		printf("0x%02X,", d[i]);
	}
}

void dumpARRAY(uint8_t *d, int length) {
	int i;
	printf("{");
	for (i = 0; i < length; ++i){
		printf("0x%02X,", d[i]);
	}
	printf("}");
}

void dump2(char *text, uint8_t *d, int length) {
	int i;
	printf("%-20s", text);
	for (i = 0; i < length; ++i){
		printf("0x%02X,", d[i]);
	}
	printf("\n");
}

