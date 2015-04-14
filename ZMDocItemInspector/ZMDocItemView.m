//
//  INItemVIew.m
//  DociNavigator
//
//  Created by Zolo on 3/26/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import "ZMDocItemView.h"

@interface ZMDocItemView ()
@property NSTextField *nameView;
@property NSImageView *iconImageView;
@property NSTrackingArea *areaTrekker;
@end

@implementation ZMDocItemView

- (instancetype)initWithFrame:(NSRect)frameRect itemName:(NSString *)itemName itemImage:(NSImage *)itemImage {
    self = [super initWithFrame:frameRect];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [[NSColor clearColor] CGColor];

    
    // TextView
    float textHeight = 15;
    self.nameView = [[NSTextField alloc] initWithFrame:CGRectMake(itemImage.size.width+8, frameRect.size.height/2-textHeight/2, frameRect.size.width, 14)];
    self.nameView.selectable = NO;
    self.nameView.editable = NO;
    self.nameView.bezeled = NO;
    self.nameView.drawsBackground = NO;
    if (!itemImage) {
        self.nameView.font = [NSFont boldSystemFontOfSize:11];
    } else {
        self.nameView.font = [NSFont systemFontOfSize:11];
    }
    [self.nameView setLineBreakMode:NSLineBreakByTruncatingTail];
    [self addSubview:self.nameView];
    
    
    if (itemName) {
        // Label value
        [self.nameView setStringValue:itemName];

        // Icon view
        float imageSize = 28;
        self.iconImageView = [[NSImageView alloc] initWithFrame:CGRectMake(0, frameRect.size.height/2-imageSize/2, imageSize, imageSize)];
        self.iconImageView.image = itemImage;
        [self addSubview:self.iconImageView];
        
    } else {
        
        NSView *sep = [[NSView alloc] initWithFrame:CGRectMake(0, frameRect.size.height/2-1/2, frameRect.size.width, 0.5)];
        [sep setWantsLayer:YES];
        sep.layer.backgroundColor = [[NSColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0] CGColor];
        [self addSubview:sep];
    }
    
    return self;
}


-(void)mouseEntered:(NSEvent *)theEvent {
    if (self.iconImageView) {
        self.nameView.textColor = [NSColor whiteColor];
        self.layer.backgroundColor = [[NSColor colorWithRed:0 green:108/255.f blue:210/255.f alpha:1] CGColor];
    }
    [self.delegate itemDidReceiveMouseEnter:self];
}

-(void)mouseExited:(NSEvent *)theEvent {
    [self resetItemAppearance];
    [self.delegate itemDidReceiveMouseExit:self];
}


- (void)resetItemAppearance {
    self.nameView.textColor = [NSColor blackColor];
    self.layer.backgroundColor = [[NSColor clearColor] CGColor];
}


- (void)mouseUp:(NSEvent *)theEvent {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.05;
        self.animator.alphaValue = 0;
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.05;
            self.animator.alphaValue = 1;
        } completionHandler:nil];
    }];
    [self.delegate itemViewDidReceiveClick:self];
}


-(void)updateTrackingAreas {
    if(self.areaTrekker != nil) {
        [self removeTrackingArea:self.areaTrekker];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.areaTrekker = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:self.areaTrekker];
}



@end
