//
//  NSBundle+XJPodsResources.h
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (XJPodsResources)

+ (NSBundle *)xj_podsBundle;

+ (NSBundle *)xj_podsBundleWithResource:(nullable NSString *)resource;

+ (NSString *)xj_podsBundlePathWithResource:(nullable NSString *)resource;

@end

NS_ASSUME_NONNULL_END
