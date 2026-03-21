#!/usr/bin/env python3
"""
Append Jenkins job definitions for every package in el9_pkgs.tsv into main.yml.

Usage (from repo root):
    python3 jenkins-lfs/scripts/gen_el9_jobs.py
  or with explicit paths:
    python3 jenkins-lfs/scripts/gen_el9_jobs.py <el9_pkgs.tsv> <main.yml>

The script auto-detects the highest existing job number and continues from there.
"""
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]

tsv  = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO_ROOT / "jenkins-lfs/package_maps/el9_pkgs.tsv"
main = Path(sys.argv[2]) if len(sys.argv) > 2 else REPO_ROOT / "jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml"

if not tsv.exists():
    sys.exit(f"Error: {tsv} not found. Run option 6 in start.sh first.")

# Find highest job number already in file
highest = max(
    [int(m.group(1)) for line in main.read_text().splitlines()
     for m in [re.search(r'name: (\d{4}) -', line)] if m],
    default=0
)
print(f"Highest existing job number: {highest}")

# Parse TSV
packages = []
for line in tsv.read_text().splitlines():
    parts = line.split('\t')
    if len(parts) >= 2:
        pkg_name = parts[0].strip()
        ver_rel  = parts[1].strip()
        upstream = re.sub(r'-\d+[\.\w]*\.el\d.*$', '', ver_rel)
        packages.append((pkg_name, upstream))

print(f"Packages to append: {len(packages)}")

# Build YAML blocks
blocks = []
for i, (pkg, ver) in enumerate(packages, start=highest + 1):
    block = f"""
    - name: {i:04d} - {pkg} (EL9 Packages)
      version: {ver}
      archive_file: /sources/{pkg}-{ver}.tar.gz
      source_dir: /sources/{pkg}-{ver}
      description: |
        Build {pkg} version {ver} from Rocky Linux 9 (EL9) baseline.
      category:
        This job is part of the EL9 packages build, providing {pkg} from the Rocky Linux 9 package baseline.
      exec_command: echo
      build_tool: true
      build_command: |
        {{{{ chroot_start_command }}}} -c '
          dnf install -y {pkg}-{ver}
        '
"""
    blocks.append(block)

# Append to main.yml
with main.open('a') as f:
    f.write('\n')
    f.writelines(blocks)

print(f"Done. Appended {len(blocks)} EL9 job blocks to {main}")
