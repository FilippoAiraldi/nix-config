{ config, ... }:
{
  programs.pi-coding-agent.settings.packages = [ "npm:@gotgenes/pi-permission-system" ];

  home.file."${config.programs.pi-coding-agent.configDir}/extensions/pi-permission-system/config.json".text =
    let
      deny = reason: {
        action = "deny";
        inherit reason;
      };
      noForcePush = deny "Force push is not allowed.";
      noPrivilegeEscalation = deny "Privilege escalation is not allowed.";
      noRecursiveForce = deny "Recursive force delete is not allowed. Delete specific files instead.";
    in
    builtins.toJSON {
      permission = {
        "*" = "ask";
        external_directory = "deny";
        path = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
          "*.pem" = "deny";
          "*.key" = "deny";
          "id_ed*" = "deny";
          "id_rsa*" = "deny";
          "~/.ssh/*" = "deny";
          "~/.aws/*" = "deny";
          "~/.gnupg/*" = "deny";
          "*/.git/*" = "deny";
        };

        edit = {
          "*" = "ask";
          "*.lock" = "deny";
          "*/.git/*" = "deny";
        };
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        write = {
          "*" = "ask";
          "*.lock" = "deny";
          "*/.git/*" = "deny";
        };

        bash = {
          "*" = "ask";

          "cat *" = "allow";
          "diff *" = "allow";
          "find *" = "allow";
          "fd *" = "allow";
          "grep *" = "allow";
          "head *" = "allow";
          "ls *" = "allow";
          "pwd" = "allow";
          "rg *" = "allow";
          "tail *" = "allow";
          "wc *" = "allow";

          "chmod -R *" = "ask";
          "chown -R *" = "ask";
          "dd *" = "ask";
          "mkfs*" = "deny";
          "reboot*" = "deny";
          "shutdown*" = "deny";

          "doas *" = noPrivilegeEscalation;
          "sudo *" = noPrivilegeEscalation;

          "git status" = "allow";
          "git diff *" = "allow";
          "git log *" = "allow";
          "git show *" = "allow";
          "git branch" = "allow";
          "git add *" = "ask";
          "git commit *" = "ask";
          "git push --force *" = noForcePush;
          "git push -f *" = noForcePush;
          "git push *" = "ask";
          "git reset --hard *" = "ask";
          "git clean *" = "ask";

          "rm -rf *" = noRecursiveForce;
          "rm -fr *" = noRecursiveForce;
          "rm -r -f *" = noRecursiveForce;
          "rm -f -r *" = noRecursiveForce;
          "rm -R *" = "ask";
          "rm -r *" = "ask";

          "npm publish *" = "ask";
          "pnpm publish *" = "ask";
        };
        grep = "allow";
        find = "allow";
        ls = "allow";
        mcp = "ask";
        skill."*" = "ask";
      };
    };
}
