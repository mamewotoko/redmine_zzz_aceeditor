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

          url = "#{Redmine::Utils.relative_url_root}/help/#{current_language.to_s.downcase}/wiki_syntax.html"

          # wikitoolbar_for_without_codemirror(field_id) +
          javascript_tag(%(
          var textarea = $('##{field_id}');
          var div = $('<div></div>');
          div.css({width: '90%', height: '400px'});
          div.attr('id', '#{field_id}_ace');
          textarea.after(div);
          textarea.hide();
          var editor = ace.edit("#{field_id}_ace", {mode: "ace/mode/markdown"});
          editor.getSession().setValue(textarea.val());
          editor.renderer.setShowGutter(true);
          editor.getSession().on('change', function(){
            textarea.val(editor.getSession().getValue());
            });
//              var editor = ace.edit("#{field_id}");
//            editor.setTheme("ace/theme/twilight");
            editor.setKeyboardHandler("ace/keyboard/emacs");
            editor.session.setMode("ace/mode/markdown");
          ))
        end

        def heads_for_aceeditor
          unless @heads_for_codemirror_included
            content_for :header_tags do
              javascript_include_tag("ace", :plugin => 'redmine_aceeditor') +
              javascript_include_tag("textarea-as-ace-editor.min", :plugin => 'redmine_aceeditor') +
              javascript_include_tag("mode-markdown", :plugin => 'redmine_aceeditor') +
              javascript_include_tag("ext-static_highlight", :plugin => 'redmine_aceeditor') +
#              javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}") +
              stylesheet_link_tag('jstoolbar')
            end
            @heads_for_codemirror_included = true
          end
        end

      end

    end
  end
end


unless Redmine::WikiFormatting::Markdown::Helper.included_modules.include?(RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
  Redmine::WikiFormatting::Markdown::Helper.send(:include, RedmineAceEditorPlugin::Patches::RedmineAceEditorPatch)
end
