//
//  RYRequestGenerator.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYRequestGenerator.h"
#import "AFNetworking.h"
#import "RYBaseAPICmd.h"
#import "RYServiceFactory.h"
#import "RYAPILogger.h"
#import "NSURLRequest+RYNetworkingMethods.h"

@interface RYRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation RYRequestGenerator
#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYRequestGenerator alloc] init];
    });
    return sharedInstance; 
}

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"GET";
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [RYAPILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"GET"];
    return request;
}
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:NULL];
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [RYAPILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"POST"];
    return request;
}

- (NSMutableURLRequest *)generateUploadRequestWithRequestParams:(id)requestParams url:(NSString *)url fileURL:(NSString *)fileURL mimeType:(NSString *)mimeType suffixName:(NSString *)suffixName serviceIdentifier:(NSString *)serviceIdentifier{
    
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //suffixName 需要后缀名，否则服务器无法识别
        [formData appendPartWithFileData:[NSData dataWithContentsOfFile:fileURL] name:@"file" fileName:[NSString stringWithFormat:@"fileName.%@",suffixName] mimeType:mimeType];
        
    } error:nil];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    
    return request;
}

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}

- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:url parameters:requestParams error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}
#pragma mark - private methods

/**
 *  设置请求头
 *
 *  @param service RYService
 *
 *  @return NSDictionary
 */

- (NSDictionary *)commRESTHeadersWithService:(RYService *)service
{
    NSMutableDictionary *headerDic = [[NSMutableDictionary alloc] init];
    
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    
    return headerDic;
}

/**
 *  设置Cookies
 *
 *  @param service RYService
 */

- (void)commSETCookiesWithService:(RYService *)service {
    
}

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
