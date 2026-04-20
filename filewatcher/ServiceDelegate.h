//
//  ServiceDelegate.h
//  filewatcher
//
//  Created by andr on 20.04.2026.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@property (nonatomic, strong) NSMutableArray<NSXPCConnection *> *connections;
@property (nonatomic) FSEventStreamRef stream;

- (void)startMonitoring;
- (void)stopMonitoring;
@end
