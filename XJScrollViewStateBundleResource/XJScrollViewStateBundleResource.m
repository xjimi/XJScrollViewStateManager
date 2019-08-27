//
//  XJScrollViewStateBundleResource.m
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/8/27.
//

#import "XJScrollViewStateBundleResource.h"

@implementation XJScrollViewStateBundleResource

+ (UIImage *)imageNamed:(NSString *)name {
    return [XJBundleResource imageNamed:name class:[self class] resource:@"XJScrollViewStateManager_resource_image"];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key
{
    return [XJBundleResource LocalizedStringWithKey:key class:[self class] resource:@"XJScrollViewStateManager_resource_localizable"];
}


@end
