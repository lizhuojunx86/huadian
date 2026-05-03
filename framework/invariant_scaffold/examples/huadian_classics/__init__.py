"""HuaDian classics — reference implementation of invariant_scaffold for HuaDian Postgres.

Wraps the 10 production V-invariants (V4 / V6 / V8 / V9 / V10.a/b/c / V11 +
slug + active-merged) as framework Invariant instances, plus DBPort adapter
for asyncpg + self-tests for 7 of them.

Cross-domain adopters: copy this folder, rename to your domain, replace
SQL queries with your schema. The 5 pattern subclass + plugin protocols
stay the same.

License: Apache 2.0
"""

__version__ = "0.1.0"
