#!/usr/bin/env python3
import sys
from pathlib import Path
from fnmatch import fnmatch

def load_gitignore_rules(root: Path):
    rules = []
    for gitignore in sorted(root.rglob(".gitignore")):
        base_dir = gitignore.parent
        for raw in gitignore.read_text(encoding="utf-8", errors="ignore").splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue

            negated = line.startswith("!")
            if negated:
                line = line[1:]

            rule = {
                "base_dir": base_dir,
                "pattern": line.rstrip("/"),
                "negated": negated,
                "dir_only": raw.rstrip().endswith("/"),
            }
            rules.append(rule)
    return rules

def matches_rule(path: Path, rule: dict):
    try:
        rel = path.relative_to(rule["base_dir"]).as_posix()
    except ValueError:
        return False

    if rule["dir_only"] and not path.is_dir():
        return False

    pattern = rule["pattern"].replace("\\", "/")
    if pattern.startswith("/"):
        pattern = pattern.lstrip("/")

    if not pattern:
        return False

    # Cas simples : "build", "*.log", "foo/bar.txt"
    if fnmatch(rel, pattern):
        return True
    if fnmatch(rel, f"**/{pattern}"):
        return True
    if rel == pattern or rel.startswith(pattern + "/"):
        return True
    if rel.split("/")[-1] == pattern:
        return True
    if pattern in rel.split("/"):
        return True

    # Cas dossier : "build/"
    if rule["dir_only"] and path.is_dir():
        if rel == pattern or rel.startswith(pattern + "/"):
            return True

    return False

def should_ignore(path: Path, rules):
    ignored = False
    for rule in rules:
        if matches_rule(path, rule):
            ignored = not rule["negated"]
    return ignored

def build_entries(root: Path, rules):
    entries = []
    for child in sorted(root.iterdir(), key=lambda p: (not p.is_dir(), p.name.lower())):
        if child.name == ".git":
            continue
        if rules and should_ignore(child, rules):
            continue
        entries.append(child)
    return entries

def render_tree(path: Path, prefix: str = "", rules=None):
    if rules is None:
        rules = []

    entries = build_entries(path, rules)
    lines = []

    for i, child in enumerate(entries):
        is_last = i == len(entries) - 1
        connector = "└── " if is_last else "├── "
        label = child.name + ("/" if child.is_dir() else "")
        lines.append(prefix + connector + label)

        if child.is_dir():
            next_prefix = prefix + ("    " if is_last else "│   ")
            lines.extend(render_tree(child, next_prefix, rules))

    return lines

def main():
    if len(sys.argv) < 2:
        print("Utilisation : python3 generate_tree.py <dossier> [fichier_sortie]")
        sys.exit(1)

    target = Path(sys.argv[1]).resolve()
    if not target.exists() or not target.is_dir():
        print(f"Dossier introuvable : {target}")
        sys.exit(1)

    output = Path(sys.argv[2]).resolve() if len(sys.argv) >= 3 else target / "architecture.txt"

    rules = load_gitignore_rules(target)
    tree_lines = [f"{target.name}/"] + render_tree(target, rules=rules)
    output.write_text("\n".join(tree_lines) + "\n", encoding="utf-8")

    print(f"Arborescence générée dans : {output}")

if __name__ == "__main__":
    main()