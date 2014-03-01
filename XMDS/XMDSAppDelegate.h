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
    NSWindow *_releaseNotesWindow;
    
    NSString *_xcodeDeveloperPath;
    NSString *_xmdsLibraryPath;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSWindow *updateWindow;
@property (nonatomic, retain) IBOutlet NSWindow *releaseNotesWindow;

- (IBAction)launchXMDSTerminal:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)orderFrontUpdateToDevelopmentVersionWindow:(id)sender;
- (IBAction)openXMDSHomepage:(id)sender;
- (IBAction)openReleaseNotes:(id)sender;

- (IBAction)checkForDeveloperTools:(id)sender;

- (IBAction)viewUserForumArchives:(id)sender;
- (IBAction)signupForUserForum:(id)sender;
- (IBAction)emailUserForum:(id)sender;

- (void)launchXMDSUpdateTerminalToRevision:(NSNumber *)revision;

@end
