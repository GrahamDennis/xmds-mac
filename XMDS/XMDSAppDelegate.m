//
//  XMDSAppDelegate.m
//  XMDS
//
//  Created by Graham Dennis on 10/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSAppDelegate.h"

#import <CoreServices/CoreServices.h>

@interface XMDSAppDelegate ()

- (NSString *)writeXMDSTerminalFile;
- (NSString *)writeXMDSUpdateTerminalFileWithRevision:(NSString *)revision;

- (NSString *)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters withSuffix:(NSString *)path;

- (IBAction)askUserToInstallDevToolsWithMessage:(NSString *)message
                                    buttonTitle:(NSString *)buttonTitle
                                         action:(id)action
                                 suppressionKey:(NSString *)suppressionKey;

- (IBAction)askUserToInstallCmdLineToolsFromXcode:(id)sender;
- (IBAction)askUserToInstallCmdLineToolsFromDevSite:(id)sender;
- (IBAction)askUserToUpgradeOS:(id)sender;
- (IBAction)askUserToInstallXcodeFromDevSite:(id)sender;
- (BOOL)isTextMateInstalled;
- (BOOL)isTextMateBundleInstalled;
- (void)offerToInstallTextMateBundle;
- (IBAction)installTextMateBundle:(id)sender;
- (NSString *)textMateBundlePath;
- (NSString *)textMateBundleInstallPath;
- (NSString *)textMateBundleSourcePath;

@property (readonly) NSString *usrPath;
@property (readonly) NSString *xmdsLibraryPath;
@property (readonly) NSArray *documentationPaths;
@property (nonatomic, retain) NSString *xcodeDeveloperPath;

@property (readonly, nonatomic) NSString *macosxVersion;

@end

@implementation XMDSAppDelegate

@synthesize window = _window;
@synthesize updateWindow = _updateWindow;
@synthesize releaseNotesWindow = _releaseNotesWindow;
@synthesize xcodeDeveloperPath = _xcodeDeveloperPath;

- (void)dealloc
{
    self.updateWindow = nil;
    self.releaseNotesWindow = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self checkForDeveloperTools:nil];
    
    NSString *XMDSHasLaunchedBeforeKey = @"XMDSHasLaunched";
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:XMDSHasLaunchedBeforeKey] == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:XMDSHasLaunchedBeforeKey];
    } else {
        // Things to check on second launch.
        
        [self offerToInstallTextMateBundle];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)launchXMDSTerminal:(id)sender
{
    NSString *terminalPath = [self writeXMDSTerminalFile];
    if (!terminalPath) return;
    
    NSURL *terminalURL = [NSURL fileURLWithPath:terminalPath];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (void)launchXMDSUpdateTerminalToRevision:(NSString *)revision
{
    NSString *terminalPath = [self writeXMDSUpdateTerminalFileWithRevision:revision];
    if (!terminalPath) return;
    
    NSURL *terminalURL = [NSURL fileURLWithPath:terminalPath];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (IBAction)showHelp:(id)sender
{
    for (NSString *documentationPath in self.documentationPaths) {
        NSString *documentationRoot = [documentationPath stringByAppendingPathComponent:@"index.html"];
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:documentationRoot]) {
            if ([[NSWorkspace sharedWorkspace] openFile:documentationRoot])
                return;
        }
    }
}

- (IBAction)orderFrontUpdateToDevelopmentVersionWindow:(id)sender
{
    if (!self.updateWindow) {
        NSNib *updateWindowNib;
        
        updateWindowNib = [[NSNib alloc] initWithNibNamed:@"DevelopmentVersionUpdateWindow"
                                                   bundle:nil];
        
        [updateWindowNib instantiateNibWithOwner:self
                                 topLevelObjects:nil];
        
        [updateWindowNib release];
    }
    
    if (!self.updateWindow) {
        NSLog(@"Couldn't create update window");
        return;
    }
    
    [self.updateWindow makeKeyAndOrderFront:sender];
}

