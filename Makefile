
DESTDIR=/usr/local
PREFIX=polarssl_

.SILENT:

all:
	cd library  && $(MAKE) all && cd ..
	cd programs && $(MAKE) all && cd ..
	cd tests    && $(MAKE) all && cd ..

no_test:
	cd library  && $(MAKE) all && cd ..
	cd programs && $(MAKE) all && cd ..

lib:
	cd library  && $(MAKE) all && cd ..

install:
	mkdir -p $(DESTDIR)/include/polarssl
	cp -r include/polarssl $(DESTDIR)/include
	
	mkdir -p $(DESTDIR)/lib
	cp library/libpolarssl.* $(DESTDIR)/lib
	
	mkdir -p $(DESTDIR)/bin
	for p in programs/*/* ; do              \
	    if [ -x $$p ] && [ ! -d $$p ] ;     \
	    then                                \
	        f=$(PREFIX)`basename $$p` ;     \
	        cp $$p $(DESTDIR)/bin/$$f ;     \
	    fi                                  \
	done

uninstall:
	rm -rf $(DESTDIR)/include/polarssl
	rm -f $(DESTDIR)/lib/libpolarssl.*
	
	for p in programs/*/* ; do              \
	    if [ -x $$p ] && [ ! -d $$p ] ;     \
	    then                                \
	        f=$(PREFIX)`basename $$p` ;     \
	        rm -f $(DESTDIR)/bin/$$f ;      \
	    fi                                  \
	done

clean:
	cd library  && $(MAKE) clean && cd ..
	cd programs && $(MAKE) clean && cd ..
	cd tests    && $(MAKE) clean && cd ..
	find . \( -name \*.gcno -o -name \*.gcda -o -name *.info \) -exec rm {} +

check: lib
	( cd tests && $(MAKE) && $(MAKE) check )

test-ref-configs:
	tests/scripts/test-ref-configs.pl

testcov:
	make check
	programs/test/selftest
	( cd tests && ./compat.sh )
	( cd tests && ./ssl-opt.sh )

lcov:
	rm -rf Coverage
	( cd library && lcov --capture --directory . -o polarssl.info )
	( cd library && genhtml --title PolarSSL --legend --no-branch-coverage \
	    -o ../Coverage polarssl.info )

apidoc:
	mkdir -p apidoc
	doxygen doxygen/polarssl.doxyfile

apidoc_clean:
	if [ -d apidoc ] ;			\
	then				    	\
		rm -rf apidoc ;			\
	fi
