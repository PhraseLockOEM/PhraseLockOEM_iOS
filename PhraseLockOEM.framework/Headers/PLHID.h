
//
//  HID output Impementation
//
//  Created by iPoxo IT GmbH  on 14.03.20.
//  Copyright © 2020 iPoxo IT GmbH . All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <PhraseLockOEM/PhraseLock.h>
#import <PhraseLockOEM/PhraseLockStatusDelegate.h>

#pragma mark - HID Callbacks delegate -

typedef enum {
  OS_WINDOWS_LINUX  = 0x01,   // Windows or Linux Host
  OS_MAC            = 0x02,   // Mac Host
}PL_OS_TYPE;

@protocol HIDDelegate <NSObject>
@optional

/* Indicates key-status of NUM-, SCROLL- and CAPS-lock*/
-(void)delegateKeyStatus:(BOOL)numLock scrollLock:(BOOL)scrollLock capsLock:(BOOL)capsLock;

/* Keyboar output done */
-(void)delegateKeyboardStreamDone:(uint8_t)error;

@end

@interface PLHID : NSObject <PhraseLockStatusDelegate>

-(void) setPLProtocol:(PhraseLock*)pl plDebug:(BOOL)plDebug;
-(void) setDelegate:(id<HIDDelegate>)hidDelegate;
-(BOOL) setKBDLayout:(NSString*)kbdLayout oSType:(int)oSType;
-(void) setHIDStream:(NSString*)keyboardStream;
-(BOOL) verifyKBDStream:(NSString**)unknownChars;
-(void) setStreamParam:(uint8_t)chunkSize kbdDelay:(uint8_t)kbdDelay;
-(void) startdKBDStream;

@end
