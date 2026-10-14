.POSIX:
.SILENT: package

DEB_TARGETS = \
	deb/DEBIAN/control \
	deb/usr/bin/rsyncfs \
	deb/usr/share/man/man1/rsyncfs.1 \

package:
	umask 0022 && fakeroot $(MAKE) rsyncfs.deb
	version="$$(grep ^Version: control | cut -d ' ' -f 2)"; \
	mv rsyncfs.deb rsyncfs-$$version-all.deb; \
	echo "Created rsyncfs-$$version-all.deb"

deb/DEBIAN/control: control
	install -m 644 -D $? $@

deb/usr/bin/rsyncfs: rsyncfs
	install -D -m 4755 $? $@

deb/usr/share/man/man1/rsyncfs.1: rsyncfs.1
	mkdir -p $(@D)
	if git diff --quiet; then \
		date="$$( \
			date --date="@$$(git log -1 --format="%ct")" "+%B %Y" \
		)"; \
	else \
		date="$$(date "+%B %Y")"; \
	fi; \
	version="$$(grep ^Version: control | cut -d ' ' -f 2)"; \
	sed -e "s/%DATE%/$$date/" -e "s/%VERSION%/$$version/" $? > $@

rsyncfs.deb: $(DEB_TARGETS)
	dpkg -b deb $@

clean:
	rm -rf deb/ *.deb
