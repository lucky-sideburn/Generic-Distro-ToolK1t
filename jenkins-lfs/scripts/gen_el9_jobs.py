#!/usr/bin/env python3
"""
Regenerate the el9_packages section in main.yml from el9_pkgs.tsv.

Jobs are numbered 0001-NNNN (section-relative, not global).
If an el9_packages: section already exists it is replaced; otherwise it is appended.

Usage (from repo root):
    python3 jenkins-lfs/scripts/gen_el9_jobs.py
  or with explicit paths:
    python3 jenkins-lfs/scripts/gen_el9_jobs.py <el9_pkgs.tsv> <main.yml>
"""
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]

tsv  = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO_ROOT / "jenkins-lfs/package_maps/el9_pkgs.tsv"
main = Path(sys.argv[2]) if len(sys.argv) > 2 else REPO_ROOT / "jenkins-lfs/playbooks/roles/ansible-gdt/vars/main.yml"

if not tsv.exists():
    sys.exit(f"Error: {tsv} not found. Run option 6 in start.sh first.")

# Parse TSV
packages = []
for line in tsv.read_text().splitlines():
    parts = line.split('\t')
    if len(parts) >= 2:
        pkg_name = parts[0].strip()
        ver_rel  = parts[1].strip()
        upstream = re.sub(r'-\d+[\.\w]*\.el\d.*$', '', ver_rel)
        packages.append((pkg_name, upstream))

print(f"Packages from TSV: {len(packages)}")

jinja_open  = '{{ '
jinja_close = ' }}'

# Build replacement section lines
section_lines = ['\n  el9_packages:\n']
for i, (pkg, ver) in enumerate(packages, start=1):
    section_lines.append(
        f"\n"
        f"    - name: {i:04d} - {pkg} (EL9 Packages)\n"
        f"      version: {ver}\n"
        f"      archive_file: /sources/{pkg}-{ver}.tar.gz\n"
        f"      source_dir: /sources/{pkg}-{ver}\n"
        f"      description: |\n"
        f"        Build {pkg} version {ver} from Rocky Linux 9 (EL9) baseline.\n"
        f"      category:\n"
        f"        This job is part of the EL9 packages build, providing {pkg} from the Rocky Linux 9 package baseline.\n"
        f"      exec_command: echo\n"
        f"      build_tool: true\n"
        f"      build_command: |\n"
        f"        {jinja_open}chroot_start_command{jinja_close} -c '\n"
        f"          dnf install -y {pkg}-{ver}\n"
        f"        '\n"
    )

content = main.read_text()

# If el9_packages section exists, replace it; otherwise append
if '\n  el9_packages:\n' in content:
    # Find start of el9_packages section and strip to end-of-file (it's always the last section)
    idx = content.index('\n  el9_packages:\n')
    new_content = content[:idx] + ''.join(section_lines)
    main.write_text(new_content)
    print(f"Replaced existing el9_packages section in {main}")
else:
    with main.open('a') as f:
        f.writelines(section_lines)
    print(f"Appended el9_packages section to {main}")

print(f"Done. {len(packages)} EL9 job blocks written (0001-{len(packages):04d})")
