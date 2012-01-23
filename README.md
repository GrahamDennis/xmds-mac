# Instructions for building the XMDS Mac app

Requirements: 

* `gcc-4.5` from MacPorts, `clang-3.1` from MacPorts. These are needed to build FFTW with AVX support. Update `BuildScripts/as` and `BuildScripts/fftw.sh` if you're using newer versions.
* `file` from MacPorts, and `python-magic` (`sudo easy_install python-magic`) 

Steps for a complete checkout:

1.  `git submodule init`
2.  `git submodule update`

Steps to build precompiled packages:

1.  Update the versions of the bundled packages.
	Edit the `*_VERSION` lines at the top of `BuildScripts/build.sh`
2.  If there's a specific version of `xmds2` you want to bundle, edit `BuildScripts/xmds2-checkout.sh`. Otherwise, `HEAD` will be packaged as of now.
3.  In `BuildScripts` run `./build.sh` to compile the bundled packages.  This will take a while. Probably an hour or so.

Steps to build XMDS.app:

1.  Open `XMDS/xmds.keychain` to add the XMDS private key (used for signed updates) to your keychain
	For the password, just ask Joe. In fact, many people who know Joe will know the password.
2.  Tag this build with the version number you want to release with. For example: `git --tag 2.1`
3.  Launch Xcode and open `XMDS.xcodeproj`
4.  Select the 'Distribute' target, and click 'Run'.
5.  Go to the messages section (Log navigator) to look at the log info for XMDS. There are instructions there for the remainder of the release process.  

	The first line copies the zip file produced to SourceForge.
	The second line asks you to merge the `appcast/appcast-VERSION_NUMBER.xml` file into `appcast/appcast.xml`. The appcast.xml file (once published to the web) is how existing installations of XMDS know there's a new version out.
	The third line tells you how to copy the appcast file and the release notes to the SourceForge website.
