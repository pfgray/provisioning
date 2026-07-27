{ pkgs, config, lib, ... }:

let
  git-checkout = pkgs.writeShellScriptBin "git-checkout" ''
    export PATH="${pkgs.lib.makeBinPath [ pkgs.gnused pkgs.gnugrep pkgs.gawk pkgs.coreutils pkgs.fzf pkgs.git ]}:$PATH"
    ${builtins.readFile ./checkout/git-checkout}
  '';
  git-checkout-recent = pkgs.writeShellScriptBin "git-checkout-recent" ''
    export PATH="${pkgs.lib.makeBinPath [ pkgs.gnused pkgs.gnugrep pkgs.gawk pkgs.coreutils pkgs.fzf pkgs.git ]}:$PATH"
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
        export PATH="${pkgs.lib.makeBinPath [ pkgs.gnugrep pkgs.coreutils pkgs.git ]}:$PATH"
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
        b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | ${pkgs.gnused}/bin/sed -e 's-refs/heads/--'";

        # list aliases
        la = "!git config -l | ${pkgs.gnugrep}/bin/grep alias | ${pkgs.coreutils}/bin/cut -c 7-";

        hello = "!echo hello world";

        show-files = "diff-tree --no-commit-id --name-only -r";
        rebase-until = "!f() { limit=\${1:-15}; commit=$(git l --color=always -n \"$limit\" | ${pkgs.fzf}/bin/fzf --ansi | ${pkgs.gnused}/bin/sed 's/\\x1b\\[[0-9;]*m//g' | ${pkgs.gawk}/bin/awk \"{print \\$1}\") && [ -n \"$commit\" ] && git rebase -i \"$commit\"~ --autosquash; }; f";
        fixup = "!f() { limit=\${1:-15}; commit=$(git l --color=always -n \"$limit\" | ${pkgs.fzf}/bin/fzf --ansi --prompt=\"Select commit to fixup: \" | ${pkgs.gnused}/bin/sed 's/\\x1b\\[[0-9;]*m//g' | ${pkgs.gawk}/bin/awk \"{print \\$1}\") && [ -n \"$commit\" ] && git commit --fixup=\"$commit\"; }; f";
        code = "!f() { local ref=\${1:-}; if [ -z \"$ref\" ]; then code $(git diff --name-only); else code $(git diff-tree --no-commit-id --name-only -r \"$ref\"); fi }; f";
        checkout-recent = "!${git-checkout-recent}/bin/git-checkout-recent";
        delete-branches = "!f() { git branch | ${pkgs.gnugrep}/bin/grep -v '^\\*' | ${pkgs.gnused}/bin/sed 's/^[ ]*//g' | ${pkgs.fzf}/bin/fzf --multi --prompt='Select branches to delete: ' | ${pkgs.coreutils}/bin/xargs -r git branch -d; }; f";
        force-delete-branches = "!f() { git branch | ${pkgs.gnugrep}/bin/grep -v '^\\*' | ${pkgs.gnused}/bin/sed 's/^[ ]*//g' | ${pkgs.fzf}/bin/fzf --multi --prompt='Select branches to FORCE delete: ' | ${pkgs.coreutils}/bin/xargs -r git branch -D; }; f";
        edit-commit = "!f() { limit=\${1:-15}; commit=$(git l --color=always -n \"$limit\" | ${pkgs.fzf}/bin/fzf --ansi | ${pkgs.gnused}/bin/sed 's/\\x1b\\[[0-9;]*m//g' | ${pkgs.gawk}/bin/awk \"{print \\$1}\") && [ -n \"$commit\" ] && GIT_SEQUENCE_EDITOR=\"${pkgs.gnused}/bin/sed -i 's/^pick $commit/edit $commit/'\" git rebase -i \"$commit\"~ --autosquash; }; f";
      };
    };
  };
}