- (IBAction)checkForDeveloperTools:(id)sender
{
    // For a complete installation, we need a compiler, python-config and Python.h
    // As of Mac OS X 10.7, Python.h isn't being distributed with the base install,
    // and it only comes with the command line tools.  It is also available in the
    // MacOSX10.7.sdk, but I don't know how to get python distutils to find it there.
    //
    //
    // If you have /usr/bin/g++, it means you have everything. Either:
    //   1. You have an older version of Xcode which came with 'command line tools', or
    //   2. You have the 'Command Line Tools' for 10.7.3, with or without Xcode 4.3+
    // I'm also now testing for wchar.h because I had problems with it on Mavericks
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/g++"] &&
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/include/wchar.h"]) {
        // Just use the root directory tools
        self.xcodeDeveloperPath = @"";
        return;
    }
    
    // If you don't have /usr/bin/g++, the remedy depends on the operating system version:
    //   * if you're running something earlier than 10.7, you need to go to the Developer website
    //     and download Xcode for your operating system.
    //   * if you're running 10.7.0 to 10.7.2, we can either recommend you update to 10.7.3 and install
    //     Command Line Tools, or grab Xcode 4.2.1 for Lion
    //   * if you're running 10.7.3 or later, we just tell you to grab 'Command Line Tools'
    
    if ([@"10.7.3" compare:self.macosxVersion options:NSNumericSearch] <= 0) {
        // >= 10.7.3
        
        // They either don't have any Xcode installed, or have Xcode 4.3+ installed without
        // Command Line Tools.
        
        // If they have Xcode 4.3+, suggest that they install Command Line Tools from within Xcode.
        if ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.dt.Xcode"]) {
            // We have Xcode 4.3+
            [self askUserToInstallCmdLineToolsFromXcode:sender];
        } else {
            // We don't have Xcode, so just get Command Line Tools
            [self askUserToInstallCmdLineToolsFromDevSite:sender];
        }
    } else if ([@"10.7.0" compare:self.macosxVersion options:NSNumericSearch] <= 0) {
        // >= 10.7.0
        [self askUserToUpgradeOS:sender];
    } else {
        // < 10.7.0
        [self askUserToInstallXcodeFromDevSite:sender];
    }
}

- (IBAction)askUserToInstallCmdLineToolsFromXcode:(id)sender
{
    [self askUserToInstallDevToolsWithMessage:@"Please install “Command Line Tools” from within Xcode.\nFirst open the Xcode preferences by going to the “Xcode” menu and selecting “Preferences…”.\nWithin the preferences window, select the “Downloads” tab and then the “Components” panel beneath that.\nNow click “Install” next to “Command Line Tools”."
                                  buttonTitle:nil
                                       action:nil
                               suppressionKey:@"InstallCommandLineToolsFromXcodeAlertSuppress"];
}

- (IBAction)askUserToInstallCmdLineToolsFromDevSite:(id)sender
{
    [self askUserToInstallDevToolsWithMessage:@"Please install “Command Line Tools” from the Apple Developer Portal.\nInstalling “Command Line Tools” requires signing up for the free Apple Developer Program."
                                  buttonTitle:@"Get Command Line Tools" 
                                       action:[NSURL URLWithString:@"https://developer.apple.com/downloads/index.action?=Command%20Line%20Tools"]
                               suppressionKey:@"InstallCommandLineToolsFromDevSiteAlertSuppress"];
}

- (IBAction)askUserToUpgradeOS:(id)sender
{
    [self askUserToInstallDevToolsWithMessage:@"You need to install “Command Line Tools” from the Apple Developer Portal.\nHowever, you must first update your operating system to 10.7.3 or later."
                                  buttonTitle:@"Update Mac OS X" 
                                       action:@"com.apple.SoftwareUpdate"
                               suppressionKey:@"InstallCommandLineToolsFromDevSiteAlertSuppress"];
}

