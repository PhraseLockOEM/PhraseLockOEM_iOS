//
//  StartView.m
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "AppDelegate.h"
#import "UIAlertController+Window.h"
#import "StartView.h"
#import "FC.h"
#import "db.h"

#import <PhraseLockOEM/PhraseLockDefines.h>
#import <PhraseLockOEM/PhraseLock.h>
#import <PhraseLockOEM/PLHID.h>

#define DEBUG_IS_ACIVE					  YES
#define AUTO_CONNECT_ON_LAUNCH			0

// iPoxo Community API-Key
uint8_t COMMUNITY_API_KEY_T4[] = {
	0xC6,0x6D,0x84,0x6B,0x3D,0x34,0xD7,0x10,0xB5,0x87,0xB6,0xE1,0x9B,0x4E,0x52,0xEE,
	0x85,0xB0,0x96,0xAB,0xB1,0x6F,0x1F,0x00,0x07,0x4B,0xFF,0x19,0x57,0x06,0x8D,0xC2,
	0xF2,0x26,0x9B,0x72,0xF2,0xD4,0xC7,0x2A,0x21,0x45,0xBE,0x69,0xAE,0x49,0xD5,0x10,
	0x1B,0x17,0x73,0x2B,0x1C,0xC3,0x05,0x3E,0x55,0x48,0xE1,0x03,0x66,0xF0,0x95,0x9A,
};

// iPoxo Operation API-Key
uint8_t IPOXO_API_KEY_T2[] = {
	0xC6,0x6D,0x84,0x6B,0x3D,0x34,0xD7,0x10,0xB5,0x87,0xB6,0xE1,0x9B,0x4E,0x52,0xEE,
	0x85,0xB0,0x96,0xAB,0xB1,0x6F,0x1F,0x00,0x07,0x4B,0xFF,0x19,0x57,0x06,0x8D,0xC2,
	0x7D,0x61,0xEE,0x97,0xA6,0xBA,0xD3,0xFC,0xAB,0x3B,0x8B,0x96,0x1C,0x63,0x91,0x27,
	0x79,0xF7,0xD0,0x0E,0x5A,0x20,0x0E,0x2F,0x77,0xC6,0x7F,0x96,0x2D,0x57,0x11,0xDB,
};

#define IPOXO_API_KEY 		IPOXO_API_KEY_T2

@interface StartView ()

@property(nonatomic, retain) IBOutlet UILabel                    *lockState;
@property(nonatomic, retain) IBOutlet UILabel                    *bleState;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView    *connectionIndicator;
@property(nonatomic, retain) IBOutlet UISwitch                   *bleSwitch;
@property(nonatomic, retain) IBOutlet UITextField                *hidString;
@property(nonatomic, retain) IBOutlet UILabel                    *usbModeLabel;
@property(nonatomic, retain) IBOutlet UITextView                 *logTextView;
@property(nonatomic, retain) IBOutlet UILabel                    *appState;

@end

@implementation StartView {
	PLHID* plhid;
	uint8_t usbCurrentMode;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[db initOnStartDB];
	//[db resetAuthenticationState];
	
	[self clearLog];
	[self.bleSwitch setOn:FALSE animated:NO];
	[self showConnectionState:NO stateText:@"No Connection"];

	/**
	 Es gibt noch keine IDs für Zertifikate. Das kommt später wenn die Cert-Auswahl beim User liegt.
	 */
		
	NSString* certID = nil;
	NSData * p12PrivCert = [db readCertDataFromFile:@"my_fido2_cert" ext:@"p12" origBundle:YES];

	/**
	 Der Paramete rp (relying party) gibt an, welche Autentifizierungsdaten herangezogen werden sollen.
	 Phrase-Lock unterstützt, anders als Hardware-Token, die Verwendung uneingeschränkt viele zu verwenden.
	 */
	NSString* rp1 = @"8CC24602-03BA-4F24-B80C-8F16EB93AA1E";
	NSString* rp2 = @"14678";

	NSData *apiKey = [[NSData alloc] initWithBytes:IPOXO_API_KEY length:sizeof(IPOXO_API_KEY)];

	APPDELEGATE.ploem = [[PhraseLock alloc] initPhraseLock:APPDELEGATE
													apiKey:apiKey
											   debugFilter:0xFFFF ];
	
	[APPDELEGATE.ploem enableUserVerification:FALSE];
	  
	bool bInit = [APPDELEGATE.ploem loadTokenID:rp1
											rp2:rp2
										pinCode:nil
									p12PrivCert:p12PrivCert
										certPWD:[APPDELEGATE getCertPWD:certID]];

	if(!bInit)
	{
    bInit = [APPDELEGATE.ploem loadTokenID:rp1
                                       rp2:rp2
                                   pinCode:self.hidString.text
                               p12PrivCert:p12PrivCert
                                   certPWD:[APPDELEGATE getCertPWD:certID]];
	}

	/**
	 Logging explaination:
	 
	 #define FORCE_DEBUG		0x00000001		Forcing some output in debug-mode only

	 #define LOG_PL	       		0x00000002		Logging PhraseLock.m
	 #define LOG_FDO_RW			0x00000004		Logging of CTAP1/CTAP2 Messages
	 #define LOG_KEYS			0x00000008		Logging of keys exchanged! Do not set in release-versions!!!

	 #define LOG_CTAP			0x00000010		Deep logging of CTAP1/CTAP2 communication
	 #define LOG_CBOR			0x00000020		Deep logging of CBOR
	 #define LOG_DMP			0x00000040		Deep logging of dumps

	 #define LOG_INIT			0x00000080		Logging of BLE init-prozess
	 #define LOG_BLE_RW			0x00000100		Extended logging of BLE communication
	 #define LOG_DGB_BLE		0x00000200		Logging of full BLE communication
	 #define LOG_DGB_BLE_FINE	0x00000400		Deep logging of BLE communication
	*/

	/*
	 IMPORTANT
	 This adds the StartController into the list of
	 receivers for PhraseLock-data/events transmitted by  the USB-Key.
	 */
	[APPDELEGATE.ploem addPLDelegate:self key:@"STARTVIEW"];
	
	/* Display the version of the oem-lib*/
	long oemLibVer = [APPDELEGATE.ploem oemLibVersion];
	NSString* nsOemVers = [NSString stringWithFormat:@"PhraseLockOEM.framework OEM-Lib Version : %d",(int)oemLibVer];
	[self.logTextView setText:nsOemVers];
	
	/* Initialize HID Output*/
	plhid = nil;
	plhid = [[PLHID alloc] init];
  [plhid setPLProtocol:APPDELEGATE.ploem plDebug:DEBUG_IS_ACIVE];
	[plhid setDelegate:self];
	
#if AUTO_CONNECT_ON_LAUNCH == 1
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.bleSwitch setOn:YES animated:NO];
    [self onTogglePLConnection:nil];
  });
