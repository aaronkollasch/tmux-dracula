#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

mb_to_gb() {
  if [ $# == 0 ]; then
    read num
  else
    num="$1"
  fi
  bc <<< "scale=3;$num/1024"
}

round() {
  if [ $# == 1 ]; then
    read num
    scale="$1"
  elif [ $# == 2 ]; then
    num="$1"
    scale="$2"
  fi
  printf "%.${scale}f" "${num}"
}

get_percent()
{
  case $(uname -s) in
    Linux)
      total_mem_gb=$(free -m | awk '/^Mem/ {print $2}' | mb_to_gb | round 0)
      used_mem_gb=$(free -m | awk '/^Mem/ {print $3}' | mb_to_gb | round 0)
      if (( $total_mem_gb == 0)); then
        memory_usage=$(free -m | awk '/^Mem/ {print $3}' | round 0)
        total_mem_mb=$(free -m | awk '/^Mem/ {print $2}' | round 0)
        echo "${memory_usage}MB/${total_mem_mb}MB"
      elif (( $used_mem_gb == 0 )); then
        memory_usage=$(free -m | awk '/^Mem/ {print $3}' | round 0)
        echo "${memory_usage}MB/${total_mem_gb}GB"
      else
        memory_usage="${used_mem_gb}"
        echo "${memory_usage}GB/${total_mem_gb}GB"
      fi
      ;;

    Darwin)
      # Get used memory blocks with vm_stat, multiply by page size to get size in bytes, then convert to MiB
      used_mem=$(vm_stat | grep ' active\|wired ' | sed 's/[^0-9]//g' | paste -sd ' ' - | awk -v pagesize=$(pagesize) '{printf "%d\n", ($1+$2) * pagesize / 1048576}')
      total_mem=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2 $3}')
      if (( $used_mem < 1024 )); then
        echo $used_mem\M\B/$total_mem
      else
        memory=$(($used_mem/1024))
        echo $memory\G\B/$total_mem
      fi
      ;;

    FreeBSD)
      # Looked at the code from neofetch
      hw_pagesize="$(sysctl -n hw.pagesize)"
      mem_inactive="$(($(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize))"
      mem_unused="$(($(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize))"
      mem_cache="$(($(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize))"

      free_mem=$(((mem_inactive + mem_unused + mem_cache) / 1024 / 1024))
      total_mem=$(($(sysctl -n hw.physmem) / 1024 / 1024))
      used_mem=$((total_mem - free_mem))
      echo $used_mem
      if (( $used_mem < 1024 )); then
        echo $used_mem\M\B/$total_mem
      else
        memory=$(($used_mem/1024))
        echo $memory\G\B/$total_mem
      fi
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # TODO - windows compatability
      ;;
  esac
}

main()
{
  # storing the refresh rate in the variable RATE, default is 5
  RATE=$(get_tmux_option "@dracula-refresh-rate" 5)
  ram_label=$(get_tmux_option "@dracula-ram-usage-label" "RAM")
  ram_percent=$(get_percent)
  echo "$ram_label $ram_percent"
}

#run main driver
main
