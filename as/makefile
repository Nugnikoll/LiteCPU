.PHONY:all clean

all: as

as: as.tab.cc as.yy.cc
	$(CXX) -Wall -lfl $^ -o $@

as.tab.cc: as.y as.h
	bison -o $@ -d $<

as.yy.cc: as.ll as.tab.cc as.h
	flex -o $@ $<

clean:
	-rm -rf *.yy.cc
	-rm -rf *.tab.cc *.tab.hh
	-rm -rf as
