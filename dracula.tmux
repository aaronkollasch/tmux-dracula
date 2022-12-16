#!/usr/bin/env bash

# source and run dracula theme

if [[ $LC_RETRO != yes ]]; then
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  $current_dir/scripts/dracula.sh
fi

