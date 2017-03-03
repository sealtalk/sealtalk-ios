//
//  MASUtilities.h
//  Masonry
//
//  Created by Jonas Budelmann on 19/08/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const UILayoutPriority UILayoutPriorityDefaultMedium = 500;

/**
 *  Used to create object hashes
 *  Based on http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
 */
#define RP_NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define RP_NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (RP_NSUINT_BIT - howmuch)))


