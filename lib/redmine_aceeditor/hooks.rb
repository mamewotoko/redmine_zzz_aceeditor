# coding: utf-8
require 'redmine'

# http://guide.redmine.jp/Plugin_Tutorial/
module RedmineAceEditorPlugin
  class Hooks < Redmine::Hook::ViewListener
    # render_on :view_account_right_bottom, partial: 'hooks/redmine_aceeditor/editor_setting'
    def view_my_account(context={ })
      # https://railsguides.jp/form_helpers.html
      emacs_selected = ""
      vim_selected = ""
      vscode_selected = ""
      sublime_selected = ""

      keybind = context[:user].aceeditor_preference[:keybind]
      # Rails.logger.info("keybind #{keybind}")

      # keybind = "emacs"
      case keybind
      when "vim" then
        vim_selected = %q[selected="selected" ]
      when "vscode" then
        vscode_selected = %q[selected="selected" ]
      when "sublime" then
        sublime_selected = %q[selected="selected" ]
      else
        # emacs and other value(initial)
        emacs_selected = %q[selected="selected" ]
      end

      theme_list = [
        "ambiance",
        "chaos",
        "chrome",
        "clouds",
        "clouds_midnight",
        "cobalt",
        "crimson_editor",
        "dawn",
        "dracula",
        "dreamweaver",
        "eclipse",
        "github",
        "gob",
        "gruvbox",
        "idle_fingers",
        "iplastic",
        "katzenmilch",
        "kr_theme",
        "kuroir",
        "merbivore",
        "merbivore_soft",
        "mono_industrial",
        "monokai",
        "nord_dark",
        "pastel_on_dark",
        "solarized_dark",
        "solarized_light",
        "sqlserver",
        "terminal",
        "textmate",
        "tomorrow",
        "tomorrow_night",
        "tomorrow_night_blue",
        "tomorrow_night_bright",
        "tomorrow_night_eighties",
        "twilight",
        "vibrant_ink",
        "xcode"
      ]
      selected_theme = context[:user].aceeditor_preference[:theme]

      tlist = theme_list.map {|t|
        selected = ""
        if selected_theme == t
          selected = %q[selected="selected"]
        end
        %{<option value="#{t}" #{selected}>#{t}</option>} }

      # TODO: use label to translate message
      s =  %{
        <p>
        <label for="pref_aceeditor_keybind">#{l(:aceeditor_keybind)}</label>
        <select name="pref[aceeditor_keybind]" id="pref_aceeditor_keybind">
        <option value="emacs" #{emacs_selected}>emacs</option>
        <option value="vim" #{vim_selected}>vim</option>
        <option value="vscode" #{vscode_selected}>vscode</option>
        <option value="sublime" #{sublime_selected}>sublime</option>
</select></p>
      }
      s << %{
        <p>
        <label for="pref_aceeditor_theme">#{l(:aceeditor_theme)}</label>
        <select name="pref[aceeditor_theme]" id="pref_aceeditor_theme">
      }
      s << tlist.join("\n")
      s << %{
      </select></p>
      }
      return s
    end
  end
end
