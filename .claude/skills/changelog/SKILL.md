---
description: Update the changelog's Unreleased section from the commits since the last release.
name: changelog
---

# Changelog

`CHANGELOG.md` follows [Keep a Changelog]. The Unreleased section becomes the release notes when a tag is pushed, so
it is written for someone bundling the gem, not for whoever wrote the code.

## 1. Read the commits since the last release

This repository uses `jj`. Fall back to `git` only if there is no `.jj` directory.

```sh
git tag --sort=-creatordate | head -1
jj log -r '<tag>..@' --no-graph -T 'description ++ "\n"'
```

Under git, `git log <tag>..HEAD --reverse`.

Read the bodies, not just the subjects. A commit message here says what landed and why each decision that is not
obvious went the way it did, and that reasoning is what an entry is built from. Read the diff when a message leaves
you guessing.

## 2. Decide what a user would notice

This project does not use conventional commits. The scope names the part of the project that changed, which is a
starting point rather than a rule:

| Scope                    | Usually                                                                   |
|--------------------------|---------------------------------------------------------------------------|
| `lib`                    | An entry. This is the gem.                                                |
| `sig`                    | An entry when signatures for the public API land or change                |
| `docs`                   | An entry only for documentation a user would go looking for               |
| `spec`, `scripts`, `ci`  | No entry. Nothing a user installs changed.                                |
| `config`                 | No entry, unless it changed the supported Ruby, Hanami or Phlex versions. |

The `@api` tags settle most of the remaining cases. A change to an `@api public` class or method earns an entry; a
change to an `@api private` one earns an entry only when a user can see the difference. Renaming
`SliceConfiguredView` to `SliceConfigured` changed nothing a user can reach, so it got no entry.

When neither test helps, ask what breaks or improves for someone who writes `gem "phlex-hanami"` and nothing else. If
the answer is nothing, leave it out.

## 3. Sort the entries into categories

Use the [Keep a Changelog] categories, in this order: Added, Changed, Deprecated, Removed, Fixed, Security. Only
categories with entries appear.

- **Added**: a class, module, method or convention that did not exist before.
- **Changed**: behaviour that now works differently. Say what a user upgrading has to do about it.
- **Fixed**: something that was broken. Name the breakage, not just the repair.
- **Removed**: something a user could reach that is gone.

Deprecated and Security stay empty most of the time. The API is not settled before 0.2.0 and the README says names and
behaviour can change between alphas with no deprecation cycle, so a rename lands under Changed with a plain sentence
about what to write instead, not under Deprecated.

## 4. Write the entries

Match the entries already in the file:

- **Name the constant.** `Phlex::Hanami::Mailer::Text`, `Views::Mailers::Layout`, `text_body`. This is a library, the
  names are the interface, and a user searching for one should land here.
- **One entry per thing a user can use**, not one per commit. Four commits that built mail support are one entry each
  for the mailer, the base classes, the text part and the layout convention.
- **Say what changed, then why it matters** when the why is not obvious. Two sentences beat one vague one.
- **Wrap at 120 columns**, with continuation lines indented two spaces.
- **Reference-style links at the bottom** for gems and documentation, the way `[hanami-mailer]` is already linked.
- **No Linear issue references.** The tracker is private, and an entry that needs an issue to make sense is not
  written well enough.
- **Credit an outside contributor** with a reference-style link to their GitHub profile, the way the release lines
  already credit maintainers. Work by the maintainer needs no credit.

Every rule in the writing rules section of `.claude/CLAUDE.md` applies. It names changelogs.

Good:

```markdown
- A mail layout convention: `Views::Mailers::Layout` in a slice wraps that slice's mail views.
- `url` in a view returns a String. Hanami's routes helper returns a `URI`, which Phlex rejects as an attribute
  value, so `a(href: url(:posts))` raised.
```

Bad:

```markdown
- lib: add the mailer extension and Phlex mail view classes
- Fixed a bug in url
- Improved the developer experience around mail rendering
```

The first is a commit subject. The second names no breakage. The third says nothing at all.

## 5. Update the file

Replace the contents of the `## [Unreleased]` section and nothing else. Leave released sections alone, even when they
read badly. They describe what shipped.

Check the link definitions at the bottom while you are there. `[Unreleased]` compares the latest tag to `HEAD`, and
every version heading needs a matching definition.

## 6. Check it

Run `mise run lint`, which holds the file to 120 columns. Then show the user the new Unreleased section.

## At release time

Rename `## [Unreleased]` to `## [vX.Y.Z] - YYYY-MM-DD`, add an empty Unreleased section above it, and add the link
definitions for both. The release workflow reads the section whose heading matches the tag, so
`.github/workflows/release.yml` publishes nothing for tag `0.2.0` without a `## [v0.2.0]` heading.

[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
