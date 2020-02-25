KCOV=	kcov
KCOV_OPT=	--include-pattern=lib/
KCOV_OPT+=	--exclude-pattern=valid_MACHINE_ARCH
KCOV_OPT+=	--debug-force-bash-stderr
KCOV_OPT+=	/tmp/kcov

UNITTEST=	Command_test.sh
UNITTEST+=	Logging_test.sh
UNITTEST+=	NetBSD_test.sh
UNITTEST+=	Package_test.sh
UNITTEST+=	categorizing_files_into_package_test.sh
UNITTEST+=	obsolete_filter_test.sh

unittest:
.for test in ${UNITTEST}
	/bin/sh ${test}
.endfor

coverage:
.for test in ${UNITTEST}
	${KCOV} ${KCOV_OPT} ${test}
.endfor
