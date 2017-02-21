#include "rational.hpp"

class Partition
{
	private:
	int size;
	int number_of_blocks;
	int * home_block; // home_block[i]==j iff i belongs to the jth block.  By convention, the blocks will be ordered by their least element.

	public:
	Partition(int N, int * assignments); // Constructor.
	Partition(int N, Rational * assignments); // Alternate constructor.
	Partition(); // Default constructor.
	// Operators.
	const Partition operator*(const Partition & Q) const; // P*Q returns the mutual refinement of P and Q.
	bool operator==(const Partition & Q) const;
	bool operator!=(const Partition & Q) const;
	bool operator<(Partition Q) const;
	bool operator>(Partition Q) const;
	bool operator<=(Partition Q) const;
	bool operator>=(Partition Q) const;
	// Miscellaneous methods.
	void display(std::ofstream *) const; // This just prints the partition.  This will likely be deleted.
	// Methods for accessing variables.
	int get_size() const;
	int get_number_of_blocks() const;
	int get_block(int i) const;
	int get_block_size(int i) const;
	int * get_elts_of_block(int block_num) const;
	bool are_related(int i, int j) const;
};
