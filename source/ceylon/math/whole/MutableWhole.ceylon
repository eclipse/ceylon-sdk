import ceylon.math.integer {
    largest
}

final class MutableWhole
        satisfies Integral<MutableWhole> &
                  Exponentiable<MutableWhole, MutableWhole> {

    variable Integer signValue;

    shared variable Words words;

    shared variable Integer wordsSize;

    shared new OfWords(Integer sign, Words words, Integer size = -1) {
        assert (-1 <= sign <= 1);
        this.wordsSize = realSize(words, size);
        this.words = words;
        this.signValue = if (this.wordsSize == 0) then 0 else sign;
    }

    shared new CopyOfWords(Integer sign, Words words, Integer size = -1) {
        assert (-1 <= sign <= 1);
        this.wordsSize = realSize(words, size);
        this.words = clonew(words);
        this.signValue = if (this.wordsSize == 0) then 0 else sign;
    }

    shared new CopyOfWhole(Whole whole) {
        this.wordsSize = realSize(whole.words, whole.wordsSize);
        this.words = clonew(whole.words);
        this.signValue = whole.sign;
    }

    shared actual MutableWhole plus(MutableWhole other)
        =>  addSigned(this, other, other.sign);

    shared actual MutableWhole minus(MutableWhole other)
        =>  addSigned(this, other, other.sign.negated);

    shared actual MutableWhole plusInteger(Integer integer)
        =>  plus(mutableWholeNumber(integer));

    shared actual MutableWhole times(MutableWhole other)
        =>  if (this.zero || other.zero) then
                mutableZero()
            else if (this.unit) then
                other.copy()
            else if (this.negativeOne) then
                other.negated
            else if (other.unit) then
                this.copy()
            else if (other.negativeOne) then
                this.negated
            else
                OfWords(this.sign * other.sign,
                        multiply(this.wordsSize, this.words,
                                 other.wordsSize, other.words));

    shared actual MutableWhole timesInteger(Integer integer)
        =>  if (zero || integer == 0) then
                mutableZero()
            else if (0 < integer < wordRadix) then
                OfWords(sign, multiplyWord(wordsSize, words, integer))
            else
                times(mutableWholeNumber(integer));

    shared actual MutableWhole divided(MutableWhole other) {
        if (other.zero) {
            throw Exception("Divide by zero");
        }
        return if (zero) then
            mutableZero()
        else if (other.unit) then
            copy()
        else if (other.negativeOne) then
            negated
        else (
            switch (compareMagnitude(
                        this.wordsSize, this.words,
                        other.wordsSize, other.words))
            case (equal)
                (if (sign == other.sign)
                 then mutableOne()
                 else mutableNegativeOne())
            case (smaller)
                mutableZero()
            case (larger)
                (let (quotient = wordsOfSize(this.wordsSize),
                      remainder = divide<Null>
                                        (this.wordsSize, this.words,
                                         other.wordsSize, other.words,
                                         quotient))
                 OfWords(sign * other.sign, quotient)));
    }

    shared actual MutableWhole remainder(MutableWhole other) {
        if (other.zero) {
            throw Exception("Divide by zero");
        }
        return if (zero) then
            mutableZero()
        else if (other.absUnit) then
            mutableZero()
        else (
            switch (compareMagnitude(
                    this.wordsSize, this.words,
                    other.wordsSize, other.words))
            case (equal)
                mutableZero()
            case (smaller)
                copy()
            case (larger)
                (let (remainder = divide<Nothing>
                                        (this.wordsSize, this.words,
                                         other.wordsSize, other.words))
                 OfWords(sign, remainder)));
    }

    shared MutableWhole leftLogicalShift(Integer shift)
        =>  rightArithmeticShift(-shift);

    shared MutableWhole rightArithmeticShift(Integer shift)
        =>  if (shift == 0) then
                copy()
            else if (shift < 0) then
                OfWords(sign, leftShift(wordsSize, words, -shift))
            else
                OfWords(sign, rightShift(negative, wordsSize, words, shift));

    shared actual MutableWhole power(MutableWhole other) => nothing;

    shared actual MutableWhole powerOfInteger(Integer integer) => nothing;

    shared actual MutableWhole neighbour(Integer offset)
        => plusInteger(offset);

    shared actual Integer offset(MutableWhole other) {
        value diff = Whole.CopyOfMutableWhole(this - other);
        if (integerMin <= diff <= integerMax) {
            return diff.integer;
        }
        else {
            throw OverflowException();
        }
    }

    shared Integer integer
        => integerForWords(wordsSize, words, negative);

    shared actual MutableWhole negated
        =>  if (zero) then
                mutableZero()
            else if (unit) then
                mutableNegativeOne()
            else if (negativeOne) then
                mutableOne()
            else
                CopyOfWords(sign.negated, words, wordsSize);

    shared MutableWhole copy() => CopyOfWords(sign, words, wordsSize);

    shared actual MutableWhole wholePart => copy();

    shared actual MutableWhole fractionalPart => mutableZero();

    shared actual Boolean positive => sign == 1;

    shared actual Boolean negative => sign == -1;

    shared actual Boolean zero => sign == 0;

    Boolean absUnit => wordsSize == 1 && getw(words, 0) == 1;

    Boolean negativeOne => negative && absUnit;

    shared actual Boolean unit => positive && absUnit;

    shared Boolean even => wordsSize > 0 && getw(words, 0).and(1) == 0;

    shared actual Integer sign => signValue;

    shared actual Integer hash {
        variable Integer result = 0;
        for (i in 0:wordsSize) {
            result = result * 31 + getw(words, i);
        }
        return sign * result;
    }

    shared actual String string
        =>  Whole.CopyOfMutableWhole(this).string;

    shared actual Comparison compare(MutableWhole other)
        =>  if (sign != other.sign) then
                sign.compare(other.sign)
            else if (zero) then
                equal
            else if (positive) then
                compareMagnitude(this.wordsSize, this.words,
                                 other.wordsSize, other.words)
            else
                compareMagnitude(other.wordsSize, other.words,
                                 this.wordsSize, this.words);

    shared actual Boolean equals(Object that)
        =>  if (is MutableWhole that) then
                (this === that) ||
                (this.sign == that.sign &&
                 wordsEqual(this.wordsSize, this.words,
                            that.wordsSize, that.words))
            else
                false;

    shared void inplaceLeftLogicalShift(Integer shift) {
        inplaceRightArithmeticShift(-shift);
    }

    shared void inplaceRightArithmeticShift(Integer shift) {
        if (shift < 0) {
            words = leftShiftInplace(wordsSize, words, -shift);
            wordsSize = realSize(words, -1);
        } else if (shift > 0) {
            words = rightShiftInplace(
                        negative, wordsSize, words, shift);
            wordsSize = realSize(words, wordsSize);
        }
    }

    shared void inplaceAdd(MutableWhole other) {
        inplaceAddSigned(other, other.sign);
    }

    shared void inplaceSubtract(MutableWhole other) {
        inplaceAddSigned(other, other.sign.negated);
    }

    shared Integer trailingZeroWords {
        for (i in 0:wordsSize) {
            if (getw(words, i) != 0) {
                return i;
            }
        } else {
            assert(wordsSize == 0);
            return 0;
        }
    }

    shared Integer trailingZeros
        =>  if (this.zero)
            then 0
            else (let (zeroWords = trailingZeroWords,
                       word = getw(words, zeroWords))
                  zeroWords * wordBits + numberOfTrailingZeros(word));

    MutableWhole addSigned(MutableWhole first,
                           MutableWhole second,
                           Integer secondSign)
        =>  if (first.zero) then
                (if (secondSign == second.sign)
                 then second.copy()
                 else second.negated)
            else if (second.zero) then
                first.copy()
            else if (first.sign == secondSign) then
                OfWords(first.sign,
                        add(first.wordsSize, first.words,
                            second.wordsSize, second.words))
            else
                (switch (compareMagnitude(
                                first.wordsSize, first.words,
                                second.wordsSize, second.words))
                 case (equal)
                    mutableZero()
                 case (larger)
                    OfWords(first.sign,
                            subtract(first.wordsSize, first.words,
                                     second.wordsSize, second.words))
                 case (smaller)
                    OfWords(secondSign,
                            subtract(second.wordsSize, second.words,
                                     first.wordsSize, first.words)));

    void inplaceAddSigned(MutableWhole other, Integer otherSign) {
        if (other.zero) {
            return;
        }
        else if (this.zero || this.sign == otherSign) {
            inplaceAddUnsigned(other);
            this.signValue = otherSign;
        }
        else { // opposite signs
            switch (compareMagnitude(this.wordsSize, this.words,
                                     other.wordsSize, other.words))
            case (equal) {
                this.signValue = 0;
                while (wordsSize > 0) {
                    wordsSize--;
                    setw(words, wordsSize, 0);
                }
            }
            case (larger) {
                subtract(this.wordsSize, this.words,
                         other.wordsSize, other.words,
                         this.wordsSize, this.words);
                wordsSize = realSize(words, wordsSize);
            }
            case (smaller) {
                if (sizew(words) >= other.wordsSize) {
                    // inplace can be done
                    subtract(other.wordsSize, other.words,
                             this.wordsSize, this.words,
                             this.wordsSize, this.words);
                    wordsSize = realSize(words, wordsSize);
                }
                else {
                    words = subtract(other.wordsSize, other.words,
                                     this.wordsSize, this.words);
                    wordsSize = realSize(words, -1);
                }
                this.signValue = this.sign.negated;
            }
        }
    }

    void inplaceAddUnsigned(MutableWhole other) {
        // assert(!other.zero)

        Integer rSize =
                if (this.zero)
                    then other.wordsSize
                    else 1 + largest(this.wordsSize,
                                     other.wordsSize);

        if (sizew(words) >= rSize) {
            add(this.wordsSize, this.words,
                other.wordsSize, other.words,
                rSize, this.words);
            wordsSize = realSize(words, rSize);
        }
        else {
            words = add(this.wordsSize, this.words,
                        other.wordsSize, other.words);
            wordsSize = realSize(words, -1);
        }
    }

    // TODO package private
    shared Boolean safelyAddressable
        // slightly underestimate for performance
        =>  wordsSize < 2 ||
            (wordsSize == 2 &&
             getw(words, 1)
                 .rightLogicalShift(wordBits-1) == 0);
}