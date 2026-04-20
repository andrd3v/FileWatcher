//
//  FWXPCService.h
//  filewatcher
//
//  Created by andr on 19.04.2026.
//

#import <Foundation/Foundation.h>
#import "FWXPCServiceProtocol.h"
#import "ServiceDelegate.h"

@interface FWXPCService : NSObject <FWXPCServiceProtocol>
@property (nonatomic, weak) ServiceDelegate *delegate;

- (void)ping:(void (^)(NSString *))reply;
- (void)startWatching:(void (^)(void))reply;
- (void)stopWatching:(void (^)(void))reply;
@end
