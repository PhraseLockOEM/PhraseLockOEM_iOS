//
//  StartView.h
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PhraseLockOEM/PLHID.h>
#import <PhraseLockOEM/PhraseLockStatusDelegate.h>

@interface StartView : UIViewController <PhraseLockStatusDelegate, HIDDelegate>

@end

