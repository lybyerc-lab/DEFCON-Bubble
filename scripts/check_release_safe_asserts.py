#!/usr/bin/env python3
"""[DB:CI:RELEASE_SAFE_ASSERTS]

Godot strips every `assert()` statement from release builds, including the
expression inside it. Anything essential that hides in an assert therefore runs
on desktop and in CI but silently vanishes from the exported mobile/Web build.

This check fails when an `assert()` calls a method that is not a known pure
predicate, so an essential call can never quietly become debug-only again.

Extend ALLOWED_PREDICATES only for methods that read state and change nothing.
"""

import pathlib
import re
import sys

ALLOWED_PREDICATES = frozenset({
    "has",
    "is_empty",
    "is_valid",
    "size",
})

CALL_PATTERN = re.compile(r"\.([a-zA-Z_][a-zA-Z0-9_]*)\s*\(")
ASSERT_PATTERN = re.compile(r"\bassert\(")


def assert_bodies(source: str):
    """Yield (line_number, body) for each assert(), spanning wrapped lines."""
    for match in ASSERT_PATTERN.finditer(source):
        index = match.end()
        depth = 1
        while index < len(source) and depth:
            if source[index] == "(":
                depth += 1
            elif source[index] == ")":
                depth -= 1
            index += 1
        line_number = source.count("\n", 0, match.start()) + 1
        yield line_number, source[match.end():index - 1]


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent.parent
    violations: list[str] = []

    for path in sorted(root.joinpath("scripts").rglob("*.gd")):
        source = path.read_text(encoding="utf-8")
        for line_number, body in assert_bodies(source):
            for call in CALL_PATTERN.findall(body):
                if call not in ALLOWED_PREDICATES:
                    violations.append(
                        f"{path.relative_to(root)}:{line_number}: "
                        f"assert() calls '{call}()', which release builds strip."
                    )

    if violations:
        print("[DB:CI:RELEASE_SAFE_ASSERTS] FAIL")
        for violation in violations:
            print(f"  {violation}")
        print(
            "\nMove the call out of assert() and report failure with push_error(), "
            "or add the method to ALLOWED_PREDICATES if it is genuinely pure."
        )
        return 1

    print("[DB:CI:RELEASE_SAFE_ASSERTS] PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
