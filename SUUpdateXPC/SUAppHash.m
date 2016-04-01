//
//  SUAppHash.m
//  filehashofapp
//
//  Created by Fabrice Leyne on 4/1/16.
//  Copyright © 2016 seense. All rights reserved.
//

#import "SUAppHash.h"

@implementation SUAppHash


+(NSString*) hashAtPath:(NSString*) applicationPath
{
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExistsAtPath = [fileManager fileExistsAtPath:applicationPath isDirectory:&isDirectory];
    if (fileExistsAtPath) {
        if (isDirectory)
        {
            return [self hashForFolderAtPath:applicationPath];
        }
        else
        {
            return [self hashForFileAtPath:applicationPath];
        }
    }
    
    return nil;
}

+(NSString*) hashForFolderAtPath:(NSString*) applicationPath
{
    NSString *executableFileMD5Hash = @"";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL fileURLWithPath:applicationPath];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {            
            NSString* filehash = nil;
            filehash = [self hashForFileAtPath:[url path]];
            if(filehash)
                executableFileMD5Hash = [executableFileMD5Hash stringByAppendingString:filehash];
            
        }
    }
    
    if([executableFileMD5Hash length] == 0) return nil;
    
    return [self md5HexDigest:executableFileMD5Hash];
}

+(NSString*) hashForFileAtPath:(NSString*) applicationPath
{
    NSString *executableFileMD5Hash = [FileHash md5HashOfFileAtPath:applicationPath];
    return executableFileMD5Hash;
}

+ (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
