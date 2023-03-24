//
//  PhraseLock.h
//
//  Created by iPoxo IT GmbH on 13.03.20.
//  Copyright © 2020 iPoxo IT GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <PhraseLockOEM/PLUserDataCB.h>

#pragma mark - SUOTA delegate -

@protocol PhraseLockSUOTADelegate <NSObject>

@required

/* Called to modify download progress ba */
-(void)delegateSUOTAInstallProgress:(double)percent;

@optional

@end

#pragma mark - PhraseLock interface -

@interface PhraseLock : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate >
	
/*
 Inititalize with data-Interface from App-Delegate or
 any other instance that hosts this object
 */
-(id)initPhraseLock:(id<PLUserDataCB>)ctap2DataDelegate
			 apiKey:(NSData*)apiKey
		debugFilter:(uint32_t)debugFilter;

-(bool) loadTokenID:(NSString*)rp1
				rp2:(NSString*)rp2
			pinCode:(NSString*)pinCode
		p12PrivCert:(NSData*)p12PrivCert
			certPWD:(NSString*)certPWD;

-(void) unLoadTokenID;

-(void) enableUserVerification:(bool)uv;

/* Extracts the Service-UUID from Core-Data */
-(NSData*) getServiceUUIDFromCoreData:(NSData*)coreData;

/* Recalculate scanned coredata to get ready for use */
-(NSData*) prepareScannedCoreData:(NSString*)coreData;

/* read / write */
- (void) writeValueWrp:(NSData *)data charUUID:(NSString*)charUUID;
- (void) readValueWrp:(NSString*)charUUID;

/* Connection status to BLE-Device*/
-(BOOL)hasConnection;

/* Return the version of the OEM Lib */
-(long) oemLibVersion;

/* add/remove callback receivers (delegates) */
-(void)addPLDelegate:(id<NSObject>)dlgt key:(NSString*)key;
-(void)delPLDelegate:(NSString*)key;

/* Invoke and stop PhraseLock-connections */
-(void)startPhraseLockConnection:(NSArray*)arServiceUUID pairing:(BOOL)pairing debug:(BOOL)debug;
-(void)stopPhraseLockConnection;

/* Reads the master-Key and invokes delegateReceiveMasterKey */
-(void)getMasterKey;

/* Writes the master-Key and invokes delegateReceiveMasterKey */
-(void)setMasterKey:(NSData*)iv aesKey:(NSData*)aesKey;

/* Get the actuel unique Service UUID to identify the USB-Key*/
-(NSString*)getUSBSerivceUUID;

/* Get all delegates */
-(NSDictionary*) getDelegates;

/* Logging */
-(void) plpLog:(uint32_t)filter format:(NSString *)format, ...;

-(void) PLLOGExtern:(NSString*)logMessage;

#pragma mark - Status delegates and callbacks -

/* Called when a message is not processed by baceProtocol */
-(void) proxyDelegateReceivePLData:(NSData*)data;

/* Called while the connecting process to inform the user */
-(void) proxyDelegatePhraseLockCurrentConnectionState:(int)state message:(NSString*)message;

/* Called when a connection to the USB-Key is initiated */
-(void) proxyDelegatePhraseLockDidConnect:(NSString*)versionString versionCode:(int)versionCode usbMode:(int)usbMode;

/* Called if unexpected error occured */
-(void) proxyDelegatePhraseLockConnectError;

/* Called when a masterkey is read or written form or to the usb-key */
-(void) proxyDelegateReceiveMasterKey:(uint8_t)error iv:(NSData*)iv aes256Key:(NSData*)aes256Key;

/* Called when USB-Mode has changed between CTAP2 / HID / Combined */
-(void) proxyDelegateReceiveUSBMode:(uint8_t)usbMode;

#pragma mark - HID keyboard status -

/* Indicates key-status of NUM-, SCROLL- and CAPS-lock*/
-(void) proxyDelegateKeyStatus:(BOOL)numLock scrollLock:(BOOL)scrollLock capsLock:(BOOL)capsLock;

#pragma mark - SUOTA progress status -

/* Called to modify download progress ba */
-(void) proxyDelegateSUOTAInstallProgress:(double) percent;

#pragma mark - Service functions -

-(BOOL) phraselock_v01;
-(int) plp_getPLVersion;
-(void) plp_sendHIDData:(uint8_t*)hdata len:(int)len delayF:(uint8_t)delayF;

#pragma mark - SUOTA functions -

-(void) plp_startSUOTADownLoad:(NSData*)updateFileData;
-(void) plp_install_app:(int)updateMode;
-(void) plp_rw_core_data:(BOOL)bWrite coreData:(NSData*)coredata;
-(void) plp_init_keystore:(NSData*)keyStore;
-(void) plp_usb_app_mode:(int)mode;
-(void) plp_activate_sbl;
-(void) plp_read_sbl_activation;
-(void) plp_rw_flags:(BOOL)bWrite flags:(NSData*)flags;

#pragma mark - USB-Key Setup -

-(void) setPairingMode:(BOOL)pairing;
-(void) plp_switch_application;
-(void) plp_app_valid_state:(BOOL)validState;
-(void) plp_un_install_app;
-(void) plp_reboot;

#pragma mark - Testing -

-(void) sendTestData:(NSString*)s;

@end



