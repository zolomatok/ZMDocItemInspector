//
//  ZMDocItemInspector.h
//  ZMDocItemInspector
//
//  Created by Zolo on 3/29/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ZMDocItemInspector : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end