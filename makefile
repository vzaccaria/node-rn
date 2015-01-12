
index.js: index.ls ./docs/usage.md
	echo '#!/usr/bin/env node' > $@
	lsc -p -c $<  >> $@
	chmod +x $@
	./tests/test.sh

clean:
	rm index.js

XYZ = node_modules/.bin/xyz

.PHONY: release-major release-minor release-patch
	
release-major release-minor release-patch:
	@$(XYZ) --increment $(@:release-%=%)