- (IBAction)askUserToInstallXcodeFromDevSite:(id)sender
{
    [self askUserToInstallDevToolsWithMessage:@"You need to install Xcode from the Apple Developer Portal.\nInstalling Xcode requires signing up for the free Apple Developer Program."
                                  buttonTitle:@"Get Xcode" 
                                       action:[NSURL URLWithString:@"https://developer.apple.com/downloads/index.action?=xcode"]
                               suppressionKey:@"InstallXcodeFromDevSiteAlertSuppress"];
}


- (IBAction)askUserToInstallDevToolsWithMessage:(NSString *)message
                                    buttonTitle:(NSString *)buttonTitle
                                         action:(id)action
                                 suppressionKey:(NSString *)suppressionKey
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:suppressionKey]) return;
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert setMessageText:@"Developer Tools are needed to use XMDS"];
    
    [alert setInformativeText:[@"Mac Developer Tools are required to compile and run simulations generated by XMDS.\n" stringByAppendingString:message]];
    
    if (buttonTitle) {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert addButtonWithTitle:@"Dismiss"];
    [alert setShowsSuppressionButton:YES];
    
    NSInteger selectedButtonID = [alert runModal];
    
    if (buttonTitle && selectedButtonID == NSAlertFirstButtonReturn) {
        if ([action isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)action;
            [[NSWorkspace sharedWorkspace] openURL:url];
        } else if ([action isKindOfClass:[NSString class]]) {
            NSString *bundleId = (NSString *)action;
            [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:bundleId 
                                                                 options:NSWorkspaceLaunchDefault
                                          additionalEventParamDescriptor:NULL
                                                        launchIdentifier:NULL];
        } else {
            assert(false);
        }
    }
    
    if ([[alert suppressionButton] state] == NSOnState) {
        // Suppress this alert
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:suppressionKey];
    }
    [alert release];
    
}

- (IBAction)openXMDSHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.xmds.org"]];
}

- (IBAction)openReleaseNotes:(id)sender
{
    if (!self.releaseNotesWindow) {
        NSNib *releaseNotesWindowNib;
        
        releaseNotesWindowNib = [[NSNib alloc] initWithNibNamed:@"ReleaseNotes"
                                                   bundle:nil];
        
        [releaseNotesWindowNib instantiateNibWithOwner:self
                                 topLevelObjects:nil];
        
        [releaseNotesWindowNib release];
    }
    
    if (!self.releaseNotesWindow) {
        NSLog(@"Couldn't create release notes window");
        return;
    }
    
    [self.releaseNotesWindow makeKeyAndOrderFront:sender];
}

- (IBAction)signupForUserForum:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lists.sourceforge.net/lists/listinfo/xmds-user"]];
}

- (IBAction)emailUserForum:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:xmds-user@lists.sourceforge.net"]];
}

- (IBAction)viewUserForumArchives:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/mailarchive/forum.php?forum_name=xmds-user"]];
}

#pragma mark TextMate bundle methods

- (void)offerToInstallTextMateBundle
{
    NSString *textMateBundleInstallAlertSuppress = @"TextMateBundleInstallAlertSuppress";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:textMateBundleInstallAlertSuppress])
        return;
    
    if (![self isTextMateInstalled])
        return;
    
    if ([self isTextMateBundleInstalled])
        return;
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];

    [alert setMessageText:@"Would you like to install XMDS syntax highlighting for TextMate?"];
    
    [alert addButtonWithTitle:@"Install TextMate support for XMDS"];
    [alert addButtonWithTitle:@"Dismiss"];
    [alert setShowsSuppressionButton:YES];

    NSInteger selectedButtonID = [alert runModal];
    
    if (selectedButtonID == NSAlertFirstButtonReturn) {
        [self installTextMateBundle:self];
    }
    
    if ([[alert suppressionButton] state] == NSOnState) {
        // Suppress this alert
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:textMateBundleInstallAlertSuppress];
    }
    
    [alert release];
}

- (BOOL)isTextMateInstalled
{
    // Check for normal TextMate
    if ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.macromates.TextMate"])
        return YES;
    // Check for TextMate preview
    if ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.macromates.TextMate.preview"])
        return YES;
    
    return NO;
}

