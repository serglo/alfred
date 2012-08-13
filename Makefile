dist: download-libs
	@echo Done

download-libs:
	rm -rf public/js/libs
	mkdir -p public/js/libs

	@echo Downloading backbone from backbonejs.org
	wget http://backbonejs.org/backbone.js
	mv backbone.js public/js/libs/backbone.js

	@echo Downloading jquery from jquery.com
	wget http://code.jquery.com/jquery-latest.js
	mv jquery-latest.js public/js/libs/jquery.js

	@echo Downloading underscore from underscore.org
	wget http://underscorejs.org/underscore.js
	mv underscore.js public/js/libs/underscore.js

	@echo Downloading viewporter
	wget https://raw.github.com/zynga/viewporter/master/src/viewporter.js
	mv viewporter.js public/js/libs/viewporter.js

	@echo Downloading json2
	wget https://raw.github.com/douglascrockford/JSON-js/master/json2.js
	mv json2.js public/js/libs/json2.js

	@echo Downloading spin.js
	wget http://fgnass.github.com/spin.js/dist/spin.js
	mv spin.js public/js/libs/spin.js

	@echo Downloading spin.js
	wget http://jscrollpane.kelvinluck.com/script/jquery.jscrollpane.js
	mv jquery.jscrollpane.js public/js/libs/jquery.jscrollpane.js

	@echo Downloading spin.js
	wget http://jscrollpane.kelvinluck.com/script/jquery.mousewheel.js
	mv jquery.mousewheel.js public/js/libs/jquery.mousewheel.js

	@echo Initialize App structure
	mkdir -p public/js/app/views
	mkdir -p public/js/app/models
	mkdir -p public/js/app/collections
	touch public/js/app/app.coffee

	grunt

.PHONY: dist download-libs
