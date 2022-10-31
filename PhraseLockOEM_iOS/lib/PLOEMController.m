//
//  PLOEMController.m
//  PLOEMController
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "PLOEMController.h"


#pragma mark - PLOEMController --

@implementation PLOEMController

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
