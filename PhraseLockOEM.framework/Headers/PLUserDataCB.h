#ifndef PLUserDataCB_h
#define PLUserDataCB_h

@protocol PLUserDataCB

@required

-(NSString*) getAAGUID;

-(NSData*) getCoreDataForServiceUUID:(NSString*) serviceUUID;

-(void) storeAuthnStateConfig:(NSString*) authConfig rp1:(NSString*)rp1 rp2:(NSString*)rp2;
-(NSString*) readAuthnStateConfig:(NSString*)rp1 rp2:(NSString*)rp2;

-(void) storeResidentKeyRecord:(NSString*)rp1
                           rp2:(NSString*)rp2
                    credDomain:(NSString*)credDomain
                      credName:(NSString*)credName
                         uname:(NSString*)uname
                        userid:(NSString*)userid
                         dname:(NSString*)dname
                      rpidhash:(NSString*)rpidhash
                      cridhash:(NSString*)cridhash
                   residentkey:(NSString*)residentkey
                       privkey:(NSString*)privkey;

-(NSString*) readResidentKeys:(NSString*)rp1
                          rp2:(NSString*)rp2
                     rpidHash:(NSString*)rpidHash;

-(NSString*) readResidentKeys:(NSString*)rp1
                          rp2:(NSString*)rp2
                     cridHash:(NSString*)cridHash
                     rpidHash:(NSString*)rpidHash;

-(void) userMessage:(NSString*)extra;
-(int) userAction:(NSString*)extra;

@optional

@end

#endif /* PLDataDelegate_h */
