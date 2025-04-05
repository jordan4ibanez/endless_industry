default:
	@dub run

fast:
	@dub run --build=release

install:
	dub upgrade
	dub run raylib-d:install

clean:
	dub clean