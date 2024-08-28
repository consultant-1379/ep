#!/usr/bin/env bash -x

##############################
# Internal Utility Functions #
##############################

function tput() {
  if [ -f "/usr/bin/tput" ]; then
      /usr/bin/tput $@
  else
      echo ""
  fi
}

function wget() {
  /usr/bin/wget --no-hsts --no-check-certificate $@ 2>wget.err
  res=$?
  if [ $res -ne 0 ] && [ "$(grep 'unrecognized option' wget.err)" ]; then
      /usr/bin/wget $@
      res=$?
  else
      cat wget.err
  fi
  rm wget.err
  return $res
}

function status()
{
   if [[ -t 1 ]]; then
      echo -e "\E[0;35m$1$(tput sgr0)" 2>/dev/null # in purple
   else
      echo $1
   fi
}

function info()
{
   if [[ -t 1 ]]; then
      echo -e "\E[0;32m$1$(tput sgr0)" 2>/dev/null # in purple
   else
      echo $1
   fi
}

function error()
{
   if [[ -t 1 ]]; then
      echo -e "\E[0;31m$1$(tput sgr0)" 2>/dev/null # in red
   else
      echo $1
   fi
}

function parse_git_branch_prompt()
{
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function quiet_git() {
    stdout=tempfile
    stderr=tempfile

    if ! git "$@" </dev/null >$stdout 2>$stderr; then
        cat $stderr >&2
        rm -f $stdout $stderr
        exit 1
    fi
    rm -f $stdout $stderr
}

function setup_root_project_dir()
{
   export EP_ROOT="$(git rev-parse --show-toplevel 2> /dev/null)"
}

function is_substring(){
    case "$2" in
        *$1*) return 0;;
        *) return 1;;
    esac
}

function parse_yaml()
{
    local yaml_file=$1
    local prefix=$2
    local s='[[:space:]]*'
    local w='[a-zA-Z0-9_]*'
    local fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
       -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "${yaml_file}" |
    awk -F"$fs" '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {
            if (i > indent) {
                delete vname[i]
            }
        }
        if (length($3) > 0) {
            vn=""
            for (i=0; i<indent; i++) {
                vn=(vn)(vname[i])("_")
            }
            printf("%s%s%s=%s\n", "'"${prefix}"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

function get_var_value()
{
   # Parameter $1: The pattern to look for the variable- its value.
   local var_patron=$1
   # Parameter $2: The variable to get its value.
   local var_name=$2
   # Parameter $3: The configuration file.
   local configuration_file=$3

   local var_value=$(sed -e '/'"^${var_patron}:"'/,/'"${var_name}:"'/!d' ${configuration_file} |
                            grep ${var_name} | cut -d ":" -f2 |
                            tr "\n" " " | tr -d "[[:space:]]" | tr -d "'")
   echo ${var_value}
}

function set_signum_ericsson()
{
   status "Setting the ericsson signum..."
   local user_name=$(git config --list | grep "user.name" | cut -d "=" -f2)
   if [ ! -z "${user_name}" ] && [ ${#user_name} -eq 7 ] &&
      ([ ${user_name:0:1} = "e" ] || [ ${user_name:0:1} = "x" ]); then
      info "user_name: [${user_name}] ==>> ERICSSON_SIGNUM"
      export ERICSSON_SIGNUM=${user_name}
   else
      local user_id=$(git config --list | grep "user.signum" | cut -d "=" -f2)
      if [ ! -z "${user_id}" ]; then
         info "user_id: [${user_id}] ==>> ERICSSON_SIGNUM"
         export ERICSSON_SIGNUM=${user_id}
      else
         local gerrit_user_id=$(git config --list | grep "remote.origin.url" | cut -d "/" -f3 | cut -d "@" -f1)
         info "gerrit_user_id: [${gerrit_user_id}] ==>> ERICSSON_SIGNUM"
         export ERICSSON_SIGNUM=${gerrit_user_id}
      fi
   fi
}

###############################################################################
# Returns branch name, commit id in case of detached state, or tag identifier if commit id is associated to any; summing up:
# 1) in branch => returns branch name
# 2) in commit-id with tag associated => returns tag name
# 3) in commit-id with no tag associated => returns commit-id (short format)
function git_branch()
{
   local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
   if [ "${branch}" == "HEAD" ]; then
      local last_commit=$(git log -n 1 --format=%h)
      local name_rev=$(git name-rev ${last_commit})
      echo "${name_rev}" | egrep "(.*)( +)tags/" >/dev/null
      if [ $? -eq 0 ]; then
         # Get the tag name, ignore only ^0, but not ^N nor ancestors
         branch=$(echo "${name_rev}" | cut -d/ -f2  | sed 's/\^0//')
      else
         # Last commit
         branch=${last_commit}
      fi
   else
      branch="production_offline"
   fi
   echo ${branch}
}
