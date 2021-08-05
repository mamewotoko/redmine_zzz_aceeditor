module RedmineAceEditorPlugin
  module Patches
    module RedmineAceEditorPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          # alias_method_chain :wikitoolbar_for, :aceeditor,
          alias_method :wikitoolbar_for_without_aceeditor, :wikitoolbar_for
          alias_method :wikitoolbar_for, :wikitoolbar_for_with_aceeditor
        end
      end

      module InstanceMethods
        def wikitoolbar_for_with_aceeditor(field_id, preview_url = preview_text_path)
          heads_for_aceeditor
          
          keybind = User.current.aceeditor_preference[:keybind]
          
          # url = "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax.html"
          # result = javascript_tag("var wikiToolbar = new jsToolBar(document.getElementById('#{field_id}')); wikiToolbar.setHelpLink('#{escape_javascript url}'); wikiToolbar.setPreviewUrl('#{escape_javascript preview_url}'); wikiToolbar.draw();")
          result = ""

          if keybind.nil? or keybind == ""
            keybind = "textarea"
          end

          theme = User.current.aceeditor_preference[:theme]
          if theme.nil? or theme == ""
            theme= "chrome"
          end

          wikitoolbar_for_without_aceeditor(field_id) +
          javascript_tag(%(
            (function(){
              if("#{keybind}" == "textarea"){
                  return;
              }
              var textarea = $('##{field_id}');
              var div = $('<div></div>');
              div.css({width: '100%', height: '400px'});
              div.attr('id', '#{field_id}_ace');
              textarea.after(div);
              textarea.hide();
              var editor = ace.edit("#{field_id}_ace", {mode: "ace/mode/markdown"});
              editor.getSession().setValue(textarea.val());
              editor.renderer.setShowGutter(true);
              editor.getSession().on('change', function(){
                textarea.val(editor.getSession().getValue());
              });
              editor.setTheme("ace/theme/#{theme}");
              editor.setKeyboardHandler("ace/keyboard/#{keybind}");
              //Key Support
              //Ctrl-k: clipboard is not supported
              //Ctrl-y: clipboard is not supported
              //Ctrl-w: supported
              //Alt-w: supported

              editor.on("copy", function(e){
                 navigator.clipboard.writeText(e.text);
                 return true;
              });

              //yank from clipboard
              // editor.commands.addCommand({
              //    name: "yankfromclipboard",
              //    bindKey: { win: "Ctrl-y", mac: "Ctrl-y"},
              //    exec: function(){ 
              //      //TOOD: always use clipboard
              //      navigator.clipboard.readText().then(function(text) {
              //          editor.execCommand("paste", text)
              //      });
              //    }
              // });
              // editor.on("paste", function(e){
              //   //Cmd-v, Ctrl-y -> paste
              //   console.log("paste");
              //   console.log(e);

              //   if(navigator.clipboard){
              //       navigator.clipboard.readText()
              //          .then(function(text){
              //                    editor.session.insert(editor.getCursorPosition(), text);
              //                },
              //                function(){
              //                    editor.session.insert(editor.getCursorPosition(), e.text);
              //                });
              //       return true;
              //   }
              //   return false;
              // })
              //kill-region with clipboard

              if("#{keybind}" == "emacs"){
                  editor.commands.addCommand({
                     name: "kill-region",
                     bindKey: { win: "Ctrl-w", mac: "Ctrl-w"},
                     exec: function(){ 
                       //TOOD: always use clipboard
                       var text = editor.getCopyText();
                       editor.execCommand("cut");
                       console.log("kill-region cut");
                       navigator.clipboard.writeText(text);
                     }
                  });
                  //copy-region-as-kill with clipboard
                  editor.commands.addCommand({
                     name: "copy-region-as-kill",
                     bindKey: { win: "Ctrl-w", mac: "Ctrl-w"},
                     exec: function(){ 
                       //TOOD: always use clipboard
                       var text = editor.getCopyText();
                       editor.execCommand("copy");
                       console.log("copy-region-as-kill copy");
                       navigator.clipboard.writeText(text);
                     }
                  });
                  //kill line
                  //editor.commands.addCommand({
                  //   name: "kill-line",
                  //   bindKey: { win: "Ctrl-k", mac: "Ctrl-k"},
                  //   exec: function(){ 
                  //     //TOOD: always use clipboard
                  //     var text = editor.getCopyText();
                  //     editor.execCommand("copy");
                  //     console.log("copy-region-as-kill copy");
                  //     navigator.clipboard.writeText(text);
                  //   }
                  //});
              }
              //else if("#{keybind}" == "vim"){
                  //ctrl-m -> enter
              //    editor.map(
              //}

              //TODO:modify mode, support textile
              editor.session.setMode("ace/mode/markdown");
              editor.session.setTabSize(4);
              editor.session.setUseSoftTabs(true);
              editor.setOption("showInvisibles", true);

              var base = textarea.parent().parent();
              //hide toolbar buttons
              base.find("div.jstElements").hide();
              base.find("a.tab-preview").on("click", function(event){
                  div.hide();
              });
              base.find ("a.tab-edit").on("click", function(event){
                  div.show();
              });
            })();
          ))
        end

        def heads_for_aceeditor
          unless @heads_for_aceeditor_included
            content_for :header_tags do
              javascript_include_tag("ace", :plugin => :redmine_zzz_aceeditor) +
                javascript_include_tag("textarea-as-ace-editor.min", :plugin => :redmine_zzz_aceeditor) +
                javascript_include_tag("mode-markdown", :plugin => :redmine_zzz_aceeditor) +
                javascript_include_tag("ext-static_highlight", :plugin => :redmine_zzz_aceeditor)
              # + javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}")
              # + stylesheet_link_tag('jstoolbar')
            end
            @heads_for_aceeditor_included = true
          end
        end
      end
    end
  end
end


unless Redmine::WikiFormatting::Markdown::Helper.included_modules.include?(RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
   Redmine::WikiFormatting::Markdown::Helper.send(:include, RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
end

unless Redmine::WikiFormatting::Textile::Helper.included_modules.include?(RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
   Redmine::WikiFormatting::Textile::Helper.send(:include, RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
end

# TODO: control plugin load order more specific way (e.g. list plugins in config.pluguins)
if Redmine::Plugin.installed? :redmine_pandoc_formatter
  unless RedminePandocFormatter::Helper.included_modules.include?(RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
    RedminePandocFormatter::Helper.send(:include, RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
  end
end

#
# if Redmine::Plugin.installed? :redmine_restructuredtext_formatter
#   unless RedmineRestructuredtextFormatter::Helper.included_modules.include?(RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
#     RedmineRestructuredtextFormatter::Helper.send(:include, RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
#   end
# end
