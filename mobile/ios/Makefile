.PHONY: test
test:
	@bundle exec fastlane test

.PHONY: core-data-gen
core-data-gen:
	@swiftgen run coredata \
		Sources/Shared/CoreData/MetaTracker.xcdatamodeld \
		--templateName swift5 \
		--output Sources/Shared/CoreData/CoreData.generated.swift


.PHONY: format
format:
	@swift format \
		--ignore-unparsable-files \
		--recursive \
		--in-place \
		./Sources \
		./Tests \
		./MetaTrackerLib
