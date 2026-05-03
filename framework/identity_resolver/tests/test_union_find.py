"""Tests for framework.identity_resolver.union_find — disjoint-set transitive closure."""

from __future__ import annotations

from framework.identity_resolver import UnionFind


def test_each_element_starts_as_its_own_root():
    uf = UnionFind(["a", "b", "c"])
    for x in ("a", "b", "c"):
        assert uf.find(x) == x


def test_union_makes_two_elements_share_a_root():
    uf = UnionFind(["a", "b"])
    uf.union("a", "b")
    assert uf.find("a") == uf.find("b")


def test_transitive_union_connects_all_via_intermediate():
    uf = UnionFind(["a", "b", "c", "d"])
    uf.union("a", "b")
    uf.union("c", "d")
    uf.union("b", "c")
    root = uf.find("a")
    assert uf.find("b") == root
    assert uf.find("c") == root
    assert uf.find("d") == root


def test_groups_excludes_singletons_and_returns_size_ge_2_components():
    uf = UnionFind(["a", "b", "c", "d", "e"])
    uf.union("a", "b")
    uf.union("c", "d")
    # 'e' stays singleton
    groups = uf.groups()
    # Two groups of size 2; 'e' must NOT appear
    sizes = sorted(len(members) for members in groups.values())
    assert sizes == [2, 2]
    flat = {x for members in groups.values() for x in members}
    assert "e" not in flat
    assert flat == {"a", "b", "c", "d"}
