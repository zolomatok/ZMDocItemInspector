//
//  INItemVIew.h
//  DociNavigator
//
//  Created by Zolo on 3/26/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZMDocItemView;
@protocol DocItemViewDelegate <NSObject>
- (void)itemViewDidReceiveClick:(ZMDocItemView *)itemView;
@end

@interface ZMDocItemView : NSView
- (instancetype)initWithFrame:(NSRect)frameRect itemName:(NSString *)itemName itemImage:(NSImage *)itemImage;

@property int customTag;
@property (weak) id <DocItemViewDelegate> delegate;
@end
