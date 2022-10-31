//
//  QRProxyDelegate.h
//

#ifndef QRProxyDelegate_h
#define QRProxyDelegate_h

@protocol QRProxyDelegate <NSObject>
-(void)getQRProxyResponse:(NSString*)data sel:(SEL)selector;
@end

#endif /* QRProxyDelegate_h */
