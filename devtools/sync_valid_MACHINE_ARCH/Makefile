PYTHON_UNITTEST=	python -m unittest
PYTHON_PATH=		${PWD}/src:${PYTHONPATH}
TESTCODE=			tests.taker

test:
	cd src && PYTHONPATH=${PYTHON_PATH} ${PYTHON_UNITTEST} ${TESTCODE} -v

install:
	python setup.py install
