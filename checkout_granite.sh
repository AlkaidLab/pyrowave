#!/bin/bash

# Copyright (c) 2026 AlkaidLab contributors
# SPDX-License-Identifier: MIT AND GPL-3.0-only

# Granite is a pinned nested submodule. Dependency downloads belong to the
# repository setup step, not to a CMake/build invocation.
set -euo pipefail
script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
git -C "$script_dir" submodule update --init --recursive third_party/Granite
