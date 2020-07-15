require 'uri'
require 'zipfile'

class ValidationController < ApplicationController

  before_filter(:only => [:show]) { alternate_formats [:json] }

  def show
    @validation = Validation.fetch_validation(params[:id], params[:format], params[:revalidate])

    raise ActionController::RoutingError.new('Not Found') if @validation.state.nil?
    # @result stores all the validation errors, warnings and information messages
    @result = @validation.validator
    # byebug
    @dialect = @result.dialect || Validation.standard_dialect
    # Responses
    respond_to do |wants|
      wants.html
      wants.json
      wants.png { render_badge(@validation.state, "png") }
      wants.svg { render_badge(@validation.state, "svg") }
      wants.csv { send_data standardised_csv(@validation), type: "text/csv; charset=utf-8", disposition: "attachment" }
    end
  end

  def update
    # this method is triggered when user revalidates a schema
    dialect = build_dialect(params)
    # build a fresh dialect for comparing a file against
    v = Validation.find(params[:id])
    if v.has_attribute?(:expirable_created_at)
      # has expirable_created_at value
      v.update_validation(dialect, expiry=true)
    else
      v.update_validation(dialect)
    end
    cloudflare.zone_file_purge('csvlint.io', validation_url(v))
    redirect_to validation_path(v)
  end

  private

  def standardised_csv(validation)
    data = CSV.parse(validation.csv, validation.parse_options.symbolize_keys)
    CSV.generate(standard_csv_options) do |csv|
      data.each do |row|
        csv << row if row
      end
    end
  end

  def build_dialect(params)
    case params[:line_terminator]
      when "auto"
        line_terminator = :auto
      when "\\n"
        line_terminator = "\n"
      when "\\r\\n"
        line_terminator = "\r\n"
    end

    {
        "header" => params[:header],
        "delimiter" => params[:delimiter],
        "skipInitialSpace" => params[:skip_initial_space],
        "lineTerminator" => line_terminator,
        "quoteChar" => params[:quote_char]
    }.reject {|k,v| v.nil?}
  end

end
