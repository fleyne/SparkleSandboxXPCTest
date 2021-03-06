//
//  SUUpdateXPC.m
//  SUUpdateXPC
//
//  Created by Fabrice Leyne on 3/31/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//
//New for XPC vs Sparkle 1.14

#import "SUUpdateXPC.h"
#import "SUFileManager.h"
#import "SUAppHash.h"

@implementation SUUpdateXPC

-(bool) isCopyLegitimate
{
    bool isLegitimate = YES;
    
    NSString* md5str = [SUAppHash hashAtPath:self.tempDir];
    
    if(!md5str) isLegitimate = NO;
    else if([self.hashTempDir length] == 0) isLegitimate = NO;
    else if([md5str length] == 0) isLegitimate = NO;
    else if(![md5str isEqualToString:self.hashTempDir]) isLegitimate = NO;
    
    return isLegitimate;
}


// Creates intermediate directories up until targetPath if they don't already exist,
// and removes the directory at targetPath if one already exists there
- (BOOL)preparePathForRelaunchTool:(NSString *)targetPath error:(NSError * __autoreleasing *)error
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:targetPath]) {
        NSError *removeError = nil;
        if (![fileManager removeItemAtPath:targetPath error:&removeError]) {
            if (error != NULL) {
                *error = removeError;
            }
            return NO;
        }
    } else {
        NSError *createDirectoryError = nil;
        if (![fileManager createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:@{} error:&createDirectoryError]) {
            if (error != NULL) {
                *error = createDirectoryError;
            }
            return NO;
        }
    }
    return YES;
}

- (void)unfoldDataToPerformedTheCopty:(NSDictionary*) dico
{
    if([dico objectForKey:@"sourceappurl"])
        [self setSourceappurl:[NSURL fileURLWithPath:[dico objectForKey:@"sourceappurl"]]];
    if([dico objectForKey:@"targetPath"])
        [self setTargetPath:[dico objectForKey:@"targetPath"]];
    if([dico objectForKey:@"sparkleBundleURL"])
        [self setSparkleBundle:[NSBundle bundleWithURL:[NSURL fileURLWithPath:[dico objectForKey:@"sparkleBundleURL"]]]];
    if([dico objectForKey:@"relaunchPathToCopy"])
        [self setRelaunchPathToCopy:[dico objectForKey:@"relaunchPathToCopy"]];
    if([dico objectForKey:@"relaunchPath"])
        [self setRelaunchPath:[dico objectForKey:@"relaunchPath"]];
    if([dico objectForKey:@"hostname"])
        [self setHostname:[dico objectForKey:@"hostname"]];
    if([dico objectForKey:@"hostbundlePath"])
        [self setHostbundlePath:[dico objectForKey:@"hostbundlePath"]];
    if([dico objectForKey:@"tempDir"])
        [self setTempDir:[dico objectForKey:@"tempDir"]];
    if([dico objectForKey:@"processIdentifierString"])
        [self setProcessIdentifierString:[dico objectForKey:@"processIdentifierString"]];
    if([dico objectForKey:@"hashTempDir"])
        [self setHashTempDir:[dico objectForKey:@"hashTempDir"]];
}

- (void)installWithToolAndRelaunch:(BOOL)relaunch displayingUserInterface:(BOOL)showUI withDataToPerformTheCopy:(NSDictionary*) dico  withReply:(void (^)(NSError *error))reply
{
    NSError* Error;
    
    [self unfoldDataToPerformedTheCopty:dico];
    
    if(![self isCopyLegitimate])
    {
        Error = [NSError errorWithDomain:SUSparkleErrorDomain code:SURelaunchError userInfo:@{
                                                                                              NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while extracting the archive. Please try again later.", nil),
                                                                                              NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Couldn't copy relauncher (%@) to temporary path (%@)! %@", self.relaunchPathToCopy, self.targetPath, @""]
                                                                                              }];
        reply(Error);
        return;
    }
    
    
    SUFileManager *fileManager = [SUFileManager fileManagerAllowingAuthorization:NO];
    NSError *error = nil;
    
    NSURL *relaunchURLToCopy = [NSURL fileURLWithPath:self.relaunchPathToCopy];
    NSURL *targetURL = [NSURL fileURLWithPath:self.targetPath];


    
    if ([self preparePathForRelaunchTool:self.targetPath error:&error] && [fileManager copyItemAtURL:relaunchURLToCopy toURL:targetURL error:&error]) {
        // We probably don't need to release the quarantine, but we'll do it just in case it's necessary.
        // Perhaps in a sandboxed environment this matters more. Note that this may not be a fatal error.
        NSError *quarantineError = nil;
        if (![fileManager releaseItemFromQuarantineAtRootURL:targetURL error:&quarantineError]) {
            NSLog(@"Failed to release quarantine on %@ with error %@", self.targetPath, quarantineError);
        }
        self.relaunchPath = self.targetPath;
    } else {
        Error = [NSError errorWithDomain:SUSparkleErrorDomain code:SURelaunchError userInfo:@{
                                                                                                                 NSLocalizedDescriptionKey: SULocalizedString(@"An error occurred while extracting the archive. Please try again later.", nil),
                                                                                                                 NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Couldn't copy relauncher (%@) to temporary path (%@)! %@", self.relaunchPathToCopy, self.targetPath, (error ? [error localizedDescription] : @"")]
                                                                                                                 }];
        
        reply(Error);
        return;        
    }
    
    
    NSString *relaunchToolPath = [[NSBundle bundleWithPath:self.relaunchPath] executablePath];
    if (!relaunchToolPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.relaunchPath]) {
        // Note that we explicitly use the host app's name here, since updating plugin for Mail relaunches Mail, not just the plugin.
        Error = [NSError errorWithDomain:SUSparkleErrorDomain code:SURelaunchError userInfo:@{
                                                                                                                 NSLocalizedDescriptionKey: [NSString stringWithFormat:SULocalizedString(@"An error occurred while relaunching %1$@, but the new version will be available next time you run %1$@.", nil), self.hostname],
                                                                                                                 NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Couldn't find the relauncher (expected to find it at %@)", self.relaunchPath]
                                                                                                                 }];
        // We intentionally don't abandon the update here so that the host won't initiate another.
        reply(Error);
        return;
    }
    
    
    NSString* md5str = [SUAppHash hashAtPath:self.tempDir];
    if(!md5str) md5str = @"";
    
    [NSTask launchedTaskWithLaunchPath:relaunchToolPath arguments:@[self.hostbundlePath,
                                                                    self.hostbundlePath,
                                                                    self.processIdentifierString,
                                                                    self.tempDir,
                                                                    md5str,
                                                                    relaunch ? @"1" : @"0",
                                                                    showUI ? @"1" : @"0"]];
    
    reply(Error);
}


@end
