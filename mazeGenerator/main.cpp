#include "maze.h"

int main() {
	maze test(20, 20);
	srand(time(0));
    test.dfs();
    test.printMaze();
	return 0;
}