//
//  Glimworm.m
//  Dashboard
//
//  Created by Joel Oliveira on 15/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "Glimworm.h"
#import "NSString+Utils.h"

@implementation Glimworm {
    BOOL isUpdating;
}


-(id)init{
    
    if (self = [super init]) {

        //[[self centralManager] setDelegate:self];
        [self setCommandQueue:[NSMutableArray array]];
        
        isUpdating = NO;
    }
    
    return self;
}


-(void)connectToBeacon:(BluetoothLEBeacon *)beacon{
    
    [self setBeacon:beacon];
    [self setPeripheral:[beacon peripheral]];
    [[self peripheral] setDelegate:self];
    
    [[self centralManager] connectPeripheral:[self peripheral]
                                                  options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
                                                            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @NO,
                                                            CBConnectPeripheralOptionNotifyOnNotificationKey: @NO}];
    
}


-(void)updateBeacon:(BluetoothLEBeacon *)beacon{
    
    [[self commandQueue] removeAllObjects];
    
    [self setBeacon:beacon];
    
    isUpdating = YES;

    NSString * major = [[NSString alloc] initWithFormat:@"%04X", [[beacon major] intValue]];
    NSString * minor = [[NSString alloc] initWithFormat:@"%04X", [[beacon minor] intValue]];
    
    NSString * bMajor = [[NSString alloc] initWithFormat:@"AT+MARJ0x%@%@",
                             [major substringWithRange:NSMakeRange(0,2)],
                             [major substringWithRange:NSMakeRange(2,2)]];
    
    [[self commandQueue] addObject:@{@"command":bMajor}];
    
    NSString * bMinor = [[NSString alloc] initWithFormat:@"AT+MINO0x%@%@",
                             [minor substringWithRange:NSMakeRange(0,2)],
                             [minor substringWithRange:NSMakeRange(2,2)]];
    
    [[self commandQueue] addObject:@{@"command":bMinor}];
    
    NSString * bAdvertisementRate = [NSString stringWithFormat:@"AT+ADVI%@",[self advertisementRate:[beacon beaconAdvertisingRate]]];
    
    //[[self commandQueue] addObject:@{@"command":bAdvertisementRate}];
    
    NSString * bRange = [NSString stringWithFormat:@"AT+POWE%@",[NSString stringWithFormat:@"%i",[beacon beaconRange]]];
    
    //[[self commandQueue] addObject:@{@"command":bRange}];

    if ([self isCapableOfSettingModes]) {
        NSString * bMode = [NSString stringWithFormat:@"AT+ADTY%@",[NSString stringWithFormat:@"%i", [self modeSetting:[beacon beaconMode]]]];
        //[[self commandQueue] addObject:@{@"command":bMode}];
    }
    
    /*
     * @TODO:
     */
//    NSString * sRange = @"GB+SRANGE";
//    NSString * stopSleepMode = @"AT+PWRM1";
//    NSString * showBattery = @"AT+BATC1";
//    
//    if ([beacon beaconRange] == 2) {
//        sRange = nil;
//        stopSleepMode = nil;
//    }
//    
//    if ([self isFirstBeaconType]) {
//        if ([[beacon beaconDate] longLongValue] < 1406451969) {
//            sRange = nil;
//            stopSleepMode = nil;
//        } else {
//            showBattery = @"AT+BATC0";
//        }
//    } else {
//        sRange = nil;
//        stopSleepMode = nil;
//        showBattery = @"AT+BATC0";
//    }
//    
//    if ([self isCapableOfSettingBatteryLevel]) {
//        showBattery = [NSString stringWithFormat:@"AT+BATC%@",[NSString stringWithFormat:@"%i",[beacon beaconBatteryLevel]]];
//    }
//
//    NSString * power = nil;
//    switch ([beacon beaconRange]) {
//        case 0:
//            power = @"AT+MEAAE";
//            break;
//        case 1:
//            power = @"AT+MEAB8";
//            break;
//        case 2:
//            power = @"AT+MEAC0";
//            break;
//        case 3:
//            power = @"AT+MEAC5";
//            break;
//        default:
//            break;
//    }
//
//    if(sRange){
//        [[self commandQueue] addObject:@{@"command":sRange}];
//    }
//    
//    if(showBattery){
//        [[self commandQueue] addObject:@{@"command":showBattery}];
//    }
//    
//    if(power){
//        [[self commandQueue] addObject:@{@"command":power}];
//    }
//    
//    if(stopSleepMode){
//        [[self commandQueue] addObject:@{@"command":stopSleepMode}];
//    }
//    
    
    NSString * bName = [[NSString alloc] initWithFormat:@"AT+NAME%@",
                          ([[beacon name] length] > 11 ) ? [[[beacon name] uppercaseString] substringWithRange:NSMakeRange(0, 11)] : [[beacon name] uppercaseString]];
    
    //[[self commandQueue] addObject:@{@"command":bName}];
    
//    NSString *pass0 = nil;
//    NSString *pass1 = nil;
//    NSString *pass2 = nil;
//    
//    if ([[beacon beaconPincode] length] > 5) {
//        pass0 = @"AT+TYPE0";
//        pass1 = [NSString stringWithFormat:@"AT+PASS%@",[beacon beaconPincode]];
//        pass2 = @"AT+TYPE2";
//    } else if ([[beacon beaconPincode] length] == 0) {
//        pass0 = @"AT+TYPE0";
//    }
//    
//    if(pass0){
//        [[self commandQueue] addObject:@{@"command":pass0}];
//    }
//    if(pass1){
//        [[self commandQueue] addObject:@{@"command":pass1}];
//    }
//    if(pass2){
//        [[self commandQueue] addObject:@{@"command":pass2}];
//    }
    
    
    if ([[beacon uuid] length] == 36) {
        
        NSString * ib0 = [NSString stringWithFormat:@"AT+IBE0%@",
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(0, 8)]
                         ];
        
        NSString * ib1 = [NSString stringWithFormat:@"AT+IBE1%@%@",
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(9, 4)],
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(14, 4)]
                         ];
        
        NSString * ib2 = [NSString stringWithFormat:@"AT+IBE2%@%@",
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(19, 4)],
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(24, 4)]
                         ];
        
        NSString * ib3 = [NSString stringWithFormat:@"AT+IBE3%@",
                         [[[beacon uuid] uppercaseString] substringWithRange:NSMakeRange(28, 8)]
                         ];
        
        if(ib0){
            [[self commandQueue] addObject:@{@"command":ib0}];
        }
        if(ib1){
            [[self commandQueue] addObject:@{@"command":ib1}];
        }
        if(ib2){
            [[self commandQueue] addObject:@{@"command":ib2}];
        }
        if(ib3){
            [[self commandQueue] addObject:@{@"command":ib3}];
        }

    }
    
    [self handleQueueOfCharacteristics];
}

