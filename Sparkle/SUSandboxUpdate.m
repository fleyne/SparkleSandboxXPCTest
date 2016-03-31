//
//  SUSandboxUpdate.m
//  Sparkle
//
//  Created by Fabrice Leyne on 3/31/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//
//New for XPC vs Sparkle 1.14

#import "SUSandboxUpdate.h"
#define machServiceName @"org.sparkle-project.Sparkle.SUUpdateXPC"

@implementation SUSandboxUpdate


-(void) startConnection
{
    self.connection = [[NSXPCConnection alloc] initWithServiceName:machServiceName];
    self.connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SUUpdateXPCProtocol)];
    [self.connection resume];
}


-(void)installWithToolAndRelaunch:(BOOL)relaunch displayingUserInterface:(BOOL)showUI
{    
    [self startConnection];
    
    [self.connection.remoteObjectProxy installWithToolAndRelaunch:relaunch displayingUserInterface:showUI withDataToPerformTheCopy:[self dicoToTransfer] withReply:^(NSError *error){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (error)
            {
                [self.delegate performSelector:@selector(abortUpdateWithError:) withObject:error];
                [self.connection invalidate];
                return;
            }
        }];
        
            [self.connection invalidate];
            [self.delegate performSelector:@selector(terminateApp) withObject:nil];
        }];
}


-(NSDictionary*) dicoToTransfer
{
    NSMutableDictionary* dico = [[NSMutableDictionary alloc] init];
    
    if(self.sourceappurl)
        [dico setObject:self.sourceappurl.absoluteString forKey:@"sourceappurl"];
    if(self.targetPath)
        [dico setObject:self.targetPath forKey:@"targetPath"];
    if(self.sparkleBundle)
        [dico setObject:self.sparkleBundle.bundleURL.absoluteString forKey:@"sparkleBundleURL"];
    if(self.relaunchPathToCopy)
        [dico setObject:self.relaunchPathToCopy forKey:@"relaunchPathToCopy"];
    if(self.relaunchPath)
        [dico setObject:self.relaunchPath forKey:@"relaunchPath"];
    if(self.hostname)
        [dico setObject:self.hostname forKey:@"hostname"];
    if(self.hostbundlePath)
        [dico setObject:self.hostbundlePath forKey:@"hostbundlePath"];
    if(self.tempDir)
        [dico setObject:self.tempDir forKey:@"tempDir"];
    if(self.processIdentifierString)
        [dico setObject:self.processIdentifierString forKey:@"processIdentifierString"];
    
        
    return [[NSDictionary alloc] initWithDictionary:dico];
}



@end
