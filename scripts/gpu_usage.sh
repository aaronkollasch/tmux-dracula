#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

get_platform()
{
  case $(uname -s) in
    Linux)
      gpu=$(lspci -v | grep VGA | head -n 1 | awk '{print $5}')
      echo $gpu
      ;;

    Darwin)
      # TODO - Darwin/Mac compatability
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # TODO - windows compatability
      ;;
  esac
}

get_gpu()
{
  gpu=$(get_platform)
  if [[ "$gpu" == NVIDIA ]]; then
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%d%%\n", sum / NR) }')
  else
    usage='unknown'
  fi
  normalize_percent_len $usage
}

main()
{
  gpu_label=$(get_tmux_option "@dracula-gpu-usage-label" "GPU")
  gpu_usage=$(get_gpu)
  echo "$gpu_label $gpu_usage"
}

# run the main driver
main
