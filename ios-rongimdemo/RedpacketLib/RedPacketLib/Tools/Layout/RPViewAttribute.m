//
//  MASAttribute.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "RPViewAttribute.h"

@implementation RPViewAttribute

- (id)initWithView:(UIView *)view layoutAttribute:(NSLayoutAttribute)layoutAttribute {
    self = [self initWithView:view item:view layoutAttribute:layoutAttribute];
    return self;
}

- (id)initWithView:(UIView *)view item:(id)item layoutAttribute:(NSLayoutAttribute)layoutAttribute {
    self = [super init];
    if (!self) return nil;
    
    _view = view;
    _item = item;
    _layoutAttribute = layoutAttribute;
    
    return self;
}

- (BOOL)isSizeAttribute {
    return self.layoutAttribute == NSLayoutAttributeWidth
        || self.layoutAttribute == NSLayoutAttributeHeight;
}

- (BOOL)isEqual:(RPViewAttribute *)viewAttribute {
    if ([viewAttribute isKindOfClass:self.class]) {
        return self.view == viewAttribute.view
            && self.layoutAttribute == viewAttribute.layoutAttribute;
    }
    return [super isEqual:viewAttribute];
}

- (NSUInteger)hash {
    return RP_NSUINTROTATE([self.view hash], RP_NSUINT_BIT / 2) ^ self.layoutAttribute;
}

@end
