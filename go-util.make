# Just a bunch of useful subroutines

# same as $(dir) but if there is no dir, returns empty instead of './'
DIR_OF=$(filter-out ./,$(dir $1))

# for 'dir' returns 'dir/'
# for '/dir' returns '/dir/'
# for '' returns ''
DIR_AS_PREFIX=$(if $1,$(patsubst %/,%,$1)/,)

# same as above, but for '' returns './'
DIR_AS_EXE_PREFIX=$(if $1,$(patsubst %/,%,$1)/,./)

# if not empty adds -I prefix, otherwise leaves empty
DIR_AS_I_FLAG=$(if $1,-I$(patsubst %/,%,$1),)

# if not empty adds -L prefix, otherwise leaves empty
DIR_AS_L_FLAG=$(if $1,-L$(patsubst %/,%,$1),)

# if not empty prepends space
PRESPACE=$(if $1,$(space)$1,)

# if not empty prepends "cd $1 &&"
CDPREFIX=$(if $1,cd $1 &&,)

# if not empty makes it: "mkdir -p $1"
MKDIRP=$(if $1,mkdir -p $1,)

# vim: ft=make
