#include <iostream>
#include <string>
#include <fstream>

#include "partition.hpp"

using namespace std;

Partition::Partition(int N, int * assignments) // Constructor.
{
	size = N;
	home_block = new int[N];
	bool * used;
	used = new bool[N];

	// Get the number of blocks by reducing as follows.
	for (int i = 0; i < N; i++)
		used[i] = false;
	number_of_blocks = 0;
	for (int i = 0; i < N; i++)
	{
		if (used[i])
			continue;
		number_of_blocks++;
		for (int j = i+1; j < N; j++)
		{
			if (assignments[j] == assignments[i])
				used[j] = true;
		}
	}

	// Order the blocks.
	for (int i = 0; i < N; i++)
		used[i] = false;
	int current_block = 0;
	for (int i = 0; i < N; i++)
	{
		if (used[i])
			continue;
		home_block[i] = current_block;
		used[i] = true;
		for (int j = 0; j < N; j++)
		{
			if (assignments[i] == assignments[j])
			{
				home_block[j] = current_block;
				used[j] = true;
			}
		}
		current_block++;
	}
}

Partition::Partition(int N, Rational * assignments) // Alternate constructor.
{
	size = N;
	home_block = new int[N];
	bool * used;
	used = new bool[N];

	// Get the number of blocks by reducing as follows.
	for (int i = 0; i < N; i++)
		used[i] = false;
	number_of_blocks = 0;
	for (int i = 0; i < N; i++)
	{
		if (used[i])
			continue;
		number_of_blocks++;
		for (int j = i+1; j < N; j++)
		{
			if ( (*(assignments+j)) == (*(assignments+i)) )
				used[j] = true;
		}
	}

	// Order the blocks.
	for (int i = 0; i < N; i++)
		used[i] = false;
	int current_block = 0;
	for (int i = 0; i < N; i++)
	{
		if (used[i])
			continue;
		home_block[i] = current_block;
		used[i] = true;
		for (int j = 0; j < N; j++)
		{
			if ( (*(assignments+j)) == (*(assignments+i)) )
			{
				home_block[j] = current_block;
				used[j] = true;
			}
		}
		current_block++;
	}
}

Partition::Partition() // Default constructor.
{
	size = 0;
	number_of_blocks = 0;
}

// Operators.
const Partition Partition::operator*(const Partition & Q) const // P*Q returns the mutual refinement of P and Q.
{
	// These shouldn't be necessary.
	if (size < Q.get_size())
		return *this;
	if (size > Q.get_size())
		return Q;

	int entries[size];
	int which_block = 0;
	bool used[size];
	for (int i = 0; i < size; i++)
		used[i] = false;
	for (int i = 0; i < size; i++)
	{
		if (used[i])
			continue;
		for (int j = 0; j < size; j++)
		{
			if ( (this->are_related(i,j)) && (Q.are_related(i,j)) )
			{
				used[j] = true;
				entries[j] = which_block;
			}
		}
		which_block++;
	}
	Partition result(size, entries);
	return result;
}

bool Partition::operator==(const Partition & Q) const
{
	if (size != Q.get_size())
		return false;
	bool same = true;
	int N = size;
	for (int i = 0; i < N; i++)
	{
		if (this->get_block(i) != Q.get_block(i))
			same = false;
	}
	return same;
}

bool Partition::operator!=(const Partition & Q) const
{
	return !(*this==Q);
}

bool Partition::operator<(Partition Q) const
{
	if (size != Q.get_size())
		return false;
	for (int i = 0; i < size; i++)
	{
		for (int j = 0; j < i; j++)
		{
			if ( (this->are_related(i,j)) && !(Q.are_related(i,j)) )
				return false;
		}
	}
	if (*this == Q)
		return false;
	return true;
}

bool Partition::operator>(Partition Q) const
{
	return ( Q < *this);
}

bool Partition::operator<=(Partition Q) const
{
	return ( (*this < Q) || (*this == Q) );
}

bool Partition::operator>=(Partition Q) const
{
	return (Q <= *this);
}

// Miscellaneous methods.
void Partition::display(std::ofstream * output) const // This just prints the partition.  This will likely be deleted.
{
	*output << "{";
	for (int j = 0; j < number_of_blocks; j++)
	{
		*output << "{";
		for (int k = 0; k < size; k++)
		{
			if (home_block[k] == j)
				*output << k << ",";
		}
		*output << "}";
	}
	*output << "}\n";
}

// Methods for accessing variables.
int Partition::get_size() const
{
	return size;
}

int Partition::get_number_of_blocks() const
{
	return number_of_blocks;
}

int Partition::get_block(int i) const
{
	return home_block[i];
}

int Partition::get_block_size(int i) const
{
	int block_size = 0;
	int j;

	for (j = 0; j < size; j++)
	{
		if (home_block[j] == i)
			block_size++;
	}
	return block_size;
}

int * Partition::get_elts_of_block(int block_num) const
{
	int i, j;
	int * the_block;
	j = 0;
	for (i = 0; i < size; i++)
	{
		if (home_block[i] == block_num)
			j++;
	}
	the_block = new int[j];
	j = 0;
	for (i = 0; i < size; i++)
	{
		if (home_block[i] == block_num)
		{
			the_block[j] = i;
			j++;
		}
	}
	return the_block;
}

bool Partition::are_related(int i, int j) const
{
	return (home_block[i] == home_block[j]);
}
