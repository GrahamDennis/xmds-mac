# Stuff that needs to be done

* Update for Xcode 4.3 and test.

    I suspect that the command line compiler tools don't exist by default any more when you install Xcode.  We now need to test whether or not they exist, and prompt the user to install them.
    
    If we were to permit the user to use compilers other than Xcode's, we'd need to obtain the PATH set by their default shell.  Worse, we would then need to pass this information through to the 'XMDS Terminal'.

* The 'XMDS Terminal' only works if the user's default shell is `bash`.  We should either make it work with any shell, or enforce the shell to be `bash`.

The only way to reconcile these two features is either to make 'XMDS Terminal' work with any shell by using only features available in `sh`, or only work with Xcode's compilers.  Unfortunately, `sh` syntax and `csh` syntax are not compatible essentially by design.

