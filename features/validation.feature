Feature: CSV Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid

  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/3000_rows.csv" is available at the URL "http://example.org/large.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
    Given the fixture "csvs/revalidate.csv" is available at the URL "http://example.org/revalidate.csv"

  Scenario: Enter a URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And my url should be persisted in the database

  Scenario: Validation with info messages
    When I go to the homepage
    And I enter "http://example.org/info.csv" in the "url" field
    And I press "Validate"
    Then I should see "Non-standard Line Breaks"

  Scenario: Validation of a URL that 404s
    Given the URL "http://example.org/test2.csv" returns a status of "404"
    When I go to the homepage
    And I enter "http://example.org/test2.csv" in the "url" field
    And I press "Validate"
    Then I should see "There appears to be a problem with the URL you supplied."

  Scenario: Validation of a URL that 500s
    Given the URL "http://example.org/test2.csv" returns a status of "500"
    When I go to the homepage
    And I enter "http://example.org/test2.csv" in the "url" field
    And I press "Validate"
    Then I should see "There appears to be a problem with the URL you supplied."

  @rackmock @javascript
  Scenario: Validation of a URL that 413s
    Given I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And the data exceeds the amount the proxy can handle
    When I press "Validate"
    Then I should see "The request couldn't complete"

  Scenario: Upload a file for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Validate"
    Then I should see a page of validation results
    And my file should be persisted in the database

  Scenario: Upload a file with warnings
    When I go to the homepage
    And I attach the file "csvs/warnings.csv" to the "file" field
    And I press "Validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
    And the database record should have a "warning" of the type "check_options"
    And I should see a page of validation results

  Scenario: Upload a file with errors
    When I go to the homepage
    And I attach the file "csvs/errors.csv" to the "file" field
    And I press "Validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
    And the database record should have a "error" of the type "ragged_rows"
    And I should see a page of validation results

  Scenario: Find a CSV by url
    Given I have already validated the URL "http://example.org/test.csv"
    When I load the validation by URL
    Then I should see a page of validation results
    And I should see my URL

  Scenario: Validate a CSV by url
    Given I have not already validated the URL "http://example.org/test.csv"
    When I load the validation by URL
    Then I should get a 202 response
    When the CSV has finished processing
    And I load the validation by URL
    Then I should see a page of validation results
    And I should see my URL

  Scenario: Validate a large CSV by url
    Given I have not already validated the URL "http://example.org/large.csv"
    When I load the validation by URL
    Then I should get a 202 response
    When the CSV has finished processing
    And I load the validation by URL
    Then I should see a page of validation results
    And I should see the number of rows processed
    And the number of rows processed should equal 3000
    #TODO this is the new addition - decide on how row number is to be evaluated
    And I should see my URL

  Scenario: Validate a CSV and request badge
    Given I have not already validated the URL "http://example.org/test.csv"
    When I load the validation badge by URL in "png" format
    Then I should get a 202 response
    And I should get a badge in "png" format

  Scenario: Find a CSV badge by url
    Given I have already validated the URL "http://example.org/test.csv"
    When I load the validation badge by URL in "png" format
    Then I should get a badge in "png" format

  Scenario: Updated CSVs should be revalidated
    Given I have already validated the URL "http://example.org/test.csv"
    And it's two weeks in the future
    And I have updated the URL "http://example.org/test.csv"
    Then the validation should be updated
    When I load the validation by URL

  Scenario: Non-updated CSVs should not be revalidated
    Given I have already validated the URL "http://example.org/test.csv"
    And the CSV has not changed
    Then the validation should not be updated
    When I load the validation by URL

  Scenario: CSVs hosted on servers that don't support If-Modified-Since should not be revalidated every time
    Given I have already validated the URL "http://example.org/test.csv"
    And the server does not support If-Modified-Since
    Then the validation should not be updated
    When I load the validation by URL

  Scenario: CSVs hosted on servers that don't support If-Modified-Since should not be revalidated after two weeks
    Given I have already validated the URL "http://example.org/test.csv"
    And the server does not support If-Modified-Since
    And it's three hours in the future
    Then the validation should be updated
    When I load the validation by URL

  Scenario: Give the option to revalidate if CSV options seem incorrect
    When I go to the homepage
    And I enter "http://example.org/revalidate.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should be given the option to revalidate using a different dialect

