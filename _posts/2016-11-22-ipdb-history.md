---
layout: post
title:  "Ipdb persistent history"
date:   2016-11-22 14:00:00 +0100
---

When I'm doing a debugging session, I like to have all the comfort of a good
command line interface for the interpreter, that's why I use
[ipbd](https://github.com/gotcha/ipdb), a wrapper for the debugger provided by
[IPython](https://ipython.org) interpreter.

Ipdb extends the features of the Python debugger adding the interactivity of
IPython, that involves **tab completion** and **syntax highlighting**, improving the
debugging experience.

However, I felt that something of very essential was missing: **history**, or to
be more precise, a **persistent history**.

That's why I decided to fork the project and start hacking on top of it.

## Implementation (TL;DR)

The original code for ipdb contains this import line:

```python
from IPython.terminal.debugger import TerminalPdb as Pdb
```
I extended the `TerminalPdb` class in order to implement history storing:

```python
from IPython.paths import locate_profile
try:
    history_path = os.path.join(locate_profile(), 'ipdb_history')
except (IOError, OSError):
    history_path = os.path.join(os.path.expanduser('~'), '.ipdb_history')

class Pdb(TerminalPdb):
    def __init__(self, color_scheme='NoColor', completekey=None,
                 stdin=None, stdout=None, context=5):
        """Init pdb and load the history file if present"""
        super(Pdb, self).__init__(color_scheme, completekey, stdin, stdout,
                                  context)
        try:
            with open(history_path, 'r') as f:
                self.shell.debugger_history.strings = [
                    unicode(line.replace(os.linesep, ''))
                    for line in f.readlines()
                ]
        except IOError:
            pass

    def parseline(self, line):
        """Append the line in the history file before parsing"""
        if 'EOF' != line != '':
            try:
                with open(history_path, 'a') as f:
                    f.write(line + os.linesep)
            except IOError:
                pass
        return super(Pdb, self).parseline(line)
```

After calling the super constructor, the history file, stored in
the IPython profile directory, it's opened (if exists), to read all the
previous line of history. The `parseline` method, used by the debugger to parse
command lines, has been extended in order to append the current line in the
history file. The next time ipdb will be used, it will load the appended lines
from the file.

If, for some reason, the IPython profile directory can't be found, the history
file will be saved in the user home directory as an hidden file.

That was a good start. However, it didn't take count of duplicate lines that
could appear in the history file, so I managed to add a control to prevent the
appending of a line if it's equal to the last one in the history file.

## Patched version

The patched version can be found [here](https://github.com/michelesr/ipdb), and
can be installed with:

    pip install git+https://github.com/michelesr/ipdb.git

The patch works only with IPython 5 or higher, so be sure to upgrade that too:

    pip install ipython --upgrade

I also opened a [pull
request](https://github.com/gotcha/ipdb/pull/104),
hoping that the maintainer will check it out eventually.
