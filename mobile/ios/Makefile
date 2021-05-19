.PHONY: test
test:
	@bundle exec fastlane test

.PHONY: format
format:
	@swift format \
		--ignore-unparsable-files \
		--recursive \
		--in-place \
		./Sources \
		./Tests \
		./MetaTrackerLib
