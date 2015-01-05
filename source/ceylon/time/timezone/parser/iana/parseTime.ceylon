import ceylon.time {
    time,
    Time
}
import ceylon.time.timezone.model {
    AtTime,
    AtWallClockTime,
    AtNauticalTime,
    AtUtcTime,
    AtLocalMeanTime,
    AtGmtTime
}

"Alias to represent a specific signal:
 * Positive = 1
 * Negative = -1"
shared alias Signal => Integer;

[AtTime, Signal] parseTime(String atTime) {
    if( atTime.equals("-") ) {
        return [AtWallClockTime(time(0, 0)), 1];
    }
    value signal = atTime.startsWith("-") then -1 else 1;
    value position = atTime.startsWith("-") then 1 else 0;
    
    if(! atTime.firstOccurrence(':') exists ) {
        assert(exists hours = parseInteger(atTime.spanFrom(position)));
        return [AtWallClockTime(adjustToEndOfDayIfNecessary(hours, 0)), signal];
    }
    
    value indexes = atTime.indexesWhere(':'.equals).sequence();
    
    assert( exists firstIndex = indexes[0] );
    assert( exists hours = parseInteger(atTime.span(position, firstIndex-1)));
    assert( exists minutes = parseInteger(atTime.span(firstIndex +1,firstIndex  + 2 )));
    variable value partialTime = adjustToEndOfDayIfNecessary( hours, minutes ); 
    AtTime ruleDefinition;
    if( indexes.size == 1 ) {
        ruleDefinition = atTimeDefinition(partialTime, atTime.spanFrom(firstIndex + 3));
    } else {
        assert( exists secondIndex = indexes[1] );  
        assert( exists seconds = parseInteger(atTime.span(secondIndex + 1 ,secondIndex  + 2 ))); 
        
        partialTime = partialTime.plusSeconds(seconds);   
        ruleDefinition = atTimeDefinition(partialTime, atTime.spanFrom(secondIndex + 3));
    }
    
    return [ruleDefinition, signal];
}

AtTime atTimeDefinition(Time time, String token) {
    switch (token)
    case("s", "S") {
        return AtLocalMeanTime(time);
    }
    case("u", "U") {
        return AtUtcTime(time);
    }
    case("z", "Z") {
        return AtNauticalTime(time);
    }
    case("g", "G") {
        return AtGmtTime(time);
    }
    case("w", "W") {
        return AtWallClockTime(time);
    } 
    else {
        return AtWallClockTime(time);
    }
}

"The rules represent the end of day as 24:00 and our ceylon.time.Time 
 does have another semantic for this."
Time adjustToEndOfDayIfNecessary(Integer hours, Integer minutes) {
    if( hours == 24 && minutes == 0 ) {
        return time(23,59,59,999);
    }
    return time( hours, minutes );
}