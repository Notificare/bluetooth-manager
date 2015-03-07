//
//  Glimworm.h
//  Dashboard
//
//  Created by Joel Oliveira on 15/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothLEBeacon.h"

@class Glimworm;

@protocol GlimwormDelegate <NSObject>

@required

- (void)glimworm:(Glimworm *)library didPowerOn:(BluetoothLEBeacon *)beacon;
- (void)glimworm:(Glimworm *)library didPowerOff:(BluetoothLEBeacon *)beacon;
- (void)glimworm:(Glimworm *)library didConnectToBeacon:(BluetoothLEBeacon *)beacon;
- (void)glimworm:(Glimworm *)library didUpdateBeacon:(BluetoothLEBeacon *)beacon;

@end

@interface Glimworm : NSObject <CBPeripheralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic, assign) id <GlimwormDelegate> delegate;
@property (nonatomic, strong) CBPeripheral * peripheral;
@property (nonatomic, strong) CBCentralManager * centralManager;
@property (nonatomic, strong) CBCharacteristic * currentCharacteristic;
@property (nonatomic, strong) BluetoothLEBeacon * beacon;
@property (nonatomic, strong) NSMutableArray * commandQueue;
@property (nonatomic, strong) NSString * currentCommand;
@property (nonatomic, strong) NSString * incomingUUID;

-(void)connectToBeacon:(BluetoothLEBeacon *)beacon;
-(void)closeConnectionToBeacon:(BluetoothLEBeacon *)beacon;
-(void)discoverServicesForPeripheral:(CBPeripheral *)peripheral;
-(void)updateBeacon:(BluetoothLEBeacon *)beacon;
-(BOOL)isUSBBeacon;
-(BOOL)isFirstBeaconType;
-(BOOL)isCapableOfSettingModes;
-(BOOL)isCapableOfSettingBatteryLevel;

@end
