//
//  GlimwormBTBeacon.h
//  Dashboard
//
//  Created by Joel Oliveira on 14/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothLEBeacon : NSObject

@property(retain, readwrite) NSString * name;
@property(retain, readwrite) NSString * beaconUUID;
@property(retain, readwrite) NSNumber * rssi;
@property(readwrite) CFUUIDRef * uuidRef;
@property(nonatomic, strong) CBPeripheral * peripheral;
@property(retain, readwrite) NSString * uuid;
@property(retain, readwrite) NSString * major;
@property(retain, readwrite) NSString * minor;
@property(retain, readwrite) NSString * vendor;
@property(retain, readwrite) NSString * beaconType;
@property(retain, readwrite) NSString * beaconDate;
@property(retain, readwrite) NSString * beaconVersion;
@property(retain, readwrite) NSString * beaconPincode;
@property(retain, readwrite) NSString * beaconMeasuredPower;
@property(readwrite) int beaconMode;
@property(readwrite) int beaconRange;
@property(readwrite) int beaconAdvertisingRate;
@property(readwrite) int beaconBatteryLevel;
@property(readwrite) int batterylLevel;
@property(readwrite) BOOL isUSBBeacon;


@end
