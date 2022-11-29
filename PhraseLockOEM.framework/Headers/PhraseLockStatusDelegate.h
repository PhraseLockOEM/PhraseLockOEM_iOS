//
//  PhraseLockStatusDelegate.h
//  PhraseLockOEM
//
//  Created by Thomas Donhauser on 15.09.22.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#ifndef PhraseLockStatusDelegate_h
#define PhraseLockStatusDelegate_h


@protocol PhraseLockStatusDelegate <NSObject>

@required

@optional

/**
 ATTENTION: Under regular circumstances you never need to implement this!
 Called on incomming data from BLE for PL-characteristic.
 */
-(void)delegateReceivePLData:(uint8_t*)data len:(int)len;

/* Called while the connecting process to inform the user */
-(void) delegatePhraseLockCurrentConnectionState:(int)state message:(NSString*)message;

/* Called when a connection to the USB-Key is established */
-(void) delegatePhraseLockDidConnect:(NSString*)versionString versionCode:(int)versionCode usbMode:(int)usbMode;

/* Called when a connection to the USB-Key got lost */
-(void) delegatePhraseLockDidDisconnect;

/* Called if unexpected error occured */
-(void) delegatePhraseLockConnectError;

/* Called when a connection to the USB-Key could not established in time */
-(void) delegatePhraseLockConnectTimeOut;

/* Called when a masterkey is read or written form or to the usb-key */
-(void) delegateReceiveMasterKey:(uint8_t)error iv:(NSData*)iv aes256Key:(NSData*)aes256Key;

/* Called when USB-Mode has changed between CTAP2 / HID / Combined */
-(void) delegateReceiveUSBMode:(uint8_t)usbMode;

/*	Output of PhraseLock-Framework logging */
-(void)delegateLogging:(uint32_t)filter logStr:(NSString*)logStr;

/* Called to modify download progress ba */
void delegateSUOTAInstallProgress(double percent);

@end
#endif /* PhraseLockStatusDelegate_h */
