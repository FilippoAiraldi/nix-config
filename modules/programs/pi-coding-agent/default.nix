{
  flake.modules.homeManager.pi-coding-agent =
    { pkgs, ... }:
    {
      imports = [
        ./_packages/pi-permission-system.nix
      ];

      programs.pi-coding-agent = {
        enable = true;

        # content of AGENTS.md
        # context = ''
        #   # Writing rules

        #   These rules apply to all prose produced, including when a loaded skill sets a different voice. Code and code comments are exempt. Status reports must say plainly what was and wasn't verified.

        #   - No em dashes, exclamation marks, scare quotes, or intensifiers (significantly, truly, incredibly).
        #   - No weasel words (may potentially, helps ensure). State the claim or cut it.
        #   - No unsourced statistics, fabricated history, case studies, or attributions. If no real number, date, or source exists, cut the sentence.
        #   - Quotes match the source word for word. Set off quotes over about fifteen words as blocks.
        #   - No filler openers ("In today's world", "It's important to note", "Whether you're") and no AI transitions (Furthermore, Moreover, That being said). Use also, and, but, however.
        #   - No AI verbs (delve, leverage, utilize, foster) or academic tells (shed light on, prior to, in terms of).
        #   - Headings name the content. No drama, clickbait, or vague abstractions.
        #   - In published documents, don't narrate research or list what couldn't be found. Delete unsupported claims.
        #   - Say each point once.
        #   - Before returning prose, check it against these rules and fix violations.
        # '';

        settings = {
          defaultProvider = "github-copilot";
          defaultModel = "claude-haiku-5.5";

          defaultThinkingLevel = "low";
          defaultTools = [
            "bash"
            "codemode"
            "edit"
            "find"
            "grep"
            "read"
            "ls"
            "write"
          ];

          # simple packages that do not require further config customization
          packages = [ "npm:pi-web-access" ];
        };
      };
    };
}
