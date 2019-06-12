//
//  NSString+XJPodsResources.m
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/6/12.
//

#import "NSString+XJPodsResources.h"
#import "NSBundle+XJPodsResources.h"

@implementation NSString (XJPodsResources)

+ (NSString *)xj_podsLocalizedKey:(NSString *)key
{
    NSBundle *bundle = [NSBundle xj_podsBundleWithResource:@"resource_localizable"];
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

@end
