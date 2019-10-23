//
//  ZCRouter.m
//  Kiwi
//
//  Created by Chuan on 2019/10/16.
//

#import "ZCRouter.h"

#import <objc/runtime.h>

@interface ZCRouter ()

@property (nonatomic, strong) NSMutableDictionary *routeDic;
@property (nonatomic, strong) NSMutableDictionary *propertyDic;

@end

@implementation ZCRouter

+ (void)load {
    [[self shared] getAllViewControllerClass];
}

+ (instancetype)shared {
    static ZCRouter* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZCRouter new];
        instance.routeDic = @{}.mutableCopy;
        instance.propertyDic = @{}.mutableCopy;
    });
    return instance;
}

+ (void)open:(NSString *)route {
    NSURL *url = [NSURL URLWithString:route];
    if (url.scheme) {
        NSURL *new = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        
        NSMutableDictionary *params = @{}.mutableCopy;
        NSArray *queries = [url.query componentsSeparatedByString:@"&"];
        for (NSString *query in queries) {
            NSArray *queryPair = [query componentsSeparatedByString:@"="];
            if (queryPair.count == 2) {
                params[queryPair[0]] = queryPair[1];
            }
        }
        
        [self open:new.absoluteString params:params];
    } else {
        [self open:route params:nil];
    }
}

+ (void)open:(NSString *)route params:(NSDictionary *)params {
    NSString *clsStr = [ZCRouter shared].routeDic[route];
    Class cls = NSClassFromString(clsStr);
    UIViewController<ZCRouter> *vc = [cls new];
    
    if (params && [ZCRouter shared].propertyDic[clsStr]) {
        NSArray *props = [ZCRouter shared].propertyDic[clsStr];
        for (NSString *key in params.allKeys) {
            NSArray *res = [props filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyName = %@", key]];
            if (res.count > 0 && res.firstObject[@"propertyType"]) {
                if ([params[key] isKindOfClass:NSClassFromString(res.firstObject[@"propertyType"])]) {
                    [vc setValue:params[key] forKey:key];
                }
            }
        }
    }
    
    if ([cls respondsToSelector:@selector(zc_usePresent)] && [cls performSelector:@selector(zc_usePresent)]) {
        [[self currentViewController] presentViewController:vc animated:YES completion:nil];
    } else {
        [[self currentViewController].navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Util
+ (UIViewController *)currentViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return [self topViewControllerWithRootViewController:window.rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:nav.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark - Private
- (void)getAllViewControllerClass {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int numClasses;
        Class *classes = NULL;
        numClasses = objc_getClassList(NULL,0);
        if (numClasses >0 ) {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (int i = 0; i < numClasses; i++) {
                Class cls = classes[i];
                while (class_getSuperclass(cls)) {
                    cls = class_getSuperclass(cls);
                }
                if (cls == [NSObject class] && [classes[i] conformsToProtocol:@protocol(ZCRouter)]){
                    if ([classes[i] respondsToSelector:@selector(zc_router)]) {
                        self.routeDic[[classes[i] performSelector:@selector(zc_router)]] = NSStringFromClass(classes[i]);
                        [self getClassPropertyList:classes[i]];
                    }
                }
            }
            free(classes);
        }
    });
}

- (void)getClassPropertyList:(Class)cls {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        NSMutableArray *properties = @[].mutableCopy;
        if (propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithCString:propName
                                                                encoding:[NSString defaultCStringEncoding]];
            NSString *propertyType = [NSString stringWithCString:propType
                                                                encoding:[NSString defaultCStringEncoding]];
            [properties addObject:@{@"propertyName": propertyName, @"propertyType": propertyType}];
        }
        self.propertyDic[NSStringFromClass(cls)] = properties;
    }
    free(properties);
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}

@end
