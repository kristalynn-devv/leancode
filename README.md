# leancode — moved

This skill now lives in [`kristalynn-devv/dotfiles`](https://github.com/kristalynn-devv/dotfiles/tree/main/skills/leancode)
under `skills/leancode/`, with its full history. This repo is no longer updated; its files stay as they
were at v4.1.1, so existing clones keep working.

## Switch an existing install

If `~/.claude/skills/leancode` is a clone of this repo:

```bash
mv ~/.claude/skills/leancode ~/.claude/skills/leancode.old
git clone https://github.com/kristalynn-devv/dotfiles.git ~/src/dotfiles
ln -s ~/src/dotfiles/skills/leancode ~/.claude/skills/leancode
cp ~/.claude/skills/leancode.old/FRICTION.md ~/.claude/skills/leancode/   # keep your friction log, if you have one
```

Setup, docs and updates: [`skills/leancode/README.md`](https://github.com/kristalynn-devv/dotfiles/blob/main/skills/leancode/README.md).
