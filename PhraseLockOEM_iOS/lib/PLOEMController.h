//
//  MaintenanceController.h
//  PLOEMController
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogDelegate <NSObject>

@required

@optional

-(void) log:(NSString*)message print:(BOOL)print;

@end

@interface PLOEMController : UIViewController  <LogDelegate>

@property (nonatomic, retain)  IBOutlet UITextView                 *logTextView;

- (void) clearLog;
- (void) log:(NSString *)message;

@end

