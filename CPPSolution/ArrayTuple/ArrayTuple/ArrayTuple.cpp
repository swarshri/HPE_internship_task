#include<iostream>
#include<vector>
#include<tuple>
#include<set>
#include<algorithm>

using namespace std;

int main(int argc, char* argv[])
{
	vector<int> ip_vec = {-12, -11, -8, 0, 4, 5, 8};
	set<int> ip_set(ip_vec.begin(), ip_vec.end());
	ip_vec.assign(ip_set.begin(), ip_set.end());

	vector<tuple<int, int, int>> op_vec;
	
	sort(ip_vec.begin(), ip_vec.end());
	
	int i = 0;
	int last = ip_vec.size() - 2;
	while (ip_vec[i] < 0 && i < last) {
		int j = i + 1;
		int k = ip_vec.size() - 1;

		while (j < k) {
			int sum = ip_vec[i] + ip_vec[j] + ip_vec[k];

			if (sum == 0) {
				op_vec.push_back(tuple<int, int, int>(ip_vec[i], ip_vec[j], ip_vec[k]));
				j++;
				k--;
			}
			else if (sum < 0)
				j++;
			else
				k--;
		}
		i++;
	}
	
	cout << endl << "Number of tuples: " << op_vec.size() << endl;
	for (auto i = op_vec.begin(); i < op_vec.end(); i++) {
		cout << "(" << get<0>(*i) << "," << get<1>(*i) << "," << get<2>(*i) << ")" << endl;
	}
	return 0;
}