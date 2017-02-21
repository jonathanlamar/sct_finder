#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <vector>
#include <bitset>
#include <time.h>

#include "partition.hpp"

using namespace std;



/*
	These variables are global both for ease of use, and because recomputing them slows the program down. 
*/
int NUMBER_IRREPS;					// This will be the size of the character table.
int * CHARACTER_TABLE;				// This will be an array representing the character table itself.
Rational * CT_INVERSE;				// This will be an array of rationals representing the inverse of the character table.
vector<Partition> PREVIOUS_SUPP;	// This is a stack of all supports (see build_sct()).
vector<vector<int> > SUBSETS;		// This is a stack of vectors which represent subsets of Irr(G).
vector<Partition> SCT_LIST;			// This is a stack of partitions which represents the list of supercharacter theories.
bool * USED_CHARS;					// Array of bools to quickly determine if a character lies in an element of SUBSETS.
int LEVEL = 0;						// FOR DEBUGGING.
ofstream OUTPUT("sct_finder.out");	// Output file for debugging.



Rational * change_basis(int *);									// Matrix multiplication by CT_inverse.
int * wedderburn_sum(vector<int> *);							// Return the Wedderburn sum of a subset of Irr(G).
Partition * support_of_product(vector<int> *, vector<int> *);	// See the explanation in the function body.
void build_sct();												// This is the main algorithm.  See comments in the function body.



