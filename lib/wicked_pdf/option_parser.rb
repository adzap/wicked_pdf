module WickedPdf
  class OptionParser
    def parse(options)
      [
        parse_extra(options),
        parse_others(options),
        parse_global(options),
        parse_outline(options.delete(:outline)),
        parse_header_footer(:header => options.delete(:header),
                            :footer => options.delete(:footer),
                            :layout => options[:layout]),
        parse_cover(options.delete(:cover)),
        parse_toc(options.delete(:toc)),
        parse_basic_auth(options)
      ].flatten
    end

    private

    def parse_extra(options)
      return [] if options[:extra].nil?
      return options[:extra].split if options[:extra].respond_to?(:split)
      options[:extra]
    end

    def parse_basic_auth(options)
      if options[:basic_auth]
        user, passwd = Base64.decode64(options[:basic_auth]).split(':')
        ['--username', user, '--password', passwd]
      else
        []
      end
    end

    def parse_header_footer(options)
      r = []
      unless options.blank?
        [:header, :footer].collect do |hf|
          next if options[hf].blank?
          opt_hf = options[hf]
          r += make_options(opt_hf, [:center, :font_name, :left, :right], hf.to_s)
          r += make_options(opt_hf, [:font_size, :spacing], hf.to_s, :numeric)
          r += make_options(opt_hf, [:line], hf.to_s, :boolean)
          if options[hf] && options[hf][:content]
            @hf_tempfiles = [] unless defined?(@hf_tempfiles)
            @hf_tempfiles.push(tf = WickedPdf::Tempfile.new("wicked_#{hf}_pdf.html"))
            tf.write options[hf][:content]
            tf.flush
            options[hf][:html] = {}
            options[hf][:html][:url] = "file:///#{tf.path}"
          end
          unless opt_hf[:html].blank?
            r += make_option("#{hf}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
          end
        end
      end
      r
    end

    def parse_cover(argument)
      arg = argument.to_s
      return [] if arg.blank?
      # Filesystem path or URL - hand off to wkhtmltopdf
      if argument.is_a?(Pathname) || (arg[0, 4] == 'http')
        ['cover', arg]
      else # HTML content
        @hf_tempfiles ||= []
        @hf_tempfiles << tf = WickedPdf::Tempfile.new('wicked_cover_pdf.html')
        tf.write arg
        tf.flush
        ['cover', tf.path]
      end
    end

    def parse_toc(options)
      return [] if options.nil?
      r = ['toc']
      unless options.blank?
        r += make_options(options, [:font_name, :header_text], 'toc')
        r += make_options(options, [:xsl_style_sheet])
        r += make_options(options, [:depth,
                                    :header_fs,
                                    :text_size_shrink,
                                    :l1_font_size,
                                    :l2_font_size,
                                    :l3_font_size,
                                    :l4_font_size,
                                    :l5_font_size,
                                    :l6_font_size,
                                    :l7_font_size,
                                    :level_indentation,
                                    :l1_indentation,
                                    :l2_indentation,
                                    :l3_indentation,
                                    :l4_indentation,
                                    :l5_indentation,
                                    :l6_indentation,
                                    :l7_indentation], 'toc', :numeric)
        r += make_options(options, [:no_dots,
                                    :disable_links,
                                    :disable_back_links], 'toc', :boolean)
        r += make_options(options, [:disable_dotted_lines,
                                    :disable_toc_links], nil, :boolean)
      end
      r
    end

    def parse_outline(options)
      r = []
      unless options.blank?
        r = make_options(options, [:outline], '', :boolean)
        r += make_options(options, [:outline_depth], '', :numeric)
      end
      r
    end

    def parse_margins(options)
      make_options(options, [:top, :bottom, :left, :right], 'margin', :numeric)
    end

    def parse_global(options)
      r = []
      unless options.blank?
        r += make_options(options, [:orientation,
                                    :dpi,
                                    :page_size,
                                    :page_width,
                                    :title])
        r += make_options(options, [:lowquality,
                                    :grayscale,
                                    :no_pdf_compression], '', :boolean)
        r += make_options(options, [:image_dpi,
                                    :image_quality,
                                    :page_height], '', :numeric)
        r += parse_margins(options.delete(:margin))
      end
      r
    end

    def parse_others(options)
      r = []
      unless options.blank?
        r += make_options(options, [:proxy,
                                    :username,
                                    :password,
                                    :encoding,
                                    :user_style_sheet,
                                    :viewport_size,
                                    :window_status])
        r += make_options(options, [:cookie,
                                    :post], '', :name_value)
        r += make_options(options, [:redirect_delay,
                                    :zoom,
                                    :page_offset,
                                    :javascript_delay], '', :numeric)
        r += make_options(options, [:book,
                                    :default_header,
                                    :disable_javascript,
                                    :enable_plugins,
                                    :disable_internal_links,
                                    :disable_external_links,
                                    :print_media_type,
                                    :disable_smart_shrinking,
                                    :use_xserver,
                                    :no_background,
                                    :images,
                                    :no_images,
                                    :no_stop_slow_scripts], '', :boolean)
      end
      r
    end

    def make_options(options, names, prefix = '', type = :string)
      return [] if options.nil?
      names.collect do |o|
        if options[o].blank?
          []
        else
          make_option("#{prefix.blank? ? '' : prefix + '-'}#{o}",
                      options[o],
                      type)
        end
      end
    end

    def make_option(name, value, type = :string)
      if value.is_a?(Array)
        return value.collect { |v| make_option(name, v, type) }
      end
      if type == :name_value
        parts = value.to_s.split(' ')
        ["--#{name.tr('_', '-')}", *parts]
      elsif type == :boolean
        if value
          ["--#{name.tr('_', '-')}"]
        else
          []
        end
      else
        ["--#{name.tr('_', '-')}", value.to_s]
      end
    end
  end
end
