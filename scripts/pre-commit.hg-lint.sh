#!/bin/bash
# Copyright 2013-2014 Sebastian Kreft
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

RED='\033[0;31m'
CLEAR='\033[0m'

# First part return the files being commited, excluding deleted files.
if [ "$NO_VERIFY" != "" ]; then
    exit 0
fi

# Builds a list of removed files to display them before proceeding with the linters
# Allow developer to review if something was accidentally removed and fix
has_removed_files(){
  declare -a REMOVED
  readarray -t REMOVED <<< $(hg status -r -d)

  if [ "$(echo -ne ${REMOVED[@]} | wc -m)" -gt 0 ]; then
    printf "%b" $RED
    echo "============== WARNING: FILE REMOVAL FOUND ================"
    echo " The following were removed:"
    printf "%s\n" "${REMOVED[@]}"
    echo "==========================================================="
  fi
}

has_removed_files


# Add switches to check for -m (modified) and -a (added files)
# removed and deleted files don't need to be checked ;)
hg status -m -a --change $HG_NODE | cut -b 3- | tr '\n' '\0' |
xargs --null --no-run-if-empty git-lint;

if [ "$?" != "0" ]; then
  echo "There are some problems with the modified files.";
  echo "Fix them before committing or suggest a change to the rules defined in REPO_HOME/.gitlint.yaml.";
  echo "If it is not possible to fix them all commit with NO_VERIFY=1 hg commit ... .";

  exit 1;
fi
