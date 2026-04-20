//
//  FWXPCServiceProtocol.h
//  filewatcher
//
//  Created by andr on 19.04.2026.
//

#import <Foundation/Foundation.h>

@protocol FWXPCServiceProtocol <NSObject>
@required
- (void)ping:( void (^)(NSString *))reply;
- (void)startWatching:(void (^)(void))reply;
- (void)stopWatching:(void (^)(void))reply;

@optional
@end

@protocol FWXPCClientProtocol <NSObject>
- (void)fileDidAppear:(NSString *)filePath;
- (void)fileDidDisappear:(NSString *)filePath;
@end
