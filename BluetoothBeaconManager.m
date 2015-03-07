//
//  Glimworm.m
//  Dashboard
//
//  Created by Joel Oliveira on 15/02/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "BluetoothBeaconManager.h"
#import "NSString+Utils.h"

@implementation BluetoothBeaconManager {
    NSMutableArray * beacons;
}



+(BluetoothBeaconManager*)shared {
    
    static BluetoothBeaconManager *shared = nil;
    
    if (shared == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            shared = [[BluetoothBeaconManager alloc] init];
            
        });
    }
    return shared;
}

- (id)init {
    
    if (self = [super init]) {
        
        [self setCentralManager:[[CBCentralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:@{CBCentralManagerOptionRestoreIdentifierKey : @"00000000-0000-0000-0000-000000000003"}]];
        [[self centralManager] setDelegate:self];
        
        
        [self setGlimworm:[[Glimworm alloc] init]];
        [[self glimworm] setCentralManager:[self centralManager]];
        [[self glimworm] setDelegate:self];
        
        beacons = [NSMutableArray array];
    }
    
    return self;
}

-(void)scanPeripherals{
    [[self centralManager] scanForPeripheralsWithServices:nil options: @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

-(void)stopScan{
    [[self centralManager] stopScan];
}




#pragma CoreBluetooth Framework required delegates

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)manager{

    switch ([manager state]) {
        case CBPeripheralManagerStatePoweredOn:

            //
            NSLog(@"CBPeripheralManagerStatePoweredOn in BluetoothManager");

            break;
        case CBPeripheralManagerStatePoweredOff:
            
            NSLog(@"CBPeripheralManagerStatePoweredOff in BluetoothManager");
            
            break;
        default:
            break;
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch ([central state]) {
        case CBCentralManagerStatePoweredOn:
            
            if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didPowerOn:)]){
                [[self delegate] bluetoothBeaconManager:self didPowerOn:central];
            }
            
            break;
        case CBCentralManagerStatePoweredOff:
            
            if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didPowerOff:)]){
                [[self delegate] bluetoothBeaconManager:self didPowerOff:central];
            }
            
            break;
        default:
            break;
    }
    
}



- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral{

    [[self glimworm] discoverServicesForPeripheral:aPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    
    if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didFailConnectToBeacon:withError:)]){
        [[self delegate] bluetoothBeaconManager:self didFailConnectToBeacon:[self currentBeacon] withError:error];
    }
    
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    [self handlePeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    
}

-(void)handlePeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSString * name = [[NSString alloc] initWithFormat:@"%@", [peripheral name]];
    NSString * uuid = [[peripheral identifier] UUIDString];
    NSDictionary* serviceData = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
    NSString * vendor = [self handleVendor:serviceData];
    int battery = [self batteryLevelForPeripheral:serviceData];
    
    if(vendor){
        
        for (BluetoothLEBeacon * beacon in beacons) {
            if ([[beacon beaconUUID] isEqualToString:(uuid)]){
                return;
            }
        }
        
        
        BluetoothLEBeacon * beacon = [BluetoothLEBeacon new];
        [beacon setName:name];
        [beacon setBeaconUUID:uuid];
        [beacon setRssi:RSSI];
        [beacon setPeripheral:peripheral];
        [beacon setUuid:@""];
        [beacon setMajor:@""];
        [beacon setMinor:@""];
        [beacon setVendor:vendor];
        [beacon setBatterylLevel:battery];
        
        for (id key in [advertisementData allKeys]){
            id obj = [advertisementData objectForKey: key];
            
            NSString * advertisementKey = [[NSString alloc] initWithFormat:@"%@", key];
            
            
            if ([advertisementKey isEqualToString:@"kCBAdvDataManufacturerData"]) {
                NSString *ss2 = [NSString stringWithFormat:@"%@",obj];
                NSString *ib_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@%@",
                                     [ss2 substringWithRange:NSMakeRange(10, 8)],
                                     [ss2 substringWithRange:NSMakeRange(19, 4)],
                                     [ss2 substringWithRange:NSMakeRange(23, 4)],
                                     [ss2 substringWithRange:NSMakeRange(28, 4)],
                                     [ss2 substringWithRange:NSMakeRange(32, 4)],
                                     [ss2 substringWithRange:NSMakeRange(37, 8)]
                                     ];
                NSString *ib_major = [NSString stringWithFormat:@"%@",
                                      [ss2 substringWithRange:NSMakeRange(46, 4)]];
                
                NSString *ib_minor = [NSString stringWithFormat:@"%@",
                                      [ss2 substringWithRange:NSMakeRange(50, 4)]];
                
                
                [beacon setUuid:ib_uuid];
                [beacon setMajor:[[beacon major] hex2dec:ib_major]];
                [beacon setMinor:[[beacon major] hex2dec:ib_minor]];
                
            }
        }
        
        [beacons addObject:beacon];
        
        if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didDiscoverPeripherals:)]){
            [[self delegate] bluetoothBeaconManager:self didDiscoverPeripherals:beacons];
        }
        
    }

}


