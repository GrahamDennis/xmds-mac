# Stuff that needs to be done

* Update for Xcode 4.3 and test.

    I suspect that the command line compiler tools don't exist by default any more when you install Xcode.  We now need to test whether or not they exist, and prompt the user to install them.
    
    If we were to permit the user to use compilers other than Xcode's, we'd need to obtain the PATH set by their default shell.  Worse, we would then need to pass this information through to the 'XMDS Terminal'.
    
    We will not permit other compilers. It's that simple. We work with a known configuration. If someone wants something else, they can install manually.  XMDS.app is all about just working.  Thus perhaps the best solution is to determine the compiler path using `xcrun`.  We then need to set DEVELOPER_DIR to the /Developer dir (for Xcode 4.2) or /Applications/Xcode.app (or /Applications/Xcode.app/Contents/Developer) for Xcode 4.3.  Fortunately, Xcode.app 4.2 and earlier is in a fixed location relative to the /Developer directory. Xcode.app is in /Developer/Applications/Xcode.app.  Of course, this all needs testing.

* The 'XMDS Terminal' only works if the user's default shell is `bash`.  We should either make it work with any shell, or enforce the shell to be `bash`.

The only way to reconcile these two features is either to make 'XMDS Terminal' work with any shell by using only features available in `sh`, or only work with Xcode's compilers.  Unfortunately, `sh` syntax and `csh` syntax are not compatible essentially by design.

