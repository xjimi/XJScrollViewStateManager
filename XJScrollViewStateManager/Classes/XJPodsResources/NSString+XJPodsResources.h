//
//  NSString+XJPodsResources.h
//  XJScrollViewStateManager
//
//  Created by XJIMI on 2019/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LNoContentYet           [NSString xj_podsLocalizedKey:@"LNoContentYet"]
#define LNetworkError           [NSString xj_podsLocalizedKey:@"LNetworkError"]
#define LLoading                [NSString xj_podsLocalizedKey:@"LLoading"]


@interface NSString (XJPodsResources)

+ (NSString *)xj_podsLocalizedKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
