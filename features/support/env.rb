require 'frank-cucumber'

# UIQuery is deprecated. Please use the shelley selector engine. 
Frank::Cucumber::FrankHelper.use_shelley_from_now_on

# override default timeout; not quite sure how exactly this works, tried a few different things.
# TODO: clean-up to do whatever is actually the correct thing.
timeoutToUse = 20
Frank::Cucumber::WaitHelper.const_set("TIMEOUT", timeoutToUse)
# echo the timeout value so it appears in cucumber reports.
puts "Timeout in use: #{timeoutToUse}"
