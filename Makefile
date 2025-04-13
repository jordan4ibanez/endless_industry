default:
	@dub run --build=debug

fast:
	@DFLAGS="--O3" dub run --build=release

debug:
	DFLAGS="-g -gc -d-debug" dub build --build=debug && gdb -q -ex run ./endless_industry

install:
	dub upgrade
	dub run raylib-d:install

clean:
	dub clean

test:
	dub -b unittest