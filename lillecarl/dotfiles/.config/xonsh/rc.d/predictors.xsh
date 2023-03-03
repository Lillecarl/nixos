#! /usr/bin/env xonsh

_predictors = __xonsh__.commands_cache.threadable_predictors
_pred_false = _xonsh.commands_cache.predict_false
_pred_true = _xonsh.commands_cache.predict_true

def _pred_systemctl(*args, **kw):
  for i in ["status", "edit"]:
    if i in args:
      return True

  return False
_
_predictors['less'] = _pred_false
_predictors['more'] = _pred_false
_predictors['moar'] = _pred_false
_predictors['journalctl'] = _pred_false
_predictors['vim'] = _pred_false
#_predictors['systemctl'] = lambda *a, **kw: "status" in a
_predictors['systemctl'] = _pred_systemctl

