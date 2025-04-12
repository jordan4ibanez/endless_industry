default:
	@dub run

fast:
	@dub run --build=release

debug:
	DFLAGS="-g -gc -d-debug" dub build  && gdb -q -ex run ./endless_industry

install:
	dub upgrade
	dub run raylib-d:install

test:
	dub -b unittest

clean:
	dub clean