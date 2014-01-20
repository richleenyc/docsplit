module Docsplit

  # Delegates to **pdftk** in order to create bursted single pages from
  # a PDF document.
  class PageExtractor

    # Burst a list of pdfs into single pages, as `pdfname_pagenumber.pdf`.
    def extract(pdfs, opts)
      extract_options opts
      [pdfs].flatten.each do |pdf|
        page_path = "#{pdf}_%d"
        output_dir = File.split(pdf)[0]
        FileUtils.mkdir_p @output unless File.exists?(@output)
        
        cmd = if DEPENDENCIES[:pdftailor] # prefer pdftailor, but keep pdftk for backwards compatability
          "pdftailor unstitch --output #{ESCAPE[page_path]} #{ESCAPE[pdf]} 2>&1"
        else
          "pdftk #{ESCAPE[pdf]} burst output #{ESCAPE[page_path]} 2>&1"
        end
        result = `#{cmd}`.chomp
        FileUtils.rm('#{output_dir}/doc_data.txt') if File.exists?('#{output_dir}/doc_data.txt')
        raise ExtractionFailed, result if $? != 0
        result
      end
    end


    private

    def extract_options(options)
      @output = options[:output] || '.'
    end

  end

end