-(void)closeConnectionToBeacon:(BluetoothLEBeacon *)beacon{
    
    if([beacon peripheral]){
        
        if([[beacon peripheral] state] == CBPeripheralStateConnected){
            
            if([[self commandQueue] count] > 0){
                [[beacon peripheral] setNotifyValue:NO forCharacteristic:[self currentCharacteristic]];
            }
            
            [[self centralManager] cancelPeripheralConnection:[[self beacon] peripheral]];
            [[self commandQueue] removeAllObjects];
        } else {
            [[self centralManager] cancelPeripheralConnection:[[self beacon] peripheral]];
            [[self commandQueue] removeAllObjects];
        }
    }
}


-(void)discoverServicesForPeripheral:(CBPeripheral *)peripheral{
    
    [[self beacon] setPeripheral:peripheral];
    [self setPeripheral:peripheral];
    [[self peripheral] setDelegate:self];
    
    [peripheral discoverServices:nil];
    
}

-(void)handleCharacteristic:(CBCharacteristic *)characteristic{
    
    [self setCurrentCharacteristic:characteristic];
    
    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"GB+BTYPE"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"GB+PDATE"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+VERS?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+BATT?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+BATC?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+ADVI?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+POWE?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+MEA??"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+ADTY?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+PASS?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+MARJ?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+MINO?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+IBE0?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+IBE1?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+IBE2?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+IBE3?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+TYPE?"]}];

    [[self commandQueue] addObject:@{@"command":[NSString stringWithFormat:@"AT+NAME?"]}];
    
    [self handleQueueOfCharacteristics];
    
}