#pragma
-(NSString *)handleVendor:(NSDictionary *)serviceData{
    
    NSString * vendor = nil;
    
    for (CBUUID * key in [serviceData allKeys]){
        
        NSString * dataKey = [[NSString alloc] initWithFormat:@"%@", [key data]];
        
        if ([dataKey isEqualToString:@"<b000>"]) {
            vendor = @"Glimworm";
        } else if ([dataKey isEqualToString:@"<d00d>"]){
            vendor = @"Kontakt";
        }
    }
    
    return vendor;
}


-(int)batteryLevelForPeripheral:(NSDictionary *)serviceData{
    
    int battery = 0;
    
    NSString * vendor = [self handleVendor:serviceData];
    
    if([vendor isEqualToString:@"Glimworm"]){
        
        for (CBUUID * key in [serviceData allKeys]){
            
            NSData * obj = [serviceData objectForKey:key];
            
            NSString * dataKey = [[NSString alloc] initWithFormat:@"%@", [key data]];
            NSString * dataValue = [[NSString alloc] initWithFormat:@"%@", obj];
            
            if ([dataKey isEqualToString:@"<b000>"]) {
                
                NSString * hexBatteryLavel = [NSString stringWithFormat:@"%@",
                                              [dataValue substringWithRange:NSMakeRange(6, 3)]];
                battery = [[hexBatteryLavel hex2dec:hexBatteryLavel] intValue];
                
            }
        }
        
    } else if([vendor isEqualToString:@"Kontakt"]){
        
        for (CBUUID * key in [serviceData allKeys]){
            
            NSData * obj = [serviceData objectForKey:key];
            
            NSString * dataKey = [[NSString alloc] initWithFormat:@"%@", [key data]];
            NSString * dataValue = [[NSString alloc] initWithFormat:@"%@", obj];

            if ([dataKey isEqualToString:@"<d00d>"]) {
                
                NSString * hexBatteryLavel = [NSString stringWithFormat:@"%@",
                                              [dataValue substringWithRange:NSMakeRange(14, 3)]];
                battery = [[hexBatteryLavel hex2dec:hexBatteryLavel] intValue];
                
            }
        }
    }
    
    
    
    return battery;
}



#pragma Peripheral methods

-(void)connectToBeacon:(BluetoothLEBeacon *)beacon{
    
    if([[beacon vendor] isEqualToString:@"Glimworm"]){
        [[self glimworm] connectToBeacon:beacon];
        [self setCurrentBeacon:beacon];
    } else if([[beacon vendor] isEqualToString:@"Kontakt"]){
        //TODO:
        if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didFailConnectToBeacon:withError:)]){
            [[self delegate] bluetoothBeaconManager:self didFailConnectToBeacon:beacon withError:nil];
        }
    }

}

-(void)closeConnectionToBeacon:(BluetoothLEBeacon *)beacon{
    
    if([[beacon vendor] isEqualToString:@"Glimworm"]){
        [[self glimworm] closeConnectionToBeacon:beacon];
        [self setCurrentBeacon:nil];
    } else if([[beacon vendor] isEqualToString:@"Kontakt"]){
        
    }
}

-(void)updateBeacon:(BluetoothLEBeacon *)beacon{
    
    if([[beacon vendor] isEqualToString:@"Glimworm"]){
        [[self glimworm] updateBeacon:beacon];
        [self setCurrentBeacon:beacon];
    } else if([[beacon vendor] isEqualToString:@"Kontakt"]){

    }
    
}


-(void)updateBeacon:(BluetoothLEBeacon *)beacon withValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic{
    
}


#pragma Glimworm delegates
- (void)glimworm:(Glimworm *)library didPowerOn:(CBCentralManager *)manager{
    
}
- (void)glimworm:(Glimworm *)library didPowerOff:(CBCentralManager *)manager{

}

- (void)glimworm:(Glimworm *)library didConnectToBeacon:(BluetoothLEBeacon *)beacon{
    
    if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didConnectToBeacon:)]){
        [[self delegate] bluetoothBeaconManager:self didConnectToBeacon:beacon];
    }
}

- (void)glimworm:(Glimworm *)library didUpdateBeacon:(BluetoothLEBeacon *)beacon{
    
    if([[self delegate] respondsToSelector:@selector(bluetoothBeaconManager:didUpdateBeacon:)]){
        [[self delegate] bluetoothBeaconManager:self didUpdateBeacon:beacon];
    }
}

- (void)glimworm:(Glimworm *)library didWriteToPeripheral:(BluetoothLEBeacon *)beacon{
    
}
- (void)glimworm:(Glimworm *)library didDiscoverServices:(NSArray *)services forBeacon:(BluetoothLEBeacon *)beacon{
    
}



@end
