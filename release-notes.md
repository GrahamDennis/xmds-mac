CSS: css/github.css

# XMDS 2.1.4-3 "Well if this isn't nice, I don't know what is" [version-2.1.4-3]

This is a Mac OS X-specific release intended to fix some problems with Mac OS X Mavericks.  Please send an email to xmds-user@lists.sourceforge.net if you have any problems.

# XMDS 2.1.4 "Well if this isn't nice, I don't know what is" [version-2.1.4]

The XMDS 2.1.4 update contains many new improvements and bugfixes:

* `xsil2graphics2` now supports all output formats for MATLAB, Octave and Python.  The scripts generated for MATLAB/Octave are compatible with both.
* Fix a bug when [nonlocally][nonlocal-reference] referencing a [dimension alias][dimension-aliases] with subsampling in `sampling_group` blocks or in some situations when MPI is used.  This bug caused incorrect elements of the vector to be accessed.
* Correct the Fourier basis for dimensions using Hermite-Gauss transforms.  Previously 'kx' was effectively behaving as '-kx'.
* Improve the performance of 'nx' <--> 'kx' Hermite-Gauss transforms.
* Stochastic error checking with runtime noise generation now works correctly.  Previously different random numbers were generated for the full-step paths and the half-step paths.
* Documentation updates.

[nonlocal-reference]: http://xmds.org/reference_elements.html#referencingnonlocal
[dimension-aliases]: http://xmds.org/advanced_topics.html#dimension-aliases

# XMDS 2.1.3 "Happy Mollusc" [version-2.1.3]

The XMDS 2.1.3 update is a bugfix release that includes the following improvements:

* XMDS will work when MPI isn't installed (but only for single-process simulations).
* Support for GCC 4.8
* The number of paths used by the multi-path driver can now be specified at run-time (using `<validation kind="run-time">`)
* Other bug fixes

# XMDS 2.1.2a "Happy Mollusc" [version-2.1.2a]

Compatibility fixes for older versions of Mac OS X.

# XMDS 2.1.2 "Happy Mollusc" [version-2.1.2]

We have published a paper in Computer Physics Communications.  If you use XMDS2 in your research, we would appreciate it if you cited us in your publications:

[G.R. Dennis, J.J. Hope, and M.T. Johnsson, Computer Physics Communications 184, 201–208 (2013)][CPCPaper]

The XMDS 2.1.2 update has many improvements:

* Named filters.  You can now specify a name for a filter block and call it like a function if you need to execute it conditionally.  See the documentation for the `<filter>` block for more information.
* New `chunked_output` feature.  XMDS can now output simulation results as it goes, reducing the memory requirement for simulations that generate significant amounts of output.  See the documentation for more details.
* Improved OpenMP support
* The EX operator is now faster in the common case (but you should still prefer IP when possible)
* If seeds are not provided for a `noise_vector`, they are now generated at simulation run-time, so different executions will give different results.  The generated noises can still be found in the output .xsil files enabling results to be reproduced if desired.
* Advanced feature: Dimensions can be accessed non-locally with the index of the lattice point.  This removes the need in hacks to manually access XMDS's underlying C arrays.  This is an advanced feature and requires a little knowledge of XMDS's internal grid representation.  See the advanced topics documentation for further details.
* Fixed adaptive integrator order when noises were used in vector initialisation
* Fix the Spherical Bessel basis.  There were errors in the definition of this basis which made it previously unreliable.
* Other bug fixes

[CPCPaper]: http://dx.doi.org/10.1016/j.cpc.2012.08.016

# XMDS 2.1 "Happy Mollusc" [version-2.1]

XMDS 2.1 is a significant upgrade with many improvements and bug fixes since 2.0. We also now have installers for Linux and Mac OS X, so you no longer have to build XMDS from source! See [http://www.xmds.org/installation.html](http://www.xmds.org/installation.html) for details about the installers.

The documentation has been expanded significantly with a better tutorial, more worked examples, and description of all XMDS 2 script elements.  Take a look at the new documentation at [http://www.xmds.org](http://www.xmds.org)

Existing users should note that this release introduces a more concise syntax for moment groups.  You can now use:

    <sampling_group initial_sample="yes" basis="x y z">
        ...
    </sampling_group>
Instead of:

    <group>
        <sampling initial_sample="yes" basis="x y z">
            ...
        </sampling>
    </group>

Another syntax change is that the initial basis of a vector should be specified with `initial_basis` instead of `initial_space`.

In both cases, although the old syntax is not described in the documentation, it is still supported, so existing scripts will work without any changes.


Other changes in XMDS 2.1 include:

* The `lattice` attribute for dimensions can now be specified at run-time.  Previously only the minimum and maximum values of the domain could be specified at run-time.  See [http://www.xmds.org/reference_elements.html#validation](http://www.xmds.org/reference_elements.html#validation) for details.
* `noise_vector`s can now be used in non-uniform dimensions (e.g. dimensions using the Bessel transform for cylindrical symmetry).
* "loose" `geometry_matching_mode` for HDF5 vector initialisation.  This enables extending the simulation grid from one simulation to the next, or coarsening or refining a grid when importing.
* `vector`s can now be initialised by integrating over dimensions of other vectors.  `computed_vector`s always supported this, now `vector`s do too.
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
