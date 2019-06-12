//
//  UIImage+XJPodsResources.m
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/6/12.
//

#import "UIImage+XJPodsResources.h"
#import "NSBundle+XJPodsResources.h"

@implementation UIImage (XJPodsResources)

+ (UIImage *)xj_podsImageNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle xj_podsBundleWithResource:@"resource_image"];
    return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
