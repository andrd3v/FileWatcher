//
//  main.m
//  filewatcherclient
//
//  Created by andr on 20.04.2026.
//

#import <Foundation/Foundation.h>

@protocol FWXPCServiceProtocol <NSObject>
-(void)ping:(void (^)(NSString *))reply;
- (void)startWatching:(void (^)(void))reply;
- (void)stopWatching:(void (^)(void))reply;
@end

@protocol FWXPCClientProtocol <NSObject>
- (void)fileDidAppear:(NSString *)filePath;
- (void)fileDidDisappear:(NSString *)filePath;
@end

@interface FWXPCClient : NSObject <FWXPCClientProtocol>
- (void)fileDidAppear:(NSString *)filePath;
- (void)fileDidDisappear:(NSString *)filePath;
@end

@implementation FWXPCClient

- (void)fileDidAppear:(NSString *)filePath
{
    NSLog(@"%@", filePath);
}

- (void)fileDidDisappear:(NSString *)filePath
{
    NSLog(@"%@", filePath);
}

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSXPCConnection *connection = [[NSXPCConnection alloc] initWithMachServiceName:@"com.andrd3v.filewatcher" options:0];
        connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FWXPCServiceProtocol)];
        connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FWXPCClientProtocol)];
        connection.exportedObject = [FWXPCClient new];
        [connection resume];

        id <FWXPCServiceProtocol> proxy = [connection remoteObjectProxy];

        [proxy ping:^(NSString *reply) {
            NSLog(@"%@", reply);
        }];
        
        [proxy startWatching:^{
            NSLog(@"start watching");
        }];
        
        dispatch_main();
    }
    return EXIT_SUCCESS;
}
