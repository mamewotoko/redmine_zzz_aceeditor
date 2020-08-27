# coding: utf-8
require 'redmine'

# http://guide.redmine.jp/Plugin_Tutorial/
module RedmineAceEditorPlugin
  class Hooks < Redmine::Hook::ViewListener
    # render_on :view_account_right_bottom, partial: 'hooks/redmine_aceeditor/editor_setting'
    def view_my_account(context={ })
      # https://railsguides.jp/form_helpers.html
      return %{
        <p>
        <label for="pref_textarea_keybind">エディタのキーバインド</label>
        <select name="pref[textarea_keybind]" id="pref_textarea_keybind">
        <option selected="selected" value="emacs">emacs</option>
        <option value="vim">vim</option>
        <option value="windows">windows</option>
</select></p>
      }
    end
  end
end
