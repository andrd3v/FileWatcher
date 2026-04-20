//
//  main.m
//  filewatcher
//
//  Created by andr on 19.04.2026.
//

#import <Foundation/Foundation.h>
#import "FWXPCService.h"
#import "ServiceDelegate.h"
#import <CoreServices/CoreServices.h>

void fsEventsCallback(
    ConstFSEventStreamRef streamRef,
    void *clientCallBackInfo,
    size_t numEvents,
    void *eventPaths,
    const FSEventStreamEventFlags eventFlags[],
    const FSEventStreamEventId eventIds[])
{
    ServiceDelegate *delegate = (__bridge ServiceDelegate*)clientCallBackInfo;
    NSArray *paths = (__bridge NSArray*)eventPaths;
    
    for (size_t i = 0; i < numEvents; i++)
    {
        NSString *path = paths[i];
        FSEventStreamEventFlags flags = eventFlags[i];
        
        for (NSXPCConnection *conn in delegate.connections)
        {
            id <FWXPCClientProtocol> proxy = [conn remoteObjectProxy];
            if (flags & kFSEventStreamEventFlagItemCreated) [proxy fileDidAppear:path];
            if (flags & kFSEventStreamEventFlagItemRemoved) [proxy fileDidDisappear:path];
        }
    }
}

@implementation ServiceDelegate

- (instancetype)init
{
    self = [super init];
    if (self) { self.connections = [NSMutableArray new]; }
    return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    [self.connections addObject:newConnection];
    __weak typeof(self) weakSelf = self;
    __weak typeof(newConnection) weakConnection = newConnection;
    newConnection.invalidationHandler = ^{
        [weakSelf.connections removeObject:weakConnection];
    };
    
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FWXPCServiceProtocol)];
    FWXPCService *service = [FWXPCService new];
    service.delegate = self;
    newConnection.exportedObject = service;
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FWXPCClientProtocol)];
    
    [newConnection resume];
    return YES;
}

- (void)startMonitoring
{
    if (self.stream) return;
    
    FSEventStreamContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
    NSString *desktopPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    
    self.stream = FSEventStreamCreate(NULL, fsEventsCallback, &context, (__bridge CFArrayRef)@[desktopPath], kFSEventStreamEventIdSinceNow, 0.5, kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes);
    
    FSEventStreamSetDispatchQueue(self.stream, dispatch_get_main_queue());
    FSEventStreamStart(self.stream);
    NSLog(@"startMonitoring called");
}

- (void)stopMonitoring
{
    if (!self.stream) return;
    FSEventStreamStop(self.stream);
    FSEventStreamInvalidate(self.stream);
    FSEventStreamRelease(self.stream);
    self.stream = NULL;
}

@end


int main(int argc, const char *argv[])
{
    static ServiceDelegate *delegate;
    delegate = [[ServiceDelegate alloc] init];
    
    NSXPCListener *listener = [[NSXPCListener alloc]  initWithMachServiceName:@"com.andrd3v.filewatcher"];
    listener.delegate = delegate;
    
    [listener resume];
    
    dispatch_main();
    return 0;
}
