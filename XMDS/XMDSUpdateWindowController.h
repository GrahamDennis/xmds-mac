//
//  XMDSUpdateWindowController.h
//  XMDS
//
//  Created by Graham Dennis on 14/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMDSUpdateWindowController : NSWindowController
{
    NSNumber *_subversionRevision;
    NSNumber *_updateSelectionIndex;
}


@property (nonatomic, retain) NSNumber *subversionRevision;
@property (nonatomic, retain) NSNumber *updateSelectionIndex;

- (IBAction)updateToDevelopmentVersion:(id)sender;
@end
