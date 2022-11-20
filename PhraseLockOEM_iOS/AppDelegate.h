//
//  AppDelegate.h
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <PhraseLockOEM/PLHID.h>
#import <PhraseLockOEM/PhraseLock.h>

#define APPDELEGATE							((AppDelegate *)[UIApplication sharedApplication].delegate)
#define STATUSBARVIEW						((AppDelegate *)[UIApplication sharedApplication].delegate).statusBarView

@interface AppDelegate : UIResponder <UIApplicationDelegate, PLUserDataCB>


@property (strong, nonatomic) UIView *statusBarView;
@property (strong, nonatomic) PhraseLock* ploem;
@property (strong, nonatomic) UIWindow *window;

- (void)deleteAuthnStateConfig:(NSString *)rp;

@end

