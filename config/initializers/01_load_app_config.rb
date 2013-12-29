# -*- encoding : utf-8 -*-
APP_CONFIG = YAML.load(File.read("#{Rails.root}/config/app_config.yml", safe: true))[Rails.env].symbolize_keys
