//
//  NSString+Utils.h
//  Dashboard
//
//  Created by Joel Oliveira on 14/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSString *)uuidToString:(CFUUIDRef)uuid;

- (NSString *)hex2dec:(NSString *)hex;

- (NSString *)hex2dec_min256:(NSString *)hex;

- (NSString *)prettyNumber:(int)number;

- (NSString *)prettyBytes:(int)number;

-(NSString *)formatNameMonth:(int)month;

@end
