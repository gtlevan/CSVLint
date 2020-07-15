Then(/^the url "(.*?)" should be persisted in the database$/) do |url|
  Validation.count.should == 1
  Validation.first.url.should == url
  filename = File.basename(URI.parse(url).path)
  Validation.first.filename.should == filename
end

Then(/^I should be redirected to my package page$/) do
  patiently do
    current_path.should == package_path(Package.first)
  end
end

Then(/^my datapackage should be persisited in the database$/) do
  Package.count.should == 1
end

When(/^I click on the first report link$/) do
  click_link("View report")
end