int main()
{
	clock_t t;
	t = clock();
	string group_name;		// Storing the group name.
	string line;			// Used for grabbing input.
	string ratio;			// Placeholder for grabbing rationals.
	int i, j, m;			// Looping variables.
	int k, l;				// Substring index placeholders.
	vector<int> trivial;	// The first entry of SUBSETS.
	Partition P;			// Placeholder partition for file output.
	Partition Q;			// Placeholder partition for initializing PREVIOUS_SUPP.
	int * entries;			// Placeholder array for building Q.
	int * the_block;		// Placeholder array for file output

	ifstream file_in(".sct_finder_sage_output.txt");	// This file contains the group tag, size of Irr(G), and the character 
														// table and its inverse.
	if ( ! file_in.is_open() )
	{
		OUTPUT << "Unable to open file.\n";
		return 0;
	}

	OUTPUT << "Initializing global variables... ";
	getline(file_in, group_name);
	getline(file_in, line);
	NUMBER_IRREPS = stoi(line);
	CHARACTER_TABLE = new int[NUMBER_IRREPS*NUMBER_IRREPS];
	CT_INVERSE = new Rational[NUMBER_IRREPS*NUMBER_IRREPS];
	USED_CHARS = new bool[NUMBER_IRREPS];

	// Initialize global variables.
	for (i = 0; i < NUMBER_IRREPS; i++)
		USED_CHARS[i] = false; // TODO: Is this a problem?
	OUTPUT << "done.\n";

	OUTPUT << "Getting character table...\n";
	// Get CHARACTER_TABLE from file.
	for (i = 0; i < NUMBER_IRREPS; i++)
	{
		j = 0; // i represents the row, j represents the column.
		getline(file_in, line);
		line = line.substr(1,line.length()-2);
		l = -1;
		for (k = 0; k < line.length(); k++)
		{
			if (line[k] == ',')
			{
				CHARACTER_TABLE[NUMBER_IRREPS*i+j] = stoi(line.substr(l+1, k-l));
				OUTPUT << to_string(CHARACTER_TABLE[NUMBER_IRREPS*i+j]) << " ";
				l = k;
				j++;
			}
		}
		CHARACTER_TABLE[NUMBER_IRREPS*i+j] = stoi(line.substr(l+1,line.length()-l));
		OUTPUT << to_string(CHARACTER_TABLE[NUMBER_IRREPS*i+j]) << "\n";
	}
	OUTPUT << "done.\n";

	OUTPUT << "Getting character table inverse...\n";
	// Get CT_INVERSE from file.
	for (i = 0; i < NUMBER_IRREPS; i++)
	{
		j = 0; // i represents the row, j represents the column.
		getline(file_in, line);
		line = line.substr(1,line.length()-2);
		l = -1;
		for (k = 0; k < line.length(); k++)
		{
			if (line[k] == ',')
			{
				ratio = line.substr(l+1, k-l);
				if (ratio.find("/") == string::npos) // If no division sign, take whole strong as numerator.
				{
					CT_INVERSE[NUMBER_IRREPS*i+j] = Rational(stoi(ratio), 1);
					OUTPUT << to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_numerator()) << "/" << \
					to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_denominator()) << " ";
				}
				else
				{
					for (m = 0; m < ratio.length(); m++)
					{
						if (ratio[m] == '/')
						{
							CT_INVERSE[NUMBER_IRREPS*i+j] = \
							Rational(stoi(ratio.substr(0,m)),stoi(ratio.substr(m+1,ratio.length()-m)));
							OUTPUT << to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_numerator()) << "/" << \
							to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_denominator()) << " ";
							break;
						}
					}
				}
				l = k;
				j++;
			}
		}
		ratio = line.substr(l+1,line.length()-l);
		if (ratio.find("/") == string::npos)
		{
			CT_INVERSE[NUMBER_IRREPS*i+j] = Rational(stoi(ratio),1);
			OUTPUT << to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_numerator()) << "/" << \
			to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_denominator()) << "\n";
		}
		else
		{
			for (m = 0; m < ratio.length(); m++)
			{
				if (ratio[m] == '/')
				{
					CT_INVERSE[NUMBER_IRREPS*i+j] = \
					Rational(stoi(ratio.substr(0,m)),stoi(ratio.substr(m+1,ratio.length()-m)));
					OUTPUT << to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_numerator()) << "/" << \
					to_string(CT_INVERSE[NUMBER_IRREPS*i+j].get_denominator()) << "\n";
				}
			}
		}
	}
	OUTPUT << "done.\n";
	file_in.close();

	// Build the first entry of PREVIOUS_SUPP.
	OUTPUT << "Building first entry of PREVIOUS_SUPP...";
	entries = new int[NUMBER_IRREPS];
	entries[0] = 0;
	for (i = 1; i < NUMBER_IRREPS; i++)
		entries[i] = 1;;
	Q = Partition(NUMBER_IRREPS, entries);
	PREVIOUS_SUPP.push_back(Q);
	OUTPUT << "done.\n";
	OUTPUT << "The first entry is ";
	Q.display(&OUTPUT);

	// Build the first entry of SUBSETS.
	OUTPUT << "Building the first element of SUBSETS...";
	trivial.push_back(0);
	SUBSETS.push_back(trivial);
	USED_CHARS[0] = true; // Every time we push a subset, we set the relevant elements of USED_CHARS to true.
	OUTPUT << "done.\n";
	OUTPUT << "The first entry is ";
	for (i = 0; i < trivial.size(); i++)
		OUTPUT << to_string(trivial.at(i)) << " ";
	OUTPUT << "\n";

	// And away we go.
	OUTPUT << "Entering build_sct() for the first time...\n";
	build_sct();
	OUTPUT << "Successfully exited build_sct() for the final time.\n";

	// Output the results to a python-readable file.
	OUTPUT << "Printing the list of SCTs:\n";
	ofstream file_out(group_name+"_sct_list.txt");
	file_out << "[";
	while ( ! SCT_LIST.empty() )
	{
		P = SCT_LIST.back();
		P.display(&OUTPUT);
		file_out << "[";
		for (i = 0; i < P.get_number_of_blocks(); i++)
		{
			the_block = P.get_elts_of_block(i);
			file_out << "[";
			for (j = 0; j < P.get_block_size(i); j++)
			{
				file_out << to_string(the_block[j]);
				if ( j < (P.get_block_size(i) - 1) )
					file_out << ", ";
			}
			file_out << "]";
			if (i < (P.get_number_of_blocks() - 1))
				file_out << ", ";
		}
		file_out << "]";
		SCT_LIST.pop_back();
		if ( ! SCT_LIST.empty() )
			file_out << ", ";
	}
	file_out << "]";

	file_out.close();
	t = clock() - t;
	OUTPUT << "Running time: " << t << " clicks, which is " << ((float)t)/CLOCKS_PER_SEC << "seconds.\n";
	return 0;
}