- (BOOL)isTextMateBundleInstalled
{
    NSString *xmdsBundlePath = [self textMateBundleInstallPath];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:xmdsBundlePath];
}

- (NSString *)textMateBundlePath
{
    NSArray *searchURLs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if (![searchURLs count]) {
        NSLog(@"Empty search paths when looking for the user application support directory");
        return nil;
    }
    
    if ([searchURLs count] > 1) 
        NSLog(@"Warning: More than one user application support path found: %@", searchURLs);
    
    NSString *appSupportPath = [(NSURL *)[searchURLs lastObject] path];
    
    NSString *textMateBundlePath = [appSupportPath stringByAppendingPathComponent:@"TextMate/Bundles"];
    
    return textMateBundlePath;
}

- (NSString *)textMateBundleInstallPath
{
    NSString *xmdsBundlePath = [[self textMateBundlePath] stringByAppendingPathComponent:@"xpdeint.tmbundle"];
    
    return xmdsBundlePath;
}

- (NSString *)textMateBundleSourcePath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/usr/share/xmds/extras/xpdeint.tmbundle"];
}

- (IBAction)installTextMateBundle:(id)sender
{
    NSString *sourcePath = [self textMateBundleSourcePath];
    NSString *destPath = [self textMateBundleInstallPath];
    
    BOOL result;
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        [alert setMessageText:@"TextMate bundle previously installed"];
        [alert setInformativeText:@"You currently have the TextMate bundle installed.  Would you like to reinstall it?"];
        
        [alert addButtonWithTitle:@"Reinstall"];
        [alert addButtonWithTitle:@"Cancel"];
        
        NSInteger selectedButtonID = [alert runModal];
        
        [alert release];
        
        if (selectedButtonID == NSAlertFirstButtonReturn) {
            result = [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
            
            if (!result) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Unable to remove TextMate bundle"];
                [alert setInformativeText:[NSString stringWithFormat:@"An error occurred while trying to remove the old TextMate bundle.\nDetails: %@", error]];
                
                [alert addButtonWithTitle:@"Dismiss"];
                
                [alert runModal];
                
                [alert release];
                return;
            }
            // We successfully removed the old bundle, move on to installing the new one.
            
        } else {
            // We aren't removing the currently installed bundle.
            return;
        }
    }
    
    // Create the intermediate paths if they don't exist
    NSString *textMateBundlePath = [self textMateBundlePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:textMateBundlePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:textMateBundlePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    result = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destPath error:&error];
    if (!result) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Unable to install TextMate bundle"];
        [alert setInformativeText:[NSString stringWithFormat:@"An error occurred while trying to install the TextMate bundle.\nDetails: %@", error]];
        [alert addButtonWithTitle:@"Dismiss"];
        
        [alert runModal];
        [alert release];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"TextMate bundle installed"];
        [alert setInformativeText:@"XMDS scripts opened with TextMate will now have syntax highlighting"];
        
        [alert addButtonWithTitle:@"Dismiss"];
        
        [alert runModal];
        [alert release];
    }
    
}


#pragma mark Terminal file writing

- (NSString *)writeXMDSTerminalFile
{
    NSString *terminalFilePath = [self interpolateTerminalTemplateWithParameters:nil
                                                                      withSuffix:nil];
    
    return terminalFilePath; 
}

- (NSString *)writeXMDSUpdateTerminalFileWithRevision:(NSNumber *)revision
{
    NSString *additionalCommand = @"update-xmds2";
    
    if (revision)
        additionalCommand = [additionalCommand stringByAppendingFormat:@" --revision %@", revision];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:additionalCommand
                                                           forKey:@"${ADDITIONAL_COMMANDS}"];
    
    NSString *terminalUpdateFile = [self interpolateTerminalTemplateWithParameters:parameters
                                                                        withSuffix:@"-update"];
    
    return terminalUpdateFile;
}

