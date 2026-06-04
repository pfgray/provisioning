{ pkgs, config, lib, ... }:

let
  git-checkout = pkgs.writeShellScriptBin "git-checkout" ''
    ${builtins.readFile ./checkout/git-checkout}
  '';
  git-checkout-recent = pkgs.writeShellScriptBin "git-checkout-recent" ''
    ${builtins.readFile ./checkout-recent/git-checkout-recent}
  '';
in
{
  options.git = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user email";
    };
  };

  config = {
    home.packages = with pkgs; [
      (writeShellScriptBin "rubocop-commit" ''
        ${builtins.readFile ./rubocop_commit.sh}
      '')
      git-checkout
      git-checkout-recent
    ];

    programs.git = {
      enable = true;
      userName = config.git.userName;
      userEmail = config.git.userEmail;

      aliases = {
        # one-line log
        l = "log --pretty=format:\"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate --date=short";

        a = "add";
        ap = "add -p";
        c = "commit --verbose";
        ca = "commit -a --verbose";
        cm = "commit -m";
        cam = "commit -a -m";
        m = "commit --amend --verbose";

        d = "diff";
        ds = "diff --stat";
        dc = "diff --cached";

        s = "status -s";
        co = "checkout";
        cob = "checkout -b";
        checkout-branch = "!${git-checkout}/bin/git-checkout";

        # list branches sorted by last modified
        b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";

        # list aliases
        la = "!git config -l | grep alias | cut -c 7-";

        hello = "!echo hello world";

        show-files = "diff-tree --no-commit-id --name-only -r";
        rebase-until = "!f() { limit=\${1:-15}; commit=$(git l --color=always -n \"$limit\" | fzf --ansi | sed 's/\\x1b\\[[0-9;]*m//g' | awk \"{print \\$1}\") && [ -n \"$commit\" ] && git rebase -i \"$commit\"~ --autosquash; }; f";
        fixup = "!f() { limit=\${1:-15}; commit=$(git l --color=always -n \"$limit\" | fzf --ansi --prompt=\"Select commit to fixup: \" | sed 's/\\x1b\\[[0-9;]*m//g' | awk \"{print \\$1}\") && [ -n \"$commit\" ] && git commit --fixup=\"$commit\"; }; f";
        code = "!f() { local ref=\${1:-}; if [ -z \"$ref\" ]; then code $(git diff --name-only); else code $(git diff-tree --no-commit-id --name-only -r \"$ref\"); fi }; f";
        checkout-recent = "!${git-checkout-recent}/bin/git-checkout-recent";
        delete-branches = "!f() { git branch | grep -v '^\\*' | sed 's/^[ ]*//g' | fzf --multi --prompt='Select branches to delete: ' | xargs -r git branch -d; }; f";
        force-delete-branches = "!f() { git branch | grep -v '^\\*' | sed 's/^[ ]*//g' | fzf --multi --prompt='Select branches to FORCE delete: ' | xargs -r git branch -D; }; f";
      };
    };
  };
}
