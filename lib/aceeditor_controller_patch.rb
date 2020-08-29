require_dependency 'my_controller'

module AceEditor
  module MyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        after_action :save_aceeditor_preferences, :only => [:account]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def save_aceeditor_preferences
        if request.post? && flash[:notice] == l(:notice_account_updated)
          keybind = params[:pref][:aceeditor_keybind]
          # logger.info("save keybind #{keybind}")
          # TODO: check value in emacs, vim , windows
          User.current.aceeditor_preference[:keybind] = keybind

          theme = params[:pref][:aceeditor_theme]
          # logger.info("save theme #{theme}")
          User.current.aceeditor_preference[:theme] = theme
        end
      end
    end
  end
end

MyController.send(:include, AceEditor::MyControllerPatch) unless MyController.included_modules.include? AceEditor::MyControllerPatch
