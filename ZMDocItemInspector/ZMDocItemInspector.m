//
//  ZMDocItemInspector.m
//  ZMDocItemInspector
//
//  Created by Zolo on 3/29/15.
//  Copyright (c) 2015 Zolo. All rights reserved.
//

#import "ZMDocItemInspector.h"
#import "ZMDocItemView.h"
#import "NSTaggableView.h"

// Utils
#import "JGMethodSwizzler.h"
#import "DTXcodeUtils.h"

// Panel UI
#import "DVTControllerContentView.h"

// Source code
#import "DVTSourceLandmarkItem.h"
#import "DVTTextDocumentLocation.h"

static ZMDocItemInspector *sharedPlugin;

@interface ZMDocItemInspector() <DocItemViewDelegate>
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSTaggableView *containerView;
@property NSArray *currentDocItems;
@property NSMutableArray *itemsUnderMouse;
@end


@implementation ZMDocItemInspector


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}


+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationListener:) name:nil object:nil];
        
        
        // Create the panel
        [self createDocPanel];
    }
    return self;
}





#pragma mark - Notification listener
- (void)notificationListener:(NSNotification *)notif {
    
    // Save (did) || Setup complete (changed files)
    if ([notif.name isEqualToString:@"IDEEditorDocumentDidSaveNotification"] || [notif.name isEqualToString:@"IDESourceCodeEditorDidFinishSetup"]) {
        NSLog(@"[DOCI] Did save");
        [sharedPlugin updateDocItems];
    }
}




#pragma mark - Create panel
- (void)createDocPanel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class d = NSClassFromString(@"IDEInspectorArea");
    [d swizzleInstanceMethod:@selector(_contentViewForSlice:inCategory:) withReplacement:JGMethodReplacementProviderBlock {
        return JGMethodReplacement(id, id, id slice, id category) {
            
            // Inspecting params and self
//            NSLog(@"NNNN: %@",((DVTExtension *)slice).name);
//            NSLog(@"SELF: %@",self);
            
            
            DVTControllerContentView *orig = JGOriginalImplementation(DVTControllerContentView *, slice, category);
            if ([[slice name] isEqualToString:@"QuickHelpInspectorMain"]) {
                
                // Create the container
                sharedPlugin.containerView = [[NSTaggableView alloc] initWithFrame:CGRectMake(0, 0, orig.frame.size.width, 400)];
                [sharedPlugin.containerView setWantsLayer:YES];
                [sharedPlugin.containerView.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
                sharedPlugin.containerView.mTag = @998;
                
                // Update the items
                [sharedPlugin updateDocItems];
                
                
                // Push the container
                [orig setContentView:sharedPlugin.containerView];
                
                
                // Listen for scroll events
                [[NSNotificationCenter defaultCenter] addObserver:sharedPlugin selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:orig.superview];
                [orig setPostsBoundsChangedNotifications:YES];
            }
            
            
            return orig;
        };
    }];
#pragma clang diagnostic pop
}


- (void)boundsDidChange:(NSNotification *)notif {
    
    // Deselect items on scroll (else if the scrolling was done with a gesture or mouse wheel, items with be stuck with a blue background)
    for (ZMDocItemView *itemView in sharedPlugin.itemsUnderMouse) {
        [itemView resetItemAppearance];
    }
}




#pragma mark - Update
- (void)updateDocItems {
    
    // Parse
    [self parseDocItems]; // Array of DVTSourceLandmarkItems
    
    
    // Populate
    @try {
        [self populatePanel];
    }
    @catch (NSException *exception) {
        NSLog(@"ZMDocItemsInspector EXCEPTION: %@",exception);
    }
    @finally {
        
    }
}


- (void)parseDocItems {
    
    
    // Vars
    IDESourceCodeDocument *scd = [DTXcodeUtils currentSourceCodeDocument];
    NSArray *landmarkItems = [scd ideTopLevelStructureObjects];
    
    
    NSMutableArray *allItemsFlat = [NSMutableArray array];
    for (DVTSourceLandmarkItem *item in landmarkItems) {
        NSMutableArray *items = [self childrenFromLandmarkItem:item];
        [allItemsFlat addObjectsFromArray:items];
    }
    
    
    self.currentDocItems = allItemsFlat;
}


- (NSMutableArray *)childrenFromLandmarkItem:(DVTSourceLandmarkItem *)landmarkItem {
    
    NSMutableArray *returnArray = [NSMutableArray array];
    [returnArray addObject:landmarkItem];
    for (DVTSourceLandmarkItem *child in landmarkItem.children) {
        [returnArray addObjectsFromArray:[self childrenFromLandmarkItem:child]];
    }
    
    
    return returnArray;
}


