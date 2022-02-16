//
//  JMMulticastDelegate.m
//  BottomSheet
//
//  Created by Mikhail Maslo on 16.02.2022.
//  Copyright © 2022 Joom. All rights reserved.
//

#define JMSuppressPerformSelectorLeakWarning(Code) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Code; \
        _Pragma("clang diagnostic pop") \
    } while (0)

#import "JMMulticastDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@implementation JMMulticastDelegate {
    __weak id _target;
    SEL _delegateGetter;
    SEL _delegateSetter;
    NSHashTable *_delegates;
    NSInteger _enumerationCounter;
}

- (instancetype)initWithTarget:(id)target
                delegateGetter:(SEL)delegateGetter
                delegateSetter:(SEL)delegateSetter {
    self = [super init];
    if (self) {
        _target = target;
        _delegateGetter = delegateGetter;
        _delegateSetter = delegateSetter;

        _delegates = [NSHashTable weakObjectsHashTable];

        [self addInitialDelegate];
        [self ensureMulticastingDelegateIsSet];
    }
    return self;
}

#pragma mark - Public

- (void)enumerateDelegatesUsingBlock:(void(^ NS_NOESCAPE)(id delegate, BOOL *stop))block {
    ++_enumerationCounter;

    BOOL stop = NO;
    for (id delegate in _delegates) {
        block(delegate, &stop);
        if (stop) {
            break;
        }
    }

    --_enumerationCounter;
}

#pragma mark - Private

- (void)addInitialDelegate {
    id delegate;
    JMSuppressPerformSelectorLeakWarning(
        delegate = [_target performSelector:_delegateGetter];
    );

    if (delegate) {
        [_delegates addObject:delegate];
    }
}

- (void)ensureMulticastingDelegateIsSet {
    [_target addObserver:self
              forKeyPath:NSStringFromSelector(_delegateGetter)
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                 context:nil];

    JMSuppressPerformSelectorLeakWarning([_target performSelector:_delegateSetter withObject:self]);
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(nullable void *)context {
    if (!keyPath || !object || !change) {
        return;
    }

    id newDelegate = change[NSKeyValueChangeNewKey];
    id oldDelegate = change[NSKeyValueChangeOldKey];
    if (newDelegate == oldDelegate || newDelegate == self) {
        return;
    }

    if (oldDelegate && oldDelegate != NSNull.null) {
        [self removeDelegate:oldDelegate];
    }
    if (newDelegate && newDelegate != NSNull.null) {
        [self addDelegate:newDelegate];
    }

    if (newDelegate && newDelegate != NSNull.null) {
        JMSuppressPerformSelectorLeakWarning([self->_target performSelector:self->_delegateSetter withObject:self]);
    }
}

- (void)ensureUIKitCacheUpdated {
    id strongTarget = _target;

    JMSuppressPerformSelectorLeakWarning([strongTarget performSelector:_delegateSetter withObject:nil]);
    JMSuppressPerformSelectorLeakWarning([strongTarget performSelector:_delegateSetter withObject:self]);
}

#pragma mark - MulticastingDelegate

- (void)addDelegate:(id)delegate {
    if (![_delegates containsObject:delegate]) {
        if (_enumerationCounter > 0) {
            _delegates = [_delegates copy];
        }

        [_delegates addObject:delegate];
        [self ensureUIKitCacheUpdated];
    }
}

- (void)removeDelegate:(id)delegate {
    if ([_delegates containsObject:delegate]) {
        if (_enumerationCounter > 0) {
            _delegates = [_delegates copy];
        }

        [_delegates removeObject:delegate];
        [self ensureUIKitCacheUpdated];
    }
}

#pragma mark - NSObject

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    __block BOOL result = NO;
    [self enumerateDelegatesUsingBlock:^(id delegate, BOOL *stop) {
        if ([delegate conformsToProtocol:aProtocol]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    __block BOOL result = NO;
    [self enumerateDelegatesUsingBlock:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:aSelector]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self enumerateDelegatesUsingBlock:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    __block NSMethodSignature *signature = nil;
    [self enumerateDelegatesUsingBlock:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:selector]) {
            signature = [delegate methodSignatureForSelector:selector];
            *stop = YES;
        }
    }];
    return signature ?: [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

@end

NS_ASSUME_NONNULL_END
