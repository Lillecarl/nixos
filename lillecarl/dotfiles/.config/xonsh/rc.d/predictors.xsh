#! /usr/bin/env xonsh

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

# Things that can just never thread, for reasons
_predictors['less'] = _pred_false
_predictors['more'] = _pred_false
_predictors['moar'] = _pred_false
_predictors['vim'] = _pred_false
_predictors['journalctl'] = _pred_false

# Things where some commands spawn a pager, pagers are incompatible
# with xonsh threading stuff
_predictors['systemctl'] = _pred_systemctl
_predictors['kubectl'] = _pred_kubectl

