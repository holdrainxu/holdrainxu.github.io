# Windows-only patch for jekyll-imagemagick.
#
# Why: on Windows the built-in C:\Windows\System32\convert.exe (FAT->NTFS converter)
# shadows ImageMagick's "convert" command and emits a GBK-encoded error message
# that Jekyll's logger then chokes on (invalid UTF-8). On Linux/macOS the gem's
# default behaviour is fine, so we patch nothing there — important because the
# Ubuntu GitHub-Actions runner installs ImageMagick 6, which only ships
# `convert` (no `magick` binary).

if Gem.win_platform?
  require 'open3'
  require 'jekyll-imagemagick/convert'

  module JekyllImagemagick
    class ImageConvert
      def self.run(input_file, output_file, flags, long_edge, resize_flags)
        Jekyll.logger.info(LOG_PREFIX, "Generating image \"#{output_file}\"")

        cmd = "magick \"#{input_file}\" #{flags} "
        if long_edge != 0
          cmd += "-resize \"#{long_edge}>\" #{resize_flags} "
        end
        cmd += "\"#{output_file}\""
        Jekyll.logger.debug(LOG_PREFIX, "Running command \"#{cmd}\"")
        run_cmd(cmd)
      end

      def self.run_cmd(cmd)
        exit_code = 0
        error = ''
        output = ''
        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          stdin.close
          output = stdout.gets
          error = stderr.gets
          exit_code = wait_thr.value
        end

        if exit_code != 0
          safe_error = (error || '').to_s.force_encoding('UTF-8').scrub('?')
          Jekyll.logger.error(LOG_PREFIX, "Command returned #{exit_code} with error #{safe_error}")
        end

        [output, error]
      end
    end
  end
end
