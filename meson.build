#
# Global Project Setup
#

project(
        'dbus-broker',
        default_options: [
                'c_std=c11',
                'rust_std=2021',
        ],
        license: 'Apache-2.0',
        meson_version: '>=1.3',
        version: '37',
)

add_languages('c', native: false)
add_languages('rust', native: false)

bindgen_msv = '0.60'
rust_edition = '2021'
rust_msv = '1.84'

cc = meson.get_compiler('c')
conf = configuration_data()
mod_pkgconfig = import('pkgconfig')
mod_rust = import('rust')
rust = meson.get_compiler('rust')

#
# System Requirements
#

if rust.version().version_compare('<' + rust_msv)
        error('Found Rust ' + rust.version() + ' but requires >=' + rust_msv)
endif

bindgen_prog = find_program('bindgen', native: true, required: true, version: '>=' + bindgen_msv)
bindgen_version = bindgen_prog.version()

#
# Mandatory Dependencies
#

dep_cdvar = dependency('libcdvar-1', version: '>=1.1.0')
dep_cini = dependency('libcini-1', version: '>=1.1.0')
dep_clist = dependency('libclist-3', version: '>=3.1.0')
dep_crbtree = dependency('libcrbtree-3', version: '>=3.2.0')
dep_cshquote = dependency('libcshquote-1', version: '>=1.1.0')
dep_cstdaux = dependency('libcstdaux-1', version: '>=1.5.0')
dep_math = cc.find_library('m')
dep_thread = dependency('threads')

dep_libc_rs = dependency(
        'libc-rs-0.2',
        default_options: {
                'warning_level': '0',
        },
        version: '>=0.2.175',
)

dep_osi = dependency(
        'libosi-1',
        default_options: {
                'libc': true,
                'std': true,
        },
        version: '>=1.0.0',
)

#
# Default CFLAGS
#

add_project_arguments(dep_cstdaux.get_variable('cflags').split(' '), language: 'c')
add_project_arguments('-D_TIME_BITS=64', language: 'c')
add_project_arguments('-DBINDIR="' + join_paths(get_option('prefix'), get_option('bindir')) + '"', language: 'c')
add_project_arguments('-DPACKAGE_VERSION="' + meson.project_version() + '"', language: 'c')

#
# Config: apparmor
#

use_apparmor = get_option('apparmor')
if not use_apparmor
        error('This release patch set requires AppArmor support (-D apparmor=true)')
endif
if use_apparmor
        dep_libapparmor = dependency('libapparmor', version: '>=3.0')
endif

#
# Config: audit
#

use_audit = get_option('audit')
if use_audit
        error('This release patch set disables audit support (-D audit=false)')
endif
if use_audit
        dep_libaudit = dependency('audit', version: '>=3.0')
        dep_libcapng = dependency('libcap-ng', version: '>=0.6')
endif

#
# Config: docs
#

use_docs = get_option('docs')
if use_docs
        prog_rst2man = find_program('rst2man', 'rst2man.py')
endif

#
# Config: doctest
#

use_doctest = get_option('doctest')

#
# Config: launcher
#

use_launcher = get_option('launcher')
if use_launcher
        system_uid_max = '999'
        system_unit_dir = join_paths(get_option('prefix'), 'lib/systemd/system')
        user_unit_dir = join_paths(get_option('prefix'), 'lib/systemd/user')
        catalog_dir = join_paths(get_option('prefix'), 'lib/systemd/catalog')

        dep_expat = dependency('expat', version: '>=2.2')
        dep_libsystemd = dependency('libsystemd', version: '>=230')
        dep_systemd = dependency('systemd', version: '>=230', required: false)
        if dep_systemd.found()
                system_uid_max = dep_systemd.get_variable('systemuidmax')
                system_unit_dir = dep_systemd.get_variable('systemdsystemunitdir')
                user_unit_dir = dep_systemd.get_variable('systemduserunitdir')
                catalog_dir = dep_systemd.get_variable('catalogdir')
        else
                message('systemd pkg-config metadata unavailable; using fallback install paths and SYSTEMUIDMAX=999')
        endif

        add_project_arguments('-DSYSTEMUIDMAX=' + system_uid_max, language: 'c')
        conf.set('systemunitdir', system_unit_dir)
        conf.set('userunitdir', user_unit_dir)
        conf.set('catalogdir', catalog_dir)
endif

#
# Config: reference-test
#

use_reference_test = get_option('reference-test')
if use_reference_test
        dep_dbus = dependency('dbus-1', version: '>=1.10')
endif

#
# Config: selinux
#

use_selinux = get_option('selinux')
if use_selinux
        error('This release patch set disables SELinux support (-D selinux=false)')
endif
if use_selinux
        dep_libselinux = dependency('libselinux', version: '>=3.2')
endif

#
# Config: system-console-users
#

use_system_console_users = get_option('system-console-users')

acc_sysusers = ''
foreach user : use_system_console_users
        acc_sysusers += '"' + user + '",'
endforeach

add_project_arguments('-DSYSTEM_CONSOLE_USERS=' + acc_sysusers, language: 'c')

#
# Config: tests
#

use_tests = get_option('tests')
conf.set('testdir', get_option('prefix') / 'lib/dbus-broker/tests')

#
# Global Parameters
#

conf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))

#
# Subdirs
#

subdir('src')

if use_docs
        subdir('docs')
endif

if use_launcher
        subdir('test/dbus')
endif
