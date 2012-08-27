# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
	watch('Gemfile')
end

guard :rspec, version: 2, cli: "--color" do
  watch(%r{^spec/.+_spec\.rb$})
	watch(%r{^spec/factories\.rb$}) { "spec" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

