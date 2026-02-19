#!/usr/bin/env python3
import argparse
from pathlib import Path
from typing import List


DELETE_KWS = {"COPY", "USER", "ENTRYPOINT", "EXPOSE", "CMD", "FROM"}


def convert_env(rest: str) -> List[str]:
    """
    Convert a Dockerfile ENV instruction into one or more export statements.
    Examples:
      ENV A=1 B=2      -> export A=1 B=2
      ENV A 1 B 2      -> export A=1 B=2
    """
    rest = rest.strip()
    if not rest:
        return []

    tokens = rest.split()
    pairs: List[str] = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if "=" in t:
            pairs.append(t)
            i += 1
        else:
            # A 1  => A=1
            if i + 1 < len(tokens):
                pairs.append(f"{t}={tokens[i + 1]}")
                i += 2
            else:
                # Unusual format, keep token as-is
                pairs.append(t)
                i += 1

    return [f"export {' '.join(pairs)}"]


def convert_line(line: str) -> str | None:
    """
    Convert a single Dockerfile line according to rules:
    - ENV      -> export
    - RUN      -> remove prefix
    - WORKDIR  -> cd
    - COPY/USER/ENTRYPOINT/EXPOSE/CMD/FROM lines are removed
    Other lines are kept as-is (including comments).
    """
    raw = line.rstrip("\n")
    stripped = raw.lstrip()

    if stripped == "":
        return ""  # keep empty lines

    # Keep pure comment lines untouched
    if stripped.startswith("#"):
        return raw

    # Extract the first word as the Dockerfile directive keyword
    parts = stripped.split(None, 1)
    kw = parts[0].upper()
    rest = parts[1] if len(parts) > 1 else ""

    # Directives we want to drop from the output
    if kw in DELETE_KWS:
        return None

    if kw == "ENV":
        exports = convert_env(rest)
        return "\n".join(exports) if exports else None

    if kw == "RUN":
        # RUN apt-get ... -> apt-get ...
        return rest

    if kw == "WORKDIR":
        # WORKDIR /app -> cd /app
        return f"cd {rest.strip()}"

    # Any other directive is kept as-is
    return stripped


def convert_dockerfile(input_path: Path) -> str:
    output_lines: List[str] = []

    skip_block = False
    begin_marker = "docker build only begin"
    end_marker = "docker build only end"

    for line in input_path.read_text(encoding="utf-8").splitlines(keepends=False):
        stripped = line.strip()

        # Skip everything between the special begin/end markers (inclusive)
        if begin_marker in stripped:
            skip_block = True
            continue
        if end_marker in stripped:
            skip_block = False
            continue
        if skip_block:
            continue

        converted = convert_line(line)
        if converted is None:
            continue
        # convert_line may return multiple lines (ENV)
        if "\n" in converted:
            output_lines.extend(converted.split("\n"))
        else:
            output_lines.append(converted)

    return "\n".join(output_lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert a Dockerfile into an approximate shell script."
    )
    parser.add_argument(
        "dockerfile",
        type=Path,
        help="Path to the Dockerfile to convert.",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Output shell script path (default: stdout).",
    )
    args = parser.parse_args()

    result = convert_dockerfile(args.dockerfile)

    if args.output:
        args.output.write_text(result, encoding="utf-8")
    else:
        print(result, end="")


if __name__ == "__main__":
    main()