void build_sct()
{
	/*
		This method is the main algorithm.  It builds supercharacter theories supercharacter-by-supercharacter by recursively
		applying the following algorithm.  At a given step, we have a partial partition (collection of pairwise disjoint subsets)
		of Irr(G), which is represented by the variable SUBSETS.  At the same time, we have a partition of Irr(G) called the
		previous support, which is represented by the back element of PREVIOUS_SUPP.  This partition is compatible with SUBSETS
		in the sense that each element of SUBSETS is contained in a part of the previous support.  Now, we let chi be the
		minimally-indexed element of Irr(G) which is not contained in any of the subsets, and we let B_chi be the block of the
		previous support containing chi.  For each subset A of B_chi containing chi (here represented by the_subset), we take the 
		mutual refinement of the previous support with support_of_product(A,B), for each B in SUBSETS.  Call the resulting 
		partition the current support.  If any element of SUBSETS (including A) is not contained in a part of current support, 
		then it is discarded and we move on to the next choice of A.  Otherwise, if the SUBSETS (including A) cover Irr(G), then 
		we have a supercharacter theory.  Add it to the list and return.  If the SUBSETS do not cover Irr(G), then we call the 
		algorithm again on current support (which is pushed on the stack PREVIOUS_SUPPORT) and on the current list of subsets (we 
		push A onto SUBSETS).
	*/
	int new_char;												// Minimally indexed character not in old_chars.
	int block_of_new_char;										// The block of PREVIOUS_SUPP.back() containing new_char.
	vector<int> fresh_chars;									// The set difference of block_of_new_char and old_chars.
	bool partial_partition_is_good;
	Partition current_supp;										// Build a new filtration to push onto PREVIOUS_SUPP.
	unsigned long long num_subsets_of_fresh_chars;				// Number of subsets of fresh_chars.
	bitset<sizeof(unsigned long long) * CHAR_BIT> * bit_subset;	// Bitset to identify subsets of fresh_chars.
	vector<int> * the_subset;									// This will be a vector constructed from bit_subset.
	int i, j;													// Loop variables.
	unsigned long long k;										// Another (bigger) loop variable.
	int m,n;													// Loop variables (for replacing the above iterators).

	LEVEL++;
	// Find new_char.
	for (i = 0; i < NUMBER_IRREPS; i++)
	{
		if ( ! USED_CHARS[i] )
		{
			new_char = i;
			break;
		}
	}
	USED_CHARS[new_char] = true;

	// Get block_of_new_char.
	block_of_new_char = PREVIOUS_SUPP.back().get_block(new_char);

	// Get the set of fresh_chars.
	for (i = 0; i < NUMBER_IRREPS; i++)
	{
		if ( ( PREVIOUS_SUPP.back().are_related(new_char,i) ) && ( ! USED_CHARS[i] ) )
			fresh_chars.push_back(i);
	}

	// Loop over subsets of fresh_chars.
	num_subsets_of_fresh_chars = pow(2, fresh_chars.size());
	for (k = 0; k < num_subsets_of_fresh_chars; k++)
	{
		OUTPUT << "In build_sct() at level " << LEVEL << " with k = " << k << ".\n";
		// Build the subset of fresh_chars represented by k.
		bit_subset = new bitset<sizeof(unsigned long long) * CHAR_BIT> (k); // Get binary string representing subset.
		the_subset = new vector<int>;
		for (i = 0; i < (sizeof(unsigned long long)*CHAR_BIT); i++)
		{
			if ( bit_subset->operator[](i) )
				the_subset->push_back(fresh_chars.at(i));
		}
		the_subset->push_back(new_char);

		OUTPUT << "Current subset being tested: ";
		for (i = 0; i < the_subset->size(); i++)
			OUTPUT << the_subset->at(i) << " ";
		OUTPUT << "\n";

		// Build current_supp;
		partial_partition_is_good = true;
		current_supp = PREVIOUS_SUPP.back();
		OUTPUT << "Displaying current support before refinement: ";
		current_supp.display(&OUTPUT);
		SUBSETS.push_back(*the_subset);
		for (m = 0; m < the_subset->size(); m++)
			USED_CHARS[the_subset->at(m)] = true; // Capture these characters.
		for (m = 0; m < SUBSETS.size(); m++)
			current_supp = current_supp * ( *(support_of_product(the_subset,&(SUBSETS[m]))) ); // TODO: Test this in isolation.
		OUTPUT << "Displaying current support after refinement: ";
		current_supp.display(&OUTPUT);

		// Check that each new set is supported in the new partition.
		for (m = 0; m < SUBSETS.size(); m++)
		{
			for (n = 0; n < SUBSETS[m].size(); n++)
			{
				// Escape if two elements of the set lie in different blocks.
				if ( current_supp.get_block( SUBSETS[m].at(n) ) != current_supp.get_block( SUBSETS[m].at(0) ) )
				{
					partial_partition_is_good = false;
					break;
				}
			}
		}
		// I think this works just as well.
		if ( partial_partition_is_good )
		{
			OUTPUT << "Partial partition is good.\n";
			// Store the number of unused characters in i.
			i = 0;
			for (j = 0; j < NUMBER_IRREPS; j++)
			{
				if ( ! USED_CHARS[j] )
					i++;
			}

			// If i == 0, then we have a supercharacter theory; otherwise we go one step deeper.
			if ( i == 0 )
			{
				OUTPUT << "We have a supercharacter theory.\n";
				SCT_LIST.push_back(current_supp);
			}
			else
			{
				OUTPUT << "We need to keep going.\n";
				PREVIOUS_SUPP.push_back(current_supp);
				build_sct();
				PREVIOUS_SUPP.pop_back();
			}
		}
		if ( ! partial_partition_is_good )
			OUTPUT << "Partial partition is bad.\n";
		OUTPUT << "Popping the following subset from SUBSETS: ";
		for (m = 0; m < the_subset->size(); m++)
		{
			USED_CHARS[the_subset->at(m)] = false; // Release these characters.
			OUTPUT << the_subset->at(m) << " ";
		}
		OUTPUT << "\n";
		SUBSETS.pop_back();
		delete bit_subset;
		delete the_subset;
	}
	LEVEL--;
}