- (void)populatePanel {
    
//    for (DVTSourceLandmarkItem *item in self.currentDocItems) {
//        NSLog(@"\nItem type: %i\nItem name:%@\n---------",item.type,item.name);
//    }
    
    // Remove the previous views
    [sharedPlugin.containerView setSubviews:[NSArray array]];
    [sharedPlugin.itemsUnderMouse removeAllObjects];
    
    
    // Calculate and set the height of the container view
    float itemHeight = 20;
    float correctHeight = self.currentDocItems.count*itemHeight+itemHeight*1.5;
    [sharedPlugin.containerView setFrame:CGRectMake(sharedPlugin.containerView.frame.origin.x, sharedPlugin.containerView.frame.origin.y, sharedPlugin.containerView.frame.size.width, correctHeight)];
    
    
    // Add the current symbols
    for (int i = 0; i < self.currentDocItems.count; i++) {
        
        DVTSourceLandmarkItem *item = self.currentDocItems[i];
        if (item.type != 1 &&
            item.type != 2 &&
            item.type != 3 &&
            item.type != 4 &&
            item.type != 5 &&
            item.type != 7 &&
            item.type != 8 &&
            item.type != 19) {
            continue;
        }
        
        NSString *imagePath;
        float offset = 15;
        
        // Pragma separator
        if (item.type == 1 && item.name) {
            offset += 12;
            
            // Pragma text
        } else if (item.type == 1 && !item.name) {
            offset = 0;
            
            // Interface & Implementation
        } else if (item.type == 2 || item.type == 3) {
            imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"class-icon" ofType:@"png"];
            
            // Method
        } else if (item.type == 4 || item.type == 5) {
            imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"method-icon" ofType:@"png"];
            offset += 15;
            
            // C function
        } else if (item.type == 7) {
            imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"function-icon" ofType:@"png"];
            offset += 15;
            
            // #Define
        } else if (item.type == 8) {
            imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"define-icon" ofType:@"png"];
            
            // Property
        } else if (item.type == 19) {
            imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"property-icon" ofType:@"png"];
            offset += 15;
        }
        NSImage *iconImage;
        if (imagePath)
            iconImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        
        
        
        float itemY = sharedPlugin.containerView.frame.size.height-itemHeight*1.5-(i*itemHeight);
        ZMDocItemView *itemView = [[ZMDocItemView alloc] initWithFrame:CGRectMake(offset, itemY, sharedPlugin.containerView.frame.size.width-offset*1.2, itemHeight) itemName:item.name itemImage:iconImage];
        itemView.customTag = i;
        itemView.delegate = self;
        [sharedPlugin.containerView addSubview:itemView];
    }
}


- (void)itemViewDidReceiveClick:(ZMDocItemView *)itemView {
    if (self.currentDocItems.count > itemView.customTag) {
        [self jumpToLandmarkItemInTheEditor:self.currentDocItems[itemView.customTag]];
    }
}


- (void)itemDidReceiveMouseEnter:(ZMDocItemView *)itemView {
    if (!sharedPlugin.itemsUnderMouse) {
        sharedPlugin.itemsUnderMouse = [NSMutableArray array];
    }
    
    if (![sharedPlugin.itemsUnderMouse containsObject:itemView]) {
        [sharedPlugin.itemsUnderMouse addObject:itemView];
    }
}

- (void)itemDidReceiveMouseExit:(ZMDocItemView *)itemView {
    [sharedPlugin.itemsUnderMouse removeObject:itemView];
}




#pragma mark - Jump
- (void)jumpToLandmarkItemInTheEditor:(DVTSourceLandmarkItem *)landmarkItem {
    
    // Check if the current editor is a source code editor (not IB or quick look, etc)
    IDESourceCodeEditor *editor = (IDESourceCodeEditor *)[DTXcodeUtils currentEditor];
    if (![editor isKindOfClass:[NSClassFromString(@"IDESourceCodeEditor") class]]) {
        return;
    }
    
    
    // Jump to the symbol's locaiton in the source code
    IDESourceCodeDocument *scd = [DTXcodeUtils currentSourceCodeDocument];
    DVTDocumentLocation *highlightLocation = [[NSClassFromString(@"DVTTextDocumentLocation") alloc] initWithDocumentURL:scd.fileURL timestamp:[NSNumber numberWithDouble:landmarkItem.timestamp] characterRange:landmarkItem.nameRange];
    [editor selectDocumentLocations:@[highlightLocation] highlightSelection:NO];
}





- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