#  Scenario: Revalidate CSV using new options
#    When I go to the homepage
#    And I enter "http://example.org/revalidate.csv" in the "url" field
#    And I press "Validate"
#    And I enter ";" in the "Field delimiter" field
#    And I enter "'" in the "Quote character" field
#    And I select "LF (\n)" from the "Line terminator" dropdown
#    And I press "Revalidate"
#    Then I should see a page of validation results
#    And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
#    And I should not see "Check CSV parsing options"
#    And I should see "Non standard dialect"

  @revalidate
  Scenario: Revalidate CSV using same options should offer revalidation again
    When I go to the homepage
    And I enter "http://example.org/revalidate.csv" in the "url" field
    And I press "Validate"
    And I press "Revalidate"
    Then I should see a page of validation results
    And I should see "Check CSV parsing options"
    And I should be given the option to revalidate using a different dialect

#  Scenario: Revalidate file using new options
#    When I go to the homepage
#    And I attach the file "csvs/revalidate.csv" to the "file" field
#    And I press "Validate"
#    And I enter ";" in the "Field delimiter" field
#    And I enter "'" in the "Quote character" field
#    And I select "LF (\n)" from the "Line terminator" dropdown
#    And I press "Revalidate"
#    Then I should see a page of validation results
#    And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
#    And I should not see "Check CSV parsing options"
#    And I should see "Non standard dialect"

  @revalidate
  Scenario: Revalidate file using same options should offer revalidation again
    When I go to the homepage
    And I attach the file "csvs/revalidate.csv" to the "file" field
    And I press "Validate"
    And I press "Revalidate"
    Then I should see a page of validation results
    And I should see "Check CSV parsing options"
    And I should be given the option to revalidate using a different dialect

  @revalidate
  Scenario: Standardised CSV download
    When I go to the homepage
    And I enter "http://example.org/revalidate.csv" in the "url" field
    And I press "Validate"
    And I enter ";" in the "Field delimiter" field
    And I enter "'" in the "Quote character" field
    And I select "LF (\n)" from the "Line terminator" dropdown
    And I press "Revalidate"
    Then I should see a page of validation results
    When I click on "Download Standardised CSV"
    Then a CSV file should be downloaded
    And that CSV file should have a field "firstname"
    And that CSV file should have a field "lastname"
    And that CSV file should have a field "status"
    And that CSV file should have double-quoted fields
    And that CSV file should use CRLF line endings

  @revalidate
  Scenario: Standardised CSV download with file
    When I go to the homepage
    And I attach the file "csvs/revalidate.csv" to the "file" field
    And I press "Validate"
    And I enter ";" in the "Field delimiter" field
    And I enter "'" in the "Quote character" field
    And I select "LF (\n)" from the "Line terminator" dropdown
    And I press "Revalidate"
    Then I should see a page of validation results
    When I click on "Download Standardised CSV"
    Then a CSV file should be downloaded
    And that CSV file should have a field "firstname"
    And that CSV file should have a field "lastname"
    And that CSV file should have a field "status"
    And that CSV file should have double-quoted fields
    And that CSV file should use CRLF line endings

  Scenario: Validation with Github raw URL
    Given the fixture "csvs/valid.csv" is available at the URL "https://raw.githubusercontent.com/username/project/master/test.csv"
    And the URL "https://raw.githubusercontent.com/username/project/master/test.csv" returns a Content-Type of "text/plain; charset=utf-8"
    When I go to the homepage
    And I enter "https://raw.githubusercontent.com/username/project/master/test.csv" in the "url" field
    And I press "Validate"
    Then I should see "It looks like your CSV is hosted on Github."