- (NSString *)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters withSuffix:(NSString *)suffix
{
    if (!suffix)
        suffix = @"";
    
    NSString *terminalTemplatePath = [[NSBundle mainBundle] pathForResource:@"XMDS"
                                                                     ofType:@"terminal"];
    
    if (!terminalTemplatePath) {
        NSLog(@"Couldn't find XMDS.terminal");
        return FALSE;
    }
    
    NSString *bashProfilePath = [[NSBundle mainBundle] pathForResource:@"bash_profile" ofType:nil];
    
    if (!bashProfilePath) {
        NSLog(@"Couldn't find bash_profile");
        return FALSE;
    }
    
    NSError *error = nil;
    
    NSString *terminalContents = [NSString stringWithContentsOfFile:terminalTemplatePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    
    if (error) {
        NSLog(@"Couldn't read XMDS.terminal content. Error: %@", error);
        return FALSE;
    }
    
    NSString *bashProfileContents = [NSString stringWithContentsOfFile:bashProfilePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Couldn't read bash_profile content. Error: %@", error);
        return FALSE;
    }
    
    NSString *terminalFilename = [NSString stringWithFormat:@"XMDS%@.terminal", suffix];
    NSString *bashProfileFilename = [NSString stringWithFormat:@"bash_profile%@", suffix];
    
    NSString *terminalDestinationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:terminalFilename];
    NSString *bashProfileDestinationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:bashProfileFilename];
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          self.usrPath, @"${XMDS_USR}",
                                          self.xcodeDeveloperPath, @"${DEVELOPER_DIR}",
                                          bashProfileDestinationPath, @"${RC_FILE}",
                                          @"XMDS", @"${NAME}",
                                          @"", @"${ADDITIONAL_COMMANDS}",
                                          nil];
    
    [allParameters addEntriesFromDictionary:parameters];
    
    for (NSString *key in allParameters) {
        terminalContents = [terminalContents stringByReplacingOccurrencesOfString:key
                                                                       withString:[allParameters objectForKey:key]];
        bashProfileContents = [bashProfileContents stringByReplacingOccurrencesOfString:key
                                                                             withString:[allParameters objectForKey:key]];
    }
    
    BOOL result = [bashProfileContents writeToFile:bashProfileDestinationPath
                                        atomically:YES
                                          encoding:NSUTF8StringEncoding
                                             error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write rc file to path: %@. Error: %@", bashProfileDestinationPath, error);
        return FALSE;
    }
    
    result = [terminalContents writeToFile:terminalDestinationPath
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write terminal file to path: %@. Error: %@", terminalDestinationPath, error);
        return FALSE;
    }
    
    return terminalDestinationPath;
}

#pragma mark Path methods

- (NSString *)usrPath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/usr"];
}

- (NSString *)xmdsLibraryPath
{
    NSArray *searchURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (![searchURLs count]) {
        NSLog(@"Empty search paths when looking for the user library directory");
        return nil;
    }
    
    if ([searchURLs count] > 1) 
        NSLog(@"Warning: More than one user library path found: %@", searchURLs);
    
    NSString *libraryPath = [(NSURL *)[searchURLs lastObject] path];
    
    NSString *xmdsLibraryPath = [libraryPath stringByAppendingPathComponent:@"XMDS"];
    
    NSError *error = nil;
    
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:xmdsLibraryPath
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to create path %@. Error: %@", xmdsLibraryPath, error);
        
        return nil;
    }
    
    return xmdsLibraryPath;
}

- (NSArray *)documentationPaths
{
    NSString *userDocumentationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:@"src/xmds2/documentation"];
    NSString *appDocumentationPath = [self.usrPath stringByAppendingPathComponent:@"share/xmds/documentation"];
    
    return [NSArray arrayWithObjects:userDocumentationPath,
                                     appDocumentationPath,
                                     nil];
}

 - (NSString *)macosxVersion
 {
     SInt32 major, minor, bugfix;
     Gestalt(gestaltSystemVersionMajor, &major);
     Gestalt(gestaltSystemVersionMinor, &minor);
     Gestalt(gestaltSystemVersionBugFix, &bugfix);
     
     return [NSString stringWithFormat:@"%d.%d.%d", (int)major, (int)minor, (int)bugfix];
 }


@end
