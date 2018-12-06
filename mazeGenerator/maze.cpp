#include "maze.h"

maze::maze() {
	clear();
	_mazeHeight = 10;
	_mazeLength = 10;
	mazeInitializer();
}

maze::maze(size_t n) {
	clear();
	_mazeHeight = n;
	_mazeLength = n;
	mazeInitializer();
}

maze::maze(size_t height, size_t length) {
	clear();
	_mazeHeight = height;
	_mazeLength = length;
	mazeInitializer();
}

maze::~maze() {
	clear();
}

void maze::clear() {
	_maze.clear();
}

void maze::mazeInitializer() {
	for (size_t i = 0; i < _mazeHeight; i++) {
		vector<char> row;
		for (size_t j = 0; j < _mazeLength; j++) {
			row.push_back('*');
		}
		_maze.push_back(row);
	}
}

void maze::printMaze() {
	if (_maze.empty()) {
		cout << "The maze is empty" << endl;		
	} else {
		for (int i = 0; i < _mazeLength + 2; i++) {
			cout << "*";
		}
		cout << endl;
		for (size_t i = 0; i < _mazeHeight; i++) {
			cout << "*";
			for (size_t j = 0; j < _mazeLength; j++) {
				cout << _maze[i][j]; 
			}
			cout << "*" << endl;
		}
		for (int i = 0; i < _mazeLength + 2; i++) {
			cout << "*";
		}
		cout << endl;
	}
}

void maze::dfs() {
	dfs(0, 0);
}

bool maze::badNeighboor(int x, int y) {
	int vistedNum = 0;
	if (x + 1 < _mazeHeight && _maze[x + 1][y] == '_') {
		vistedNum++;
	}
	if (x - 1 >= 0 && _maze[x - 1][y] == '_') {
		vistedNum++;
	}
	if (y + 1 < _mazeLength && _maze[x][y + 1] == '_') {
		vistedNum++;
	}
	if (y - 1 >= 0 && _maze[x][y - 1] == '_') {
		vistedNum++;
	}
	if (vistedNum > 1) {
		return true;
	}
	return false;
}

void shuffle(vector<int> &v, int n){
    for (int i = 0; i < n; ++i) {
        std::swap(v[i], v[rand() % n]);
    }
}


void maze::dfs(int x, int y) {
	vector<int> direction;
	for (int i = 0; i < 4; ++i) direction.push_back(i);
	if (x < 0 || x >= _mazeHeight || y < 0 || y >= _mazeLength) {
		return;
	}
	if (_maze[x][y] == '_') {
		return;
	}
	if (badNeighboor(x, y)) {
		return;
	}
	_maze[x][y] = '_';
	shuffle(direction, 4);
	for (int i = 0; i < 4; i++) {
		if (direction[i] == 0) {
			dfs(x, y + 1);
		}
		if (direction[i] == 1) {
			dfs(x, y - 1);
		}
		if (direction[i] == 2) {
			dfs(x - 1, y);
		}
		if (direction[i] == 3) {
			dfs(x + 1, y);
		}
	}
}

void reconstructPath(vector< pair<int, int> >& path, pair<int, int> current) {
	path.push_back(current);
	while (_cameFromMap.find(current) != _cameFromMap.end()) {
		current = _cameFromMap[current];
		path.push_back(current);
	}
}

int getFScore(pair<int, int> & start, pair<int, int> & goal) {
	return pow((goal.first - start.first), 2) 
		 + pow((goal.second - start.second), 2);
}

vector< pair<int, int> > getNeighboor(pair<int, int> & point) {
	vector< pair<int, int> > returnVect;
	if (point.first - 1 >= 0 && point.first - 1 < _mazeHeight 
		&& point.second >= 0 && point.second < _mazeLength) {
		returnVect.push_back(make_pair(point.first - 1, point.second));
	}
	if (point.first + 1 >= 0 && point.first + 1 < _mazeHeight 
		&& point.second >= 0 && point.second < _mazeLength) {
		returnVect.push_back(make_pair(point.first + 1, point.second));
	}
	if (point.first >= 0 && point.first < _mazeHeight 
		&& point.second - 1 >= 0 && point.second - 1 < _mazeLength) {
		returnVect.push_back(make_pair(point.first, point.second - 1));
	}
	if (point.first >= 0 && point.first < _mazeHeight 
		&& point.second + 1 >= 0 && point.second + 1 < _mazeLength) {
		returnVect.push_back(make_pair(point.first, point.second + 1));
	}
	return returnVect;
}

void aStar(pair<int, int> start, pair<int, int> goal) {
	priority_queue< pair<int, int>, vector< pair<int, int>>, Compare> toVisitedSet;
	for (size_t i = 0; i < _mazeHeight; i++) {
		for (size_t j = 0; j < _mazeLength; j++) {
			pair<int, int> thru = make_pair(i, j);
			_gScoreMap[thru] = INT_MAX;
			_fScoreMap[thru] = INT_MAX;
		}
	}

	toVisitedSet.push(start);
	_gScoreMap[start] = 0;
	_fScoreMap[start] = getFScore(start, goal);

	while(!toVisitedSet.empty()) {
		pair<int, int> & current = toVisitedSet.top();
		vector< pair<int, int> > neighboors = getNeighboor(current);
		for (size_t i = 0; i < neighboors.size(); i++) {
			if (_visited[neighboors[i]]) {
				continue;
			}
			
		}
	}
}

