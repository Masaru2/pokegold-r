PYTHON := python
MD5 := md5sum -c --quiet

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .2bpp .1bpp .lz .pal .bin .blk .tilemap
.PHONY: all clean gold silver pngs compare
.SECONDEXPANSION:

poketools := extras/pokemontools
gfx       := $(PYTHON) $(poketools)/gfx.py
includes  := $(PYTHON) $(poketools)/scan_includes.py

gold_obj := \
gold.o \
home_gold.o
# gold_obj := \
# wram.o \
# main.o \
# lib/mobile/main.o \
# home.o \
# audio.o \
# maps_gold.o \
# engine/events_gold.o \
# engine/credits_gold.o \
# data/egg_moves_gold.o \
# data/evos_attacks_gold.o \
# data/pokedex/entries_gold.o \
# misc/gold_misc.o \
# gfx/pics.o

silver_obj := silver.o

all_obj := $(gold_obj) $(silver_obj)

# object dependencies
$(foreach obj, $(all_obj), \
	$(eval $(obj:.o=)_dep := $(shell $(includes) $(obj:.o=.asm))) \
)


roms := pokegold.gbc pokesilver.gbc

all: $(roms)
gold: pokegold.gbc
silver: pokesilver.gbc

clean:
	rm -f $(roms) $(all_obj) $(roms:.gbc=.map) $(roms:.gbc=.sym)

compare: pokegold.gbc pokesilver.gbc
	@$(MD5) roms.md5

%.asm: ;
$(all_obj): $$*.asm $$($$*_dep)
	rgbasm -o $@ $<

pokegold.gbc: $(gold_obj)
	rgblink -n $*.sym -m $*.map -o $@ $^
	rgbfix -cjsv -i AAUE -k 01 -l 0x33 -m 0x10 -p 0 -r 3 -t "POKEMON_GLD" $@

pokesilver.gbc: $(silver_obj)
	rgblink -n $*.sym -m $*.map -o $@ $^
	rgbfix -cjsv -i AAXE -k 01 -l 0x33 -m 0x10 -p 0 -r 3 -t "POKEMON_SLV" $@

pngs:
	find . -iname "*.lz"      -exec $(gfx) unlz {} +
	find . -iname "*.[12]bpp" -exec $(gfx) png  {} +
	find . -iname "*.[12]bpp" -exec touch {} +
	find . -iname "*.lz"      -exec touch {} +

# %.2bpp: %.png ; @$(gfx) 2bpp $<
# %.1bpp: %.png ; @$(gfx) 1bpp $<
# %.lz:   %     ; @$(gfx) lz $<


# %.pal: ;
# %.bin: ;
# %.blk: ;
# %.tilemap: ;
