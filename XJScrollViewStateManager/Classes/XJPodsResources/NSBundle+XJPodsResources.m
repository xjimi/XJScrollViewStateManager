//
//  NSBundle+XJPodsResources.m
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/6/12.
//

#import "NSBundle+XJPodsResources.h"
#import "XJScrollViewStateManager.h"

@implementation NSBundle (XJPodsResources)

+ (NSBundle *)xj_podsBundle {
    return [self xj_podsBundleWithResource:nil];
}

+ (NSBundle *)xj_podsBundleWithResource:(nullable NSString *)resource {
    return [self bundleWithPath:[self xj_podsBundlePathWithResource:resource]];
}

+ (NSString *)xj_podsBundlePathWithResource:(nullable NSString *)resource
{
    Class class = [XJScrollViewStateManager class];
    resource = resource ? : NSStringFromClass(class);
    return [[NSBundle bundleForClass:class] pathForResource:resource ofType:@"bundle"];
}

@end
