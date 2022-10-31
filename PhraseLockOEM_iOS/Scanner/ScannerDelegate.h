//
//  ScannerDelegate.h
//

#ifndef ScannerDelegate_h
#define ScannerDelegate_h

@protocol ScannerDelegate <NSObject>
	-(void)executeScanData:(NSString*)_scanData;
@end

#endif /* ScannerDelegate_h */
