
maze: main.o maze.o
	clang++ maze.o main.o -o maze

maze.o: maze.cpp
	clang++ -c maze.cpp

main.o: main.cpp
	clang++ -c main.cpp

clean:
	rm *.o maze