Rational * change_basis(int * X)
{
	/*
		X here represents a vector in the conjugacy class identifier basis.  This function returns X represented in the basis
		consisting of chi/chi(1) for chi in Irr(G).
	*/
	Rational * XS;	// The output.
	int i, j;		// Loop variables.

	// Initialize XS.
	XS = new Rational[NUMBER_IRREPS];
	for (i = 0; i < NUMBER_IRREPS; i++)
		(XS+i)->reset();

	for (i = 0; i < NUMBER_IRREPS; i++)
	{
		for (j = 0; j < NUMBER_IRREPS; j++)
			XS[j] += ( CT_INVERSE[NUMBER_IRREPS*i + j]*X[i] );
	}
	for (i = 0; i < NUMBER_IRREPS; i++)
		XS[i] *= Rational(1, CHARACTER_TABLE[NUMBER_IRREPS*i]);
	return XS;
}

int * wedderburn_sum(vector<int> * X)
{
	/*
		Given a subset X of Irr(G) (represented as a list of numbers), this method returns \sum_{\chi\in X}\chi(1)\chi,
		represented as a row vector.
	*/
	int * w_X;					// This will be the Wedderburn sum of X.
	int j;						// Loop variable.
	int m;						// Loop variable (for replacing it).

	w_X = new int[NUMBER_IRREPS];
	for (j = 0; j < NUMBER_IRREPS; j++)
		w_X[j] = 0;

	for (j = 0; j < NUMBER_IRREPS; j++)
	{
		// Add chi(1)*chi for each chi in X.
		for (m = 0; m < X->size(); m++)
			w_X[j] += ( CHARACTER_TABLE[NUMBER_IRREPS*(X->at(m))] * CHARACTER_TABLE[NUMBER_IRREPS*(X->at(m)) + j] );
	}

	return w_X;
}

Partition * support_of_product(vector<int> * X, vector<int> * Y)
{
	/* 
		Given subsets X,Y of Irr(G), this method returns the unique coarsest partition of Irr(G) such that the elementwise product
		of the Wedderburn sums of X and Y is contained in the span of the Wedderburn sums of the parts of this partition.
	*/
	Partition * support;					// The eventual output.
	int * w_X = wedderburn_sum(X);
	int * w_Y = wedderburn_sum(Y);
	int i;

	OUTPUT << "In SOP, displaying sets: X = ";
	for (i = 0; i < X->size(); i++)
		OUTPUT << X->at(i) << " ";
	OUTPUT << "Y = ";
	for (i = 0; i < Y->size(); i++)
		OUTPUT << Y->at(i) << " ";
	OUTPUT << "\n";
	OUTPUT << "In SOP, displaying Wedderburn sums.\n";
	OUTPUT << "w_X: ";
	for (i = 0; i < NUMBER_IRREPS; i++)
		OUTPUT << w_X[i] << " ";
	OUTPUT << "\n";
	OUTPUT << "w_Y: ";
	for (i = 0; i < NUMBER_IRREPS; i++)
		OUTPUT << w_Y[i] << " ";
	OUTPUT << "\n";

	// Take elementwise product of w_X and w_Y.
	for (i = 0; i < NUMBER_IRREPS; i++)
		w_X[i] *= w_Y[i];
	OUTPUT << "In SOP, displaying product of Wedderburn sums: ";
	for (i = 0; i < NUMBER_IRREPS; i++)
		OUTPUT << w_X[i] << " ";
	OUTPUT << "\n";

	Rational * R = change_basis(w_X);
	OUTPUT << "In SOP, displaying base change of product: ";
	for (i = 0; i < NUMBER_IRREPS; i++)
		OUTPUT << to_string((R+i)->get_numerator()) << "/" << to_string((R+i)->get_denominator()) << "  ";
	OUTPUT << "\n";

	// Convert to character/character_degree basis.
	support = new Partition;
	*support = Partition(NUMBER_IRREPS, change_basis(w_X));
	OUTPUT << "In SOP, displaying support: ";
	support->display(&OUTPUT);
	return support;
}
