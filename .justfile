# justfile for obsidian-skills

# auto-format all files
tidy:
	npx prettier --write .

# check formatting (no fix)
check:
	npx prettier --check .
