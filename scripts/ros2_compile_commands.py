#!/usr/bin/env python3
"""Merge colcon package compile databases for clangd."""

import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Merge build/<package>/compile_commands.json into the workspace root."
    )
    parser.add_argument("workspace", nargs="?", type=Path, default=Path.cwd())
    args = parser.parse_args()
    workspace = args.workspace.expanduser().resolve()
    build_dir = workspace / "build"
    databases = sorted(build_dir.rglob("compile_commands.json"))
    entries_by_file = {}

    for database in databases:
        try:
            entries = json.loads(database.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            parser.error(f"cannot read {database}: {error}")
        for entry in entries:
            directory = Path(entry["directory"])
            if not directory.is_absolute():
                directory = (database.parent / directory).resolve()
            source = Path(entry["file"])
            if not source.is_absolute():
                source = (directory / source).resolve()
            normalized = dict(entry, directory=str(directory), file=str(source))
            entries_by_file[str(source)] = normalized

    if not entries_by_file:
        parser.error(
            f"no package databases found under {build_dir}; configure colcon with "
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON and build the workspace first"
        )

    output = workspace / "compile_commands.json"
    output.write_text(
        json.dumps(list(entries_by_file.values()), indent=2) + "\n", encoding="utf-8"
    )
    print(f"Wrote {len(entries_by_file)} compilation commands to {output}")


if __name__ == "__main__":
    main()
