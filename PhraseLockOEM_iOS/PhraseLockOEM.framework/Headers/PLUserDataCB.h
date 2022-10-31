//
//  PLUserDataCB.h
//  PhraseLockOEM
//
//  Created by Thomas Donhauser on 22.07.22.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#ifndef PLUserDataCB_h
#define PLUserDataCB_h

@protocol PLUserDataCB

@required

-(NSData*) getAAGUID;
-(uint32_t) getAtomicSignCounter:(uint32_t)baseNumber;
-(uint32_t) getSignCounterForRPID:(uint32_t*)signCountBase;
-(NSString*) getCertPWD:(NSString*) certID;

-(void) userMessage:(NSString*)extra;
-(int) userAction:(NSString*)extra;

-(NSData*) getCoreDataForServiceUUID:(NSString*) serviceUUID;
-(void) deleteAuthnStateConfig:(NSString*)rp;

-(void) storeAuthnStateConfig:(NSData*) authConfig rp:(NSString*)rp;
-(NSData*) getAuthnStateConfig:(NSString*)rp;
				
-(void) storeResidentKeyRecord:(NSString*)uname
						userid:(NSString*)userid
						 dname:(NSString*)dname
					  rpidhash:(NSString*)rpidhash
					  cridhash:(NSString*)cridhash
				   residentkey:(NSString*)residentkey
					   privkey:(NSString*)privkey;

-(NSString*) readResidentKeys:(NSString*)rpidHash;
-(NSString*) readResidentKeys:(NSString*)cridHash rpidHash:(NSString*)rpidHash;

@optional

@end

#endif /* PLDataDelegate_h */
