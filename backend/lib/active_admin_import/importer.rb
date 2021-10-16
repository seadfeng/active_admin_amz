# frozen_string_literal: true
require 'csv'
module ActiveAdminImport
  class Importer
    attr_reader :resource, :options, :result, :model
    attr_accessor :csv_lines, :headers, :history_csv_lines, :history_headers

    OPTIONS = [
      :validate,
      :on_duplicate_key_update,
      :on_duplicate_key_ignore,
      :ignore,
      :timestamps,
      :before_import,
      :after_import,
      :before_batch_import,
      :after_batch_import,
      :headers_rewrites,
      :batch_size,
      :batch_transaction,
      :csv_options
    ].freeze

    def initialize(resource, model, options)
      @resource = resource
      @model = model
      @headers = model.respond_to?(:csv_headers) ? model.csv_headers : []  
      assign_options(options)
    end

    def import_result
      @import_result ||= ImportResult.new
    end

    def file
      @model.file
    end

    def cycle(lines) 
      @csv_lines = CSV.parse(lines.join, @csv_options) 
      @history_csv_lines = CSV.parse(lines.join, @csv_options) 
      import_result.add(batch_import, lines.count)
    end

    def import
      run_callback(:before_import)
      process_file
      run_callback(:after_import)
      import_result
    end

    def import_options
      @import_options ||= options.slice(
        :validate,
        :validate_uniqueness,
        :on_duplicate_key_update,
        :on_duplicate_key_ignore,
        :ignore,
        :timestamps,
        :batch_transaction,
        :batch_size
      )
    end

    def batch_replace(header_key, options) 
      batch_replace_history(header_key, options)
      index = header_index(header_key)
      csv_lines.map! do |line|
        from = line[index]&.downcase&.lstrip&.rstrip
        line[index] = options[from] if options.key?(from)
        line
      end 
    end

    def batch_replace_history(header_key, options)
      history_index = history_header_index(header_key)
      history_csv_lines.map! do |line|
        from = line[history_index]&.downcase&.lstrip&.rstrip
        line[history_index] = options[from] if options.key?(from)
        line
      end 
    end


    # Use this method when CSV file contains unnecessary columns
    #
    # Example:
    #
    # ActiveAdmin.register Post
    #   active_admin_import before_batch_import: lambda { |importer|
    #                         importer.batch_slice_columns(['name', 'birthday'])
    #                       }
    # end
    #
    def batch_slice_columns(slice_columns)
      # Only set @use_indexes for the first batch so that @use_indexes are in correct
      # position for subsequent batches
      unless defined?(@use_indexes)
        @use_indexes = []
        headers.values.each_with_index do |val, index|
          @use_indexes << index if val.to_s.in?(slice_columns)
        end
        return csv_lines if @use_indexes.empty?

        # slice CSV headers
        @headers = headers.to_a.values_at(*@use_indexes).to_h
      end

      # slice CSV values
      csv_lines.map! do |line|
        line.values_at(*@use_indexes)
      end 
    end

    def values_at(header_key, history = false)
      if history
          history_csv_lines.collect { |line| history_header_index(header_key)? line[history_header_index(header_key)] : "" } 
      else
          csv_lines.collect { |line|  header_index(header_key)? line[header_index(header_key)] : ""  } 
      end
    end

    def header_index(header_key)
      headers.values.index(header_key)
    end

    def history_header_index(header_key)
      history_headers.values.index(header_key)
    end

    protected

    def process_file
      lines = []
      batch_size = options[:batch_size].to_i
      File.open(file.path, "r:UTF-8") do |f|
        # capture headers if not exist
        prepare_headers { CSV.parse(f.readline, @csv_options).first }
        f.each_line do |line|
          lines << line if line.present?
          if lines.size == batch_size || f.eof?
            cycle(lines)
            lines = []
          end
        end
      end
      cycle(lines) unless lines.blank?
    end

    def prepare_headers
      headers = self.headers.present? ? self.headers.map(&:to_s) : yield
      @headers = Hash[headers.zip(headers.map { |el| el.underscore.gsub(/\s+/, '_') })].with_indifferent_access
      @headers.merge!(options[:headers_rewrites].symbolize_keys.slice(*@headers.symbolize_keys.keys))
      @headers  
      @history_headers = self.headers
    end

    def run_callback(name)
      options[name].call(self) if options[name].is_a?(Proc)
    end

    def batch_import
      batch_result = nil
      @resource.transaction do
        run_callback(:before_batch_import)
        batch_result = resource.import(headers.values, csv_lines, import_options)
        raise ActiveRecord::Rollback if import_options[:batch_transaction] && batch_result.failed_instances.any?
        run_callback(:after_batch_import)
      end
      batch_result
    end

    def assign_options(options)
      @options = {
        batch_size: 1000,
        validate_uniqueness: true
      }.merge(options.slice(*OPTIONS))
      detect_csv_options
    end

    def detect_csv_options
      @csv_options = if model.respond_to?(:csv_options)
                       model.csv_options
                     else
                       options[:csv_options] || {}
                     end.reject { |_, value| value.nil? || value == "" }
    end
  end
end
