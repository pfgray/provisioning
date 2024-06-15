#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

contents=""


if [ -z "${1-}" ]; then
  contents=$(cat -)
else
  contents=$(cat "${1-}")
fi

home_team_name=$(echo "$contents" | sed -nr 's/var HomeTeam = "(.*)";/\1/p' | awk '{$1=$1};1')
home_team_id=$(echo "$contents" | sed -nr 's/var HomeId = "(.*)";/\1/p' | awk '{$1=$1};1')
away_team_name=$(echo "$contents" | sed -nr 's/var AwayTeam = "(.*)";/\1/p' | awk '{$1=$1};1')
away_team_id=$(echo "$contents" | sed -nr 's/var AwayId = "(.*)";/\1/p' | awk '{$1=$1};1')

game_stats=$(echo "$contents" | sed -nr 's/var db_Elements = (.*);/\1/p' | awk '{$1=$1};1')

date=$(echo "$contents" | sed -nr 's/Monday (.*)<br>/\1/p' | awk '{$1=$1};1')

goals=$(echo "$game_stats" | jq -r '.[] | select(.type == "goal") | .team')

home_team_goals=0
away_team_goals=0

export away_team_name
export home_team_name
export date
# Add title template
BODY=$(envsubst < title_template)

echo "computed:"
echo "$BODY"

item_number=0

for goal in $goals; do
  item_number=$((item_number + 1))
  if [ "$goal" == "$home_team_id" ]; then
    home_team_goals=$((home_team_goals + 1))
    echo "$away_team_name $away_team_goals"
    echo "$home_team_name $home_team_goals"
    echo "----"
    export item_number
    export home_team_goals
    export away_team_goals
    BODY="$BODY $(envsubst < score_template)"
  else
    away_team_goals=$((away_team_goals + 1))
    echo "$away_team_name $away_team_goals"
    echo "$home_team_name $home_team_goals"
    echo "----"
    export item_number
    export home_team_goals
    export away_team_goals
    BODY="$BODY $(envsubst < score_template)"
  fi
done

echo "computed body:"
echo "$BODY"



