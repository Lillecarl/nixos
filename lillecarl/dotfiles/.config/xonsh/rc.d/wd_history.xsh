#! /usr/bin/env xonsh

__xonsh__.wd_history = list()
__xonsh__.wd_history_idx = 0
__xonsh__.wd_history_lock = 0

@events.on_chdir
def add_to_history(olddir, newdir, **kw):
  if __xonsh__.wd_history_lock <= 0:
    __xonsh__.wd_history_lock = 0 # Unlock
  if __xonsh__.wd_history_lock == 0: # Ignore when we chdir programatically
    __xonsh__.wd_history.append(newdir) # Add cwd to history
    __xonsh__wd_history_idx = len(__xonsh__.wd_history) # Set history index to last entry

  __xonsh__.wd_history_lock = 0 # Unlock
