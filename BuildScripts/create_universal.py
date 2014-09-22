#!/usr/bin/env python
# encoding: utf-8
"""
create_universal.py

Created by Graham Dennis on 2011-12-19.
Copyright (c) 2011 __MyCompanyName__. All rights reserved.
"""

import sys
import os, filecmp, shutil, stat, subprocess, magic

base_32 = 'output32'
base_64 = 'output64'
base_universal = 'output'
base_noarch = 'output_noarch'

mime_guesser = magic.Magic(mime=True)

BASE_HEADER_TEMPLATE = """
#ifndef %(DEFINE_GUARD)s
#define %(DEFINE_GUARD)s

#if defined (__i386__)
#include <i386/%(include_file)s>
#elif defined (__x86_64__)
#include <x86_64/%(include_file)s>
#else
#error architecture not supported
#endif

#endif /* %(DEFINE_GUARD)s */
"""


def recursive_diff(relpath):
    diff = filecmp.dircmp(os.path.join(base_32, relpath), os.path.join(base_64, relpath))
    if not os.path.exists(os.path.join(base_universal, relpath)):
        os.makedirs(os.path.join(base_universal, relpath))
    
    if len(diff.left_only) > 0 or len(diff.right_only) > 0:
        print "WARNING: Some files are not in common!"
        print "left:", diff.left_only
        print "right:", diff.right_only
    
    # Copy identical files
    for filename in diff.same_files:
        shutil.copy2(os.path.join(base_32, relpath, filename), os.path.join(base_universal, relpath, filename))
    
    # Now deal with different files
    for filename in diff.diff_files:
        left_path  = os.path.join(base_32, relpath, filename)
        right_path = os.path.join(base_64, relpath, filename)
        out_path = os.path.join(base_universal, relpath, filename)
        
        extension = os.path.splitext(filename)[1]
        if extension in ['.dylib', '.a', '.so'] or extension == '' and (mime_guesser.from_file(left_path).startswith('application') or mime_guesser.from_file(left_path).startswith('binary')):
            lipo_combine(relpath, filename)
        elif extension in ['.h']:
            header_combine(relpath, filename)
        elif extension in ['.la', '.pc'] or filename in ['libhdf5.settings']:
            pass # Ignore the file
        elif relpath.startswith('share/openmpi') and extension == '.txt':
            fixup_mpi_txt(relpath, filename)
        elif os.path.islink(left_path):
            if not os.path.lexists(out_path):
                assert os.readlink(left_path) == os.readlink(right_path)
                os.symlink(os.readlink(left_path), out_path)
        else:
            print "Assuming different files '%s' are executable, and using a selector to choose." % os.path.join(relpath, filename)
            shutil.copy2(os.path.join(base_noarch, "..", "arch_selector"), out_path)

            i386_base_path = os.path.join(base_universal, relpath, "i386")
            if not os.path.exists(i386_base_path): os.makedirs(i386_base_path)
            shutil.copy2(left_path, os.path.join(i386_base_path, filename))

            x86_64_base_path = os.path.join(base_universal, relpath, "x86_64")
            if not os.path.exists(x86_64_base_path): os.makedirs(x86_64_base_path)
            shutil.copy2(right_path, os.path.join(x86_64_base_path, filename))
    
    for dirname in diff.common_dirs:
        recursive_diff(os.path.join(relpath, dirname))


def lipo_combine(relpath, filename):
    subprocess.call(["lipo", "-create", "-arch", "i386",   os.path.join(base_32, relpath, filename),
                                        "-arch", "x86_64", os.path.join(base_64, relpath, filename),
                                        "-output", os.path.join(base_universal, relpath, filename)])


def header_combine(relpath, filename):
    include_file = os.path.relpath(os.path.join(relpath, filename), 'include')
    DEFINE_GUARD = '_MACHINE_' + include_file.replace('/','_').replace('.', '_').upper() + "_"
    
    f = open(os.path.join(base_universal, relpath, filename), 'w')
    f.write(BASE_HEADER_TEMPLATE % dict(DEFINE_GUARD=DEFINE_GUARD, include_file=include_file))
    f.close()
    
    if not os.path.exists(os.path.join(base_universal, 'include', os.path.dirname(include_file))):
        os.makedirs(os.path.join(base_universal, 'include', os.path.dirname(include_file)))
    if not os.path.exists(os.path.join(base_universal, 'include', 'i386', os.path.dirname(include_file))):
        os.makedirs(os.path.join(base_universal, 'include', 'i386', os.path.dirname(include_file)))
    if not os.path.exists(os.path.join(base_universal, 'include', 'x86_64', os.path.dirname(include_file))):
        os.makedirs(os.path.join(base_universal, 'include', 'x86_64', os.path.dirname(include_file)))
    
    shutil.copy2(os.path.join(base_32, 'include', include_file), os.path.join(base_universal, 'include', 'i386', include_file))
    shutil.copy2(os.path.join(base_64, 'include', include_file), os.path.join(base_universal, 'include', 'x86_64', include_file))


def fixup_mpi_txt(relpath, filename):
    lines = []
    for line in open(os.path.join(base_64, relpath, filename), 'r').readlines():
        if line.startswith('compiler='):
            line = 'compiler=g++\n' if '++' in line else 'compiler=gcc\n'
        lines.append(line)
    open(os.path.join(base_universal, relpath, filename), 'w').write(''.join(lines))

def main():
    recursive_diff('lib')
    recursive_diff('bin')
    recursive_diff('include')
    recursive_diff('share/man')
    recursive_diff('share/openmpi')
    recursive_diff('etc')
    os.system("cp -r output_noarch/ output/")


if __name__ == '__main__':
    main()

