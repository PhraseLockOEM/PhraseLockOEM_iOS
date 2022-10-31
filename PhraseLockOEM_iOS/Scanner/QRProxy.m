//
//  QRProxy.m
//

#import "Scanner.h"
#import "QRProxy.h"

@implementation QRProxy

Scanner *_scqr;

-(id)init {
	if(self = [super init]) {
	}
	return self;
}

-(id)initQRScanner:(id)dlgt sel:(SEL)selector{
	self.qRProxydelegate=dlgt;
	self.sel=selector;
	UITabBarController* nv = ((UIViewController*)dlgt).tabBarController;
	_scqr = nil;
	_scqr =[[Scanner alloc] initWithNibName:@"Scanner" bundle:nil];
	_scqr.edgesForExtendedLayout = UIRectEdgeAll;
	_scqr.extendedLayoutIncludesOpaqueBars=NO;
	_scqr.modalPresentationCapturesStatusBarAppearance=NO;
	_scqr.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	_scqr.modalPresentationStyle = UIModalPresentationPageSheet;
	[_scqr setScannerDelegate:self];
	[_scqr setModalPresentationStyle:UIModalPresentationOverCurrentContext];
	[nv presentViewController:_scqr animated:YES completion:nil];
	return self;
}

-(void)postStartQRScanner{

}

#pragma mark - ScannerDelegate Callbacks

-(void)executeScanData:(NSString*)_scanData{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.qRProxydelegate getQRProxyResponse:_scanData sel:self.sel ];
	});
}

@end
