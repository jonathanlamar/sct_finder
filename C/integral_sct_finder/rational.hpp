class Rational
{
	private:
	long long numerator;
	long long denominator;
	void reduce();
	public:
	Rational(long long num, long long denom); // Constructor.
	Rational(); // Default constructor.
	bool is_integer() const;
	// This will be removed eventually.
	void display();
	void reset();
	// Methods for grabbing private attributes.
	long long get_numerator() const;
	long long get_denominator() const;
	// Operations with other Rationals.
	const Rational operator+=(const Rational S);
	const Rational operator-=(const Rational S);
	const Rational operator*=(const Rational S);
	const Rational operator/=(const Rational S);
	bool operator==(const Rational S) const;
	const Rational operator+(const Rational S) const;
	const Rational operator-(const Rational S) const;
	const Rational operator*(const Rational S) const;
	const Rational operator*(const int S) const;
	const Rational operator/(const Rational S) const;
	bool operator!=(const Rational S) const;
	long double to_double() const;
};
