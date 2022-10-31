//
//  QRProxy.m
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "QRProxyDelegate.h"
#import "ScannerDelegate.h"

@interface QRProxy : NSObject <ScannerDelegate>{
}

@property (nonatomic, retain) id <QRProxyDelegate> qRProxydelegate;
@property (nonatomic, assign) SEL sel;

-(id)initQRScanner:(id)dlgt sel:(SEL)selector;
-(void)postStartQRScanner;

@end
