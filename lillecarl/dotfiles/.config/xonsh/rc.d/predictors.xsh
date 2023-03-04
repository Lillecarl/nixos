#! /usr/bin/env xonsh

import xonsh as _xonsh

_predictors = __xonsh__.commands_cache.threadable_predictors
_pred_false = _xonsh.commands_cache.predict_false
_pred_true = _xonsh.commands_cache.predict_true

def _pred_systemctl(*args, **kw):
  for i in ["status", "edit"]:
    if i in args:
      return True

  return False

def _pred_kubectl(*args, **kw):
  for i in ["logs", "edit"]:
    if i in args:
      return True

  return False

def _pred_git(*args, **kw):
  for i in ["commit", "log", "rebase"]:
    if i in args:
      return True

  return False

# Things that can just never thread, for reasons
_predictors['devenv'] = _pred_false
_predictors['git-imerge'] = _pred_false
_predictors['journalctl'] = _pred_false
_predictors['less'] = _pred_false
_predictors['moar'] = _pred_false
_predictors['more'] = _pred_false
_predictors['nvim'] = _pred_false
_predictors['vim'] = _pred_false
_predictors['vimdiff'] = _pred_false

# Things where some subcommands are incompatible with threading.
_predictors['git'] = _pred_git
_predictors['kubectl'] = _pred_kubectl
_predictors['systemctl'] = _pred_systemctl

