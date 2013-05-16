# A makefile to create a RPM package containing the uthash headers.

VERSION := 1.9.8

# set rpmbuild related variables
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
  RPMBUILD_BASE_PREFIX := "/tmp/rpm_bb_"
  ifeq ($(origin RPMBUILD_BASE), undefined)
    export ORIGIN := $(abspath $(shell pwd))
    export RPMBUILD_BASE := $(abspath $(shell mktemp -d $(RPMBUILD_BASE_PREFIX)XXXX))
    export RPMBUILD_DIRS := $(addprefix $(RPMBUILD_BASE)/,SOURCES SPECS BUILD RPMS SRPMS)
  endif
endif

# define rpm spec file
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
  define SPEC_FILE
%global _enable_debug_package 0
%global debug_package %{nil}
%global __os_install_post /usr/lib/rpm/brp-compress %{nil}

Name:           uthash
Version:        $(VERSION)
Release:        1%{?dist}
Summary:        C macros for hash tables and more.
License:        BSD revised
Packager:       Tobias Schlager <schlagert@github.com>
Source:         uthash-$(VERSION).tar.gz
Url:            http://troydhanson.github.com/uthash/

%description
C macros for hash tables and more written by Troy D. Hanson. For more
information, documentation and examples visit
http://troydhanson.github.com/uthash/.

%prep
%setup -q

%build
cd tests
make

%install
install -d %{buildroot}/%{_includedir}
install src/*.h %{buildroot}/%{_includedir}

%files
%{_includedir}/*
  endef
endif

export SPEC_FILE
export CLONE := /tmp/uthash

.PHONY: default

default:
ifneq ($(strip $(shell $(CC) -v 2>&1 | grep "linux")),)
 ifneq ($(strip $(shell rpmbuild -? 2>&1 | grep "Build options")),)
	mkdir -p $(RPMBUILD_DIRS)
	$(MAKE) rpm
	$(MAKE) clean
 else
	echo "Cannot build RPM without 'rpmbuild' tool."
 endif
else
	@echo "Cannot build RPM on non-linux systems."
endif

.PHONY: rpm

rpm: uthash-$(VERSION).tar.gz uthash.spec
	mv uthash-$(VERSION).tar.gz $(RPMBUILD_BASE)/SOURCES/
	mv uthash.spec $(RPMBUILD_BASE)/SPECS/
	rpmbuild --define "_topdir $(RPMBUILD_BASE)" -bb $(RPMBUILD_BASE)/SPECS/uthash.spec
	find $(RPMBUILD_BASE)/RPMS -name *.rpm -exec mv '{}' $(ORIGIN)/ ';'

uthash-$(VERSION).tar.gz:
	-rm -rf $(CLONE)
	git clone https://github.com/troydhanson/uthash.git $(CLONE)
	cd $(CLONE) ; git checkout v$(VERSION)
	mkdir -p uthash-$(VERSION)
	cp -r $(CLONE)/src uthash-$(VERSION)
	cp -r $(CLONE)/tests uthash-$(VERSION)
	tar czf $@ uthash-$(VERSION)
	-rm -rf uthash-$(VERSION)
	-rm -rf $(CLONE)

uthash.spec:
	echo "$$SPEC_FILE" > $@

.PHONY: clean

clean:
	-rm -rf $(RPMBUILD_BASE_PREFIX)*
	-rm -rf uthash-$(VERSION)
	-rm -rf $(CLONE)
	-rm -f *.spec
	-rm -f *.tar.gz

.PHONY: distclean

distclean: clean
	-rm -f *.rpm