#endif

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - UI Actions -

- (IBAction)onSendHIDData:(id)sender
{
	/*	A new-line is added */
	[self sendHIDData: [NSString stringWithFormat:@"%@\r", self.hidString.text ]];
}

- (IBAction)onSwitchUSBMode:(id)sender
{
	if(usbCurrentMode == CHF_USB)
	{
		[APPDELEGATE.ploem plp_usb_app_mode:FDO_USB];
	}else{
		[APPDELEGATE.ploem plp_usb_app_mode:CHF_USB];
	}	
}

- (IBAction)onTogglePLConnection:(id)sender {
	if([self.bleSwitch isOn]){
		[self onOffPhraseLock:YES];
	}else{
		[self onOffPhraseLock:NO];
	}
}

#pragma mark - Functions -

-(void)showConnectionState:(BOOL)waitForConnection stateText:(NSString*)stateText {
	
	if(waitForConnection){
		[self.connectionIndicator startAnimating];
		self.connectionIndicator.hidden=NO;
	}else{
		[self.connectionIndicator stopAnimating];
		self.connectionIndicator.hidden=YES;
	}
	
	if(stateText!=nil){
		self.bleState.text = stateText;
		self.bleState.hidden=NO;
	}else{
		self.bleState.text = nil;
		self.bleState.hidden=YES;
	}
	
	self.bleSwitch.hidden=NO;
}

-(void)onOffPhraseLock:(BOOL)turnOn {
	
	if(turnOn){
		[self showConnectionState:YES stateText: @"...wait..."];
		/**
		 Reading of all stored core data. In practical use, the list is limited by a user-specified list
		 */
		NSMutableArray*  coreDataArray =  [[NSMutableArray alloc] init];
		
		coreDataArray =  [db getAllCoreDataSets];
				
		NSMutableArray* arServiceUUID= [NSMutableArray array];
		
		// Read out only the service UUIDs from the core data
		if(coreDataArray != nil) {
			for(NSData *cd in coreDataArray){
				NSData* nsTmp = [APPDELEGATE.ploem getServiceUUIDFromCoreData:cd];
				if(nsTmp)
				{
					NSData* serviceUUID = [[NSData alloc] initWithData:nsTmp];
					if(serviceUUID)
					{
						[arServiceUUID addObject:[CBUUID UUIDWithData:serviceUUID]];
					}
				}
			}
		}
				
		if(arServiceUUID.count > 0){
			[APPDELEGATE.ploem startPhraseLockConnection:arServiceUUID pairing:NO debug:DEBUG_IS_ACIVE];
		}else{
			[APPDELEGATE.ploem stopPhraseLockConnection];
			[self delegatePhraseLockDidDisconnect];
		}
	}else{
				
		[APPDELEGATE.ploem stopPhraseLockConnection];
		[self delegatePhraseLockDidDisconnect];
	}
}

#pragma mark - HID data handling -

/*
 In this demo-code the keyboard layout is reloaded again for every sending attempt.
 It is recommended to do it more resource efficient in productive code.
 The keyboard-, resp. scan code mapping may be different on different operating
 systems. This is why it must be considered do choose the right one.
 */