-(void)handleQueueOfCharacteristics{
    
    if([[self commandQueue] count] > 0){
        
        NSDictionary * command = [[self commandQueue] firstObject];
        [[self commandQueue] removeObjectAtIndex:0];
        [self setCurrentCommand:[command objectForKey:@"command"]];
        
        NSData *data = [[command objectForKey:@"command"] dataUsingEncoding:[NSString defaultCStringEncoding]];
        [[self peripheral] writeValue:data forCharacteristic:[self currentCharacteristic]  type:CBCharacteristicWriteWithoutResponse];

    } else {
        
        if(isUpdating){
            if([[self delegate] respondsToSelector:@selector(glimworm:didUpdateBeacon:)]){
                [[self delegate] glimworm:self didUpdateBeacon:[self beacon]];
                isUpdating = NO;
                [self closeConnectionToBeacon:[self beacon]];
            }
        } else {
            if([[self delegate] respondsToSelector:@selector(glimworm:didConnectToBeacon:)]){
                [[self delegate] glimworm:self didConnectToBeacon:[self beacon]];
            }
        }

    }

}




#pragma Helper methods
- (BOOL)has16AdvertisementRates{
    if ([[[self beacon] beaconVersion] isEqualToString:@"V517"]) return FALSE;
    if ([[[self beacon] beaconVersion] isEqualToString:@"V518"]) return FALSE;
    if ([[[self beacon] beaconVersion] isEqualToString:@"V519"]) return FALSE;
    if ([[[self beacon] beaconVersion] isEqualToString:@"V520"]) return FALSE;
    if ([[[self beacon] beaconVersion] isEqualToString:@"V521"]) return FALSE;
    if ([[[self beacon] beaconVersion] isEqualToString:@"V522"]) return FALSE;
    return TRUE;
}


- (BOOL)isUSBBeacon {
    if ([[[self beacon] beaconType] isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}
- (BOOL)isFirstBeaconType {
    if ([[[self beacon] beaconType] isEqualToString:@"000100010001"]) return TRUE;
    return FALSE;
}
- (BOOL)isCapableOfSettingModes {
    if ([[[self beacon] beaconType] isEqualToString:@"000100020001"]) return TRUE;
    if ([[[self beacon] beaconType] isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}
- (BOOL)isCapableOfSettingBatteryLevel {
    if ([[[self beacon] beaconType] isEqualToString:@"000100020001"]) return TRUE;
    if ([[[self beacon] beaconType] isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}

/**
 * Helper method to check if string is a valid UUID
 */
-(BOOL)isUUID:(NSString *)str{
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    
    NSUInteger matches = [regex numberOfMatchesInString:[str lowercaseString] options:0 range:NSMakeRange(0, [str length])];
    
    if(matches == 1){

        return TRUE;
    } else {

        return FALSE;
    }
}

#pragma CoreBluetooth delegates

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)manager{
    
    switch ([manager state]) {
        case CBPeripheralManagerStatePoweredOn:
            
            if([[self delegate] respondsToSelector:@selector(glimworm:didPowerOn:)]){
                [[self delegate] glimworm:self didPowerOn:[self beacon]];
            }
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            
            //
            if([[self delegate] respondsToSelector:@selector(glimworm:didPowerOff:)]){
                [[self delegate] glimworm:self didPowerOff:[self beacon]];
            }
            
            break;
        default:
            break;
    }
}


-(NSString *)advertisementRate:(int)rate{
    switch (rate) {
        case 10:
            return @"A";
            break;
        case 11:
            return @"B";
            break;
        case 12:
            return @"C";
            break;
        case 13:
            return @"D";
            break;
        case 14:
            return @"E";
            break;
        case 15:
            return @"F";
            break;
        default:
            return [NSString stringWithFormat:@"%i",rate];
            break;
    }
}


-(int)modeSetting:(int)mode{
    switch (mode) {
        case 0:
            return 0;
            break;

        default:
            return 2;
            break;
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
   
    for (CBService * service in [peripheral services]) {

        if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"FFE0"]]){

            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"FFE0"]]){

        for (CBCharacteristic * characteristic in [service characteristics]){

            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"FFE1"]]){

                [peripheral setNotifyValue:YES forCharacteristic:characteristic];

                [self performSelector:@selector(handleCharacteristic:) withObject:characteristic afterDelay:3.0];
            }
        }
        
       
    }
    
}


- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
        
        if([characteristic value] &&  !error ) {

            NSString * str =[[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];

            
            if ([[self currentCommand] isEqualToString:@"GB+BTYPE"]) {
                
                NSArray * bType = [str componentsSeparatedByString:@":"];

                if ([bType count] > 1) {
                    [[self beacon] setBeaconType:[bType objectAtIndex:1]];

                } else {
                    [[self beacon] setBeaconType:nil];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"GB+PDATE"]) {

                if ([str length] > 1) {
                    [[self beacon] setBeaconDate:[NSString stringWithFormat:@"%@", str]];
                } else {
                    [[self beacon] setBeaconDate:nil];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+VERS?"]) {

                NSArray * bVersion = [str componentsSeparatedByString:@" "];
                if ([bVersion count] > 1) {
                    [[self beacon] setBeaconVersion:[bVersion objectAtIndex:1]];
                } else {
                   [[self beacon] setBeaconVersion:nil];
                }
                
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+MARJ?"]) {
                NSArray * bMajor = [str componentsSeparatedByString:@":"];
                NSString * major = @"";
                [[self beacon] setMajor:[major hex2dec:[bMajor objectAtIndex:1]]];
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+MINO?"]) {
                NSArray * bMinor = [str componentsSeparatedByString:@":"];
                NSString * minor = @"";
                [[self beacon] setMinor:[minor hex2dec:[bMinor objectAtIndex:1]]];
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+IBE0?"]) {
                NSArray * bUUID = [str componentsSeparatedByString:@"x"];
                
                [self setIncomingUUID:[NSString stringWithFormat:@"00000000-0000-0000-0000-000000000000"]];
                
                if ([bUUID count] > 1) {
                    [self setIncomingUUID:[NSString stringWithFormat:@"%@%@",[bUUID objectAtIndex:1],[[self incomingUUID] substringWithRange:NSMakeRange(8,28)]]];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+IBE1?"]) {
                NSArray * bUUID = [str componentsSeparatedByString:@"x"];
                if ([bUUID count] > 1 && [[self incomingUUID] length] == 36) {
                    [self setIncomingUUID:[NSString stringWithFormat:@"%@-%@-%@-%@",
                                     [[self incomingUUID] substringWithRange:NSMakeRange(0,8)],
                                     [[bUUID objectAtIndex:1] substringWithRange:NSMakeRange(0,4)],
                                     [[bUUID objectAtIndex:1] substringWithRange:NSMakeRange(4,4)],
                                     [[self incomingUUID] substringWithRange:NSMakeRange(19,17)]]];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+IBE2?"]) {
                NSArray * bUUID = [str componentsSeparatedByString:@"x"];
                if ([bUUID count] > 1 && [[self incomingUUID] length] == 36) {
                    [self setIncomingUUID:[NSString stringWithFormat:@"%@-%@-%@%@",
                                     [[self incomingUUID] substringWithRange:NSMakeRange(0,18)],
                                     [[bUUID objectAtIndex:1] substringWithRange:NSMakeRange(0,4)],
                                     [[bUUID objectAtIndex:1] substringWithRange:NSMakeRange(4,4)],
                                     [[self incomingUUID] substringWithRange:NSMakeRange(28,8)]]];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+IBE3?"]) {
                NSArray *bUUID = [str componentsSeparatedByString:@"x"];
                if ([bUUID count] > 1 && [[self incomingUUID] length] == 36) {
                    [self setIncomingUUID:[NSString stringWithFormat:@"%@%@",
                                     [[self incomingUUID] substringWithRange:NSMakeRange(0,28)],
                                     [[bUUID objectAtIndex:1] substringWithRange:NSMakeRange(0,8)]]];
                    [[self beacon] setUuid:[self incomingUUID]];
                }
            }
            
            
            
            if ([[self currentCommand] isEqualToString:@"AT+NAME?"]) {
                NSArray * bName = [str componentsSeparatedByString:@":"];
                if ([bName count] > 1) {
                    [[self beacon] setName:[bName objectAtIndex:1]];
                }
            }
            
            
            if ([[self currentCommand] isEqualToString:@"AT+PASS?"]) {
                NSArray * bPincode = [str componentsSeparatedByString:@":"];
                if ([bPincode count] > 1) {
                    [[self beacon] setBeaconPincode:[bPincode objectAtIndex:1]];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+TYPE?"]) {
                NSArray * bType = [str componentsSeparatedByString:@":"];
                if ([bType count] > 1) {
                    if ([[bType objectAtIndex:1] intValue] == 0) {
                        [[self beacon] setBeaconPincode:nil];
                    }
                }
            }
            
            
            if ([[self currentCommand] isEqualToString:@"AT+MEA??"]) {
                NSArray * bPower = [str componentsSeparatedByString:@":"];
                NSString * power = @"";
                [[self beacon] setBeaconMeasuredPower:[power hex2dec_min256:[bPower objectAtIndex:1]]];
                
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+ADTY?"]) {
                NSArray * bMode = [str componentsSeparatedByString:@":"];
                [[self beacon] setBeaconMode:[[bMode objectAtIndex:1] intValue]];
            }
            
            
            if ([[self currentCommand] isEqualToString:@"AT+POWE?"]) {
                NSArray * bRange = [str componentsSeparatedByString:@":"];
                [[self beacon] setBeaconRange:[[bRange objectAtIndex:1] intValue]];
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+ADVI?"]) {
                NSArray * bAdvertising = [str componentsSeparatedByString:@":"];
                if ([bAdvertising count] > 1) {
                    
                    int value = 0;
                    NSString * rate = [bAdvertising objectAtIndex:1];
   
                    if (![self has16AdvertisementRates]) {
                        if ([rate isEqualToString:@"0"]) value = 0;
                        if ([rate isEqualToString:@"1"]) value = 15;
                    } else {
                        if ([rate isEqualToString:@"0"]) value = 0;
                        if ([rate isEqualToString:@"1"]) value = 1;
                        if ([rate isEqualToString:@"2"]) value = 2;
                        if ([rate isEqualToString:@"3"]) value = 3;
                        if ([rate isEqualToString:@"4"]) value = 4;
                        if ([rate isEqualToString:@"5"]) value = 5;
                        if ([rate isEqualToString:@"6"]) value = 6;
                        if ([rate isEqualToString:@"7"]) value = 7;
                        if ([rate isEqualToString:@"8"]) value = 8;
                        if ([rate isEqualToString:@"9"]) value = 9;
                        if ([rate isEqualToString:@"A"]) value = 10;
                        if ([rate isEqualToString:@"B"]) value = 11;
                        if ([rate isEqualToString:@"C"]) value = 12;
                        if ([rate isEqualToString:@"D"]) value = 13;
                        if ([rate isEqualToString:@"E"]) value = 14;
                        if ([rate isEqualToString:@"F"]) value = 15;
                    }
                    
                    [[self beacon] setBeaconAdvertisingRate:value];
                }
            }
            
            
            if ([[self currentCommand] isEqualToString:@"AT+BATC?"]) {
                NSArray * bLevel = [str componentsSeparatedByString:@":"];
                if([bLevel count] > 0){
                    [[self beacon] setBeaconBatteryLevel:[[bLevel objectAtIndex:1] intValue]];
                }
            }
            
            if ([[self currentCommand] isEqualToString:@"AT+BATT?"]) {
                
                NSArray * bBattery = [str componentsSeparatedByString:@":"];
                if ([bBattery count] > 1) {
                    [[self beacon] setBatterylLevel:[[bBattery objectAtIndex:1] intValue]];
                }
            }

            [self performSelector:@selector(handleQueueOfCharacteristics) withObject:self afterDelay:0.2];
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{

    NSLog(@"didWriteValueForCharacteristic: %@ - %@",characteristic,error);
}


@end
