default:
	@dub run

install:
	dub upgrade
	dub run raylib-d:install

clean:
	dub clean