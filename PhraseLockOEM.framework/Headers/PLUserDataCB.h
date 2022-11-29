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

-(NSString*) getAAGUID;

-(NSData*) getCoreDataForServiceUUID:(NSString*) serviceUUID;

-(void) storeAuthnStateConfig:(NSString*) authConfig rp:(NSString*)rp;
-(NSString*) readAuthnStateConfig:(NSString*)rp;

-(void) storeResidentKeyRecord:(NSString*)uname
						userid:(NSString*)userid
						 dname:(NSString*)dname
					  rpidhash:(NSString*)rpidhash
					  cridhash:(NSString*)cridhash
				   residentkey:(NSString*)residentkey
					   privkey:(NSString*)privkey;

-(NSString*) readResidentKeys:(NSString*)rpidHash;
-(NSString*) readResidentKeys:(NSString*)cridHash rpidHash:(NSString*)rpidHash;

-(void) userMessage:(NSString*)extra;
-(int) userAction:(NSString*)extra;

@optional

@end

#endif /* PLDataDelegate_h */
