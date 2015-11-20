#!/usr/bin/env python
# encoding: utf-8
"""
create_universal.py

Created by Graham Dennis on 2011-12-19.
Copyright (c) 2011 __MyCompanyName__. All rights reserved.
"""

import sys
import os, filecmp, shutil, stat, subprocess, magic, re

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
    extension = os.path.splitext(filename)[1]
    if extension in ['.dylib', '.so', '']:
        fixup_lib_paths(relpath, filename)
    
    subprocess.call(["lipo", "-create", "-arch", "i386",   os.path.join(base_32, relpath, filename),
                                        "-arch", "x86_64", os.path.join(base_64, relpath, filename),
                                        "-output", os.path.join(base_universal, relpath, filename)])

def fixup_lib_paths(relpath, filename):
    fixup_lib_paths_for(base_32, relpath, filename)
    fixup_lib_paths_for(base_64, relpath, filename)

otool_regex = re.compile(r'\t(.*) \(compatibility.*\)$')

def fixup_lib_paths_for(prefix, relpath, filename):
    otool = subprocess.Popen(["otool", "-L", os.path.join(prefix, relpath, filename)], stdout=subprocess.PIPE)
    lines = otool.communicate()[0].splitlines()
    
    matches = [otool_regex.match(line) for line in lines]

    absolute_path = os.path.abspath('.')
    lib_paths = [match.group(1) for match in matches if match]
    lib_paths = [path for path in lib_paths if os.path.commonprefix([absolute_path, path]).startswith(absolute_path)]
    
    if len(lib_paths) == 0:
        return 

    new_filename = filename + ".fixed"
    shutil.copy2(os.path.join(prefix, relpath, filename), os.path.join(prefix, relpath, new_filename))

    args = ['install_name_tool']
    for lib_path in lib_paths:
        relative_path = os.path.relpath(lib_path, os.path.join(absolute_path, prefix, relpath))
        # print "(%s): %s from %s is %s" % (os.path.join(prefix, relpath, filename), lib_path, absolute_path, relative_path)
        args.extend(['-change', lib_path, "@loader_path/" + relative_path])
    args.append(os.path.join(prefix, relpath, new_filename))
    subprocess.check_call(args)
    shutil.move(os.path.join(prefix, relpath, new_filename), os.path.join(prefix, relpath, filename))


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

