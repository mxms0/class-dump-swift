all:
	clang main.mm -std=c++11 `llvm-config --libs` `llvm-config --cxxflags` `llvm-config --ldflags` -lstdc++ -lncurses -o swiftd


clean:
	rm -rf swiftd swiftd.dSYM
