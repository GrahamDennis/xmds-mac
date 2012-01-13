//
//  XMDSAppDelegate.m
//  XMDS
//
//  Created by Graham Dennis on 10/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSAppDelegate.h"

@interface XMDSAppDelegate ()

- (NSURL *)writeTerminalFile;

@end

@implementation XMDSAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (NSString *)usrPath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/usr"];
}

- (IBAction)launchXMDSTerminal:(id)sender
{
    NSURL *terminalURL = [self writeTerminalFile];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (NSURL *)writeTerminalFile
{
    NSString *terminalTemplatePath = [[NSBundle mainBundle] pathForResource:@"XMDS"
                                                                     ofType:@"terminal"];
    
    if (!terminalTemplatePath) {
        NSLog(@"Couldn't find XMDS.terminal");
        return nil;
    }
    
    NSError *error = nil;
    
    NSString *terminalContents = [NSString stringWithContentsOfFile:terminalTemplatePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    
    if (error) {
        NSLog(@"Couldn't read XMDS.terminal content. Error: %@", error);
        return nil;
    }
    
    NSString *interpolatedTerminalContent = [terminalContents stringByReplacingOccurrencesOfString:@"${XMDS_USR}"
                                                                                        withString:self.usrPath];
    
    NSArray *searchURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (![searchURLs count]) {
        NSLog(@"Empty search paths when looking for the user library directory");
        return nil;
    }
    
    for (NSURL *libraryURL in searchURLs) {
        NSURL *xmdsLibraryURL = [libraryURL URLByAppendingPathComponent:@"XMDS"];
        
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:xmdsLibraryURL withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (!result || error) {
            NSLog(@"Unable to create path %@. Error: %@", xmdsLibraryURL, error);
            error = nil;
            
            // Try next URL...
            continue;
        }
        
        NSURL *terminalURL = [xmdsLibraryURL URLByAppendingPathComponent:@"XMDS.terminal"];
        
        result = [interpolatedTerminalContent writeToURL:terminalURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (!result || error) {
            NSLog(@"Unable to write terminal file to URL: %@. Error: %@", terminalURL, error);
            error = nil;
            
            // Try next URL...
            continue;
        }
        
        return terminalURL;
    }
    
    NSLog(@"Couldn't write a terminal file");
    return nil;
}


@end
