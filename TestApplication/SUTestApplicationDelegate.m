//
//  SUTestApplicationDelegate.m
//  Sparkle
//
//  Created by Mayur Pawashe on 7/25/15.
//  Copyright (c) 2015 Sparkle Project. All rights reserved.
//

#import "SUTestApplicationDelegate.h"
#import "SUUpdateSettingsWindowController.h"
#import "SUFileManager.h"
#import "SUTestWebServer.h"

@interface SUTestApplicationDelegate ()

@property (nonatomic) SUUpdateSettingsWindowController *updateSettingsWindowController;
@property (nonatomic) SUTestWebServer *webServer;

@end

@implementation SUTestApplicationDelegate

@synthesize updateSettingsWindowController = _updateSettingsWindowController;
@synthesize webServer = _webServer;

static NSString * const UPDATED_VERSION = @"2.0";

- (void)applicationDidFinishLaunching:(NSNotification * __unused)notification
{
       // Show the Settings window
    self.updateSettingsWindowController = [[SUUpdateSettingsWindowController alloc] init];
    [self.updateSettingsWindowController showWindow:nil];        
}

- (void)applicationWillTerminate:(NSNotification * __unused)notification
{

}

@end
