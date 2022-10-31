//
//  Scanner.h
//

#import <UIKit/UIKit.h>
#import "ScannerDelegate.h"

@interface Scanner : UIViewController {
}

@property (nonatomic, retain) id <ScannerDelegate> scannerDelegate;

@property (nonatomic, retain) IBOutlet UIButton *btnStartStop;
@property (nonatomic, retain) IBOutlet UIView *captureView;


@end
