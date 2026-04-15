"""Minimal CLI entry point — Phase 0 stub."""

import argparse


def main() -> None:
    parser = argparse.ArgumentParser(description="HuaDian Pipeline CLI")
    parser.add_argument("command", choices=["ingest", "extract", "validate"], help="Pipeline command")
    parser.add_argument("--source", default="ctext", help="Data source")
    parser.add_argument("--book", default="", help="Book name")
    args = parser.parse_args()
    print(f"[huadian-pipeline] {args.command} — stub (source={args.source}, book={args.book})")


if __name__ == "__main__":
    main()
