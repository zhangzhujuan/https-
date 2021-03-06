//
//  GenerateRequestService.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "GenerateRequestService.h"

@implementation GenerateRequestService
#pragma mark - AIFServiceProtocal
- (BOOL)isOnline
{
    return YES;
}

- (NSString *)onlineApiBaseUrl
{
    return @"https://192.168.253.33:452/";
}

- (NSString *)onlineApiVersion
{
    return @"";
}

- (NSString *)onlinePrivateKey
{
    return @"";
}

- (NSString *)onlinePublicKey
{
    return @"";
}

- (NSString *)offlineApiBaseUrl
{
    return self.onlineApiBaseUrl;
}

- (NSString *)offlineApiVersion
{
    return self.onlineApiVersion;
}

- (NSString *)offlinePrivateKey
{
    return self.onlinePrivateKey;
}

- (NSString *)offlinePublicKey
{
    return self.onlinePublicKey;
}

- (NSDictionary *)cookis
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"];
    if (data == nil) {
        return nil;
    }
    NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in arcCookies){
        [cookieStorage setCookie: cookie];
    }
    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookies];
    return sheaders;
}

@end
