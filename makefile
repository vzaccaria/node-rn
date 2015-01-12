
index.js: index.ls ./docs/usage.md
	echo '#!/usr/bin/env node' > $@
	lsc -p -c $<  >> $@
	chmod +x $@
	./tests/test.sh

clean:
	rm index.js
