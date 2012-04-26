CSS: css/github.css

# XMDS 2.1 "Happy Mollusc" [version-2.1]

XMDS 2.1 includes a number of bug fixes and improvements since 2.0, as well as the new Linux and Mac OS X installers.

Changes include:

* `noise_vector`s can now be used in non-uniform dimensions (e.g. dimensions using the Bessel transform for cylindrical symmetry).
* "loose" `geometry_matching_mode` for HDF5 vector initialisation.  This enables extending the simulation grid from one simulation to the next, or coarsening or refining a grid when importing.
* Update to latest version of [waf], which is used for compiling simulations and detecting FFTW, HDF5, etc. This should lead to fewer waf-related problems.
* Bug fixes.

[waf]: http://code.google.com/p/waf

# XMDS 2.1β8 [version-2.1beta8]

This release actually adds support for Xcode 4.3.


# XMDS 2.1β7 [version-2.1beta7]

This release adds support for Xcode 4.3.  You can now just install the [Command Line Tools for Xcode][CommandLineTools], a ~170Mb download instead of the full Xcode package which is ~1.3Gb.

The 'XMDS Terminal' feature now works for users who have changed their shell from the default (`bash`).

[CommandLineTools]: https://developer.apple.com/downloads/index.action?=Command%20Line%20Tools

# XMDS 2.1β6 [version-2.1beta6]

Bugfix release.

This release corrects an issue in XMDS 2.1β5 where in renaming the `initial_space` attribute to `initial_basis`, we failed to make the change backward compatible.

# XMDS 2.1β5 [version-2.1beta5]

Mac installer changes:

* Fix an issue that could occur if you had manually installed `gzip`.
* The 'Update to Development Version' window is dismissed when you choose to update.
* `man`-pages are now included.
* Minor changes.

XMDS changes:

* Updated documentation with information about Linux and Mac installers.
* Updated Linux installer script.
* You can now specify `volume_prefactor` on dimensions to modify the metric factor.  This is useful for Bessel-transform and DCT dimensions.
* Configuration improvements.

# XMDS 2.0 "Shiny!" [version-2.0]

XMDS 2.0 is a major upgrade which has been rewritten from the ground up to make it easier for us to apply new features. And there are many. XMDS 2.0 is faster and far more versatile than previous versions, allowing the efficient integration of almost any initial value problem on regular domains.

The feature list includes:

* Quantities of different dimensionalities. So you can have a 1D potential and a 3D wavefunction.
* Integrate more than one vector (in more than one geometry), so you can now simultaneously integrate a PDE and a coupled ODE (or coupled PDEs of different dimensions).
* Non-Fourier transformations including the Bessel basis, Spherical Bessel basis and the Hermite-Gauss (harmonic oscillator) basis.
* The ability to have more than one kind of noise (gaussian, poissonian, etc) in a simulation.
* Integer-valued dimensions with non-local access. You can have an array of variables and access different elements of that array.
* Significantly better error reporting. When errors are found when compiling the script they will almost always be reported with the corresponding line of your script, instead of the generated source.
* `IP`/`EX` operators are separate from the integration algorithm, so you can have both `IP` and `EX` operators in a single integrate block. Also, `EX` operators can act on arbitrary code, not just vector components. (e.g. `L[phi*phi]`).
* Cross propagation in the increasing direction of a given dimension or in the decreasing dimension. And you can have more than one cross-propagator in a given integrator (going in different directions or dimensions).
* Faster Gaussian noises.
* The ability to calculate spatial correlation functions.
* OpenMP support.
* MPI support.
* Output moment groups use less memory when there isn't a `post_processing` element.
* Generated source is indented correctly.
* An `xmds1`-like script file format.
* `xmds1`-like generated source.
* All of the integrators from `xmds1` (`SI`, `RK4`, `ARK45`, `RK9`, `ARK89`).
