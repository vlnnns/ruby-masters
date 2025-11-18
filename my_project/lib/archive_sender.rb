require 'sidekiq'
require 'pony'

module MyProject
  class ArchiveSender
    include Sidekiq::Worker

    def perform(file_path, email)
      if File.exist?(file_path)
        Pony.mail(
          to: email,
          subject: 'Your Parsed Data Archive',
          body: 'Please find the attached archive with parsed data.',
          attachments: { File.basename(file_path) => File.read(file_path) },
          via: :test
        )
        puts "[Sidekiq] Email sent to #{email} with archive: #{file_path}"
      else
        puts "[Sidekiq] Error: File not found - #{file_path}"
      end
    rescue StandardError => e
      puts "[Sidekiq] Failed to send email: #{e.message}"
    end
  end
end