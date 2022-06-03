
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
end

if test -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh
  fenv source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
end

set -x fish_color_normal '#feffff' # the default color
set -x fish_color_command '#8bada8' # the color for commands
set -x fish_color_quote '#c4c47d' # the color for quoted blocks of text
set -x fish_color_redirection '#e9e950' #   the color for IO redirections
set -x fish_color_end '#e9e950' # the color for process separators like ';' and '&'
set -x fish_color_error '#e2a690' # the color used to highlight potential errors
set -x fish_color_param '#9bcac4' # the color for regular command parameters
set -x fish_color_comment '#646565' # the color used for code comments
set -x fish_color_match '#e9e950' # the color used to highlight matching parenthesis
# fish_color_selection, the color used when selecting text (in vi visual mode)
# fish_color_search_match, used to highlight history search matches and the selected pager item (must be a background)
# set -x fish_color_operator '#F1FF52' # the color for parameter expansion operators like '*' and '~'
# fish_color_escape, the color used to highlight character escapes like '\n' and '\x70'

#fish_color_cwd, the color used for the current working directory in the default prompt
set -x fish_color_autosuggestion '#646565' # the color used for autosuggestions
#fish_color_user, the color used to print the current username in some of fish default prompts
#fish_color_host, the color used to print the current host system in some of fish default prompts
#fish_color_host_remote, the color used to print the current host system in some of fish default prompts, if fish is running remotely (via ssh or similar)
#fish_color_cancel, th


# Bobthefish
function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'
  set -l grey   323232 # a bit darker than normal zenburn grey
  set -l white  feffff
  set -l red    e2a690
  set -l green  9bca9f
  set -l yellow c4c47d
  set -l orange cea16b
  set -l blue   5f91ae

  set -x color_initial_segment_exit     $grey $red --bold
  set -x color_initial_segment_su       $white $green --bold
  set -x color_initial_segment_jobs     $white $blue --bold

  set -x color_path                     $grey $white
  set -x color_path_basename            $grey $white --bold
  set -x color_path_nowrite             $grey $red
  set -x color_path_nowrite_basename    $grey $red --bold

  set -x color_repo                     $green $grey --bold
  set -x color_repo_work_tree           $grey $grey --bold
  set -x color_repo_dirty               $red $grey
  set -x color_repo_staged              $yellow $grey

  set -x color_vi_mode_default          $grey $yellow --bold
  set -x color_vi_mode_insert           $green $white --bold
  set -x color_vi_mode_visual           $yellow $grey --bold

  set -x color_vagrant                  $blue $green --bold
  set -x color_k8s                      $green $white --bold
  set -x color_username                 $grey $blue --bold
  set -x color_hostname                 $grey $blue
  set -x color_rvm                      $red $grey --bold
  set -x color_nvm                      $green $white --bold
  set -x color_virtualfish              $blue $grey --bold
  set -x color_virtualgo                $blue $grey --bold
  set -x color_desk                     $blue $grey --bold
end

function jwtFromClipboard
  pbpaste | jwt decode -j - | jq
end

set -x KUBECONFIG "$KUBECONFIG:$HOME/.kube/config"

kubectl completion fish | source

set -gx PATH $PATH (ruby -e 'print Gem.user_dir')/bin

# Nix
# if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
#   fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
# end
# End Nix