//
//  SUSandboxUpdate.h
//  Sparkle
//
//  Created by Fabrice Leyne on 3/31/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//
//New for XPC vs Sparkle 1.14

#import <Foundation/Foundation.h>
#import "SUUpdateXPCProtocol.h"

@interface SUSandboxUpdate : NSObject

@property (nonatomic, strong) NSXPCConnection *connection;
@property(nonatomic, strong) NSURL* sourceappurl;
@property(nonatomic, strong) NSString* targetPath;
@property(nonatomic, strong) NSBundle* sparkleBundle;
@property(nonatomic, strong) NSString* relaunchPathToCopy;
@property(nonatomic, strong) NSString* relaunchPath;
@property(nonatomic, strong) NSString* hostname;
@property(nonatomic, strong) NSString* hostbundlePath;
@property(nonatomic, strong) NSString* tempDir;
@property(nonatomic, strong) NSString* processIdentifierString;
@property(nonatomic, assign) id delegate;
- (void)installWithToolAndRelaunch:(BOOL)relaunch displayingUserInterface:(BOOL)showUI;

@end
