//
//  AppDelegate.m
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "AppDelegate.h"
#import "UIAlertController+Window.h"
#import "FC.h"
#import "db.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
	NSString* userMutex;
	dispatch_semaphore_t sema;
	long long lastTimeUPVerfication;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.

	UITabBarController * tabBarController = (UITabBarController*)self.window.rootViewController;
	if(tabBarController!=nil){
		tabBarController.selectedIndex = 0;
	}

	self.statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
	STATUSBARVIEW.backgroundColor=[UIColor whiteColor];
	[self.window.rootViewController.view addSubview:self.statusBarView];

	return YES;
}

#pragma mark - PLUserDataCB -

- (NSData *)getAAGUID
{
	return hexStringToNSData(@"F0DB552BB9B74AE6BCAF4E87F9C563D4");
}

- (NSString *)getCertPWD:(NSString *)certID
{
	NSString* certPWD = @"my_secret_cert_pa&&word";
	return certPWD;
}

- (void)deleteAuthnStateConfig:(NSString *)rp
{
	if(rp!=nil && rp.length>0){
		[db deleteBlockdata:[NSString stringWithFormat:@"%@%@%@",GLOBAL_AUTHNDATA,@"_",rp]];
	}else{
		[db deleteBlockdata:GLOBAL_AUTHNDATA];
	}
}

- (uint32_t)getAtomicSignCounter:(uint32_t)baseNumber
{
	uint32_t counter1 = [db getBlockdata:ATOMIC_COUNTER dataUint32_t:(uint32_t)1];
	counter1 += (baseNumber + 1);
	[db setBlockdata:ATOMIC_COUNTER dataUint32_t:counter1];
	return counter1;
}

- (NSData *)getAuthnStateConfig:(NSString *)rp
{
	if(rp!=nil && rp.length>0){
		return [db getBlockdata:[NSString stringWithFormat:@"%@%@%@",GLOBAL_AUTHNDATA,@"_",rp] dataNSData:nil];
	}else{
		return [db getBlockdata:GLOBAL_AUTHNDATA dataNSData:nil];
	}
}

- (NSData *)getCoreDataForServiceUUID:(NSString *)serviceUUID
{
	return [db getCoreDataSet:serviceUUID];
}

- (uint32_t)getSignCounterForRPID:(uint32_t *)signCountBase
{
	uint32_t count = [self getAtomicSignCounter:1];
	if (count == 0) {    // count 0 will indicate invalid token
		count = [self getAtomicSignCounter:0];
	}
	
	uint8_t * byte = (uint8_t*) signCountBase;
	
	// Hier wird nach Big-Endian umgeschrieben
	*byte++ = (count >> 24) & 0xff;
	*byte++ = (count >> 16) & 0xff;
	*byte++ = (count >> 8) & 0xff;
	*byte++ = (count >> 0) & 0xff;
	
	return count;
}

- (NSString *)readResidentKeys:(NSString *)rpidHash
{
	return [db readResidentKeys:rpidHash];
}

- (NSString *)readResidentKeys:(NSString *)cridHash rpidHash:(NSString *)rpidHash
{
	return [db readResidentKeys:cridHash rpidHash:rpidHash];
}

- (void)storeAuthnStateConfig:(NSData *)authConfig rp:(NSString *)rp
{
	if(rp!=nil && rp.length>0){
		[db setBlockdata:[NSString stringWithFormat:@"%@%@%@",GLOBAL_AUTHNDATA,@"_",rp] dataNSData:authConfig];
	}else{
		[db setBlockdata:GLOBAL_AUTHNDATA dataNSData:authConfig];
	}
}

- (void)storeResidentKeyRecord:(NSString *)uname
						userid:(NSString *)userid
						 dname:(NSString *)dname
					  rpidhash:(NSString *)rpidhash
					  cridhash:(NSString *)cridhash
				   residentkey:(NSString *)residentkey
					   privkey:(NSString *)privkey
{
	[db storeResidentKeyRecord:uname
						userid:userid
						 dname:dname
					  rpidhash:rpidhash
					  cridhash:cridhash
				   residentkey:residentkey
					   privkey:privkey];
	
}

#define USER_ACTION			1
-(int )userAction:(NSString*)extra
{
#if USER_ACTION == 0
	return 1;
#else
	self->sema = dispatch_semaphore_create(0);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		window.rootViewController = [UIViewController new];
		window.windowLevel = UIWindowLevelAlert + 1;
		
		UIAlertController* alertCtrl = [UIAlertController alertControllerWithTitle:@"Phrase-Lock User Presence"
																		   message:@"Confirm User-Presense"
																	preferredStyle:UIAlertControllerStyleAlert];
		/**
		 This is for development purposes only. It is just
		 more convenient not to hit the button every time.
		 */
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[alertCtrl dismissViewControllerAnimated:NO completion:nil];
			@synchronized (self->userMutex) {
				self->userMutex = @"1";
				dispatch_semaphore_signal(self->sema);
			}
		});
		
		[alertCtrl addAction:[UIAlertAction actionWithTitle:@"No"
													  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			@synchronized (self->userMutex) {
				self->userMutex = @"0";
				dispatch_semaphore_signal(self->sema);
			}
			// very important to hide the window afterwards.
			// this also keeps a reference to the window until the action is invoked.
			window.hidden = YES;
		}]];
		
		[alertCtrl addAction:[UIAlertAction actionWithTitle:@"Yes"
													  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			@synchronized (self->userMutex) {
				self->userMutex = @"1";
				dispatch_semaphore_signal(self->sema);
			}
			// very important to hide the window afterwards.
			// this also keeps a reference to the window until the action is invoked.
			window.hidden = YES;
		}]];
		
		[window makeKeyAndVisible];
		[window.rootViewController presentViewController:alertCtrl animated:YES completion:^{
			
		}];
	});

	@synchronized (self->userMutex) {
		self->userMutex = @"-1";
	}
	while (dispatch_semaphore_wait(self->sema, DISPATCH_QUEUE_PRIORITY_LOW)) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0]];
		[NSThread sleepForTimeInterval:0.001];
	}
	@synchronized (userMutex) {
		int result = [userMutex intValue];
		if(result>=0){
			if(result==1) {
				lastTimeUPVerfication = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
				return 1;
			}else{
				return 0;
			}
		}
	}
 
	return 0;
#endif
}

- (void)userMessage:(NSString *)extra
{
	
}

@end
