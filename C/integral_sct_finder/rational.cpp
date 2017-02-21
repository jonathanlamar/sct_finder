#include <iostream>
#include "rational.hpp"

using namespace std;

long long numerator;
long long denominator;
void Rational::reduce()
{
	long long int a, b, r;
	a = numerator;
	b = denominator;
	while (b != 0)
	{
		r = a % b;
		a = b;
		b = r;
	}
	numerator /= a;
	denominator /= a;
}

Rational::Rational(long long num, long long denom) // Constructor.
{
	// Reduce num and denom.
	numerator = num;
	denominator = denom;
	reduce(); // Maybe shouldn't reduce too much...
}

Rational::Rational() // Constructor.
{
	// Reduce num and denom.
	numerator = 0;
	denominator = 1;
}

bool Rational::is_integer() const
{
	return ( (numerator % denominator) == 0 );
}

// This will be removed eventually.
void Rational::display()
{
	cout << numerator << "/" << denominator;
}

void Rational::reset()
{
	numerator = 0;
	denominator = 1;
}

// Methods for grabbing private attributes.
long long Rational::get_numerator() const
{
	return numerator;
}

long long Rational::get_denominator() const
{
	return denominator;
}

// Operations with other Rationals.
const Rational Rational::operator+=(const Rational S)
{
	long int c, d;
	c = S.get_numerator();
	d = S.get_denominator();
	numerator = (numerator*d + denominator*c);
	denominator *= d;
	reduce();
	return *this;
}

const Rational Rational::operator-=(const Rational S)
{
	long int c, d;
	c = S.get_numerator();
	d = S.get_denominator();
	numerator = (numerator*d - denominator*c);
	denominator *= d;
	reduce();
	return *this;
}

const Rational Rational::operator*=(const Rational S)
{
	numerator *= S.get_numerator();
	denominator *= S.get_denominator();
	reduce();
	return *this;
}

const Rational Rational::operator/=(const Rational S)
{
	numerator *= S.get_denominator();
	denominator *= S.get_numerator();
	reduce();
	return *this;
}

bool Rational::operator==(const Rational S) const
{
	return ( (this->get_numerator() == S.get_numerator()) && (this->get_denominator() == S.get_denominator()) );
}

const Rational Rational::operator+(const Rational S) const
{
	Rational result = *this;
	result += S;
	return result;
}

const Rational Rational::operator-(const Rational S) const
{
	Rational result = *this;
	result -= S;
	return result;
}

const Rational Rational::operator*(const Rational S) const
{
	Rational result = *this;
	result *= S;
	return result;
}

const Rational Rational::operator*(const int S) const
{
	return Rational(this->get_numerator()*S, this->get_denominator());
}

const Rational Rational::operator/(const Rational S) const
{
	Rational result = *this;
	result /= S;
	return result;
}

bool Rational::operator!=(const Rational S) const
{
	return !(*this == S);
}

long double Rational::to_double() const
{
	return (long double)numerator / (long double)denominator;
}
