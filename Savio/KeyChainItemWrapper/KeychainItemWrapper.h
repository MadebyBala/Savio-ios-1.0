#import <Foundation/Foundation.h>

@interface KeychainItemWrapper : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end