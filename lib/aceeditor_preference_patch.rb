require_dependency 'user'

module AceEditor
  class Preference
    def initialize(user)
      @user = user
      @prefs = {}
    end

    def []=(attr, value)
      prefixed = "aceeditor_#{attr}".intern

      case attr
        when :keybind
          value = value.to_s.strip
        when :theme
          value = value.to_s.strip
        else
          raise "Unsupported attribute '#{attr}'"
      end

      @user.pref[prefixed] = value
      @prefs[prefixed] = value
      @user.pref.save!
    end

    def [](attr)
      prefixed = "aceeditor_#{attr}".intern

      unless @prefs.include?(prefixed)
        # default value
        value = @user.pref[prefixed].to_s.strip
        @prefs[prefixed] = value
      end

      return @prefs[prefixed]
    end
  end

  module UserPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
    end

    module InstanceMethods
      def aceeditor_preference
        @aceeditor_preference ||= AceEditor::Preference.new(self)
      end
    end
  end
end

User.send(:include, AceEditor::UserPatch) unless User.included_modules.include? AceEditor::UserPatch
