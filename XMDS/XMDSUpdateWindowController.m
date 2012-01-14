//
//  XMDSUpdateWindowController.m
//  XMDS
//
//  Created by Graham Dennis on 14/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSUpdateWindowController.h"
#import "XMDSAppDelegate.h"

@implementation XMDSUpdateWindowController

@synthesize subversionRevision = _subversionRevision;
@synthesize updateSelectionIndex = _updateSelectionIndex;

- (void)dealloc
{
    self.subversionRevision = nil;
    self.updateSelectionIndex = nil;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)updateToDevelopmentVersion:(id)sender
{
    NSNumber *revision = nil;
    if ([self.updateSelectionIndex integerValue] == 1)
        revision = self.subversionRevision;
    
    [(XMDSAppDelegate *)[NSApp delegate] launchXMDSUpdateTerminalToRevision:revision];
}

@end
