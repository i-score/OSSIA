OSSIA
=====

The base repository for the OSSIA project. Contains initialization and build scripts.

For now, there is a build script that works for Unix OSes.
Every command are detailed when called with `--help`.

Setup
=====
If you want to try the current i-score release quickly, run : 

    ./Build.sh jamoma iscore --clone --install-deps

If you want to try the next version of i-score (0.3), which is only at the prototype state run : 

    ./Build.sh jamoma iscore-recast --clone --install-deps

Setup for developers
====================
In the name of quickness, the commands only fetch the latest git commits, which can be a problem if you want to develop, switch branches, etc...

So if you want to develop, please add the --fetch-all command.

Old setup (Mac OS X only)
=========================
Follow this if you already have some parts of the OSSIA project on your computer.

If you already have a Jamoma / Score installed using the Ruby scripts : 

    ./Build.sh iscore --clone --classic --install-deps

Or if you already have Jamoma but not Score

    ./Build.sh jamoma iscore --clone --classic --install-deps --jamoma-path=/Path/To/Jamoma/Core/folder
    
Additional notes
================
For Linux, Jamoma is packed either on a Debian package for Debian, Ubuntu or RPM for Fedora and installed, so it might ask your root password.
On OS X, due to the lack of package manager, make install is called. However, a recipe for Macports is provided on https://github.com/ChristianFrisson/MacPortsCycles
