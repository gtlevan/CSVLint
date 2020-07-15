require 'spec_helper'

describe "validation/_message.html.erb", type: :view do

  it "displays errors and warnings correctly" do

    {
      :encoding => "Your CSV appears to be encoded in <code>iso-8859-1</code>. We recommend you use <code>UTF-8</code>.",
      :no_encoding => "The encoding of your CSV file is not being declared in the HTTP response.",
      :invalid_encoding => "Your CSV appears to be encoded in <code>iso-8859-1</code>, but invalid characters were found",
      :wrong_content_type => "Your CSV file is being delivered with an incorrect <code>Content-Type</code>",
      :no_content_type => "Your CSV file is being delivered without a <code>Content-Type</code> header",
      :nonrfc_line_breaks => "Your CSV appears to use <code>LF</code> line-breaks"
    }.each do |k, v|

      message = Csvlint::ErrorMessage.new(k, nil, nil, nil, nil, nil)
      validator = double("validator")
      allow(validator).to receive(:encoding) { "iso-8859-1" }
      allow(validator).to receive(:content_type) { "text/plain" }
      allow(validator).to receive(:extension) { ".csv" }
      allow(validator).to receive(:headers) { {"content-type" => "text/plain"} }
      allow(validator).to receive(:line_breaks) { "\n" }
      allow(validator).to receive(:schema) { nil }

      @validation = Validation.create(result: validator)

      render :partial => "validation/message", :locals => { :message => message, :validator => validator }

      expect(rendered).to include v
    end

  end

end