//
//  NSString+Utils.m
//  Dashboard
//
//  Created by Joel Oliveira on 14/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)


- (NSString *)uuidToString:(CFUUIDRef)uuid {
    NSString *retval = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    return retval;
}

- (NSString *)hex2dec:(NSString *)hex {
    unsigned int ibmajor;
    NSScanner* scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&ibmajor];
    NSString *dec_string = [[NSString alloc] initWithFormat:@"%u", ibmajor];
    return dec_string;
}

- (NSString *)hex2dec_min256:(NSString *)hex {
    unsigned int ibmajor;
    NSScanner* scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&ibmajor];
    NSString *dec_string = [[NSString alloc] initWithFormat:@"%u", (256 - ibmajor)];
    return dec_string;
}


- (NSString *)prettyNumber:(int)number {
    
    NSString * str = [NSString stringWithFormat:@"%i",number];
    
    if(number > 1000){
        str = [NSString stringWithFormat:@"%ik",number/1000];
    }
    
    if(number > 1000000){
        str = [NSString stringWithFormat:@"%im",number/1000000];
    }
    
    if(number > 1000000000){
        str = [NSString stringWithFormat:@"%ib",number/1000000000];
    }
    
    
    return str;
}


- (NSString *)prettyBytes:(int)number {
    
    NSString * str = [NSString stringWithFormat:@"%i Bytes",number];

    if(number == 0) return str;
    
    NSArray * sizes = @[@"Bytes", @"KB", @"MB", @"GB", @"TB"];
    
    int i = floor(log(number) / log(1024));
    number = number / pow(1024, i);
    
    str = [NSString stringWithFormat:@"%i%@", number, sizes[i]];

    return str;
}


-(NSString *)formatNameMonth:(int)month{
    switch (month) {
        case 1:
            return @"Jan";
            break;
        case 2:
            return @"Feb";
            break;
        case 3:
            return @"Mar";
            break;
        case 4:
            return @"Apr";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"Jun";
            break;
        case 7:
            return @"Jul";
            break;
        case 8:
            return @"Aug";
            break;
        case 9:
            return @"Sep";
            break;
        case 10:
            return @"Oct";
            break;
        case 11:
            return @"Nov";
            break;
        case 12:
            return @"Dec";
            break;
        default:
            break;
    }
    
    return @"";
}

@end
