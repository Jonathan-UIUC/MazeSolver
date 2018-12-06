#include <vector>
#include <iostream>
#include <random>
#include <ctime>
#include <climits>
#include <map>
#include <cmath>
#include <queue>
#include <cstdlib>

using std::vector;
using std::pair;
using std::cout;
using std::map;
using std::endl;
using std::time;
using std::pair;
using std::make_pair;
using std::priority_queue;
using std::pow;

class maze {
public:
	maze();
	~maze();
	maze(size_t n);
	maze(size_t height, size_t length);
	void dfs();
	void printMaze();
	void reconstructPath(vector<pair<int, int> & path>, pair<int, int> current);
	void solutionPrintMaze();

private:
	size_t _mazeHeight;
	size_t _mazeLength;
	vector< vector<char> > _maze;
	map< pair<int, int>, pair<int, int> > _cameFromMap;
	map< pair<int, int>, bool > _visited;
	map< pair<int, int>, int > _gScoreMap;
	map< pair<int, int>, int > _fScoreMap;

	void mazeInitializer();
	void clear();
	void dfs(int x, int y);
	void aStar();
	bool badNeighboor(int x, int y);
	int getFScore(pair<int, int> & start, pair<int, int> & goal);
	vector< pair<int, int> > getNeighboor(pair<int, int> & point);
	class Compare
	{
	public:
	    bool operator() (pair<int, int> & first, pair<int, int> & second) {
	        if (_fScoreMap[first] < _fScoreMap[second]) {
	        	return true;
	        }
	        return false;
	    }
	};

};

