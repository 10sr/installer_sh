src := installer.sh
sha256sum := $(shell which sha256sum 2>/dev/null)

ifeq (,$(sha256sum))
$(warning sha256sum not found)
endif

test: checksum

checksum: $(src)
	calced=`sed -ne '/INSTALLER_SH INTERNALS/,$$p' $(src) | $(sha256sum) | cut -f 1 -d ' '` && \
		written=`grep __sha256sum= $(src) | cut -f 2 -d =` && \
		echo "Caled  " $$calced && echo Written $$written && \
		test $$calced = $$written
