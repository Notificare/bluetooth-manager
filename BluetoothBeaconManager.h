//
//  Glimworm.h
//  Dashboard
//
//  Created by Joel Oliveira on 15/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Glimworm.h"
#import "BluetoothLEBeacon.h"

@class BluetoothBeaconManager;

@protocol BluetoothBeaconManagerDelegate <NSObject>

@optional

- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didConnectToBeacon:(BluetoothLEBeacon *)beacon;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didFailConnectToBeacon:(BluetoothLEBeacon *)peripheral withError:(NSError *)error;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didUpdateBeacon:(BluetoothLEBeacon *)beacon;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didFailUpdateBeacon:(BluetoothLEBeacon *)beacon withError:(NSError *)error;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didDiscoverServices:(NSArray *)services forBeacon:(BluetoothLEBeacon *)beacon;

@required

- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didPowerOn:(CBCentralManager *)manager;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didPowerOff:(CBCentralManager *)manager;
- (void)bluetoothBeaconManager:(BluetoothBeaconManager *)library didDiscoverPeripherals:(NSArray *)peripherals;

@end



@interface BluetoothBeaconManager : NSObject <CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate, GlimwormDelegate>


@property (nonatomic, assign) id <BluetoothBeaconManagerDelegate> delegate;
@property (nonatomic, strong) CBCentralManager * centralManager;
@property (nonatomic, strong) Glimworm * glimworm;
@property (nonatomic, strong) BluetoothLEBeacon * currentBeacon;

+(BluetoothBeaconManager*)shared;
-(void)scanPeripherals;
-(void)stopScan;
-(void)connectToBeacon:(BluetoothLEBeacon *)beacon;
-(void)closeConnectionToBeacon:(BluetoothLEBeacon *)beacon;
-(void)updateBeacon:(BluetoothLEBeacon *)beacon;

@end
