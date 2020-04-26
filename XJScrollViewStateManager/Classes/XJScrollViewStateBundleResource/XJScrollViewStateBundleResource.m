//
//  XJScrollViewStateBundleResource.m
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/8/27.
//

#import "XJScrollViewStateBundleResource.h"

@implementation XJScrollViewStateBundleResource

+ (UIImage *)imageNamed:(NSString *)name {
    return [self imageNamed:name class:[self class] resource:@"XJScrollViewStateManager_resource_image"];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key
{
    return [self LocalizedStringWithKey:key class:[self class] resource:@"XJScrollViewStateManager_resource_localizable"];
}

+ (UIImage *)imageNamed:(NSString *)name class:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [self bundleForClass:class resource:resource];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key class:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [self bundleForClass:class resource:resource];
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

+ (NSBundle *)bundleForClass:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [NSBundle bundleForClass:class];
    NSString *resourcePath = [bundle pathForResource:resource ofType:@"bundle"];
    return [NSBundle bundleWithPath:resourcePath];
}

@end
