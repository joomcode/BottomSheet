//
//  JMMulticastDelegate.h
//  BottomSheet
//
//  Created by Mikhail Maslo on 16.02.2022.
//  Copyright © 2022 Joom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MulticastDelegate)
@interface JMMulticastDelegate : NSObject

- (instancetype)initWithTarget:(id)target
                delegateGetter:(SEL)delegateGetter
                delegateSetter:(SEL)delegateSetter NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)addDelegate:(id)delegate NS_SWIFT_NAME(addDelegate(_:));

- (void)removeDelegate:(id)delegate NS_SWIFT_NAME(removeDelegate(_:));

@end

NS_ASSUME_NONNULL_END
