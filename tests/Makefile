EXCLUDE_PATTERN="valid_MACHINE_ARCH"
INCLUDE_PATTERN="lib/"

all: unittest coverage

unittest:
	./NetBSD_test.sh
	./Logging_test.sh
	./Command_test.sh
	./output_file_and_package_pair_lists_test.sh

coverage:
	kcov \
		--include-pattern=${INCLUDE_PATTERN} \
		--exclude-pattern=${EXCLUDE_PATTERN} \
		/tmp/kcov ./NetBSD_test.sh
	kcov \
		--include-pattern=${INCLUDE_PATTERN} \
		--exclude-pattern=${EXCLUDE_PATTERN} \
		/tmp/kcov ./Logging_test.sh
	kcov \
		--include-pattern=${INCLUDE_PATTERN} \
		--exclude-pattern=${EXCLUDE_PATTERN} \
		/tmp/kcov ./Command_test.sh
