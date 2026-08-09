# Variables (override via environment or `just --set`)
hostname := `hostname`
flake    := ".#" + hostname

# List available recipes (running `just` runs this recipe, since it is first)
[private]
default:
    @just --list

# Rebuild the NixOS configuration
nixos-rebuild flake=flake:
    @echo "Rebuilding NixOS configuration..."
    sudo nixos-rebuild switch --flake {{flake}}
    @echo "NixOS rebuild complete."

# Run Nix garbage collection
nix-gc:
    @echo "Collecting Nix garbage..."
    nix-collect-garbage -d
    @echo "Garbage collection complete."

# Update flake inputs
flake-update:
    @echo "Updating flake inputs..."
    nix flake update
    @echo "Flake update complete."

# Check the flake for issues
flake-check:
    @echo "Checking flake..."
    nix flake check
    @echo "Flake check complete."

# Format the repository
fmt:
    nix fmt
