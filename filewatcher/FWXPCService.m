//
//  FWXPCService.m
//  filewatcher
//
//  Created by andr on 19.04.2026.
//

#import "FWXPCService.h"

@implementation FWXPCService

- (void)ping:(void (^)(NSString *))reply
{
    NSString *echo = @"echo";
    reply(echo);
}

- (void)startWatching:(void (^)(void))reply
{
    [self.delegate startMonitoring];
    reply();
}


- (void)stopWatching:(void (^)(void))reply
{
    [self.delegate stopMonitoring];
    reply();
}

@end
