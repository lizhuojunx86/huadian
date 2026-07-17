# Keep bare `pytest kb_forge` runnable as a whole tree (audit-2026-07-16).
#
# The examples/huadian_classics dogfood scripts are `python -m` entry points
# that need a live Postgres; their historical `test_*` filenames made naive
# full-tree collection crash with ModuleNotFoundError. The supported suites
# live in each package's tests/ directory — ignore examples at collection.
collect_ignore_glob = ["*/examples/*"]
