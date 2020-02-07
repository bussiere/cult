#all: clean cult.js
all: clean app.js-debug
.PHONY: app.js app.js-debug

app.js:
	~/haxe-4.0.2/run.sh cult-electron.hxml && \
	cp app-classic.html app.* main.* package.json \
	/mnt/d/1/electron-v7.1.10-win32-ia32/resources/app/ 

app.js-debug:
	~/haxe-4.0.2/run.sh -D mydebug cult-electron.hxml && \
	cp app-classic.html app.* main.* package.json \
	/mnt/d/1/electron-v7.1.10-win32-ia32/resources/app/ 

cult.js:
	haxe cult.hxml

clean:
	rm -f cult.js app.js main.js
