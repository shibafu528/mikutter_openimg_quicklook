# frozen_string_literal: true

require 'securerandom'
require 'fileutils'

Plugin.create(:openimg_quicklook) do
  intent Plugin::Openimg::Photo do |intent_token|
    download_and_open(intent_token.model)
  end

  intent :photo do |intent_token|
    download_and_open(intent_token.model)
  end

  def download_and_open(photo_model)
    variant = photo_model.maximum
    variant.download.next do |model|
      ext = File.extname(variant.uri.path)&.gsub(/:[a-z]+\z/, '')
      path = File.join(File.expand_path(Environment::TMPDIR), "#{SecureRandom.uuid}#{ext}")
      File.open(path, 'wb') do |io|
        io.write(model.blob)
      end
      Process.detach(spawn('qlmanage', '-p', path))
      Kernel.at_exit do
        FileUtils.rm_f(path)
      end
    end
  end
end
