#!/bin/sh
# shellcheck disable=SC2236

# Include bcbio toolkit binaries in PATH, if defined.
# Modified 2019-06-25.

# Attempt to locate bcbio installation automatically on supported platforms.

if [ -z "${BCBIO_EXE:-}" ]
then
    if [ ! -z "${HARVARD_O2:-}" ]
    then
        BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ ! -z "${HARVARD_ODYSSEY:-}" ]
    then
        BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    else
        BCBIO_EXE=
    fi
fi

# Export in PATH, if accessible.
if [ -x "$BCBIO_EXE" ]
then
    export BCBIO_EXE
    unset -v PYTHONHOME PYTHONPATH
    bin_dir="$(dirname "$BCBIO_EXE")"
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    force_add_to_path_end "$bin_dir"
    unset -v bin_dir
else
    unset -v BCBIO_EXE
fi
