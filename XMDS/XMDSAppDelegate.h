//
//  XMDSAppDelegate.h
//  XMDS
//
//  Created by Graham Dennis on 10/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMDSAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *_window;
    NSWindow *_updateWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSWindow *updateWindow;
@property (readonly) NSString *usrPath;
@property (readonly) NSString *xmdsLibraryPath;
@property (readonly) NSArray *documentationPaths;

- (IBAction)launchXMDSTerminal:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)orderFrontUpdateToDevelopmentVersionWindow:(id)sender;
- (void)launchXMDSUpdateTerminalToRevision:(NSNumber *)revision;

@end
