//
//  SUUpdateXPC.h
//  SUUpdateXPC
//
//  Created by Fabrice Leyne on 3/31/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//
//New for XPC vs Sparkle 1.14

#import <Foundation/Foundation.h>
#import "SUUpdateXPCProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface SUUpdateXPC : NSObject <SUUpdateXPCProtocol>

@property(nonatomic, strong) NSURL* sourceappurl;
@property(nonatomic, strong) NSString* targetPath;
@property(nonatomic, strong) NSBundle* sparkleBundle;
@property(nonatomic, strong) NSString *const relaunchPathToCopy;
@property(nonatomic, strong) NSString* relaunchPath;
@property(nonatomic, strong) NSString* hostname;
@property(nonatomic, strong) NSString* hostbundlePath;
@property(nonatomic, strong) NSString* tempDir;
@property(nonatomic, strong) NSString* hashTempDir;
@property(nonatomic, strong) NSString* processIdentifierString;

@end
