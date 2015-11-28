import ceylon.buffer.base64 {
    Base64String,
    Base64Byte,
    base64StringStandard,
    base64StringUrl,
    base64ByteStandard,
    base64ByteUrl
}
import ceylon.buffer {
    ByteBuffer
}
import ceylon.collection {
    HashSet
}

Set<String> capitalizations(String base) {
    value permutations = HashSet<String>();
    if (exists head = base.first) {
        for (tail in capitalizations(base.spanFrom(1))) {
            permutations.add(head.uppercased.string + tail);
            permutations.add(head.lowercased.string + tail);
        }
    } else {
        // base is the empty string
        permutations.add(base);
    }
    return permutations;
}

shared Map<String,CodecOrLower> buildCodecLookup<CodecOrLower>({CodecOrLower*} codecs)
        given CodecOrLower satisfies Codec {
    return map<String,CodecOrLower> {
        for (codec in codecs)
            for (codecAlias in codec.aliases)
                for (p in capitalizations(codecAlias)) p->codec
    };
}

//shared Map<String,Codec> codecsByAlias = buildCodecLookup(nothing);
shared Map<String,Base64String> base64StringByAlias = buildCodecLookup {
    base64StringStandard,
    base64StringUrl
};
shared Map<String,Base64Byte> base64ByteByAlias = buildCodecLookup {
    base64ByteStandard,
    base64ByteUrl
};

shared [IncrementalCodec<ToMutable,ToImmutable,ToSingle,FromMutable,FromImmutable,FromSingle>*]
buildAuction<ToMutable, ToImmutable, ToSingle, FromMutable, FromImmutable, FromSingle>
        ({IncrementalCodec<ToMutable,ToImmutable,ToSingle,
        FromMutable,FromImmutable,FromSingle>+} bidders)
        ({FromSingle*} lot) {
    value bids = map<Integer,
        IncrementalCodec<ToMutable,ToImmutable,ToSingle,FromMutable,FromImmutable,FromSingle>>
        { for (bidder in bidders) bidder.encodeBid(lot) -> bidder };
    return bids.filterKeys((k) => k > 0).sort(increasingKey)*.item;
}

shared [IncrementalCodec<ByteBuffer,Array<Byte>,Byte,
    ByteBuffer,Array<Byte>,Byte>*]({Byte*}) auctionByteToByteEncode = buildAuction {
    base64ByteStandard,
    base64ByteUrl
};

void asd() {
    value bytes = [0.byte];
    value results = auctionByteToByteEncode(bytes);
    assert (nonempty results);
    results.first.encode(bytes);
}

// TODO single and multi-round bidding of IncrementalCodecs for a small sample. With hint/force param?

// TODO should be something like https://github.com/libarchive/libarchive/wiki/FormatDetection
// TODO eventually need to add Format for things like tar, as libarchive has. IncrementalCodec is equiv. to libarchive filter?
// TODO stream Formats probably be done here, but to actually exctract need to do I/O,
// TODO so addon functionality for that goes into ceylon.io.
