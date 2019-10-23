//
//  ZCRouter.h
//  Kiwi
//
//  Created by Chuan on 2019/10/16.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCRouter

+ (NSString *)zc_router;
@optional
+ (BOOL)zc_usePresent;

@end

@interface ZCRouter : NSObject

+ (void)open:(NSString *)route;

+ (void)open:(NSString *)route params:(nullable NSDictionary *)params;

+ (UIViewController *)currentViewController;

@end

NS_ASSUME_NONNULL_END
