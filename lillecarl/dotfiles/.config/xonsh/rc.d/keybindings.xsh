#! /usr/bin/env xonsh

from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition, EmacsInsertMode, ViInsertMode
 
@events.on_ptk_create
def custom_keybindings(bindings, **kw):

  @bindings.add(Keys.ControlA)
  def begin_line(event):
    event.current_buffer.cursor_position = 0

  @bindings.add(Keys.ControlE)
  def begin_line(event):
    event.current_buffer.cursor_position = len(event.current_buffer.text)