-(void)sendHIDData:(NSString*)asciiString
{	
	NSString * map = [db readTXTFile:@"de_de" ext:@"xml" origBundle:YES];
  [plhid setStreamParam:6 kbdDelay:2];
	[plhid setKBDLayout:map oSType:OS_WINDOWS_LINUX];
	[plhid setHIDStream:asciiString];
		
	NSString * unknownChars = nil;
	if( ![plhid verifyKBDStream:&unknownChars] ){
		NSString *msg = [NSString stringWithFormat:@"%@\n\n%@\n",@"Unsupported chars in string:",unknownChars];
		ALERT_ASYNC(@"STOP", msg );
		ALERT_BUTTON(@"Continue",
					 [self->plhid startdKBDStream];
					 );
		ALERT_BUTTON(@"Abort",
					 // Do here what ever it needs to be done ...
					 );
		ALERT_ASYNC_SHOW
	}else{
		[plhid startdKBDStream];
	}
}

#pragma mark - PhraseLockStatusDelegate callbacks -

/*	Output of PhraseLock-Framework logging*/
-(void)delegateLogging:(uint32_t)filter logStr:(NSString*)logStr
{
	dispatch_async(dispatch_get_main_queue(), ^{
		printf("%s\n", [logStr cStringUsingEncoding:[NSString defaultCStringEncoding]] );
	});
}

-(void) delegatePhraseLockCurrentConnectionState:(int)state message:(NSString*)message
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self log:[NSString stringWithFormat:@"CONNECT STATE: %d: %@",state,message]];
	});
}

-(void) delegatePhraseLockDidConnect:(NSString*)versionString versionCode:(int)versionCode usbMode:(int)usbMode
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self showConnectionState:NO stateText:@"Connection OK"];
		self->usbCurrentMode = usbMode;
		[self delegateReceiveUSBMode:usbMode];
		self.appState.text = versionString;
	});
}

-(void) delegatePhraseLockDidDisconnect
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.bleSwitch setOn:FALSE animated:NO];
		[self showConnectionState:NO stateText:@"No Connection"];
		self.appState.text = nil;
	});
}

-(void) delegatePhraseLockConnectError
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.bleSwitch setOn:FALSE animated:NO];
		[self showConnectionState:NO stateText:@"Connection error"];
		self.appState.text = nil;
	});
}

-(void) delegatePhraseLockConnectTimeOut
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.bleSwitch setOn:FALSE animated:NO];
		[self showConnectionState:NO stateText:@"Connection time out"];
		self.appState.text = nil;
	});
}

-(void) delegateReceiveMasterKey:(uint8_t)error iv:(NSData*)iv aes256Key:(NSData*)aes256Key
{
	dispatch_async(dispatch_get_main_queue(), ^{
		/**
		 This callback is called when your main-key + iv-vector is transmittet from the Phrase-Lock USB-Key
		 to your application. You may use this key to e.g. encrypt/decrypt login-credentials. You are free to
		 change this key at any time.
		 */
	});
}

-(void) delegateReceiveUSBMode:(uint8_t)usbMode;
{
	dispatch_async(dispatch_get_main_queue(), ^{
		self->usbCurrentMode = usbMode;
		switch(self->usbCurrentMode){
			case RETURN_USB_MODE:
				self.usbModeLabel.text = @"NO USB";
				break;
			case HID_USB:
				self.usbModeLabel.text = @"HID";
				break;
			case FDO_USB:
				self.usbModeLabel.text = @"CTAP2";
				break;
			case CHF_USB:
				self.usbModeLabel.text = @"CTAP2 | HID";
				break;
		}
	});
}

#pragma mark - HID callbacks -

-(void)delegateKeyStatus:(BOOL)numLock scrollLock:(BOOL)scrollLock capsLock:(BOOL)capsLock
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (capsLock ) {
			self.lockState.text = @"Caps-Lock set!";
		}else{
			self.lockState.text = nil;
		}
	});
}

/*
 This function is called when sending HID-data is finished.
 */
-(void)delegateKeyboardStreamDone:(uint8_t)error
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Callback after send HID-data
		[self log:[NSString stringWithFormat:@"HID Data Transfer done with error: %d",error]];
	});
}

#pragma mark - Logging -

- (void) clearLog {
	self.logTextView.text = @"";
}

- (void) logToLogView:(NSString*)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSDate* date = [[NSDate alloc] init];
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
		[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC2"]];
		[formatter setDateFormat:@"HH:mm:ss.SS"];
		NSString* dateString = [formatter stringFromDate:date];
		self.logTextView.text = [self.logTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@: %@", dateString, message]];
		[self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)];
	});
}

- (void) log:(NSString *)message{
	if(message!=nil){
		[self logToLogView:message];
		printf("%s\n", [message cStringUsingEncoding:[NSString defaultCStringEncoding]] );
	}
}

@end
