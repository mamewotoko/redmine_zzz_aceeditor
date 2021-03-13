require_dependency 'redmine_aceeditor/hooks'
require_dependency 'redmine_aceeditor'
require_dependency 'aceeditor_preference_patch'
require_dependency 'aceeditor_controller_patch'

Redmine::Plugin.register :redmine_zzz_aceeditor do
  name 'Redmine Ace Editor plugin'
  author 'Takashi Masuyama'
  description 'This is a Ace editor plugin for Redmine wiki'
  version '0.0.3'
  url 'https://github.com/mamewotoko/redmine_aceeditor'
  author_url 'mailto:mamewotoko@gmail.com'
end
Rails.logger.info("ace editor registered")
