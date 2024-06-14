#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

output=""

if [ -z "${1-}" ]; then
  echo "no gamesheet specified"
  echo "usage: process-gamesheet <gamesheel.html>"
  exit 1;
fi

contents=$(cat "${1-}")


home_team_name=$(sed -nr 's/var HomeTeam = "(.*)";/\1/p' gamesheet.html | awk '{$1=$1};1')
home_team_id=$(sed -nr 's/var HomeId = "(.*)";/\1/p' gamesheet.html | awk '{$1=$1};1')

away_team=$(sed -nr 's/var AwayTeam = "(.*)";/\1/p' gamesheet.html | awk '{$1=$1};1')
away_team_id=$(sed -nr 's/var AwayId = "(.*)";/\1/p' gamesheet.html | awk '{$1=$1};1')


game_stats=$(sed -nr 's/var db_Elements = (.*);/\1/p' gamesheet.html | awk '{$1=$1};1')







