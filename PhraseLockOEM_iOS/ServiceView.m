//
//  ServiceView.m
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "AppDelegate.h"
#import "ServiceView.h"
#import "db.h"

#import "QRProxy.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
@interface ServiceView ()
@property(nonatomic, retain) IBOutlet UITextView                 *logTextView;
@end

@implementation ServiceView

- (void)viewDidLoad {
	[super viewDidLoad];
}

#pragma mark - UI Actions -

- (IBAction)onScanCoreData:(id)sender
{
	QRProxy* qr = [[QRProxy alloc]initQRScanner:self sel:@selector( asyncReply_QRResponse: )];
	[qr postStartQRScanner];
}

- (IBAction)onDeleteResidentKeys:(id)sender
{
	[db delete_All_residentCredData];
}

#pragma mark - Functions -

// Callback auf das Einlesen von Daten vom QR Scanner
-(void)getQRProxyResponse:(NSString*)data sel:(SEL)selector{
	[self performSelector:selector withObject:data];
}

-(void)asyncReply_QRResponse:(NSString *)scannData{
	if (scannData!=nil && scannData.length>=12) {
		
		[self log:scannData];
		
		NSLog(@"QR-Code des USB-Stick: %@ ",scannData);
				
		NSData* nsCoreData = [APPDELEGATE.ploem prepareScannedCoreData:scannData];
		NSData* nsServiceUUID = [APPDELEGATE.ploem getServiceUUIDFromCoreData:nsCoreData];
		CBUUID *uuid = [CBUUID UUIDWithData:nsServiceUUID];
		
		NSString* ltc = [uuid UUIDString];
		[db setCoreDataSet:ltc cd:nsCoreData];
	}
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
