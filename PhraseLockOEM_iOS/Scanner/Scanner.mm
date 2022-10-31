//
//  Scanner.m
//

//#import "mt_def.h"
//#import "db.h"
#import "Scanner.h"
#import "MTBBarcodeScanner.h"


@implementation Scanner

@synthesize scannerDelegate;
@synthesize btnStartStop;

MTBBarcodeScanner *_scanner;
UIView *_captureView;

UINavigationController *_nvc;

- (void)dealloc {
}

-(id)init{
	self = [super init];
	self.scannerDelegate = nil;
	_scanner = nil;
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	self = [super initWithCoder:aDecoder];
	self.scannerDelegate = nil;
	_scanner = nil;
	return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	self.scannerDelegate = nil;
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Scanner

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self startScanner];
}

-(void)startScanner{
	[MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
		if (success) {
			_scanner = nil;
			_scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.captureView];
			NSError *error = nil;
			[_scanner startScanningWithResultBlock:^(NSArray *codes) {
				for (AVMetadataMachineReadableCodeObject *code in codes) {
					if (code.stringValue) {
						NSLog(@"Found unique code: %@", code.stringValue);
						[self.scannerDelegate executeScanData:code.stringValue];
						
						[self abortQRScanner:self];
					}
				}
			} error:&error];
		}
	}];
}

-(IBAction)abortQRScanner:(id)sender{
	[_scanner stopScanning];
	[self dismissViewControllerAnimated:YES completion:nil];
}



@end
