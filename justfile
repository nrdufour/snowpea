# Main justfile for SnowPea infrastructure management

# Import sub-justfiles
import '.justfiles/nix.just'
import '.justfiles/sops.just'
import '.justfiles/sd.just'

# Default recipe - list available commands
default:
    @just --list

# Run statix lint
lint:
    statix check .

# Format project files
format:
    nixpkgs-fmt {{justfile_directory()}}
