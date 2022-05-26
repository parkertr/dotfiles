#!/usr/bin/env bash
set -e
set -o pipefail

# Used during installation to fetch SSH Passphrase from 1Password.
# This is implemented as a standalone executable so it can be used with SSH_ASKPASS.

op item get --account="$OP_ACCOUNT" "$OP_ITEM_SSHKEY" --fields Passphrase
