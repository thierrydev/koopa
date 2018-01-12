if [[ -n "$PS1" ]]; then
    echo "==== seqcloud ============================================================="
    echo "==========================================================================="
fi

# Alternate methods:
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
# case "$-" in
# *i*)	echo This shell is interactive ;;
# *)	echo This shell is not interactive ;;
# esac
#
# if [ -z "$PS1" ]; then
#         echo This shell is not interactive
# else
#         echo This shell is interactive
# fi
