//
//  SUAppHash.h
//  filehashofapp
//
//  Created by Fabrice Leyne on 4/1/16.
//  Copyright © 2016 seense. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileHash.h"

@interface SUAppHash : NSObject


+(NSString*) hashAtPath:(NSString*) applicationPath;


@end
