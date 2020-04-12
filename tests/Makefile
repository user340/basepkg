KCOV=	kcov
KCOV_OPT=	--include-pattern=lib/
KCOV_OPT+=	--exclude-pattern=valid_MACHINE_ARCH
KCOV_OPT+=	--debug-force-bash-stderr
KCOV_OPT+=	/tmp/kcov

KCOVTEST=	Command_test.sh
KCOVTEST+=	Logging_test.sh
KCOVTEST+=	NetBSD_test.sh
KCOVTEST+=	Package_test.sh

UNITTEST=	categorizing_files_into_package_test.sh
UNITTEST+=	obsolete_filter_test.sh
UNITTEST+=	${KCOVTEST}

unittest:
.for test in ${UNITTEST}
	/bin/sh ${test}
.endfor

coverage:
.for test in ${KCOVTEST}
	${KCOV} ${KCOV_OPT} ${test}
.endfor
